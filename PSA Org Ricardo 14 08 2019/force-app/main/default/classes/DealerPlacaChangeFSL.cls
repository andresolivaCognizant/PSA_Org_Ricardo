/**
*   @Class          :   DealerPlacaChangeFSL.cls
*   @Author         :   Sergio López
*   @Created        :   18 Mar 2019
*   @Description    :   Placa changes for a Dealer, Process to manage Secondary Service Territories for Dealer
*
*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Author             Date             Description
*      Segio Lopez        18/03/2019       Creation.
*   ----------------------------------------------------------------------------------------------------------------------------
**/ 
public with sharing class DealerPlacaChangeFSL {
    
    /*********************************************************************************************************
    * @Method          : endSecTerrRelation
    * @Author          : Sergio Lopez
    * @Created         : 18/03/2019
    * @Description     : When a Dealer moves to other Placa or leave the Place it belongs. There are three cases:
    *                       A) Dealer moves to other Placa, keeps Primary Territory, Secondary Territories are removed and 
    *                           new Secondary Territories are created for the new Placa.
    *                       B) Dealer leaves the Placa, keeps Primary, Secondary Territories are removed and no more are created.
    *                       C) Dealer end its activity, end Territories and Service Resources. 
    *                  Common) All Service Appoinment related to the ended Territory and Service Resource are canceled and Owner is notified.
    * @params          : String. Dealer Account Id. 
    *                  : Boolean. True, Dealer ends activity; False, Dealer changes Placa.
    **********************************************************************************************************/
    public static void endSecTerrRelation(List<Account> lAccId, boolean dealerEnd){

        System.debug('@@@ DealerPlacaChangeFSL.endSecTerrRelation. LAcc: '+lAccId+' / Flag: '+dealerEnd);

        try {
            List<ServiceTerritoryMember> lSTMToUpd  = new List<ServiceTerritoryMember>();
            List<ServiceAppointment> lSAToUpd       = new List<ServiceAppointment>();
            List<ServiceResource> lSRToUpd          = new List<ServiceResource>();
            List<ServiceAppointment> lSApp          = new List<ServiceAppointment>();

            Set<String> setST       = new Set<String>();
            Set<String> setSR       = new Set<String>();
            Set<String> setSA       = new Set<String>();
            Set<String> setValSt    = new Set<String>();
            Set<Id> setSrOw         = new Set<Id>();

            List<ServiceTerritoryMember> lSTM;	
		
		    String query;

            query = 'SELECT Id, EffectiveStartDate, EffectiveEndDate, ServiceTerritoryId, ServiceResourceId FROM ServiceTerritoryMember WHERE ServiceTerritory.Account__c IN :lAccId';
    		
    		if (dealerEnd == true){
    			query += ' AND (TerritoryType = \'P\' OR TerritoryType = \'S\')';
    		} else {
                query += ' AND TerritoryType = \'S\'';
            } 
    		
    		query += ' AND (EffectiveEndDate = null OR EffectiveEndDate > TODAY)';
    		
    		System.debug('@@@endSecTerrRelation query: ' + query);
    		
    		//[SELECT Id, EffectiveEndDate, ServiceTerritoryId, ServiceResourceId FROM ServiceTerritoryMember 
            //                                    WHERE ServiceTerritory.Account__c IN :lAccId
            //                                      AND TerritoryType = 'S' OR 'P'
            //                                      AND (EffectiveEndDate = null
            //                                       OR EffectiveEndDate > TODAY)
    		lSTM = Database.query(query);

            // Ending Secondary Territory Members, Dealer goes out from Placa
            for (ServiceTerritoryMember stm : lSTM){

                System.debug('## EffectiveStartDate: '+ stm.EffectiveStartDate);
                stm.EffectiveEndDate = System.Now();
                System.debug('## EffectiveEndDate: '+ stm.EffectiveEndDate);

                lSTMToUpd.add(stm);
                setST.add(stm.ServiceTerritoryId);
                System.debug('## ServiceTerritoryId: '+stm.ServiceTerritoryId);
                setSR.add(stm.ServiceResourceId);
                System.debug('## ServiceResourceId: '+stm.ServiceResourceId);
            }
            
            if (!lSTMToUpd.isEmpty()){
                update lSTMToUpd;
            }
            
            // DELETE - I 
            List<AssignedResource> listName = [SELECT Id, ServiceAppointment.ServiceTerritoryId, ServiceResourceId
                                              FROM AssignedResource];

            System.debug('## setSR: '+setSR);
            System.debug('## setST: '+setST);
            System.debug('## listNAME: '+listName);
            // DELETE - E


            // Collect Assigned Resources for ending Appointment
            if (!setST.isEmpty() && !setSR.isEmpty()){
                for (AssignedResource ar : [SELECT Id, ServiceAppointmentId
                                              FROM AssignedResource
                                             WHERE ServiceResourceId IN :setSR
                                               AND ServiceAppointment.ServiceTerritoryId IN :setST]){
                    setSA.add(ar.ServiceAppointmentId);
                }
            }            

            // Collect Service Resources for ending Territories and Inactive them
            if (!setSR.isEmpty() && dealerEnd){
                for (ServiceResource sr : [SELECT Id, IsActive, RelatedRecordId
                                              FROM ServiceResource
                                             WHERE Id IN :setSR
                                               AND IsActive = true]){
                    sr.IsActive = false;

                    lSRToUpd.add(sr);
                    setSrOw.add(sr.RelatedRecordId);
                }
            }

            if (!lSRToUpd.isEmpty() && dealerEnd){
                ServiceResourceTriggerHandler.dontRunTrigger();

                update lSRToUpd;
            }         

            Id keepOwner = null;
            String email = '';
            String fName = '';
 
            UtilSetting__mdt[] util = [SELECT Value__c FROM UtilSetting__mdt WHERE DeveloperName = 'Service_Appointment_Valid_Status' Limit 1];    

            String[] valStatus = util[0].Value__c.split(',');

            for (integer ivs=0;ivs<valStatus.size();ivs++) {
                setValSt.add(valStatus[ivs]);
            } 

            // Collect Service Appointment from ending territories. Service Apps will be canceled.
            if (!setSA.isEmpty()){
                for (ServiceAppointment sa : [SELECT Id, OwnerId, Owner.Email, Owner.FirstName, Status, AppointmentNumber
                                              FROM ServiceAppointment
                                             WHERE Id IN :setSA
                                               AND Status IN :setValSt
                                               AND SchedStartTime > YESTERDAY 
                                             ORDER BY OwnerId]){

                    sa.Status = 'Canceled';

                    if (keepOwner != sa.OwnerId){
                        if (keepOwner != null && !lSApp.isEmpty()){ 
                            //Send Canceled Servbice Appointment notification
                            lSApp.clear(); 
                        }

                        keepOwner = sa.OwnerId;
                        email = sa.Owner.Email;
                        fName = sa.Owner.FirstName;
                        lSApp.add(sa);
                    } else {
                        lSApp.add(sa);
                    }

                    lSAToUpd.add(sa);
                }
            }

            if (!lSApp.isEmpty()){
                sendNotifcation(email, fName, lSApp);
            }

            if (!lSAToUpd.isEmpty()){
                update lSAToUpd;
            }

            // Process for sharing Service Resources with other Placa's Dealer
            if (!dealerEnd){
                System.debug('### lAccId: ' + lAccId);
                // Get Placa Id query
                List<Account> lPlacaId = [SELECT OwnerId FROM Account WHERE Id IN :lAccId];

                System.debug('### lPlacaId: ' + lPlacaId);

                Set<Id> setPlaca = new Set<Id>();

                for (Account acc : lPlacaId){
                    setPlaca.add(acc.OwnerId);
                }

                // Process to check other Dealer for the Placa and share Service Resources for Test Drive between them
                List<Account> lDealer = [SELECT Id FROM Account WHERE Id NOT IN :lAccId 
                                            AND OwnerId IN :setPlaca 
                                            AND Owner.TECH_GroupOfDealersStockSharing__c = true 
                                            AND RecordType.name = 'Dealer'];

                System.debug('### lDealer: ' + lDealer);

                if (!lDealer.isEmpty()){
                    startSecTerrRelation(lDealer);
                }
            }           
            
        } catch(dmlexception e) {
            string error = 'DMLexception ERROR DealerPlacaChangeFSL.endSecTerrRelation --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
            system.debug('Error: '+error);
        } catch(exception e){
            string error = 'Exception ERROR DealerPlacaChangeFSL.endSecTerrRelation --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
            system.debug('Error: '+error);
        } 
    }

    /*********************************************************************************************************
    * @Method          : startSecTerrRelation
    * @Author          : Sergio Lopez
    * @Created         : 18/03/2019
    * @Description     : When a Dealer moves to other Placa new Secondary Territories are created for the new Placa.
    * @params          : List. Dealer Accounts Id. 
    **********************************************************************************************************/
    public static void startSecTerrRelation(List<Account> lAccount){

        System.debug('@@@ DealerPlacaChangeFSL.startSecTerrRelation. LAcc: '+lAccount);

        try {
            List<ServiceTerritoryMember> lSTMToInsert = new List<ServiceTerritoryMember>();

            List<ServiceTerritory> lST = [SELECT Id, OperatingHoursId, Account__r.Name, Account__r.OwnerId FROM ServiceTerritory WHERE Account__c IN :lAccount AND IsActive = true];

            List<ServiceResource> lSR = [SELECT Id, Account__r.OwnerId FROM ServiceResource WHERE Account__c IN :lAccount AND IsActive = true];

            for (ServiceResource sr : lSR){
                for (ServiceTerritory st : lST){
                    if (sr.Account__r.OwnerId == st.Account__r.OwnerId){
                        ServiceTerritoryMember stm = new ServiceTerritoryMember();

                        stm.TerritoryType       = 'S';
                        stm.ServiceResourceId   = sr.Id;
                        stm.ServiceTerritoryId  = st.Id;
                        stm.OperatingHoursId    = st.OperatingHoursId;
                        stm.EffectiveStartDate  = System.now();
                        stm.ExternalId__c       = st.Account__r.Name;

                        System.debug('### stm: ' + stm);

                        lSTMToInsert.add(stm);
                    }
                }
            }

            if (!lSTMToInsert.isEmpty()){
                insert lSTMToInsert;
            }
        } catch(dmlexception e) {
            string error = 'DMLexception ERROR DealerPlacaChangeFSL.startSecTerrRelation --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
            system.debug('Error: '+error);
        } catch(exception e){
            string error = 'Exception ERROR DealerPlacaChangeFSL.startSecTerrRelation --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
            system.debug('Error: '+error);
        } 
    }    

    /*********************************************************************************************************
    * @Method          : sendNotifcation
    * @Author          : Sergio Lopez
    * @Created         : 18/03/2019
    * @Description     : When a Service Appointment are canceled, a notification is send to the owners.
    * @params          : String, email. 
    *                    String, first name.
    *                    List, of Service App. Numbers.
    **********************************************************************************************************/
    public static void sendNotifcation(String email, String firstName, List<ServiceAppointment> lSApp) {

        System.debug('@@@ DealerPlacaChangeFSL.sendNotifcation. email: '+email+' / firstName: '+firstName+' / lSApp: '+lSApp);

        // Step 0: Create a master list to hold the emails we'll send
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    
        // Step 1: Create a new Email
        Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
    
        // Step 2: Set list of people who should get the email
        List<String> sendTo = new List<String>();
        //sendTo.add(myContact.Email);
        //sendTo.add('patil.rajan@gmail.com');
        sendTo.add(email);
        mail.setToAddresses(sendTo);
    
        // Step 3: Set who the email is sent from
        //mail.setReplyTo(UserInfo.getUserEmail());
        //mail.setSenderDisplayName(UserInfo.getFirstName());
         
        // (Optional) Set list of people who should be CC'ed
        //List<String> ccTo = new List<String>();
        //ccTo.add('business@example.com');
        //mail.setCcAddresses(ccTo);

        // Step 4. Set email contents - you can use variables!
        mail.setSubject(Label.SResInactiveSubjectNot);

        String fullFileURL = System.URL.getSalesforceBaseUrl().toExternalForm();

        System.debug('##fullFileURL: '+fullFileURL);

        String body = Label.EmailSalutation + ' ' + firstName+ ', ';
        body += '<br/>';
        body += '<br/>' + Label.SResInactiveBodyNot;
    
        for (ServiceAppointment sa : lSApp) { 
            body += '<br><a href='+fullFileURL+'/'+sa.Id+'><p>'+sa.AppointmentNumber+'</p></a>';
        }
        
        body += '<br/>-------------------------------------';
        body += '<br/>';
        body += '<br/>' + Label.GoodbyeMsg;

        mail.setHtmlBody(body);
    
        System.debug('## mail: '+mail);
        // Step 5. Add your email to the master list
        mails.add(mail);   
    }
}
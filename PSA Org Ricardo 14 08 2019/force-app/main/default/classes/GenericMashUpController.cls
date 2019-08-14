/**
    *   @Class          :   GenericMashUpController 
    *
    *   @Author         :   Sergio Lopez
    *   @Created        :   08 May 2018
    *   @Description    :   Controller Class for Generic Mashup component
    *
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer           		Date                     Description	
    *	   Sergio Lopez				08/05/2018				 Creation.
    *	   Ricardo Pereira          19/06/2019				 Splitted GenericMashUpController method to allow Country and Brand as parameters.
    *   ----------------------------------------------------------------------------------------------------------------------------
**/
public with sharing class GenericMashUpController {

    @AuraEnabled
    public static String getFlowMUpParams(String mUpName) {
        return getFlowMUpParamsByBrandCountry(mUpName, null, null);
    }

    @AuraEnabled
    public static String getFlowMUpParamsByBrandCountry(String mUpName, String countryParam, String brandParam) {

        system.debug('getFlowMUpParams mUpName --> ' + mUpName); 

        User[] uData = [
            SELECT
                Id,
                Country__c,
                Brand__c,
                Contact.Account.ShortVNContractNumber__c,
                Contact.Account.TECH_ShortAgentContractNumber__c,
                LanguageLocaleKey,
                ContactId
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];

        String country = countryParam == null || countryParam == '' ? uData[0].Country__c : countryParam;
        String brand   = brandParam == null || brandParam == '' ? uData[0].Brand__c : brandParam;

        String url = '';
        String qGen = '';
        String sObjectApiName = '';

        try {
            
            sObjectApiName = 'Generic_MashUP__mdt';
        
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get(sObjectApiName).getDescribe().fields.getMap();
     
            String genMdtMashupFields = '';
          
            for(String fieldName : fieldMap.keyset()){
                if (genMdtMashupFields == null || genMdtMashupFields == ''){
                    genMdtMashupFields = fieldName;
                }else{
                    genMdtMashupFields = genMdtMashupFields + ', ' + fieldName;
                }
            }
               
            qGen += 'SELECT ' +genMdtMashupFields+ ' FROM Generic_MashUP__mdt';		
            qGen += ' WHERE Util_MdtObj_DevName__c = :mUpName AND Country__c = :country AND Brand__c = :brand LIMIT 1';

            system.debug('getMUpParams QUERY --> ' + qGen);
     
            List<Generic_MashUP__mdt> lParams = Database.query(qGen);
            
            system.debug('getMUpParams lParams --> ' + lParams);
                        
               if (lParams != null && !lParams.isEmpty()) {
                   url = (String)lParams.get(0).get('Param_URL__c');
               } else {
                throw new GMasUpexception('No URL had been recovered for MashUp: '+mUpName+''); 
            }

        } catch(dmlexception e) { 
            url = 'DMLexception ERROR GenericMashUpController.getFlowMUpParams --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
        }  catch(exception e){
            url = 'exception ERROR GenericMashUpController.getFlowMUpParams --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
        }
        
        System.debug('getFlowMUpParams URL: ' + url); 
        
        return url;
    }
    
    @AuraEnabled
    public static String getMUpParams(String mUpName, String objName, Id recId) {
        
        system.debug('getMUpParams mUpName --> ' + mUpName); 
        system.debug('getMUpParams objName --> ' + objName); 
        system.debug('getMUpParams recId --> ' + recId); 
        
        User[] uData = [SELECT Id, Country__c, Brand__c, Contact.Account.ShortVNContractNumber__c, Contact.Account.TECH_ShortAgentContractNumber__c, 
                        LanguageLocaleKey, ContactId, AccountId 
                        FROM User 
                        WHERE Id = :UserInfo.getUserId() LIMIT 1];
        //String dealerId = ;
        
        String country = uData[0].Country__c;
        String brand   = uData[0].Brand__c;
        
        String url = '';
        String qGen = '';
        String sObjectApiName = '';
        
        try {
            String oType = '';
            String customerType = '';
            String oStatus = '';
            
            Order[] accOrder;
            SBQQ__Quote__c[] accQuote;
            Account[] accAccount;
            Asset[] accAsset;
            
            String sdhContactPersonId = '';
            String sdhCustomerId = '';
            String sdhDriverId = '';
            String sdhLeaserContactPersonId = '';
            String sdhLessorId = '';
            String sdhOrderId = '';
            String sdhQuoteId = '';
            String sdhVpoId = '';
            String sdhContractId = '';

            
            if (mUpName == 'Order Delivery Creation' || mUpName == 'Order Delivery Edition' || mUpName == 'Order Edition'){
                accOrder = [
                    SELECT
                        Id,
                        AccountId,
                        Order_Type__c,
                        OpportunityId,
                        SBQQ__Quote__c,
                        OrderFormId__c,
                        Leaser__c,
                        Driver__c,
                        ShipToContactId,
                        Account.RecordType.Name,
                        Status,
                        OPV_Contract_Code__c,
                        OrderFormId__r.OPV_OfferCode__c,
                        SBQQ__Quote__r.OPV_OfferCode__c
                    FROM Order 
                    WHERE Id = :recId
                    LIMIT 1
                ];

                for ( AccountExtRef__c ref: [
                    SELECT ExternalId__c, Account__c
                    FROM AccountExtRef__c 
                    WHERE
                        Brand__c = :brand AND
                        Country__c = :country AND
                        System__c = 'CRM' AND
                        Account__c != null AND
                        (Account__c = :accOrder[0].Driver__c OR Account__c = :accOrder[0].AccountId)
                ]){
                    if (ref.Account__c == accOrder[0].Driver__c) {
                        sdhDriverId = ref.ExternalId__c;
                    } else if (ref.Account__c == accOrder[0].AccountId) {
                        sdhCustomerId = ref.ExternalId__c;
                    }
                }

                if (accOrder[0].Account.RecordType.Name == 'B2C_PA'){
                    customerType = 'B2C';
                } else if (accOrder[0].Account.RecordType.Name == 'B2B') {
                    customerType = 'B2B';
                } else {
                    customerType = null;
                }

                oType = accOrder[0].Order_Type__c;
                oStatus = accOrder[0].Status;
                sdhOrderId = accOrder[0].OPV_Contract_Code__c;
                sdhContractId = String.valueOf(accOrder[0].OrderFormId__r.OPV_OfferCode__c);

                if (oType == null || oType == ''){
                    throw new GMasUpexception('Type for the Quote/Order Form/Order/Delivery is not defined');
                }
                
            /* BEGIN - Manuel Medina - C1ST-8697 - New logic to enable Contract Validation mashup - 28092018 */
            /* mUpName.equals( 'Contract Validation' ) logic was added to current if */
            } else if (mUpName == 'Quote Edition' || mUpName == 'Contract Edition' || mUpName == 'Quote Delivery Creation' || mUpName == 'Quote Delivery Edition' || mUpName.equals( 'Contract Validation' ) ){
            /* END - Manuel Medina - 28092018 */
                
                accQuote = [SELECT Id, SBQQ__Account__c, OfferType__c, SBQQ__Opportunity2__c, SBQQ__Account__r.RecordType.Name, SBQQ__PrimaryContact__c, OPV_OfferCode__c FROM SBQQ__Quote__c WHERE Id = :recId LIMIT 1];
                
                if (accQuote[0].SBQQ__Account__r.RecordType.Name == 'B2C_PA'){
                    customerType = 'B2C';
                } else if (accQuote[0].SBQQ__Account__r.RecordType.Name == 'B2B') {
                    customerType = 'B2B';
                } else {
                    customerType = null;
                }

                for(AccountExtRef__c ref: [SELECT ExternalId__c 
                                            FROM AccountExtRef__c 
                                            WHERE Brand__c = :brand AND Country__c = :country
                                            AND System__c = 'CRM'
                                            AND Account__c != null
                                            AND Account__c = :accQuote[0].SBQQ__Account__c]){
                    
                    sdhCustomerId = ref.ExternalId__c;
                }

                for(ContactExternalReference__c ref: [SELECT ExternalId__c 
                                            FROM ContactExternalReference__c 
                                            WHERE Dealer__c = :uData[0].AccountId AND Dealer__c != null
                                            AND System__c = 'CRM'
                                            AND Contact__c != null
                                            AND Contact__c = :accQuote[0].SBQQ__PrimaryContact__c]){
                    
                    sdhContactPersonId = ref.ExternalId__c;
                }

                sdhQuoteId = '' + accQuote[0].OPV_OfferCode__c;
                sdhContractId = '' + accQuote[0].OPV_OfferCode__c;
                
                oType = accQuote[0].OfferType__c;
                            
                if (oType == null || oType == ''){
                    throw new GMasUpexception('Type for the Quote/Order Form/Order/Delivery is not defined');
                }
            } else if (mUpName == 'Service Contract' || mUpName == 'VPO Creation') {
                accAccount = [SELECT Id, RecordType.Name FROM Account WHERE Id = :recId LIMIT 1];
                
                if (accAccount[0].RecordType.Name == 'B2C_PA'){
                    customerType = 'B2C';
                } else if (accAccount[0].RecordType.Name == 'B2B') {
                    customerType = 'B2B';
                } else {
                    customerType = null;
                }

                for(AccountExtRef__c ref: [SELECT ExternalId__c 
                                            FROM AccountExtRef__c 
                                            WHERE Brand__c = :brand AND Country__c = :country
                                            AND System__c = 'CRM'
                                            AND Account__c != null
                                            AND Account__c = :accAccount[0].Id]){
                    
                    sdhCustomerId = ref.ExternalId__c;
                }


            } else if(mUpName == 'VPO Modification' || mUpName == 'Additional actions forms options'){
                
                accAsset = [SELECT Id, AccountId, Account.RecordType.Name, OPVAssetCode__c FROM Asset WHERE Id=:recId];

                if (accAsset[0].Account.RecordType.Name == 'B2C_PA'){
                    customerType = 'B2C';
                } else if (accAsset[0].Account.RecordType.Name == 'B2B') {
                    customerType = 'B2B';
                } else {
                    customerType = null;
                }

                for(AccountExtRef__c ref: [SELECT ExternalId__c 
                                            FROM AccountExtRef__c 
                                            WHERE Brand__c = :brand AND Country__c = :country
                                            AND System__c = 'CRM'
                                            AND Account__c != null
                                            AND Account__c = :accAsset[0].AccountId]){
                    
                    sdhCustomerId = ref.ExternalId__c;
                }

                sdhVpoId = accAsset[0].OPVAssetCode__c;
            }
            

            if (mUpName == 'Order Delivery Creation' || mUpName == 'Quote Delivery Creation'){
                mUpName = oType + ' Delivery Creation';
            } else if (mUpName == 'Order Delivery Edition' || mUpName == 'Quote Delivery Edition'){
                mUpName = oType + ' Delivery Edition';
            } else if (mUpName == 'Quote Edition'){
                mUpName = 'Quote ' + oType +' Edition';
            } else if (mUpName == 'Contract Edition'){
                mUpName = 'Contract ' + oType +' Edition';
            } else if (mUpName == 'Order Edition'){
                if(oStatus == '9'){
                    mUpName = oType + ' Delivery Edition';
                }else{
                    mUpName = 'Order ' + oType +' Edition';
                }
            }
            
            /* BEGIN - Manuel Medina - C1ST-8697 - New logic to enable Contract Validation mashup - 28092018 */
            else if( mUpName.equals( 'Contract Validation' ) ){
                mUpName			= 'Contract ' + oType + ' Validation';
            }
            /* END - Manuel Medina - 28092018 */
                                        
            sObjectApiName = 'Generic_MashUP__mdt';
        
              Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
              Map<String, Schema.SObjectField> fieldMap = schemaMap.get(sObjectApiName).getDescribe().fields.getMap();
               
              String genMdtMashupFields = '';

              for(String fieldName : fieldMap.keyset()){
                  if (genMdtMashupFields == null || genMdtMashupFields == ''){
                      genMdtMashupFields = fieldName;
                  }else{
                       genMdtMashupFields = genMdtMashupFields + ', ' + fieldName;
                  }
              }

             qGen += 'SELECT ' +genMdtMashupFields+ ' FROM Generic_MashUP__mdt';		
            qGen += ' WHERE Util_MdtObj_DevName__c = :mUpName AND Country__c = :country AND Brand__c = :brand LIMIT 1';
    
            system.debug('getMUpParams QUERY Util_MdtObj_DevName__c --> ' + mUpName);
            system.debug('getMUpParams QUERY Country__c --> ' + country);
            system.debug('getMUpParams QUERY Brand__c --> ' + brand);
            system.debug('getMUpParams QUERY --> ' + qGen);
     
            List<Generic_MashUP__mdt> lParams = Database.query(qGen);
            
            system.debug('getMUpParams lParams --> ' + lParams);



               if (lParams != null && !lParams.isEmpty() && lParams.size()>0){		   		
                   url += (String)lParams.get(0).get('Param_URL__c');
                   
                   url += '&dealerId=' +uData[0].Contact.Account.ShortVNContractNumber__c+'';
                url += '&salesAgentId=' +uData[0].Contact.Account.TECH_ShortAgentContractNumber__c+'';
                url += '&localeId=' +uData[0].LanguageLocaleKey+'';
                url += '&brand=' +uData[0].Brand__c+'';
                    
                if (mUpName == 'VN Delivery Creation'){
                    url += '&slOrderId=' +accOrder[0].Id+'';
                    url += '&slCustomerId=' +accOrder[0].AccountId+'';
                    url += '&slDriverId=' +accOrder[0].Driver__c+'';
                    url += '&slLessorId=' +accOrder[0].Leaser__c+'';
                    url += '&slContactPersonId=' +accOrder[0].ShipToContactId+'';
                    url += '&slOpportunityId=' +accOrder[0].OpportunityId+'';
                    url += '&slCustomerType=' +customerType+'';
                } else if (mUpName == 'VN Delivery Edition' || mUpName == 'VD Delivery Edition'){
                    // C1ST-18358 - B
                    url += '&slContactPersonId=' + accOrder[0].ShipToContactId + '';
                    //url += '&slOrderId=' +accOrder[0].Id+'';
                    if (mUpName == 'VN Delivery Edition') {
                        url += '&slOrderId=' +accOrder[0].Id+'';
                    } else if (mUpName == 'VD Delivery Edition'){
                        url += '&slContractId=' +accOrder[0].OrderFormId__c+'';
                    }
                    // C1ST-18358 - E
                    url += '&slCustomerId=' +accOrder[0].AccountId+'';
                    url += '&slCustomerType=' +customerType+'';
                    url += '&sdhOrderId=' +sdhOrderId+'';
                    url += '&sdhCustomerId=' +sdhCustomerId+'';
                } else if (mUpName == 'VO Delivery Edition'){
                    // C1ST-18358 - B
                    //url += '&slOrderId=' +accOrder[0].Id+'';
                    url += '&slContractId=' +accOrder[0].OrderFormId__c+'';
                    url += '&slContactPersonId=' + accOrder[0].ShipToContactId + '';
                    // C1ST-18358 - E
                    url += '&slCustomerId=' +accOrder[0].AccountId+'';
                    url += '&slCustomerType=' +customerType+'';
                    url += '&sdhContractId=' +sdhContractId+'';
                    url += '&sdhCustomerId=' +sdhCustomerId+'';
                } else if (mUpName == 'VO Delivery Creation' || mUpName == 'VD Delivery Creation'){
                    url += '&slContractId=' +accQuote[0].Id+'';
                    url += '&slCustomerId=' +accQuote[0].SBQQ__Account__c+'';
                    url += '&slCustomerType=' +customerType+'';
                    url += '&slContactPersonId=' + accQuote[0].SBQQ__PrimaryContact__c+'';
                    url += '&slOpportunityId=' + accQuote[0].SBQQ__Opportunity2__c+'';
                } else if (mUpName == 'Quote VN Edition' || mUpName == 'Quote VD Edition' || mUpName == 'Quote VO Edition'){
                       url += '&slQuoteId=' +accQuote[0].Id+'';
                    url += '&slCustomerId=' +accQuote[0].SBQQ__Account__c+'';
                    url += '&slOpportunityId=' +accQuote[0].SBQQ__Opportunity2__c+'';
                    url += '&slContactPersonId=' +accQuote[0].SBQQ__PrimaryContact__c+'';
                    url += '&slCustomerType=' +customerType+'';
                    url += '&sdhCustomerId=' +sdhCustomerId+'';
                    url += '&sdhQuoteId=' +sdhQuoteId+'';
                    url += '&sdhContactPersonId=' +sdhContactPersonId+'';
                
                /* BEGIN - Manuel Medina - C1ST-8697 - New logic to enable Contract Validation mashup - 28092018 */
                /* mUpName.equals( 'Contract ' + oType + ' Validation' ) logic was added to current if */
                } else if (mUpName == 'Contract VN Edition' || mUpName == 'Contract VD Edition' || mUpName == 'Contract VO Edition' || mUpName.equals( 'Contract ' + oType + ' Validation' ) ){
                /* END - Manuel Medina - 28092018 */
                   
                    url += '&slContractId=' +accQuote[0].Id+'';
                    url += '&slCustomerId=' +accQuote[0].SBQQ__Account__c+'';
                    url += '&slOpportunityId=' +accQuote[0].SBQQ__Opportunity2__c+'';
                    url += '&slCustomerType=' +customerType+'';
                    
                    if (customerType == 'B2B') {
                        url += '&slContactPersonId=' + accQuote[0].SBQQ__PrimaryContact__c+'';
                    }
                    
                    url += '&sdhCustomerId=' +sdhCustomerId+'';
                    url += '&sdhContractId=' +sdhContractId+'';
                    url += '&sdhContactPersonId=' +sdhContactPersonId+'';

                } else if (mUpName == 'Order VN Edition'){
                    url += '&slOrderId=' +accOrder[0].Id+'';
                    url += '&slContractId=' +accOrder[0].SBQQ__Quote__c+'';
                    url += '&slCustomerId=' + accOrder[0].AccountId+'';
                    url += '&slOpportunityId=' + accOrder[0].OpportunityId+'';
                    url += '&slCustomerType=' + customerType+'';
                    if (customerType == 'B2B') {
                        url += '&slContactPersonId=' + accOrder[0].ShipToContactId+'';
                    }
                    url += '&sdhOrderId=' +sdhOrderId+'';
                    url += '&sdhCustomerId=' +sdhCustomerId+'';
                /* BEGIN (06/11/18) - Ruben Moreno - C1ST-10166 */
                } else if (mUpName == 'Order VN Creation'){
                    url += '&slCustomerId=' + accOrder[0].AccountId+'';
                    url += '&slContractId=' +accOrder[0].SBQQ__Quote__c+'';
                    url += '&slDriverId=' +accOrder[0].Driver__c+'';
                    url += '&slLessorId=' +accOrder[0].Leaser__c+'';
                    if (customerType == 'B2B') {
                        url += '&slContactPersonId=' + accOrder[0].ShipToContactId+'';
                    }                    
                    url += '&slOpportunityId=' + accOrder[0].OpportunityId+'';
                    url += '&slCustomerType=' + customerType+'';
                } else if (mUpName == 'Service Contract'){
                    url += '&slCustomerId=' +accAccount[0].Id+'';
                    url += '&slCustomerType=' +customerType+'';
                } else if (mUpName == 'VPO Creation'){
                    url += '&slCustomerId=' +accAccount[0].Id+'';
                    url += '&slCustomerType=' +customerType+'';
                    url += '&sdhCustomerId=' +sdhCustomerId+'';

                }else if (mUpName == 'VPO Modification' || mUpName == 'Additional actions forms options'){
                    url += '&slVpoId=' +accAsset[0].Id+'';
                    url += '&slCustomerId=' +accAsset[0].AccountId+'';
                    url += '&slCustomerType=' +customerType+'';
                    url += '&sdhCustomerId=' +sdhCustomerId+'';
                    url += '&sdhVpoId=' +sdhVpoId+'';
                }
                /* END - Ricardo Pereira - 11012019 */
                   else {
                       throw new GMasUpexception('MashUp name Incorrrect, NO parameters found, current: '+mUpName+'');
                   }
                       
                   //url +='&protocol=https';		    		
            } else {
                throw new GMasUpexception('Functionality not available at the moment, for '+mUpName+' MashUP');
            }
        
        } catch(dmlexception e) {
            url = 'DMLexception ERROR GenericMashUpController.getMUpParams --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
            return url;
        } catch(exception e){
            url = 'exception ERROR: ' + e.getMessage();
            //url = 'exception ERROR GenericMashUpController.getMUpParams --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
            return url;
        }
        
        system.debug('getMUpParams url --> ' + url);
        
        return url;
        
    }
    
    public class GMasUpexception extends exception{
        // Custom exception class
    }
    
}
/*
-- - Name         : LeadConversionProcess
-- - Author       : Ruben Moreno Leyva
-- - Date         : 15/02/2018
-- - Description  : Lead Conversion Process
--
-- - History:
-- - Date       Author  Version  Comments
-- -----------  -----   -------  ---------------------------------------
-- 15/02/2018   RML     1.0      Creation
-- 24/04/2018   RML     2.0      Added Consents creation.
-- 23/05/2018   RML     3.0      Fixed access bug.
-- 05/06/2018   RML     3.1      Added Email subject.
-- 12/06/2018   RML     3.2      Added map opportunity field (TECH_Web2Lead__c)
-- 19/09/2018   RML     3.3      Added map opportunity field (TECH_Web2Lead__c)
-- 19/02/2019   DR      3.4      Opportunity's name mapping update
*/

public without sharing class LeadConversionProcess {
    
    private final static string LEAD_NURTURING      = 'Nurturing'; 
    private final static string LEAD_QUALIFIED      = 'Qualified';
    private final static string LEAD_DISCARDED      = 'Discarded';
    private final static string EMAIL_SUBJECT       = Label.LeadConversionErrorSubject;
    private final static string OPP_NEGOTIATION     = '2';
    private final static string OPP_NEEDANALYSIS    = '1';
    private final static string OPP_CLOSEDLOST      = '7';
    private final static string UTIL_SETTING        = 'PSADealerCommunity';
    private final static id RT_LEADB2C              = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
    private final static id RT_LEADB2B              = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
    private final static id RT_ACCOUNTB2C           = Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2C_PA').getRecordTypeId();
    private final static id RT_ACCOUNTB2B           = Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
    private final static String TYPE_ACCOUNT        = 'Prospect';
    private final static String REQUEST_TYPE        = '1';
    public static map<Id,Id> mapIdLeadContact       = new map<Id,Id>();//##RM## 24/4
    private static string B2B_RULES                 ='B2B Matching';
    private static string B2C_RULES                 ='B2C Matching';
    private final static String USER_COUNTRY 	    = [SELECT Country__c FROM User Where Id = :UserInfo.getUserId()].Country__c;
    private final static String CODE_PORTUGAL 		= 'PT';
    private final static String CODE_NIF        	= 'NIF';
    
    @TestVisible public static void sendEmailLeadConversion(String sEmail, String sSubject, string sMessageError, id idObject){
        
        List<UtilSetting__mdt> lURLCommunity = [SELECT Value__c FROM UtilSetting__mdt where developername = :UTIL_SETTING];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where DisplayName = :Label.DisplayNameOwea];
        
        System.debug('OWEA: '+owea);
        if (owea!=null && !owea.isEmpty()) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        
        String sLink = '';
        if(idObject!=null){
            sLink = (lURLCommunity!=null && !lURLCommunity.isEmpty())?lURLCommunity[0].Value__c+idObject:'';
            mail.setHtmlBody(String.format(Label.LeadConversionError, new String[]{sLink,sMessageError}));   
        }else{
            mail.setHtmlBody(String.format(Label.LeadConversionDMLError, new String[]{sLink,sMessageError}));                    
        }
            
        String[] toAddresses = new String[] {sEmail};
        mail.setToAddresses(toAddresses);
        mail.setSubject(sSubject);       
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
    }

    @InvocableMethod(label='Lead Conversion Process')
    public static void ConvertLead(List<Lead> lNewLeads) { 

        System.debug('***LEAD CONVERSION PROCESS***');

        List<Lead> lLeads                                   = new List<Lead>();//leads that have changed the status.
        List<Database.LeadConvert> lLeadsToConvert          = new List<Database.LeadConvert>();
        map<Id,String> mapIdLeadStageOpp                    = new map<Id,String>();
        map<Id,Lead> mapIdLead                              = new map<Id,Lead>();
        List<sObject> lSObjects                             = new List<sObject>();//to access visibility
        Set<Id> setIdCustomerAccounts                       = new Set<Id>();
        Set<Id> setIdCustomerContacts                       = new Set<Id>();
        Set<Id> setIdLeadAccountContactRel                  = new Set<Id>();//to create AccountContactRelation records.
        List<Account> lPersonAccounts                       = new List<Account>();
        List<AccountContactRelation> lAccountContactRel     = new List<AccountContactRelation>();
        List<Contact> lContactUpdateParent                  = new List<Contact>();
        List<Account> lAccountsToUpdate                     = new List<Account>();
        List<Account> lAccountsToDelete                     = new List<Account>();
        List<Opportunity> lOpportunityToUpdate              = new List<Opportunity>();
        List<Contact> lContactToUpdate                      = new List<Contact>();
        map<Id,string> mapIdLeadStatus                      = new map<Id,string>();
        List<Lead> lLeadFailConversion                      = new List<Lead>();
        List<Account> lAccountB2B                           = new List<Account>();
        List<Lead> lLeadConsentToCreate                     = new List<Lead>();//##RM## 24/4 - Added lead conversion to consents
        Map<Id,Id> mapAccountSharing                        = new Map<Id,Id>();//##RF## 11/07 - Extend sharing for converted accounts. C1STRUN-279
        map<Id,Lead> mapLeadIdBYAccountId    				= new map<Id,Lead>();
        
        //##RM## START - 24 08 18 ADDED MATCHING RULE BEFORE TO CONVERSION PROCESS.
        List<Lead> lLeadsB2C                                = new List<Lead>();
        List<Lead> lLeadsB2B                                = new List<Lead>();
        Set<Id> setIdB2C                                    = new Set<Id>();
        Set<Id> setIdB2B                                    = new Set<Id>();

        for(Lead l : lNewLeads){
            if (l.Company != null) {
                setIdB2B.add(l.id);
            } else{
                setIdB2C.add(l.id);
            }
        }

        if (!setIdB2C.isEmpty()) {
            lLeadsB2C = [SELECT FirstName,LastName,Street,City,Country,PostalCode,Latitude,
            Longitude,Phone,NationalId__c,DestinationGeographicalCode__c,DestinationPOSCode__c,Company,BrandOwnedVehicle__c,
            Email,LeadCountry__c,Activity__c,CustomerType__c,LeadChannel__c,LeadRequestType__c,LeadSource,LeadType__c,CustomerContact__c,
            MarketingCode__c,BirthDate__c,TECH_DealerPdVInternal__c,FiscalId__c,VINOwnedVehicle__c,MobileProfessionalTelephone__c,
            LandlineProfessionalTelephone__c,LandlinePersonalTelephone__c,MobilePersonalTelephone__c,Customer__c,
            CalculatedPOS__c,LocalIdOfCustomer__c,RecordTypeId,CalculatedPOS__r.AgentFlag__c,CalculatedPOS__r.RAFlag__c, CalculatedPOS__r.TECH_AfterSalesManager__c,
            CalculatedPOS__r.TECH_SalesManager__c,CalculatedPOS__r.TECH_SalesManagerAgent__c,CalculatedPOS__r.LeadFilters__c,VehicleRegistrationNumber__c,
            PSABrand__c,TreatmentDueDate__c,OwnerId,CreatedDate,TECH_Web2Lead__c,TECH_isMysteryLead__c,TECH_TemplateLead__c FROM Lead Where Id IN: setIdB2C];

            AllocationMatchingProcess.matchLeadsAccounts(lLeadsB2C,B2C_RULES);

            try {
                update lLeadsB2C;
            } catch (System.DmlException e) {
                System.debug('DmlException ERROR LeadConversionProcess.ConvertLead -->' + e.getMessage() + ' Line: '+e.getLineNumber());
                LeadConversionProcess.sendEmailLeadConversion(userinfo.getUserEmail(),EMAIL_SUBJECT,e.getMessage(),e.getDmlId(0));
            } catch (Exception e) {
                System.debug('Exception ERROR LeadConversionProcess.ConvertLead-->' + e.getMessage() + ' Line: '+e.getLineNumber());
                LeadConversionProcess.sendEmailLeadConversion(userinfo.getUserEmail(),EMAIL_SUBJECT,e.getMessage(),null);
            }
        }

        if(!setIdB2B.isEmpty()){
            lLeadsB2B = [SELECT FirstName,LastName,Street,City,Country,PostalCode,Latitude,
            Longitude,Phone,NationalId__c,DestinationGeographicalCode__c,DestinationPOSCode__c,Company,BrandOwnedVehicle__c,
            Email,LeadCountry__c,Activity__c,CustomerType__c,LeadChannel__c,LeadRequestType__c,LeadSource,LeadType__c,CustomerContact__c,
            MarketingCode__c,BirthDate__c,TECH_DealerPdVInternal__c,FiscalId__c,VINOwnedVehicle__c,MobileProfessionalTelephone__c,
            LandlineProfessionalTelephone__c,LandlinePersonalTelephone__c,MobilePersonalTelephone__c,Customer__c,
            CalculatedPOS__c,LocalIdOfCustomer__c,CalculatedPOS__r.AgentFlag__c,CalculatedPOS__r.RAFlag__c, CalculatedPOS__r.TECH_AfterSalesManager__c,
            CalculatedPOS__r.TECH_SalesManager__c,CalculatedPOS__r.TECH_SalesManagerAgent__c,CalculatedPOS__r.LeadFilters__c,VehicleRegistrationNumber__c,
            PSABrand__c,TreatmentDueDate__c,OwnerId,RecordtypeId,CreatedDate,TECH_Web2Lead__c,TECH_isMysteryLead__c,TECH_TemplateLead__c FROM Lead Where Id IN: setIdB2B];
            
            AllocationMatchingProcess.matchLeadsAccounts(lLeadsB2B,B2B_RULES);
            try{
                
                update lLeadsB2B;
                
            }catch(System.DmlException e){
                System.debug('DmlException ERROR LeadConversionProcess.ConvertLead -->' + e.getMessage() + ' Line: '+e.getLineNumber());
                LeadConversionProcess.sendEmailLeadConversion(userinfo.getUserEmail(),EMAIL_SUBJECT,e.getMessage(),e.getDmlId(0));
            }catch(Exception e){
                System.debug('Exception ERROR LeadConversionProcess.ConvertLead-->' + e.getMessage() + ' Line: '+e.getLineNumber());
                LeadConversionProcess.sendEmailLeadConversion(userinfo.getUserEmail(),EMAIL_SUBJECT,e.getMessage(),null);
            }

        }
        
        //##RM## END - 24 08 18 ADDED MATCHING RULE BEFORE TO CONVERSION PROCESS.
        
        for(Lead l : lNewLeads){
            setIdCustomerAccounts.add(l.Customer__c);
            setIdCustomerContacts.add(l.CustomerContact__c);
            mapIdLead.put(l.id,l);
            mapIdLeadStatus.put(l.id,l.Status);
        }
        
        AccountContactCheck.generateRelations(lNewLeads);
        
        System.debug('Leads: '+lNewLeads);
        if(!lNewLeads.isEmpty()){
            
            map<id,Account> mapIdAccount = new map<id,Account>([SELECT id,OwnerId FROM Account WHERE Id IN :setIdCustomerAccounts]);
            map<id,Contact> mapIdContact = new map<id,Contact>([SELECT id,Salutation,Firstname,LastName,Email,Phone FROM Contact WHERE Id IN :setIdCustomerContacts]);
            
            for(Lead oLead : lNewLeads){

                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setLeadId(oLead.id);
                lc.setOwnerId(oLead.OwnerId);

                if(oLead.RecordTypeId == RT_LEADB2B){//Lead B2B
                    if(oLead.CustomerContact__c != null){//CustomerContact != null

                        if(oLead.Customer__c != null){//Customer != null
                            System.debug('*1 - ALL*');
                            lc.setAccountId(new Account(id=oLead.Customer__c).id);
                            lc.setContactId(new Contact(id=oLead.CustomerContact__c).id);

                            if(mapIdAccount.get(oLead.Customer__c)!=null && oLead.OwnerId != mapIdAccount.get(oLead.Customer__c).OwnerId){
                                System.debug('DIFFERENT OWNER LEAD: '+oLead.OwnerId);
                                System.debug('DIFFERENT OWNER ACCOUNT: '+mapIdAccount.get(oLead.Customer__c).OwnerId);
                                lSObjects.add(oLead);
                            }

                        }else{//Customer == null
                            System.debug('*2  - CustomerContact*');
                            lc.setContactId(new Contact(id=oLead.CustomerContact__c).id);                          
                            lAccountB2B.add(
                                new Account(
                                    TECH_IdLead__c                              = oLead.Id,
                                    Type                                        = TYPE_ACCOUNT,
                                    Adress2__c                                  =oLead.Address2__c,
                                    BillingCity                                 =oLead.City,
                                    Name                                        =oLead.Company,
                                    Industry                                    =oLead.Industry,
                                    /* BEGIN - Manuel Medina - Code commented because the field ProfessionalEmail__pc can't be used in B2B accounts - 10122018 */
                                    /*// modified by ramesh artham--//
                                    ProfessionalEmail__pc                       =oLead.Email,*/
                                    /* END - Manuel Medina - 10122018 */
                                    Email__c                                    =oLead.Email,
                                    CompanyActivityType__c                      =oLead.CompanyActivityType__c,
                                    BillingCountry                              =oLead.Country,
                                    DescriptionofVehicleVPParcSize__c           =oLead.DescriptionofVehicleVPParcSize__c,
                                    DescriptionofVehicleVUParcSize__c           =oLead.DescriptionofVehicleVUParcSize__c,
                                    FiscalId__c                                 =oLead.FiscalId__c,
                                    FleetSize__c                                =oLead.FleetSize__c,
                                    LocalIdOfCustomer__c                        =oLead.LocalIdOfCustomer__c,
                                    MainBrandofVehicleVPParc__c                 =oLead.MainBrandofVehicleVPParc__c,
                                    MainBrandofVehicleVUParc__c                 =oLead.MainBrandofVehicleVUParc__c,
                                    MainModelofVehicleVPParc__c                 =oLead.MainModelofVehicleVPParc__c,
                                    MainModelofVehicleVUParc__c                 =oLead.MainModelofVehicleVUParc__c,
                                    NumberOfEmployees                           =oLead.NumberOfEmployees,
                                    BillingPostalCode                           =oLead.PostalCode,
                                    Brand__c                                    =oLead.PSABrand__c,
                                    FlagAC__c                                   = (oLead.PSABrand__c == 'AC' || oLead.PSABrand__c == 'All')?TRUE:FALSE,
                                    FlagAP__c                                   = (oLead.PSABrand__c == 'AP' || oLead.PSABrand__c == 'All')?TRUE:FALSE,
                                    FlagDS__C                                   = (oLead.PSABrand__c == 'DS' || oLead.PSABrand__c == 'All')?TRUE:FALSE,
                                    RenewalDateVehicleVPParc__c                 =oLead.RenewalDateVehicleVPParc__c,
                                    RenewalDateVehicleVUParc__c                 =oLead.RenewalDateVehicleVUParc__c,
                                    BillingState                                =oLead.State,
                                    BillingStreet                               =oLead.Street
                                )
                            
                            );
                            
                        }


                    }else{//CustomerContact == null

                        if(oLead.Customer__c != null){//Customer != null
                            System.debug('*3 - Customer*');
                            lc.setAccountId(new Account(id=oLead.Customer__c).id);

                            if(mapIdAccount.get(oLead.Customer__c)!=null && oLead.OwnerId != mapIdAccount.get(oLead.Customer__c).OwnerId){
                                    System.debug('DIFFERENT OWNER LEAD: '+oLead.OwnerId);
                                    System.debug('DIFFERENT OWNER ACCOUNT: '+mapIdAccount.get(oLead.Customer__c).OwnerId);
                                    lSObjects.add(oLead);
                            }
                        }else{//Customer == null
                            System.debug('*4 - Empty*');
                            //*** Create Account-Contact relationship. ***
                            setIdLeadAccountContactRel.add(oLead.id);
                        }
                    }

                 }else{//Lead B2C
                    if(oLead.Customer__c != null){//Customer != null
                        System.debug('*5 - Customer*');
                        lc.setAccountId(oLead.Customer__c);
                    }else{//Customer == null

                        if(oLead.CustomerContact__c != null){ //customer contact != null
                            //create person account based on contact
                            lPersonAccounts.add(
                            new Account(TECH_IdLead__c = oLead.Id,
                            RecordTypeId = RT_ACCOUNTB2C,
                            Firstname=mapIdContact.get(oLead.CustomerContact__c).Firstname,
                            LastName=mapIdContact.get(oLead.CustomerContact__c).LastName,
                            PersonEmail=mapIdContact.get(oLead.CustomerContact__c).Email,
                            Phone = mapIdContact.get(oLead.CustomerContact__c).Phone,
                            Salutation=mapIdContact.get(oLead.CustomerContact__c).Salutation,
                            Type = TYPE_ACCOUNT,
                            LandlinePersonalTelephone__pc=mapIdContact.get(oLead.CustomerContact__c).Phone,
                            PersonalEmail__pc=mapIdContact.get(oLead.CustomerContact__c).Email));
                            
                            System.debug('*6 - CustomerContact*');
                        }else{//customer contact != null && Customer__c != null
                            System.debug('*7 - Empty*');
                        }
                    }
                }



                if(oLead.Status == LEAD_QUALIFIED){//QUALIFIED
                    lc.setConvertedStatus(LEAD_QUALIFIED);
                    lc.setSendNotificationEmail(true);//to send notification.
                    if(oLead.LeadRequestType__c == REQUEST_TYPE && oLead.IdReservationVD__c!=null){
                        System.debug('________Negotiation_______');
                        mapIdLeadStageOpp.put(oLead.id, OPP_NEGOTIATION);
                    }else{
                        System.debug('________Needs Analysis_______');
                        mapIdLeadStageOpp.put(oLead.id, OPP_NEEDANALYSIS);
                    }

                }else{//NURTURING
                    System.debug('________Closed Lost_______');

                    lc.setConvertedStatus(LEAD_NURTURING);
                    mapIdLeadStageOpp.put(oLead.id, OPP_CLOSEDLOST);
                    lc.setAccountId(oLead.Customer__c);
                    lc.setContactId(oLead.CustomerContact__c);
                }

                lLeadsToConvert.add(lc);//add the leadconvert record in list to convert.
            }

            try{
                System.debug('____lAccountB2B: '+lAccountB2B);
                System.debug('LeadsToConvert bef: '+lLeadsToConvert );
                if(!lLeadsToConvert.isEmpty()){
                                       
                    Database.insert(lPersonAccounts,true); 
                    Database.insert(lAccountB2B,true);

                    map<Id,Id> mapIdLeadPAccount    = new map<Id,Id>();
                    map<Id,Id> mapIdLeadB2BAccount  = new map<Id,Id>();
                    
                    for(Account pa : lPersonAccounts){
                        mapIdLeadPAccount.put(pa.TECH_IdLead__c, pa.id);
                    }

                    for(Account a : lAccountB2B){
                        mapIdLeadB2BAccount.put(a.TECH_IdLead__c, a.id);
                    }

                    for(Database.LeadConvert c : lLeadsToConvert){
                        if(mapIdLeadPAccount.get(c.getLeadID())!=null){//to associate person account id to the conversion B2C(there are not Customer but there are CustomerContact)
                            c.setAccountId(mapIdLeadPAccount.get(c.getLeadID()));
                        }

                        if(mapIdLeadB2BAccount.get(c.getLeadID())!=null){//to associate B2Baccount id to the conversion B2B.
                            c.setAccountId(mapIdLeadB2BAccount.get(c.getLeadID()));
                            lContactUpdateParent.add(new Contact(accountid=mapIdLeadB2BAccount.get(c.getLeadID()) , Id=c.getContactId()));
                        }
                    }

                    
                    Database.update(lContactUpdateParent,true);
                    
                    for (Database.LeadConvertResult sr : Database.convertLead(lLeadsToConvert,false)) {
                        if (sr.isSuccess()) {
                            // C1STRUN-1835 - Created by Satyabrat
                            mapLeadIdBYAccountId.put(sr.getAccountId(),mapIdLead.get(sr.getLeadId()));
                            
                            // Operation was successful, so get the ID of the record that was processed
                            System.debug('Successfully inserted account. Lead ID: ' + sr);
                            mapIdLeadContact.put(sr.getLeadId(),sr.getContactId());//##RM## 24/4
                            lLeadConsentToCreate.add(mapIdLead.get(sr.getLeadId()));//##RM## 24/4 - Added lead conversion to consents
                            //Contact field mapping
                            lContactToUpdate.add(
                                new Contact(
                                    Id                                  =sr.getContactId(),
                                    Birthdate                           =mapIdLead.get(sr.getLeadId()).Birthdate__c,
                                    FirstName                           =mapIdLead.get(sr.getLeadId()).FirstName,
                                    LastName                            =mapIdLead.get(sr.getLeadId()).LastName,
                                    LandlinePersonalTelephone__c        =mapIdLead.get(sr.getLeadId()).LandlinePersonalTelephone__c,
                                    LandlineProfessionalTelephone__c    =mapIdLead.get(sr.getLeadId()).LandlineProfessionalTelephone__c,
                                    MobilePersonalTelephone__c          =mapIdLead.get(sr.getLeadId()).MobilePersonalTelephone__c,
                                    MobileProfessionalTelephone__c      =mapIdLead.get(sr.getLeadId()).MobileProfessionalTelephone__c,
                                    Salutation                          =mapIdLead.get(sr.getLeadId()).Salutation,
                                    //** line number 374 changed by Artham Ramesh**//
                                    Email                               =mapIdLead.get(sr.getLeadId()).Email,
                                    ProfessionalEmail__c                =(mapIdLead.get(sr.getLeadId()).recordtypeid == RT_LEADB2B)?mapIdLead.get(sr.getLeadId()).Email:null,
                                    /* BEGIN - Manuel Medina - C1STRUN-1552 - New mapping field to B2C accounts - 24122018 */
                                    PersonalEmail__c                    =(mapIdLead.get(sr.getLeadId()).recordtypeid == RT_LEADB2C)?mapIdLead.get(sr.getLeadId()).Email:null,
                                    /* END - Manuel Medina - 24122018 */
                                    NationalId__c                       =mapIdLead.get(sr.getLeadId()).NationalId__c,
                                    //New mapping field to B2C accounts for Portugal
                                    NationalIdType__c					=(mapIdLead.get(sr.getLeadId()).recordtypeid == RT_LEADB2C && USER_COUNTRY == CODE_PORTUGAL)?CODE_NIF:null,
                                    Title                               =mapIdLead.get(sr.getLeadId()).Title,
                                    ClientLanguage__c                   =mapIdLead.get(sr.getLeadId()).Language__c,
                                    MailingState                        =mapIdLead.get(sr.getLeadId()).State,
                                    MailingStreet                       =mapIdLead.get(sr.getLeadId()).Street,
                                    MailingCountry                      =mapIdLead.get(sr.getLeadId()).Country,
                                    MailingPostalCode                   =mapIdLead.get(sr.getLeadId()).PostalCode,
                                    MailingCity                         =mapIdLead.get(sr.getLeadId()).City
                                )
                                
                            );
                            
                            //Opportunity field mapping
                            lOpportunityToUpdate.add(
                                new Opportunity(
                                    Id                                      = sr.getOpportunityId(),
                                    Stagename                               = mapIdLeadStageOpp.get(sr.getLeadId()),                                    
                                    Activity__c                             = mapIdLead.get(sr.getLeadId()).Activity__c,
                                    AgentCallCenterComments__c              = mapIdLead.get(sr.getLeadId()).AgentCallCenterComments__c,
                                    AmountFinanced__c                       = mapIdLead.get(sr.getLeadId()).AmountFinanced__c,
                                    AppointmentDate__c                      = mapIdLead.get(sr.getLeadId()).AppointmentDate__c,
                                    CampaignContent__c                      = mapIdLead.get(sr.getLeadId()).CampaignContent__c,
                                    CampaignIDUSER__c                       = mapIdLead.get(sr.getLeadId()).CampaignIDUSER__c,
                                    CampaignMedium__c                       = mapIdLead.get(sr.getLeadId()).CampaignMedium__c,
                                    CampaignName__c                         = mapIdLead.get(sr.getLeadId()).CampaignName__c,
                                    CampaignSource__c                       = mapIdLead.get(sr.getLeadId()).CampaignSource__c,
                                    CampaignTerm__c                         = mapIdLead.get(sr.getLeadId()).CampaignTerm__c,
                                    CustomerComments__c                     = mapIdLead.get(sr.getLeadId()).CustomerComments__c,
                                    DaysBeforeCheckOut__c                   = mapIdLead.get(sr.getLeadId()).DaysBeforeCheckOut__c,
                                    DesiredRecallDateFromCustomer__c        = mapIdLead.get(sr.getLeadId()).DesiredRecallDateFromCustomer__c,
                                    DestinationGeographicalCode__c          = mapIdLead.get(sr.getLeadId()).DestinationGeographicalCode__c,
                                    //PartnerAccount                           =mapIdLead.get(sr.getLeadId()).CalculatedPOS__c,
                                    DestinationPOSCode__c                   = mapIdLead.get(sr.getLeadId()).DestinationPOSCode__c,
                                    EndContractDate__c                      = mapIdLead.get(sr.getLeadId()).EndContractDate__c,
                                    EvaluationPriceForVO__c                 = mapIdLead.get(sr.getLeadId()).EvaluationPriceForVO__c,
                                    FinalPrice__c                           = mapIdLead.get(sr.getLeadId()).FinalPrice__c,
                                    FinanceContractNumber__c                = mapIdLead.get(sr.getLeadId()).FinanceContractNumber__c,
                                    FinanceDescription__c                   = mapIdLead.get(sr.getLeadId()).FinanceDescription__c,
                                    FinanceOfferInterestFlag__c             = mapIdLead.get(sr.getLeadId()).FinanceOfferInterest__c,
                                    FinancingDuration__c                    = mapIdLead.get(sr.getLeadId()).FinancingDuration__c,
                                    // Name                                    = (mapIdLead.get(sr.getLeadId()).RecordTypeId == RT_LEADB2C)?mapIdLead.get(sr.getLeadId()).FirstName + mapIdLead.get(sr.getLeadId()).LastName:mapIdLead.get(sr.getLeadId()).Company,
                                    Name                                    = mapIdLead.get(sr.getLeadId()).ProductCustomerInterest__c + ' ' + mapIdLead.get(sr.getLeadId()).Activity__c + ' ' + Date.today().format(),
                                    FirstAppointmentDateDesired__c          = mapIdLead.get(sr.getLeadId()).FirstAppointmentDateDesired__c,
                                    FirstDesiredSchedule__c                 = mapIdLead.get(sr.getLeadId()).FirstDesiredSchedule__c,
                                    FiscalPower__c                          = mapIdLead.get(sr.getLeadId()).FiscalPower__c,
                                    FlagPSAProduct__c                       = mapIdLead.get(sr.getLeadId()).FlagPSAProduct__c,
                                    IdCookies__c                            = mapIdLead.get(sr.getLeadId()).IdCookies__c,
                                    IdReservationVD__c                      = mapIdLead.get(sr.getLeadId()).IdReservationVD__c,
                                    InitialPurchaseDate__c                  = mapIdLead.get(sr.getLeadId()).InitialPurchaseDate__c,
                                    LCDVInterest__c                         = mapIdLead.get(sr.getLeadId()).LCDVInterest__c,
                                    LCDVOwnedProduct__c                     = mapIdLead.get(sr.getLeadId()).LCDVOwnedProduct__c,
                                    //#7/3#LeadChannel__c                           =mapIdLead.get(sr.getLeadId()).LeadChannel__c,
                                    Country__c                              = mapIdLead.get(sr.getLeadId()).LeadCountry__c,
                                    LeadLabel__c                            = mapIdLead.get(sr.getLeadId()).LeadLabel__c,
                                    LeadRequestDate__c                      = mapIdLead.get(sr.getLeadId()).LeadRequestDate__c,
                                    LeadRequestType__c                      = mapIdLead.get(sr.getLeadId()).LeadRequestType__c,
                                    LeadSource                              = mapIdLead.get(sr.getLeadId()).LeadSource,
                                    //#7/3#LeadType__c                              =mapIdLead.get(sr.getLeadId()).LeadType__c,
                                    Link__c                                 = mapIdLead.get(sr.getLeadId()).Link__c,
                                    LinkDescription__c                      = mapIdLead.get(sr.getLeadId()).LinkDescription__c,
                                    MarketingCode__c                        = mapIdLead.get(sr.getLeadId()).MarketingCode__c,
                                    // --> Different Types!!
                                    //MileageBeforeCheckOut__c                =mapIdLead.get(sr.getLeadId()).MileageBeforeCheckOut__c,
                                     // --> END!
                                    MonthlyPayments__c                      = mapIdLead.get(sr.getLeadId()).MonthlyPayments__c,
                                    NumberFleetVehiclesFinanceContract__c   = mapIdLead.get(sr.getLeadId()).NumberFleetVehiclesFinanceContract__c,
                                    OnTheRoadFirstDate__c                   = mapIdLead.get(sr.getLeadId()).OnTheRoadFirstDate__c,
                                    PreferredContactMethod__c               = mapIdLead.get(sr.getLeadId()).PreferredContactMethod__c,
                                    ProductCustomerInterest__c              = mapIdLead.get(sr.getLeadId()).ProductCustomerInterest__c,
                                    ProductOwned__c                         = mapIdLead.get(sr.getLeadId()).ProductOwned__c,
                                    Brand__c                                = mapIdLead.get(sr.getLeadId()).PSABrand__c,
                                    PurchaseIntentionPeriod__c              = mapIdLead.get(sr.getLeadId()).PurchaseIntentionPeriod__c,
                                    RemainingAmount__c                      = mapIdLead.get(sr.getLeadId()).RemainingAmount__c,
                                    SecondAppointmentDateDesired__c         = mapIdLead.get(sr.getLeadId()).SecondAppointmentDateDesired__c,
                                    SecondDesiredSchedule__c                = mapIdLead.get(sr.getLeadId()).SecondDesiredSchedule__c,
                                    ServiceOfferInterestFlag__c             = mapIdLead.get(sr.getLeadId()).ServiceOfferInterestFlag__c,
                                    Vehiclestatus__c                        = mapIdLead.get(sr.getLeadId()).Vehiclestatus__c,
                                    VehicleFinishingDescription__c          = mapIdLead.get(sr.getLeadId()).VehicleFinishingDescription__c,
                                    // --> Different Types!!
                                    //VehicleMileage__c                       =mapIdLead.get(sr.getLeadId()).VehicleMileage__c,
                                    // -->
                                    VehicleOfferInterestFlag__c             = mapIdLead.get(sr.getLeadId()).VehicleOfferInterestFlag__c,
                                    VehiclePerformances__c                  = mapIdLead.get(sr.getLeadId()).VehiclePerformances__c,
                                    VehicleRegistrationNumber__c            = mapIdLead.get(sr.getLeadId()).VehicleRegistrationNumber__c,
                                    VehicleType__c                          = mapIdLead.get(sr.getLeadId()).VehicleType__c,
                                    VINOwnedVehicle__c                      = mapIdLead.get(sr.getLeadId()).VINOwnedVehicle__c,
                                    TECH_Web2Lead__c                        = mapIdLead.get(sr.getLeadId()).TECH_Web2Lead__c,
                                    TECH_CreatedFromLead__c                 = true,
                                    VNContractNumber__c                     = (mapIdLead.get(sr.getLeadId()).Activity__c == 'VN' || mapIdLead.get(sr.getLeadId()).Activity__c == 'VO' || mapIdLead.get(sr.getLeadId()).Activity__c == 'FI') ? 
                                                                              mapIdLead.get(sr.getLeadId()).DestinationPOSCode__c : null
                                )
                            );
                            
                            
                            if(mapIdLead.get(sr.getLeadId())!=null && mapIdLead.get(sr.getLeadId()).Company != null){ 
                                                                                              
                                //B2B Account field mapping
                                lAccountsToUpdate.add(
                                    new Account(
                                        Id                                          =sr.getAccountId(),
                                        Type                                        = TYPE_ACCOUNT,
                                        Adress2__c                                  =mapIdLead.get(sr.getLeadId()).Address2__c,
                                        BillingCity                                 =mapIdLead.get(sr.getLeadId()).City,
                                        Name                                        =mapIdLead.get(sr.getLeadId()).Company,
                                        Industry                                    =mapIdLead.get(sr.getLeadId()).Industry,
                                        CompanyActivityType__c                      =mapIdLead.get(sr.getLeadId()).CompanyActivityType__c,
                                        BillingCountry                              =mapIdLead.get(sr.getLeadId()).Country,
                                        DescriptionofVehicleVPParcSize__c           =mapIdLead.get(sr.getLeadId()).DescriptionofVehicleVPParcSize__c,
                                        DescriptionofVehicleVUParcSize__c           =mapIdLead.get(sr.getLeadId()).DescriptionofVehicleVUParcSize__c,
                                        FiscalId__c                                 =mapIdLead.get(sr.getLeadId()).FiscalId__c,
                                        FleetSize__c                                =mapIdLead.get(sr.getLeadId()).FleetSize__c,
                                        //#7/3#IdCodeVehicleVPParcSize__c                   =mapIdLead.get(sr.getLeadId()).IdCodeVehicleVPParcSize__c,
                                        //#7/3#IdCodeVehicleVUParcSize__c                   =mapIdLead.get(sr.getLeadId()).IdCodeVehicleVUParcSize__c,
                                        LocalIdOfCustomer__c                        =mapIdLead.get(sr.getLeadId()).LocalIdOfCustomer__c,
                                        MainBrandofVehicleVPParc__c                 =mapIdLead.get(sr.getLeadId()).MainBrandofVehicleVPParc__c,
                                        MainBrandofVehicleVUParc__c                 =mapIdLead.get(sr.getLeadId()).MainBrandofVehicleVUParc__c,
                                        MainModelofVehicleVPParc__c                 =mapIdLead.get(sr.getLeadId()).MainModelofVehicleVPParc__c,
                                        MainModelofVehicleVUParc__c                 =mapIdLead.get(sr.getLeadId()).MainModelofVehicleVUParc__c,
                                        NumberOfEmployees                           =mapIdLead.get(sr.getLeadId()).NumberOfEmployees,
                                        BillingPostalCode                           =mapIdLead.get(sr.getLeadId()).PostalCode,
                                        Brand__c                                    =mapIdLead.get(sr.getLeadId()).PSABrand__c,
                                        FlagAC__c                                   = (mapIdLead.get(sr.getLeadId()).PSABrand__c == 'AC' || mapIdLead.get(sr.getLeadId()).PSABrand__c == 'All')?TRUE:FALSE,
                                        FlagAP__c                                   = (mapIdLead.get(sr.getLeadId()).PSABrand__c == 'AP' || mapIdLead.get(sr.getLeadId()).PSABrand__c == 'All')?TRUE:FALSE,
                                        FlagDS__C                                   = (mapIdLead.get(sr.getLeadId()).PSABrand__c == 'DS' || mapIdLead.get(sr.getLeadId()).PSABrand__c == 'All')?TRUE:FALSE,
                                        RenewalDateVehicleVPParc__c                 =mapIdLead.get(sr.getLeadId()).RenewalDateVehicleVPParc__c,
                                        RenewalDateVehicleVUParc__c                 =mapIdLead.get(sr.getLeadId()).RenewalDateVehicleVUParc__c,
                                        BillingState                                =mapIdLead.get(sr.getLeadId()).State,
                                        BillingStreet                               =mapIdLead.get(sr.getLeadId()).Street
                                    )
                                );
                                
                            }
                            
                            if(setIdLeadAccountContactRel.contains(sr.getLeadId())){
                                AccountContactRelation acr = new AccountContactRelation(AccountId = sr.getAccountId(), ContactId = sr.getContactId());
                                lAccountContactRel.add(acr); 
                                /* START C1STRUN-279 */
                                mapAccountSharing.put(sr.getAccountId(),mapIdLead.get(sr.getLeadId()).OwnerId);
                                /* END C1STRUN-279 */
                            }
                        }
                        else {// Operation failed, so get all errors
                            
                            //remove the accounts create before conversion.
                            if(mapIdLeadB2BAccount.values().contains(sr.getAccountId()) || mapIdLeadPAccount.values().contains(sr.getAccountId()))
                                lAccountsToDelete.add(new Account(id=sr.getAccountId()));
                            
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('The following error has occurred.');                    
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Account fields that affected this error: ' + err.getFields());
                                LeadConversionProcess.sendEmailLeadConversion(userinfo.getUserEmail(),EMAIL_SUBJECT,err.getMessage(),sr.getLeadId());
                            }
                        }
                    }
                    
                    if(!lSObjects.isEmpty())
                        AccountSharing.ManualSharingLeadConversion(lSObjects);//to give edit permissions to owner of opportunity/lead.
                    /* START C1STRUN-279 */
                    if(!mapAccountSharing.isEmpty())
                        AccountSharing.PGroupAccountSharingLeadConversion(mapAccountSharing);
                    /* END C1STRUN-279 */

                    //remove the accounts create before conversion.
                    database.delete(lAccountsToDelete,true);
                    
                    //updates following the field mapping.
                    database.update(lOpportunityToUpdate,true);
                    database.update(lAccountsToUpdate,true);
                    database.update(lContactToUpdate,true);
					
                    /* START C1STRUN-1835 - Satyabrat */
                    	List<AccountShare> lstAccShare = new List<AccountShare>();
                  	  	List<LeadShare> lstLeadShare = new List<LeadShare>();
                        
                        for(Id idAccount : mapLeadIdBYAccountId.keySet()){
                            AccountShare objAccShare = new AccountShare();
                            objAccShare.AccountId = idAccount;//Set the ID of record being shared.
                            objAccShare.UserOrGroupId = mapLeadIdBYAccountId.get( idAccount ).TECH_LeadPreviousOwner__c; // Set the ID of user being granted access				
                            objAccShare.AccountAccessLevel = 'Edit';// Set the access level.
                            objAccShare.OpportunityAccessLevel = 'Read';
                            objAccShare.CaseAccessLevel = 'Read'; 
                            objAccShare.RowCause = Schema.AccountShare.RowCause.Manual;
                            lstAccShare.add( objAccShare );
                            
                            LeadShare objLeadShare = new LeadShare();
                            objLeadShare.LeadId = mapLeadIdBYAccountId.get( idAccount ).Id;//Set the ID of record being shared.
                            objLeadShare.UserOrGroupId = mapLeadIdBYAccountId.get( idAccount ).TECH_LeadPreviousOwner__c; // Set the ID of user being granted access				
                            objLeadShare.LeadAccessLevel = 'Edit';// Set the access level.
                            objLeadShare.RowCause = Schema.LeadShare.RowCause.Manual;
                            lstLeadShare.add( objLeadShare );
                        }
                    
                    LeadConversionProcess.createConsent(lLeadConsentToCreate);

                    database.insert(lAccountContactRel,true);
					insert lstAccShare;
                    insert lstLeadShare;
                   /* END C1STRUN-1835 - Satyabrat */
                }


            }catch(System.DmlException e){
                System.debug('DmlException ERROR LeadConversionProcess.ConvertLead -->' + e.getMessage() + ' Line: '+e.getLineNumber());
                LeadConversionProcess.sendEmailLeadConversion(userinfo.getUserEmail(),EMAIL_SUBJECT,e.getMessage(),e.getDmlId(0));
            }catch(Exception e){
                System.debug('Exception ERROR LeadConversionProcess.ConvertLead-->' + e.getMessage() + ' Line: '+e.getLineNumber());
                LeadConversionProcess.sendEmailLeadConversion(userinfo.getUserEmail(),EMAIL_SUBJECT,e.getMessage(),null);
            }
        }
    }
    
    public static void ConvertLeadStatus(List<Lead> lNewLeads , boolean bDiscard) {
        System.debug('***LEAD CONVERSION PROCESS***');

        List<Lead> lLeads                               = new List<Lead>();//leads that have changed the status.
        List<Database.LeadConvert> lLeadsToConvert      = new List<Database.LeadConvert>();
        map<Id,String> mapIdLeadStageOpp                = new map<Id,String>();
        map<Id,Lead> mapIdLead                          = new map<Id,Lead>();
        List<sObject> lSObjects                         = new List<sObject>();//to access visibility
        Set<Id> setIdCustomerAccounts                   = new Set<Id>();
        Set<Id> setIdCustomerContacts                   = new Set<Id>();
        Set<Id> setIdLeadAccountContactRel              = new Set<Id>();//to create AccountContactRelation records.
        List<Account> lPersonAccounts                   = new List<Account>();
        List<AccountContactRelation> lAccountContactRel = new List<AccountContactRelation>();
        List<Account> lAccountsToUpdate                 = new List<Account>();
        List<Contact> lContactUpdateParent              = new List<Contact>();
        List<Opportunity> lOpportunityToUpdate          = new List<Opportunity>();
        List<Contact> lContactToUpdate                  = new List<Contact>();
        map<Id,string> mapIdLeadStatus                  = new map<Id,string>();
        List<Lead> lLeadFailConversion                  = new List<Lead>();
        List<Account> lAccountB2B                       = new List<Account>();  
        List<Account> lAccountsToDelete                 = new List<Account>();
        List<Lead> lLeadConsentToCreate                 = new List<Lead>();//##RM## 24/4 - Added lead conversion to consents
        Map<Id,Id> mapAccountSharing                    = new Map<Id,Id>();//##RF## 11/07 - Extend sharing for converted accounts. C1STRUN-279

        //##RM## START - 24 08 18 ADDED MATCHING RULE BEFORE TO CONVERSION PROCESS.
        List<Lead> lLeadsB2C                            = new List<Lead>();
        List<Lead> lLeadsB2B                            = new List<Lead>();
        Set<Id> setIdB2C                                = new Set<Id>();
        Set<Id> setIdB2B                                = new Set<Id>();

        for(Lead l : lNewLeads){
            if (l.Company!=null){
                setIdB2B.add(l.id);
            } else {
                setIdB2C.add(l.id);
            }
        }

        if(!setIdB2C.isEmpty()){
            lLeadsB2C = [SELECT FirstName,LastName,Street,City,Country,PostalCode,Latitude,
            Longitude,Phone,NationalId__c,DestinationGeographicalCode__c,DestinationPOSCode__c,Company,BrandOwnedVehicle__c,
            Email,LeadCountry__c,Activity__c,CustomerType__c,LeadChannel__c,LeadRequestType__c,LeadSource,LeadType__c,CustomerContact__c,
            MarketingCode__c,BirthDate__c,TECH_DealerPdVInternal__c,FiscalId__c,VINOwnedVehicle__c,MobileProfessionalTelephone__c,
            LandlineProfessionalTelephone__c,RecordTypeId,LandlinePersonalTelephone__c,MobilePersonalTelephone__c,Customer__c,
            CalculatedPOS__c,LocalIdOfCustomer__c,CalculatedPOS__r.AgentFlag__c,CalculatedPOS__r.RAFlag__c, CalculatedPOS__r.TECH_AfterSalesManager__c,
            CalculatedPOS__r.TECH_SalesManager__c,CalculatedPOS__r.TECH_SalesManagerAgent__c,CalculatedPOS__r.LeadFilters__c,VehicleRegistrationNumber__c,
            PSABrand__c,TreatmentDueDate__c,OwnerId,CreatedDate,TECH_Web2Lead__c,TECH_isMysteryLead__c,TECH_TemplateLead__c FROM Lead Where Id IN: setIdB2C];
            
            AllocationMatchingProcess.matchLeadsAccounts(lLeadsB2C,B2C_RULES);
            
            try{
                
                update lLeadsB2C;
                
            }catch(System.DmlException e){
                System.debug('DmlException ERROR LeadConversionProcess.ConvertLead -->' + e.getMessage() + ' Line: '+e.getLineNumber());
                LeadConversionProcess.sendEmailLeadConversion(userinfo.getUserEmail(),EMAIL_SUBJECT,e.getMessage(),e.getDmlId(0));
            }catch(Exception e){
                System.debug('Exception ERROR LeadConversionProcess.ConvertLead-->' + e.getMessage() + ' Line: '+e.getLineNumber());
                LeadConversionProcess.sendEmailLeadConversion(userinfo.getUserEmail(),EMAIL_SUBJECT,e.getMessage(),null);
            }
            
        }
        
        if(!setIdB2B.isEmpty()){
            
            lLeadsB2B = [SELECT FirstName,LastName,Street,City,Country,PostalCode,Latitude,
            Longitude,Phone,NationalId__c,DestinationGeographicalCode__c,DestinationPOSCode__c,Company,BrandOwnedVehicle__c,
            Email,LeadCountry__c,Activity__c,CustomerType__c,LeadChannel__c,LeadRequestType__c,LeadSource,LeadType__c,CustomerContact__c,
            MarketingCode__c,BirthDate__c,TECH_DealerPdVInternal__c,FiscalId__c,VINOwnedVehicle__c,MobileProfessionalTelephone__c,
            LandlineProfessionalTelephone__c,RecordTypeId,LandlinePersonalTelephone__c,MobilePersonalTelephone__c,Customer__c,
            CalculatedPOS__c,LocalIdOfCustomer__c,CalculatedPOS__r.AgentFlag__c,CalculatedPOS__r.RAFlag__c, CalculatedPOS__r.TECH_AfterSalesManager__c,
            CalculatedPOS__r.TECH_SalesManager__c,CalculatedPOS__r.TECH_SalesManagerAgent__c,CalculatedPOS__r.LeadFilters__c,VehicleRegistrationNumber__c,
            PSABrand__c,TreatmentDueDate__c,OwnerId,CreatedDate,TECH_Web2Lead__c,TECH_isMysteryLead__c,TECH_TemplateLead__c FROM Lead Where Id IN: setIdB2B];
            
            AllocationMatchingProcess.matchLeadsAccounts(lLeadsB2B,B2B_RULES);
            try{
                
                update lLeadsB2B;
                
            }catch(System.DmlException e){
                System.debug('DmlException ERROR LeadConversionProcess.ConvertLead -->' + e.getMessage() + ' Line: '+e.getLineNumber());
                LeadConversionProcess.sendEmailLeadConversion(userinfo.getUserEmail(),EMAIL_SUBJECT,e.getMessage(),e.getDmlId(0));
            }catch(Exception e){
                System.debug('Exception ERROR LeadConversionProcess.ConvertLead-->' + e.getMessage() + ' Line: '+e.getLineNumber());
                LeadConversionProcess.sendEmailLeadConversion(userinfo.getUserEmail(),EMAIL_SUBJECT,e.getMessage(),null);
            }

        }
        
        //##RM## END - 24 08 18 ADDED MATCHING RULE BEFORE TO CONVERSION PROCESS.
        
        
        for(Lead l : lNewLeads){
            setIdCustomerAccounts.add(l.Customer__c);
            setIdCustomerContacts.add(l.CustomerContact__c);
            mapIdLead.put(l.id,l);
            mapIdLeadStatus.put(l.id,l.Status);
        }
        
        AccountContactCheck.generateRelations(lNewLeads);
        
        System.debug('Leads: '+lNewLeads);
        if(!lNewLeads.isEmpty()){
            
            map<id,Account> mapIdAccount = new map<id,Account>([SELECT id,OwnerId FROM Account WHERE Id IN :setIdCustomerAccounts]);
            map<id,Contact> mapIdContact = new map<id,Contact>([SELECT id,Salutation,Firstname,LastName,Email,Phone FROM Contact WHERE Id IN :setIdCustomerContacts]);
            
            for(Lead oLead : lNewLeads){

                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setLeadId(oLead.id);
                lc.setOwnerId(oLead.OwnerId);
                
                

                if(oLead.RecordTypeId == RT_LEADB2B){//Lead B2B
                    if(oLead.CustomerContact__c != null){//CustomerContact != null
                                                
                        if(oLead.Customer__c != null){//Customer != null
                            System.debug('*1 - ALL*');
                            lc.setAccountId(new Account(id=oLead.Customer__c).id);
                            lc.setContactId(new Contact(id=oLead.CustomerContact__c).id);

                            if(mapIdAccount.get(oLead.Customer__c)!=null && oLead.OwnerId != mapIdAccount.get(oLead.Customer__c).OwnerId){
                                System.debug('DIFFERENT OWNER LEAD: '+oLead.OwnerId);
                                System.debug('DIFFERENT OWNER ACCOUNT: '+mapIdAccount.get(oLead.Customer__c).OwnerId);
                                lSObjects.add(oLead);
                            }

                        }else{//Customer == null
                            System.debug('*2  - CustomerContact*');
                            lc.setContactId(new Contact(id=oLead.CustomerContact__c).id);                          
                            lAccountB2B.add(
                                new Account(
                                    Type                                        = TYPE_ACCOUNT,
                                    TECH_IdLead__c                              = oLead.Id,                                   
                                    Adress2__c                                  =oLead.Address2__c,
                                    BillingCity                                 =oLead.City,
                                    Name                                        =oLead.Company,
                                    Industry                                    =oLead.Industry,
                                    CompanyActivityType__c                      =oLead.CompanyActivityType__c,
                                    BillingCountry                              =oLead.Country,

                                    /* BEGIN - Manuel Medina - Code commented because the field ProfessionalEmail__pc can't be used in B2B accounts - 10122018 */
                                    /*ProfessionalEmail__pc                       =oLead.Email,*/
                                    /* END - Manuel Medina - 10122018 */
                                    
                                    Email__c                                    =oLead.Email,
                                    DescriptionofVehicleVPParcSize__c           =oLead.DescriptionofVehicleVPParcSize__c,
                                    DescriptionofVehicleVUParcSize__c           =oLead.DescriptionofVehicleVUParcSize__c,
                                    FiscalId__c                                 =oLead.FiscalId__c,
                                    FleetSize__c                                =oLead.FleetSize__c,
                                    LocalIdOfCustomer__c                        =oLead.LocalIdOfCustomer__c,
                                    MainBrandofVehicleVPParc__c                 =oLead.MainBrandofVehicleVPParc__c,
                                    MainBrandofVehicleVUParc__c                 =oLead.MainBrandofVehicleVUParc__c,
                                    MainModelofVehicleVPParc__c                 =oLead.MainModelofVehicleVPParc__c,
                                    MainModelofVehicleVUParc__c                 =oLead.MainModelofVehicleVUParc__c,
                                    NumberOfEmployees                           =oLead.NumberOfEmployees,
                                    BillingPostalCode                           =oLead.PostalCode,
                                    Brand__c                                    =oLead.PSABrand__c,
                                    FlagAC__c                                   = (oLead.PSABrand__c == 'AC' || oLead.PSABrand__c == 'All')?TRUE:FALSE,
                                    FlagAP__c                                   = (oLead.PSABrand__c == 'AP' || oLead.PSABrand__c == 'All')?TRUE:FALSE,
                                    FlagDS__C                                   = (oLead.PSABrand__c == 'DS' || oLead.PSABrand__c == 'All')?TRUE:FALSE,
                                    RenewalDateVehicleVPParc__c                 =oLead.RenewalDateVehicleVPParc__c,
                                    RenewalDateVehicleVUParc__c                 =oLead.RenewalDateVehicleVUParc__c,
                                    BillingState                                =oLead.State,
                                    BillingStreet                               =oLead.Street
                                )
                            
                            );
                            
                        }


                    }else{//CustomerContact == null

                        if(oLead.Customer__c != null){//Customer != null
                            System.debug('*3 - Customer*');
                            lc.setAccountId(new Account(id=oLead.Customer__c).id);

                            if(mapIdAccount.get(oLead.Customer__c)!=null && oLead.OwnerId != mapIdAccount.get(oLead.Customer__c).OwnerId){
                                    System.debug('DIFFERENT OWNER LEAD: '+oLead.OwnerId);
                                    System.debug('DIFFERENT OWNER ACCOUNT: '+mapIdAccount.get(oLead.Customer__c).OwnerId);
                                    lSObjects.add(oLead);
                            }


                        }else{//Customer == null
                            System.debug('*4 - Empty*');
                            //*** Create Account-Contact relationship. ***
                            setIdLeadAccountContactRel.add(oLead.id);
                            
                            
                        }


                    }


                }else{//Lead B2C
                    if(oLead.Customer__c != null){//Customer != null
                        System.debug('*5 - Customer*');
                        lc.setAccountId(oLead.Customer__c);
                    }else{//Customer == null

                        if(oLead.CustomerContact__c != null){ //customer contact != null
                            //create person account based on contact
                            lPersonAccounts.add(new Account(
                                TECH_IdLead__c = oLead.Id , 
                                RecordTypeId = RT_ACCOUNTB2C, 
                                Firstname=mapIdContact.get(oLead.CustomerContact__c).Firstname, 
                                LastName=mapIdContact.get(oLead.CustomerContact__c).LastName, 
                                PersonEmail=mapIdContact.get(oLead.CustomerContact__c).Email,
                                Phone = mapIdContact.get(oLead.CustomerContact__c).Phone,
                                Salutation=mapIdContact.get(oLead.CustomerContact__c).Salutation,
                                Type = TYPE_ACCOUNT, 
                                LandlinePersonalTelephone__pc=mapIdContact.get(oLead.CustomerContact__c).Phone, 
                                PersonalEmail__pc=mapIdContact.get(oLead.CustomerContact__c).Email));
                            
                            System.debug('*6 - CustomerContact*');
                        }else{//customer contact != null && Customer__c != null
                            System.debug('*7 - Empty*');
                        }    


                    }


                }



                if(oLead.Status == LEAD_QUALIFIED){//QUALIFIED
                    lc.setConvertedStatus(LEAD_QUALIFIED);
                    lc.setSendNotificationEmail(true);//to send notification.
                    if(oLead.LeadRequestType__c == REQUEST_TYPE && oLead.IdReservationVD__c!=null){
                        System.debug('________Negotiation_______');
                        mapIdLeadStageOpp.put(oLead.id, OPP_NEGOTIATION);
                    }else{
                        System.debug('________Needs Analysis_______');
                        mapIdLeadStageOpp.put(oLead.id, OPP_NEEDANALYSIS);
                    }

                }else{//NURTURING
                    System.debug('________Closed Lost_______');
                    if(bDiscard){
                        lc.setConvertedStatus(LEAD_DISCARDED);
                    }else{
                        lc.setConvertedStatus(LEAD_NURTURING);
                    }
                        
                    mapIdLeadStageOpp.put(oLead.id, OPP_CLOSEDLOST);
                    lc.setAccountId(oLead.Customer__c);
                    lc.setContactId(oLead.CustomerContact__c);
                }



                System.debug('LeadsToConvert: '+lc);
                lLeadsToConvert.add(lc);//add up lc in list to convert.

            }


            try{

                
                if(!lLeadsToConvert.isEmpty()){
  
                    Database.insert(lPersonAccounts,true);
                    Database.insert(lAccountB2B,true);
                    
                    map<Id,Id> mapIdLeadPAccount    = new map<Id,Id>();
                    map<Id,Id> mapIdLeadB2BAccount  = new map<Id,Id>();
                    
                    
                    for(Account pa : lPersonAccounts){
                        mapIdLeadPAccount.put(pa.TECH_IdLead__c, pa.id);
                    }
                    
                    
                    for(Account a : lAccountB2B){
                        mapIdLeadB2BAccount.put(a.TECH_IdLead__c, a.id);
                    }
                    

                    for(Database.LeadConvert c : lLeadsToConvert){

                        if(mapIdLeadPAccount.get(c.getLeadID())!=null){//to associate person account id to the conversion B2C(there are not Customer but there are CustomerContact)
                            c.setAccountId(mapIdLeadPAccount.get(c.getLeadID()));
                        }
                        
                        
                        if(mapIdLeadB2BAccount.get(c.getLeadID())!=null){//to associate B2Baccount id to the conversion B2B.
                            c.setAccountId(mapIdLeadB2BAccount.get(c.getLeadID()));
                            lContactUpdateParent.add(new Contact(accountid=mapIdLeadB2BAccount.get(c.getLeadID()) , Id=c.getContactId()));
                        }
                            
                    }

                    
                    Database.update(lContactUpdateParent,true);


                    for (Database.LeadConvertResult sr : Database.convertLead(lLeadsToConvert,false)) {
                        if (sr.isSuccess()) {
                            // Operation was successful, so get the ID of the record that was processed
                            System.debug('Successfully inserted account. Lead ID: ' + sr);
                            mapIdLeadContact.put(sr.getLeadId(),sr.getContactId());//##RM## 24/4
                            lLeadConsentToCreate.add(mapIdLead.get(sr.getLeadId()));//##RM## 24/4 - Added lead conversion to consents
                            
                            //Contact field mapping
                            lContactToUpdate.add(
                                new Contact(
                                    Id                                  =sr.getContactId(),                                       
                                    Birthdate                           =mapIdLead.get(sr.getLeadId()).Birthdate__c,
                                    FirstName                           =mapIdLead.get(sr.getLeadId()).FirstName,
                                    LastName                            =mapIdLead.get(sr.getLeadId()).LastName,
                                    LandlinePersonalTelephone__c        =mapIdLead.get(sr.getLeadId()).LandlinePersonalTelephone__c,
                                    LandlineProfessionalTelephone__c    =mapIdLead.get(sr.getLeadId()).LandlineProfessionalTelephone__c,
                                    MobilePersonalTelephone__c          =mapIdLead.get(sr.getLeadId()).MobilePersonalTelephone__c,                                     
                                    MobileProfessionalTelephone__c      =mapIdLead.get(sr.getLeadId()).MobileProfessionalTelephone__c,
                                    Salutation                          =mapIdLead.get(sr.getLeadId()).Salutation,
                                    //** line number 912 changed by Artham Ramesh**//
                                    Email                               =mapIdLead.get(sr.getLeadId()).Email,
                                    ProfessionalEmail__c                =(mapIdLead.get(sr.getLeadId()).recordtypeid == RT_LEADB2B)?mapIdLead.get(sr.getLeadId()).Email:null,
                                    
                                    /* BEGIN - Manuel Medina - C1STRUN-1552 - New mapping field to B2C accounts - 24122018 */
                                    PersonalEmail__c                    =(mapIdLead.get(sr.getLeadId()).recordtypeid == RT_LEADB2C)?mapIdLead.get(sr.getLeadId()).Email:null,
                                    /* END - Manuel Medina - 24122018 */
                                    
                                    NationalId__c                       =mapIdLead.get(sr.getLeadId()).NationalId__c,
                                    //New mapping field to B2C accounts for Portugal
                                    NationalIdType__c					=(mapIdLead.get(sr.getLeadId()).recordtypeid == RT_LEADB2C && USER_COUNTRY == CODE_PORTUGAL)?CODE_NIF:null,
                                    Title                               =mapIdLead.get(sr.getLeadId()).Title,                       
                                    ClientLanguage__c                   =mapIdLead.get(sr.getLeadId()).Language__c,
                                    MailingState                        =mapIdLead.get(sr.getLeadId()).State,
                                    MailingStreet                       =mapIdLead.get(sr.getLeadId()).Street,
                                    MailingCountry                      =mapIdLead.get(sr.getLeadId()).Country,
                                    MailingPostalCode                   =mapIdLead.get(sr.getLeadId()).PostalCode,
                                    MailingCity                         =mapIdLead.get(sr.getLeadId()).City
                                    
                                )
                                
                            );
                            
                            //Opportunity field mapping
                            lOpportunityToUpdate.add(
                                new Opportunity(
                                    Id                                      = sr.getOpportunityId(),
                                    Stagename                               = mapIdLeadStageOpp.get(sr.getLeadId()),
                                    Activity__c                             = mapIdLead.get(sr.getLeadId()).Activity__c,
                                    AgentCallCenterComments__c              = mapIdLead.get(sr.getLeadId()).AgentCallCenterComments__c,
                                    AmountFinanced__c                       = mapIdLead.get(sr.getLeadId()).AmountFinanced__c,
                                    AppointmentDate__c                      = mapIdLead.get(sr.getLeadId()).AppointmentDate__c,
                                    CampaignContent__c                      = mapIdLead.get(sr.getLeadId()).CampaignContent__c,
                                    CampaignIDUSER__c                       = mapIdLead.get(sr.getLeadId()).CampaignIDUSER__c,
                                    CampaignMedium__c                       = mapIdLead.get(sr.getLeadId()).CampaignMedium__c,
                                    CampaignName__c                         = mapIdLead.get(sr.getLeadId()).CampaignName__c,
                                    CampaignSource__c                       = mapIdLead.get(sr.getLeadId()).CampaignSource__c,
                                    CampaignTerm__c                         = mapIdLead.get(sr.getLeadId()).CampaignTerm__c,
                                    CustomerComments__c                     = mapIdLead.get(sr.getLeadId()).CustomerComments__c,
                                    DaysBeforeCheckOut__c                   = mapIdLead.get(sr.getLeadId()).DaysBeforeCheckOut__c,
                                    DesiredRecallDateFromCustomer__c        = mapIdLead.get(sr.getLeadId()).DesiredRecallDateFromCustomer__c,
                                    DestinationGeographicalCode__c          = mapIdLead.get(sr.getLeadId()).DestinationGeographicalCode__c,
                                    //PartnerAccount                          =mapIdLead.get(sr.getLeadId()).CalculatedPOS__c, //not writeable
                                    DestinationPOSCode__c                   = mapIdLead.get(sr.getLeadId()).DestinationPOSCode__c,
                                    EndContractDate__c                      = mapIdLead.get(sr.getLeadId()).EndContractDate__c,
                                    EvaluationPriceForVO__c                 = mapIdLead.get(sr.getLeadId()).EvaluationPriceForVO__c,
                                    FinalPrice__c                           = mapIdLead.get(sr.getLeadId()).FinalPrice__c,
                                    FinanceContractNumber__c                = mapIdLead.get(sr.getLeadId()).FinanceContractNumber__c,
                                    FinanceDescription__c                   = mapIdLead.get(sr.getLeadId()).FinanceDescription__c,
                                    FinanceOfferInterestFlag__c             = mapIdLead.get(sr.getLeadId()).FinanceOfferInterest__c,
                                    FinancingDuration__c                    = mapIdLead.get(sr.getLeadId()).FinancingDuration__c,
                                    // Name                                    = (mapIdLead.get(sr.getLeadId()).RecordTypeId == RT_LEADB2C)?mapIdLead.get(sr.getLeadId()).FirstName + mapIdLead.get(sr.getLeadId()).LastName:mapIdLead.get(sr.getLeadId()).Company,
                                    Name                                    = mapIdLead.get(sr.getLeadId()).ProductCustomerInterest__c + ' ' + mapIdLead.get(sr.getLeadId()).Activity__c + ' ' + Date.today().format(),
                                    FirstAppointmentDateDesired__c          = mapIdLead.get(sr.getLeadId()).FirstAppointmentDateDesired__c,
                                    FirstDesiredSchedule__c                 = mapIdLead.get(sr.getLeadId()).FirstDesiredSchedule__c,
                                    FiscalPower__c                          = mapIdLead.get(sr.getLeadId()).FiscalPower__c,
                                    FlagPSAProduct__c                       = mapIdLead.get(sr.getLeadId()).FlagPSAProduct__c,
                                    IdCookies__c                            = mapIdLead.get(sr.getLeadId()).IdCookies__c,
                                    IdReservationVD__c                      = mapIdLead.get(sr.getLeadId()).IdReservationVD__c,
                                    InitialPurchaseDate__c                  = mapIdLead.get(sr.getLeadId()).InitialPurchaseDate__c,
                                    LCDVInterest__c                         = mapIdLead.get(sr.getLeadId()).LCDVInterest__c,
                                    LCDVOwnedProduct__c                     = mapIdLead.get(sr.getLeadId()).LCDVOwnedProduct__c,
                                    //#7/3#LeadChannel__c                           =mapIdLead.get(sr.getLeadId()).LeadChannel__c,
                                    Country__c                              = mapIdLead.get(sr.getLeadId()).LeadCountry__c,
                                    LeadLabel__c                            = mapIdLead.get(sr.getLeadId()).LeadLabel__c,
                                    LeadRequestDate__c                      = mapIdLead.get(sr.getLeadId()).LeadRequestDate__c,
                                    LeadRequestType__c                      = mapIdLead.get(sr.getLeadId()).LeadRequestType__c,
                                    LeadSource                              = mapIdLead.get(sr.getLeadId()).LeadSource,
                                    //#7/3#LeadType__c                              =mapIdLead.get(sr.getLeadId()).LeadType__c,
                                    Link__c                                 = mapIdLead.get(sr.getLeadId()).Link__c,
                                    LinkDescription__c                      = mapIdLead.get(sr.getLeadId()).LinkDescription__c,
                                    MarketingCode__c                        = mapIdLead.get(sr.getLeadId()).MarketingCode__c,
                                    // --> Different Types!!
                                    //MileageBeforeCheckOut__c                =mapIdLead.get(sr.getLeadId()).MileageBeforeCheckOut__c,
                                    // --> END
                                    MonthlyPayments__c                      = mapIdLead.get(sr.getLeadId()).MonthlyPayments__c,
                                    NumberFleetVehiclesFinanceContract__c   = mapIdLead.get(sr.getLeadId()).NumberFleetVehiclesFinanceContract__c,
                                    OnTheRoadFirstDate__c                   = mapIdLead.get(sr.getLeadId()).OnTheRoadFirstDate__c,
                                    PreferredContactMethod__c               = mapIdLead.get(sr.getLeadId()).PreferredContactMethod__c,
                                    ProductCustomerInterest__c              = mapIdLead.get(sr.getLeadId()).ProductCustomerInterest__c,
                                    ProductOwned__c                         = mapIdLead.get(sr.getLeadId()).ProductOwned__c,
                                    Brand__c                                = mapIdLead.get(sr.getLeadId()).PSABrand__c,
                                    PurchaseIntentionPeriod__c              = mapIdLead.get(sr.getLeadId()).PurchaseIntentionPeriod__c,
                                    RemainingAmount__c                      = mapIdLead.get(sr.getLeadId()).RemainingAmount__c,
                                    SecondAppointmentDateDesired__c         = mapIdLead.get(sr.getLeadId()).SecondAppointmentDateDesired__c,
                                    SecondDesiredSchedule__c                = mapIdLead.get(sr.getLeadId()).SecondDesiredSchedule__c,
                                    ServiceOfferInterestFlag__c             = mapIdLead.get(sr.getLeadId()).ServiceOfferInterestFlag__c,
                                    Vehiclestatus__c                        = mapIdLead.get(sr.getLeadId()).Vehiclestatus__c,
                                    VehicleFinishingDescription__c          = mapIdLead.get(sr.getLeadId()).VehicleFinishingDescription__c,
                                    // --> Different Types!!
                                    //VehicleMileage__c                       =mapIdLead.get(sr.getLeadId()).VehicleMileage__c,
                                    // --> end 
                                    VehicleOfferInterestFlag__c             = mapIdLead.get(sr.getLeadId()).VehicleOfferInterestFlag__c,
                                    VehiclePerformances__c                  = mapIdLead.get(sr.getLeadId()).VehiclePerformances__c,
                                    VehicleRegistrationNumber__c            = mapIdLead.get(sr.getLeadId()).VehicleRegistrationNumber__c,
                                    VehicleType__c                          = mapIdLead.get(sr.getLeadId()).VehicleType__c,
                                    VINOwnedVehicle__c                      = mapIdLead.get(sr.getLeadId()).VINOwnedVehicle__c,
                                    TECH_Web2Lead__c                        = mapIdLead.get(sr.getLeadId()).TECH_Web2Lead__c,
                                    VNContractNumber__c                     = (mapIdLead.get(sr.getLeadId()).Activity__c == 'VN' || mapIdLead.get(sr.getLeadId()).Activity__c == 'VO' || mapIdLead.get(sr.getLeadId()).Activity__c == 'FI') ?
                                                                                mapIdLead.get(sr.getLeadId()).DestinationPOSCode__c :
                                                                                null
                                )
                            );
                            
                            
                            if(mapIdLead.get(sr.getLeadId())!=null && mapIdLead.get(sr.getLeadId()).Company != null){
                                                                                              
                                //B2B Account field mapping
                                lAccountsToUpdate.add(
                                    new Account(
                                        Id                                          =sr.getAccountId(),
                                        Type                                        = TYPE_ACCOUNT,
                                        Adress2__c                                  =mapIdLead.get(sr.getLeadId()).Address2__c,
                                        BillingCity                                 =mapIdLead.get(sr.getLeadId()).City,
                                        Name                                        =mapIdLead.get(sr.getLeadId()).Company,
                                        Industry                                    =mapIdLead.get(sr.getLeadId()).Industry,
                                        CompanyActivityType__c                      =mapIdLead.get(sr.getLeadId()).CompanyActivityType__c,
                                        BillingCountry                              =mapIdLead.get(sr.getLeadId()).Country,
                                        DescriptionofVehicleVPParcSize__c           =mapIdLead.get(sr.getLeadId()).DescriptionofVehicleVPParcSize__c,
                                        DescriptionofVehicleVUParcSize__c           =mapIdLead.get(sr.getLeadId()).DescriptionofVehicleVUParcSize__c,
                                        FiscalId__c                                 =mapIdLead.get(sr.getLeadId()).FiscalId__c,
                                        FleetSize__c                                =mapIdLead.get(sr.getLeadId()).FleetSize__c,
                                        //#7/3#IdCodeVehicleVPParcSize__c                   =mapIdLead.get(sr.getLeadId()).IdCodeVehicleVPParcSize__c,
                                        //#7/3#IdCodeVehicleVUParcSize__c                   =mapIdLead.get(sr.getLeadId()).IdCodeVehicleVUParcSize__c,
                                        LocalIdOfCustomer__c                        =mapIdLead.get(sr.getLeadId()).LocalIdOfCustomer__c,
                                        MainBrandofVehicleVPParc__c                 =mapIdLead.get(sr.getLeadId()).MainBrandofVehicleVPParc__c,
                                        MainBrandofVehicleVUParc__c                 =mapIdLead.get(sr.getLeadId()).MainBrandofVehicleVUParc__c,
                                        MainModelofVehicleVPParc__c                 =mapIdLead.get(sr.getLeadId()).MainModelofVehicleVPParc__c,
                                        MainModelofVehicleVUParc__c                 =mapIdLead.get(sr.getLeadId()).MainModelofVehicleVUParc__c,
                                        NumberOfEmployees                           =mapIdLead.get(sr.getLeadId()).NumberOfEmployees,
                                        BillingPostalCode                           =mapIdLead.get(sr.getLeadId()).PostalCode,
                                        Brand__c                                    =mapIdLead.get(sr.getLeadId()).PSABrand__c,
                                        FlagAC__c                                   = (mapIdLead.get(sr.getLeadId()).PSABrand__c == 'AC' || mapIdLead.get(sr.getLeadId()).PSABrand__c == 'All')?TRUE:FALSE,
                                        FlagAP__c                                   = (mapIdLead.get(sr.getLeadId()).PSABrand__c == 'AP' || mapIdLead.get(sr.getLeadId()).PSABrand__c == 'All')?TRUE:FALSE,
                                        FlagDS__C                                   = (mapIdLead.get(sr.getLeadId()).PSABrand__c == 'DS' || mapIdLead.get(sr.getLeadId()).PSABrand__c == 'All')?TRUE:FALSE,
                                        RenewalDateVehicleVPParc__c                 =mapIdLead.get(sr.getLeadId()).RenewalDateVehicleVPParc__c,
                                        RenewalDateVehicleVUParc__c                 =mapIdLead.get(sr.getLeadId()).RenewalDateVehicleVUParc__c,
                                        BillingState                                =mapIdLead.get(sr.getLeadId()).State,
                                        BillingStreet                               =mapIdLead.get(sr.getLeadId()).Street
                                    )
                                );
                                
                            }
                            
                            if(setIdLeadAccountContactRel.contains(sr.getLeadId())){
                                AccountContactRelation acr = new AccountContactRelation(AccountId = sr.getAccountId(), ContactId = sr.getContactId());
                                lAccountContactRel.add(acr);
                                 /* START C1STRUN-279 */
                                mapAccountSharing.put(sr.getAccountId(),mapIdLead.get(sr.getLeadId()).OwnerId);
                                /* END C1STRUN-279 */
                            }
                        }
                        else {// Operation failed, so get all errors
                            
                            //remove the accounts create before conversion.
                            if(mapIdLeadB2BAccount.values().contains(sr.getAccountId()) || mapIdLeadPAccount.values().contains(sr.getAccountId()))
                                lAccountsToDelete.add(new Account(id=sr.getAccountId()));
                            
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('The following error has occurred.');                    
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Account fields that affected this error: ' + err.getFields());
                                LeadConversionProcess.sendEmailLeadConversion(userinfo.getUserEmail(),EMAIL_SUBJECT,err.getMessage(),sr.getLeadId());
                            }
                        }
                    }
                    
                    if(!lSObjects.isEmpty())
                        AccountSharing.ManualSharingLeadConversion(lSObjects);//to give edit permissions to owner of opportunity/lead.
                    
                    /* START C1STRUN-279 */
                    if(!mapAccountSharing.isEmpty())
                        AccountSharing.PGroupAccountSharingLeadConversion(mapAccountSharing);
                    /* END C1STRUN-279 */

                    database.delete(lAccountsToDelete,true);
                   
                    //updates following the field mapping.
                    database.update(lOpportunityToUpdate,true);
                    database.update(lAccountsToUpdate,true);
                    database.update(lContactToUpdate,true);
                    
                    
                    
                    LeadConversionProcess.createConsent(lLeadConsentToCreate);
                    
                    database.insert(lAccountContactRel,true);

                }


            }catch(System.DmlException e){
                System.debug('DmlException ERROR LeadConversionProcess.ConvertLead -->' + e.getMessage() + ' Line: '+e.getLineNumber());
                LeadConversionProcess.sendEmailLeadConversion(userinfo.getUserEmail(),EMAIL_SUBJECT,e.getMessage(),e.getDmlId(0));
            }catch(Exception e){
                System.debug('Exception ERROR LeadConversionProcess.ConvertLead-->' + e.getMessage() + ' Line: '+e.getLineNumber());
                LeadConversionProcess.sendEmailLeadConversion(userinfo.getUserEmail(),EMAIL_SUBJECT,e.getMessage(),null);
            }
    
        }
    }
    
    public static void createConsent(List<Lead> lLeads){
        System.debug('**** CREATE CONSENTS ****');
        List<Consent__c> lConsents = new List<Consent__c>();
        
        for(Lead oLead : lLeads){
            lConsents.add(new Consent__c(
                Contact__c				=mapIdLeadContact.get(oLead.id),
                DocumentBrand__c		=oLead.PSABrand__c,
                DocumentRelease__c		='',
                DocumentType__c			='WebForm',//apiname
                EnteredByCustomer__c	=(oLead.leadchannel__C == '12' || oLead.leadchannel__C == '13')?true:false,
                //ProcessedDate__c=oLead.,
                CollectorUserId__c		=(oLead.leadchannel__C == '10' || oLead.leadchannel__C == '11' || oLead.leadchannel__C == '14' || oLead.leadchannel__C == '15' || oLead.leadchannel__C == '16' )?oLead.ownerId:null,
                Purpose__c				='Marketing&survey',//api name
                CollectedCountry__c		=oLead.LeadCountry__c,
                CollectedDate__c		=oLead.LeadRequestDate__c,
                CollectedEntityId__c	=oLead.CalculatedPOS__c,
                CheckBox1Meaning__c		=oLead.CheckBox1Meaning__c,
                CheckBox1Value__c		=oLead.CheckBox1Value__c,
                CheckBox2Meaning__c		=oLead.CheckBox2Meaning__c,
                CheckBox2Value__c		=oLead.CheckBox2Value__c,
                CheckBox3Meaning__c		=oLead.CheckBox3Meaning__c,
                CheckBox3Value__c		=oLead.CheckBox3Value__c,
                CheckBox4Meaning__c		=oLead.CheckBox4Meaning__c,
                CheckBox4Value__c		=oLead.CheckBox4Value__c,
                CheckBox5Meaning__c		=oLead.CheckBox5Meaning__c,
                CheckBox5Value__c		=oLead.CheckBox5Value__c,
                CheckBox6Meaning__c		=oLead.CheckBox6Meaning__c,
                CheckBox6Value__c		=oLead.CheckBox6Value__c,
                CheckBox7Meaning__c		=oLead.CheckBox7Meaning__c,
                CheckBox7Value__c		=oLead.CheckBox7Value__c,
                CheckBox8Meaning__c		=oLead.CheckBox8Meaning__c,
                CheckBox8Value__c		=oLead.CheckBox8Value__c,
                CheckBox9Meaning__c		=oLead.CheckBox9Meaning__c,
                CheckBox9Value__c		=oLead.CheckBox9Value__c,
                CheckBox10Meaning__c	=oLead.CheckBox10Meaning__c,
                CheckBox10Value__c		=oLead.CheckBox10Value__c
                )
            );
        }

        try {
            Database.insert(lConsents,TRUE);
            System.debug('****##RM## CONSENTS: '+lConsents);
        } catch (System.DmlException e) {
            System.debug('DmlException ERROR LeadConversionProcess.createConsent -->' + e.getMessage() + ' Line: '+e.getLineNumber());
            LeadConversionProcess.sendEmailLeadConversion(userinfo.getUserEmail(),EMAIL_SUBJECT,e.getMessage(),e.getDmlId(0));
        } catch (Exception e) {
            System.debug('Exception ERROR LeadConversionProcess.createConsent-->' + e.getMessage() + ' Line: '+e.getLineNumber());
            LeadConversionProcess.sendEmailLeadConversion(userinfo.getUserEmail(),EMAIL_SUBJECT,e.getMessage(),null);
        }
    }

}
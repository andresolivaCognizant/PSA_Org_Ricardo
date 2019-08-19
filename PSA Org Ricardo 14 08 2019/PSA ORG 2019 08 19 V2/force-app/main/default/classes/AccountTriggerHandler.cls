/*
*   @Class          :   AccountTriggerHandler
*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
*   @Created        :   20 feb 2018
*   @Description    :   To manage account trigger methods
*   ----------------------------------------------------------------------------------------------------------------------------
*   Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*   Developer            Date                   Description
*   Raul Barba           20/02/2018             Creation.
*   Ruben Fernandez      26/07/2018             C1STAGILE-XXXX  : Added After Insert method
*   Manuel Medina        22/01/2019             C1STAGILE-6351  : New logic to copy address based on selected checbox (CopyToBillingAddress__c/CopyFromBillingAddress__c)
*   Diego Rincon         16/01/2019             REFACTORING     : Process Builder migration
*   Manuel Medina        31/01/2019             C1ST-12624      : New logic to sync Contact.Salutation and Contact.TECH_Salutation__c fields
*   User                 00/00/2019             C1STAGILE       : 5489, 1348, 1018, 5246, 6140, 16847, 521
*   Manuel Medina        10/05/2019             C1STAGILE-9672  : Methods required because PBs will be inactive 
*   Ruben Fernandez      22/05/2019             C1STAGILE-9754  : List().contains method not working properly with IDs. 
*   Pedro Parraga        24/05/2019             C1STAGILE-9912  : Added before delete method. anonymous accounts can not be deleted
*   Ruben Fernandez      01/06/2019             REFACTORING     : Removed unnecesary loops and soql queries. Prepared to switch of specific methods
*   Ruben Fernandez      06/06/2019             C1STRUN-2516    : Fixed ConsentsInit method
*   ----------------------------------------------------------------------------------------------------------------------------
*/

public with sharing class AccountTriggerHandler {

    private static Boolean runtrigger                   = true;
    public static Boolean isLeadConversionProcess       = false;
    public static Boolean isCaseWebForm                 = false;
    private final static Id RT_ACCOUNT_DEALER           = Schema.SObjectType.ACCOUNT.getRecordTypeInfosByDeveloperName().get('Account_DealerPartner').getRecordTypeId();
    private final static Set<String> PSA_BRANDS         = new Set<String>{'AC', 'AP', 'DS'};
    private static Map<Id, User> map_DefaultOwnerCL     = new Map<Id, User>();
    private static Map<Id, User> map_DealerInfo         = new Map<Id, User>();
    private static Map<Id, User> map_ConsentInit        = new Map<Id, User>();
    private static Map<Id, User> map_OwnerInfo          = new Map<Id, User>();

    /*
     * @Method          :   shouldRunTrigger
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
     * @Created         :   20 feb 2018
     * @Description     :   To get the flag that indicate if the trigger should run or not
     * @Params          :   -
     * @Returns         :   -
     */     
    public static boolean shouldRunTrigger() {
        return runtrigger;
    }
    /*
     * @Method          :   dontRunTrigger
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
     * @Created         :   20 feb 2018
     * @Description     :   To indicate that the trigger should not run
     * @Params          :   -
     * @Returns         :   -
     */     
    public static void dontRunTrigger() {
        runtrigger = false;
    }
    /*
     * @Method          :   runTrigger
     * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
     * @Created         :   18 julio 2019
     * @Description     :   To indicate that the trigger should run
     * @Params          :   -
     * @Returns         :   -
     */     
    public static void runTrigger() {
        runtrigger = true;
    }
    /*
     * @Method          :   beforeInsert
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
     * @Created         :   20 feb 2018
     * @Description     :   Call the actions that handle the before insert trigger.
     * @Params          :   List<Account> records before the insert.
     * @Returns         :   -
     */
    @SuppressWarnings('PMD.CyclomaticComplexity')
    public static void beforeInsert(List<Account> lAccounts) {
        // user / operation based trigger bypassing
        if (!PAD.canTrigger('Account_BeforeInsert')) {
            return;
        }
        Set<Id> setIdLead            = new Set<Id>();
        Set<Id> setAllOwners         = new Set<Id>();
        Set<Id> setB2COwners         = new Set<Id>();

        List<Account> lstB2CAccounts = new List<Account>();
        List<Account> lstPersonAcc   = new List<Account>();
        map<Id,AccountUtils.WrapperMappingAccount> mapIdLeadWrapper = new map<Id,AccountUtils.WrapperMappingAccount>();
        for (Account acc :lAccounts) {
            if (acc.TECH_CreatedFromLead__c && acc.RecordTypeId == AccountConstants.ACCOUNT_RT_B2C && acc.TECH_Idlead__c!=null) {
                setIdLead.add(acc.TECH_Idlead__c);
            }
        }
        // preventing execution of unnecesary queries
        if(setIdLead.size()>0){
            for (Lead l : [Select id, phone,ConvertedAccountId,Email,Address2__c,Birthdate__c,FirstName,LastName,LandlinePersonalTelephone__c,LandlineProfessionalTelephone__c,
                        PSABrand__c,MobilePersonalTelephone__c,MobileProfessionalTelephone__c,Salutation,NationalId__c,tITLE,Language__c,State,Street,Country,PostalCode,City,LeadSource                     
                        FROM Lead where Id IN :setIdLead LIMIT 1000]){
                mapIdLeadWrapper.put(l.id, new AccountUtils.WrapperMappingAccount(l.phone,l.Email,l.Address2__c,l.Birthdate__c,l.FirstName,l.LastName,l.LandlinePersonalTelephone__c,
                                                                                    l.LandlineProfessionalTelephone__c,l.PSABrand__c,l.MobilePersonalTelephone__c,l.MobileProfessionalTelephone__c,
                                                                                    l.Salutation,l.NationalId__c,l.tITLE,l.Language__c,l.State,l.Street,l.Country,l.PostalCode,l.City,l.LeadSource));
            }
        }
        for(Account a :lAccounts){
            AccountUtils.populateAccountFromLead(a, mapIdLeadWrapper);
            if(a.recordtypeid == AccountConstants.ACCOUNT_RT_B2C){
                Standardized.accountB2C(a);
                lstB2CAccounts.add(a);
            }else if((a.recordtypeid == AccountConstants.ACCOUNT_RT_B2B) || (a.recordtypeid == RT_ACCOUNT_DEALER)){
                Standardized.accountNotB2C(a);
                AccountUtils.b2bCreationDate(a);
                AccountUtils.isBusinessCenter(a);
            }
            if (a.IsPersonAccount){ 
                if(null == a.et4ae5__Mobile_Country_Code__pc) {
                    lstPersonAcc.add(a);
                }
                consentManagement(a);
            }
            setAllOwners.add(a.OwnerId);
            AccountUtils.copyAddress( a );
            AccountUtils.populateSalutation( a, null );
            AccountUtils.fillShippingAddress(a);
            AccountUtils.fillFieldLeaser(a);
            AccountUtils.addressUpdateFromWilayaFields(a, null);            
        }
        setOwnersMaps(setAllOwners);
        ManagersPublicGroup.createPublicGroup(lAccounts);
        ManagersPublicGroupContract.createPublicGroup(lAccounts);
        if(!lstB2CAccounts.isEmpty()){
            PopulateStandardEmailAndPhone.setEmailAndPhone(lstB2CAccounts, null); 
            if(PAD.sUserCountry==AccountConstants.USER_COUNTRY_PT){
                PT00_NIFValidation.mainFunction(lstB2CAccounts, true);   //To validate the NIF Format for Portugal
            }
        }
        if(PAD.sUserCountry==AccountConstants.USER_COUNTRY_CL){
            CL00_RUTValidation.mainFunction(lAccounts);
        }
        if(!lstPersonAcc.isEmpty()){
            getOwnerInfo(lstPersonAcc);
        }
        anonymizeRecords(lAccounts);
        defaultsByOwner(lAccounts,setAllOwners);            // Only for Chile
        getDealerInfo(lAccounts,setAllOwners);
    }
    /*
     * @Method          :   beforeUpdate
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
     * @Created         :   20 feb 2018
     * @Description     :   Call the actions that handle the before update trigger.
     * @Params          :   List<Account> records before the update.
     */
    @SuppressWarnings('PMD.CyclomaticComplexity')
    public static void beforeUpdate(List<Account> lNewAccounts, map<id,account> mapOldAccounts) {
        // user / operation based trigger bypassing
        if (!PAD.canTrigger('Account_BeforeUpdate')) {
            return;
        }
        if (PAD.canTrigger('AllObjects_All_Interfaces')){
            AccountUtils.IsChatCaseAssignmentAccount(lNewAccounts);
        }
        map<Id, Account> mapAccountForgotten            = new map<Id, Account>();
        map<Id, Account> mapPersonContactIdForgotten    = new map<Id, Account>();
        List<Account> lAccountsToValidateRUT            = new List<Account>();
        List<Account> lAccountsToValidateNIF            = new List<Account>();
        List<Account> lstPersonAcc                      = new List<Account>();
        Set<Id> setB2COwners                            = new Set<Id>();
        Set<Id> setAllOwners                            = new Set<Id>();
        for(Account l : lNewAccounts){
            AccountUtils.copyAddress(l);
            AccountUtils.populateSalutation(l,mapOldAccounts);
            if (PAD.canTrigger('AllObjects_All_Interfaces')){
                if (l.recordtypeid == AccountConstants.ACCOUNT_RT_B2C && l.NationalId__pc != mapOldAccounts.get(l.id).NationalId__pc){
                    lAccountsToValidateRUT.add(l);
                } else if(l.recordtypeid == AccountConstants.ACCOUNT_RT_B2B && l.FiscalId__c != mapOldAccounts.get(l.id).FiscalId__c){
                    lAccountsToValidateRUT.add(l);
                }
                if (l.recordtypeid == AccountConstants.ACCOUNT_RT_B2C && 
                (l.FirstName != mapOldAccounts.get(l.Id).FirstName || l.LastName != mapOldAccounts.get(l.Id).LastName)){
                    Standardized.accountB2C(l);
                } else if(((l.recordtypeid == AccountConstants.ACCOUNT_RT_B2B) || (l.recordtypeid == RT_ACCOUNT_DEALER)) && l.Name != mapOldAccounts.get(l.Id).Name){
                    Standardized.accountNotB2C(l);
                }
            }
            if (l.IsPersonAccount){ 
                if(null == l.et4ae5__Mobile_Country_Code__pc) {
                    setB2COwners.add(l.OwnerId);
                    lstPersonAcc.add(l);
                }
                if (PAD.canTrigger('AllObjects_All_Interfaces')){
                    consentManagement(l);
                }
            }
            setAllOwners.add(l.OwnerId);
            if (l.recordtypeid == AccountConstants.ACCOUNT_RT_B2C && 
               (l.ACAnonymization__pc && !mapOldAccounts.get(l.id).ACAnonymization__pc) || 
               (l.APAnonymization__pc && !mapOldAccounts.get(l.id).APAnonymization__pc) || 
               (l.DSAnonymization__pc && !mapOldAccounts.get(l.id).DSAnonymization__pc)){
                   mapAccountForgotten.put(l.id,l);
                   mapPersonContactIdForgotten.put(l.PersonContactId,l);
            }
            if ((l.NationalId__pc != mapOldAccounts.get(l.id).NationalId__pc) ||                    //Changes in NationaId
               (l.NationalIdType__pc != mapOldAccounts.get(l.id).NationalIdType__pc) ||             //Changes in NationalType
               (l.NationalId2__pc!= mapOldAccounts.get(l.id).NationalId2__pc) ||                    //Changes in NationalId2
               (l.NationalId2Type__pc != mapOldAccounts.get(l.id).NationalId2Type__pc) ||           //Changes in NationalType2
               (l.NonResidentCustomer__pc != mapOldAccounts.get(l.id).NonResidentCustomer__pc) ||   //Changes in NonResidentCustomer
               (l.RecordTypeId != mapOldAccounts.get(l.id).RecordTypeId)){                          //Changes in RecordType
                    lAccountsToValidateNIF.add(l);
            }
            AccountUtils.fillShippingAddress(l); // C1STAGILE-5489
            AccountUtils.addressUpdateFromWilayaFields(l, mapOldAccounts);            
        }
        setOwnersMaps(setAllOwners); // Needed for get OwnerInfo

        if (PAD.canTrigger('AllObjects_All_Interfaces')){
            if(!lAccountsToValidateRUT.isEmpty()){
                if(PAD.sUserCountry==AccountConstants.USER_COUNTRY_CL){
                    CL00_RUTValidation.mainFunction(lAccountsToValidateRUT);
                }
            }
            if(!mapAccountForgotten.isEmpty()){
                ConsentForgotten.generateConsents(mapPersonContactIdForgotten);
            }
            anonymizeRecords(lNewAccounts);
            if(!lAccountsToValidateNIF.isEmpty()){
                if(PAD.sUserCountry==AccountConstants.USER_COUNTRY_PT){
                    PT00_NIFValidation.mainFunction(lNewAccounts, false);
                }
            }
        }
       
        if(!lstPersonAcc.isEmpty()){
            getOwnerInfo(lstPersonAcc);
        }

        PopulateStandardEmailAndPhone.setEmailAndPhone(lNewAccounts, mapOldAccounts);
        ManagersPublicGroup.createPublicGroup(lNewAccounts);
        ManagersPublicGroupContract.createPublicGroup(lNewAccounts);
    }
    /*
     * @Method          :   afterInsert
     * @Author          :   Ruben Fernandez
     * @Created         :   26 Jul 2018
     * @Description     :   Call the actions that handle the after insert trigger.
     * @Params          :   List<Account> records after the insert.
     * @Returns         :   -
     */
    @SuppressWarnings('PMD.CyclomaticComplexity')
    public static void afterInsert(List<Account> lNewAccounts) {
        // user / operation based trigger bypassing
        if (!PAD.canTrigger('Account_AfterInsert')) {
            return;
        }

        Map<Id,Id> mapOwnerAccounts     = new Map <Id, Id>();   // Store the owners of each account
        Set<Id> setAllOwners            = new Set<Id>();        // Store all owner Ids
        List<Account> lstShare          = new List<Account>();
        List<Account> lstAccountDMS     = new List<Account>();  // Reduce the number of accounts to iterate each time
        List<Account> lstAccountOpp     = new List<Account>();  // Reduce the number of accounts to iterate each time
        List<Account> lstAccountEmail   = new List<Account>();  // Reduce the number of accounts to iterate each time
        for (Account a : lNewAccounts) {
            if (a.RecordTypeId == AccountConstants.ACCOUNT_RT_B2C || a.RecordTypeId == AccountConstants.ACCOUNT_RT_B2B) {
                lstShare.add(a);
                if (a.RecordTypeId == AccountConstants.ACCOUNT_RT_B2C ){
                    lstAccountEmail.add(a);
                    mapOwnerAccounts.put(a.Id, a.OwnerId);
                }
            }
            if (PAD.sUserTypeCode == '1' && PAD.sUserDMS && PAD.sUserDMSType == '2'){
                lstAccountDMS.add(a);
            }
            setAllOwners.add(a.OwnerId);
            if ( AccountConstants.ACCOUNT_SOURCE_VISITSHOW == a.AccountSource && AccountConstants.ACCOUNT_TYPE_PROSPECT  == a.Type ){
                lstAccountOpp.add(a);
            }
        }
        if (PAD.canTrigger('AllObjects_All_Interfaces')){
            if(map_ConsentInit.isEmpty()){
                setOwnersMaps(setAllOwners);
            }

            consentsInit(lNewAccounts);        //reduce unnecesary loops
        
            if(!lstAccountOpp.isEmpty()) {
                AccountUtils.createOpportunity(lstAccountOpp);  //reduce unnecesary loops
            }
        
            //Send an email to the owner when creating the account, If it is a created in {the Lead Conversion Process / WebForm Case} is not executed ...
            if(!isLeadConversionProcess && !isCaseWebForm && PAD.canTrigger('Account_AfterInsert_SendEmails')){
                if (!lstAccountEmail.isEmpty()) {
                    sendEmailWhenProspectIsCreated(lstAccountEmail,mapOwnerAccounts);
                }
            }

            // Call DMS: Only S2S
            if(!lstAccountDMS.isEmpty()){
                SAPIWebhook.ProcessRecords(lstAccountDMS,1);
            }

        }
        // Extending Account Sharing
        if (!lstShare.isEmpty()) {
            ManualSharingProcess.ManualSharing(ManualSharingProcess.setRecordToShare(lstShare));
        }
        
        System.debug('CPU Time : ' + LIMITS.getCpuTime());
        System.debug('CPU Time Limit: ' + LIMITS.getLimitCpuTime());
    }
    /*
     * @Method          :   afterUpdate
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
     * @Created         :   20 feb 2018
     * @Description     :   Call the actions that handle the before update trigger.
     * @Params          :   List<Account> records before the update.
     * @Returns         :   -
     */     
    @SuppressWarnings('PMD.CyclomaticComplexity')
    public static void afterUpdate(List<Account> lNewAccounts, map<id,account> mapOldAccounts) {
        // user / operation based trigger bypassing
        if (!PAD.canTrigger('Account_AfterUpdate')) {
            return;
        }
        Map<Id, Account> mapAccountForgotten    = new Map<Id, Account>();
        List<Account> lstAccountDMS             = new List<Account>();
        List<Account> lstAccToShare             = new List<Account>();
        List<Account> lstAccToCheck             = new List<Account>();
        List<Id> lstAccountCase                 = new List<id>();
        List<Id> auxLST                         = new List<Id>();
        for (Account l : lNewAccounts){
            if (l.recordtypeid == AccountConstants.ACCOUNT_RT_B2C && 
               (l.ACAnonymization__pc && !mapOldAccounts.get(l.id).ACAnonymization__pc) || 
               (l.APAnonymization__pc && !mapOldAccounts.get(l.id).APAnonymization__pc) || 
               (l.DSAnonymization__pc && !mapOldAccounts.get(l.id).DSAnonymization__pc)){           
                mapAccountForgotten.put(l.id,l);
                if  (l.ACAccountStatus__c != AccountConstants.ACCOUNT_TYPE_CUSTOMER && l.APAccountStatus__c != AccountConstants.ACCOUNT_TYPE_CUSTOMER && l.DSAccountStatus__c != AccountConstants.ACCOUNT_TYPE_CUSTOMER &&
                    (l.ACAccountStatus__c == AccountConstants.ACCOUNT_TYPE_PROSPECT || l.APAccountStatus__c == AccountConstants.ACCOUNT_TYPE_PROSPECT || l.DSAccountStatus__c == AccountConstants.ACCOUNT_TYPE_PROSPECT)){
                    lstAccountCase.add(l.id);
                }
            }
            if (PAD.sUserTypeCode == '1' && PAD.sUserDMS && PAD.sUserDMSType == '2'){
                lstAccountDMS.add(l);
            }
            if ((l.RecordTypeId == AccountConstants.ACCOUNT_RT_B2C || l.RecordTypeId == AccountConstants.ACCOUNT_RT_B2B) && l.OwnerId != mapOldAccounts.get(l.Id).OwnerId){
                lstAccToShare.add(l);
            }
            if (l.recordtypeid == AccountConstants.ACCOUNT_RT_DEALER && (l.OwnerId != mapOldAccounts.get(l.id).OwnerId)){
                lstAccToCheck.add(l);
            }
            auxLST.add(l.Id);
        }

        // Extending Account Sharing
        if(!lstAccToShare.isEmpty()){
            ManualSharingProcess.ManualSharing(ManualSharingProcess.setRecordToShare(lstAccToShare));
        }
        if (PAD.canTrigger('AllObjects_All_Interfaces')){
            // Right to Forgotten
            if(!mapAccountForgotten.isEmpty()){
                AccountSharing.revokeAccessByBrand(mapAccountForgotten);
            }

            // Call DMS: Only S2S
            if(!lstAccountDMS.isEmpty()){
                SAPIWebhook.ProcessRecords(lstAccountDMS,1);
            }
           
            // FSL: Dealer Placa Change
            if(!lstAccToCheck.isEmpty()){
                DealerPlacaChangeFSL.endSecTerrRelation(lstAccToCheck,false);
            }
            
            // Clean Customer Cases
            if(lstAccountCase.size() != 0){
                fixCustomerCases(lstAccountCase);
            }
        
        }
    }
    /*
     * @Method          :   sendEmailWhenProspectIsCreated
     * @Description     :   After creating an account (B2C_PA) send an email to the Owner as a reminder to create an opportunity
     * @Param 1         :   List<Account> listAccounts: List of new accounts
     * @Return          :   -
     */     
    public static void sendEmailWhenProspectIsCreated(List<Account> listAccounts, Map<Id,Id> mapOwnerAccounts){
        try {
            if(mapOwnerAccounts != null && mapOwnerAccounts.size()>0){
                //Map<Id, User> mapOwners = new Map<Id, User>([SELECT Id, Email FROM User WHERE Id IN: mapOwnerAccounts.values()]);
                List<Messaging.SingleEmailMessage> listMails= new List<Messaging.SingleEmailMessage>();    //Create List Emails
                for(Id accountId : mapOwnerAccounts.keySet()){
                    Id ownerIdTmp = mapOwnerAccounts.get(accountId);
                    //if(mapOwners.containskey(ownerIdTmp) && mapOwners.get(ownerIdTmp).Email != null){
                    if(map_ConsentInit.containskey(ownerIdTmp) && map_ConsentInit.get(ownerIdTmp).Email != null){
                        Messaging.SingleEmailMessage  mail  = new Messaging.SingleEmailMessage();
                        List<String> listSendTo             = new List<String>();
                        //listSendTo.add(mapOwners.get(ownerIdTmp).Email);
                        listSendTo.add(map_ConsentInit.get(ownerIdTmp).Email);
                        mail.setToAddresses(listSendTo);
                        mail.setSenderDisplayName('Salesforce Support'); //Set Display Name
                        mail.setSubject(Label.ReminderEmailToCreateOppSubject);
                        mail.setHtmlBody(Label.ReminderEmailToCreateOppBody+' '+URL.getSalesforceBaseUrl().toExternalForm() + '/'+accountId);
                        listMails.add(mail);
                    }
                }
                //Send all emails 
                Messaging.sendEmail(listMails);
            }
        }
        catch(Exception e){
            System.debug( '\n\n\n\t<<<<<<<<< ExceptionType >>>>>>>>> \n\t\t@@--> getCause > ' + e.getCause() + '\n\t\t@@--> getLineNumber > ' + e.getLineNumber() + '\n\t\t@@--> getMessage > '+ e.getMessage() + '\n\t\t@@--> getStackTraceString > '+ e.getStackTraceString() + '\n\t\t@@--> getTypeName > ' + e.getTypeName() + '\n\n' );            
        }
    }
    /*
    * Moved from afterUpdate method.
    * @date     : 2019-05-22
    * @param    : list of account ids
    * @return   : -
    */
    private static void fixCustomerCases(List<Id> lstAccountCase){
        try{
            List<Case> lstCase                  = [SELECT id, AccountId, CaseSurveyFirstComments__c, CaseSurveyLastComments__c, 
                                                    SuppliedNationalID__c,RegistrationNumber__c,Description,VIN__c,
                                                    SuppliedCity__c,SuppliedEmail,SuppliedFirstName__c,SuppliedName,
                                                    SuppliedPhone,SuppliedZipCode__c  
                                                    FROM Case 
                                                    WHERE AccountId in:lstAccountCase LIMIT 1000];
            List<Id> lstIdCase                  = new List<Id>();
            for(Case ca : lstCase){
                ca.CaseSurveyFirstComments__c   = null;
                ca.CaseSurveyLastComments__c    = null;
                ca.SuppliedNationalID__c        = null;
                ca.RegistrationNumber__c        = null;
                ca.Description                  = null;
                ca.VIN__c                       = null;
                ca.SuppliedCity__c              = null;
                ca.SuppliedEmail                = null;
                ca.SuppliedFirstName__c         = null;
                ca.SuppliedName                 = null;
                ca.SuppliedPhone                = null;
                ca.SuppliedZipCode__c           = null;
                lstIdCase.add(ca.id); 
            }

            List<CaseComment> lstCaseComment    = [SELECT id, ParentId, CommentBody FROM CaseComment WHERE ParentId in:lstIdCase];
            List<Attachment> lstAttachment      = [SELECT id, ParentId, Description FROM Attachment WHERE ParentId in:lstIdCase];
            
            for(CaseComment ca : lstCaseComment){
                ca.CommentBody = null;
            }
            for(Attachment ca : lstAttachment){
                ca.Description = null;
            }
            Update lstCase;
            Update lstCaseComment;
            Update lstAttachment;

        }catch(DMLException e){
            System.debug(' DML Exception ' + e.getMessage() );
        }catch(Exception e){
            System.debug(' DML Exception ' + e.getMessage() );
        }
    }
    /**
     * Copy mobile country code information from person accounts' owner record.
     * This method replaces Account_PB001_Populate_Email_And_Phone process builder.
     *
     * @author          Diego Rincón
     * @date            2019-01-16
     * @param   lst     list of account records
     * @return          none
     */
    private static void getOwnerInfo(List<Account> lst) {
        for (Account a : lst) {
            if (
                a.IsPersonAccount && null == a.et4ae5__Mobile_Country_Code__pc && map_OwnerInfo.containsKey(a.OwnerId)
            ) {
                a.et4ae5__Mobile_Country_Code__pc = map_OwnerInfo.get(a.OwnerId).Contact.Account.Country__c;
            }
        }
    }
    /**
     * Right to be forgotten implementation per brand on account records.
     * This method replaces Account_PB002_Anonymised process builder.
     *
     * @author          Diego Rincón
     * @date            2019-01-17
     * @param   lst     list of account records
     * @return          none
     */
    private static void anonymizeRecords(List<Account> lst) {
        // map of accounts (with brands) whose related leads have to be anonymized
        Map<Id, Set<String>> map_a = new Map<Id, Set<String>>();

        for (Account a : lst) {
            if (
                a.ACAccountStatus__c == AccountConstants.ACCOUNT_TYPE_CUSTOMER ||
                a.APAccountStatus__c == AccountConstants.ACCOUNT_TYPE_CUSTOMER ||
                a.DSAccountStatus__c == AccountConstants.ACCOUNT_TYPE_CUSTOMER
            ) {
                if (a.ACAnonymization__pc) {
                    a.ACAccountStatus__c = AccountConstants.ACCOUNT_STATUS_ANONYMISED;
                    a.FlagAC__c          = false;
                }
                if (a.APAnonymization__pc) {
                    a.APAccountStatus__c = AccountConstants.ACCOUNT_STATUS_ANONYMISED;
                    a.FlagAP__c          = false;
                }
                if (a.DSAnonymization__pc) {
                    a.DSAccountStatus__c = AccountConstants.ACCOUNT_STATUS_ANONYMISED;
                    a.FlagDS__c          = false;
                }
                continue;
            }

            if (
                a.ACAccountStatus__c == AccountConstants.ACCOUNT_TYPE_PROSPECT ||
                a.APAccountStatus__c == AccountConstants.ACCOUNT_TYPE_PROSPECT ||
                a.DSAccountStatus__c == AccountConstants.ACCOUNT_TYPE_PROSPECT
            ) {
                if (a.ACAnonymization__pc) {
                    AccountUtils.obfuscateAccountFields(a);
                    a.ACAccountStatus__c = AccountConstants.ACCOUNT_STATUS_ANONYMISED;
                    a.FlagAC__c          = false;
                    if (a.Id != null) {
                        if (map_a.containsKey(a.Id)) {
                            map_a.get(a.Id).add('AC');
                        } else {
                            map_a.put(
                                a.Id,
                                new Set<String>{'AC'}
                            );
                        }
                    }
                }
                if (a.APAnonymization__pc) {
                    AccountUtils.obfuscateAccountFields(a);
                    a.APAccountStatus__c = AccountConstants.ACCOUNT_STATUS_ANONYMISED;
                    a.FlagAP__c          = false;
                    if (a.Id != null) {
                        if (map_a.containsKey(a.Id)) {
                            map_a.get(a.Id).add('AP');
                        } else {
                            map_a.put(
                                a.Id,
                                new Set<String>{'AP'}
                            );
                        }
                    }
                }

                if (a.DSAnonymization__pc) {
                    AccountUtils.obfuscateAccountFields(a);
                    a.DSAccountStatus__c = AccountConstants.ACCOUNT_STATUS_ANONYMISED;
                    a.FlagDS__c          = false;
                    if (a.Id != null) {
                        if (map_a.containsKey(a.Id)) {
                            map_a.get(a.Id).add('DS');
                        } else {
                            map_a.put(
                                a.Id,
                                new Set<String>{'DS'}
                            );
                        }
                    }
                }
            }
        }
        if (!map_a.isEmpty()) {
            obfuscateRelatedLeads(map_a);
        }
    }
    
    /*
     * @Method          :   obfuscateRelatedLeads
     * @Description     :   Anonymized a List of Leads with Status <> New.
     * @Params          :   Map with a Customer or Contact Id 
     *                      and a Set of Brands per customer.
     * @Returns         :   -
    */ 
    private static void obfuscateRelatedLeads(Map<Id, Set<String>> map_a) {
        // leads to anonimize
        List<Lead> lst_l = new List<Lead>();
        for (Lead l : [
            SELECT Id, PSABrand__c, Customer__c, CustomerContact__c
            FROM Lead
            WHERE 
                Status != 'New' AND
                (
                    CustomerContact__c IN :map_a.keySet() OR
                    Customer__c IN :map_a.keySet()
                )
        ]) {
            if (
                map_a.containsKey(l.CustomerContact__c) &&
                map_a.get(l.CustomerContact__c).contains(l.PSABrand__c)
            ) {
                lst_l.add(AccountUtils.anonymizedLead(l.Id));
                continue;
            }
            if (
                map_a.containsKey(l.Customer__c) &&
                map_a.get(l.Customer__c).contains(l.PSABrand__c)
            ) {
                lst_l.add(AccountUtils.anonymizedLead(l.Id));
            }
        }
        try{
            update lst_l;  
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    /**
     * Retrieve information from account's record owner for chilean users.
     * This method replaces Account_PB003_ConsentInitializated process builder.
     *
     * @author          Diego Rincón
     * @date            2019-01-17
     * @param   lst     list of account records
     * @return          none
    */
    private static void defaultsByOwner(List<Account> lst,Set<Id> set_o) {
        for (Account a : lst) {
            if (map_DefaultOwnerCL.containsKey(a.OwnerId)) {
                a.Brand__c          = map_DefaultOwnerCL.get(a.OwnerId).Brand__c;
                a.Country__c        = map_DefaultOwnerCL.get(a.OwnerId).Country__c;
                a.CurrencyIsoCode   = 'CLP';
            }
        }
    }

    /**
     * Insert a consent record for new chilean accounts. This method replaces
     * Account_PB003_ConsentInitializated process builder.
     *
     * @author          Diego Rincón
     * @date            2019-01-18
     * @param   lst     list of account records
     * @return          none
     */
    private static void consentsInit(List<Account> lst) {

        // consents to insert
        List<Consent__c> lst_c                  = new List<Consent__c>();
        Map<String,String> lstDealerId          = new Map<String,String>();
        Map<String,String> mapCollectedEntity   = new Map<String,String>();

        // check if current user will skip actions performed in this method
        if (PAD.uCurrentUserName.TECH_ProcessBuilderBypass__c) {
            return;
        }

        for(User us : map_ConsentInit.values()){
            if(null != us.AccountId){
                lstDealerId.put(us.AccountId, us.Id);
            }
        }

        List<Account> lstCollectedEntity = [SELECT Id, SiteGeoIdPK__c FROM Account WHERE Id IN : lstDealerId.keySet() AND RecordTypeId = : RT_ACCOUNT_DEALER];
        if(!lstCollectedEntity.isEmpty()){
            for(Account acc : lstCollectedEntity){
                mapCollectedEntity.put(lstDealerId.get(acc.Id), acc.Id);
            }
            
            for (Account a : lst) {
                if (
                    null != a.PersonContactId &&
                    null == a.TECH_IdLead__c &&
                    (
                        map_ConsentInit.get(a.OwnerId).Country__c == AccountConstants.USER_COUNTRY_CL||
                        a.Country__c == AccountConstants.USER_COUNTRY_CL
                    ) && 
                    mapCollectedEntity.containsKey(a.OwnerId)
                ) {
                    lst_c.add(new Consent__c(
                        Contact__c              = a.PersonContactId,
                        Purpose__c              = 'Marketing&survey',
                        CheckBox1Meaning__c     = 'MkgPOSBrand',
                        CheckBox1Value__c       = true,
                        CollectedCountry__c     = a.Country__c,
                        CollectedDate__c        = System.now(),
                        CollectedEntityId__c    = mapCollectedEntity.get(a.OwnerId),
                        CollectorUserId__c      = a.OwnerId,
                        DocumentBrand__c        = a.Brand__c,
                        EnteredByCustomer__c    = false,
                        TECH_AccountId__c       = a.Id
                    ));
                }
            }
            try{
                Insert lst_c;
            }catch(Exception e){
                System.debug(e.getMessage());
            }
        }
    }
    ///-----------------------------------------------------------------------------///
    /**
     * Person accounts consent management per PSA brand. This method replaces
     * Account_PB005_Consent_Management process builder.
     *
     * @author          Diego Rincón
     * @date            2019-01-21
     * @param   lst     list of person account records
     * @return          none
     */
    private static void consentManagement(Account a) {
        // citroën - begin
        if (
            '1' == a.AC_Forgotten_Request_Status__pc &&
            null != a.ACForgottenRequestDate__pc
        ) {
            if (AccountConstants.ACCOUNT_TYPE_CUSTOMER == a.ACAccountStatus__c) {
                a.ACAnonymization__pc               = true;
                a.AC_Forgotten_Request_Status__pc   = '2';
            }
            if (
                AccountConstants.ACCOUNT_TYPE_CUSTOMER != a.APAccountStatus__c &&
                AccountConstants.ACCOUNT_TYPE_CUSTOMER != a.DSAccountStatus__c &&
                (
                    AccountConstants.ACCOUNT_TYPE_PROSPECT == a.ACAccountStatus__c ||
                    AccountConstants.ACCOUNT_TYPE_OLDCUSTOMER == a.ACAccountStatus__c
                )
            ) {
                a.ACAnonymization__pc               = true;
                a.AC_Forgotten_Request_Status__pc   = '3';
            }
            if (
                AccountConstants.ACCOUNT_TYPE_PROSPECT == a.ACAccountStatus__c &&
                (
                    AccountConstants.ACCOUNT_TYPE_CUSTOMER == a.APAccountStatus__c ||
                    AccountConstants.ACCOUNT_TYPE_CUSTOMER == a.DSAccountStatus__c
                )
            ) {
                a.AC_Forgotten_Request_Status__pc   = '2';
            }
        }// citroën - end
        // peugeot - begin
        if (
            '1' == a.AP_Forgotten_Request_Status__pc &&
            null != a.APForgottenRequestDate__pc
        ) {
            if (AccountConstants.ACCOUNT_TYPE_CUSTOMER == a.APAccountStatus__c) {
                a.APAnonymization__pc               = true;
                a.AP_Forgotten_Request_Status__pc   = '2';
            }

            if (
                AccountConstants.ACCOUNT_TYPE_CUSTOMER != a.ACAccountStatus__c &&
                AccountConstants.ACCOUNT_TYPE_CUSTOMER != a.DSAccountStatus__c &&
                (
                    AccountConstants.ACCOUNT_TYPE_PROSPECT == a.APAccountStatus__c ||
                    AccountConstants.ACCOUNT_TYPE_OLDCUSTOMER == a.APAccountStatus__c
                )
            ) {
                a.APAnonymization__pc               = true;
                a.AP_Forgotten_Request_Status__pc   = '3';
            }

            if (
                AccountConstants.ACCOUNT_TYPE_PROSPECT == a.APAccountStatus__c &&
                (
                    AccountConstants.ACCOUNT_TYPE_CUSTOMER == a.ACAccountStatus__c ||
                    AccountConstants.ACCOUNT_TYPE_CUSTOMER == a.DSAccountStatus__c
                )
            ) {
                a.AP_Forgotten_Request_Status__pc   = '2';
            }
        }// peugeot - end
        // ds - begin
        if (
            '1' == a.DS_Forgotten_Request_Status__pc &&
            null != a.DSForgottenRequestDate__pc
        ) {
            if (AccountConstants.ACCOUNT_TYPE_CUSTOMER == a.DSAccountStatus__c) {
                a.DSAnonymization__pc               = true;
                a.DS_Forgotten_Request_Status__pc   = '2';
            }

            if (
                AccountConstants.ACCOUNT_TYPE_CUSTOMER != a.ACAccountStatus__c &&
                AccountConstants.ACCOUNT_TYPE_CUSTOMER != a.APAccountStatus__c &&
                (
                    AccountConstants.ACCOUNT_TYPE_PROSPECT == a.DSAccountStatus__c ||
                    AccountConstants.ACCOUNT_TYPE_OLDCUSTOMER == a.DSAccountStatus__c
                )
            ) {
                a.DSAnonymization__pc               = true;
                a.DS_Forgotten_Request_Status__pc   = '3';
            }

            if (
                AccountConstants.ACCOUNT_TYPE_PROSPECT == a.DSAccountStatus__c &&
                (
                    AccountConstants.ACCOUNT_TYPE_CUSTOMER == a.ACAccountStatus__c ||
                    AccountConstants.ACCOUNT_TYPE_CUSTOMER == a.APAccountStatus__c
                )
            ) {
                a.DS_Forgotten_Request_Status__pc   = '2';
            }
        }// ds - end
    }
    /**
     * Copy brand and country information from account owners' dealers. This
     * method replaces Account_PB008_Manually_Created_Pop_Dealer_flds
     * process builder.
     *
     * @author          Diego Rincón
     * @date            2019-01-21
     * @param   lst     list of account records
     * @return          none
     */
    private static void getDealerInfo(List<Account> lst, Set<Id> set_o) {
        for (Account a : lst) {
            if (map_DealerInfo.containsKey(a.OwnerId)) {
                a.Country__c    = map_DealerInfo.get(a.OwnerId).Contact.Account.Country__c;
                a.Brand__c      = map_DealerInfo.get(a.OwnerId).Contact.Account.Brand__c;
                switch on map_DealerInfo.get(a.OwnerId).Contact.Account.Brand__c {
                    when 'AC' {
                       a.FlagAC__c = true;
                    }
                    when 'AP' {
                       a.FlagAP__c = true;
                    }
                    when 'DS' {
                       a.FlagDS__c = true;
                    }
                }
            }
        }
    }
 
    /*
     * @Method          :   beforeDelete
     * @Author          :   Pedro Párraga <parragabornez.pedrojesus@ext.mpsa.com>
     * @Created         :   24 May 2019
     * @Description     :   Call the actions that handle the before delete trigger.
     * @Params          :   List<Account> records before the delete.
     * @Returns         :   -
    */     
    public static void beforeDelete(List<Account> lNewAccounts) {
        // user / operation based trigger bypassing
        if (!PAD.canTrigger('Account_BeforeDelete')) {
            return;
        }
        AccountUtils.IsChatCaseAssignmentAccount(lNewAccounts);
    }
    /* Reducing the number of Queries to just one */
    private static void setOwnersMaps(Set<Id> set_o){
        for(User usr : [SELECT Id,Country__c,Brand__c,Contact.AccountId,Contact.Account.Brand__c, 
                    Contact.Account.Country__c ,Email,SiteGeoId__c,TECH_ProcessBuilderBypass__c, AccountId 
                FROM User 
                WHERE Id IN : set_o AND ( Country__c = :AccountConstants.USER_COUNTRY_CL
                    OR Contact.Account.Brand__c IN :PSA_BRANDS
                    OR Contact.Account.Country__c != null) LIMIT 1000]){

            if(usr.Country__c == AccountConstants.USER_COUNTRY_CL){
                map_DefaultOwnerCL.put(usr.id,usr);
            }
            if(usr.Country__c != null){
                map_OwnerInfo.put(usr.id,usr);
            }
            if(usr.Contact.Account.Brand__c != null && usr.Contact.Account.Brand__c != 'ALL'){
                map_DealerInfo.put(usr.id,usr);
            }
            map_ConsentInit.put(usr.id,usr);
        }
    }
}
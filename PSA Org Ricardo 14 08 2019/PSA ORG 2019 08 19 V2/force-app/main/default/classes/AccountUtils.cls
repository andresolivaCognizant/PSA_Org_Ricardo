/**
 * Salesforce
 * @author              Diego Rincón (DR) href=<diego.rincon@ext.mpsa.com>
 * Project:             PSA - Customer First
 * Description:         Helper class to handle bussiness logic related to the
 *                      Account standard sObject.
 *
 * Changes (version)
 * -------------------------------------------------------------------------------------------------
 *              No.     Date            Author                  Description
 *              ----    ------------    --------------------    ------------------------------------
 * @version     1.0     2018-12-03      Diego Rincón (DR)       Class creation.
 *              1.1     2019-06-01      Ruben Fernandez(RF)     Methods updated and moved from handler to utils.
 */

public class AccountUtils {

    private static final Map<Id, String> RT_MAP;
 
    static {
        RT_MAP = new Map<Id, String>();

        for (String dn : Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().keySet()) {
            RT_MAP.put(
                Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(dn).getRecordTypeId(),
                dn
            );
        }
    }

    /**
     * Copies shipping address compound fields data from the billing address
     * (B2B accounts) or mailing address (B2C accounts).
     *
     * @param   lst     list of account records being insterted or updated
     * @return          none
     */
    public static void fillShippingAddress(Account a) {
        //for (Account a : lst) {
            if (isShippingAddressEmpty(a)) {
                switch on RT_MAP.get(a.RecordTypeId) {
                    when 'Account_B2B' {
                        if (a.TECH_BillingAddresstoShippingAddress__c) {
                            //continue;
                        
                            a.ShippingCity          = a.BillingCity;
                            a.ShippingCountry       = a.BillingCountry;
                            a.ShippingLatitude      = a.BillingLatitude;
                            a.ShippingLongitude     = a.BillingLongitude;
                            a.ShippingPostalCode    = a.BillingPostalCode;
                            a.ShippingState         = a.BillingState;
                            a.ShippingStreet        = a.BillingStreet;
                        }
                    }
                    when 'PersonAccount_B2C' {
                        if (a.TECH_MailingAddresstoBillingAddress__pc) {
                            //continue;
                            a.ShippingCity          = a.PersonMailingCity;
                            a.ShippingCountry       = a.PersonMailingCountry;
                            a.ShippingLatitude      = a.PersonMailingLatitude;
                            a.ShippingLongitude     = a.PersonMailingLongitude;
                            a.ShippingPostalCode    = a.PersonMailingPostalCode;
                            a.ShippingState         = a.PersonMailingState;
                            a.ShippingStreet        = a.PersonMailingStreet;
                        }
                    }
                }
            }
        //}
    }

    /**
     * Checks if an account's shipping address compound field has an empty value
     *
     * @param   a       account record being evaluated
     * @return          true value when input address is considered empty
     */
    public static Boolean isShippingAddressEmpty(Account a) {
        return
            null == a.ShippingCity &&
            null == a.ShippingCountry &&
            null == a.ShippingPostalCode &&
            null == a.ShippingState &&
            null == a.ShippingStreet;
    }


    /**
      * @Method          :   fillFieldLeaser
      * @Author          :   Pedro Párraga <parragabornez.pedrojesus@ext.mpsa.com>
      * @Description     :   Filling Leaser field
      * @Param           :   Account record
      * @Return          :   void
    **/ 
    public static void fillFieldLeaser(Account acc){
        //for(Account acc : lstNewAccounts){
        if(acc.CompanyActivityType__c == '3' || acc.CompanyActivityType__c == '6'){
            acc.Leaser__c = true;
        }
        //}
    }
    /**
      * @Method          :   populateAccountFromLead
      * @Author          :   
      * @Description     :   Filling the account fields with the lead converted into it
      * @Param           :   Account  record, Map of custom lead fields
      * @Return          :   void
    **/ 
    public static void populateAccountFromLead(Account acc, Map<Id,AccountUtils.WrapperMappingAccount> mapIdLeadWrapper ){
        
            if(mapIdLeadWrapper.get(acc.TECH_Idlead__c)!=null){
                acc.Type                                = AccountConstants.ACCOUNT_TYPE_PROSPECT;
                acc.Phone                               = mapIdLeadWrapper.get(acc.TECH_Idlead__c).sPhone;
                acc.PersonEmail                         = mapIdLeadWrapper.get(acc.TECH_Idlead__c).sEmail;
                acc.PersonalEmail__pc                   = mapIdLeadWrapper.get(acc.TECH_Idlead__c).sEmail;
                acc.Adress2__c                          = mapIdLeadWrapper.get(acc.TECH_Idlead__c).sAdress2;
                acc.PersonBirthdate                     = mapIdLeadWrapper.get(acc.TECH_Idlead__c).sPersonBirthdate;
                acc.FirstName                           = mapIdLeadWrapper.get(acc.TECH_Idlead__c).sFirstName;
                acc.LastName                            = mapIdLeadWrapper.get(acc.TECH_Idlead__c).sLastName;
                acc.LandlinePersonalTelephone__pc       = mapIdLeadWrapper.get(acc.TECH_Idlead__c).sLandlinePersonalTelephone;
                acc.LandlineProfessionalTelephone__pc   = mapIdLeadWrapper.get(acc.TECH_Idlead__c).sLandlineProfessionalTelephone;
                acc.Brand__c                            = mapIdLeadWrapper.get(acc.TECH_Idlead__c).sBrand;
                acc.FlagAC__c                           = (mapIdLeadWrapper.get(acc.TECH_Idlead__c).sBrand == 'AC' || mapIdLeadWrapper.get(acc.TECH_Idlead__c).sBrand == 'All')?TRUE:FALSE;
                acc.FlagAP__c                           = (mapIdLeadWrapper.get(acc.TECH_Idlead__c).sBrand == 'AP' || mapIdLeadWrapper.get(acc.TECH_Idlead__c).sBrand == 'All')?TRUE:FALSE;
                acc.FlagDS__c                           = (mapIdLeadWrapper.get(acc.TECH_Idlead__c).sBrand == 'DS' || mapIdLeadWrapper.get(acc.TECH_Idlead__c).sBrand == 'All')?TRUE:FALSE;
                acc.MobilePersonalTelephone__pc         = mapIdLeadWrapper.get(acc.TECH_Idlead__c).sMobilePersonalTelephone;
                acc.MobileProfessionalTelephone__pc     = mapIdLeadWrapper.get(acc.TECH_Idlead__c).sMobileProfessionalTelephone;
                acc.Salutation                          = mapIdLeadWrapper.get(acc.TECH_Idlead__c).sSalutation;
                acc.PersonalEmail__pc                   = mapIdLeadWrapper.get(acc.TECH_Idlead__c).sEmail;
                acc.NationalId__pc                      = mapIdLeadWrapper.get(acc.TECH_Idlead__c).sNationalId;
                acc.PersonTitle                         = mapIdLeadWrapper.get(acc.TECH_Idlead__c).sTitle;
                acc.ClientLanguage__pc                  = mapIdLeadWrapper.get(acc.TECH_Idlead__c).sLanguage;
                acc.PersonMailingState                  = mapIdLeadWrapper.get(acc.TECH_Idlead__c).sState;
                acc.PersonMailingStreet                 = mapIdLeadWrapper.get(acc.TECH_Idlead__c).sStreet;
                acc.PersonMailingCountry                = mapIdLeadWrapper.get(acc.TECH_Idlead__c).sCountry;
                acc.PersonMailingPostalCode             = mapIdLeadWrapper.get(acc.TECH_Idlead__c).sPostalCode;
                acc.PersonMailingCity                   = mapIdLeadWrapper.get(acc.TECH_Idlead__c).sCity;
                acc.BillingState                        = mapIdLeadWrapper.get(acc.TECH_Idlead__c).sState;
                acc.BillingStreet                       = mapIdLeadWrapper.get(acc.TECH_Idlead__c).sStreet;
                acc.BillingCountry                      = mapIdLeadWrapper.get(acc.TECH_Idlead__c).sCountry;
                acc.BillingPostalCode                   = mapIdLeadWrapper.get(acc.TECH_Idlead__c).sPostalCode;
                acc.BillingCity                         = mapIdLeadWrapper.get(acc.TECH_Idlead__c).sCity;
                acc.PersonLeadSource                    = mapIdLeadWrapper.get(acc.TECH_Idlead__c).sLeadSource;
            }
    }
    /**
      * @Method          :   IsChatCaseAssignmentAccount
      * @Author          :   Pedro Párraga <parragabornez.pedrojesus@ext.mpsa.com>
      * @Description     :   If it's Chat Case Assignment Account, the account can not be edited or deleted
      * @Param           :   List<Account> lstNewAccounts
      * @Return          :   void
    **/ 
    public static void IsChatCaseAssignmentAccount(List<Account> lstNewAccounts){
        for(Account acc : lstNewAccounts){
            if(acc.TECH_IsChatCaseAssignmentAccount__c){
                acc.addError(Label.NoEditAndDeleteAccount);
            }
        }
    }
    /**
     * Check whether an account should be flagged as business center. This
     * method replaces Account_PB006_Business_Center process builder.
     *
     * @author          Diego Rincón
     * @date            2019-01-21
     * @param   lst     list of account records
     * @return          none
     */
    public static void isBusinessCenter(Account a) {
        //for (Account a : lst) {
            if (
                a.RecordTypeId == AccountConstants.ACCOUNT_RT_DEALER &&
                null != a.LicenseCode__c &&
                a.LicenseCode__c.contains('Z')
            ) {
                a.BusinessCenter__c = true;
            }
        //}
    }
    /**
     * Store records' creation date for B2B accounts. This method replaces
     * Account_PB007_Company_Creation_Date process builder.
     *
     * @author          Diego Rincón
     * @date            2019-01-21
     * @param   lst     list of account records
     * @return          none
     */
    public static void b2bCreationDate(Account a) {
        //for (Account a : lst) {
            if (a.RecordTypeId == AccountConstants.ACCOUNT_RT_B2B) {
                a.CompanyCreationDate__c = System.today();
            }
        //}
    }
     /**
     * Insert an opportunity record for new accounts. This method replaces
     * Account_PB004_Create_Opportunity process builder.
     *
     * @author          Diego Rincón
     * @date            2019-01-18
     * @param   lst     list of account records
     * @return          none
     */
    public static void createOpportunity(List<Account> lst) {
        List<Opportunity> lst_o = new List<Opportunity>();

        for (Account a : lst) {
            //if (
            //    'Visit Showroom' == a.AccountSource &&
            //    'Prospect' == a.Type
            //) {
                lst_o.add(new Opportunity(
                    CloseDate               = System.today().addDays(180),
                    Name                    = a.Name,
                    StageName               = '1',
                    AccountId               = a.Id,
                    CurrencyIsoCode         = a.CurrencyIsoCode,
                    ForecastCategoryName    = 'Omitted',
                    OwnerId                 = a.OwnerId
                ));
           // }
        }
        try{
            insert lst_o;   
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }

    /*
     * @Method          :   obfuscateAccountFields
     * @Description     :   Anonymized an Account.
     * @Params          :   Account to be anonymized / obfuscate.
     * @Returns         :   -
    */ 
    public static void obfuscateAccountFields(Account a) {
        a.BirthCity__pc                     = null;	
        a.CollaboratorAGAPEId__pc           = null;
        a.DayOfBirth__pc                    = null;	
        a.Salutation                        = null;
        a.FirstName                         = 'XXX';
        a.LastName                          = 'XXX';
        a.SingleName__pc                    = null;
        a.MaidenName__pc                    = null;
        a.LandlinePersonalTelephone__pc     = null;
        a.LandlineProfessionalTelephone__pc = null;
        a.MailingAddressComplement__pc      = null;
        a.MobilePersonalTelephone__pc       = null;
        a.MobileProfessionalTelephone__pc   = null;
        a.Patronym__pc                      = null;
        a.PersonBirthdate                   = null;
        a.PersonMailingCity                 = null;
        a.PersonMailingCountry              = null;
        a.PersonMailingPostalCode           = null;
        a.PersonMailingState                = null;
        a.PersonMailingStreet               = null;
        a.PersonEmail                       = 'XXX@XXX.XX';
        a.ProfessionalEmail__pc             = 'XXX@XXX.XX';
        a.PersonTitle                       = null;
        a.Email__c							= null;
        a.StandardizedFirstName__pc			= null;
        a.StandardizedLastName__pc			= null;
        a.Title__pc							= null;
        a.NationalId__pc					= null;
        a.NationalId2__pc					= null;
        a.PersonalEmail__pc					= null;
        a.MailingGPSGeocoding__pc			= null;
        a.BillingStreet						= null;
        a.BillingAddressComplement__c		= null;
        a.BillingCity						= null;
        a.BillingState						= null;
        a.BillingCountry					= null;
        a.BillingGPSGeocoding__c			= null;
        a.PersonMobilePhone					= null;
        a.PersonHomePhone					= null;
        a.LoyaltyCardId__pc					= null;
        a.DriverLicenceNumber__pc			= null;
        a.TECH_IdLead__c					= null;
    }
    /*
     * @Method          :   anonymizedLead
     * @Description     :   Anonymized a Lead.
     * @Params          :   Lead id to be anonymized.
     * @Returns         :   Same Lead anonymized
    */  
    public static Lead anonymizedLead(Id lead_id) {
        return new Lead(
            Id                                  = lead_id,
            Address2__c                         = null,
            BirthDate__c                        = null,
            DayOfBirth__c                       = null,
            City                                = null,
            Country                             = null,
            LeadCountry__c                      = null,
            Customer__c                         = null,
            CustomerContact__c                  = null,
            Email                               = 'XXX@XXX.XX',
            Salutation                          = null,
            Title                               = null,
            FirstName                           = 'XXX',
            LastName                            = 'XXX',
            FiscalId__c                         = null,
            LandlinePersonalTelephone__c        = null,
            LandlineProfessionalTelephone__c    = null,
            MobilePersonalTelephone__c          = null,
            MobileProfessionalTelephone__c      = null,
            NationalId__c                       = null,
            PostalCode                          = null,
            State                               = null,
            Street                              = null,
            VINOwnedVehicle__c                  = null
        );
    }
    /*
    * @Method          :   copyAddress
    * @Author          :   Manuel Medina
    * @Created         :   22 Jan 2019
    * @Description     :   Copy billing/mailing/shipping address from/to shipping/mailing/billing address.
    * @Params          :   Account objAccount
    * @Returns         :   -
    */ 
    public static void copyAddress( Account objAccount ){
        if( objAccount.CopyToBillingAddress__c && objAccount.IsPersonAccount ){
            objAccount.BillingState					= objAccount.PersonMailingState;
            objAccount.BillingStreet				= objAccount.PersonMailingStreet;
            objAccount.BillingCountry				= objAccount.PersonMailingCountry;
            objAccount.BillingPostalCode			= objAccount.PersonMailingPostalCode;
            objAccount.BillingCity					= objAccount.PersonMailingCity;
            
            objAccount.CopyToBillingAddress__c		= objAccount.CopyFromBillingAddress__c;
        }else if( objAccount.CopyFromBillingAddress__c && objAccount.IsPersonAccount ){
            objAccount.PersonMailingState			= objAccount.BillingState;
            objAccount.PersonMailingStreet			= objAccount.BillingStreet;
            objAccount.PersonMailingCountry			= objAccount.BillingCountry;
            objAccount.PersonMailingPostalCode		= objAccount.BillingPostalCode;
            objAccount.PersonMailingCity			= objAccount.BillingCity;
 
            objAccount.CopyFromBillingAddress__c	= objAccount.CopyToBillingAddress__c;
        }else if( objAccount.CopyToBillingAddress__c && !objAccount.IsPersonAccount ){
            objAccount.BillingState					= objAccount.ShippingState;
            objAccount.BillingStreet				= objAccount.ShippingStreet;
            objAccount.BillingCountry				= objAccount.ShippingCountry;
            objAccount.BillingPostalCode			= objAccount.ShippingPostalCode;
            objAccount.BillingCity					= objAccount.ShippingCity;
            
            objAccount.CopyToBillingAddress__c		= objAccount.CopyFromBillingAddress__c; 
        }else if( objAccount.CopyFromBillingAddress__c && !objAccount.IsPersonAccount ){
            objAccount.ShippingState				= objAccount.BillingState;
            objAccount.ShippingStreet				= objAccount.BillingStreet;
            objAccount.ShippingCountry				= objAccount.BillingCountry;
            objAccount.ShippingPostalCode			= objAccount.BillingPostalCode;
            objAccount.ShippingCity					= objAccount.BillingCity;
            
            objAccount.CopyFromBillingAddress__c	= objAccount.CopyToBillingAddress__c;
        }
    }
    /*
    * @Method          :   pupulateSalutation
    * @Author          :   Manuel Medina <manuel.medinaperez@ext.mpsa.com>
    * @Created         :   31 jan 2019
    * @Description     :   N/A
    * @Params          :   Account objAccount
    * @Params          :   Map<Id, Account> mapOldAccounts
    * @Returns         :   -
    */
    public static void populateSalutation( Account objAccount, Map<Id, Account> mapOldAccounts ){
        if( objAccount.RecordTypeId != null && objAccount.RecordTypeId.equals( AccountConstants.ACCOUNT_RT_B2C ) ){
            if( Trigger.isInsert && String.isNotBlank( objAccount.Salutation ) ){
                objAccount.TECH_Salutation__pc						= objAccount.Salutation;
            }else if( Trigger.isUpdate && String.isNotBlank( objAccount.Salutation ) && String.isNotBlank( mapOldAccounts.get( objAccount.Id ).Salutation ) && objAccount.Salutation != mapOldAccounts.get( objAccount.Id ).Salutation ){
                objAccount.TECH_Salutation__pc						= objAccount.Salutation;
            }else if( Trigger.isUpdate && String.isNotBlank( objAccount.TECH_Salutation__pc ) && objAccount.TECH_Salutation__pc != mapOldAccounts.get( objAccount.Id ).TECH_Salutation__pc ){
                objAccount.Salutation								= objAccount.TECH_Salutation__pc;
            }
        }
    }
    
    /*********************************************************************************************************
    * @Method          :   addressUpdateFromWilayafield
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/02/2019
    * @Description     :   This method updates the address from the XXWilaya__c fields. 
    * 					   This method replaces Account_PB009_Address_Update_from_Wilaya_field process builder
    * @params	       :   Account : objAccount record before insert/update
    * @Returns         :   void
    **********************************************************************************************************/    
    public static void addressUpdateFromWilayaFields( Account objAccount , Map<Id, Account> mapOldAccounts){
        if((mapOldAccounts == null && String.isNotBlank(objAccount.ShippingWilaya__c)) ||
           ((mapOldAccounts != null) && (mapOldAccounts.get(objAccount.Id).ShippingWilaya__c != objAccount.ShippingWilaya__c))){
            objAccount.ShippingState = objAccount.ShippingWilaya__c;
        }          
        if((mapOldAccounts == null && String.isNotBlank(objAccount.BillingWilaya__c)) ||
           ((mapOldAccounts != null) && (mapOldAccounts.get(objAccount.Id).BillingWilaya__c != objAccount.BillingWilaya__c))){        
            objAccount.BillingState = objAccount.BillingWilaya__c;            
        }
        if(objAccount.IsPersonAccount && 
           ((mapOldAccounts == null && String.isNotBlank(objAccount.MailingWilaya__pc)) ||
            ((mapOldAccounts != null) && (mapOldAccounts.get(objAccount.Id).MailingWilaya__pc != objAccount.MailingWilaya__pc)))){           
            objAccount.PersonMailingState = objAccount.MailingWilaya__pc;
        }
    }       

    public class WrapperMappingAccount{
        public string sPhone {get;set;}
        public string sEmail {get;set;}
        public string sAdress2 {get;set;}
        public Date sPersonBirthdate {get;set;}
        public string sFirstName {get;set;}
        public string sLastName {get;set;}
        public string sLandlinePersonalTelephone {get;set;}
        public string sLandlineProfessionalTelephone {get;set;}
        public string sBrand {get;set;}
        public string sMobilePersonalTelephone{get;set;}
        public string sMobileProfessionalTelephone{get;set;}
        public string sSalutation{get;set;}
        public string sNationalId{get;set;}
        public string sTitle{get;set;}
        public string sLanguage{get;set;}
        public string sState{get;set;}
        public string sStreet{get;set;}
        public string sCountry{get;set;}
        public string sPostalCode{get;set;}
        public string sCity{get;set;}
        public string sLeadSource{get;set;}

        public WrapperMappingAccount(string sPhone,string sEmail,String sAdress2 ,Date sPersonBirthdate ,String sFirstName ,String sLastName ,String sLandlinePersonalTelephone ,String sLandlineProfessionalTelephone ,
                                  String sBrand ,String sMobilePersonalTelephone,String sMobileProfessionalTelephone,String sSalutation,String sNationalId,
                                  String sTitle,String sLanguage,String sState,String sStreet,String sCountry,String sPostalCode,String sCity,String sLeadSource){

            this.sPhone                         = sPhone;
            this.sEmail                         = sEmail;
            this.sAdress2                       = sAdress2 ;
            this.sPersonBirthdate               = sPersonBirthdate ;
            this.sFirstName                     = sFirstName ;
            this.sLastName                      = sLastName ;
            this.sLandlinePersonalTelephone     = sLandlinePersonalTelephone ;
            this.sLandlineProfessionalTelephone = sLandlineProfessionalTelephone ;
            this.sBrand                         = sBrand ;
            this.sMobilePersonalTelephone       = sMobilePersonalTelephone;
            this.sMobileProfessionalTelephone   = sMobileProfessionalTelephone;
            this.sSalutation                    = sSalutation;
            this.sNationalId                    = sNationalId;
            this.sTitle                         = sTitle;
            this.sLanguage                      = sLanguage;
            this.sState                         = sState;
            this.sStreet                        = sStreet;
            this.sCountry                       = sCountry;
            this.sPostalCode                    = sPostalCode;
            this.sCity                          = sCity;
            this.sLeadSource                    = sLeadSource;
        }
    }
}
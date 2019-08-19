/*-- -----------  -----   -------  --------------------------------------------------
-- - Name         : TestDataFactoryUtil
-- - Author       : DXC. Ruben Fernandez Lopez
-- - Date         : 18/01/2018
-- - Description  : Test utility classes contain methods that can be called by
--                  test methods to perform useful tasks, such as setting up
--                  test data.
-- - Methods      : createAccount. Creates from 1 to n accounts of any record type
                    createAsset.   Creates from 1 to n asset records
                    createDealers. Creates from 1 to n dealers
                    createOpportunities. Creates from 1 to n opportunities
-- -----------  -----   -------  --------------------------------------------------
-- - History:
-- Date         Author  Version  Comments
-- -----------  -----   -------  --------------------------------------------------
-- 18/01/2018   DXC     1.0      Initial version rfernandezlo
-- 27/01/2019   SFDC    1.1      Updated createDealers method. DMS fields added.
-- -----------  -----   -------  --------------------------------------------------
*/
@isTest
public class TestDataFactoryUtil {

    /***********************************************************************************************************************************************************************
    *                                                                           ACCOUNT FACTORY                                                                            *
    ***********************************************************************************************************************************************************************/
    /**
    * This method is used to return a list of account records
    * @param numAccts - Number of Accounts to be created
    * @param sType - Type of account (B2B, B2C or Dealer);
    */
    public static List<Account> createAccount(Integer numAccts, String sType) {

        List<Account> lstAccts      = new List<Account>();
        String sKeyword             = '000000000';
        String rt                   = PAD.getObjRecordType('Account',sType);

        for(Integer i=0;i<numAccts;i++) {
            sKeyword = sKeyword + i;
            Account acct = new Account(
                Name                =   'Account_' +  sType +  '_' + uniqueKey(),
                BillingStreet       =   'Eduardo Barreiro Nº' +sKeyword.right(4),
                BillingCity         =   'Madrid',
                BillingCountry      =   'España',
                BillingPostalCode   =   sKeyword.right(5),
                RecordTypeId        =   rt);
            lstAccts.add(acct);
        }
        if(!lstAccts.isEmpty()){
            insert lstAccts;
        }

        return lstAccts;
    }
    /**
    * This method is used to return a list of person account records
    * @param numAccts - Number of Accounts to be created
    */
    public static List<Account> createPersonAccount(Integer numAccts) {

        List<Account> lstAccts      = new List<Account>();
        String sKeyword             = '000000000';
        String rt                   = PAD.getObjRecordType('Account','B2C_PA');

        for(Integer i=0;i<numAccts;i++) {
            sKeyword = sKeyword + i;
            Account acct = new Account(
                OwnerId             =   UserInfo.getUserId(),
                FirstName           =   'Account_' + uniqueKey(),
                LastName            =   uniqueKey(),
                Salutation          =   '1',
                Country__c          =   PAD.sUserCountry,
                PersonalEmail__pc   =   'test' + uniqueKey() + '@example.com',
                BillingStreet       =   'Eduardo Barreiro Nº' +sKeyword.right(4),
                BillingCity         =   'Madrid',
                BillingCountry      =   'España',
                BillingPostalCode   =   sKeyword.right(5),
                RecordTypeId        =   rt);
            lstAccts.add(acct);
        }
        if(!lstAccts.isEmpty()){
            insert lstAccts;
        }
        return lstAccts;
    }
    /**
    *   This method instanciate one account
    *   @
    */
    // public static Account createOneAccount(String sAccountName){
    //     'accName', '12345', Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2B').getRecordTypeId()

    // }


    /**
    * This method is used to return a list of account records
    * @param numAccts - Number of Accounts to be created
    * @param sType - Type of account (B2B, B2C or Dealer);
    */
    public static List<Account> createDealers(Integer numAccts, String sType, String sKeyWord, String sContNumber, String sDesPOSCode, String sBrand, String sCountry, String sLicense,List<String> lstActivities, Boolean isPdVInternal) {

        List<Account> lstAccts      = new List<Account>();
        String rt                   = PAD.getObjRecordType('Account',sType);
        Map<String,String> mapAux   = new Map<String, String>();
        for(String sVal : lstActivities){
            mapAux.put(sVal,'1');
        }
        String sName    = '';
        String sAddress = '';
        if(sKeyword.left(2)=='99'){
            sName       = 'Auxiliar_Dealer';
            sAddress    = 'Calle Del Sol ';
        }else{
            sName = sType + '_Account_';
            sAddress    = 'Calle de Sebastián Elcano ';
        }

        for(Integer i=0;i<numAccts;i++) {
            if(numAccts>1){
                if(i<10){
                    sDesPOSCode = sDesPOSCode.left(9) + i;
                }else if(i<100){
                    sDesPOSCode = sDesPOSCode.left(8) + i;
                }else if(i<1000){
                    sDesPOSCode = sDesPOSCode.left(7) + i;
                }else{
                    sDesPOSCode = sDesPOSCode.left(6) + i;
                }
            }
            sKeyword = sKeyword + i;
            Account acct = new Account(
                Name                        = sName + i + uniqueKey(),
                BillingStreet               = sAddress + sKeyword.right(4),
                BillingCity                 = 'Madrid',
                BillingCountry              = 'España',
                BillingPostalCode           = sKeyword.right(5),
                //Phone                       = sKeyword.right(9),
                PdVInterne__c               = isPdVInternal,
                VNContractNumber__c         = mapAux.containsKey('VN')?sContNumber:'',
                VNPrincipalSite__c          = mapAux.containsKey('VN'),
                RAContractNumber__c         = mapAux.containsKey('RA')?sContNumber:'',
                RAPrincipalSite__c          = mapAux.containsKey('RA'),
                PRContractNumber__c         = mapAux.containsKey('PR')?sContNumber:'',
                PRPrincipalSite__c          = mapAux.containsKey('PR'),
                AgentContractNumber__c      = mapAux.containsKey('Agent')?sContNumber:'',
                AgentPrincipalSite__c       = mapAux.containsKey('Agent'),
                VNContractBeginDate__c      = date.today() - 5,
                VNContractEndDate__c        = date.today() + 5,
                RAContractBeginDate__c      = date.today() - 5,
                RAContractEndDate__c        = date.today() + 5,
                PRContractBeginDate__c      = date.today() - 5,
                PRContractEndDate__c        = date.today() + 5,
                AgentContractBeginDate__c   = date.today() - 5,
                AgentContractEndDate__c     = date.today() + 5,
                SiteGeoIdPK__c              = sDesPOSCode,
                Brand__c                    = sBrand,
                Country__c                  = sCountry,
                PRFlag__c                   = mapAux.containsKey('PR'),
                RAFlag__c                   = mapAux.containsKey('RA'),
                VOActivity__c               = mapAux.containsKey('Agent'),
                VNFlag__c                   = mapAux.containsKey('VN'),
                AgentFlag__c                = mapAux.containsKey('Agent'),
                LicenseCode__c              = sLicense,
                DMSConnectedToC1st__c       = true,
                CommunicationMode__c        = (i==0)?'1':'2',      // --> DMS Field
                DMSport__c                  = '88',                // --> DMS Field
                UrlDMS__c                   = 'https://localhost', // --> DMS Field
                RecordTypeId                = rt,
            	OrderFormValidation__c		= true);
            lstAccts.add(acct);
        }
        if(!lstAccts.isEmpty()){
            insert lstAccts;
        }
        return lstAccts;
    }

    /**
    * This method is used to return a list of account records
    * @param numAccts - Number of Accounts to be created
    * @param sType - Type of account (B2B, B2C or Dealer);
    */
    public static List<Account> createAccountContact(Integer numAccts, String sType) {

        String sKeyword             =   '000000000';
        List<Contact> lstCnts       =   new List<Contact>();
        List<Account> lstAccts      =   createAccount(numAccts, sType);
        for(Integer i=0;i<lstAccts.size();i++) {
            sKeyword                =   sKeyword + i;
            Contact cnt             =   new Contact (
                FirstName           =   'Contact_FirstName_' +sKeyword.right(3),
                LastName            =   'Contact_LastName_',
                Salutation          =   '1',
                Email               =   'psaFirstName' + sKeyword.right(5) +  '@example.com',
                NationalId__c       =   'ID' + sKeyword,
                Phone               =   sKeyword.right(9),
                AccountId           =   lstAccts.get(i).Id,
                AvailableLeadTreatment__c  =  true
                );
            lstCnts.add(cnt);
        }
        if(!lstCnts.isEmpty()){
            insert lstCnts;
        }
        return lstAccts;
    }



    /**
     * @description create one account
     * @param mapApiNameToFieldValue - map that associate api name with the value
     * @param doInsert - allow to insert or not the record
     * @example Account account = TestDataFactoryUtil.createAccount(new map<String, Object>{
            'Name'                  => 'TEST MATCH 26',
            'Phone'                 => '+8434334',
            'BillingPostalCode'     => '23456',
            'RecordTypeId'          => PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2B)
        }, true);
     */
    public static Account createAccount(map<string,object> mapApiNameToFieldValue, boolean doInsert){
        Account account = (account)createSobject('Account', mapApiNameToFieldValue);

        if(doInsert){
            insert account;
        }

        return account;
    }

    /**
     * @description create several account
     * @param mapApiNameToFieldValue - map that associate api name with the value
     * @param doInsert - allow to insert or not the record
     * @param numberOfRecordToCreate - number of record to create
     * @example Cointact contact = TestDataFactoryUtil.createContact(new map<String, Object>{
            'AccountId'             => account.id,
            'FirstName'             => 'Contact FirstName',
            'LastName'              => 'Contact LastName',
            'Salutation'            => '1',
            'Phone'                 => '9867767',
            'ACAnonymization__c'    => true,
            'APAnonymization__c'    => true,
            'DSAnonymization__c'    => false,
            'TECH_OptOut__c'        => true
        }, true);
     */
    public static list<Account> createAccountList(map<string,object> mapApiNameToFieldValue, boolean doInsert, Integer numberOfRecordToCreate){
        list<Account> accounts = (list<Account>)createSobjectList('Account', mapApiNameToFieldValue,numberOfRecordToCreate);

        if(doInsert){
            insert accounts;
        }

        return accounts;
    }


    /***********************************************************************************************************************************************************************
    *                                                          ACCOUNT CONTACT ASSET RELATION FACTORY                                                                      *
    ***********************************************************************************************************************************************************************/

    /**
     * @description create one account contact asset relations
     * @param mapApiNameToFieldValue - map that associate api name with the value
     * @param doInsert - allow to insert or not the record
     * @example AccountContactAssetRelation__c accountContactAssetRelation = TestDataFactoryUtil.createAccountContactAssetRelation(new map<String, Object>{
            'PosessionChangeConfirmation__c' => true,
            'AccountRole__c'                 => 'Owner',
            'AccountId__c'                   => account.Id,
            'AssetId__c'                     => asset.Id,
            'RelationEndDate__c'             => System.today()
        }, true);
     */
    public static AccountContactAssetRelation__c createAccountContactAssetRelation(map<string,object> mapApiNameToFieldValue, boolean doInsert){
        AccountContactAssetRelation__c accountContactAssetRelation = (AccountContactAssetRelation__c)createSobject('AccountContactAssetRelation__c', mapApiNameToFieldValue);

        if(doInsert){
            insert accountContactAssetRelation;
        }

        return accountContactAssetRelation;
    }

    /***********************************************************************************************************************************************************************
    *                                                                           CONTACT FACTORY                                                                            *
    ***********************************************************************************************************************************************************************/

    /**
     * @description create one contact
     * @param mapApiNameToFieldValue - map that associate api name with the value
     * @param doInsert - allow to insert or not the record
     */
    public static Contact createContact(map<string,object> mapApiNameToFieldValue, boolean doInsert){
        Contact contact = (contact)createSobject('Contact', mapApiNameToFieldValue);

        if(doInsert){
            insert contact;
        }

        return contact;
    }


    /***********************************************************************************************************************************************************************
    *                                                                       OPPORTUNITY FACTORY                                                                            *
    ***********************************************************************************************************************************************************************/

    /**
    * This method is used to return a list of opportunities records
    * @param numOpps - Number of Opportunities to be created
    * @param sType - Type of Opportunity;
    * @param oAcct -  Account
    * @param dAmount - Type of account (B2B, B2C or Dealer);
    * @param sStageName -
    * @param dProbability -
    * @example Opportunity opportunity = TestDataFactoryUtil.createOpportunities(new map<String, Object>{
            'Name'          =>  'opportunity name',
            'Probability'   =>30,
            'Amount'        => 2,
            'AccountId'     => account.id,
            'CloseDate'     => System.today(),
            'Activity__c'   => 'VN',
            'Country__c'    => 'PL',
            'StageName'     => '1'
        }, true);

    */
    public static List<Opportunity> createOpportunities(Integer numOpps, String sType,Account oAcct,Decimal dAmount,String sStageName, Integer dProbability) {

        //String sKeyword             = '000000000';
        List<Opportunity> lstOpps   = new List<Opportunity>();
        //String rt                   = PAD.getObjRecordType('Opportunity',sType);
        String sKeyUnique           = '';

        for(Integer i=0;i<numOpps;i++) {
            sKeyUnique              =   uniqueKey();
            Opportunity opp         =   new Opportunity (
                Name                =   oAcct.Name + ' Opportunity Test' +sKeyUnique.right(3),
                StageName           =   sStageName,
                Probability         =   dProbability,
                Amount              =   dAmount,
                AccountId           =   oAcct.Id,
                CloseDate           =   System.today(),
                Activity__c         =   'VN',
                Country__c          =   'PL'
                //RecordTypeId        =   rt
                );
            lstOpps.add(opp);
        }
        if(!lstOpps.isEmpty()){
            insert lstOpps;
        }
        return lstOpps;
    }



    /**
     * @description create one opportunity
     * @param mapApiNameToFieldValue - map that associate api name with the value
     * @param doInsert - allow to insert or not the record
     * @example - Opportunity opportunity = TestDataFactoryUtil.createOpportunities(new map<String, Object>{
     *       'Name'         =>  'opportunity name',
     *       'Probability'   =>30,
     *       'Amount'        => 2,
     *       'AccountId'     => account.id,
     *       'CloseDate'     => System.today(),
     *       'Activity__c'   => 'VN',
     *       'Country__c'    => 'PL',
     *       'StageName'     => '1'
     *  } ,true);
     */
    public static Opportunity createOpportunities(map<String,Object> mapApiNameToFieldValue, boolean doInsert){
        Opportunity opportunity = (Opportunity)createSobject('Opportunity', mapApiNameToFieldValue);

        if(doInsert){
            insert opportunity;
        }

        return opportunity;
    }


    /***********************************************************************************************************************************************************************
    *                                                                        SBQQ QUOTE FACTORY                                                                            *
    ***********************************************************************************************************************************************************************/

    /**
     * @description create one Sbqq quote
     * @param mapApiNameToFieldValue - map that associate api name with the value
     * @param doInsert - allow to insert or not the record
     * @example - SBQQ__Quote__C quotes = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
        'SBQQ__ExpirationDate__c'   => System.today(),
        'SBQQ__Status__c'           => '1',
        'SBQQ__Opportunity2__c'     => opportunity.id
        } ,true);
     */
   public static SBQQ__Quote__c createSbqqQuote(map<String,Object> mapApiNameToFieldValue, boolean doInsert){
        
        //Mandatory Fields
        if (mapApiNameToFieldValue.get('ProductionYear__c')==null) {
            mapApiNameToFieldValue.put('ProductionYear__c', 2019);
        }
        SBQQ__Quote__c quotes = (SBQQ__Quote__c)createSobject('SBQQ__Quote__c', mapApiNameToFieldValue);

        if(doInsert){
            insert quotes;
        }

        return quotes;
    }

    /***********************************************************************************************************************************************************************
    *                                                                              USER FACTORY                                                                            *
    ***********************************************************************************************************************************************************************/

    /**
    * This method is used to return a list of account records
    * @param numAccts - Number of Accounts to be created
    * @param sType - Type of account (B2B, B2C or Dealer);
    */
    public static List<Contact> createPartnerUser(Integer numAccts,Integer numRecords, String sType, String sKeyWord, String sContNumber, String sDesPOSCode, String sBrand, String sCountry, String sLicense,List<String> lstActivities, Boolean bPdVInternal) {

        List<Contact> lstCnts       =   new List<Contact>();
        List<Account> lstAccts      =   createDealers( numAccts, sType, sKeyWord, sContNumber, sDesPOSCode, sBrand, sCountry, sLicense, lstActivities,bPdVInternal);
        for(Integer j=0;j<lstAccts.size();j++) {
            for(Integer i=0;i<numRecords;i++) {
                sKeyword                =   sKeyword + i;
                Contact cnt             =   new Contact (
                    FirstName           =   'First Name ' +sKeyword.right(3),
                    LastName            =   'LastName_',
                    Salutation          =   '1',
                    Email               =   'psaContactFirstName' + sKeyword.right(5) +  '@contactexample.com',
                    ProfessionalEmail__c=   'psaContactFirstName' + sKeyword.right(5) +  '@contactexample.com',
                    NationalId__c       =   sKeyword.right(8) + 'C',
                    Phone               =   sKeyword.right(9),
                    AccountId           =   lstAccts.get(j).Id,
                    AvailableLeadTreatment__c = true
                    );
                lstCnts.add(cnt);
            }
        }
        if(!lstCnts.isEmpty()){
            insert lstCnts;
        }

        return lstCnts;
    }


     /**
    * This method return an instanciate User
    * @param sProfileName - profile name
    * @param sRoleNameDeveloperName - role developer name
    * @return User instanciated
    */
    public static User createOneUser(String sProfileName,  String sRoleNameDeveloperName, String sBrand, String sCountry, String sLdapId){

        profile profile = [SELECT id FROM profile WHERE Name =:sProfileName limit 1];
        UserRole uRole    = [SELECT PortalType, PortalAccountId FROM UserRole WHERE DeveloperName=: sRoleNameDeveloperName limit 1];
        List<User> lstUser      =   new List<User>();
        String sOrgId           = UserInfo.getOrganizationId();
        String sDateString      = '';
        Integer iRandomInt      = 0;
        String sUniqueName      = '';

        sDateString         = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        iRandomInt          = Integer.valueOf(math.rint(math.random()*1000000));
        sUniqueName         = sOrgId + sDateString + iRandomInt;

        User user           = new User(
            alias               = sUniqueName.substring(18, 23),
            email               = sUniqueName + '@example' + sOrgId + '.org',
            emailencodingkey    = 'UTF-8',
            lastname            = 'Testing',
            languagelocalekey   = 'en_US',
            localesidkey        = 'en_US',
            profileid           = profile.Id,
            country             = 'United States',
            IsActive            = true,
            UserRoleId          = uRole.id,
            Country__c          = sCountry,
            Brand__c            = sBrand,
            ldapid__c           = sLdapId,
            timezonesidkey      = 'America/Los_Angeles',
            username            = sUniqueName + '@example' + sOrgId + '.org');

        return user;
    }


    public static List<User> createUser(List<Contact> lstContact,String sProfileName, String sRole, String sRoleName){

        List<profile> profileId = new List<profile>([SELECT id FROM profile WHERE Name =: sProfileName]);
        //List<UserRole> uRole    = new List<UserRole>([SELECT PortalType, PortalAccountId FROM UserRole WHERE PortalType =: sRole AND DeveloperName=: sRoleName limit 1]);
        List<User> lstUser      = new List<User>();
        String sOrgId           = UserInfo.getOrganizationId();
        String sDateString      = '';
        Integer iRandomInt      = 0;
        String sUniqueName      = '';

        for (Contact c : lstContact){
            sDateString         = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            iRandomInt          = Integer.valueOf(math.rint(math.random()*1000000));
            sUniqueName         = sOrgId + sDateString + iRandomInt;

            User user           = new User(
                alias               = sUniqueName.substring(18, 23),
                email               = sUniqueName + '@example' + sOrgId + '.org',
                emailencodingkey    = 'UTF-8',
                lastname            = 'Testing',
                languagelocalekey   = 'en_US',
                localesidkey        = 'en_US',
                profileid           = profileId.get(0).Id,
                country             = 'United States',
                IsActive            = true,
                ContactId           = c.Id,
                PortalRole          = sRoleName,
                Country__c          = 'ES',
                Brand__c            = 'AP',
                RAorAgentRRDICode__c= 'D02445A',
                LDAPId__c           = 'E4624' + '' + iRandomInt,
                timezonesidkey      = 'America/Los_Angeles',
                username            = sUniqueName + '@example' + sOrgId + '.org');
            lstUser.add(user);
        }
        return lstUser;
    }


    /**
    * This method insert a system Admin which will use in @testSetup method in test class, and so create data set in test class
    * @return User inserted Admin with role, brand and country and also a fake ldap id(9876543)
    */
    public static User createUserCreatorDataSet(){
        User CreatorDataSetUser = createOneUser('System Administrator', 'PSA', 'AP', 'PL', '9876543');

        insert CreatorDataSetUser;

        return CreatorDataSetUser;
    }



    /**
    * This method fetch the user created in the method createUserCreatorDataSet
    * @return User  Admin with role, brand and country and also a fake ldap id(9876543)
    */
    public static User getTestorUser(){
        return [
            SELECT Id, alias, email, emailencodingkey, lastname, languagelocalekey, localesidkey, profileid, country, IsActive, UserRoleId, Country__c, Brand__c, ldapid__c, timezonesidkey, username
            FROM User
            WHERE ldapid__c = '9876543' LIMIT 1
        ];
    }

    /***********************************************************************************************************************************************************************
    *                                                                           ASSET FACTORY                                                                              *
    ***********************************************************************************************************************************************************************/

    /**
     * This method is used to return a list of asset records
     * @param numAssets - Number of Assets to be created
     */
    public static List<Asset> createAsset(Integer numAssets, List<Account> lstAccounts) {
        List<Asset> lstAssets = new List<Asset>();
        for(Integer i=0;i<numAssets;i++) {
            Asset asst = new Asset(Name='TestAsset' + i,AssetType__c='VN', Accountid = lstAccounts.get(i).Id , VIN__c ='VF36E4HTH20603732',LastKnownRegistrationNumber__c='JJK-1234' );
            lstAssets.add(asst);
        }
        if(!lstAssets.isEmpty()){
            insert lstAssets;
        }
        return lstAssets;
    }

    /*********************************************************************************************************
    * @Method          :   createAssetBulk
    * @Author          :   Nerea Leguinazabal
    * @Created         :   28/06/2019
    * @Description     :   Create Assets for bulk testing
    * @params	       :   Integer numberAssets, Account acc
    * @Returns         :   List<Asset>
    **********************************************************************************************************/

    public static List<Asset> createAssetBulk(Integer numAssets, Account acc) {
        List<Asset> lstAssets = new List<Asset>();
        String VIN = 'VF36E4HTH20160';
        for(Integer i=0;i<numAssets;i++) {
            if (i<10) {
                VIN='VF36E4HTH2016000'+i;
            }else if (i<100) {
                VIN='VF36E4HTH201600'+i;
            }else if (i<1000) {
                VIN='VF36E4HTH20160'+i;
            }
            Asset asst = new Asset(Name='TestAsset' + i,AssetType__c='VN', Accountid = acc.Id , VIN__c =VIN,LastKnownRegistrationNumber__c='JJK-'+ i );
            lstAssets.add(asst);
        }
        if(!lstAssets.isEmpty()){
           insert lstAssets;
        }
        return lstAssets;
    }

    /**
     * @description create one Asset
     * @param mapApiNameToFieldValue - map that associate api name with the value
     * @param doInsert - allow to insert or not the record
     * @example Asset asset = TestDataFactoryUtil.createAsset(new map<String, Object>{
            'Name'                => 'Test Vehicle',
            'AssetType__c'        => 'VN',
            'CurrencyIsoCode'     => 'EUR',
            'AccountId'           => account.Id
        }, true);
     */
     public static Asset createAsset(map<string,object> mapApiNameToFieldValue, boolean doInsert){
        Asset asset = (Asset)createSobject('Asset', mapApiNameToFieldValue);

        if(doInsert){
            insert asset;
        }

        return asset;
    }

    /***********************************************************************************************************************************************************************
    *                                                                           LEAD FACTORY                                                                               *
    ***********************************************************************************************************************************************************************/

     /**
    * This method is used to return a list of account records
    * @param numAccts - Number of Accounts to be created
    * @param sType - Type of account (B2B, B2C or Dealer);
    */
    public static List<Lead> createLead(Integer numLeads, String sType, String sAccount,String sDesPOSCode, String sBrand,String sCountry,String sActivity, String sKeyword) {

        List<Lead> lstLeads         = new List<Lead>();
        String rtID                 = PAD.getObjRecordType('Lead',!String.isEmpty(sType)?sType:'B2C');
        String sKeyUnique           = '';
        for(Integer i=0;i<numLeads;i++) {
            sKeyword    = sKeyword + i;
            sKeyUnique  = uniqueKey();
            Lead oLead  = new Lead(
                FirstName                   = 'First Name ' +  sType +  '_' + sKeyUnique,
                LastName                    =  uniqueKey(),
                Street                      = 'Calle de Sebastián Elcano ' + sKeyword.right(4),
                City                        = 'Madrid',
                Country                     = 'España',
                PostalCode                  = sKeyword.right(5),
                Latitude                    =  39.9691,
                Longitude                   = -4.8237,
                Phone                       = sKeyword.right(9),
                NationalId__c               = sKeyword.right(8) + 'A',
                DestinationGeographicalCode__c= sAccount,
                DestinationPOSCode__c       = sDesPOSCode,
                Company                     = (sType!='B2B')?' TEST COMPANY_'+ sKeyUnique:'',
                PSABrand__c                 = sBrand,
                Email                       = 'psaLead' + sKeyword.right(5) +  '@leadexample.com',
                LeadCountry__c              =  sCountry,
                Activity__c                 =  sActivity,
                CustomerType__c             = '1',
                LeadChannel__c              = '10',
                LeadRequestType__c          = '5',
                LeadSource                  = 'Partner',
                LeadType__c                 = '1',
                MarketingCode__c            = '01234567899876543210',
                RecordTypeId                = rtID);

            lstLeads.add(oLead);
        }
        return lstLeads;
    }

    /**
     * @description create one lead
     * @param mapApiNameToFieldValue - map that associate api name with the value
     * @param doInsert - allow to insert or not the record
     * @example Lead lead = TestDataFactoryUtil.createLead(new map<String, Object>{
            'lastName'  => 'lastname test',
            'firstName' => 'firstname test',
            'Email'     => 'test@leadexample.com',
            'RecordTypeId'  => PAD.recordTypesMapByDeveloperName.get(Constants.RT_LEAD_B2C)
        }, false);
     */
    public static Lead createLead(map<string,object> mapApiNameToFieldValue, boolean doInsert){
        Lead lead = (Lead)createSobject('Lead', mapApiNameToFieldValue);

        if(doInsert){
            insert lead;
        }

        return lead;
    }

    /**
     * @description create several leads
     * @param mapApiNameToFieldValue - map that associate api name with the value
     * @param doInsert - allow to insert or not the record
     * @param numberOfRecordToCreate - number of record to create
     */
    public static list<Lead> createLeadList(map<string,object> mapApiNameToFieldValue, boolean doInsert, Integer numberOfRecordToCreate){
        list<Lead> leads = new list<Lead>();


        for(integer i = 0; i < numberOfRecordToCreate; i++ ){
            Lead lead = new lead();

            for(String apiName: mapApiNameToFieldValue.keyset()){
                lead.put(apiName, apiName.toLowerCase() == 'lastname' ?  mapApiNameToFieldValue.get(apiName) + ' ' + i : mapApiNameToFieldValue.get(apiName));
            }

            leads.add(lead);
        }

        if(doInsert){
            insert leads;
        }

        return leads;
    }



    /***********************************************************************************************************************************************************************
    *                                                                       CAMPAIGN FACTORY                                                                               *
    ***********************************************************************************************************************************************************************/


    /**
     * @description create one  Campaign
     * @param mapApiNameToFieldValue - map that associate api name with the value
     * @param doInsert - allow to insert or not the record
     * @example Campaign Campaign = TestDataFactoryUtil.createCampaign(new map<String, Object>{
            'Name'          =>  'Template Campaign',
            'RecordTypeId'  =>  PAD.recordTypesMapByDeveloperName.get(Constants.RT_CAMPAIGN_DMCAMPAIGN)
        }, true);
     */
     public static Campaign createCampaign(map<string,object> mapApiNameToFieldValue, boolean doInsert){
        Campaign Campaign = (Campaign)createSobject('Campaign', mapApiNameToFieldValue);

        if(doInsert){
            insert Campaign;
        }

        return Campaign;
    }


    /***********************************************************************************************************************************************************************
    *                                                                           TASK FACTORY                                                                               *
    ***********************************************************************************************************************************************************************/


    /**
     * @description create one Task
     * @param mapApiNameToFieldValue - map that associate api name with the value
     * @param doInsert - allow to insert or not the record
     * @example
     */
     public static Task createTask(map<string,object> mapApiNameToFieldValue, boolean doInsert){
        Task task = (Task)createSobject('Task', mapApiNameToFieldValue);

        if(doInsert){
            insert Task;
        }

        return Task;
    }


    /***********************************************************************************************************************************************************************
    *                                                                           ORDER FACTORY                                                                               *
    ***********************************************************************************************************************************************************************/

    /**
    * This method is used to return a list of order records
    * @param numOrders  - Number of Orders to be created
    * @param sOrderType - Order Record Type (developer name)
    * @param sStatus    - Order Status
    * @param lstAccs    - List of accounts to relate the Orders. The number of accunts must be th same of the number of Orders to create.
    */
    public static List<Order> createOrder(Integer numOrders, String sOrderType, String sStatus, List<Account> lstAccs) {
        List<Order> lstOrders               = new List<Order>();
        String sKeyword                     = '200';
        for(Integer i=0;i<numOrders;i++) {
            sKeyword    = sKeyword + i;
            Order objOrder                  = new Order();
            objOrder.OrderId__c             = '814140' + i;
            objOrder.SupplyOrderId__c       = 'ORDER'+ sKeyword;
            objOrder.OrderCreationDate__c   = System.today().addDays( -10 );
            objOrder.FleetCode__c           = 'FLEET'+ sKeyword;
            objOrder.UseType__c             = '1';
            objOrder.AccountId              = (i>lstAccs.size())?lstAccs.get(0).Id:lstAccs.get(i).Id;
            objOrder.RecordTypeId           = PAD.getRecordTypeIdByDeveloperName('Order',sOrderType);
            objOrder.EffectiveDate          = System.today().addDays( 25 );
            objOrder.Status                 = sStatus;
            objOrder.CompletedSaleDate__c   = System.today().addMonths( -2 );
            lstOrders.add(objOrder);
        }
        if(!lstOrders.isEmpty()){
            Insert lstOrders;
        }
        return lstOrders;
    }

    /**
     * @description create one oOrder
     * @param mapApiNameToFieldValue - map that associate api name with the value
     * @param doInsert - allow to insert or not the record
     * @example Order oOrder = TestDataFactoryUtil.createOrder(new map<String, Object>{
            'OrderId__c'        => '8141401',
            'SupplyOrderId__c'  => 'ORDER200',
            'UseType__c'        => '1',
            'RecordTypeId'      => PAD.recordTypesMapByDeveloperName.get(Constants.RT_ORDER_VN)
        }, false);
     */
    public static Order createOrder(map<string,object> mapApiNameToFieldValue, boolean doInsert){
        Order oOrder = (Order)createSobject('Order', mapApiNameToFieldValue);

        if(doInsert){
            insert oOrder;
        }

        return oOrder;
    }

    /********************************************************************************************************
    *                                   GENERIC CREATION SOBJECT METHODS                                    *
    ********************************************************************************************************/

    /**
     * @description create one sObject
     * @param String - sObjectType - sObjectType to instanciate
     * @param map<String, Object> - mapApiNameToFieldValue - map that associate api name with the value
     * @param boolean - insert record
     * @return - sObject - return created object
     */
    public static sObject createSobject(String sObjectType, map<String, Object> mapApiNameToFieldValue, boolean doInsert){
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(sObjectType);

        if(targetType == null){
            throw new TestException('Wrong  SObjectType : ' + sObjectType);
        }

        sObject mySobject = targetType.newSObject();
        for(String apiName: mapApiNameToFieldValue.keyset()){
            mySobject.put(apiName, mapApiNameToFieldValue.get(apiName));
        }

        if(doInsert){
            insert mySobject;
        }

        return mySobject;
    }


    /**
     * @description create several sObject
     * @param String - sObjectType - sObjectType to instanciate
     * @param map<String, Object> - mapApiNameToFieldValue - map that associate api name with the value
     * @param numberOfSobjectToCreate - number of record to create
     * @param boolean - insert records
     * @return - list<sObject> - return created list of object
     */
    public static list<sObject> createSobjectList(String sObjectType, map<String, Object> mapApiNameToFieldValue, Integer numberOfSobjectToCreate, boolean doInsert){

        list<sObject> sObjects = new list<sObject>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(sObjectType);

        if(targetType == null){
            throw new TestException('Wrong  SObjectType : ' + sObjectType);
        }

        for(integer i = 0; i < numberOfSobjectToCreate; i++ ){
            sObject mySobject = targetType.newSObject();


            for(String apiName: mapApiNameToFieldValue.keyset()){
                //if api is in Constants.LIST_API_FIELD_TO_INCREMENT, concat with value with i loop ie: 'lastname' => 'test' will be lastname = test 0
                mySobject.put(apiName, Constants.LIST_API_FIELD_TO_INCREMENT.contains(apiName.toLowerCase()) ?  mapApiNameToFieldValue.get(apiName) + ' ' + i : mapApiNameToFieldValue.get(apiName));
            }

            sObjects.add(mySobject);
        }

        if(doInsert){
            insert sObjects;
        }

        return sObjects;
    }

    /********************************************************************************************************
    *                                           PRIVATE METHODS                                             *
    ********************************************************************************************************/

    /**
     * @description create one sObject
     * @param sObjectType - sObjectType to instanciate
     * @param mapApiNameToFieldValue - map that associate api name with the value
     */
    private static sObject createSobject(String sObjectType, map<String, Object> mapApiNameToFieldValue){
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(sObjectType);

        if(targetType == null){
            throw new TestException('Wrong  SObjectType : ' + sObjectType);
        }

        sObject mySobject = targetType.newSObject();
        for(String apiName: mapApiNameToFieldValue.keyset()){
            mySobject.put(apiName, mapApiNameToFieldValue.get(apiName));
        }


        return mySobject;
    }

    /**
     * @description create several sObject
     * @param sObjectType - sObjectType to instanciate
     * @param mapApiNameToFieldValue - map that associate api name with the value
     * @param numberOfSobjectToCreate - number of record to create
     */
    private static list<sObject> createSobjectList(String sObjectType, map<String, Object> mapApiNameToFieldValue, Integer numberOfSobjectToCreate){

        list<sObject> sObjects = new list<sObject>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(sObjectType);

        if(targetType == null){
            throw new TestException('Wrong  SObjectType : ' + sObjectType);
        }

        for(integer i = 0; i < numberOfSobjectToCreate; i++ ){
            sObject mySobject = targetType.newSObject();


            for(String apiName: mapApiNameToFieldValue.keyset()){
                //if api is in Constants.LIST_API_FIELD_TO_INCREMENT, concat with value with i loop ie: 'lastname' => 'test' will be lastname = test 0
                mySobject.put(apiName, Constants.LIST_API_FIELD_TO_INCREMENT.contains(apiName.toLowerCase()) ?  mapApiNameToFieldValue.get(apiName) + ' ' + i : mapApiNameToFieldValue.get(apiName));
            }

            sObjects.add(mySobject);
        }

        return sObjects;
    }

    private static String uniqueKey(){

        String dateString   = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt   = Integer.valueOf(math.rint(math.random()*1000000));
        return  dateString + randomInt;

    }

    private class TestException extends Exception{}
}
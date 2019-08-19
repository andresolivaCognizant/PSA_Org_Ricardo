/**
 * Salesforce
 * @author              Diego Rincón (DR) href=<diego.rincon@ext.mpsa.com>
 * Project:             PSA - Customer First
 * Description:         Unit tests to validate the behavior of AccountUtils class.
 *
 * Changes (version)
 * -------------------------------------------------------------------------------------------------
 *              No.     Date            Author                  Description
 *              ----    ------------    --------------------    ------------------------------------
 * @version     1.0     2018-11-29      Diego Rincón (DR)       Class creation. Code coverage: 100%.
 *              1.1     2019-06-04      Ruben Fernandez (RF)    AccountUtilsAllMethodsTest added.
 *              1.2     18/06/2019      Pedro Párraga           Edit. 
 *
 */

@isTest
private class AccountUtilsTest {
    
    private static final String BILLING1_CHIEF			= '2000';
    private static final String BILLING2_ALGER			= '16000';
    private static final String MAILING1_ADRAR			= '1000';
    private static final String MAILING2_ORAN			= '31000';
    private static final String SHIPPING1_BATNA			= '5000';
    private static final String SHIPPING2_MILA			= '43000';
    

    @testSetup static void setup() {
        
        Account account_B2C_PA_true = TestDataFactoryUtil.createAccount(new map<String, Object>{
            'FirstName'                                 => 'Account 1 FirstName',
            'LastName'                                  => 'Account 1 LastName',
            'Salutation'                                => '1',
            'PersonalEmail__pc'                         => 'b2c1@test.com',
            'TECH_MailingAddresstoBillingAddress__pc'   =>  true,
            'ShippingWilaya__c'                         => SHIPPING1_BATNA,
            'BillingWilaya__c'                          => BILLING1_CHIEF,
            'MailingWilaya__pc'                         => MAILING1_ADRAR,
            'RecordTypeId'                              => PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA)
        },true);
        Account account_B2C_PA_false = TestDataFactoryUtil.createAccount(new map<String, Object>{
            'FirstName'                                 => 'Account 2 FirstName',
            'LastName'                                  => 'Account 3 LastName',
            'Salutation'                                => '1',
            'PersonalEmail__pc'                         => 'b2c2@test.com',
            'TECH_MailingAddresstoBillingAddress__pc'   =>  false,
            'RecordTypeId'                              => PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA)
        },true);
        Account account_B2B_true = TestDataFactoryUtil.createAccount(new map<String, Object>{
           'Name'                                       =>   'TEST 1 MATCH',
           'BillingPostalCode'                          =>   '12234',
           'TECH_BillingAddresstoShippingAddress__c'    => true,
           'RecordTypeId'                               =>   PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2B)
        },true);     
        Account account_B2B_false = TestDataFactoryUtil.createAccount(new map<String, Object>{
           'Name'                                       =>   'TEST 2 MATCH',
           'BillingPostalCode'                          =>   '98764',
           'TECH_BillingAddresstoShippingAddress__c'    => false,
           'RecordTypeId'                               =>   PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2B)
        },true);
            
    }

    @isTest static void fillShippingAddress_test1(){
        List<Account> accounts = new List<Account>([
            SELECT
                Id,
                Name,
                CurrencyIsoCode,
                RecordTypeId,
                ShippingAddress,
                ShippingCity,
                ShippingCountry,
                ShippingLatitude,
                ShippingLongitude,
                ShippingPostalCode,
                ShippingState,
                ShippingStreet,
                BillingAddress,
                BillingCity,
                BillingCountry,
                BillingLatitude,
                BillingLongitude,
                BillingPostalCode,
                BillingState,
                BillingStreet,
                PersonMailingAddress,
                PersonMailingCity,
                PersonMailingCountry,
                PersonMailingLatitude,
                PersonMailingLongitude,
                PersonMailingPostalCode,
                PersonMailingState,
                PersonMailingStreet,
                TECH_MailingAddresstoBillingAddress__pc,
                TECH_BillingAddresstoShippingAddress__c,
                TECH_IsChatCaseAssignmentAccount__c,
                OwnerId
            FROM Account
        ]);
        Test.startTest();
            for(account a : accounts){
                AccountUtils.fillShippingAddress(a);
            }
        Test.stopTest();
    }
    
    @isTest static void AccountUtilsAllMethodsTest(){
        List<Account> accounts = new List<Account>([
            SELECT
                Id,
                Name,
                CurrencyIsoCode,
                RecordTypeId,
                ShippingAddress,
                ShippingCity,
                ShippingCountry,
                ShippingLatitude,
                ShippingLongitude,
                ShippingPostalCode,
                ShippingState,
                ShippingStreet,
                BillingAddress,
                BillingCity,
                BillingCountry,
                BillingLatitude,
                BillingLongitude,
                BillingPostalCode,
                BillingState,
                BillingStreet,
                PersonMailingAddress,
                PersonMailingCity,
                PersonMailingCountry,
                PersonMailingLatitude,
                PersonMailingLongitude,
                PersonMailingPostalCode,
                PersonMailingState,
                PersonMailingStreet,
                TECH_MailingAddresstoBillingAddress__pc,
                TECH_BillingAddresstoShippingAddress__c,
                TECH_IsChatCaseAssignmentAccount__c,
                OwnerId
            FROM Account
        ]);
        
        Lead l = new Lead(
                FirstName                   = 'First Name 044',
                Salutation                  =  '1',
                LastName                    = 'LastName 044',
                Street                      = 'Calle Test 472',
                City                        = 'Madrid',
                Country                     = 'España', 
                PostalCode                  = '28012',
                Latitude                    =  39.9691,
                Longitude                   = -4.8237,
                Phone                       = '915001000',
                DestinationPOSCode__c       = '1237771',
                Company                     = 'DEALER TEST COMPANY_0031',
                PSABrand__c                 = 'AP',
                Email                       = 'test4@leadexample.com',
                LeadCountry__c              = 'PL',
                LeadRequestType__c          = '5',
                IdReservationVD__c          = '12345323X',
                status                      = 'Qualified',
                OwnerId                     = UserInfo.getUserId(),
                RecordTypeId                = PAD.getObjRecordType('Lead','B2C'));
        
        insert l;
        Set<Id> accountsIds = new Set<Id>();
        Test.startTest();
            for(Account a : accounts){
                accountsIds.add(a.Id);
            }
            accounts.get(0).TECH_IsChatCaseAssignmentAccount__c = true;
            AccountUtils.IsChatCaseAssignmentAccount(accounts);
            AccountUtils.createOpportunity(accounts);
            AccountUtils.obfuscateAccountFields(accounts.get(0));
            AccountUtils.WrapperMappingAccount wma = new AccountUtils.WrapperMappingAccount(l.phone,l.Email,l.Address2__c,l.Birthdate__c,l.FirstName,
                              l.LastName,l.LandlinePersonalTelephone__c,l.LandlineProfessionalTelephone__c,l.PSABrand__c,l.MobilePersonalTelephone__c,l.MobileProfessionalTelephone__c,
                              l.Salutation,l.NationalId__c,l.tITLE,l.Language__c,l.State,l.Street,l.Country,l.PostalCode,l.City,l.LeadSource);
            accounts.get(0).TECH_Idlead__c = l.Id;
            AccountUtils.populateAccountFromLead(accounts.get(0), new Map<Id,AccountUtils.WrapperMappingAccount>{
            l.id => wma});
            Lead l2 = AccountUtils.anonymizedLead(l.id);
        Test.stopTest();
        
        System.assertEquals(true, ![SELECT Id FROM Opportunity WHERE AccountId In : accountsIds].isEmpty());
        System.assertEquals(4, [SELECT Id FROM Opportunity WHERE AccountId In : accountsIds].size());

    }
    
    /*********************************************************************************************************
    * @Method          :   addressUpdateFromWilayaFieldTest
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/02/2019
    * @Description     :   This method checks the functionality of the 'addressUpdateFromWilayaField' method, 
    *                      updates the address from the 'Wila' fields
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/     
    @isTest static void addressUpdateFromWilayaFieldTest(){
        
        Account personAccounTest = [SELECT Id, ShippingState, BillingState, PersonMailingState 
                                    FROM Account WHERE PersonalEmail__pc = 'b2c1@test.com' LIMIT 1];
        
        //Check Case 1: Insert Account, Verify that the address has been populated with the data of the 'XXWilaya__c' fields
        System.assertEquals(SHIPPING1_BATNA, personAccounTest.ShippingState);
        System.assertEquals(BILLING1_CHIEF, personAccounTest.BillingState);
        System.assertEquals(MAILING1_ADRAR, personAccounTest.PersonMailingState);
        
        //Update the Wilaya fields...
        personAccounTest.ShippingWilaya__c = SHIPPING2_MILA;
        personAccounTest.BillingWilaya__c = BILLING2_ALGER;
        personAccounTest.MailingWilaya__pc = MAILING2_ORAN;
        Test.startTest();
        update personAccounTest;
        Test.stopTest();
            
        //Get updated data
        personAccounTest = [SELECT Id, ShippingWilaya__c, ShippingState, BillingWilaya__c, BillingState, MailingWilaya__pc, PersonMailingState
                            FROM Account WHERE Id =: personAccounTest.Id];            
        
        //Check Case 2: Update Account, Verify that the address has been populated with the data of the 'XXWilaya__c' fields
        System.assertEquals(SHIPPING2_MILA, personAccounTest.ShippingState);
        System.assertEquals(BILLING2_ALGER, personAccounTest.BillingState);
        System.assertEquals(MAILING2_ORAN, personAccounTest.PersonMailingState);
    }
}
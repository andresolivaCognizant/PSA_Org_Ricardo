/*-----------------------------------------------------------------------------------------------------------//
  * Class Name    : CaseWebFormControllerTest
  * Project       : PSA - C1ST - Care
  * Author        : Borja Gay Flores    <gayflores.borja@ext.mpsa.com>
  * Date          : 10/29/2018
  * Description   : Test Class of CaseWebFormController
  *
  *-----------------------------------------------------------------------------------------------------------
  *      Modification Log :
  *-----------------------------------------------------------------------------------------------------------
  *      Developer                Date                     Description
  *      Borja Gay Flores         10/29/2018               Creation.
  * 	 Carmen & Martin		  07/05/2019			   Add testSetup, comments and methods: Coverage: 90%
  *-----------------------------------------------------------------------------------------------------------*/

@isTest
public class CaseWebFormControllerTest {

    /*********************************************************************************************************
    * @Method          :   setupCommonData
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/05/2019
    * @Description     :   This method is used to create test records once and then access them in every test
    *                  :   method in the test class
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/
    @testSetup static void setupCommonData(){

        //Create Person Account - not Matching
        Account personAccNotMatching = TestDataFactoryUtil.createAccount(new map<String, Object>{
            'FirstName'=>'Pablo', 'LastName'=>'Hernandez', 'Phone'=>'+34630120456', 'Brand__c'=>'AP',
                'Country__c'=>'PT', 'BillingPostalCode'=>'23456',
                'RecordTypeId'=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA)}, false);

        //Create Person Account - Matching
        Account personAccMatching = TestDataFactoryUtil.createAccount(new map<String, Object>{
            'FirstName'=>'Juan', 'LastName'=>'Perez', 'Phone'=>'+351640234781', 'Brand__c'=>'AP',
                'Country__c'=>'PT', 'BillingPostalCode'=>'23456', 'Email__c'=>'testMatching@email.es',
                'RecordTypeId'=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA)}, false);

        //Insert 2 test accounts
        List<Account> testAccounts = new List<Account>{personAccNotMatching, personAccMatching};
        insert testAccounts;

        //Create Asset - matching
        Asset asset1 = TestDataFactoryUtil.createAsset(new map<String, Object>{
            'Name'=>'Test Vehicle', 'AssetType__c'=>'VN', 'VIN__c'=>'VF36E4HTH20603732',
            'CurrencyIsoCode'=>'EUR', 'AccountId'=>personAccMatching.Id}, true);

    }

    /*********************************************************************************************************
    * @Method          :   checkCaseFromWebFormMatching
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/05/2019
    * @Description     :   This method is used to check the Account and Asset matching
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/
    @isTest static void checkCaseFromWebFormMatching(){
        //Get Account Juan Perez
        Account existingAccJuan = [SELECT Id
                                    FROM Account
                                    WHERE Name = 'Juan Perez'
                                    LIMIT 1];

        Asset existingAsset = [SELECT Id
                                FROM Asset
                                WHERE VIN__c = 'VF36E4HTH20603732'
                                LIMIT 1];

        //Create new case from WebForm
        Test.startTest();
        CaseWebFormController.createCase(CareConstants.CASE_REASON_INFORMATION_REQUEST, '123', 'Subject: Case B2C Matching',
                                         'Summary Test', false, '', 'Juan', 'Perez', 'testMatching@email.es', '+351640234781',
                                         '1412', 'Lisboa', 'VF36E4HTH20603732', 'String regNumber', 'PT', 'PT', 'AP',
                                         CareConstants.CASE_STATUS_OPEN, '', '', 'cRole', 'Yes');
        Test.stopTest();

        //Get updated data
        Case newCaseWebForm = [SELECT AccountId,
                                      AssetId
                                FROM Case
                                WHERE Subject = 'Subject: Case B2C Matching'
                                LIMIT 1];

        //Check matching Asset
        System.assertEquals(existingAsset.Id, newCaseWebForm.AssetId, 'We should have only the same Asset as the beginning');
    }

    /*********************************************************************************************************
    * @Method          :   checkCaseFromWebFormCreatePersonAccount
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/05/2019
    * @Description     :   This method is used to verify that the Person Account is created correctly when
    *                  :   there is no matching
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/
    @isTest static void checkCaseFromWebFormCreatePersonAccount(){

        //Check that before inserting the case there are no accounts and consents with this data ..
        List<Consent__c> consentList = [SELECT Id
                                        FROM Consent__c];

        List<Account> accountList = [SELECT Id
                                     FROM Account
                                     WHERE Name = 'Manuel Martin'];

        System.assert(consentList.isEmpty(),'There should be no Consents');
        System.assert(accountList.isEmpty(),'There should be no Accounts');

        //Insert case
        Test.startTest();
        CaseWebFormController.createCase(CareConstants.CASE_REASON_INFORMATION_REQUEST, '123',
                                        'Subject: Case Create Person Account', 'Summary Test', false, '', 'Manuel', 'Martin',
                                        'testCreatePersonAccount@email.es', '+351640234781','1412', 'Lisboa', 'VF36E4HTH20603732',
                                        'String regNumber', 'PT', 'PT', 'AC',CareConstants.CASE_STATUS_OPEN, '', '', 'cRole', 'Yes');
        Test.stopTest();

        //Get updated data
        Case newCaseWebForm = [SELECT AccountId,
                                      AssetId
                                FROM Case
                                WHERE Subject = 'Subject: Case Create Person Account'
                                LIMIT 1];

        //Check that after inserting the case an account and a consent have been created
        consentList = [SELECT Id
                        FROM Consent__c];

        accountList = [SELECT Id
                        FROM Account
                        WHERE Name = 'Manuel Martin'];

        System.assertEquals(1, consentList.size(), 'There should be just one Consent');
        System.assertEquals(1, accountList.size(), 'There should be just one Account');
    }

    /*********************************************************************************************************
    * @Method          :   checkCaseFromWebFormNewAccountB2B
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/05/2019
    * @Description     :   This method is used to verify that the B2B Account is created correctly when
    *                  :   there is no matching
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/
    @isTest static void checkCaseFromWebFormNewAccountB2B(){

        //Check that before inserting the case there are no accounts and contacts with this data ..
        List<Contact> contactList = [SELECT Id
                                     FROM Contact
                                     WHERE Name = 'Beatriz Salamanca'];

        List<Account> accountList = [SELECT Id
                                     FROM Account
                                     WHERE Name = 'Super Company'];

        System.assert(contactList.isEmpty(),'There should be no Contacts');
        System.assert(accountList.isEmpty(), 'There should be no Accounts');

        //Insert case
        Test.startTest();
        CaseWebFormController.createCase(CareConstants.CASE_REASON_INFORMATION_REQUEST, '123',
                                        'Subject: Case Create Person Account', 'Summary Test', true, 'Super Company', 'Beatriz', 'Salamanca',
                                        'testCreateB2BAccount@email.es', '+56640234781','1412', 'Lisboa', 'VF36E4HTH20603732',
                                        'String regNumber', 'CL', 'ES', 'DS','String status,', '', '', 'cRole', 'No');
        Test.stopTest();

        //Check that after inserting the case an account and a contact have been created
        contactList = [SELECT Id
                        FROM Contact
                        WHERE Name = 'Beatriz Salamanca'];

        accountList = [SELECT Id
                        FROM Account
                        WHERE Name = 'Super Company'];
        System.assertEquals(1, contactList.size(), 'There should be just one Contact');
        System.assertEquals(1, accountList.size(), 'There should be just one Account');
    }


    /*********************************************************************************************************
    * @Method          :   matchB2CAccountsTest
    * @Author          :   Martin de Leon
    * @Created         :   07/05/2019
    * @Description     :   This method is used to check the functionality of the case-account matching on B2C Accounts
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/
	@isTest
    private static void matchB2CAccountsTest() {

        String sKeyword             = '000000000';
        String rt                   = PAD.getObjRecordType('Account','B2C_PA');

        // We should start with the Accounts from the setup.
        List<Account> accounts = [SELECT Id FROM Account];

        System.assertEquals(2, accounts.size(), 'We should start with 2 Accounts');

        // We should have no Cases.
        List<Case> cases = [SELECT Id FROM Case];

        System.assert(cases.isEmpty(), 'We should start with no Cases');

        Test.startTest();

        // Users created by this method have a role
        User anonymousUser = TestDataFactoryUtil.createOneUser('peugeot Profile', 'PSA', 'AP', 'PT', '9876543');

        // Anonymous users cannot have a role
        anonymousUser.UserRoleId = null;

        // Test the matching rules for anonymous users
        System.runAs(anonymousUser) {
            // Insert an Account for the current user
            Account existingAccount = new Account(
                OwnerId             =   UserInfo.getUserId(),
                FirstName           =   'Juan',
                LastName            =   'Perez',
                Salutation          =   '1',
                Country__c          =   PAD.sUserCountry,
                PersonalEmail__pc   =   'test@example.com',
                BillingStreet       =   'Eduardo Barreiro Nº' + sKeyword.right(4),
                BillingCity         =   'Madrid',
                BillingCountry      =   'España',
                BillingPostalCode   =   sKeyword.right(5),
                RecordTypeId        =   rt);

        insert existingAccount;

        // We should have the Account we have just inserted.
        accounts = [SELECT Id FROM Account];

        System.assertEquals(1, accounts.size(), 'We should start with 1 Accounts');

        // Test the create Case scenario
        String caseId = CaseWebFormController.createCase('1',
                                                         '123',
                                                         'Test',
                                                         'test',
                                                         false,
                                                          '',
                                                         'Juan',
                                                         'Perez',
                                                         'test@example.com',
                                                         '+351640234781',
                                                         '',
                                                         '',
                                                         'AAAAAAAAAAAAAAAAA',
                                                         '',
                                                         'PT',
                                                         'PT',
                                                         'AP',
                                                         '1',
                                                         '1111111-1',
                                                         '',                                                             '',
                                                         '');

            // We should end with a new Case that we have created and the same Account as before
            // as it should have matched with the case criteria instead of creating a new one.

            System.assert(caseId != null, 'We should have one case created with Id');

        	String caseNumber = CaseWebFormController.getCaseNumber(caseId);

            System.assert(caseNumber != null, 'We should have one case created with Id');

        }

        Test.stopTest();

        accounts = [SELECT Id
                    FROM Account];

        System.assertEquals(3,accounts.size(),'We should have 3 Accounts now');

        cases = [SELECT Id
                 FROM Case];

        System.assertEquals(1,cases.size(), 'We should have 1 Case now');

    }

    /*********************************************************************************************************
    * @Method          :   getselectOptionsTest
    * @Author          :   Borja Gay Flores    <gayflores.borja@ext.mpsa.com>
    * @Created         :   10/29/2018
    * @Description     :   This method is used to check the functionality of the method getselectOptions()
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/
    @isTest
    public static void getselectOptionsTest(){
        Test.startTest();
        String mapType = CaseWebFormController.getselectOptions('Type');
        System.assert(!String.isBlank(mapType),'The returned string is empty!');
        Test.stopTest();
    }

    /*********************************************************************************************************
    * @Method          :   getKnowledgeArticlesTest
    * @Author          :   Borja Gay Flores    <gayflores.borja@ext.mpsa.com>
    * @Created         :   10/29/2018
    * @Description     :   This method is used to check the functionality of the method getKnowledgeArticles()
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/
    @isTest
    public static void getKnowledgeArticlesTest() {

        Knowledge__kav knowledgeKav = new Knowledge__kav(Title = '123', UrlName = 'URl-Test', Country__c = 'CL', Brand__c = 'AP', Language = 'pt_PT' );

        insert knowledgeKav;

        Test.startTest();

        List<Knowledge__kav> mapKnow = CaseWebFormController.getKnowledgeArticles('123','CL','AP','ES','pt_PT','Peugeot');

        Test.stopTest();

        //    System.assertEquals(1,mapKnow.size(), 'There should be articles with the requested data.');
    }


    /*********************************************************************************************************
    * @Method          :   getKnowledgeArticlesTest
    * @Author          :   Borja Gay Flores    <gayflores.borja@ext.mpsa.com>
    * @Created         :   10/29/2018
    * @Description     :   This method is used to check the functionality of the method getKnowledgeArticles()
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/
    @isTest
    public static void getKnowledgeArticlesWithNoSubjectTest() {

        Knowledge__kav knowledgeKav = new Knowledge__kav(Title = '123', UrlName = 'URl-Test', Country__c = 'CL', Brand__c = 'AP', Language = 'pt_PT' );

        insert knowledgeKav;

        Test.startTest();

        List<Knowledge__kav> mapKnow = CaseWebFormController.getKnowledgeArticles('123','CL','AP','ES','pt_PT', '');

        Test.stopTest();

        System.assertEquals(null,mapKnow, 'Result should be null.');
    }


    /*********************************************************************************************************
    * @Method          :   getUserCountryAndLangTest
    * @Author          :   Borja Gay Flores    <gayflores.borja@ext.mpsa.com>
    * @Created         :   10/29/2018
    * @Description     :   This method is used to check the functionality of the method getUserCountryAndLang()
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/
    @isTest
    public static void getUserCountryAndLangTest(){
        Test.startTest();

        // Users created by this method have a role
        User anonymousUser = TestDataFactoryUtil.createOneUser('peugeot Profile', 'PSA', 'AP', 'PT', '9876543');

        // Anonymous users cannot have a role
        anonymousUser.UserRoleId = null;

        // Test the matching rules for anonymous users
        System.runAs(anonymousUser) {
            String userCountryAndLanguage = CaseWebFormController.getUserCountryAndLang();

            System.assertEquals('guest',userCountryAndLanguage, 'Returned String is not the specified.');
        }


        User testUser = TestDataFactoryUtil.createOneUser('System Administrator', 'PSA', 'AP', 'PT', '9876544');

        // Test the matching rules for non anonymous users
        System.runAs(testUser) {
            String userCountryAndLanguage = CaseWebFormController.getUserCountryAndLang();

            System.assertEquals('PT;EN',userCountryAndLanguage, 'Returned String is not the specified.');
        }

    	Test.stopTest();
    }

    /*********************************************************************************************************
    * @Method          :   saveChunkTest
    * @Author          :   Borja Gay Flores    <gayflores.borja@ext.mpsa.com>
    * @Created         :   10/29/2018
    * @Description     :   This method is used to check the functionality of the method saveChunk()
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/
    @isTest
    public static void saveChunkTest(){

        List<Attachment> attachments = [SELECT Id FROM Attachment];

        System.assert(attachments.isEmpty(),'There should be no Attachments.');

        Id caseId = CaseWebFormController.createCase('1','123','TestChunk', 'testChunk',false, '', 'Test Name','Test Last','test@test.com', '+351666666666','','','AAAAAAAAAAAAAAAAA','','PT', 'PT','AP','1','1111111-1', '','','');

        Test.startTest();

        CaseWebFormController.saveTheFile(caseId, 'Test', 'VGVzdA==', 'txt');

        Test.stopTest();

        attachments = [SELECT Id
                        FROM Attachment
                        WHERE ParentId = : caseId];

        System.assertEquals(1,attachments.size(),'There should be just one Attachment.');
    }


    /*********************************************************************************************************
    * @Method          :   validateVINTest
    * @Author          :   Martin De Leon    <martin.deleon@ext.mpsa.com>
    * @Created         :   07/12/2019
    * @Description     :   This method is used to check the functionality of the method validateVIN()
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/
    @isTest
    public static void validateVINTest(){

        Test.setMock( HttpCalloutMock.class, new RestInt91Mock( 200 ) );

        Test.startTest();

        Integer result = CaseWebFormController.validateVIN('553', 'CL','ES','AP');

        Test.stopTest();

        System.assertEquals(200,result,'CaseWebFormControllerTest - validateVINTest()');

    }


}
/*
-- - Name         : CSResultAControllerTest
-- - Author       : DXC. Ruben Fernandez
-- - Date         : 22/01/2018
-- - Description  : Test class for CSResultAController
--                  1. AccountSearchTest.
--                  2. SecretQuestionTest
--                  3. RamdonNumberTest
--                  4. BulkAccountSearchTest
-- - History:
-- Date         Author  Version  Comments
-- -----------  -----   -------  ---------------------------------------
-- 22/01/2018   DXC     1.0      Initial version Ruben Fernandez
-- 18/06/2019   PP    1.1        Edit version Pedro Párraga
*/
@isTest
public class CSResultAControllerTest {



    @isTest 
    static void AccountSearchTest() {
        // Test data setup
        // Create one account by calling a utility method
        List<Account> lstAccts = TestDataFactoryUtil.createAccount(1,'B2B');
        
        // Perform test
        Test.startTest();
            List<String> aux            =   new List<String>();
            String sObj                 =   'Account';
            CSResultWrapper rwRecords   =   new CSResultWrapper();
            rwRecords                   =   CSResultAController.getRecords(sObj,'Name',5,'10','LastViewedDate','isPersonAccount=False',aux);
            List<String> lstLabels      =   CSResultAController.getLabels(sObj,null,new String[]{'id','name','Owner.Name','UserRecordAccess.HasReadAccess'});
        Test.stopTest();

    } 
    @isTest 
    static void SecretQuestionTest() {
      
         List<Account> lstAccts         =   TestDataFactoryUtil.createAccountContact(1,'B2B');
        
        // Perform test
        Test.startTest();
            List<Contact> lstContact    =   new List<Contact>([SELECT Id From Contact Where AccountId =:lstAccts.get(0).Id]);
            String  sQuestion           =   CSResultAController.getSecretQuestion(lstContact.get(0).Id, 'SecretQuestionFieldsB2B','Contact');
            Boolean bResponse           =   CSResultAController.getQuestionResponse('Y3Zuk+0K/+J1s6rJeH9bAe3o4WDx4Ki0CIUWaG2NyP4=','response',null,null);

        Test.stopTest();

    }
    @isTest 
    static void RandomNumberTest() {
      
        // Perform test
        Test.startTest();
        
            Integer iRamdon             =   CSResultAController.randomWithLimit(5);
                
        Test.stopTest();

    }

    @isTest 
    static void FechRecordsTest() {
      
        // Preparing the test conditions.
        List<String> lstActivities  =   new List<String>(); 
        lstActivities.add('VN');
        List<Contact> lstConts      =   TestDataFactoryUtil.createPartnerUser(1, 1, 'Dealer', '133225511','1237770', 'EXTKEY0002','AP','CL', 'J',lstActivities,true);
        List<Account> lstAccts      =   new List<Account>([Select Id,Name From Account Where Id =:lstConts.get(0).AccountId]);
        List<Account> lstB2BAcc     =   TestDataFactoryUtil.createAccount(1,'B2B');
        List<User> lstUsers         =   TestDataFactoryUtil.createUser(lstConts,'Salesman','Partner','Manager');
        List<Lead> lstLeads         =   TestDataFactoryUtil.createLead(1, 'B2B', 'EXTKEY0002',null, 'AP','CL','VN', '22334455');

        System.debug('Results-->Lead:  OwnerId: ' + lstLeads.get(0).OwnerId + ' CalculatedPOS__c: ' + lstLeads.get(0).CalculatedPOS__c + ' Customer__c: ' + lstLeads.get(0).Customer__c );
        
        lstLeads.get(0).Customer__c = lstB2BAcc.get(0).Id;
        lstLeads.get(0).NationalId__c = '30686957-4';
        lstLeads.get(0).FiscalId__c  = '30686957-4';
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            Insert lstUsers;
        }

        // Perform test
        Test.startTest();
            Insert lstLeads;

            Boolean bResult = CSResultAController.manualShareRecord(lstAccts.get(0).Id, lstUsers.get(0).Id, 'Read');
            CSResultAController.getfetchRecords('Lead','Id,Name','');

        Test.stopTest();
    }



    /*BULK*/
    @isTest
    static void BulkAccountSearchTest() {
        // Test data setup
        // Create one account by calling a utility method
        List<Account> lstAccts = TestDataFactoryUtil.createAccount(200,'B2B');
        List<String> aux = new List<String>();
        // Perform test
        Test.startTest();
            String sObj                 =   'Account';
            CSResultWrapper rwRecords   =   new CSResultWrapper();
            rwRecords                   =   CSResultAController.getRecords(sObj,'Name',5,'10','LastViewedDate','',aux);
            List<String> lstLabels      =   CSResultAController.getLabels(sObj,null,new String[]{'id','name'});   
        Test.stopTest();

    } 

}
/*-----------------------------------------------------------------------------------------------------------//
  * Class Name    : CaseTriggerHandlerTest
  * Project       : PSA - C1ST
  * Author        : Borja Gay Flores    <gayflores.borja@ext.mpsa.com>
  * Date          : XX/XX/2018
  * Description   : Test Class of CaseTriggerHandler
  *
  *-----------------------------------------------------------------------------------------------------------
  *      Modification Log :
  *-----------------------------------------------------------------------------------------------------------
  *      Developer                Date                     Description    
  *      Borja Gay Flores         XX/XX/2019               Creation.      
  * 	 Carmen Hernandez		  06/11/2019			   Refactor: Add testSetup & new methods - 89%
  * 	 Carmen Hernandez		  07/05/2019			   Add new methods - 91%
  *      Carmen Hernandez         07/15/2019               Add new method: checkCasesFromPartnerCommunity - 95%
  *-----------------------------------------------------------------------------------------------------------*/
@isTest
private class CaseTriggerHandlerTest {
    
    private static final String KEY_PERSON_ACCOUNT_PEUGEOT = 'personAccPeugeot@emai.es';
    private static final String KEY_PERSON_ACCOUNT_CITROEN = 'personAccCitroen@emai.es';
    private static final String KEY_ANONYMOUS_ACCOUNT_PORTUGAL = 'anonymousPortugal@email.es';
    private static final String KEY_ANONYMOUS_ACCOUNT_CHILE = 'anonymousChile@email.es';
    private static final String KEY_ASSET_1 = 'VF36E4HTH20603732';
    private static final String KEY_ASSET_2 = 'VF36E4HTH20603000';
    
    /*********************************************************************************************************
    * @Method          :   setupCommonData
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   06/11/2019
    * @Description     :   This method is used to create test records once and then access them in every test 
    *                  :   method in the test class
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/    
    @testSetup static void setupCommonData(){
        
        //Create Person Account - Peugeot Portugal
        Account personAccPeugeot = TestDataFactoryUtil.createAccount(new map<String, Object>{
            'FirstName'=>'Pablo', 'LastName'=>'Hernandez', 'Phone'=>'+34630120456', 'Brand__c'=>'AP',
            'Country__c'=>'PT', 'BillingPostalCode'=>'23456', 'Email__c'=> KEY_PERSON_ACCOUNT_PEUGEOT,
            'RecordTypeId'=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA)}, false);
        
        //Create Person Account - Citroen Portugal
        Account personAccCitroen = TestDataFactoryUtil.createAccount(new map<String, Object>{
            'FirstName'=>'Juan', 'LastName'=>'Perez', 'Phone'=>'+351640234781', 'Brand__c'=>'AC',
            'Country__c'=>'PT', 'BillingPostalCode'=>'23456', 'Email__c'=> KEY_PERSON_ACCOUNT_CITROEN,
            'RecordTypeId'=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA)}, false);
        
        //Create anonymous Account - Portugal
        Account anonymousAccountPortugal = TestDataFactoryUtil.createAccount(new map<String, Object>{
            'FirstName'=>'Portugal', 'LastName'=>'Anonymous', 'Phone'=>'+34630120456', 'Email__c'=> KEY_ANONYMOUS_ACCOUNT_PORTUGAL,
            'TECH_IntegrationExtId__c'=> CareConstants.ANONYMOUS + 'PT', 'Country__c'=> 'PT',
            'RecordTypeId'=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA)}, false);
        
		//Create anonymous Account - Chile
        Account anonymousAccountChile = TestDataFactoryUtil.createAccount(new map<String, Object>{
            'FirstName'=>'Chile', 'LastName'=>'Anonymous', 'Phone'=>'+34630120456', 'Email__c'=> KEY_ANONYMOUS_ACCOUNT_CHILE,
            'TECH_IntegrationExtId__c'=> CareConstants.ANONYMOUS + 'CL', 'Country__c'=> 'CL',               
            'RecordTypeId'=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA)}, false);
        
        //Insert 4 test accounts
        List<Account> lstTestAccounts = new List<Account>{personAccPeugeot, personAccCitroen, anonymousAccountPortugal, anonymousAccountChile}; 
        insert lstTestAccounts;
        
        //Create Assets
        Asset asset1 = TestDataFactoryUtil.createAsset(new map<String, Object>{
            'Name'=> KEY_ASSET_1, 'AssetType__c'=>'VN', 'VIN__c'=> KEY_ASSET_1, 'LastKnownRegistrationNumber__c' => 'RN '+KEY_ASSET_1,
            'CurrencyIsoCode'=>'EUR', 'AccountId'=> personAccPeugeot.Id}, false);  
        
        Asset asset2 = TestDataFactoryUtil.createAsset(new map<String, Object>{
            'Name'=> KEY_ASSET_2, 'AssetType__c'=>'VN', 'VIN__c'=> KEY_ASSET_2, 'LastKnownRegistrationNumber__c' => 'RN '+KEY_ASSET_2,
            'CurrencyIsoCode'=>'EUR', 'AccountId'=> personAccPeugeot.Id}, false);          
        
        //Insert 2 test assets
        List<Asset> lstTestAssets = new List<Asset>{asset1, asset2}; 
        insert lstTestAssets;       
        
        //Create cases
        Case casePeugeotPortugal = (Case)TestDataFactoryUtil.createSobject('Case', new map<String, Object>{
            'Country__c'=>'PT', 'Brand__c'=>'AP', 'AccountId'=> personAccPeugeot.Id, 'AssetId'=> asset1.Id,
            'Origin'=> CareConstants.CASE_ORIGIN_LETTER, 'Reason'=> CareConstants.CASE_REASON_COMPLAINT}, false);            
        
        Case caseCitroenPortugal = (Case)TestDataFactoryUtil.createSobject('Case', new map<String, Object>{
            'Country__c'=>'PT', 'Brand__c'=>'AC', 'AccountId'=> personAccCitroen.Id, 
            'Origin'=> CareConstants.CASE_ORIGIN_LETTER, 'Reason'=> CareConstants.CASE_REASON_COMPLAINT}, false);  
        
        Case caseCitroenArgentina = (Case)TestDataFactoryUtil.createSobject('Case', new map<String, Object>{
            'Country__c'=>'AR', 'Brand__c'=>'AC', 'AccountId'=> personAccCitroen.Id, 
            'Origin'=> CareConstants.CASE_ORIGIN_LETTER, 'Reason'=> CareConstants.CASE_REASON_COMPLAINT,
            'CategoryL1__c' => CareConstants.CASE_CATEGORYL1_SAVING_PLAN_FI}, false); 

        //Insert 3 test cases
        List<Case> lstTestCases = new List<Case>{casePeugeotPortugal, caseCitroenPortugal, caseCitroenArgentina}; 
        insert lstTestCases;
        
        //Insert Partner User
		List<Contact> lstContacts = TestDataFactoryUtil.createPartnerUser(1, 1, 'Dealer', '133225511','1237770', 'EXTKEY0002','AP','PT', 'J',new List<String>{'VN','VD'},true);
        List<User> lstUsers = TestDataFactoryUtil.createUser(lstContacts,'Sales_Manager','Partner','Manager');
        insert lstUsers;    
    
    
    }    
    
    /*********************************************************************************************************
    * @Method          :   checkCaseFromWebFormChat
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   06/11/2019
    * @Description     :   This method is used to verify that cases created from the chat are linked to the 
    *                  :   anonymous accounts. (Depending on the country)
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/           
    @isTest static void checkCaseFromChat(){
        
        //Get Anonymous Account
        Account anonymousAccountPT = [SELECT Id FROM Account WHERE Email__c =: KEY_ANONYMOUS_ACCOUNT_PORTUGAL LIMIT 1];
            
        //Create new case with Origin = Chat
        Case newCaseChat = (Case)TestDataFactoryUtil.createSobject('Case', new map<String, Object>{
             'Origin'=> CareConstants.CASE_ORIGIN_CHAT, 'Country__c'=>'PT', 'Brand__c'=>'AP', 'Language__c'=>'PT',   
             'Reason'=> CareConstants.CASE_REASON_INFORMATION_REQUEST}, false);        
        
        //Insert Case
        test.startTest();
        insert newCaseChat;
        test.stopTest();
         
        //Get updated data
        newCaseChat = [SELECT Id, Subject, AccountId FROM Case WHERE Id =: newCaseChat.Id];
        
        //Check that the case created from the chat is linked to the anonymous account
        System.assertEquals(anonymousAccountPT.Id, newCaseChat.AccountId);
        System.assertEquals(Label.Chat_conversation, newCaseChat.Subject);
    }
    
    /*********************************************************************************************************
    * @Method          :   checkUpdatedFieldFromPersonAcc
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/05/2019
    * @Description     :   Check that the ContactId field is updated with the contact of the associated person
    *                  :   account
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/           
    @isTest static void checkUpdatedFieldsFromPersonAcc(){
        
        Case casePeugeot = [SELECT Id, ContactId, Account.PersonContactId FROM Case 
                            WHERE Account.Email__c =: KEY_PERSON_ACCOUNT_PEUGEOT LIMIT 1];
        Account accountCitroen = [SELECT Id, PersonContactId FROM Account 
                                  WHERE Email__c =: KEY_PERSON_ACCOUNT_CITROEN LIMIT 1];
       
        //Case 1: INSERT CASE LINKED TO A PERSON ACCOUNT
        //Check that the ContactId field is updated
        System.assertEquals(casePeugeot.Account.PersonContactId, casePeugeot.ContactId);        

        //Case 2: UPDATE THE CASE WITH A CHANGE IN THE 'AccountId' FIELD
		casePeugeot.AccountId = accountCitroen.Id;       
        Test.startTest();
        update casePeugeot;
        Test.stopTest();
        //Check that the ContactId field is updated when there is a change in the AccountId field        
        casePeugeot = [SELECT ContactId FROM Case WHERE Id =: casePeugeot.Id  LIMIT 1];        
        System.assertEquals(accountCitroen.PersonContactId, casePeugeot.ContactId);        
    }    
    
    /*********************************************************************************************************
    * @Method          :   checkUpdatedFieldsFromAsset
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/05/2019
    * @Description     :   Check that the 'VIN__c' and 'RegistrationNumber__c' fields are updated each time 
    *                  :   the 'AssetId' field is changed
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/           
    @isTest static void checkUpdatedFieldsFromAsset(){
        
        Case casePeugeot = [SELECT Id, VIN__c, RegistrationNumber__c, Asset.VIN__c, Asset.LastKnownRegistrationNumber__c 
                            FROM Case WHERE Asset.VIN__c =: KEY_ASSET_1 LIMIT 1];
        Asset asset2 = [SELECT VIN__c, LastKnownRegistrationNumber__c FROM Asset WHERE Asset.VIN__c =: KEY_ASSET_2 LIMIT 1];
       
        //Case 1: INSERT CASE LINKED TO AN ASSET
        //Check that the VIN__c & RegistrationNumber__c fields are updated
        System.assertEquals(casePeugeot.Asset.VIN__c, casePeugeot.VIN__c);  
        System.assertEquals(casePeugeot.Asset.LastKnownRegistrationNumber__c, casePeugeot.RegistrationNumber__c);  

        //Case 2: UPDATE THE CASE WITH A CHANGE IN THE 'AssetId' FIELD
		casePeugeot.AssetId = asset2.Id;       
        Test.startTest();
        update casePeugeot;
        Test.stopTest();
        //Check that the VIN__c & RegistrationNumber__c fields are updated when there is a change in the AssetId field
        casePeugeot = [SELECT VIN__c, RegistrationNumber__c FROM Case WHERE Id =: casePeugeot.Id  LIMIT 1];        
        System.assertEquals(asset2.VIN__c, casePeugeot.VIN__c);  
        System.assertEquals(asset2.LastKnownRegistrationNumber__c, casePeugeot.RegistrationNumber__c);  
    }
    
    
    /*********************************************************************************************************
    * @Method          :   checkUpdateCaseAccountOngoing
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   06/11/2019
    * @Description     :   This method is used to ....
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/           
    @isTest static void checkUpdateCaseAccountOngoing(){
        
        //Get Anonymous Account
        List<Case> lstCasesToUpdate = [SELECT Id FROM Case];
        
        //Change status
        lstCasesToUpdate.get(0).Status = CareConstants.CASE_STATUS_CLOSED;
        lstCasesToUpdate.get(0).CloseReasonL1__c = CareConstants.CASE_CLOSE_REASONL1_INF_REQUEST;
        lstCasesToUpdate.get(1).Status = CareConstants.CASE_STATUS_BUSINESS_WAITING;

        //Update cases
        Test.startTest();
        update lstCasesToUpdate;
        lstCasesToUpdate.get(1).Status = CareConstants.CASE_STATUS_CLOSED;
        lstCasesToUpdate.get(1).CloseReasonL1__c = CareConstants.CASE_CLOSE_REASONL1_INF_REQUEST;
        update lstCasesToUpdate.get(1);
        Test.stopTest();
        
        //Asserts...... 
    }   

    /*********************************************************************************************************
    * @Method          :   checkCasesFromPartnerCommunity
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/15/2019
    * @Description     :   This method is used to check the functionality of cases created from the Partner community 
                            - The 'Dealer__c' field is updated correctly with the Partner user account
                            - The Case Owner is a queue
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/           
    @isTest static void checkCasesFromPartnerCommunity(){

        User partnerUser = [SELECT Id, Name, Contact.AccountId FROM User 
                                WHERE LastName = 'Testing' AND IsActive = true LIMIT 1];

        //Create new case
        Case newCase = (Case)TestDataFactoryUtil.createSobject('Case', new map<String, Object>{
             'Origin'=> CareConstants.CASE_ORIGIN_CHAT, 'Country__c'=>'PT', 'Brand__c'=>'AP', 'Language__c'=>'PT',   
             'Reason'=> CareConstants.CASE_REASON_INFORMATION_REQUEST}, false);        
        
        //Run as a Partner User
        System.runAs(partnerUser){
            Test.startTest();
                insert newCase;
            Test.stopTest();
        }

        newCase = [SELECT Dealer__c, OwnerId FROM Case WHERE Id =: newCase.Id];
        //Check that the Dealer__c field is updated properly
        System.assertEquals(partnerUser.Contact.AccountId, newCase.Dealer__c);
        //Check that the case owner is a queue
        System.assert(String.valueOf(newCase.OwnerId).startsWith('00G'));
    }
}
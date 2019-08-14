/**
    *   @Class          : GenericMashUpControllerTest
    *   @Author         : Sergio Lopez 
    *   @Created        : 11 May 2018
    *   @Description    : Test for GenericMashUpController
    *
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *    Developer          Date                Description  
    *    Sergio Lopez       11/05/2018          Creation.
    * 	 Ruben Fernandez	26/06/2019			Fixed test methods to last changes.
    * 											- Added SetUp method
    * 											- Removed SOQL to retrieve RT Ids. Only 1 insert per object.
    * 											- Added new method: getFlowMUpParamsErrorTest
    *     Nerea Leguinazabal 07/11/2019		    #C1STAGILE-16994: Use TestDataFactoryUtil for Data creation 
    *   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
private class GenericMashUpControllerTest {
	
	@testSetup 
    static void setup() {
    	User UserTest = TestDataFactoryUtil.createOneUser('PSA_Admin', 'PSA', 'AC', 'PL', '9878513');
        Insert UserTest;
    }
    static testMethod void getFlowMUpParamsTest() {
      
        User UserTest = [SELECT Id FROM User WHERE ldapid__c = '9878513' AND IsActive = true LIMIT 1];
        
        // Perform test
        Test.startTest();
          System.runAs(UserTest) {
              GenericMashUpController.getFlowMUpParams('Quote VD Creation'); 
          }
        Test.stopTest();  
    }
    
    static testMethod void getMUpParamsTest() {
       
        Account acc = new Account(Name = 'Test 1', RecordTypeId =  AccountConstants.ACCOUNT_RT_B2B); 
        insert acc;
       
        Account acc1 = new Account(FirstName = 'Test 2', LastName = 'Test 2', PersonalEmail__pc = 'test@test.es', RecordTypeId =  AccountConstants.ACCOUNT_RT_B2C); 
        insert acc1; 
        
        RecordType rType = [SELECT Id FROM RecordType WHERE Name like '%OPV%' AND SObjectType = 'SBQQ__Quote__c' LIMIT 1];
        
        Opportunity opp = new Opportunity(CloseDate = system.today()+180, Name = 'Test', StageName = '2',Country__c = 'CL');
        insert opp;
        
        Order ord = new Order(Order_Type__c = 'VN', AccountId = acc.Id, EffectiveDate = system.today(), Status = '9', OrderId__c = 'Test',Driver__c=acc.Id);
        insert ord;
    
        AccountExtRef__c accExt             =   new AccountExtRef__c (
            Account__c     	=  acc.id,
            System__c	   	=  'CRM',
            Brand__c	   	=  PAD.sUserBrand,
            Country__c		=  PAD.sUserCountry,
            ExternalId__c  	=  'Ext' + acc.id
        );
        insert accExt;

        SBQQ__Quote__C quoteVN = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
                    'SBQQ__Account__c'      => acc.Id,
                    'SBQQ__Opportunity2__c' => opp.id,
                    'RecordTypeId'          => rType.Id,
                    'OfferType__c'          => 'VN'
                } ,false);
        SBQQ__Quote__C quoteVD = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
                    'SBQQ__Account__c'      => acc.Id,
                    'SBQQ__Opportunity2__c' => opp.id,
                    'RecordTypeId'          => rType.Id,
                    'OfferType__c'          => 'VD'
                } ,false);
        SBQQ__Quote__C quoteVO = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
                    'SBQQ__Account__c'      => acc.Id,
                    'SBQQ__Opportunity2__c' => opp.id,
                    'RecordTypeId'          => rType.Id,
                    'OfferType__c'          => 'VO'
                } ,false);

        List<SBQQ__Quote__c> lstQuotes = new List<SBQQ__Quote__c>{quoteVN,quoteVD,quoteVO};
        insert lstQuotes;
        User UserTest = [SELECT Id FROM User WHERE ldapid__c = '9878513' AND IsActive = true LIMIT 1];
        // Perform test
        Test.startTest();
          System.runAs(UserTest) {
            GenericMashUpController.getMUpParams('Test','Order',ord.Id); 
            GenericMashUpController.getMUpParams('Order Delivery Creation','Order',ord.Id);
            GenericMashUpController.getMUpParams('Quote Delivery Creation','SBQQ__Quote__c',lstQuotes.get(1).Id);
            GenericMashUpController.getMUpParams('Quote Delivery Creation','SBQQ__Quote__c',lstQuotes.get(2).Id);
            GenericMashUpController.getMUpParams('Order Delivery Edition','Order',ord.Id);
            GenericMashUpController.getMUpParams('Quote Delivery Edition','SBQQ__Quote__c',lstQuotes.get(1).Id);
            GenericMashUpController.getMUpParams('Quote Delivery Edition','SBQQ__Quote__c',lstQuotes.get(2).Id);
            GenericMashUpController.getMUpParams('Quote Edition','SBQQ__Quote__c',lstQuotes.get(0).Id);
            GenericMashUpController.getMUpParams('Contract Edition','SBQQ__Quote__c',lstQuotes.get(0).Id);
            GenericMashUpController.getMUpParams('Order Edition','Order',ord.Id);
            GenericMashUpController.getMUpParams('Service Contract','Account',acc.Id);
            GenericMashUpController.getMUpParams('Service Contract','Account',acc1.Id);
            GenericMashUpController.getMUpParams('VPO Creation','Account',acc.Id);
			GenericMashUpController.getMUpParams('VO Delivery Edition','Account',acc.Id);              
          }
        Test.stopTest();
    }

    static testMethod void getMUpParamsTest2() {

        Account acc = new Account(Name = 'Test 1', RecordTypeId =  AccountConstants.ACCOUNT_RT_B2B); 
        insert acc;
        Account acc1 = new Account(FirstName = 'Test 2', LastName = 'Test 2', PersonalEmail__pc = 'test@test.es', RecordTypeId =  AccountConstants.ACCOUNT_RT_B2C); 
        insert acc1; 
           
        RecordType rType = [SELECT Id FROM RecordType WHERE Name like '%OPV%' AND SObjectType = 'SBQQ__Quote__c' LIMIT 1];
        
        User UserTest = [SELECT Id FROM User WHERE ldapid__c = '9878513' AND IsActive = true LIMIT 1];
        // Perform test
        Test.startTest();
            System.runAs(UserTest) {

                List<Asset> lstAssets = TestDataFactoryUtil.createAsset(1, new List<Account>{acc});
                GenericMashUpController.getMUpParams('VPO Modification','Asset',lstAssets[0].Id);
                GenericMashUpController.getMUpParams('Additional actions forms options','Asset',lstAssets[0].Id);
            }
        Test.stopTest();
    }

    @isTest static void getMUpParamsServiceContractTest(){

        List<Account> lstAccount  = new List<Account>{
        	new Account(Name = 'Test 1', RecordTypeId = AccountConstants.ACCOUNT_RT_B2B),
        	new Account(FirstName = 'Test 2', LastName = 'Test 2', PersonalEmail__pc = 'test@test.es', RecordTypeId = AccountConstants.ACCOUNT_RT_B2C) 
        };
		insert lstAccount;
        RecordType rType = [SELECT Id FROM RecordType WHERE Name like '%OPV%' AND SObjectType = 'SBQQ__Quote__c' LIMIT 1];
        
        Opportunity opp = new Opportunity(CloseDate = system.today()+180, Name = 'Test', StageName = '2',Country__c = 'CL');
        insert opp;
        
        Order ord = new Order(Order_Type__c = 'VN', AccountId = lstAccount.get(1).Id, EffectiveDate = system.today(), Status = '9', OrderId__c = 'Test');
        insert ord;

        SBQQ__Quote__C quoteVN = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
                    'SBQQ__Account__c'      =>  lstAccount.get(1).Id,
                    'SBQQ__Opportunity2__c' => opp.id,
                    'RecordTypeId'          => rType.Id,
                    'OfferType__c'          => 'VN'
                } ,false);
        SBQQ__Quote__C quoteVD = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
                    'SBQQ__Account__c'      =>  lstAccount.get(1).Id,
                    'SBQQ__Opportunity2__c' => opp.id,
                    'RecordTypeId'          => rType.Id,
                    'OfferType__c'          => 'VD'
                } ,false);
        SBQQ__Quote__C quoteVO = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
                    'SBQQ__Account__c'      =>  lstAccount.get(1).Id,
                    'SBQQ__Opportunity2__c' => opp.id,
                    'RecordTypeId'          => rType.Id,
                    'OfferType__c'          => 'VO'
                } ,false);
      
        List<SBQQ__Quote__c> lstQuotes = new List<SBQQ__Quote__c>{quoteVD,quoteVN,quoteVO};
        insert lstQuotes;        

        User UserTest = [SELECT Id FROM User WHERE ldapid__c = '9878513' AND IsActive = true LIMIT 1];
        Test.startTest();
            System.runAs(UserTest) {
                GenericMashUpController.getMUpParams(
                    'Service Contract',
                    'Account',
                    lstAccount.get(1).Id
                );
                GenericMashUpController.getMUpParams(
                    'Order VN Edition',
                    'Order',
                    ord.Id
                );
                GenericMashUpController.getMUpParams(
                    'Order VN Creation',
                    'Order',
                    ord.Id
                );
            }
        Test.stopTest();
    }
    static testMethod void getFlowMUpParamsErrorTest() {
      
        User UserTest = [SELECT Id FROM User WHERE ldapid__c = '9878513' AND IsActive = true LIMIT 1];
        
        // Perform test
        Test.startTest();
          System.runAs(UserTest) {
              GenericMashUpController.getFlowMUpParams(null); 
          }
        Test.stopTest();  
    }
}
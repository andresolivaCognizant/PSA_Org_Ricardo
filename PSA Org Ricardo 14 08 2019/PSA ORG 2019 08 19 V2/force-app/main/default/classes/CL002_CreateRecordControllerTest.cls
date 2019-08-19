/**
* Salesforce
* @author 			Ruben Fernandez
* Project:			AfterSales
* Description:		Test class for CL002_CreateRecord.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2018-10-24		Ruben Fernandez (RF)	Initial definition.
*     	            18/06/2019      Pedro Párraga        	Edit.  
*********************************************************************************************************/
@isTest 
public with sharing class CL002_CreateRecordControllerTest {
	 @testSetup 
	 static void setup() {
	 	Account b2c = new Account(
			FirstName           = 'Account First Name',
			LastName            = 'Account Last Name',
			Salutation          = '1',
			Country__c          = 'PL',
			PersonalEmail__pc   = 'b2ccorstest@example.com',
			CompanyActivityType__c   = '0',
        	AccountType__c           = '0',
			RecordTypeId        = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId()
		);

		insert b2c;

		List<String> lstActivities  =   new List<String>(); 
        lstActivities.add('VN');
		List<Contact> lstConts       =   TestDataFactoryUtil.createPartnerUser(1, 2, 'Dealer', '133225511','1237770', 'EXTKEY0002','AP','CL', 'J',lstActivities,true);
		
		List<Contact> lstConts1      =  new List<Contact>();
		lstConts1.add(lstConts.get(0));
		List<Contact> lstConts2      =  new List<Contact>();
		lstConts2.add(lstConts.get(1));
        List<User> lstUsers1         =   TestDataFactoryUtil.createUser(lstConts1,'Aftersales_Manager','Partner','Manager');
        List<User> lstUsers2         =   TestDataFactoryUtil.createUser(lstConts2,'Sales_Manager_Agent','Partner','Worker');
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
        	lstUsers1.addAll(lstUsers2);
            Insert lstUsers1;
        }

	 }
	 @isTest 
	 static void fetchRecordTypeValuesTest(){
		Test.startTest();
			List<String> lstResults = CL002_CreateRecordController.fetchRecordTypeValues('Account');
			List<String> lstNoResult= CL002_CreateRecordController.fetchRecordTypeValues('');
		Test.stopTest();
	}
	@isTest 
	static void fetchDefaultRecordTypeTest(){
		Test.startTest();
			String sResult = CL002_CreateRecordController.fetchDefaultRecordType('Account');
		Test.stopTest();
	}
	@isTest 
	static void getRecordTypeIdTest(){
		Test.startTest();
			Id idResult = CL002_CreateRecordController.getRecordTypeId('Account','B2B');
		Test.stopTest();
	}
	@isTest 
	static void DMSWakeUpbyCORSKOTest(){

		User thisUser = [ select Id from User where username like '%@example%' limit 1];

		Test.startTest();
		 	System.runAs ( thisUser ) {
				Map<String,String> mapResults 	= CL002_CreateRecordController.DMSWakeUpbyCORS('Account');
				//String sResult 					= CL002_CreateRecordController.getObjectValue('Account');
			}
		Test.stopTest();
	}
	@isTest 
	static void DMSWakeUpbyCORSOKTest(){
		Account b2c = new Account(
			FirstName           = 'Account FirstName',
			LastName            = 'Account LastName',
			Salutation          = '1',
			Country__c          = 'PL',
			PersonalEmail__pc   = 'b2c@test.com',
			CompanyActivityType__c   = '0',
        	AccountType__c           = '0',
			RecordTypeId        = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId()
		);

		insert b2c;
		
		Order objOrder												= new Order();
		objOrder.OrderId__c											= '2141411';
		objOrder.SupplyOrderId__c									= 'ORDER0001';
		objOrder.OrderCreationDate__c								= System.today().addDays( -10 );
		objOrder.FleetCode__c										= 'FLEET001';
		objOrder.UseType__c											= '1';
		objOrder.AccountId											= b2c.Id;
		objOrder.RecordTypeId										= Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get( 'VNOrders' ).getRecordTypeId();
		objOrder.EffectiveDate										= System.today().addDays( 25 );
		objOrder.Status												= 'Draft';
		objOrder.CompletedSaleDate__c								= System.today().addMonths( -2 );
		
		insert objOrder;

		Asset a = new Asset(
			Name                = 'Test Vehicle',
			AssetType__c        = 'VN',
			CurrencyIsoCode     = 'EUR',
			AccountId           = b2c.Id,
			OrderId__c			= objOrder.Id
		);

		insert a;
		Test.startTest();
		 	
			Map<String,String> mapResults 	= CL002_CreateRecordController.DMSWakeUpbyCORS('Account');
			//String sResult 					= CL002_CreateRecordController.getObjectValue('Account');

		Test.stopTest();
	}
}
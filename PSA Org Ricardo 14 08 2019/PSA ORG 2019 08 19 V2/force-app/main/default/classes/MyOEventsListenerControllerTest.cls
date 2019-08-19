/******************************************************************************************
* Name: 			MyOEventsListenerControllerTest
* Author: 			Ruben Fernandez
* Description:		Test class for MyOEventsListenerController class
* 
* Changes (Version)
* -----------------------------------------------------------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2019-05-27		Ruben Fernandez (MM)	Initial definition.
*******************************************************************************************/
@isTest
private class MyOEventsListenerControllerTest {
	
	/******************************************************************************************************
	* @Method			: setup
	* @Author			: Ruben Fernandez
	* @Created			: ##/##/2018
	* @Description		: Setup Method
	******************************************************************************************************/
	@testSetup static void setup() {
		List<Account> lstA = new List<Account>();
		Account acct = new Account(
				Salutation              = '1',
				Firstname               = 'Test 1',
				LastName                = 'Account_Test', 
				BillingStreet           = 'Eduardo Barreiro Nº1',
				BillingCity             = 'Madrid',
				BillingCountry          = 'España',
				PersonEmail             = 'test@expalme.com',
				ProfessionalEmail__pc   = 'test@example.com',
				RecordTypeId            = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C_PA').getRecordTypeId());
		insert acct;

		lstA.add(acct);

		List<Account> lstB2C = new List<Account>();
			
		for(Account a : lstA) {
			Account p = new Account(
				Id              = a.Id,
				RecordTypeId    = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C_PA').getRecordTypeId()
			);
			lstB2C.add(p);
		}

		update lstB2C;
		
		Asset a1 = new Asset(
				Name                        = 'Asset Test 1',
				AssetType__c                = 'VN',
				CurrencyIsoCode             = 'EUR',
				AccountId                   = acct.Id,
				InitialStepKm__c            = 25000,
				InitialStepYear__c          = 1,
				CyclicStepKm__c             = 25000,
				CyclicStepYear__c           = 1,
				Country__c                  = 'ES',
				EnergyCode__c               = '01',
				FirstRegistrationDate__c    = Date.today().addMonths(-6),
				LastAPVVisitDate__c         = Date.today().addMonths(-3),
				LastAPVVisitMileage__c      = 100
			);
		insert a1;
	}

	/******************************************************************************************************
	 * @Method			: getUserDetailsTest
	 * @Author			: Ruben Fernandez
	 * @Created			: ##/##/2018
	 * @Description		: Test for getUserDetails method. This method also covers:
	 *						- getMyOHost
	 ******************************************************************************************************/
	@isTest static void getUserDetailsTest() {
		List<Account> lstA = new List<Account>([SELECT Id, IsPersonAccount FROM Account]); 
		List<Asset> lstV = new List<Asset>([SELECT Id, AccountId FROM Asset]);
		List<AccountContactAssetRelation__c> lstR = new List<AccountContactAssetRelation__c>([SELECT Id FROM AccountContactAssetRelation__c]);

		Test.startTest();
			WorkshopAppointment__c w = new WorkshopAppointment__c(
				Driver__c = lstA.get(0).Id,
				Asset__c = lstV.get(0).Id,
				TECH_AccountAssetRelation__c = lstR.get(0).Id
			);
			
			insert w;
			MyOEventsListenerController.MyOParams par = new MyOEventsListenerController.MyOParams();
			par = MyOEventsListenerController.getUserDetails('Agenda',w.id,'edit');

			System.assertEquals( true, String.isNotBlank( par.host ) );
		Test.stopTest();
	}

	/******************************************************************************************************
	 * @Method			: cancelAppointmentTest
	 * @Author			: Manuel Medina
	 * @Created			: 04/07/2018
	 * @Description		: Test for cancelAppointment method. This method also covers:
	 *						- getAppointmentId
	 ******************************************************************************************************/
	@isTest static void cancelAppointmentTest() {
		List<Account> lstAccounts								= new List<Account>( [SELECT Id, IsPersonAccount FROM Account] ); 
		List<Asset> lstAssets									= new List<Asset>( [SELECT Id, AccountId FROM Asset] );
		List<AccountContactAssetRelation__c> lstRelations		= new List<AccountContactAssetRelation__c>( [SELECT Id FROM AccountContactAssetRelation__c] );

		Test.startTest();
			WorkshopAppointment__c objAppointment				= new WorkshopAppointment__c();
			objAppointment.Driver__c							= lstAccounts.get(0).Id;
			objAppointment.Asset__c								= lstAssets.get(0).Id;
			objAppointment.TECH_AccountAssetRelation__c			= lstRelations.get(0).Id;
			objAppointment.AppointmentSBId__c					= 'TESTWAP01';

			insert objAppointment;

			JSONGenerator jsRequest_RecordId					= JSON.createGenerator( true );
			jsRequest_RecordId.writeStartObject();
			jsRequest_RecordId.writeStringField( 'strRecordId', objAppointment.Id );
			jsRequest_RecordId.writeStringField( 'strAppointmentId', 'TESTWAP01' );
			jsRequest_RecordId.writeEndObject();

			JSONGenerator jsRequest_NotRecordId					= JSON.createGenerator( true );
			jsRequest_NotRecordId.writeStartObject();
			jsRequest_NotRecordId.writeStringField( 'strAppointmentId', 'TESTWAP01' );
			jsRequest_NotRecordId.writeEndObject();

			JSONGenerator jsRequest_Error						= JSON.createGenerator( true );
			jsRequest_Error.writeStartObject();
			jsRequest_Error.writeStringField( 'strRecordId', 'InvalidId' );
			jsRequest_Error.writeStringField( 'strAppointmentId', 'TESTWAP01' );
			jsRequest_Error.writeEndObject();
			
			Map<String, Object> mapResponse_RecordId			= MyOEventsListenerController.cancelAppointment( jsRequest_RecordId.getAsString() );
			Map<String, Object> mapResponse_NotRecordId			= MyOEventsListenerController.cancelAppointment( jsRequest_NotRecordId.getAsString() );
			Map<String, Object> mapResponse_Error				= MyOEventsListenerController.cancelAppointment( jsRequest_Error.getAsString() );

			System.assertEquals( false, Boolean.valueOf( mapResponse_RecordId.get( 'hasError' ) ) );
			System.assertEquals( false, Boolean.valueOf( mapResponse_NotRecordId.get( 'hasError' ) ) );
			System.assertEquals( true, Boolean.valueOf( mapResponse_Error.get( 'hasError' ) ) );
			System.assertEquals( true, [SELECT Id FROM WorkshopAppointment__c WHERE AppointmentStatus__c = '9'] != null );
		Test.stopTest();
	}
}
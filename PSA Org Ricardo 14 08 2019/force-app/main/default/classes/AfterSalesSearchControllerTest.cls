/******************************************************************************************
* Name: 			AfterSalesSearchControllerTest
* Author: 			DXC
* Description:		Test class for CustomRelatedListController class
* 
* Changes (Version)
* -----------------------------------------------------------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2018-05-10		NN (NN)		            Initial definition.
*******************************************************************************************/
@isTest
public with sharing class AfterSalesSearchControllerTest {

	/******************************************************************************************************
	* @Method			: setup
	* @Author			: DXC
	* @Created			: ##/##/2018
	* @Description		: Setup Method
	******************************************************************************************************/
	@testSetup 
	static void setup() {
		List<Account> testRecords = new List<Account>();
		Account b2c = new Account(
			FirstName           = 'Account FirstName',
			LastName            = 'Account LastName',
			Salutation          = '1',
			PersonalEmail__pc   = 'b2c@test.com',
			PersonEmail         = 'b2c2@test.com',
			Phone               = '+56666666666',
			RecordTypeId        = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId()
		);
		Account b2c2 = new Account(
			FirstName           = 'B2C Acc FName',
			LastName            = 'User Account LName',
			Salutation          = '1',
			PersonalEmail__pc   = 'b2caccfname@example.com',
			PersonEmail         = 'b2caccfname2@example.com',
			Phone               = '+57666166999',
			BillingPostalCode   = '28080',
			RecordTypeId        = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId()
		);
		testRecords.add(b2c);
		testRecords.add(b2c2);
		Insert testRecords;
		Asset a = new Asset(
			Name                        = 'Asset Test 1',
			AssetType__c                = 'VN',
			CurrencyIsoCode             = 'EUR',
			AccountId                   = b2c.Id,
			InitialStepKm__c            = 25000,
			InitialStepYear__c          = 1,
			CyclicStepKm__c             = 25000,
			CyclicStepYear__c           = 1,
			Country__c                  = 'ES',
			Brand__c                    = 'AP',
			EnergyCode__c               = '01',
			FirstRegistrationDate__c    = Date.today().addMonths(-6),
			LastAPVVisitDate__c         = Date.today().addMonths(-3),
			LastAPVVisitMileage__c      = 3500,
			VIN__c                      = 'VF830232323233333',
			LastKnownRegistrationNumber__c = '7998-JJK',
			Model__c                    = '3008 Aircross'
		);

		Insert a;
		
		List<Account> lstAccts  = TestDataFactoryUtil.createAccountContact(1,'B2B');
		List<Asset> lstAssets   = TestDataFactoryUtil.createAsset(1,lstAccts);
		AccountContactAssetRelation__c bAux = new AccountContactAssetRelation__c(
				AccountId__c    = b2c.Id,
				AssetId__c      = lstAssets.get(0).Id,
				AccountRole__c  ='OldOwner'
			);
		Insert bAux;
	}

	/******************************************************************************************************
	* @Method			: AfterSalesSearchControllerTest
	* @Author			: DXC
	* @Created			: ##/##/2018
	* @Description		: Test for main process of AfterSalesSearchController
	******************************************************************************************************/
	static testMethod void AfterSalesSearchControllerTest(){
		List<Id> searchResultsIds = new List<Id>();
		
		Map<Id, Account> mapA = new Map<Id, Account>([
			SELECT Id FROM Account
		]);
		
		Map<Id, Asset> mapV = new Map<Id, Asset>([
			SELECT Id FROM Asset
		]);

		Map<Id, AccountContactAssetRelation__c> mapAC = new Map<Id, AccountContactAssetRelation__c>([
			SELECT Id FROM AccountContactAssetRelation__c
		]);
		
		

		searchResultsIds.addAll(mapA.keySet());
		searchResultsIds.addAll(mapV.keySet());
		searchResultsIds.addAll(mapAC.keySet());

		Test.setFixedSearchResults(searchResultsIds);

		List<Account> acc1 = new List<Account>([Select Id From Account Where PersonEmail = 'b2c2@test.com']);
		List<Asset> ass1 = new List<Asset>([Select Id From Asset Where Name = 'Asset Test 1']);
		
		if( !acc1.isEmpty() && !ass1.isEmpty() ){
			AccountContactAssetRelation__c bAux = new AccountContactAssetRelation__c(
				AccountId__c    = acc1.get(0).Id,
				AssetId__c      = ass1.get(0).Id,
				AccountRole__c  ='OldOwner'
			);
			
			Insert bAux;
		}

		Test.startTest();
			AfterSalesSearchController.DataTableResponse aux = AfterSalesSearchController.getfetchRecords('Account','', true);
			AfterSalesSearchController.DataTableResponse aux2 = AfterSalesSearchController.getfetchRecords('b2c@test.com','VF36', false);
			
			AfterSalesSearchController.setSelect('B2B');
			AfterSalesSearchController.setSelect('Account');
			AccountContactAssetRelation__c c = new AccountContactAssetRelation__c();
			AfterSalesSearchController.getselectOptions( c,'AccountRole__c');

			List<String> fields = new List<String>();
			fields.add('Id');
			fields.add('FirstName');
			fields.add('LastName');
			fields.add('Account.Name');
			AfterSalesSearchController.getLabelsAux('Contact','Account', fields);
		 Test.stopTest();
	}

	/******************************************************************************************************
	* @Method			: AfterSalesSearchControllerVariosTest
	* @Author			: DXC
	* @Created			: ##/##/2018
	* @Description		: Test for DMSWakeUpbyCORS method.
	******************************************************************************************************/
	static testMethod void AfterSalesSearchControllerVariosTest(){
		Test.startTest();
			sObject o;
			List<AfterSalesSearchController.DataTableObject> lstValues         = new List<AfterSalesSearchController.DataTableObject>();          // Wrapper to add to final response
			List<AfterSalesSearchController.DataTableObjectWrapper> lstValuesW = new List<AfterSalesSearchController.DataTableObjectWrapper>();   // Wrapper to add to final response
			List<AfterSalesSearchController.DataTableField>lstFieldsWrapper        = new List<AfterSalesSearchController.DataTableField>();  
			lstValues.add(new AfterSalesSearchController.DataTableObject(o,true));
			lstFieldsWrapper.add( new AfterSalesSearchController.DataTableField('AuxField', 'AuxValue'));
			lstValuesW.add(new AfterSalesSearchController.DataTableObjectWrapper(lstFieldsWrapper ,true));
			Map<String,String> mapResults   = AfterSalesSearchController.DMSWakeUpbyCORS('Account');
		Test.stopTest();
	}

	/******************************************************************************************************
	* @Method			: SecretQuestionTest
	* @Author			: DXC
	* @Created			: ##/##/2018
	* @Description		: Test for getSecretQuestion method. This method also covers:
	 *						- getQuestionResponse
	******************************************************************************************************/
	static testMethod void SecretQuestionTest() {
		List<Account> lstAccts          =   new List<Account>([SELECT Id From Account WHERE Name Like 'Account_B2B%' Limit 1]);

		Test.startTest();
			List<Contact> lstContact    =   new List<Contact>([SELECT Id From Contact Where AccountId =:lstAccts.get(0).Id]);
			String  sQuestion           =   AfterSalesSearchController.getSecretQuestion(lstContact.get(0).Id, 'SecretQuestionFieldsB2B','Contact');
			Boolean bResponse           =   AfterSalesSearchController.getQuestionResponse('Y3Zuk+0K/+J1s6rJeH9bAe3o4WDx4Ki0CIUWaG2NyP4=','response',null,null);

		Test.stopTest();
	}

	/******************************************************************************************************
	* @Method			: CreateRelationShipsTest
	* @Author			: DXC
	* @Created			: ##/##/2018
	* @Description		: Test for setAccountAssetRelationship method. This method also covers:
	 *						- setAccountRoleValue
	******************************************************************************************************/
	static testMethod void CreateRelationShipsTest() {

		List<Account> lstAccts          =   new List<Account>([SELECT Id From Account WHERE Name Like 'Account_B2B%' Limit 1]);
		List<Asset> lstAssets		    =   new List<Asset>([SELECT Id From Asset Where Accountid =:lstAccts.get(0).Id]);

		Test.startTest();
			AfterSalesSearchController.setAccountAssetRelationship(lstAssets.get(0).Id,lstAccts.get(0).Id, 'OldOwner', true);
			AccountContactAssetRelation__c bAux = new AccountContactAssetRelation__c(AccountId__c = lstAccts.get(0).Id, AssetId__c = lstAssets.get(0).Id , AccountRole__c ='OldOwner');
			AfterSalesSearchController.setAccountRoleValue(bAux.Id,'OldKeeper',true);
		Test.stopTest();
	}

	/******************************************************************************************************
	* @Method			: insertWorkshopAppointmentTest
	* @Author			: DXC
	* @Created			: ##/##/2018
	* @Description		: Test for insertWorkshopAppointment method. This method also covers:
	 *						- setAccountRoleValue
	******************************************************************************************************/
	static testMethod void insertWorkshopAppointmentTest(){

		AccountContactAssetRelation__c r = [
			SELECT Id, AccountId__c, AssetId__c
			FROM AccountContactAssetRelation__c
			LIMIT 1
		];

		Test.startTest();
			AfterSalesSearchController.insertWorkshopAppointment( r.Id, true, null );
		Test.stopTest();
	}

	/******************************************************************************************************
	* @Method			: insertWorkshopAppointmentTest
	* @Author			: DXC
	* @Created			: ##/##/2018
	* @Description		: Test for insertWorkshopAppointment method. This method also covers:
	 *						- setAccountRoleValue
	******************************************************************************************************/
	static testMethod void CreateAppoitmentAdvanceTest(){

		AccountContactAssetRelation__c r = [
			SELECT Id, AccountId__c, AssetId__c
			FROM AccountContactAssetRelation__c
			LIMIT 1
		];
		
		JSONGenerator jsRequest_success						= JSON.createGenerator( true );
		jsRequest_success.writeStartObject();
		jsRequest_success.writeStringField( 'EntityType', 'OLB_APPOINTMENT' );
		jsRequest_success.writeFieldName( 'paramsArray' );
			jsRequest_success.writeStartObject();
			jsRequest_success.writeStringField( 'appointmentId', 'SB0000000000AP010' );
			jsRequest_success.writeStringField( 'receptionDateTime', '2018-07-27T09:00:00' );
			jsRequest_success.writeEndObject();
		jsRequest_success.writeEndObject();

		JSONGenerator jsRequest_error						= JSON.createGenerator( true );
		jsRequest_error.writeStartObject();
		jsRequest_error.writeStringField( 'EntityType', 'OLB_APPOINTMENT' );
		jsRequest_error.writeFieldName( 'paramsArray' );
			jsRequest_error.writeStartObject();
			jsRequest_error.writeStringField( 'appointmentId', 'SB0000000000AP010' );
			jsRequest_error.writeStringField( 'receptionDateTime', '2018-07-27T09:00:00' );
			jsRequest_error.writeEndObject();
		jsRequest_error.writeEndObject();
  
		Test.startTest();
			Map<String, Object> mapResponse_success			= AfterSalesSearchController.insertWorkshopAppointment( r.Id, false, jsRequest_success.getAsString() );
			Map<String, Object> mapResponse_error			= AfterSalesSearchController.insertWorkshopAppointment( r.Id, false, jsRequest_error.getAsString() );

			System.assertEquals( false, Boolean.valueOf( mapResponse_success.get( 'hasError' ) ) );
			System.assertEquals( true, Boolean.valueOf( mapResponse_error.get( 'hasError' ) ) );
		Test.stopTest();
	}

}
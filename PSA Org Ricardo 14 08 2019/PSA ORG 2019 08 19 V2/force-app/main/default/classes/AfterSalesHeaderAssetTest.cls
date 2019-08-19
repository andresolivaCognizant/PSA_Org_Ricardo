/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			AfterSales
* Description:		AfterSalesHeaderAsset controller test class.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	2.0		2018-11-22		Manuel Medina (MM)		Initial definition.
* 	   			    07/11/2019		Nerea Leguinazabal		#C1STAGILE-16994: Use TestDataFactoryUtil for Data creation
*********************************************************************************************************/
@isTest
public class AfterSalesHeaderAssetTest {
	
	public static String CRON_EXP									= '0 0 0 3 9 ? 2099';

	/******************************************************************************************************
	* @Method			: setup
	* @Author			: Manuel Medina
	* @Created			: 03/07/2019
	* @Description		: Setup Method
	******************************************************************************************************/
	@testSetup static void setup() {
		Account b2c = new Account(
			FirstName           = 'Account FirstName',
			LastName            = 'Account LastName',
			Salutation          = '1',
			PersonalEmail__pc   = 'b2c@test.com',
			RecordTypeId        = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId()
		);

		Account objOwnerAccount = new Account(
			FirstName           = 'Owner',
			LastName            = 'Account LastName',
			Salutation          = '1',
			PersonalEmail__pc   = 'b2cowner@test.com',
			RecordTypeId        = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId()
		);

		insert new List<Account>{ b2c, objOwnerAccount };
		
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
			Name						= 'Test Vehicle',
			AssetType__c				= 'VN',
			CurrencyIsoCode				= 'EUR',
			AccountId					= objOwnerAccount.Id,
			OrderId__c					= objOrder.Id,
			WarrantyEndDate__c			= System.today().addDays( 90 ),
			NextMaintenanceDate__c		= System.today().addDays( 30 ),
			ProductionDate__c			= System.today().addDays( -1480 ),
			FirstRegistrationDate__c	= System.today().addDays( -1480 ),
			Eurorepar__c				= true,
			Country__c					= 'ES',
			Brand__c					= 'AC'
		);

		insert a;

		List<AccountContactAssetRelation__c> lst = new List<AccountContactAssetRelation__c>{
			new AccountContactAssetRelation__c(
				AccountId__c    = b2c.Id,
				AssetId__c      = a.Id,
				AccountRole__c  = 'Keeper'
			)
		};
	}

	/******************************************************************************************************
	* @Method			: getAssetPropertiesTest
	* @Author			: Manuel Medina
	* @Created			: 03/07/2019
	* @Description		: Test for getAssetProperties method. This method also covers:
	*						- getServiceContracts
	******************************************************************************************************/
	@isTest static void getAssetPropertiesTest(){
		Asset a = [SELECT Id FROM Asset];

		List<AccountContactAssetRelation__c> lst = new List<AccountContactAssetRelation__c>{
			new AccountContactAssetRelation__c(
				AccountId__c    = [SELECT Id FROM Account LIMIT 1].Id,
				AssetId__c      = [SELECT Id FROM Asset LIMIT 1].Id,
				AccountRole__c  = 'Keeper'
			),
			new AccountContactAssetRelation__c(
				AccountId__c    = [SELECT Id FROM Account WHERE NOT Name LIKE '%Owner%' LIMIT 1].Id,
				AssetId__c      = [SELECT Id FROM Asset LIMIT 1].Id,
				AccountRole__c  = 'Owner',
				PosessionChangeConfirmation__c	= true
			)
		};

		insert lst;

		Test.startTest();
			AfterSalesHeaderAssetController.WrapperVehicleProperties wrpVehicle		= AfterSalesHeaderAssetController.getAssetProperties( a.Id );

			System.assertEquals( true, wrpVehicle.keeper != null );
			System.assertEquals( true, wrpVehicle.owner != null );
		Test.stopTest();
	}
	
	/******************************************************************************************************
	* @Method			: getVINInfoFromERECATest_200
	* @Author			: Manuel Medina
	* @Created			: 03/07/2019
	* @Description		: Test for getVINInfoFromERECA method.
	******************************************************************************************************/
	@isTest static void getVINInfoFromERECATest_200(){
		Test.startTest();
			Test.setMock( HttpCalloutMock.class, new AfterSalesHeaderAssetErecaMock( 200 ) );
			Map<String, Object> mapResponse								= AfterSalesHeaderAssetController.getVINInfoFromERECA( 'QWRQWAFQAFQ', 'AC' );
			
			System.assertEquals( false, Boolean.valueOf( mapResponse.get( 'hasError' ) ) );
		Test.stopTest();
	}
	
	/******************************************************************************************************
	* @Method			: getVINInfoFromERECATest_500
	* @Author			: Manuel Medina
	* @Created			: 03/07/2019
	* @Description		: Test for getVINInfoFromERECA method.
	******************************************************************************************************/
	@isTest static void getVINInfoFromERECATest_500(){
		Test.startTest();
			Test.setMock( HttpCalloutMock.class, new AfterSalesHeaderAssetErecaMock( 500 ) );
			Map<String, Object> mapResponse								= AfterSalesHeaderAssetController.getVINInfoFromERECA( 'QWRQWAFQAFQ', 'AC' );
			
			System.assertEquals( true, Boolean.valueOf( mapResponse.get( 'hasError' ) ) );
		Test.stopTest();
	}
	
	/******************************************************************************************************
	* @Method			: getVINInfoFromERECATest_null
	* @Author			: Manuel Medina
	* @Created			: 05/07/2019
	* @Description		: Test for getVINInfoFromERECA method.
	******************************************************************************************************/
	@isTest static void getVINInfoFromERECATest_null(){
		Test.startTest();
			Test.setMock( HttpCalloutMock.class, new AfterSalesHeaderAssetErecaMock( null ) );
			Map<String, Object> mapResponse								= AfterSalesHeaderAssetController.getVINInfoFromERECA( 'QWRQWAFQAFQ', 'AC' );
			
			System.assertEquals( true, Boolean.valueOf( mapResponse.get( 'hasError' ) ) );
		Test.stopTest();
	}
	
	/******************************************************************************************************
	* @Method			: allowOpportunitiesTest
	* @Author			: Manuel Medina
	* @Created			: 05/07/2019
	* @Description		: Test for allowOpportunities method.
	******************************************************************************************************/
	@isTest static void allowOpportunitiesTest(){
		Test.startTest();
			Account objAccount											= [SELECT Id FROM Account LIMIT 1];

			String strRequest_WarrantyExtension							= '{' +
																			'"strAccountId"				: "' + objAccount.Id + '",' +
																			'"strBrand"					: "AC",' +
																			'"strCountry"				: "ES",' +
																			'"strPurchaseDate"			: "2017-08-23",' +
																			'"strWarrantyStartDate"		: "2017-08-23",' +
																			'"strWarrantyEndDate"		: "2018-12-05"' +
																		'}';

			String strRequest_Maintenance								= '{' +
																			'"strAccountId"				: "' + objAccount.Id + '",' +
																			'"strBrand"					: "AC",' +
																			'"strCountry"				: "ES",' +
																			'"strPurchaseDate"			: "2017-07-23",' +
																			'"strWarrantyStartDate"		: "2017-06-23",' +
																			'"strWarrantyEndDate"		: "2018-12-23",' +
																			'"strLastMaintenanceDate"	: "2018-08-30"' +
																		'}';

			String strRequest_Error										= '{' +
																			'"strAccountId"				: "' + objAccount.Id + '",' +
																			'"strBrand"					: "AC",' +
																			'"strCountry"				: "ES",' +
																			'"strPurchaseDate"			: "2017-07-23",' +
																			'"strWarrantyStartDate"		: "2017-086-23",' +
																			'"strWarrantyEndDate"		: "2018-12-23",' +
																			'"strLastMaintenanceDate"	: "2018-08-30"' +
																		'}';
																		
			Map<String, Object> mapResponse_WarrantyExtension			= AfterSalesHeaderAssetController.allowOpportunities( strRequest_WarrantyExtension );
			Map<String, Object> mapResponse_Maintenance					= AfterSalesHeaderAssetController.allowOpportunities( strRequest_Maintenance );
			Map<String, Object> mapResponse_Error						= AfterSalesHeaderAssetController.allowOpportunities( strRequest_Error );
			
			System.assertEquals( false, Boolean.valueOf( mapResponse_WarrantyExtension.get( 'hasError' ) ) );
			System.assertEquals( false, Boolean.valueOf( mapResponse_Maintenance.get( 'hasError' ) ) );
			System.assertEquals( true, Boolean.valueOf( mapResponse_Error.get( 'hasError' ) ) );
		Test.stopTest();
	}
	
	/******************************************************************************************************
	* @Method			: createOpportunitiesTest
	* @Author			: Manuel Medina
	* @Created			: 05/07/2019
	* @Description		: Test for createOpportunities method. This method also covers:
	*						- assignOpportunity
	******************************************************************************************************/
	@isTest static void createOpportunitiesTest(){
		Test.startTest();
			Account objAccount											= [SELECT Id FROM Account LIMIT 1];

			String strRequest_Maintenace								= '{' +
																			'"strAccountId"				: "' + objAccount.Id + '",' +
																			'"strCurrencyIsoCode"		: "EUR",' +
																			'"strBrand"					: "AC",' +
																			'"strCountry"				: "ES",' +
																			'"strWarrantyEndDate"		: "2018-12-23",' +
																			'"strLastKnownRegNumber"	: "AELFIKAFKL",' +
																			'"blnWarratyOpp"			: true,' +
																			'"blnMaintOpp"				: true ' +
																		'}';

			String strRequest_WarrantyExtension							= '{' +
																			'"strAccountId"				: "' + objAccount.Id + '",' +
																			'"strCurrencyIsoCode"		: "EUR",' +
																			'"strBrand"					: "AC",' +
																			'"strCountry"				: "ES",' +
																			'"strWarrantyEndDate"		: "2018-12-23",' +
																			'"strLastKnownRegNumber"	: "AELFIKAFKL",' +
																			'"blnWarratyOpp"			: true,' +
																			'"blnMaintOpp"				: false ' +
																		'}';

			String strRequest_DMLError									= '{' +
																			'"strAccountId"				: "InvalidId",' +
																			'"strCurrencyIsoCode"		: "EUR",' +
																			'"strBrand"					: "AC",' +
																			'"strCountry"				: "ES",' +
																			'"strWarrantyEndDate"		: "2018-12-23",' +
																			'"strLastKnownRegNumber"	: "AELFIKAFKL",' +
																			'"blnWarratyOpp"			: true,' +
																			'"blnMaintOpp"				: false ' +
																		'}';

			String strRequest_Error										= '{' +
																			'"strAccountId"				: "' + objAccount.Id + '",' +
																			'"strCurrencyIsoCode"		: "EUR",' +
																			'"strBrand"					: "AC",' +
																			'"strCountry"				: "ES",' +
																			'"strWarrantyEndDate"		: "2018-12-23",' +
																			'"strLastKnownRegNumber"	: "AELFIKAFKL",' +
																			'"blnWarratyOpp"			: true,' +
																			'"blnMaintOpp"				: false ' +
																		'}';
																		
			Map<String, Object> mapResponse_Maintenance					= AfterSalesHeaderAssetController.createOpportunities( strRequest_Maintenace );
			Map<String, Object> mapResponse_WarrantyExtension			= AfterSalesHeaderAssetController.createOpportunities( strRequest_WarrantyExtension );
			Map<String, Object> mapResponse_DMLError					= AfterSalesHeaderAssetController.createOpportunities( strRequest_DMLError );
			Map<String, Object> mapResponse_Error						= AfterSalesHeaderAssetController.createOpportunities( strRequest_DMLError );

			System.assertEquals( false, Boolean.valueOf( mapResponse_Maintenance.get( 'hasError' ) ) );
			System.assertEquals( false, Boolean.valueOf( mapResponse_WarrantyExtension.get( 'hasError' ) ) );
			System.assertEquals( true, ![SELECT Id FROM Opportunity WHERE LeadRequestType__c = '100'].isEmpty() );
			System.assertEquals( true, ![SELECT Id FROM Opportunity WHERE LeadRequestType__c = '101'].isEmpty() );
			System.assertEquals( true, Boolean.valueOf( mapResponse_DMLError.get( 'hasError' ) ) );
			System.assertEquals( true, Boolean.valueOf( mapResponse_Error.get( 'hasError' ) ) );
		Test.stopTest();
	}
	
	/******************************************************************************************************
	* @Method			: createVehicleEventTest
	* @Author			: Manuel Medina
	* @Created			: 05/07/2019
	* @Description		: Test for createVehicleEvent method.
	******************************************************************************************************/
	@isTest static void createVehicleEventTest(){
		Test.startTest();
			String strRequest											= '{' +
																			'"strAssetId"		: "' + [SELECT Id FROM Asset LIMIT 1].Id + '",' +
																			'"strRealMileage"	: "10000"' +
																		'}';

			String strRequest_error										= '{' +
																			'"strAssetId"		: "' + [SELECT Id FROM Asset LIMIT 1].Id + '",' +
																			'"strRealMileage"	: "10000A"' +
																		'}';

			Map<String, Object> mapResponse								= AfterSalesHeaderAssetController.createVehicleEvent( strRequest );
			Map<String, Object> mapResponse_error						= AfterSalesHeaderAssetController.createVehicleEvent( strRequest_error );

			System.assertEquals( false, Boolean.valueOf( mapResponse.get( 'hasError' ) ) );
			System.assertEquals( true, Boolean.valueOf( mapResponse_error.get( 'hasError' ) ) );
		Test.stopTest();
	}

	/******************************************************************************************************
	* @Method			: validateVehicleEventRulesTest
	* @Author			: Manuel Medina
	* @Created			: 05/07/2019
	* @Description		: Test for APS012_AfterSalesVehicleEvent.validateVehicleEventRules method.
	******************************************************************************************************/
	@isTest static void validateVehicleEventRulesTest(){
		Test.startTest();
			String strJobId												= System.schedule( 'testBasicScheduledApex', CRON_EXP, new APS012_AfterSalesVehicleEvent() );
		Test.stopTest();
	}

	/******************************************************************************************************
	* @Method			: getAlertsTest
	* @Author			: Manuel Medina
	* @Created			: 05/07/2019
	* @Description		: Test for getAlerts method in not massive process. This method also covers:
	*						- getInitData
	*						- addAlert
	*						- getHighlightedIconColors
	*						- validateDate
	*						- updateAppointmentIcons
	******************************************************************************************************/
	@isTest static void getAlertsTest(){
		Account objAccount												= [SELECT Id FROM Account WHERE Name LIKE '%Owner%' LIMIT 1];
		Asset objAsset													= [SELECT Id FROM Asset LIMIT 1];

		WorkshopAppointment__c objAppointment1							= new WorkshopAppointment__c();
		objAppointment1.Name											= 'WAP0001';
		objAppointment1.Owner__c										= objAccount.Id;
		objAppointment1.Driver__c										= objAccount.Id;
		objAppointment1.Asset__c										= objAsset.Id;
		objAppointment1.AppointmentRepeatRepair__c						= true;
		objAppointment1.AppointmentStatus__c							= '5';
		objAppointment1.RestitutionDateTime__c							= System.now().addDays( -2 );

		WorkshopAppointment__c objAppointment2							= new WorkshopAppointment__c();
		objAppointment2.Name											= 'WAP0002';
		objAppointment2.Owner__c										= objAccount.Id;
		objAppointment2.Driver__c										= objAccount.Id;
		objAppointment2.Asset__c										= objAsset.Id;
		objAppointment2.AppointmentRepeatRepair__c						= true;
		objAppointment2.AppointmentStatus__c							= '5';
		objAppointment2.RestitutionDateTime__c							= System.now().addDays( -1 );
		
		insert new List<WorkshopAppointment__c>{ objAppointment1, objAppointment2 };

		Test.startTest();
			String strRequest											= '{' +
																			'"strCurrentAppointmentId"	: "' + objAppointment1.Id + '",' +
																			'"strCountry"				: "ES",' +
																			'"strBrand"					: "AC",' +
																			'"strType"					: "VN"' +
																		'}';

			String strRequest_Error										= '{' +
																			'"strCurrentAppointmentId"	: "InvalidId",' +
																			'"strCountry"				: "ES",' +
																			'"strBrand"					: "AC",' +
																			'"strType"					: "VN"' +
																		'}';
																		
			Map<String, Object> mapResponse								= AfterSalesHeaderAssetController.getAlerts( strRequest );
			Map<String, Object> mapResponse_Error						= AfterSalesHeaderAssetController.getAlerts( strRequest_Error );

			System.assertEquals( true, Boolean.valueOf( mapResponse.get( 'hasAlert1' ) ) );
			System.assertEquals( true, Boolean.valueOf( mapResponse.get( 'hasAlert3' ) ) );
			System.assertEquals( true, Boolean.valueOf( mapResponse.get( 'isReturn' ) ) );
			System.assertEquals( true, Boolean.valueOf( mapResponse.get( 'oldVehicle' ) ) );
			System.assertEquals( true, Boolean.valueOf( mapResponse_Error.get( 'hasError' ) ) );
		Test.stopTest();
	}

	/******************************************************************************************************
	* @Method			: getAlertsMassiveTest
	* @Author			: Manuel Medina
	* @Created			: 05/07/2019
	* @Description		: Test for getAlerts method in massive process. This method also covers:
	*						- getInitData
	*						- addAlert
	*						- getHighlightedIconColors
	*						- validateDate
	*						- updateAppointmentIcons
	******************************************************************************************************/
	@isTest static void getAlertsMassiveTest(){
		Account objAccount												= [SELECT Id FROM Account WHERE Name LIKE '%Owner%' LIMIT 1];
		Asset objAsset													= [SELECT Id FROM Asset LIMIT 1];

		WorkshopAppointment__c objAppointment1							= new WorkshopAppointment__c();
		objAppointment1.Name											= 'WAP0001';
		objAppointment1.Owner__c										= objAccount.Id;
		objAppointment1.Driver__c										= objAccount.Id;
		objAppointment1.Asset__c										= objAsset.Id;
		objAppointment1.AppointmentRepeatRepair__c						= true;
		objAppointment1.AppointmentStatus__c							= '5';
		objAppointment1.RestitutionDateTime__c							= System.today().addDays( -3 );

		WorkshopAppointment__c objAppointment2							= new WorkshopAppointment__c();
		objAppointment2.Name											= 'WAP0002';
		objAppointment2.Owner__c										= objAccount.Id;
		objAppointment2.Driver__c										= objAccount.Id;
		objAppointment2.Asset__c										= objAsset.Id;
		objAppointment2.AppointmentRepeatRepair__c						= true;
		objAppointment2.AppointmentStatus__c							= '5';
		objAppointment2.RestitutionDateTime__c							= System.today().addDays( -2 );

		WorkshopAppointment__c objAppointment3							= new WorkshopAppointment__c();
		objAppointment3.Name											= 'WAP0002';
		objAppointment3.Owner__c										= objAccount.Id;
		objAppointment3.Driver__c										= objAccount.Id;
		objAppointment3.Asset__c										= objAsset.Id;
		objAppointment3.AppointmentRepeatRepair__c						= true;
		objAppointment3.AppointmentStatus__c							= '5';
		objAppointment3.RestitutionDateTime__c							= System.today().addDays( -1 );
		
		insert new List<WorkshopAppointment__c>{ objAppointment1, objAppointment2, objAppointment3 };

		Test.startTest();
			Map<Id, WorkshopAppointment__c> mapAppointmentById			= new Map<Id, WorkshopAppointment__c>( [
																			SELECT Id,
																				TECH_InfoIconsCode__c
																			FROM WorkshopAppointment__c
																			LIMIT 2
																		] );

			AfterSalesHeaderAssetController.getAlerts( mapAppointmentById.keySet() );

			System.assertEquals( true, ![SELECT Id FROM WorkshopAppointment__c WHERE TECH_InfoIconsCode__c = '1111'].isEmpty() );
		Test.stopTest();
	}

	/******************************************************************************************************
	* @Method			: getDMSDataTest
	* @Author			: Manuel Medina
	* @Created			: 08/07/2019
	* @Description		: Test for getDMSData method. This method also covers:
	*						- DMSWakeUp
	*						- DMSWakeUpbyServer
	******************************************************************************************************/
	@isTest static void getDMSDataTest(){
		Test.startTest();
			Account objAccount											= [SELECT Id FROM Account LIMIT 1];
			Asset objAsset												= [SELECT Id FROM Asset LIMIT 1];

			String strRequest											= '{' +
																			'"strAccountId"		: "' + objAccount.Id + '",' +
																			'"strIdDMSType"		: "Owner"' +
																		'}';
																		
			String strRequest_error										= '{' +
																			'"strAccountId"		: "InvalidId",' +
																			'"strIdDMSType"		: "Owner"' +
																		'}';
																		
			Map<String, Object> mapResponse								= AfterSalesHeaderAssetController.getDMSData( strRequest );
			Map<String, Object> mapResponse_error						= AfterSalesHeaderAssetController.getDMSData( strRequest_error );

			AfterSalesHeaderAssetController.DMSWakeUp( objAccount.Id, objAsset.Id );
			AfterSalesHeaderAssetController.DMSWakeUpbyServer( objAccount.Id );
			
			System.assertEquals( false, Boolean.valueOf( mapResponse.get( 'hasError' ) ) );
			System.assertEquals( true, Boolean.valueOf( mapResponse_error.get( 'hasError' ) ) );
		Test.stopTest();
	}
}
/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			AfterSales
* Description:		AfterSalesAppointmentPlanningController controller test class.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2019-05-13		Antoine Audollent (AA)	Class creation.
* @version	2.0		2019-07-08		Manuel Medina (MM)		Test class refactoring.
*********************************************************************************************************/
@isTest
private class AfterSalesAppointmentPlanningCtrlTest {

	/******************************************************************************************************
	* @Method			: setup
	* @Author			: Manuel Medina
	* @Created			: 08/07/2019
	* @Description		: Setup Method
	******************************************************************************************************/
	@testSetup static void setup() {
		List<Contact> lstConts								= TestDataFactoryUtil.createPartnerUser( 1, 1, 'Dealer', '133225515', '1237775', 'EXTKEY0010', 'AP', 'ES', 'J', new List<String>{ 'VN' }, true );
		List<User> lstUsers									= TestDataFactoryUtil.createUser( lstConts, 'Salesman', 'Partner', 'Manager' );
		
		lstUsers.get(0).Country__c	= 'ES';
		insert lstUsers;

		User objUser										= [SELECT Id,
																	Contact.AccountId
																FROM User
																WHERE LastName LIKE '%Testing%'
																LIMIT 1
															];

		System.runAs( objUser ){
			Account b2c										= new Account();
			b2c.FirstName									= 'Account FirstName';
			b2c.LastName									= 'Account LastName';
			b2c.Salutation									= '1';
			b2c.PersonalEmail__pc							= 'b2c@test.com';
			b2c.RecordTypeId								= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get( 'PersonAccount_B2C' ).getRecordTypeId();

			Account objOwnerAccount							= new Account();
			objOwnerAccount.FirstName						= 'Owner';
			objOwnerAccount.LastName						= 'Account LastName';
			objOwnerAccount.Salutation						= '1';
			objOwnerAccount.PersonalEmail__pc				= 'b2cowner@test.com';
			objOwnerAccount.RecordTypeId					= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get( 'PersonAccount_B2C' ).getRecordTypeId();

			insert new List<Account>{ b2c, objOwnerAccount };
			
			Order objOrder									= new Order();
			objOrder.OrderId__c								= '2141411';
			objOrder.SupplyOrderId__c						= 'ORDER0001';
			objOrder.OrderCreationDate__c					= System.today().addDays( -10 );
			objOrder.FleetCode__c							= 'FLEET001';
			objOrder.UseType__c								= '1';
			objOrder.AccountId								= b2c.Id;
			objOrder.RecordTypeId							= Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get( 'VNOrders' ).getRecordTypeId();
			objOrder.EffectiveDate							= System.today().addDays( 25 );
			objOrder.Status									= 'Draft';
			objOrder.CompletedSaleDate__c					= System.today().addMonths( -2 );
			
			insert objOrder;

			Asset objAsset									= new Asset();
			objAsset.Name									= 'Test Vehicle';
			objAsset.AssetType__c							= 'VN';
			objAsset.CurrencyIsoCode						= 'EUR';
			objAsset.AccountId								= objOwnerAccount.Id;
			objAsset.OrderId__c								= objOrder.Id;
			objAsset.WarrantyEndDate__c						= System.today().addDays( 90 );
			objAsset.NextMaintenanceDate__c					= System.today().addDays( 30 );
			objAsset.ProductionDate__c						= System.today().addDays( -1480 );
			objAsset.FirstRegistrationDate__c				= System.today().addDays( -1480 );
			objAsset.Eurorepar__c							= true;
			objAsset.Country__c								= 'ES';
			objAsset.Brand__c								= 'AC';

			insert objAsset;

			WorkshopAppointment__c objAppointment1			= new WorkshopAppointment__c();
			objAppointment1.Name							= 'WAP0001';
			objAppointment1.Owner__c						= objOwnerAccount.Id;
			objAppointment1.Driver__c						= objOwnerAccount.Id;
			objAppointment1.Asset__c						= objAsset.Id;
			objAppointment1.AppointmentRepeatRepair__c		= true;
			objAppointment1.AppointmentStatus__c			= '5';
			objAppointment1.ReceptionDatetime__c			= System.today().addDays( -3 );
			objAppointment1.Workshop__c						= objUser.Contact.AccountId;

			WorkshopAppointment__c objAppointment2			= new WorkshopAppointment__c();
			objAppointment2.Name							= 'WAP0002';
			objAppointment2.Owner__c						= objOwnerAccount.Id;
			objAppointment2.Driver__c						= objOwnerAccount.Id;
			objAppointment2.Asset__c						= objAsset.Id;
			objAppointment2.AppointmentRepeatRepair__c		= true;
			objAppointment2.AppointmentStatus__c			= '5';
			objAppointment2.ReceptionDatetime__c			= System.today().addDays( -2 );
			objAppointment2.Workshop__c						= objUser.Contact.AccountId;

			WorkshopAppointment__c objAppointment3			= new WorkshopAppointment__c();
			objAppointment3.Name							= 'WAP0003';
			objAppointment3.Owner__c						= objOwnerAccount.Id;
			objAppointment3.Driver__c						= objOwnerAccount.Id;
			objAppointment3.Asset__c						= objAsset.Id;
			objAppointment3.AppointmentRepeatRepair__c		= true;
			objAppointment3.AppointmentStatus__c			= '5';
			objAppointment3.ReceptionDatetime__c			= System.today().addDays( -1 );
			objAppointment3.Workshop__c						= objUser.Contact.AccountId;
			
			insert new List<WorkshopAppointment__c>{ objAppointment1, objAppointment2, objAppointment3 };
		}
	}

	/******************************************************************************************************
	* @Method			: getAppointmentListTest
	* @Author			: Manuel Medina
	* @Created			: 08/07/2019
	* @Description		: Test for getAppointmentList method.
	******************************************************************************************************/
	@isTest static void getAppointmentListTest(){
		Test.startTest();
			String strRequest								= '{' +
																'"strStartDate"				: "' + System.now().addDays( -5 ).format( 'yyyy-MM-dd' ) + '",' +
																'"strEndDate"				: "' + System.now().format( 'yyyy-MM-dd' ) + '",' +
																'"strStatusSelected"		: "[5, 6]",' +
																'"strReceptionistSelected"	: "all"' +
															'}';

			String strRequest_Error							= '{' +
																'"strStartDate"				: "InvalidDate",' +
																'"strEndDate"				: "' + System.now().format( 'yyyy-MM-dd' ) + '"' +
															'}';
																		
			Map<String, Object> mapResponse					= new Map<String, Object>();
			Map<String, Object> mapResponse_Error			= new Map<String, Object>();

			System.runAs( [SELECT Id FROM User WHERE LastName LIKE '%Testing%' LIMIT 1][0] ){
				mapResponse									= AfterSalesAppointmentPlanningController.getAppointmentList( strRequest );
				mapResponse_Error							= AfterSalesAppointmentPlanningController.getAppointmentList( strRequest_Error );
			}

			List<WorkshopAppointment__c> lstAppointmest		= mapResponse.containsKey( 'payload' ) ? ( List<WorkshopAppointment__c> ) mapResponse.get( 'payload' ) : new List<WorkshopAppointment__c>();
			
			System.assertEquals( true, !lstAppointmest.isEmpty() );
			System.assertEquals( true, Boolean.valueOf( mapResponse_Error.get( 'hasError' ) ) );
		Test.stopTest();
	}
}
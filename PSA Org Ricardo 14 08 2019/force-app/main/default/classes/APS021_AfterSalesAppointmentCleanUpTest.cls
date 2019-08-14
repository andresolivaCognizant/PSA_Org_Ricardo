/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			AfterSales
* Description:		APS021_AfterSalesAppointmentCleanUp and APB021_AfterSalesAppointmentCleanUp test class.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	2.0		2019-07-08		Manuel Medina (MM)		Initial definition.
*********************************************************************************************************/
@isTest
public class APS021_AfterSalesAppointmentCleanUpTest {

	public static String CRON_EXP									= '0 0 0 3 9 ? 2099';

	/******************************************************************************************************
	* @Method			: setup
	* @Author			: Manuel Medina
	* @Created			: 03/07/2019
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
			
			Asset objAsset									= new Asset();
			objAsset.Name									= 'Test Vehicle';
			objAsset.AssetType__c							= 'VN';
			objAsset.CurrencyIsoCode						= 'EUR';
			objAsset.AccountId								= objOwnerAccount.Id;
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
			objAppointment1.TECH_SBConfirmation__c			= false;

			WorkshopAppointment__c objAppointment2			= new WorkshopAppointment__c();
			objAppointment2.Name							= 'WAP0002';
			objAppointment2.Owner__c						= objOwnerAccount.Id;
			objAppointment2.Driver__c						= objOwnerAccount.Id;
			objAppointment2.Asset__c						= objAsset.Id;
			objAppointment2.AppointmentRepeatRepair__c		= true;
			objAppointment2.AppointmentStatus__c			= '5';
			objAppointment2.ReceptionDatetime__c			= System.today().addDays( -2 );
			objAppointment2.Workshop__c						= objUser.Contact.AccountId;
			objAppointment2.TECH_SBConfirmation__c			= false;

			WorkshopAppointment__c objAppointment3			= new WorkshopAppointment__c();
			objAppointment3.Name							= 'WAP0003';
			objAppointment3.Owner__c						= objOwnerAccount.Id;
			objAppointment3.Driver__c						= objOwnerAccount.Id;
			objAppointment3.Asset__c						= objAsset.Id;
			objAppointment3.AppointmentRepeatRepair__c		= true;
			objAppointment3.AppointmentStatus__c			= '5';
			objAppointment3.ReceptionDatetime__c			= System.today().addDays( -1 );
			objAppointment3.Workshop__c						= objUser.Contact.AccountId;
			objAppointment3.TECH_SBConfirmation__c			= false;
			
			insert new List<WorkshopAppointment__c>{ objAppointment1, objAppointment2, objAppointment3 };
		}
	}

	/******************************************************************************************************
	* @Method			: getAssetPropertiesTest
	* @Author			: Manuel Medina
	* @Created			: 08/07/2019
	* @Description		: Test for APB021_AfterSalesAppointmentCleanUp batch class through 
	*						APS021_AfterSalesAppointmentCleanUp schedule class.
	******************************************************************************************************/
	@isTest static void batch_APS021_AfterSalesAppointmentCleanUpTest(){
		Test.startTest();
			APS021_AfterSalesAppointmentCleanUp schCleanUp	= new APS021_AfterSalesAppointmentCleanUp();

			String strJobId									= System.schedule( 'Test Appointment Clean Up', CRON_EXP, schCleanUp );
			schCleanUp.execute( null );

			System.assertEquals( true, ![SELECT Id FROM WorkshopAppointment__c].isEmpty() );
		Test.stopTest();

		System.assertEquals( true, [SELECT Id FROM WorkshopAppointment__c].isEmpty() );
	}
}
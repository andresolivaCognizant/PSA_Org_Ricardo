/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			AfterSales
* Description:		AfterSalesSearchCountersController controller test class.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	2.0		2019-07-08		Manuel Medina (MM)		Test class refactoring.
*********************************************************************************************************/
@isTest 
public class AfterSalesSearchCountersControllerTest {
	
	/******************************************************************************************************
	* @Method			: setup
	* @Author			: Manuel Medina
	* @Created			: 08/07/2019
	* @Description		: Setup Method
	******************************************************************************************************/
	@testSetup static void setup() {
		Account objAccount											=  new Account(
																		FirstName			= 'Account FirstName',
																		LastName			= 'Account LastName',
																		Salutation			= '1',
																		PersonalEmail__pc	= 'b2c@test.com',
																		RecordTypeId		= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get( 'PersonAccount_B2C' ).getRecordTypeId()
																	);

		insert objAccount;
		
		Account objAccount2											=  new Account(
																		FirstName			= 'Account FirstName2',
																		LastName			= 'Account LastName2',
																		Salutation			= '1',
																		PersonalEmail__pc	= 'b2c2@test.com',
																		RecordTypeId		= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get( 'PersonAccount_B2C' ).getRecordTypeId()
																	);

		insert objAccount2;
		
		Account objDealer											=  new Account(
																		Name				= 'Dealer',
																		RecordTypeId		= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get( 'Account_DealerPartner' ).getRecordTypeId()
																	);

		insert objDealer;
		
		List<WorkshopAppointment__c> lstAppointments				= new List<WorkshopAppointment__c>();
		
		WorkshopAppointment__c objAppointment1						= new WorkshopAppointment__c();
		objAppointment1.Driver__c									= objAccount.Id;
		objAppointment1.Workshop__c									= null;
		objAppointment1.Brand__c									= null;
		objAppointment1.ReceptionDatetime__c						= System.today();
		objAppointment1.AppointmentStatus__c						= '1';
		objAppointment1.TECH_SBConfirmation__c						= true;
		
		WorkshopAppointment__c objAppointment2						= new WorkshopAppointment__c();
		objAppointment2.Driver__c									= objAccount.Id;
		objAppointment2.Workshop__c									= null;
		objAppointment2.Brand__c									= null;
		objAppointment2.ReceptionDatetime__c						= System.today();
		objAppointment2.AppointmentStatus__c						= '2';
		objAppointment2.TECH_SBConfirmation__c						= true;
		
		WorkshopAppointment__c objAppointment3						= new WorkshopAppointment__c();
		objAppointment3.Driver__c									= objAccount.Id;
		objAppointment3.Workshop__c									= null;
		objAppointment3.Brand__c									= null;
		objAppointment3.ReceptionDatetime__c						= System.today().addDays( 5 );
		objAppointment3.AppointmentStatus__c						= '2';
		objAppointment3.TECH_SBConfirmation__c						= true;
		
		WorkshopAppointment__c objAppointment4						= new WorkshopAppointment__c();
		objAppointment4.Driver__c									= objAccount.Id;
		objAppointment4.Workshop__c									= null;
		objAppointment4.Brand__c									= null;
		objAppointment4.ReceptionDatetime__c						= System.today();
		objAppointment4.AppointmentStatus__c						= '5';
		objAppointment4.TECH_SBConfirmation__c						= true;
		
		WorkshopAppointment__c objAppointment5						= new WorkshopAppointment__c();
		objAppointment5.Driver__c									= objAccount.Id;
		objAppointment5.Workshop__c									= null;
		objAppointment5.Brand__c									= null;
		objAppointment5.ReceptionDatetime__c						= System.today().addDays( 10 );
		objAppointment5.AppointmentStatus__c						= '5';
		objAppointment5.TECH_SBConfirmation__c						= true;
		
		WorkshopAppointment__c objAppointment6						= new WorkshopAppointment__c();
		objAppointment6.Driver__c									= objAccount2.Id;
		objAppointment6.Workshop__c									= null;
		objAppointment6.Brand__c									= null;
		objAppointment6.ReceptionDatetime__c						= System.today().addDays( 10 );
		objAppointment6.AppointmentStatus__c						= '2';
		objAppointment6.TECH_SBConfirmation__c						= true;
		
		lstAppointments.add( objAppointment1 );
		lstAppointments.add( objAppointment2 );
		lstAppointments.add( objAppointment3 );
		lstAppointments.add( objAppointment4 );
		lstAppointments.add( objAppointment5 );
		lstAppointments.add( objAppointment6 );
		insert lstAppointments;
		
		Consent__c objConsent1										= new Consent__c();
		objConsent1.CollectedEntityId__c							= null;
		objConsent1.Purpose__c										= 'Geolocation';
		objConsent1.Contact__c										= [SELECT Id
																		FROM Contact
																		WHERE AccountId =: objAccount.Id LIMIT 1
																	].Id;
		insert objConsent1;
	}
	
	/******************************************************************************************************
	* @Method			: getConsentsOutdatedTest
	* @Author			: Manuel Medina
	* @Created			: 08/07/2019
	* @Description		: Test for getConsentsOutdated method. This method also covers:
	*						- getAppointmentTotals
	*						- getFieldLabel
	******************************************************************************************************/
	@isTest static void getConsentsOutdatedTest(){
		Test.startTest();
			AfterSalesSearchCountersController.DataTable wrpData	= AfterSalesSearchCountersController.getConsentsOutdated();

			System.assertEquals( true, !wrpData.lstConsentsOutdated.isEmpty() );
		Test.stopTest();
	}
}
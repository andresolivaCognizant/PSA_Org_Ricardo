/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			AfterSales
* Description:		DMSCustomerDataController test class.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2018-06-19		Manuel Medina (MM)		Initial definition.
*********************************************************************************************************/
@isTest 
public class DMSCustomerDataControllerTest {
	
	@testSetup static void setup() {
		Account objAccount						= new Account(
													FirstName			= 'Account FirstName',
													LastName			= 'Account LastName',
													Salutation			= '1',
													PersonalEmail__pc	= 'b2c@test.com',
													RecordTypeId		= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get( 'PersonAccount_B2C' ).getRecordTypeId()
												);

		insert objAccount;
		
		Account objDealer						= new Account(
													Name				= 'Dealer',
													RecordTypeId		= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get( 'Account_DealerPartner' ).getRecordTypeId()
												);

		insert objDealer;
		
		AccountExtRef__c objAccountExt			= new AccountExtRef__c(
													ExternalId__c		= 'DMSTST001',
													Dealer__c			= objDealer.Id,
													Account__c			= objAccount.Id,
													System__c			= 'DMS'
												);
												
		insert objAccountExt;
	}
	
	@isTest static void testMethod1(){
		Account objAccount						= [SELECT Id
													FROM Account 
													WHERE RecordType.DeveloperName = 'PersonAccount_B2C'
												];
		
		DMSCustomerDataController.getDMSCustomerData( String.valueOf( objAccount.Id ) );
	}
    
    @isTest static void testMethod2(){
		Account objAccount						= [SELECT Id
													FROM Account 
													WHERE RecordType.DeveloperName = 'PersonAccount_B2C'
												];
		
		DMSCustomerDataController.getDMSData( String.valueOf( objAccount.Id ) );
	}
    
    @isTest static void testMethod3(){
			Account b2c = new Account(
                    FirstName               = 'Account Test 01',
                    LastName                = '01 LastName',
                    Salutation              = '1',
                    Country__c              = 'PL',
                    PersonalEmail__pc       = 'test01b2c@test.com',
                    CompanyActivityType__c  = '0',
                    AccountType__c          = '0',
                    BillingStreet           = 'Eduardo Barreiros 100',
                    BillingCity             = 'Madrid',
                    BillingCountry          = 'España',
                    BillingPostalCode       = '28041',
                    RecordTypeId            = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId()
                );
                Insert b2c;

                Order objOrder												= new Order();
                objOrder.OrderId__c											= '9941311';
                objOrder.SupplyOrderId__c									= 'ORDER2002';
                objOrder.OrderCreationDate__c								= System.today().addDays( -10 );
                objOrder.FleetCode__c										= 'FLEET202';
                objOrder.UseType__c											= '1';
                objOrder.AccountId											= b2c.Id;
                objOrder.RecordTypeId										= Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get( 'VNOrders' ).getRecordTypeId();
                objOrder.EffectiveDate										= System.today().addDays( 25 );
                objOrder.Status												= 'Draft';
                objOrder.CompletedSaleDate__c								= System.today().addMonths( -2 );
                Insert objOrder;

                Asset a = new Asset(
                    Name                = 'Test Vehicle 02',
                    AssetType__c        = 'VN',
                    CurrencyIsoCode     = 'EUR',
                    AccountId           = b2c.Id,
                    OrderId__c			= objOrder.Id
                );
                Insert a;

                List<AccountContactAssetRelation__c> lst = new List<AccountContactAssetRelation__c>{
                    new AccountContactAssetRelation__c(
                        AccountId__c    = b2c.Id,
                        AssetId__c      = a.Id,
                        AccountRole__c  = 'Keeper'
                    ),
                    new AccountContactAssetRelation__c(
                        AccountId__c    = b2c.Id,
                        AssetId__c      = a.Id,
                        AccountRole__c  = 'Driver'
                    )
                };
                Insert lst;
                WorkshopAppointment__c w = new WorkshopAppointment__c(
                    Driver__c = b2c.Id,
                    Asset__c  = a.Id,
                    TECH_AccountAssetRelation__c = lst.get(0).Id
                );
            
            	insert w;
			DMSCustomerDataController.getDMSCustomerData( String.valueOf( w.Id ) );
	} 
}
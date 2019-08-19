/******************************************************************************************
* Name: 			dmsCallOutsControllerTest
* Author: 			Ruben Fernandez
* Description:		Test class for dmsCallOutsController class
* 
* Changes (Version)
* -----------------------------------------------------------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2019-02-24		Ruben Fernandez (RF)	Initial definition.
*           1.1		2019-02-27		Ruben Fernandez (RF)    Covering all methods. Cover: 100%
*******************************************************************************************/
@isTest 
public class dmsCallOutsControllerTest {
    
    @testSetup static void setup() {

        List<String> lstActivities   =   new List<String>{'VN'};
		List<Contact> lstContsA      =   TestDataFactoryUtil.createPartnerUser(2, 1, 'Dealer', '133225511','1237770', 'EXTKEY0002','AP','CL', 'J',lstActivities,true);   		
        List<User> lstUsers1         =   TestDataFactoryUtil.createUser(lstContsA,'Sales_Manager','Partner','Manager');
        Insert lstUsers1;
        
		Account b2c = new Account(
			FirstName               = 'Account FirstName',
			LastName                = 'Account LastName',
			Salutation              = '1',
			Country__c              = 'PL',
			PersonalEmail__pc       = 'b2c@test.com',
			CompanyActivityType__c  = '0',
        	AccountType__c          = '0',
			RecordTypeId            = AccountConstants.ACCOUNT_RT_B2C
		);
		Insert b2c;
		
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
		Insert objOrder;

		Asset a = new Asset(
			Name                                                    = 'Test Vehicle',
			AssetType__c                                            = 'VN',
			CurrencyIsoCode                                         = 'EUR',
			AccountId                                               = b2c.Id,
			OrderId__c			                                    = objOrder.Id
		);
		Insert a;

		List<AccountContactAssetRelation__c> lst                    = new List<AccountContactAssetRelation__c>{
			new AccountContactAssetRelation__c(
				AccountId__c                                        = b2c.Id,
				AssetId__c                                          = a.Id,
				AccountRole__c                                      = 'Keeper'
			),
			new AccountContactAssetRelation__c(
				AccountId__c                                        = b2c.Id,
				AssetId__c                                          = a.Id,
				AccountRole__c                                      = 'Driver'
			)
		};
 		Account objDealer		                                    = new Account();
        objDealer.Country__c	                                    = 'PL';
        objDealer.Name			                                    = 'Dealer';
        objDealer.RecordTypeId	                                    = AccountConstants.ACCOUNT_RT_DEALER;
        Insert objDealer;
        
        Opportunity objFleetRequest									= new Opportunity();
        objFleetRequest.OpportunityExtId__c							= 'FLEETTST0001';
        objFleetRequest.Name										= 'CORS TST 25112018-1';
        objFleetRequest.StageName									= 'FR1';
        objFleetRequest.FleetRequestDate__c							= System.now();
        objFleetRequest.AccountId									= b2c.Id;
        objFleetRequest.FleetCategory__c							= '17';
        objFleetRequest.CloseDate									= System.today().addDays( 15 );
        objFleetRequest.OrderStartDate__c							= System.today().addDays( 15 );
        objFleetRequest.OrderEndDate__c								= System.today().addDays( 20 );
        objFleetRequest.RecordTypeId								= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get( 'FleetRequestOpportunity' ).getRecordTypeId();
        objFleetRequest.Country__c									= 'PL';
        Insert objFleetRequest;
        
        SBQQ__Quote__c objFleetQuote								= new SBQQ__Quote__c();
        objFleetQuote.SBQQ__Key__c									= 'FLEETQUOTETST001';
        objFleetQuote.RecordTypeId									= Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get( 'FleetRequestQuote' ).getRecordTypeId();
        objFleetQuote.SBQQ__Account__c								= b2c.Id;
        objFleetQuote.SBQQ__Status__c								= 'FR1';
        objFleetQuote.SBQQ__Partner__c								= objDealer.Id;
        objFleetQuote.Agent__c										= objDealer.Id;
        objFleetQuote.SBQQ__PrimaryContact__c						= [SELECT Id FROM Contact WHERE AccountId =: b2c.Id LIMIT 1].Id;
        objFleetQuote.Driver__c										= b2c.Id;
        objFleetQuote.SBQQ__Opportunity2__c							= objFleetRequest.Id;
        objFleetQuote.LCDV16__c										= 'LCDV001';
        objFleetQuote.ColorCode__c									= 'CC001';
        objFleetQuote.InteriorTrimCode__c							= 'ITC001';
        objFleetQuote.VersionDescription__c							= 'test';
        objFleetQuote.InteriorTrimDescription__c					= 'test';
        objFleetQuote.OptionCodes__c								= 'Opt 1';
        objFleetQuote.BasePrice__c									= 45;
        objFleetQuote.TotalOptions__c								= 87;
        objFleetQuote.ProductionYear__c								= 2017;
        objFleetQuote.SubsidiaryPartPercentage__c					= 2;
        objFleetQuote.DealerPartPercentage__c						= 6;
        objFleetQuote.OPV_LinkToOPVOffer__c							= 'https://psacallout.com/test';
        
        Insert objFleetQuote;
		Insert lst;
        
	}
	 /* Testing Client to Server call */
	@isTest static void CORSCalloutTest(){
        AccountContactAssetRelation__c aca = [SELECT Id,AccountId__c,AssetId__c FROM AccountContactAssetRelation__c LIMIT 1];
        List<Account> auxAcc 		= [SELECT Id,CommunicationMode__c FROM Account Where Name like 'Dealer_Account_%' AND CommunicationMode__c = '1'];
        User usr					= [SELECT Id, Contact.AccountId,Contact.Account.CommunicationMode__c FROM User WHERE Contact.AccountId =: auxAcc.get(0).Id LIMIT 1];
        
        System.runAs(usr) {
            Test.startTest();
                dmsCallOutsController.DMSWakeUpbyCORS(aca.AccountId__c,aca.AssetId__c );
            Test.stopTest();
        }
        List<DMSWebhook__c> lstPushT = [SELECT Id FROM DMSWebhook__c];
        System.assertEquals(true,lstPushT.isEmpty());
	}
    /* Testing Server to Server call*/
	@isTest static void CoreSERVERCalloutTest(){
        List<Account> auxAcc 				= [SELECT Id,CommunicationMode__c FROM Account Where Name like 'Dealer_Account_%' AND CommunicationMode__c = '2'];
		system.debug('User End Size:' + auxAcc.size());       
        
        Account acc 				= [SELECT Id FROM Account LIMIT 1];
        Asset ast 					= [SELECT Id,AccountId FROM Asset LIMIT 1];
        User usr					= [SELECT Id, Contact.AccountId,Contact.Account.CommunicationMode__c FROM User WHERE Contact.AccountId =: auxAcc.get(0).Id LIMIT 1];
     		
        System.runAs(usr) {
            Test.startTest();
                dmsCallOutsController.DMSWakeUpbyServer(acc.Id);
            	dmsCallOutsController.DMSWakeUpbyServer(ast.Id);
        	Test.stopTest(); 
        }
        List<DMSWebhook__c> lstPushT = [SELECT Id FROM DMSWebhook__c];
        System.assertEquals(false,lstPushT.isEmpty());
	}
    /* Testing Server to Server call*/
	@isTest static void SalesSERVERCalloutTest(){
        List<Account> auxAcc 				= [SELECT Id,CommunicationMode__c FROM Account Where Name like 'Dealer_Account_%' AND CommunicationMode__c = '2'];
		system.debug('User End Size:' + auxAcc.size());
        
        SBQQ__Quote__c cpq 			= [SELECT Id, SBQQ__Account__c FROM SBQQ__Quote__c LIMIT 1];
        Order ord 					= [SELECT Id,AccountId FROM Order LIMIT 1];
        User usr					= [SELECT Id, Contact.AccountId,Contact.Account.CommunicationMode__c FROM User WHERE Contact.AccountId =: auxAcc.get(0).Id LIMIT 1];
     		
        System.runAs(usr) {
            Test.startTest();
            	dmsCallOutsController.DMSWakeUpbyServer(cpq.Id);
            	dmsCallOutsController.DMSWakeUpbyServer(ord.Id);
        	Test.stopTest(); 
        }
        List<DMSWebhook__c> lstPushT = [SELECT Id FROM DMSWebhook__c];
        System.assertEquals(true,lstPushT.isEmpty());
	}
    /* Testing Server to Server call*/
	@isTest static void RelSERVERCalloutTest(){
        List<Account> auxAcc 				= [SELECT Id,CommunicationMode__c FROM Account Where Name like 'Dealer_Account_%' AND CommunicationMode__c = '2'];
		system.debug('User End Size:' + auxAcc.size());       
        
        AccountContactAssetRelation__c aca = [SELECT Id,AccountId__c,AssetId__c FROM AccountContactAssetRelation__c LIMIT 1];
        User usr					= [SELECT Id, Contact.AccountId,Contact.Account.CommunicationMode__c FROM User WHERE Contact.AccountId =: auxAcc.get(0).Id LIMIT 1];
     		
        System.runAs(usr) {
            Test.startTest();
            	dmsCallOutsController.DMSWakeUpbyServer(aca.Id);
        	Test.stopTest(); 
        }
        List<DMSWebhook__c> lstPushT = [SELECT Id FROM DMSWebhook__c];
        System.assertEquals(true,lstPushT.isEmpty());
	}
    /*Negative Case. Try - Catch */
    @isTest static void NegativeSERVERCalloutTest(){ 
        List<Account> auxAcc 				= [SELECT Id,CommunicationMode__c FROM Account Where Name like 'Dealer_Account_%' AND CommunicationMode__c = '2'];
        User usr							= [SELECT Id, Contact.AccountId,Contact.Account.CommunicationMode__c FROM User WHERE Contact.AccountId =: auxAcc.get(0).Id LIMIT 1];	
        System.runAs(usr) {
            Test.startTest();
            	dmsCallOutsController.DMSWakeUpbyServer('999');
        	Test.stopTest();  
        }
        List<DMSWebhook__c> lstPushT = [SELECT Id FROM DMSWebhook__c];
        System.assertEquals(true,lstPushT.isEmpty());
	}
    
}
/**
	*   @Class : ChangeAccountStatusBatchTest
	*
	*   @Author         :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
	*   @Created        :   9 Mar 2019
	*   @Description    :   Test Class of ChangeAccountStatusBatch
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer                Date                     Description    
	*      Carmen Hernandez         9/03/2019                Creation.      
	* 	   Carmen Hernandez		    5/14/2019				 #C1STAGILE-9723: Apex CPU time limit exceeded-> Refactored Query
	* 	   Nerea Leguinazabal	    07/11/2019				 #C1STAGILE-16994: Use TestDataFactoryUtil for Data creation
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest(SeeAllData=false)
public class ChangeAccountStatusBatchTest {
	
	private final static Id RT_OPV_ORDER_FORM_VN        = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('OPVOrderFormVN').getRecordTypeId();
	private final static Id RT_ACCOUNT_PERSONB2C        = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId();


	@testSetup static void setupCommonData(){

		//New Account
		Account acc = TestDataFactoryUtil.createAccountContact(1, 'B2C').get(0);
		acc.country__c = 'FR';
		acc.CompanyActivityType__c = '0';
		acc.AccountType__c = '0';
		update acc;
		
		//New Opportunity
		Opportunity opp         =   new Opportunity (
			Name                =   'Test',
			StageName           =   'FR1',
			AccountId           =   acc.Id,
			CloseDate           =   System.today(),
			Activity__c         =   'VN',
			RecordTypeId        =   Schema.SObjectType.OPPORTUNITY.getRecordTypeInfosByDeveloperName().get('FleetRequestOpportunity').getRecordTypeId(),
			Country__c          =   'ES',
			Segment__c			=	'27',
			FundingForm__c      =   '1'
		);
		insert opp;
		
		//New Order
		Order ord = new Order(
			AccountId = acc.Id,
			EffectiveDate = System.today(),
			Status = '0',
			OrderId__c = '123456789',
			OpportunityId = opp.Id
		);
		insert ord;

		//New Quote
		SBQQ__Quote__C quotes = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
                    'SBQQ__Account__c'  => acc.Id,
                    'SBQQ__Status__c' => '6',
                    'RecordTypeId'  => RT_OPV_ORDER_FORM_VN
                } ,true);
		//SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Account__c = acc.Id, SBQQ__Status__c = '6', RecordTypeId = RT_OPV_ORDER_FORM_VN);        
		//insert quote;
		
		//New Asset
		Asset asse = new Asset(
			Name                = 'Test Vehicle',
			AssetType__c        = 'VN',
			CurrencyIsoCode     = 'EUR',
			AccountId           = acc.Id
		);
		insert asse;

	}
	
	@isTest static void testExecuteMassiveBatchAsset(){
		test.startTest();
		Database.executeBatch(new ChangeAccountStatusBatch('AccAssetRel'), 200);
		test.stopTest();        
		
	}    
	
	@isTest static void testExecuteMassiveBatchOrder(){
		test.startTest();
		Database.executeBatch(new ChangeAccountStatusBatch('Order'), 200);
		test.stopTest();        
	} 
	 
	@isTest static void testExecuteMassiveBatchOrderForm(){        
		test.startTest();
		Database.executeBatch(new ChangeAccountStatusBatch('OrderForm'), 200);
		test.stopTest();        
	}     
	
	@isTest static void testExecuteMassiveBatchDefault(){        
		test.startTest();
		Database.executeBatch(new ChangeAccountStatusBatch(), 200);
		test.stopTest();        
	}     
	
	@isTest static void testExecuteMassiveBatchError(){        
		test.startTest();
		Database.executeBatch(new ChangeAccountStatusBatch('ErrorString'), 200);
		test.stopTest();        
	}    

}
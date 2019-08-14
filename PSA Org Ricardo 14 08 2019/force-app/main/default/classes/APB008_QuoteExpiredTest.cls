/**
	*   @Class 			: APB008_QuoteExpiredTest
	*   @Author         : Pedro Párraga
	*   @Created        : 10 Juli 2019
	*   @Description    : Test for APB008_QuoteExpired
	*
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Pedro Párraga			11/06/2019				 Creation.
	* 	   Nerea Leguinazabal	    07/11/2019				 #C1STAGILE-16994: Use TestDataFactoryUtil for Data creation		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
private class APB008_QuoteExpiredTest {

	@testSetup static void setup(){
        Account acc = new Account(
            Name            = 'Test Dealer 1',
            RecordTypeId    = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account_DealerPartner').getRecordTypeId()
        );

        insert acc;

	   	Opportunity opp = new Opportunity(
	   		CloseDate = system.today()+180, 
	   		Name = 'Test', 
	   		StageName = '6', 
	   		Country__c = 'ES',
	   		AccountId = acc.Id
	   	);

	   	insert opp;

		SBQQ__Quote__C quote = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
                    'SBQQ__ExpirationDate__c'  => System.Today()-1,
                    'SBQQ__Status__c' => '2',
                    'SBQQ__Account__c'  => acc.Id
            } ,true);

		SBQQ__Quote__C quote2 = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
                    'SBQQ__ExpirationDate__c'  => System.Today()+1,
                    'SBQQ__Status__c' => '2',
                    'SBQQ__Account__c'  => acc.Id,
					'SBQQ__Opportunity2__c' => opp.Id
            } ,true);
        		
	}
	
	@isTest static void APB008_QuoteExpired() {
        Test.startTest();
        	APB008_QuoteExpired b = new APB008_QuoteExpired(); 
            Database.executeBatch(b,60); 
            SBQQ__Quote__c quote = [SELECT Id, SBQQ__Status__c FROM SBQQ__Quote__c  WHERE SBQQ__Opportunity2__c != null LIMIT 1];
            System.assertEquals(quote.SBQQ__Status__c, '2');
        Test.stopTest();
	}	
}
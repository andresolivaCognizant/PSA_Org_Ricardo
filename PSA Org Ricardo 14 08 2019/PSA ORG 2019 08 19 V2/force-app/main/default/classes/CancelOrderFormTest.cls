/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class CancelOrderFormTest {
    
    static testMethod void myUnitTest1() {
	 	Id rType = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('CPQ_Order_Form').getRecordTypeId();
    		 	
	 	Opportunity opp = new Opportunity(CloseDate = system.today()+180, Name = 'Test 4', StageName = '2', FundingForm__c='1', Country__c='PL');
	   	insert opp;
        
        Account acc2 = new Account(Name = 'Test'); 
	   	insert acc2;
	   	
		SBQQ__Quote__C oQuoteCPQ = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
			'ReservedVehicle__c'  		=> false,
			'SBQQ__Opportunity2__c' 	=> opp.Id,
			'SBQQ__Account__c'  		=> acc2.id,
			'SBQQ__Status__c'			=> '3',
			'SBQQ__ExpirationDate__c' 	=> System.today().addDays(+1)

		} ,true);
    	
		SBQQ__Quote__C oQuote = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
			'QuotesWithOrderForms__c'  	=> oQuoteCPQ.id,
			'ReservedVehicle__c'		=> false,
			'RecordTypeId' 				=> rType,
			'SBQQ__Opportunity2__c'  	=> opp.Id,
			'SBQQ__Account__c'			=> acc2.id,
			'SBQQ__Status__c' 			=> '1'

		} ,true);
       

		oQuoteCPQ = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
			'ReservedVehicle__c'		=> false,
			'SBQQ__Opportunity2__c'  	=> opp.Id,
			'SBQQ__Account__c'			=> acc2.id,
			'SBQQ__Status__c' 			=> '3',
			'SBQQ__ExpirationDate__c'	=>  System.today().addDays(-1)

		} ,true);


		oQuote = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
			'QuotesWithOrderForms__c'	=> oQuoteCPQ.id,
			'ReservedVehicle__c'		=> false,
			'RecordTypeId'				=> rType,
			'SBQQ__Opportunity2__c'  	=> opp.Id,
			'SBQQ__Account__c'			=> acc2.id,
			'SBQQ__Status__c' 			=> '1'
		} ,true);
       
    	Account acc = new Account(Name = 'Test'); 
	   	insert acc;
    	
    	Product2 prd = new Product2(CDC__c = 'TestId 1', Name = 'TestVeh', StockDealer__c = ' ', StockBourse__c = ' ', StockCentral__c = 'X', Dealer_Group__c = acc.ownerId, Stock__c = true,Family = 'Version',
    								IsActive = true, SBQQ__Component__c = false, CurrencyIsoCode = 'CLP', Reserved__c = true, ProductCode = 'PC1', ColorCode__c = 'CC1', InteriorTrimCode__c = 'IT1', OptionsCode__c = 'OC1');
    	insert prd;
    	    	
    	OrderFormLine__c qLine = new OrderFormLine__c(Product__c = prd.Id, OrderForm__c = oQuote.Id);
    	insert qLine;
    	
        SBQQ__Quote__c quoteToUpdate = [Select id,SBQQ__Status__c,RecordTypeId,QuotesWithOrderForms__c from SBQQ__Quote__c where id = :oQuote.id limit 1];
        quoteToUpdate.SBQQ__Status__c= '7';
        
    	
    	// Perform test for Product Stock = false
        Test.startTest();
		update quoteToUpdate;
		CancelOrderForm.mainFunction(new List<SBQQ__Quote__c>{quoteToUpdate}, new map<id,SBQQ__Quote__c>{oQuote.id => oQuote});
        Test.stopTest();
    }


}
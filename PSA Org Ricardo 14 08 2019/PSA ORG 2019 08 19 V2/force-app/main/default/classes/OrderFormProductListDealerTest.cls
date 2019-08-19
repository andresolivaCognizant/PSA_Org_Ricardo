/**
	*   @Class : OrderFormFreeSetProductTest
	*
	*   @Author         :  
	*   @Created        :   
	*   @Description    :   
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer                Date                     Description    
	*      	-----					----					 Creation.
	*	   Nerea Leguinazabal	    07/11/2019				 #C1STAGILE-16994: Use TestDataFactoryUtil for Data creation      
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
private class OrderFormProductListDealerTest {
    
    static testMethod void myUnitTest() {
        RecordType rType = [SELECT Id FROM RecordType WHERE Name like '%OPV%' AND SObjectType = 'SBQQ__Quote__c' LIMIT 1];
        
    		 	
	 	Opportunity opp = new Opportunity(CloseDate = system.today()+180, Name = 'Test 4', StageName = '2', FundingForm__c='1', Country__c = 'ES');
	   	insert opp;
        
        Account acc2 = new Account(Name = 'Test'); 
	   	insert acc2;
	   	
        SBQQ__Quote__C quote4 = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
                'ReservedVehicle__c'  	=> false,
				'RecordTypeId'			=> rType.Id,
				'SBQQ__Opportunity2__c'	=> opp.Id,
				'SBQQ__Account__c'		=> acc2.id
                } ,true); 
		
    	Account acc = new Account(Name = 'Test'); 
	   	insert acc;
    	
    	Product2 prd = new Product2(CDC__c = 'TestId 1', Name = 'TestVeh', StockDealer__c = ' ', StockBourse__c = ' ', StockCentral__c = 'X', Dealer_Group__c = acc.ownerId, Stock__c = true,
    								IsActive = true, SBQQ__Component__c = false, CurrencyIsoCode = 'CLP', Reserved__c = true, ProductCode = 'PC1', ColorCode__c = 'CC1', InteriorTrimCode__c = 'IT1', OptionsCode__c = 'OC1');
    	insert prd;
    	    	
    	SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Product__c = prd.Id, SBQQ__Quote__c = quote4.Id);
    	insert qLine;
    	
        SBQQ__Quote__C quote4b = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
                'ReservedVehicle__c'  	=> false,
				'RecordTypeId'			=> rType.Id,
				'SBQQ__Opportunity2__c'	=> opp.Id,
				'SBQQ__Account__c'		=> acc2.id
                } ,true); 
		
    	qLine = new SBQQ__QuoteLine__c(SBQQ__Product__c = prd.Id, SBQQ__Quote__c = quote4b.Id);
    	insert qLine;
    	
    	prd = new Product2(CDC__c = 'TestId 2', Name = 'TestVeh', StockDealer__c = ' ', StockBourse__c = ' ', StockCentral__c = 'X', Dealer_Group__c = acc.ownerId, Stock__c = false,
    								IsActive = true, SBQQ__Component__c = false, CurrencyIsoCode = 'CLP', Reserved__c = true, ProductCode = 'PC1', ColorCode__c = 'CC1', InteriorTrimCode__c = 'IT1', OptionsCode__c = 'OC1');
    	insert prd;
    	   	 
        Test.startTest();
            List<OrderFormProductListDealer.ObjectRequestListProduct> lWrActivity 	= new List<OrderFormProductListDealer.ObjectRequestListProduct>();
        	OrderFormProductListDealer.ObjectRequestListProduct 		wrp 			= new OrderFormProductListDealer.ObjectRequestListProduct();
	        wrp.idQuote 	= quote4.Id;
        	wrp.idProduct 	= prd.Id;
        	lWrActivity.add(wrp);
			OrderFormProductListDealer.handleRecords(lWrActivity); 
        Test.stopTest();
        
    }

}
/**
	*   @Class : OrderFormCreateTest
	*
	*   @Author         :  
	*   @Created        :   
	*   @Description    :   
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer                Date                     Description    
	*      	-----					----					 Creation.
	*		Nerea Leguinazabal	    07/11/2019				 #C1STAGILE-16994: Use TestDataFactoryUtil for Data creation      
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
private class OrderFormCreateTest {
    
    static testMethod void myUnitTest1() {
	 	RecordType rType = [SELECT Id FROM RecordType WHERE Name like '%OPV%' LIMIT 1];
    		 	
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
    	   	 
    	// Perform test for Product Stock = false
        Test.startTest();
            List<OrderFormCreate.ObjectRequest> lWrActivity 	= new List<OrderFormCreate.ObjectRequest>();
        	OrderFormCreate.ObjectRequest 		wrp 			= new OrderFormCreate.ObjectRequest();
	        wrp.recordId 	= quote4.Id;
        	lWrActivity.add(wrp);
			OrderFormCreate.handleRecords(lWrActivity); 
        Test.stopTest();
    }
    
    static testMethod void myUnitTest2() {
	 	RecordType rType = [SELECT Id FROM RecordType WHERE Name like '%OPV%' LIMIT 1];
	 	
	 	Opportunity opp = new Opportunity(CloseDate = system.today()+180, Name = 'Test 1', StageName = '2',FundingForm__c='1', Country__c = 'ES');
	   	insert opp;
        
        Account acc2 = new Account(Name = 'Test'); 
	   	insert acc2;
    	
    	SBQQ__Quote__C quote1 = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
			'ReservedVehicle__c'  	=> false,
			'RecordTypeId'			=> rType.Id,
			'SBQQ__Opportunity2__c'	=> opp.Id,
			'SBQQ__Account__c'		=> acc2.id
			} ,true);
		
    		    	
    	Account acc = new Account(Name = 'Test'); 
	   	insert acc;
    	
    	Product2 prd = new Product2(CDC__c = 'TestId 1', Name = 'TestVeh', StockDealer__c = ' ', StockBourse__c = ' ', StockCentral__c = 'X', Dealer_Group__c = acc.ownerId, Stock__c = true,
    								IsActive = true, SBQQ__Component__c = false, CurrencyIsoCode = 'CLP', Reserved__c = true);
    	insert prd;
    	
    	SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Product__c = prd.Id, SBQQ__Quote__c = quote1.Id);
    	insert qLine;
    	 
    	// Perform test for Product Stock and Reserved Check = true and Reserved Quote = true
        Test.startTest();
            List<OrderFormCreate.ObjectRequest> lWrActivity 	= new List<OrderFormCreate.ObjectRequest>();
        	OrderFormCreate.ObjectRequest 		wrp 			= new OrderFormCreate.ObjectRequest();
	        wrp.recordId 	= quote1.Id;
        	lWrActivity.add(wrp);
			OrderFormCreate.handleRecords(lWrActivity); 
        Test.stopTest();
    }
    
    static testMethod void myUnitTest3() {  	
    	RecordType rType = [SELECT Id FROM RecordType WHERE Name like '%CPQ%' LIMIT 1];
    		 	
	 	Opportunity opp = new Opportunity(CloseDate = system.today()+180, Name = 'Test 2', StageName = '2',FundingForm__c='1', Country__c = 'ES');
	   	insert opp;
        
        Account acc2 = new Account(Name = 'Test'); 
	   	insert acc2;
    	
    	SBQQ__Quote__C quote2 = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
			'ReservedVehicle__c'  	=> true,
			'RecordTypeId'			=> rType.Id,
			'SBQQ__Opportunity2__c'	=> opp.Id,
			'SBQQ__Account__c'		=> acc2.id
			} ,true);
    		    	
    	Account acc = new Account(Name = 'Test'); 
	   	insert acc;
    	
    	Product2 prd = new Product2(CDC__c = 'TestId 1', Name = 'TestVeh', StockDealer__c = ' ', StockBourse__c = ' ', StockCentral__c = 'X', Dealer_Group__c = acc.ownerId, Stock__c = true,
    								IsActive = true, SBQQ__Component__c = false, CurrencyIsoCode = 'CLP', Reserved__c = true);
    	insert prd; 
    	
    	SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Product__c = prd.Id, SBQQ__Quote__c = quote2.Id);
    	insert qLine;
    	 
    	// Perform test for Product Stock and Reserved Check = true and Reserved Quote = false
        Test.startTest();
            List<OrderFormCreate.ObjectRequest> lWrActivity 	= new List<OrderFormCreate.ObjectRequest>();
        	OrderFormCreate.ObjectRequest 		wrp 			= new OrderFormCreate.ObjectRequest();
	        wrp.recordId 	= quote2.Id;
        	lWrActivity.add(wrp);
			OrderFormCreate.handleRecords(lWrActivity); 
        Test.stopTest();
    }
    
    static testMethod void myUnitTest4() {
	 	RecordType rType = [SELECT Id FROM RecordType WHERE Name like '%OPV%' LIMIT 1];
    		 	
	 	Opportunity opp = new Opportunity(CloseDate = system.today()+180, Name = 'Test 3', StageName = '2',FundingForm__c='1', Country__c = 'ES');
	   	insert opp;
        
        Account acc2 = new Account(Name = 'Test'); 
	   	insert acc2;
	   	
    	SBQQ__Quote__C quote3 = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
			'ReservedVehicle__c'  	=> false,
			'RecordTypeId'			=> rType.Id,
			'SBQQ__Opportunity2__c'	=> opp.Id,
			'SBQQ__Account__c'		=> acc2.id
			} ,true);
    		    	
    		    	
    	Account acc = new Account(Name = 'Test'); 
	   	insert acc;
    	
    	Product2 prd = new Product2(CDC__c = 'TestId 1', Name = 'TestVeh', StockDealer__c = ' ', StockBourse__c = ' ', StockCentral__c = 'X', Dealer_Group__c = acc.ownerId, Stock__c = true,
    								IsActive = true, SBQQ__Component__c = false, CurrencyIsoCode = 'CLP', Reserved__c = false);
    	insert prd;
    	 
    	// Perform test for Product Stock = true and Reserved Check = false and Reserved Quote = false
        Test.startTest();
            List<OrderFormCreate.ObjectRequest> lWrActivity 	= new List<OrderFormCreate.ObjectRequest>();
        	OrderFormCreate.ObjectRequest 		wrp 			= new OrderFormCreate.ObjectRequest();
	        wrp.recordId 	= quote3.Id;
        	lWrActivity.add(wrp);
			OrderFormCreate.handleRecords(lWrActivity); 
        Test.stopTest();
    }  
    
    static testMethod void myUnitTest5() {
	 	RecordType rType = [SELECT Id FROM RecordType WHERE Name like '%OPV%' LIMIT 1];
    		 	
	 	Opportunity opp = new Opportunity(CloseDate = system.today()+180, Name = 'Test 5', StageName = '2',FundingForm__c='1', Country__c = 'ES');
	   	insert opp;
        
        Account acc2 = new Account(Name = 'Test'); 
	   	insert acc2;
	   	
		SBQQ__Quote__C quote5 = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
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
    	
    	prd = new Product2(CDC__c = 'TestId FreeSet', Name = 'TestVeh', StockDealer__c = ' ', StockBourse__c = ' ', StockCentral__c = 'X', Dealer_Group__c = acc.ownerId, Stock__c = false,
    								IsActive = true, SBQQ__Component__c = false, CurrencyIsoCode = 'CLP', Reserved__c = true, ProductCode = 'PC1', ColorCode__c = 'CC1', InteriorTrimCode__c = 'IT1', OptionsCode__c = 'OC1');
    	insert prd;
    	
    	SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Product__c = prd.Id, SBQQ__Quote__c = quote5.Id);
    	insert qLine;
    		 	
	 	opp = new Opportunity(CloseDate = system.today()+180, Name = 'Test 5b', StageName = '2',FundingForm__c='1', Country__c = 'ES');
	   	insert opp;
	   	
    	
		quote5 = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
			'ReservedVehicle__c'  	=> true,
			'RecordTypeId'			=> rType.Id,
			'SBQQ__Opportunity2__c'	=> opp.Id,
			'SBQQ__Account__c'		=> acc2.id
			} ,true);
    	
    	qLine = new SBQQ__QuoteLine__c(SBQQ__Product__c = prd.Id, SBQQ__Quote__c = quote5.Id);
    	insert qLine;
    	 
    	// Perform test for Product Stock and Reserved Check = true and Reserved Quote = true
        Test.startTest();
            List<OrderFormCreate.ObjectRequest> lWrActivity 	= new List<OrderFormCreate.ObjectRequest>();
        	OrderFormCreate.ObjectRequest 		wrp 			= new OrderFormCreate.ObjectRequest();
	        wrp.recordId 	= quote5.Id;
        	lWrActivity.add(wrp);
			OrderFormCreate.handleRecords(lWrActivity); 
        Test.stopTest();
    }

    static testMethod void myUnitTest6() {
	 	RecordType rType = [SELECT Id FROM RecordType WHERE Name like '%OPV%' LIMIT 1];
    		 	
	 	Opportunity opp = new Opportunity(CloseDate = system.today()+180, Name = 'Test 4', StageName = '2',FundingForm__c='1', Country__c = 'ES');
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
			'ReservedVehicle__c'  	=> true,
			'RecordTypeId'			=> rType.Id,
			'SBQQ__Opportunity2__c'	=> opp.Id,
			'SBQQ__Account__c'		=> acc2.id
			} ,true);
    	
    	qLine = new SBQQ__QuoteLine__c(SBQQ__Product__c = prd.Id, SBQQ__Quote__c = quote4b.Id);
    	insert qLine;
    	   	 
    	// Perform test for Product Stock = false
        Test.startTest();
            List<OrderFormCreate.ObjectRequest> lWrActivity 	= new List<OrderFormCreate.ObjectRequest>();
        	OrderFormCreate.ObjectRequest 		wrp 			= new OrderFormCreate.ObjectRequest();
	        wrp.recordId 	= quote4.Id;
        	lWrActivity.add(wrp);
			OrderFormCreate.handleRecords(lWrActivity); 
        Test.stopTest();
    }
    
	static testMethod void myUnitTest7() {
	 	RecordType rType = [SELECT Id, Name FROM RecordType WHERE Name like '%OPV%' LIMIT 1];

		List<SBQQ__QuoteLine__c> qLines = new List<SBQQ__QuoteLine__c>();
		List<Id> lstRecords = new List<Id>();
    		 	
	 	Opportunity opp = new Opportunity(CloseDate = system.today()+180, Name = 'Test 4', StageName = '2',FundingForm__c='1', Country__c = 'ES');
	   	insert opp;
        
        Account acc2 = new Account(Name = 'Test'); 
	   	insert acc2;
	   	
    	SBQQ__Quote__C quote4 = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
			'ReservedVehicle__c'  	=> false,
			'RecordTypeId'			=> rType.Id,
			'SBQQ__Opportunity2__c'	=> opp.Id,
			'SBQQ__Account__c'		=> acc2.id
			} ,true);
		quote4.RecordType = rType;
		quote4.SBQQ__Opportunity2__r = opp;
		quote4.SBQQ__Account__r = acc2;
		lstRecords.add(quote4.Id);

		

    	Account acc = new Account(Name = 'Test'); 
	   	insert acc;
    	
    	Product2 prd = new Product2(CDC__c = 'TestId 1', Name = 'TestVeh', StockDealer__c = ' ', StockBourse__c = ' ', StockCentral__c = 'X', Dealer_Group__c = acc.ownerId, Stock__c = true,
    								IsActive = true, SBQQ__Component__c = false, CurrencyIsoCode = 'CLP', Reserved__c = true, ProductCode = 'PC1', ColorCode__c = 'CC1', InteriorTrimCode__c = 'IT1', OptionsCode__c = 'OC1');
    	insert prd;
    	    	
    	SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Product__c = prd.Id, SBQQ__Quote__c = quote4.Id);
    	insert qLine;
		qLine.SBQQ__Product__r = prd;
		qLine.SBQQ__Quote__r = quote4;
		qLines.add(qLine);
    	
    	SBQQ__Quote__C quote4b = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
			'ReservedVehicle__c'  	=> true,
			'RecordTypeId'			=> rType.Id,
			'SBQQ__Opportunity2__c'	=> opp.Id,
			'SBQQ__Account__c'		=> acc2.id
			} ,true);
		quote4b.RecordType = rType;
		quote4b.SBQQ__Opportunity2__r = opp;
		quote4b.SBQQ__Account__r = acc2;
		lstRecords.add(quote4b.Id);
    	
    	qLine = new SBQQ__QuoteLine__c(SBQQ__Product__c = prd.Id, SBQQ__Quote__c = quote4b.Id);
    	insert qLine;
		qLine.SBQQ__Product__r = prd;
		qLine.SBQQ__Quote__r = quote4b;
		qLines.add(qLine);
    	   	 
    	// Perform test for Product Stock = false
        Test.startTest();
			OrderFormCreate.cloneFreeSetPrd(qLines, lstRecords, 1); 
        Test.stopTest();
    }

}
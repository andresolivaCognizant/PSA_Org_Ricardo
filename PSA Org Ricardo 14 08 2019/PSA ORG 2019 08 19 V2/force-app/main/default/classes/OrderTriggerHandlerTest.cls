/*********************************************************************************************************
* Project:			C1ST: Sales
* Name:				OrderTriggerHandlerTest
* Description:		Test class FOR OrderTriggerHandler apex class.
* Tests:			orderCreationTest.
*					staticMethodsTest.
* -------------------------------------------------------------------------------------------------------
* COVERAGE:         OrderTrigger		--> 100%
*					OrderTriggerHandler --> 100%
*					OrderUtils			-->  82%
* Changes (Version)
* -------------------------------------------------------------------------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2019-03-06		Ricardo Pereira (RP)	Initial definition.    orderCreationTest
*           1.1     2019-03-06      Ruben Fernandez (RF)    Added new test method. staticMethodsTest
*	   	    1.2		2019-07-11		Nerea Leguinazabal		#C1STAGILE-16994: Use TestDataFactoryUtil for Data creation   
*********************************************************************************************************/
@isTest
private class OrderTriggerHandlerTest {
    
    @testSetup static void setup() {
    	List<String> lstActivities   =   new List<String>{'VN'};
		List<Contact> lstContsA      =   TestDataFactoryUtil.createPartnerUser(3, 1, 'Dealer', '133225511','1237770', 'EXTKEY0002','AP','PL', 'J',lstActivities,true);
        List<User> lstUsers1         =   TestDataFactoryUtil.createUser(lstContsA,'Sales_Manager','Partner','Manager');
        Insert lstUsers1;    
    }
    
	//Test the full process of an Order Creation
	static testMethod void orderCreationTest() {
	 	RecordType rType = [SELECT Id FROM RecordType WHERE Name like '%OPV%' AND SObjectType = 'SBQQ__Quote__c' LIMIT 1];

	 	Opportunity opp = new Opportunity(CloseDate = system.today()+180, Name = 'Test 4', StageName = '2', FundingForm__c='1', Country__c='PL');
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
    	
    	prd = new Product2(CDC__c = 'TestId 2', Name = 'TestVeh', StockDealer__c = ' ', StockBourse__c = ' ', StockCentral__c = 'X', Dealer_Group__c = acc.ownerId, Stock__c = false,
    								IsActive = true, SBQQ__Component__c = false, CurrencyIsoCode = 'CLP', Reserved__c = true, ProductCode = 'PC1', ColorCode__c = 'CC1', InteriorTrimCode__c = 'IT1', OptionsCode__c = 'OC1');
    	insert prd;

		Order ord = new Order(
			AccountId = acc.Id,
			EffectiveDate = System.today(),
			Status = '8',
			OrderId__c = '123456789',
			OpportunityId = opp.Id,
			LCDV16__c = '0123456789abcdef'
		);
    	   	 
    	// Perform test for Product Stock = false
        Test.startTest();
            Insert ord;
            ord.Status = '9';
            update ord;
			Order checkOrder = [SELECT AssetId__c FROM Order WHERE Id = :ord.Id];
			//TODO recheck assert 
			//System.assert(checkOrder.AssetId__c != null);
        Test.stopTest();
    }
    
    // Testing Static Methods as a Sales Manager
    static testMethod void staticMethodsTest() {
        User usr					 			= [SELECT Id, Contact.AccountId,Contact.Account.CommunicationMode__c FROM User WHERE Contact.Account.CommunicationMode__c = '2' AND Profile.Name = 'Sales_Manager' LIMIT 1]; 	
     	// Runing test as a Sales Manager
        System.runAs(usr) {
            Test.startTest();
            	// Create a new data set: B2C Accounts & Orders
            	List <Account> lstAcc 			= TestDataFactoryUtil.createPersonAccount(1);
            	List <Order> lstOrd				= TestDataFactoryUtil.createOrder(1,'VNOrders','Draft',lstAcc);
            	// Testing Static Methos
            	Boolean bRun     				= OrderTriggerHandler.shouldRunTrigger();
        		OrderTriggerHandler.dontRunTrigger();
        		OrderTriggerHandler.afterUpdate(new List<Order>(), new Map<Id,Order>(),new Map<Id,Order>());
            	// Check if can execute
        		System.assert(bRun);
            	// Now let's verify when the order is update 
        		lstOrd.get(0).LCDV16__c 	 	= '0123456789abcdeg';
        		Update lstOrd;
        		Boolean bDontRun 				= OrderTriggerHandler.shouldRunTrigger();
            	// Check if cannot execute
        		System.assertEquals(false, bDontRun);
        	Test.stopTest();
     	}
	}
	/*
     * @Method          :   beforeupdateOrderFormToActiveStatusInsert
     * @Author          :   Andres Oliva <andres.oliva@cognizant.com>
     * @Created         :   19/08/2019
     * @Description     :   This method verify JIRA user story C1STDEPLOY-231 in the before insert proccess. So when an order records have cancell status, the related QUOTE status must be update to Active. 
     */		
  
    static testMethod void updateOrderFormToActiveStatus() {
        // Test data setup

        List<Account>       lstAccts    =   TestDataFactoryUtil.createAccount(2,'Dealer');
        List<Opportunity>   lstOpps     =   TestDataFactoryUtil.createOpportunities(1, null ,lstAccts[0], 1000.0 ,'9', 75);
        recordType objRecortypeQuote =   [  SELECT DeveloperName,
                                                    Id 
                                            FROM    RecordType 
                                            WHERE   SobjectType = 'SBQQ__Quote__C' 
                                                    AND DeveloperName = 'CPQ_Order_Form'];
		SBQQ__Quote__C objQuote =   new SBQQ__Quote__C();
        objQuote.SBQQ__Opportunity2__c  =   lstOpps[0].id;            
        objQuote.SBQQ__Account__c       =   lstAccts[0].id;
        objQuote.recordtypeId           =   objRecortypeQuote.Id;
        objQuote.SBQQ__Status__c        =   '4'; //  'Whith order'
        insert objQuote;

        Test.startTest();
          	order objOrder =   new order();
            objOrder.OpportunityId  	=   lstOpps[0].id;            
            objOrder.AccountId       	=   lstAccts[0].id; 
			objOrder.EffectiveDate 		=	system.Today();
			objOrder.OrderId__c      	=	'TestId';     
            objOrder.OrderFormId__c		=	objQuote.Id;
			objOrder.status        		=   '0'; // 'Cancelled Order'
            insert objOrder;        
        Test.stopTest();

        system.debug('\n order after before trigger @@@@@ ' +  objOrder );       
        system.assertEquals( '2',objQuote.SBQQ__Status__c); // 'Active'
    
    }	
}
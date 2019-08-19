/******************************************************************************************
* Name: 			OrderUtilsTest
* Author: 			Gema Santiago
* Description:		Test class for OrderUtils class
* 
* Changes (Version)
* -----------------------------------------------------------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2019-05-14		Gema Santiago (GS)		Initial definition.
 			1.1		2019-07-11		Nerea Leguinazabal		#C1STAGILE-16994: Use TestDataFactoryUtil for Data creation  
*******************************************************************************************/
@isTest 
public class OrderUtilsTest {
	 @testSetup static void setup() {
    	List<String> lstActivities   =   new List<String>{'VN'};
		List<Contact> lstContsA      =   TestDataFactoryUtil.createPartnerUser(3, 1, 'Dealer', '133225511','1237770', 'EXTKEY0002','AP','PL', 'J',lstActivities,true);
        List<User> lstUsers1         =   TestDataFactoryUtil.createUser(lstContsA,'Sales_Manager','Partner','Manager');
        Insert lstUsers1;    
    }

	static testMethod void orderCreationTest_LCDV() {
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


		Order ord1a = new Order(
			AccountId = acc.Id,
			EffectiveDate = System.today(),
			Status = '8',
			OrderId__c = '123456789',
			OpportunityId = opp.Id,
			LCDV16__c = '0123456789abcdef'
		);
		Order ord1b = new Order(
			AccountId = acc.Id,
			EffectiveDate = System.today(),
			Status = '8',
			OrderId__c = '123456789',
			OpportunityId = opp.Id,
			LCDV16__c = '0123456789abcdef'
		);
    	   	

		//OrderTriggerHandler.dontRunTrigger();
    	// Perform test for Product Stock = false
        Test.startTest();
            Insert ord1a;
            ord1a.OwnerID=userInfo.getUserId();
            ord1a.Status = '9';
            OrderUtils.callBUSingleOrderMethods(ord1a, ord1b);
            

            //update ord;
			//Order checkOrder = [SELECT AssetId__c FROM Order WHERE Id = :ord.Id];
			//TODO recheck assert 
			//System.assert(checkOrder.AssetId__c != null);
        Test.stopTest();
    }

	static testMethod void orderCreationTest_VO() {
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


		
		Order ord2a = new Order(
			AccountId = acc.Id,
			EffectiveDate = System.today(),
			Status = '8',
			OrderId__c = '123456798',
			OpportunityId = opp.Id,
			LCDV16__c = '0123456789abcde'
		);
		Order ord2b = new Order(
			AccountId = acc.Id,
			EffectiveDate = System.today(),
			Status = '8',
			OrderId__c = '123456798',
			OpportunityId = opp.Id,
			LCDV16__c = '0123456789abcde'
		);
    	   	

		//OrderTriggerHandler.dontRunTrigger();
    	// Perform test for Product Stock = false
        Test.startTest();
            Insert ord2a;
            ord2a.OwnerID=userInfo.getUserId();
            ord2a.Status = '9';
            OrderUtils.callBUSingleOrderMethods(ord2a, ord2b);

            //update ord;
			//Order checkOrder = [SELECT AssetId__c FROM Order WHERE Id = :ord.Id];
			//TODO recheck assert 
			//System.assert(checkOrder.AssetId__c != null);
        Test.stopTest();
    }

	static testMethod void orderCreationTest_matchOrderAssetWithSameVIN() {
        
        Opportunity testingOpportunity = new Opportunity(CloseDate = system.today()+180, Name = 'Test 4', StageName = '2', FundingForm__c='1', Country__c='PL');
        insert testingOpportunity;
        
        Account testingAccount = new Account(Name = 'Testing1235'); 
        insert testingAccount;        
        
        Account acc2 = new Account(
            Name = 'MatchAccountAsset');
        insert acc2;
        
        Asset a1 = new Asset(
            AccountId = acc2.Id,
            VIN__c = 'VF36E4HTH20603732',
            Name = 'testing'
        );
        insert a1;
        
        Order ord1a = new Order(
            AccountId = testingAccount.Id,
            Driver__c = acc2.Id,
            Leaser__c = acc2.Id,
            EffectiveDate = System.today(),
            Status = '8',
            OrderId__c = '123456789',
            OpportunityId = testingOpportunity.Id,
            LCDV16__c = '0123456789abcdef',
            Vin__c = 'VF36E4HTH20603732'
        );
        
        Insert ord1a;        
        
        
        Test.startTest();
        
        ord1a.Status = '9';
        OrderUtils.callBUSingleOrderMethods(ord1a, null);     
        
        List<AccountContactAssetRelation__c> checkNumberAccountContactAssetRelation = [Select Id from AccountContactAssetRelation__c where AssetId__c =: a1.Id];
        
        // Number of AccountContactAssetRelation__c = OldOwner + Owner + Driver + Keeper
        System.assertEquals(4, checkNumberAccountContactAssetRelation.size()); 
        
        Test.stopTest(); 
    }

	static testMethod void autoContactTaskCreationTest() {

	 	Opportunity opp = (Opportunity)TestDataFactoryUtil.createSobject(Constants.SOT_OPPORTUNITY,new map<String,Object>{
			 'CloseDate' => system.today()+180, 
			 'Name' 	 => 'Test 4', 
			 'StageName' => '2',
			 'FundingForm__c' => '1',
			 'Country__c' => 'ES'
		}, true);
        
        Account acc = (Account)TestDataFactoryUtil.createSobject(Constants.SOT_ACCOUNT, new map<String, Object>{
                'FirstName'             => 'Account FirstName testMethod sobject',
                'LastName'              => 'Account LastNametest sobject',
                'Salutation'            => '1',
                'PersonalEmail__pc'     => 'b2ctestMethod2@test.com',
                'RecordTypeId'		    => PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA)
    	}, true);
	   	
		Order order = new Order(
			AccountId = acc.Id,
			EffectiveDate = System.today(),
			Status = '9',
			Country__c = 'ES',
			Brand__c = 'AP',
			OrderId__c = '123456798',
			OpportunityId = opp.Id,
			RealDeliveryDate__c = Date.Today(),
			Order_Type__c = 'VN',
			LCDV16__c = '0123456789abcdef'
		);
        Test.startTest();
            Insert order;
			List<Task> lstTask = [SELECT id from Task where whatId = :acc.id];
			System.assertEquals(2, lstTask.size(),'TASK NOT CREATED');
        Test.stopTest();
    }

}
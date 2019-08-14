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
private class QuotesCPQStockCounterTest{
  
  @testSetup static void setupTestData(){
    
    	Account acc = new Account(Name = 'Test'); 
	   	insert acc;
    	 
    	Product2 prd = new Product2(CDC__c = 'TestId 1', Name = 'TestVeh', StockDealer__c = 'X', StockBourse__c = 'X', StockCentral__c = 'X', Dealer_Group__c = acc.ownerId, Stock__c = true,
    								IsActive = true, SBQQ__Component__c = false, CurrencyIsoCode = 'CLP');
    	insert prd;
    	
    	Pricebook2 standardPB = new Pricebook2(Id = Test.getStandardPricebookId());
    	
    	PricebookEntry pEnt = new PricebookEntry(IsActive = true, Product2Id = prd.Id, UnitPrice = 10600000, Pricebook2Id = standardPB.Id);
    	insert pEnt; 
    	
    	prd = new Product2(CDC__c = 'TestId 2', Name = 'TestVeh', StockDealer__c = 'X', StockBourse__c = 'X', StockCentral__c = 'X', Dealer_Group__c = acc.ownerId, Stock__c = false,
    								IsActive = true, SBQQ__Component__c = false, CurrencyIsoCode = 'CLP');
    	insert prd;
    	
		pEnt = new PricebookEntry(IsActive = true, Product2Id = prd.Id, UnitPrice = 10600000, Pricebook2Id = standardPB.Id);
    	insert pEnt; 
  
  }
  static testMethod void test_isFilterHidden_UseCase1(){
    List<PricebookEntry> pricebookentry_Obj  =  [SELECT Pricebook2Id,Product2Id,UnitPrice,IsActive,UseStandardPrice from PricebookEntry];
    System.assertEquals(true,pricebookentry_Obj.size()>0);
    List<Product2> product2_Obj  =  [SELECT Name,IsActive from Product2];
    System.assertEquals(true,product2_Obj.size()>0);
    List<Account> account_Obj  =  [SELECT Name from Account];
    System.assertEquals(true,account_Obj.size()>0);
    QuotesCPQStockCounter obj01 = new QuotesCPQStockCounter(); 
    SBQQ__Quote__c q = new SBQQ__Quote__c();
    obj01.type1 = account_Obj[0].Name; 
    obj01.isFilterHidden(q,'test data');  
  }
  static testMethod void test_getFilterDefaultValue_UseCase1(){
    List<PricebookEntry> pricebookentry_Obj  =  [SELECT Pricebook2Id,Product2Id,UnitPrice,IsActive,UseStandardPrice from PricebookEntry];
    System.assertEquals(true,pricebookentry_Obj.size()>0);
    List<Product2> product2_Obj  =  [SELECT Name,IsActive from Product2];
    System.assertEquals(true,product2_Obj.size()>0);
    List<Account> account_Obj  =  [SELECT Name from Account];
    System.assertEquals(true,account_Obj.size()>0);
    QuotesCPQStockCounter obj01 = new QuotesCPQStockCounter();
    SBQQ__Quote__c q = new SBQQ__Quote__c(); 
    obj01.type1 = account_Obj[0].Name;
    obj01.getFilterDefaultValue(q,'test data'); 
  }
  static testMethod void test_isSearchCustom_UseCase1(){
    List<PricebookEntry> pricebookentry_Obj  =  [SELECT Pricebook2Id,Product2Id,UnitPrice,IsActive,UseStandardPrice from PricebookEntry];
    System.assertEquals(true,pricebookentry_Obj.size()>0);
    List<Product2> product2_Obj  =  [SELECT Name,IsActive from Product2];
    System.assertEquals(true,product2_Obj.size()>0);
    List<Account> account_Obj  =  [SELECT Name from Account];
    System.assertEquals(true,account_Obj.size()>0);
    QuotesCPQStockCounter obj01 = new QuotesCPQStockCounter();
    SBQQ__Quote__c q = new SBQQ__Quote__c();
    obj01.type1 = account_Obj[0].Name;
    obj01.isSearchCustom(q,new Map<String,Object>()); 
  }
  static testMethod void test_getAdditionalSearchFilters_UseCase1(){
    List<PricebookEntry> pricebookentry_Obj  =  [SELECT Pricebook2Id,Product2Id,UnitPrice,IsActive,UseStandardPrice from PricebookEntry];
    System.assertEquals(true,pricebookentry_Obj.size()>0);
    List<Product2> product2_Obj  =  [SELECT Name,IsActive from Product2];
    System.assertEquals(true,product2_Obj.size()>0);
    List<Account> account_Obj  =  [SELECT Name from Account];
    System.assertEquals(true,account_Obj.size()>0);
    QuotesCPQStockCounter obj01 = new QuotesCPQStockCounter();
    SBQQ__Quote__c q = new SBQQ__Quote__c();
    obj01.type1 = account_Obj[0].Name;
    obj01.getAdditionalSearchFilters(q,new Map<String,Object>());
  }
  static testMethod void test_search_UseCase1(){
    List<PricebookEntry> pricebookentry_Obj  =  [SELECT Pricebook2Id,Product2Id,UnitPrice,IsActive,UseStandardPrice from PricebookEntry];
    System.assertEquals(true,pricebookentry_Obj.size()>0);
    List<Product2> product2_Obj  =  [SELECT Name,IsActive from Product2];
    System.assertEquals(true,product2_Obj.size()>0);
    List<Account> account_Obj  =  [SELECT Id,Name from Account];
    System.assertEquals(true,account_Obj.size()>0);
    QuotesCPQStockCounter obj01 = new QuotesCPQStockCounter();
    Pricebook2 standardPB = new Pricebook2(Id = Test.getStandardPricebookId());
    SBQQ__Quote__c q = new SBQQ__Quote__c(SBQQ__Partner__c = account_Obj.get(0).Id, SBQQ__PricebookId__c = standardPB.Id);
    obj01.type1 = account_Obj[0].Name;
    obj01.search(q,new Map<String,Object>());
  }
  static testMethod void test_isSuggestCustom_UseCase1(){
    List<PricebookEntry> pricebookentry_Obj  =  [SELECT Pricebook2Id,Product2Id,UnitPrice,IsActive,UseStandardPrice from PricebookEntry];
    System.assertEquals(true,pricebookentry_Obj.size()>0);
    List<Product2> product2_Obj  =  [SELECT Name,IsActive from Product2];
    System.assertEquals(true,product2_Obj.size()>0);
    List<Account> account_Obj  =  [SELECT Name from Account];
    System.assertEquals(true,account_Obj.size()>0);
    QuotesCPQStockCounter obj01 = new QuotesCPQStockCounter();
    SBQQ__Quote__c q = new SBQQ__Quote__c();
    obj01.type1 = account_Obj[0].Name;
    obj01.isSuggestCustom(q,new Map<String,Object>());
  }
  static testMethod void test_isInputHidden_UseCase1(){
    List<PricebookEntry> pricebookentry_Obj  =  [SELECT Pricebook2Id,Product2Id,UnitPrice,IsActive,UseStandardPrice from PricebookEntry];
    System.assertEquals(true,pricebookentry_Obj.size()>0);
    List<Product2> product2_Obj  =  [SELECT Name,IsActive from Product2];
    System.assertEquals(true,product2_Obj.size()>0);
    List<Account> account_Obj  =  [SELECT Name from Account];
    System.assertEquals(true,account_Obj.size()>0);
    QuotesCPQStockCounter obj01 = new QuotesCPQStockCounter();
    SBQQ__Quote__c q = new SBQQ__Quote__c();
    obj01.type1 = account_Obj[0].Name;
    obj01.isInputHidden(q,'test data');
  }
  static testMethod void test_getInputDefaultValue_UseCase1(){
    List<PricebookEntry> pricebookentry_Obj  =  [SELECT Pricebook2Id,Product2Id,UnitPrice,IsActive,UseStandardPrice from PricebookEntry];
    System.assertEquals(true,pricebookentry_Obj.size()>0);
    List<Product2> product2_Obj  =  [SELECT Name,IsActive from Product2];
    System.assertEquals(true,product2_Obj.size()>0);
    List<Account> account_Obj  =  [SELECT Name from Account];
    System.assertEquals(true,account_Obj.size()>0);
    QuotesCPQStockCounter obj01 = new QuotesCPQStockCounter();
    SBQQ__Quote__c q = new SBQQ__Quote__c();
    obj01.type1 = account_Obj[0].Name;
    obj01.getInputDefaultValue(q,'test data');
  }
  static testMethod void test_getAdditionalSuggestFilters_UseCase1(){
    List<PricebookEntry> pricebookentry_Obj  =  [SELECT Pricebook2Id,Product2Id,UnitPrice,IsActive,UseStandardPrice from PricebookEntry];
    System.assertEquals(true,pricebookentry_Obj.size()>0);
    List<Product2> product2_Obj  =  [SELECT Name,IsActive from Product2];
    System.assertEquals(true,product2_Obj.size()>0);
    List<Account> account_Obj  =  [SELECT Name from Account];
    System.assertEquals(true,account_Obj.size()>0);
    QuotesCPQStockCounter obj01 = new QuotesCPQStockCounter();
    SBQQ__Quote__c q = new SBQQ__Quote__c();
    obj01.type1 = account_Obj[0].Name;
    obj01.getAdditionalSuggestFilters(q,new Map<String,Object>());
  }
  static testMethod void test_suggest_UseCase1(){
    List<PricebookEntry> pricebookentry_Obj  =  [SELECT Pricebook2Id,Product2Id,UnitPrice,IsActive,UseStandardPrice from PricebookEntry];
    System.assertEquals(true,pricebookentry_Obj.size()>0);
    List<Product2> product2_Obj  =  [SELECT Name,IsActive from Product2];
    System.assertEquals(true,product2_Obj.size()>0);
    List<Account> account_Obj  =  [SELECT Name from Account];
    System.assertEquals(true,account_Obj.size()>0);
    QuotesCPQStockCounter obj01 = new QuotesCPQStockCounter();
    Pricebook2 standardPB = new Pricebook2(Id = Test.getStandardPricebookId());
    SBQQ__Quote__c q = new SBQQ__Quote__c(SBQQ__Partner__c = account_Obj.get(0).Id, SBQQ__PricebookId__c = standardPB.Id, CurrencyIsoCode = 'EUR');
    obj01.type1 = account_Obj[0].Name;
    
    Map<String,Object> mp = new Map<String,Object>();
    
    mp.put('Stock',true);
    
    obj01.suggest(q,mp);
    
    mp.put('Stock',false);
    
    obj01.suggest(q,mp); 
  }
   static testMethod void test_StockCounterException(){
    List<PricebookEntry> pricebookentry_Obj  =  [SELECT Pricebook2Id,Product2Id,UnitPrice,IsActive,UseStandardPrice from PricebookEntry];
    System.assertEquals(true,pricebookentry_Obj.size()>0);
    List<Product2> product2_Obj  =  [SELECT Name,IsActive from Product2];
    System.assertEquals(true,product2_Obj.size()>0);
    List<Account> account_Obj  =  [SELECT Name from Account];
    System.assertEquals(true,account_Obj.size()>0);
    QuotesCPQStockCounter obj01 = new QuotesCPQStockCounter();
    obj01.type1 = account_Obj[0].Name;
    QuotesCPQStockCounter.StockCounterException obj121 = new QuotesCPQStockCounter.StockCounterException();
  }
}
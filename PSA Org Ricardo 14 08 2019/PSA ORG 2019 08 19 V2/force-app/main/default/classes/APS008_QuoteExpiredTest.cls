/**
	*   @Class 			: APS008_QuoteExpiredTest
	*   @Author         : Sergio Lopez 
	*   @Created        : 27 March 2018
	*   @Description    : Test for APS006_LeadDiscard
	*
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Sergio Lopez 			27/3/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/

@isTest
public class APS008_QuoteExpiredTest {
	public static Account b2c;
    
    @isTest static void QuoteExpiredBatchTest1(){ 
        setupData1(); 
        
        // Perform test
        Test.startTest();
	        APS008_QuoteExpired pLD = new APS008_QuoteExpired();
			String sSchedule = '0 0 * * * ?';
			System.schedule('Expired Quotes Batch: APS008_QuoteExpired', sSchedule, pLD);	 
        Test.stopTest();
        
    } 
    
    @isTest static void QuoteExpiredBatchTest2(){ 
        setupData2();
        
        // Perform test
        Test.startTest();
	        APS008_QuoteExpired pLD = new APS008_QuoteExpired();
			String sSchedule = '0 0 * * * ?';
			System.schedule('Expired Quotes Batch: APS008_QuoteExpired', sSchedule, pLD);	 
        Test.stopTest();
        
    } 
    
        
    @isTest static void QuoteDeniedOrderFormTest3(){ 
        setupData2();
        
        // Perform test
        Test.startTest();
		   	Opportunity opp = new Opportunity(CloseDate = system.today()+180, Name = 'Test 3', StageName = '4', Country__c = 'ES');
		   	insert opp;
		   	
		   	RecordType[] rType = [Select id from recordtype where Name = 'CPQ Order Form' limit 1];
		   	
		  	//SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__ExpirationDate__c = system.today()-1, SBQQ__Status__c = '2', SBQQ__Opportunity2__c = opp.Id, Type__c='VN', RecordTypeId = rType[0].Id);
		  	SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__ExpirationDate__c = system.today()-1, SBQQ__Status__c = '2', SBQQ__Opportunity2__c = opp.Id, RecordTypeId = rType[0].Id, SBQQ__Account__c = b2c.Id);
		    insert quote; 
		    
		    quote.SBQQ__Status__c = '7';
		    
		    update quote; 
        Test.stopTest();
        
    } 
    
     
    static void setupData1() {
        Account b2c = new Account(
            FirstName           = 'Account FirstName',
            LastName            = 'Account LastName',
            Salutation          = '1',
            PersonalEmail__pc   = 'b2c@test.com',
            RecordTypeId        = Schema.SObjectType.ACCOUNT.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId()
        );

		insert b2c;
    	
	   	Opportunity opp = new Opportunity(CloseDate = system.today()+180, Name = 'Test', StageName = '2', Country__c = 'ES');
	   	insert opp;
	   	
	  	//SBQQ__Quote__c quotes = new SBQQ__Quote__c(SBQQ__ExpirationDate__c = system.today()-1, SBQQ__Status__c = '2', SBQQ__Opportunity2__c = opp.Id, Type__c='VN');
	  	SBQQ__Quote__c quotes = new SBQQ__Quote__c(SBQQ__ExpirationDate__c = system.today()+1, SBQQ__Status__c = '2', SBQQ__Opportunity2__c = opp.Id, SBQQ__Account__c = b2c.Id);
	    insert quotes; 
    
  	}
  	
  	static void setupData2() {
  		List<SBQQ__Quote__c> lst_quote = new List<SBQQ__Quote__c>();

        b2c = new Account(
            FirstName           = 'Account FirstName',
            LastName            = 'Account LastName',
            Salutation          = '1',
            PersonalEmail__pc   = 'b2c@test.com',
            RecordTypeId        = Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2C_PA').getRecordTypeId()
        );

		insert b2c;
  		
	   	Opportunity opp = new Opportunity(CloseDate = system.today()+180, Name = 'Test', StageName = '2', Country__c = 'ES');
	   	insert opp;
	   	
	   	RecordType[] rType = [Select id from recordtype where Name = 'CPQ Quote' limit 1];
	   	
	  	SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__ExpirationDate__c = system.today()-1, SBQQ__Status__c = '2', SBQQ__Opportunity2__c = opp.Id, RecordTypeId = rType[0].Id, SBQQ__Account__c = b2c.Id);
	    lst_quote.add(quote);

		opp = new Opportunity(CloseDate = system.today()+180, Name = 'Test', StageName = '2', Country__c = 'ES');
	   	insert opp;
	    
	    SBQQ__Quote__c quote2 = new SBQQ__Quote__c(SBQQ__ExpirationDate__c = system.today()+1, SBQQ__Status__c = '2', SBQQ__Opportunity2__c = opp.Id, RecordTypeId = rType[0].Id, SBQQ__Account__c = b2c.Id);
	    lst_quote.add(quote2);
	   
	   	opp = new Opportunity(CloseDate = system.today()+180, Name = 'Test 2', StageName = '2', Country__c = 'ES');
	   	insert opp;
	   	
	   	rType = [Select id from recordtype where Name = 'CPQ Order Form' limit 1];
	   	
	   	SBQQ__Quote__c  quote3 = new SBQQ__Quote__c(SBQQ__ExpirationDate__c = system.today(), SBQQ__Status__c = '2', SBQQ__Opportunity2__c = opp.Id, RecordTypeId = rType[0].Id, SBQQ__Account__c = b2c.Id);
	    lst_quote.add(quote3);
	   	
	   	SBQQ__Quote__c quote4 = new SBQQ__Quote__c(SBQQ__ExpirationDate__c = system.today()+1, SBQQ__Status__c = '2', SBQQ__Opportunity2__c = opp.Id, RecordTypeId = rType[0].Id, SBQQ__Account__c = b2c.Id);
	    lst_quote.add(quote4);

	    insert lst_quote; 
    
  	}

}
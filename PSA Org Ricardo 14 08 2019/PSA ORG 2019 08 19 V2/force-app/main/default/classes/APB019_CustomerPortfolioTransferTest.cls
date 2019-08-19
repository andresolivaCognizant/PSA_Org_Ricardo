@isTest
private class APB019_CustomerPortfolioTransferTest {
	
	@isTest static void test_method_one() {
		List<Lead> lstLead = new List<Lead>();

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

		SBQQ__Quote__C quotes = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
                    'SBQQ__ExpirationDate__c'  => System.Today()-1,
                    'SBQQ__Status__c' => '2',
                    'SBQQ__Account__c'  =>  acc.Id
                } ,true);

	  	
	    ServiceContract__c servContr = new ServiceContract__c(
	    	ContractNumber__c = 'WB1101S001',
	    	ContractStatus__c = 'A',
	    	Brand__c = 'AC',
	    	ContractStartDate__c = System.today(),
	    	ContractEndDate__c = System.today()+1, 
	    	Country__c = 'PT',
	    	SubscribedDuration__c = 84, 
	    	SubscribedMileage__c = 160000,
	    	Account__c = acc.Id
	    );

	    insert servContr;


        Lead lea  = new Lead(
                FirstName                   = 'Test 001', 
                LastName                    = 'Version1',
                Phone                       = '956789876',
                PSABrand__c                 = 'AP',
                Email                       = 'psaLead@leadexample.com',
                LeadCountry__c              = 'AZ',
            	NationalId__c				= '0909843X'
        );

        lstLead.add(lea);

        Lead lea2  = new Lead(
                FirstName                   = 'Test 001', 
                LastName                    = 'Version1',
                Phone                       = '956789876',
                PSABrand__c                 = 'AP',
                Email                       = 'psaLead@leadexample.com',
                LeadCountry__c              = 'AZ',
            	NationalId__c				= '0909843X',
            	Customer__c 				=  acc.Id
        );

        lstLead.add(lea2);

        insert lstLead;

		CustomerPortfolioTransfer__c cusPortTran = new CustomerPortfolioTransfer__c(
			Status__c = '1'
		);

		insert cusPortTran;

		List<CustomerPortfolioTransferMember__c> lstCust = new List<CustomerPortfolioTransferMember__c>();

		CustomerPortfolioTransferMember__c cusPorTransMem = new CustomerPortfolioTransferMember__c(
			CustomerPortfolioTransfer__c = cusPortTran.Id,
			Record_ID__c = acc.Id
		);

		lstCust.add(cusPorTransMem);

		CustomerPortfolioTransferMember__c cusPorTransMem2 = new CustomerPortfolioTransferMember__c(
			CustomerPortfolioTransfer__c = cusPortTran.Id,
			Record_ID__c = lea.Id
		);

		lstCust.add(cusPorTransMem2);

		insert lstCust;
        
        Test.startTest();
            APB019_CustomerPortfolioTransfer obj = new APB019_CustomerPortfolioTransfer();
            DataBase.executeBatch(obj);        
        Test.stopTest();
    }
}
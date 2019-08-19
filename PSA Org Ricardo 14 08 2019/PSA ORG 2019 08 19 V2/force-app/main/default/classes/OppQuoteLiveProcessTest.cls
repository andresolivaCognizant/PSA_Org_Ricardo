@isTest
private class OppQuoteLiveProcessTest {

	@isTest static void test_method_one() {

        Account b2c = new Account(
            FirstName           = 'Account FirstName',
            LastName            = 'Account LastName',
            Salutation          = '1',
            PersonalEmail__pc   = 'b2c@test.com',
            RecordTypeId        = Schema.SObjectType.ACCOUNT.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId()
        );

		insert b2c;

		List<Opportunity> lst_opp = new List<Opportunity>();
	   	Opportunity opp = new Opportunity(CloseDate = system.today()+180, Name = 'Test 3', StageName = '4', Country__c = 'ES', AccountId = b2c.Id);
		lst_opp.add(opp);
		insert lst_opp;

	   	RecordType[] rType = [Select id from recordtype where Name = 'CPQ Quote' limit 1];

	  	SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__ExpirationDate__c = system.today()-1, SBQQ__Status__c = '3', SBQQ__Opportunity2__c = opp.Id, RecordTypeId = rType[0].Id, SBQQ__Account__c = b2c.Id);

		insert quote;

		String cpqQId = quote.Id;

		quote.SBQQ__Status__c = '7';

		update quote;

		quote.SBQQ__Status__c = '3';

		update quote;

	   	rType = [Select id from recordtype where Name = 'CPQ Order Form' limit 1];

	  	quote = new SBQQ__Quote__c(SBQQ__ExpirationDate__c = system.today()-1, SBQQ__Status__c = '2', SBQQ__Opportunity2__c = opp.Id, RecordTypeId = rType[0].Id, SBQQ__Account__c = b2c.Id, QuotesWithOrderForms__c = cpqQId);

		insert quote;

		// Cancel quote to starting Process Builder launch
		quote.SBQQ__Status__c = '7';

		update quote;

		// Active again and create new qorder form for first quote
		quote.SBQQ__Status__c = '2';

		update quote;

		quote = new SBQQ__Quote__c(SBQQ__ExpirationDate__c = system.today()-1, SBQQ__Status__c = '2', SBQQ__Opportunity2__c = opp.Id, RecordTypeId = rType[0].Id, SBQQ__Account__c = b2c.Id, QuotesWithOrderForms__c = cpqQId);

		insert quote;

		quote.SBQQ__Status__c = '7';

		update quote;

	}

	@isTest static void test_method_two() {

        Account b2c = new Account(
            FirstName           = 'Account FirstName',
            LastName            = 'Account LastName',
            Salutation          = '1',
            PersonalEmail__pc   = 'b2c@test.com',
            RecordTypeId        = Schema.SObjectType.ACCOUNT.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId()
        );

		insert b2c;

		List<Opportunity> lst_opp = new List<Opportunity>();
	   	Opportunity opp = new Opportunity(CloseDate = system.today()+180, Name = 'Test 3', StageName = '3', Country__c = 'ES', AccountId = b2c.Id);
		lst_opp.add(opp);
		insert lst_opp;

    RecordType[] rType = [Select id from recordtype where Name = 'OPV Quote' AND SObjectType = 'SBQQ__Quote__c' limit 1];

	  	SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__ExpirationDate__c = system.today()-1, SBQQ__Status__c = '3', SBQQ__Opportunity2__c = opp.Id, RecordTypeId = rType[0].id, SBQQ__Account__c = b2c.Id);

		insert quote;

		String opvQId = quote.Id;

		quote.SBQQ__Status__c = '7';

		update quote;

		quote.SBQQ__Status__c = '3';

		update quote;

		rType = [Select id from recordtype where Name = 'OPV OrderForm VN' limit 1];

	  	quote = new SBQQ__Quote__c(SBQQ__ExpirationDate__c = system.today()-1, SBQQ__Status__c = '2', SBQQ__Opportunity2__c = opp.Id, RecordTypeId = rType[0].Id, SBQQ__Account__c = b2c.Id, QuotesWithOrderForms__c = opvQId);

		insert quote;

		quote.SBQQ__Status__c = '7';

		update quote;
	}
}
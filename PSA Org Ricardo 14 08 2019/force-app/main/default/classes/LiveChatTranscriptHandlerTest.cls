@isTest
private class LiveChatTranscriptHandlerTest {
	
	@isTest static void insertNullContactLiveTranscript() {
            Account acc              =   new Account (
                FirstName               =   'Portugal',
                LastName                =   'Anonymous',
                PersonalEmail__pc       =   'acc1C@test.com',
                RecordTypeId            =   Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2C_PA').getRecordTypeId(),
                TECH_CreatedFromLead__c =   true,
                Country__c              =   'PT',
                NonResidentCustomer__pc =   false,
                NationalId__pc          =   '500206007',
                NationalId2__pc         =   '500206007',
                TECH_ContactCountry__pc =    'PT',
                NationalIdType__pc      =   'NIF'
            );

		insert acc;

		Case cas = new Case(
							AccountId = acc.Id,
							Subject = 'Chat conversation');
		insert cas;

		LiveChatVisitor lcv = new LiveChatVisitor();
		insert lcv;

		LiveChatTranscript lct = new LiveChatTranscript(
														LiveChatVisitorId = lcv.Id, 
														CaseId = cas.Id);
		insert lct;

		Test.startTest();
			lct.ContactId = null;
			update lct;			
		Test.stopTest();
	}
}
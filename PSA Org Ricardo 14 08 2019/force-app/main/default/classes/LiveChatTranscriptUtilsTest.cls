/**
* Salesforce
* @author 			Pedro Párraga <parragabornez.pedrojesus@ext.mpsa.com>
* Project:			Care
* Description:		Test class.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2019-03-29		Pedro Parraga (MM)		Initial definition.
*********************************************************************************************************/
@isTest
private class LiveChatTranscriptUtilsTest {
	
	@isTest static void insertContactToLiveTranscript() {
		Account acc = new Account(Name = 'Test',
								  RecordTypeId = Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2B').getRecordTypeId()
		);

		insert acc;

		Case cas = new Case(
							AccountId = acc.Id);
		insert cas;

		LiveChatVisitor lcv = new LiveChatVisitor();
		insert lcv;

		LiveChatTranscript lct = new LiveChatTranscript(
														LiveChatVisitorId = lcv.Id, 
														CaseId = cas.Id);
		insert lct;

		Contact cont = new Contact(
									FirstName = 'contactTest',
									LastName = 'lastName',
									AccountId = acc.Id,
									Email = 'a@test.com');
		insert cont;

		Test.startTest();
			lct.ContactId = cont.Id;
			update lct;			
		Test.stopTest();
	}

	@isTest static void insertPersonAccountoLiveTranscript() {
            Account acc              =   new Account (
                FirstName               =   'acc1',
                LastName                =   'acc1',
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
							AccountId = acc.Id);
		insert cas;

		LiveChatVisitor lcv = new LiveChatVisitor();
		insert lcv;

		LiveChatTranscript lct = new LiveChatTranscript(
														LiveChatVisitorId = lcv.Id, 
														CaseId = cas.Id);
		insert lct;

		Contact cont = [SELECT Id FROM Contact WHERE AccountId =: acc.Id];

		Test.startTest();
			lct.ContactId = cont.Id;
			update lct;			
		Test.stopTest();
	}

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
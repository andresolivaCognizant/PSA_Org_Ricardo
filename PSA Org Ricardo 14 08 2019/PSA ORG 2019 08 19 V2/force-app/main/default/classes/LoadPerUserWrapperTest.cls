@isTest
private class LoadPerUserWrapperTest {
	
	@isTest static void test_method_one() {


        Account acct = new Account(
            LocalIdOfCustomer__c                          =   '',
            Name                                          =   'TEST matching',
            BillingPostalCode                             =   '23456',
            BillingStreet                                 =   'Calle de Sebastián Elcano ',
            FiscalId__c                                   =   '1',
            RecordTypeId                                  =   Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2B').getRecordTypeId()
         );

        insert acct;

        Contact cnt             =   new Contact (
            FirstName           =   'TEST ' ,
            LastName            =   'matching',
            Salutation          =   '1',
            Birthdate           =   Date.today() - 23,          
            AccountId           =   acct.Id,
            Phone               =   '+8745943',
            TECH_CounterSalesman__c = 1
            
        );

        insert cnt;

        Contact cnt2             =   new Contact (
            FirstName           =   'TEST2' ,
            LastName            =   'matching2',
            Salutation          =   '1',
            Birthdate           =   Date.today() - 23,          
            AccountId           =   acct.Id,
            Phone               =   '+8745943'
            
        );

        insert cnt2;

        User oUser1 = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'Partner Community User'].Id,
             LastName = 'last1',
             Email = 'user1@test.com',
             Username = 'tstuser1@test.com',
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US',
             Brand__c = 'AP',
             ContactId = cnt.Id
        );

        insert oUser1;

        User oUser2 = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'Partner Community User'].Id,
             LastName = 'last2',
             Email = 'user2@test.com',
             Username = 'tstuser2@test.com',
             CompanyName = 'TEST2',
             Title = 'title2',
             Alias = 'alias2',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US',
             Brand__c = 'AP',
             ContactId = cnt2.Id
        );

        insert oUser2;


        Test.startTest();
			User us = [SELECT Id, Contact.TECH_CounterSalesman__c FROM User WHERE Id =: oUser1.Id];	
			LoadPerUserWrapper loPerUsWra = new LoadPerUserWrapper(us);
			loPerUsWra.compareTo(loPerUsWra);

			LoadPerUserWrapper loPerUsWra2 = new LoadPerUserWrapper(oUser2);
			loPerUsWra2.compareTo(loPerUsWra2);			
		Test.stopTest();	
	}
}
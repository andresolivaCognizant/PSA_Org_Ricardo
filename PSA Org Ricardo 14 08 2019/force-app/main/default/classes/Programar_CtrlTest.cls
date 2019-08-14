@isTest
private class Programar_CtrlTest {
	
	@isTest static void test_method_one() {
        Account a = new Account(
            Name            = 'Test Dealer',
            RecordTypeId    = Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2B').getRecordTypeId()
        );

        insert a;

        List<Account> lst_acc = [SELECT Id FROM Account LIMIT 1];

        /*Contact c = new Contact(
            FirstName = 'Test Dealer',
            LastName = 'Contact',
            AccountId = a.Id,
            Email = 'contact@test.dealer.com'
        );

        insert c;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Partner Community User'];

        User u = new User(
            ContactId           = c.Id,
            ProfileId           = p.Id,
            LastName            = 'LastName',
            Email               = 'contact@test.dealer.com',
            UserName            = 'dealer.salesmen.calendar@test.com',
            Alias               = 'dsc',
            TimeZoneSidKey      = 'America/Los_Angeles',
            EmailEncodingKey    = 'UTF-8',
            LanguageLocaleKey   = 'en_US',
            LocaleSidKey        = 'en_US',
            IsActive            = true
        );

        insert u;*/

        Event e = new Event(
            Subject = 'Call',
            OwnerId = UserInfo.getUserId(),
            DurationInMinutes = 60,
            ActivityDateTime = System.today()

        );	


        Test.startTest();
        	insert e;
        	String accId = lst_acc[0].Id;
        	String eventos = Programar_Ctrl.getEventos();
        	String nameAccount = Programar_Ctrl.getNameFromAccount(accId);
        	String accData = Programar_Ctrl.getAcctData(lst_acc[0].Id);
        	Boolean event = Programar_Ctrl.addEvent(lst_acc[0].Id, '2019011711111111111', 'Call', 'mContacto', 2, false, 'Description');
        	List<String> pickValues = Programar_Ctrl.getPickValues('Event', 'Activity__c');
        	String subjValues = Programar_Ctrl.getSubjValues(accId);
        Test.stopTest();

    }
	
	@isTest static void test_method_two() {
        Account a = new Account(
            Name            = 'Test Dealer',
            RecordTypeId    = Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2B').getRecordTypeId()
        );

        insert a;

        List<Account> lst_acc = [SELECT Id FROM Account LIMIT 1];
        String accId = lst_acc[0].Id;
        
		Test.startTest();
			String subjValues = Programar_Ctrl.getSubjValues(accId);
		Test.stopTest();
	}
	
}
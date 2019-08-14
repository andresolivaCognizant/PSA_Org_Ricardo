@isTest
private class TeleAlertTriggerHandlerTest {
	
	@isTest static void test_method_one() {
        TeleAlert__c teleAlert = new TeleAlert__c(Country__c = 'PT', Brand__c = 'AP');

        Test.startTest();
        	insert teleAlert;
        	teleAlert.Brand__c = 'AC';
        	update teleAlert;
        Test.stopTest();
	}	
}
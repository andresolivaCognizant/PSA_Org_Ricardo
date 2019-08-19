@isTest
private class DMSearchCountersControllerTest {
	
	@isTest static void test_method_one() {
		Test.startTest();
			Map<String, String> map_metrics = DMSearchCountersController.getMetrics();
			WorkshopAppointment__c work = new WorkshopAppointment__c();
			DMSearchCountersController.ConsentsOutdated consents = new DMSearchCountersController.ConsentsOutdated(work);
			DMSearchCountersController.ConsentsOutdated consentsTwo = new DMSearchCountersController.ConsentsOutdated('strError');
			DMSearchCountersController.DataTable dataTable = new DMSearchCountersController.DataTable(null, null);
		Test.stopTest();
	}
}
@isTest
private class ConsentsPopUpModalControllerTest {
	
	@isTest static void test_method_one() {
        List<Contact> lstConts  =  TestDataFactoryUtil.createPartnerUser(1,1, 'Dealer', '133225511','1237770', 'EXTKEY0002','AP','CL', 'J',new List<String>(), true);
        
        List<Account> lstAccts = TestDataFactoryUtil.createAccount(1,'Dealer');

        Account a = new Account(
            Name            = 'Test Dealer',
            RecordTypeId    = Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('Dealer').getRecordTypeId()
        );

        insert a;

        Consent__c consent = new Consent__c(Contact__c = lstConts[0].Id, 
                                            DocumentBrand__c = 'AC', 
                                            CollectedEntityId__c = lstAccts[0].Id, 
                                            CollectedCountry__c = 'AF', 
                                            Purpose__c = 'Cookies', 
                                            CheckBox2Meaning__c = 'MkgGroup', 
                                            CheckBox2Value__c = true,
                                            CheckBox3Meaning__c = 'MkgPOSPhoneSMS', 
                                            CheckBox3Value__c = true, 
                                            CheckBox4Meaning__c = 'MkgBrandPhoneSMS', 
                                            CheckBox4Value__c = true, 
                                            CheckBox5Meaning__c = 'MkgGroupPhoneSMS', 
                                            CheckBox5Value__c = true, 
                                            CheckBox6Meaning__c = 'MkgPOSMail', 
                                            CheckBox6Value__c = true,
                                            TECH_AccountId__c = a.Id);
        insert consent;

		Test.startTest();
			Map<String, Object> map_obj = ConsentsPopUpModalController.getConsents(lstAccts[0].Id);
			Map<String, Object> map_objTwo = ConsentsPopUpModalController.getConsents(null);
			Map<String, Object> map_info = ConsentsPopUpModalController.getUserInfo();
			
			Map<String, Object> map_infoTwo = ConsentsPopUpModalController.getUserInfo();
			JSONGenerator g = JSON.createGenerator(true);			
			g.writeStartObject();
			g.writeFieldName('ids');
			g.writeStartArray();
			g.writeString(lstAccts[0].Id);
			g.writeEndArray();
			g.writeEndObject();

			Map<Id, WorkshopAppointment__c> map_work = ConsentsPopUpModalController.getAppointmentInfo(g.getAsString());

			JSONGenerator ge = JSON.createGenerator(true);			
			ge.writeStartObject();
			ge.writeFieldName('ids');
			ge.writeStartArray();
			ge.writeEndArray();
			ge.writeEndObject();

			Map<Id, WorkshopAppointment__c> map_workTwo = ConsentsPopUpModalController.getAppointmentInfo(ge.getAsString());
		Test.stopTest();
	}
}
@isTest
private class TaskTriggerHandlerTest {

	
    static testMethod void myUnitTest() {
        
        Lead l = new Lead(
                FirstName                   = 'First Name 003',
            	Salutation					=  '1',
                LastName                    = 'LastName 003',
                Street                      = 'Calle Test 372',
                City                        = 'Madrid',
                Country                     = 'España', 
                PostalCode                  = '28012',
                Latitude					=  39.9691,
                Longitude					= -4.8237,
                Phone                       = '915001000',
                //DestinationGeographicalCode__c= acct.Id,
                DestinationPOSCode__c       = '1237771',
                Company                     = 'DEALER TEST COMPANY_0031',
                PSABrand__c                 = 'AP',
                Email                       = 'test@leadexample.com',
                LeadCountry__c              = 'PL',
                LeadRequestType__c 			= '1',
        		IdReservationVD__c 			= '12345323X',
            	status 						= 'Qualified',
            	OwnerId						= UserInfo.getUserId(),
                RecordTypeId                = PAD.getObjRecordType('Lead','B2B'));
        
        insert l;
        
        
       	Task oTask = new Task(Subject = 'Call', priority = 'High', whoid=l.id);
        insert oTask;
        
        test.startTest();
        TaskTriggerHandler.beforeInsert(new List<Task>{oTask});
        TaskTriggerHandler.beforeUpdate(new List<Task>{oTask}, new map<id,task>{oTask.id => oTask});
        TaskTriggerHandler.dontRunTrigger();
        TaskTriggerHandler.shouldRunTrigger();
        test.stopTest();
        
    }

    static testMethod void createTaskWithOwnerLocACall() {     
        List<Task> lstTask = new List<Task>();

        TeleAlert__c teleAlert = new TeleAlert__c(Country__c = 'PT', Brand__c = 'AP');
        insert teleAlert;

        Task task1 = new Task(Subject = 'Call', priority = 'High', WhatId = teleAlert.Id, CallStatus__c = '0');
        lstTask.add(task1);

        Task task2 = new Task(Subject = 'Call', priority = 'High', WhatId = teleAlert.Id, CallStatus__c = '1');
        lstTask.add(task2);
        
        Test.startTest();
            insert lstTask;
        Test.stopTest();

        List<Event> lstEvents = [SELECT Id FROM Event WHERE WhatId = : teleAlert.Id];
        System.assertEquals(0, lstEvents.size());
        
    }
	
}
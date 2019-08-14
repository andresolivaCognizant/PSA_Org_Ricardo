/**
	*   @Class : TaskUtilsTest.cls
	*
	*   @Author         :   Antoine Audollent
	*   @Created        :   15 may 2019
	*   @Description    :   Apex Unit test class for TaskUtils.cls

	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description
	*	   Antoine Audollent		15 may 2019				 Creation.
    *      Pedro Párraga            18/06/2019               Edit. 
	*
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
private class TaskUtilsTest {
    @TestSetup
    static void makeData(){
        TestDataFactoryUtil.createSobject(Constants.SOT_LEAD, new map<String, Object>{
            'FirstName'                => 'First Name 044',
            'Salutation'               =>  '1',
            'LastName'                 => 'LastName 044',
            'Street'                   => 'Calle Test 472',
            'City'                     => 'Madrid',
            'PostalCode'               => '28012',
            'Latitude'                 =>  39.9691,
            'Longitude'                => -4.8237,
            'Phone'                    => '915001000',
            'DestinationPOSCode__c'    => '1237771',
            'PSABrand__c'              => 'AP',
            'Email'                    => 'test4@leadexample.com',
            'LeadRequestType__c'       => '1',
            'IdReservationVD__c'       => '12345323X',
            'status'                   => 'Qualified',
            'OwnerId'                  => UserInfo.getUserId(),
            'LeadCountry__c' 	       => 'FR',
            'Status'                   => 'new',
            'RecordTypeId'             => PAD.recordTypesMapByDeveloperName.get(Constants.RT_LEAD_B2C)
        }, true);

        TeleAlert__c teleAlert_AP_1 = (TeleAlert__c)TestDataFactoryUtil.createSobject(Constants.SOT_TELE_ALERT, new map<String, Object>{
            'Brand__c'		=>	'AP',
            'Country__c'	=>	'CL'
        },true);
        
        TeleAlert__c teleAlert_AP_2 = (TeleAlert__c)TestDataFactoryUtil.createSobject(Constants.SOT_TELE_ALERT, new map<String, Object>{
            'Brand__c'		=>	'AP',
            'Country__c'	=>	'CL'
        },true);

        TestDataFactoryUtil.createSobject(Constants.SOT_TASK, new map<String, Object>{
            'TaskSubtype'	=>	'Call',
            'CallStatus__c' =>  '0',
            'WhatId'		=> teleAlert_AP_1.id
        },true);

        TestDataFactoryUtil.createSobject(Constants.SOT_TASK, new map<String, Object>{
            'TaskSubtype'	=>	'Call',
            'CallStatus__c' =>  '1',
            'WhatId'		=> teleAlert_AP_2.id
        },true);

    }

    @isTest
    static void changeParentLeadStatus_test_01(){
        list<Lead> leads = [Select id, Status from Lead];

        Test.startTest();
        List<Lead> leadsReturned = TaskUtils.changeParentLeadStatus(leads);
        Test.stopTest();

        System.assertEquals('On Going', leadsReturned.get(0).Status, 'TaskUtilsTest -- changeParentLeadStatus_test_01');
    }

    @isTest
    static void manageTeleAlertCalls_test_01(){
        List<Task> tasks = [Select whatid, CallStatus__c , Type from Task];

        Test.startTest();
        TaskUtils.setActivityType(tasks);
        TaskUtils.manageTeleAlertCalls(tasks);
        Test.stopTest();
    }
    
    @isTest 
    static void updateParentTeleAlertCallCounter_test_01(){
        List<Task> tasks = [Select whatid, CallStatus__c, Type from Task];
        
        Test.startTest();
        TaskUtils.updateParentTeleAlertCallCounter(tasks);
        Test.stopTest();
    }

    /**
     * Unit test for TaskUtils.manageLeadCalls method.
     */
    @isTest static void testMethod1(){
        List<Lead> lst_l = new List<Lead>([SELECT Id FROM Lead]);

        List<Task> lst_t = new List<Task>();

        for (Lead l : [SELECT Id FROM Lead]) {
            lst_t.add(new Task(
                WhoId               = l.Id,
                CallStatus__c       = '0'
            ));
        }

        TaskUtils.manageLeadCalls(lst_t);

        for (Task t : lst_t) {
            t.CallStatus__c     = '1';
            t.Call_DNIS__c      = 'XYZ';
        }

        TaskUtils.manageLeadCalls(lst_t);
    }

    /**
     * Unit test for TaskUtils.leadCallbackActions method.
     */
    @isTest static void testMethod2(){
        List<Account> lst_d = Test.loadData(Account.sObjectType, 'LeadsTestData_DealerAccount');

        Map<Id,Lead> map_l = new Map<Id, Lead>([
            SELECT 
                Id,
                OwnerId,
                LeadCountry__c,
                PSABrand__c,
                Activity__c,
                CalculatedPOS__c
            FROM Lead
        ]);

        List<Task> lst_t = new List<Task>();

        for (Lead l : map_l.values()) {
            for (
                Integer i = 0;
                i < LeadUtils.getSubsidiaryConfig(l).CallAttempts__c.intValue();
                i++
            ) {
                lst_t.add(new Task(
                    WhoId               = l.Id,
                    TaskSubtype         = 'Call',
                    CallStatus__c       = '1'
                ));
            }
        }

        insert lst_t;

        Test.startTest();

            TaskUtils.leadCallbackActions(
                map_l.keySet(),
                map_l
            );

            for (Lead l : map_l.values()) {
                l.CalculatedPOS__c = lst_d.get(0).Id;
            }

            update map_l.values();

            map_l = new Map<Id, Lead>([
                SELECT
                    Id,
                    OwnerId,
                    LeadCountry__c,
                    PSABrand__c,
                    Activity__c,
                    CalculatedPOS__c,
                    Customer__c,
                    TreatmentDueDate__c,
                    (
                        SELECT Id
                        FROM Tasks
                    )
                FROM Lead
            ]);

            TaskUtils.leadCallbackActions(
                map_l.keySet(),
                map_l
            );

        Test.stopTest();
    }

    /**
     * Unit test for TaskUtils.telealertCallbackActions method.
     *
     * @author          Diego Rincón
     * @date            2019-05-27
     */
    @isTest static void testMethod3(){
        Map<Id, TeleAlert__c> map_t = new Map<Id, TeleAlert__c>([
            SELECT 
                Id,
                Brand__c,
                Country__c
            FROM TeleAlert__c
        ]);

        List<Task> lst_t = new List<Task>();

        for (TeleAlert__c t : map_t.values()) {
            for (
                Integer i = 0;
                i < ((Decimal) ((Map<String, Object>) TeleAlertUtils.matchingConfig(t)).get('CallAttempts__c')).intValue();
                i++
            ) {
                lst_t.add(new Task(
                    WhatId              = t.Id,
                    TaskSubtype         = 'Call',
                    CallStatus__c       = '1'
                ));
            }
        }

        insert lst_t;

        map_t = new Map<Id, TeleAlert__c>([
            SELECT 
                Id,
                Brand__c,
                Country__c,
                (
                    SELECT Id
                    FROM Tasks
                )
            FROM TeleAlert__c
        ]);

        Test.startTest();

            TaskUtils.telealertCallbackActions(
                map_t.keySet(),
                map_t
            );

        Test.stopTest();
    }

    /**
     * Unit test for TaskUtils.closeTelealertEvents method.
     *
     * @author          Diego Rincón
     * @date            2019-05-27
     */
    @isTest static void testMethod4(){
        Map<Id, TeleAlert__c> map_t = new Map<Id, TeleAlert__c>([
            SELECT 
                Id,
                Brand__c,
                Country__c
            FROM TeleAlert__c
        ]);

        List<Event> lst_e = new List<Event>();

        for (TeleAlert__c t : map_t.values()) {
            lst_e.add(new Event(
                WhatId              = t.Id,
                Status__c           = '0',
                StartDateTime       = System.now(),
                EndDateTime         = System.now().addMinutes(10)
            ));
        }

        insert lst_e;

        Test.startTest();
            TaskUtils.closeTelealertEvents(map_t.keySet());
        Test.stopTest();
    }

    /**
     * Unit test for TaskUtils.closeLeadEvents method.
     *
     * @author          Diego Rincón
     * @date            2019-05-27
     */
    @isTest static void testMethod5(){
        Map<Id,Lead> map_l = new Map<Id, Lead>([
            SELECT 
                Id,
                OwnerId,
                LeadCountry__c,
                PSABrand__c,
                Activity__c,
                CalculatedPOS__c
            FROM Lead
        ]);

        List<Event> lst_e = new List<Event>();

        for (Lead l : map_l.values()) {
            lst_e.add(new Event(
                WhoId               = l.Id,
                Status__c           = '0',
                StartDateTime       = System.now(),
                EndDateTime         = System.now().addMinutes(10)
            ));
        }

        insert lst_e;

        Test.startTest();
            TaskUtils.closeLeadEvents(map_l.keySet());
        Test.stopTest();
    }

    /**
     * Unit test for TaskUtils.updateParentTeleAlertCallCounter method.
     *
     * @author          Diego Rincón
     * @date            2019-05-27
     */
    @isTest static void testMethod6(){
        Map<Id, TeleAlert__c> map_t = new Map<Id, TeleAlert__c>([
            SELECT 
                Id,
                Brand__c,
                Country__c
            FROM TeleAlert__c
        ]);

        List<Task> lst_a = new List<Task>();

        for (TeleAlert__c t : map_t.values()) {
            lst_a.add(new Task(
                WhatId              = t.Id,
                Status              = 'Terminé',
                TaskSubtype         = 'Call'
            ));
        }

        insert lst_a;

        Test.startTest();
            TaskUtils.updateParentTeleAlertCallCounter(lst_a);
        Test.stopTest();
    }
}
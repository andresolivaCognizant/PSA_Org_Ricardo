/**
 * Salesforce
 * @author              Antoine Audollent
 * Project:             PSA - Customer First
 * Description:         Unit tests to cover class TeleAlertUtils
 * Changes (version)
 * -------------------------------------------------------------------------------------------------
 *              No.     Date            Author                  Description
 *              ----    ------------    --------------------    ------------------------------------
 * @version     1.0     2019-05-07      Antoine Audollent       Class creation.
 * @version     1.1     2019-06-10      Diego Rincón            Added external object mocking.
 *                                                              Code coverage: 92%
 */
 @isTest
private class TeleAlertUtilsTest {
    @testSetup
    static void makeData(){
       TeleAlert__c teleAlert = (TeleAlert__c)TestDataFactoryUtil.createSobject(Constants.SOT_TELE_ALERT, new map<String, Object>{
            'Brand__c'      => 'AP',
            'Country__c'    => 'CL'
        },true);
    }

    @isTest
    private static void matchingConfig_test_01(){
        TeleAlert__c teleAlert = [Select id, Country__c, Brand__c from TeleAlert__c Limit 1];

        Test.startTest();
        Map<String, Object> ta = (Map<String, Object>)TeleAlertUtils.matchingConfig(teleAlert);
        Test.stopTest();

        System.assertEquals('AP', ta.get('Brand__c'));
    }
    
    @isTest
    private static void matchingConfig_test_02(){
        TeleAlert__c teleAlert = [Select id, Country__c, Brand__C from TeleAlert__c Limit 1];

        Test.startTest();
        Map<String, Object> ta = (Map<String, Object>)TeleAlertUtils.matchingConfig(new TeleAlert__c(Brand__c = 'AP'));
        Test.stopTest();
        //System.assertEquals('AP', ta.get('Brand__c'));
    }
    
    @isTest
    private static void matchingConfig_test_03(){

        Test.startTest();
        Map<String, Object> ta = (Map<String, Object>)TeleAlertUtils.matchingConfig(new TeleAlert__c(Country__C = 'CL'));
        Test.stopTest();

        //System.assertEquals('AP', ta.get('Brand__c'));
    }

    @isTest
    private static void  eventTreatmentTimeMatch_test_01() {
        TeleAlert__c teleAlert = [Select id, Country__c, Brand__C from TeleAlert__c Limit 1];
        VehicleEvent__x VehicleEvent = new VehicleEvent__x(telealertid__c = teleAlert.id, alertcode__c = '1');
        Database.SaveResult sr = Database.insertAsync(VehicleEvent);

        VehicleEvent.telealertid__r = teleAlert;

        Test.startTest();
        Map<String, Object> tt = (Map<String, Object>)TeleAlertUtils.eventTreatmentTimeMatch(VehicleEvent);
        
        Test.stopTest();

        System.assertEquals('2', tt.get('AlertCategory__c'));
    }
    
    @isTest
    private static void  eventTreatmentTimeMatch_test_02() {
        VehicleEvent__x VehicleEvent = new VehicleEvent__x(telealertid__r = new teleAlert__c(), alertcode__c = 'Maintenace');
        Database.SaveResult sr = Database.insertAsync(VehicleEvent);

        
        Test.startTest();
        Map<String, Object> tt = (Map<String, Object>)TeleAlertUtils.eventTreatmentTimeMatch(VehicleEvent);
        Test.stopTest();

		System.assertEquals('2', tt.get('AlertCategory__c'));
    }
    
    @isTest static void eventBillabilityMatch_test_01(){
        TeleAlert__c teleAlert = [Select id, Country__c, Brand__C from TeleAlert__c Limit 1];
        VehicleEvent__x VehicleEvent = new VehicleEvent__x(telealertid__c = teleAlert.id, alerttypecode__c = '25');//ABS system fault
        Database.SaveResult sr = Database.insertAsync(VehicleEvent);

        VehicleEvent.telealertid__r = teleAlert;

        Test.startTest();
        Map<String, Object> tt = (Map<String, Object>)TeleAlertUtils.eventBillabilityMatch(VehicleEvent);
        
        Test.stopTest();

        //System.assertEquals('25', tt.get('Type__c'));
    }
    
    @isTest static void eventBillabilityMatch_test_02(){
        TeleAlert__c teleAlert = [Select id, Country__c, Brand__C from TeleAlert__c Limit 1];
        VehicleEvent__x VehicleEvent = new VehicleEvent__x(telealertid__c = teleAlert.id, alertcode__c = '25');//ABS system fault
        Database.SaveResult sr = Database.insertAsync(VehicleEvent);

        VehicleEvent.telealertid__r = teleAlert;

        Test.startTest();
        Map<String, Object> tt = (Map<String, Object>)TeleAlertUtils.eventBillabilityMatch(VehicleEvent);
        
        Test.stopTest();

        //System.assertEquals('25', tt.get('Type__c'));
    }
        
    @isTest
    static void hasUserTakenOwnership_test_01(){
        Group g = (Group)TestDataFactoryUtil.createSobject('Group', new map<String, Object>{
            'name' => 'group test'
        },true);
        
        TeleAlert__c teleAlert = [Select id, Country__c, Brand__C, Account__c, OwnerId, Status__c from TeleAlert__c Limit 1];
        TeleAlert__c teleAlertCloned = teleAlert.clone(true);
        teleAlert.ownerId = g.id; 
        teleAlert.status__C = '1'; 
        
        
        system.debug('here ' + teleAlert);

        Test.startTest();
        TeleAlertUtils.hasUserTakenOwnership(new map<id, TeleAlert__c> {teleAlert.id => teleAlert}, new map<id, TeleAlert__c> {teleAlertCloned.id => teleAlertCloned});
        Test.stopTest();

        //System.assertEquals('AP', ta.get('Brand__c'));
    }
    
    @isTest
    static void hasUserTakenOwnership_test_02(){
        TeleAlert__c teleAlert = [Select id, Country__c, Brand__C, Account__c, OwnerId, Status__c from TeleAlert__c Limit 1];
        TeleAlert__c teleAlertCloned = teleAlert.clone(true);
        

        Test.startTest();
        TeleAlertUtils.hasUserTakenOwnership(new map<id, TeleAlert__c> {teleAlert.id => teleAlert}, new map<id, TeleAlert__c> {teleAlertCloned.id => teleAlertCloned});
        Test.stopTest();

        //System.assertEquals('AP', ta.get('Brand__c'));
    }
    
    
    @isTest
    static void isStatusChanged_test_01(){
        TeleAlert__c teleAlert = [Select id, Country__c, Brand__C, Account__c, OwnerId, Status__c from TeleAlert__c Limit 1];
        TeleAlert__c teleAlertCloned = teleAlert.clone(true);
        

        Test.startTest();
        TeleAlertUtils.isStatusChanged(new map<id, TeleAlert__c> {teleAlert.id => teleAlert}, new map<id, TeleAlert__c> {teleAlertCloned.id => teleAlertCloned});
        Test.stopTest();

        //System.assertEquals('AP', ta.get('Brand__c'));
    }
    
    @isTest
    static void isStatusChanged_test_02(){
        TeleAlert__c teleAlert = [Select id, Country__c, Brand__C, Account__c, OwnerId, Status__c from TeleAlert__c Limit 1];
        TeleAlert__c teleAlertCloned = teleAlert.clone(true);
        teleAlertCloned.status__c = '3';

        Test.startTest();
        TeleAlertUtils.isStatusChanged(new map<id, TeleAlert__c> {teleAlert.id => teleAlert}, new map<id, TeleAlert__c> {teleAlertCloned.id => teleAlertCloned});
        Test.stopTest();

        //System.assertEquals('AP', ta.get('Brand__c'));
    }
    
    @isTest
    static void isStatusChanged_test_03(){
        TeleAlert__c teleAlert = [Select id, Country__c, Brand__C, Account__c, OwnerId, Status__c from TeleAlert__c Limit 1];
        TeleAlert__c teleAlertCloned = teleAlert.clone(true);
        teleAlertCloned.status__c = '4';

        Test.startTest();
        TeleAlertUtils.isStatusChanged(new map<id, TeleAlert__c> {teleAlert.id => teleAlert}, new map<id, TeleAlert__c> {teleAlertCloned.id => teleAlertCloned});
        Test.stopTest();

        //System.assertEquals('AP', ta.get('Brand__c'));
    }
    
    @isTest
    static void isStatusChanged_test_04(){
        TeleAlert__c teleAlert = [Select id, Country__c, Brand__C, Account__c, OwnerId, Status__c from TeleAlert__c Limit 1];
        TeleAlert__c teleAlertCloned = teleAlert.clone(true);
        teleAlertCloned.status__c = '5';

        Test.startTest();
        TeleAlertUtils.isStatusChanged(new map<id, TeleAlert__c> {teleAlert.id => teleAlert}, new map<id, TeleAlert__c> {teleAlertCloned.id => teleAlertCloned});
        Test.stopTest();

        //System.assertEquals('AP', ta.get('Brand__c'));
    }
    
    @isTest
    static void isStatusChanged_test_05(){
        TeleAlert__c teleAlert = [Select id, Country__c, Brand__C, Account__c, OwnerId, Status__c from TeleAlert__c Limit 1];
        TeleAlert__c teleAlertCloned = teleAlert.clone(true);
        teleAlertCloned.status__c = '6';

        Test.startTest();
        TeleAlertUtils.isStatusChanged(new map<id, TeleAlert__c> {teleAlert.id => teleAlert}, new map<id, TeleAlert__c> {teleAlertCloned.id => teleAlertCloned});
        Test.stopTest();

        //System.assertEquals('AP', ta.get('Brand__c'));
    }
    
    @isTest
    static void setCallCount_test_01(){
        TeleAlert__c teleAlert = [Select id, Country__c, Brand__C, Account__c, OwnerId, Status__c from TeleAlert__c Limit 1];
        Task task = (Task)TestDataFactoryUtil.createSobject(Constants.SOT_TASK, new map<String, Object>{
            'TaskSubtype'   => 'Call',
            'WhatId'        => teleAlert.id
        },true);
        
        Test.startTest();
        TeleAlertUtils.setCallCount(new map<id, TeleAlert__c> {teleAlert.id => teleAlert});
        Test.stopTest();
    }

    /**
     * Unit test for TeleAlertUtils.AsyncUpdateTeleAlertEvents subclass.
     *
     * @author          Diego Rincón
     * @date            2019-06-10
     */
    @isTest static void testMethod2(){
        Map<Id, TeleAlert__c> map_t = new Map<Id, TeleAlert__c>([
            SELECT Id, Brand__c, Country__c FROM TeleAlert__c
        ]);

        Group q = new Group(
            Name = 'TeleAlertUtils Test Queue',
            DeveloperName = 'TeleAlertUtilsTestQueue',
            Type = 'Queue'
        );

        insert q;

        for (TeleAlert__c t : map_t.values()) {
            t.TECH_LastQueueId__c = q.Id;
        }

        update map_t.values();

        TeleAlertUtils.TEST_EXT_OBJ_MOCK = new List<Map<String, Object>>{
            new Map<String,Object>{
                'pcscontractnumber__c'  => 538447,
                'telealertid__r'        => map_t.values().get(0)
            },
            new Map<String,Object>{
                'pcscontractnumber__c'  => null,
                'telealertid__r'        => map_t.values().get(0)
            }
        };

        Test.startTest();
            TeleAlertUtils.AsyncUpdateTeleAlertEvents j = 
                new TeleAlertUtils.AsyncUpdateTeleAlertEvents(map_t.keySet());
            System.enqueueJob(j);
        Test.stopTest();
    }
}
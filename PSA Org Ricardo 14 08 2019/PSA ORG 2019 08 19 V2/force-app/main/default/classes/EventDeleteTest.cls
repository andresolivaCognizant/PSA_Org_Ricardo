/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class EventDeleteTest {

  @testSetup
  static void setupTestData(){
    test.startTest();
    WorkOrder workorder_Obj = new WorkOrder(IsStopped = false, FSL__IsFillInCandidate__c = false, FSL__Prevent_Geocoding_For_Chatter_Actions__c = false);
    Insert workorder_Obj; 
    Event event_Obj = new Event(WhatId = workorder_Obj.id, IsAllDayEvent = false, StartDateTime = DateTime.now(), EndDateTime = DateTime.now(), Description = '15', IsPrivate = false, IsRecurrence = false, IsReminderSet = false, HotOpportunity__c = false, AutomatedCreation__c = false, IsAllDayEvent__c = false);
    Insert event_Obj;  
    test.stopTest();
  }
  static testMethod void test_deleteEvent_UseCase1(){
    List<Event> event_Obj  =  [SELECT WhatId,IsAllDayEvent,IsPrivate,IsRecurrence,IsReminderSet,HotOpportunity__c,AutomatedCreation__c,IsAllDayEvent__c from Event];
    System.assertEquals(true,event_Obj.size()>0);
    EventDelete obj01 = new EventDelete();
    
    EventDelete.WrapperEvent obj11 = new EventDelete.WrapperEvent();               
        obj11.sAppId = event_Obj[0].WhatId;  
        
    EventDelete.deleteEvent(new List<EventDelete.WrapperEvent>{obj11});
  }
}
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
private class EventCalendarControllerTest{

  @testSetup
  static void setupTestData(){
    test.startTest();
    WorkOrder workorder_Obj = new WorkOrder(IsStopped = false, FSL__IsFillInCandidate__c = false, FSL__Prevent_Geocoding_For_Chatter_Actions__c = false);
    Insert workorder_Obj; 
    Event event_Obj = new Event(WhatId = workorder_Obj.id, IsAllDayEvent = false, StartDateTime = DateTime.now(), EndDateTime = DateTime.now(), Description = '15', IsPrivate = false, IsRecurrence = false, IsReminderSet = false, HotOpportunity__c = false, AutomatedCreation__c = false, IsAllDayEvent__c = false);
    Insert event_Obj; 
    test.stopTest();
  }
  static testMethod void test_getEventos_UseCase1(){
    List<Event> event_Obj  =  [SELECT Id,WhoId,WhatId,Subject,StartDateTime,EndDateTime,Description,AccountId from Event];
    System.assertEquals(true,event_Obj.size()>0);
    List<WorkOrder> workorder_Obj  =  [SELECT Id from WorkOrder];
    System.assertEquals(true,workorder_Obj.size()>0);
    EventCalendarController obj01 = new EventCalendarController();
    EventCalendarController.getEventos();
  }
   static testMethod void test_WrapperResult(){
    List<Event> event_Obj  =  [SELECT Id,WhoId,WhatId,Subject,StartDateTime,EndDateTime,Description,AccountId from Event];
    System.assertEquals(true,event_Obj.size()>0);
    List<WorkOrder> workorder_Obj  =  [SELECT Id from WorkOrder];
    System.assertEquals(true,workorder_Obj.size()>0);
    EventCalendarController obj01 = new EventCalendarController();
    EventCalendarController.WrapperResult obj21 = new EventCalendarController.WrapperResult();
  }
}
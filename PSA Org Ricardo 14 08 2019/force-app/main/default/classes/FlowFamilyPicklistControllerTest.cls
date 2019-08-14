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
private class FlowFamilyPicklistControllerTest {
 
  @testSetup
  static void setupTestData(){
    test.startTest();
    ServiceResource serviceresource_Obj = new ServiceResource(RelatedRecordId=UserInfo.getUserId(), Name = 'Name245', IsActive = true, IsCapacityBased = false, IsOptimizationCapable = false, EnergyCode__c = '581', EnergyDescription__c = 'Energ334', FamilyCode__c = '969', FamilyDescription__c = 'Famil127', GearboxCode__c = '1', GearboxDescription__c = 'Gearb930', ShapeCode__c = '19', ShapeDescription__c = 'Shape726', isAvailable__c = false, Country__c = 'FR');
    Insert serviceresource_Obj; 
    test.stopTest();
  }
  static testMethod void test_getFamilyData_UseCase1(){
    List<ServiceResource> serviceresource_Obj  =  [SELECT Name,IsActive,IsCapacityBased,IsOptimizationCapable,EnergyCode__c,EnergyDescription__c,FamilyCode__c,FamilyDescription__c,GearboxCode__c,GearboxDescription__c,ShapeCode__c,ShapeDescription__c,isAvailable__c from ServiceResource];
    System.assertEquals(true,serviceresource_Obj.size()>0);
    FlowFamilyPicklistController obj01 = new FlowFamilyPicklistController();
    FlowFamilyPicklistController.getFamilyData('test data',new List<Id>());
  }
}
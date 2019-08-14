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

/**
    *   @Class : ActivityTimeline_ControllerTest.cls
    *
    *   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
    *   @Created        :   21 Feb 2018
    *   @Description    :   Apex Unit test class for ActivityTimeline_ControllerTest.csl
    
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description
    *      Rubén Moreno             17/4/2018                 Creation.  
    *           
    *   ----------------------------------------------------------------------------------------------------------------------------
**/


@isTest
private class ActivityTimeline_ControllerTest {

    static testMethod void myUnitTest() {
  		Lead oLead  = new Lead(
            FirstName                   = 'Test1', 
            LocalIdOfCustomer__c		= '123452',
            LastName                    = 'Last',
            Street                      = 'Calle de Sebastián Elcano ',
            City                        = 'Madrid',
            Country                     = 'España', 
            Phone                       = '79834',
            NationalId__c               = '12342',
            Company                     = ' TEST COMPANY_',
            BrandOwnedVehicle__c        = 'DS',
            Email                       = 'test@example.com',
            TreatmentDueDate__c			= System.now(),
            LeadRequestType__c			= '1',
            LeadAttemptCalls__c			= 3
            
        );
        insert oLead;
        
		Id recordId = UserInfo.getUserId();
        List<ActivityTimeline_Model> returnList = new List<ActivityTimeline_Model>();
        Task oTask = new Task(Subject = 'Call', CallStatus__c = '0', Activitydate = System.today(), whoid =oLead.id,Status='Complete' );
        Task oTask1 = new Task(Subject = 'Call', CallStatus__c = '0', Activitydate = System.today(), whoid =oLead.id);
        insert new List<Task> {oTask,oTask1};
        
        test.startTest();
		ActivityTimeline_Controller.addCalls(returnList, recordId);
        ActivityTimeline_Controller.addEmails(returnList, recordId);
        ActivityTimeline_Controller.addMeetings(returnList, recordId);
        ActivityTimeline_Controller.addTasks(returnList, recordId);
        ActivityTimeline_Controller.getActivityTimeline(recordId);
        test.stopTest();

        
    }
}
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
	*   @Class : TaskRelatedLeadTest.cls
	*
	*   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
	*   @Created        :   15 Feb 2018
	*   @Description    :   Apex Unit test class for TaskRelatedLeadTest.cls
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description
	*	   Rubén Moreno				15 Feb 2018				 Creation.	
	*	   
	*   ----------------------------------------------------------------------------------------------------------------------------
**/




@isTest
public class TaskRelatedLeadTest {

    @TestSetup
    static void makeData(){
        User u = TestDataFactoryUtil.createUserCreatorDataSet();

        system.runAs(u){

            Lead lead1 = TestDataFactoryUtil.createLead(new map<String, Object>{
                'FirstName'                 => 'First Name ', 
                'LocalIdOfCustomer__c'		=> '12345',
                'LastName'                  => 'Lastname 1',
                'Street'                    => 'Calle de Sebastián Elcano ',
                'City'                      => 'Madrid',
                'Country'                   => 'España', 
                'Phone'                     => '79834',
                'NationalId__c'             => '1234',
                'Company'                   => ' TEST COMPANY_',
                'BrandOwnedVehicle__c'      => 'DS',
                'Email'                     => 'test@example.com',
                'TreatmentDueDate__c'		=> System.now(),
                'LeadRequestType__c'		=> '1',
                'LeadAttemptCalls__c'       => 5
            }, true);

            System.debug('##### HERE LEAD: ' + lead1.IsConverted);
            System.debug('##### HERE LEAD: ' + lead1.LeadAttemptCalls__c);

            Lead lead2 = TestDataFactoryUtil.createLead(new map<String, Object>{
                'FirstName'                 => 'First Name ', 
                'LocalIdOfCustomer__c'		=> '12345',
                'LastName'                  => 'Lastname 2',
                'Street'                    => 'Calle de Sebastián Elcano ',
                'City'                      => 'Madrid',
                'Country'                   => 'España', 
                'Phone'                     => '79834',
                'NationalId__c'             => '1234',
                'Company'                   => ' TEST COMPANY_',
                'BrandOwnedVehicle__c'      => 'DS',
                'Email'                     => 'test@example.com',
                'TreatmentDueDate__c'		=> System.now(),
                'LeadRequestType__c'		=> '1'
            }, true);
            
            Task task1 = TestDataFactoryUtil.createTask(new map<String, Object>{
                'Subject'       => 'Call',
                'CallStatus__c' => '0',
                'Activitydate'  => System.today(),
                'whoid'         => lead1.id
            }, true);

            Task task2 = TestDataFactoryUtil.createTask(new map<String, Object>{
                'Subject'       => 'Call',
                'CallStatus__c' => '1',
                'Activitydate'  => System.today(),
                'whoid'         => lead1.id
            }, true);

            Task task3 = TestDataFactoryUtil.createTask(new map<String, Object>{
                'Subject'       => 'Call',
                'CallStatus__c' => '0',
                'Activitydate'  => System.today(),
                'whoid'         => lead2.id
            }, true);

            Task task4 = TestDataFactoryUtil.createTask(new map<String, Object>{
                'Subject'       => 'Call',
                'CallStatus__c' => '1',
                'Activitydate'  => System.today(),
                'whoid'         => lead2.id
            }, true);

        }
    }
	

	@isTest static void myUnitTest() {
        
        User u = TestDataFactoryUtil.getTestorUser();

        System.runAs(u){
            list<Task> tasks = [Select id, Subject, CallStatus__c, Activitydate, whoid from Task];

            Test.startTest();
            TaskRelatedLead.manageCallsToLeads(tasks);
            Test.stopTest();
        }

        
	}
	

	
}
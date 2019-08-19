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
    *   @Class : ActivityTimeLine_ModelTest.cls
    *
    *   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
    *   @Created        :   21 Feb 2018
    *   @Description    :   Apex Unit test class for ActivityTimeLine_ModelTest.csl
    
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description
    *      Rubén Moreno             17/4/2018                 Creation.  
    *           
    *   ----------------------------------------------------------------------------------------------------------------------------
**/


@isTest
private class ActivityTimeLine_ModelTest {

    static testMethod void myUnitTest() {
  		
		
        test.startTest();
        ActivityTimeline_Model ctr = new ActivityTimeline_Model();
        ctr.ActualDate = system.now();
        ctr.ActivityTimelineType = 'Test';
        ctr.Assigned = 'Test';
        ctr.Complete = true;
        ctr.Detail = 'test';
        ctr.EventTime = 'test';
        ctr.Recipients = 'Test';
        ctr.RecordId = UserInfo.getProfileId();
        ctr.ShortDate = 'Test';
        ctr.Subject='Test class';
        ctr.compareTo(ctr);
        test.stopTest();

        
    }
}
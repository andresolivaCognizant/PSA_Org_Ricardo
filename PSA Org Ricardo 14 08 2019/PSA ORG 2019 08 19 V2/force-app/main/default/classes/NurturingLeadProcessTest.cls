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
    *   @Class : NurturingLeadProcessTest.cls
    *
    *   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
    *   @Created        :   3 Feb 2018
    *   @Description    :   Apex Unit test class for NurturingLeadProcess.cls
    
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description
    *      Rubén Moreno             15/6/2018                 Creation.  
    *           
    *   ----------------------------------------------------------------------------------------------------------------------------
**/


@isTest
private class NurturingLeadProcessTest {

    static testMethod void myUnitTest() {
        
        Lead oLead  = new Lead(
                FirstName                   = 'Test 001', 
                LastName                    = 'Version1',
                PSABrand__c                 = 'AP',
                Email                       = 'psaLead@leadexample.com',
                LeadCountry__c              = 'AZ',
            	NationalId__c				= '0909843X',
            	PurchaseIntentionPeriod__c	= '1',
            	LeadRequestType__c			= '1'
            
            
        );
        
        insert oLead;
        
        test.startTest();
        NurturingLeadProcess.mainProcess(new list<Lead>{oLead});
        //System.assertEquals(true, oLead.TECH_NurturingLead__c);
        test.stopTest();
        
    }

}
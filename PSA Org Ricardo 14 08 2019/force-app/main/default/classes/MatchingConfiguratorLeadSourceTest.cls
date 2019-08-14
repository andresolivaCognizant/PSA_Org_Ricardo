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
    *   @Class : MatchingConfiguratorLeadSourceTest.cls
    *
    *   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
    *   @Created        :   3 Feb 2018
    *   @Description    :   Apex Unit test class for MatchingConfiguratorLeadSource.cls
    
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description
    *      Rubén Moreno             28/5/2018                Creation.  
    *           
    *   ----------------------------------------------------------------------------------------------------------------------------
**/


@isTest
private class MatchingConfiguratorLeadSourceTest {

    static testMethod void myUnitTest() {
        
        Account acct = new Account(
            	Salutation									  =	  '1',
                FirstName                                     =   'TEST matching',
                LastName                                      =   'Configurator',
                BillingPostalCode                             =   '23456',
                BillingStreet                                 =   'Calle de Sebastián Elcano ',
            	PersonEmail									  =   'test@test.com',
                PersonalEmail__pc							  =	  'test@test.com',
                RecordTypeId                                  =   Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2C_PA').getRecordTypeId()
             );
        
        insert acct;
        
        
        Lead oLead = new Lead(
            FirstName                   = 'Test 001', 
            LastName                    = 'Version1',
            PSABrand__c                 = 'AP',
            Email                       = 'test@test.com',
            LeadCountry__c              = 'AZ',
            NationalId__c				= '0909843X'
        );
        
        insert oLead;
        
        test.startTest();        
        MatchingConfiguratorLeadSource.mainProcess(new List<Lead>{oLead});
        test.stopTest();

        
    }
}
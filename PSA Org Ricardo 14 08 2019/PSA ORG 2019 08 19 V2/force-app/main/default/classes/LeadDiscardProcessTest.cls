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
    *   @Class : LeadDiscardProcessTest.cls
    *
    *   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
    *   @Created        :   3 Feb 2018
    *   @Description    :   Apex Unit test class for LeadDiscardProcessTest.csl
    
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description
    *      Rubén Moreno             3/2/2018                 Creation.  
    *           
    *   ----------------------------------------------------------------------------------------------------------------------------
**/


@isTest
private class LeadDiscardProcessTest {

    static testMethod void myUnitTest() {
        
        Lead oLead1  = new Lead(
                FirstName                   = 'Test 001', 
                LastName                    = 'Version1',
                Phone                       = '956789876',
                PSABrand__c                 = 'AP',
                Email                       = 'psaLead@leadexample.com',
                LeadCountry__c              = 'AZ',
            	NationalId__c				= '0909843X'
        );
        
        Lead oLead2  = new Lead(
                FirstName                   = 'Test 001', 
                LastName                    = 'Version1',
                Phone                       = '95645876',
                PSABrand__c                 = 'AC',
                Email                       = 'psaLead2@leadexample.com',
                LeadCountry__c              = 'AZ',
            	NationalId__c				= '0909823X'
        );
        
        Lead oLead3  = new Lead(
                FirstName                   = 'XXXXXX', 
                LastName                    = 'YYYYYY',
                Phone                       = '6898945',
                PSABrand__c                 = 'AC',
                Email                       = 'psaLead3@leadexample.com',
                LeadCountry__c              = 'AZ',
            	NationalId__c				= '0909873X'
        );
        
        BlackList__c bPhone = new BlackList__c(
            PhoneMatchType__c		='1',
            Brand__c				='AP', 
            Country__c				='AZ',
            Phone__c				='9567',
            FirstNameMatchType__c 	= '2',
            FirstName__c 			= '001'
        );

        BlackList__c bEmail = new BlackList__c(
            EmailMatchType__c		='0',
            Email__c				='psaLead@leadexample.com',
            Brand__c				='All', 
            Country__c				='ES',
            LastNameMatchType__c 	= '3',
            LastName__c 			= 'Version'
        );

        BlackList__c bLName = new BlackList__c(
            Brand__c				='All', 
            Country__c				=null,
            LastNameMatchType__c 	= '3',
            LastName__c 			= 'Version'
        );
        
        BlackList__c bFName = new BlackList__c(
            Brand__c				='All', 
            Country__c				=null,
            FirstNameMatchType__c 	= '0',
            FirstName__c 			= 'Test 001'
        );
        
		List<BlackList__c> lBlacklist = new List<BlackList__c>{bLName,bEmail,bPhone,bFName};
        
        insert new List<Lead>{oLead1,oLead2,oLead3};
        insert lBlacklist;


        test.startTest();
        LeadDiscardProcess.mainProcess(new List<Lead>{oLead1,oLead2,oLead3});
        LeadDiscardProcess.matchFunction(null,'','');
        LeadDiscardProcess.matchFunction('4','','');
        LeadDiscardProcess.matchFunction('1','Test V1','Test');
        LeadDiscardProcess.matchFunction('2','Test V1','V1');
        LeadDiscardProcess.matchFunction('3','Test V1','V1');
        System.assertEquals(LeadDiscardProcess.matchExact('1234','1234'), '1');
        System.assertEquals(LeadDiscardProcess.matchContains('Test V1','V2'), '0');
        System.assertEquals(LeadDiscardProcess.matchStartWith('Test V1','Test'), '1');
        System.assertEquals(LeadDiscardProcess.matchEndWith('Test V1','V1'), '1');
        test.stopTest();

        
    }
}
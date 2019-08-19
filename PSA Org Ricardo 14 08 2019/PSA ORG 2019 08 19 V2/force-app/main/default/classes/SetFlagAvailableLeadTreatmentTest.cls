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
    *   @Class : SetFlagAvailableLeadTreatmentTest.cls
    *
    *   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
    *   @Created        :   13 Feb 2018
    *   @Description    :   Apex Unit test class for SetFlagAvailableLeadTreatment.cls
    
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description
    *      Rubén Moreno             09/05/2018               Creation.  
    *      Pedro Párraga            18/06/2019               Edit. 
    *           
    *   ----------------------------------------------------------------------------------------------------------------------------
**/


@isTest
private class SetFlagAvailableLeadTreatmentTest {

    static testMethod void SetFlagTreatmentTest() {
		
        Account oAccount = new Account(
                Name                                          =   'TEST MATCH B2B2',
                phone                                         =   '+8432434',
                BillingPostalCode                             =   '2345263',
            	OwnerId										  =   UserInfo.getUserId(),
                RecordTypeId                                  =   PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2B)
        );
        
        insert oAccount;		
        
        Contact oContact =   new Contact (
            FirstName           =   'Contact_FirstName_Test',
            LastName            =   'Contact_LastName_Test',
            Salutation          =   '1',
            Phone               =   '9867767',
            AccountId           =   oAccount.Id,
            OwnerId				=  UserInfo.getUserId(),
            Email				= 'contact1@gmail.com',
            AvailableLeadTreatment__c=false
            
        );
        
        Contact oContact1 =   new Contact (
            FirstName           =   'Contact_FirstName_Test1',
            LastName            =   'Contact_LastName_Test1',
            Salutation          =   '1',
            Phone               =   '98677671',
            AccountId           =   oAccount.Id,
            OwnerId				=  UserInfo.getUserId(),
            Email				= 'contact11@gmail.com',
            AvailableLeadTreatment__c=true
            
        );

        insert new List<Contact>{oContact,oContact1};
            
        test.startTest();
        	oContact.TECH_EnableForLeadTreatment__c = system.now();
        	oContact1.TECH_EnableForLeadTreatment__c = system.now();
        	update new List<Contact>{oContact,oContact1};
        	SetFlagAvailableLeadTreatment.setFlag(new List<Contact>{oContact}, new map<Id,Contact> {oContact.id=>oContact});
			SetFlagAvailableLeadTreatment.setFlag(new List<Contact>{oContact1}, new map<Id,Contact> {oContact1.id=>oContact1});        
        test.stopTest();
    }
}
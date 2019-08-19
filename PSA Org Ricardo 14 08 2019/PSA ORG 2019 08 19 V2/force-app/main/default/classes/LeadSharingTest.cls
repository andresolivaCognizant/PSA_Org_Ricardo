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
    *   @Class : LeadSharingTest.cls
    *
    *   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
    *   @Created        :   3 Feb 2018
    *   @Description    :   Apex Unit test class for LeadSharingTest.csl
    
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description
    *      Rubén Moreno             23/4/2018                 Creation.  
    *      Pedro Párraga            18/06/2019                Edit. 
    *           
    *   ----------------------------------------------------------------------------------------------------------------------------
**/


@isTest
private class LeadSharingTest {

    static testMethod void myUnitTest() {      
        Group g = new Group(
        	Name = 'Test Public Group'
        );
        
        insert g;
        
        Account acct = new Account(
                Name                                          =   'TEST matching',
                BillingPostalCode                             =   '23456',
                BillingStreet                                 =   'Calle de Sebastián Elcano ',
                TECH_PublicGroups__c                          =   g.Id,
                RecordTypeId                                  =   Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2B').getRecordTypeId()
        );
        
        insert acct;
        
        Contact cnt = new Contact(
                AccountId                       =   acct.Id,
                Firstname                       =   'TEST ',
                MailingStreet                   =   'Calle TEST',
                MailingPostalCode               =   '23456',
                Lastname                        =   'MATCH',
                NationalId__c                   =   '72001332H',
                Salutation                      =   '1',
                PersonalEmail__c                =   'a@a.com',
                Phone                           =   '334543'
                
        );

        insert cnt;
        
        List<Contact> lstConts      = new List<Contact>();
        lstConts.add(cnt);
                  
        List<User> lUser = 	TestDataFactoryUtil.createUser(lstConts ,'Salesman','Partner','Manager');
        insert lUser;
        
        Lead oLead;
        if(lUser!=null && !lUser.isEmpty()){
            oLead  = new Lead(
                FirstName                   = 'Test 001', 
                LastName                    = 'Version1',
                Phone                       = '956789876',
                PSABrand__c                 = 'AP',
                Email                       = 'psaLead@leadexample.com',
                LeadCountry__c              = 'AZ',
            	NationalId__c				= '72001332H',
                OwnerId 					= lUser[0].id
        	);
        
        	insert oLead;
               
            LeadShare leadShr  = new LeadShare();// Create new sharing object	                
            leadShr.LeadId = oLead.id;//Set the ID of record being shared.
            leadShr.UserOrGroupId = userinfo.getUserId();// Set the ID of user being granted access				
            leadShr.LeadAccessLevel = 'Edit';// Set the access level.
            leadShr.RowCause = Schema.LeadShare.RowCause.Manual;// Set rowCause to 'manual' for manual sharing.
            insert leadShr;
            
            oLead.OwnerId = userinfo.getUserId();
            update oLead;
            
        }   
        
        Test.startTest();        
            LeadSharing.grantAccessToLead(
                new List<Lead>{oLead},
                new map<Id,Lead>{oLead.id => new Lead(Id = oLead.id,  CalculatedPOS__c = acct.Id)});
        Test.stopTest();

        
    }
}
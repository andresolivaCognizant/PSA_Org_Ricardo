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
	*   @Class : EventUtilTest.cls
	*
	*   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
	*   @Created        :   07 Feb 2018
	*   @Description    :   Apex Unit test class for EventUtilTest.cls
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description
	*	   Rubén Moreno				07 Feb 2018				 Creation.	
	*	   
	*   ----------------------------------------------------------------------------------------------------------------------------
**/


@IsTest
public class EventUtilTest {
	
    static testMethod void myUnitTest() {
    	Account acct = new Account(
                Name                            =   'TEST matching',
                BillingPostalCode               =   '23456',
                BillingStreet                   =   'Calle de Sebastián Elcano ',
                RecordTypeId                    =   Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account_DealerPartner').getRecordTypeId()
             );
        
        insert acct;
		contact cnt = new contact(
                AccountId                       =   acct.Id,
                Firstname                       =   'TEST ',
                MailingStreet                   =   'Calle TEST',
                MailingPostalCode               =   '23456',
                Lastname                        =   'MATCH',
                NationalId__c                   =   '30.686.957-4',
                Salutation                      =   '1',
                PersonalEmail__c                =   'a@a.com',
                Phone                           =   '334543'
            );
        insert cnt;
        
        List<Contact> lstConts      = new List<Contact>();
        lstConts.add(cnt);
        
        List<User> lUser 			= 	TestDataFactoryUtil.createUser(lstConts ,'Salesman','Partner','Manager');
        insert lUser;

        List<Lead> lstLeads 		= new List<Lead>();       
                
        Lead oLead  = new Lead(
                FirstName                   = 'First Name ', 
            	LocalIdOfCustomer__c		= '12345',
                LastName                    = 'Last',
                Street                      = 'Calle de Sebastián Elcano ',
                City                        = 'Madrid',
                Country                     = 'España', 
                Phone                       = '79834',
                NationalId__c               = '1234',
                Company                     = ' TEST COMPANY_',
                BrandOwnedVehicle__c        = 'DS',
                Email                       = 'test@example.com',
            	TreatmentDueDate__c			= System.now(),
            	LeadRequestType__c			= '1'
        );
        
        insert oLead;
        
		oLead.OwnerId = lUser[0].Id;
        update oLead;

        lstLeads.add(oLead);
        
        EventUtil.WrapperActivity wrp = new EventUtil.WrapperActivity();               
        wrp.idAssignedTo = lUser[0].Id; //if there is an error, check TestDataFactoryUtil.createUser.
        wrp.sNameActivityProcess = 'Task Event';
        wrp.idsObject = oLead.Id;
        
        EventUtil.WrapperActivity wrp2 = new EventUtil.WrapperActivity();               
        wrp2.idAssignedTo = lUser[0].Id; //if there is an error, check TestDataFactoryUtil.createUser.
        wrp2.sNameActivityProcess = 'TECH_EventUtilTestV2';
        wrp2.idsObject = oLead.Id;
          
        EventUtil.WrapperActivity wrp1 = new EventUtil.WrapperActivity();                
        wrp1.idAssignedTo = lUser[0].Id; //if there is an error, check TestDataFactoryUtil.createUser.
        wrp1.sNameActivityProcess = 'TECH_EventUtilTest';
        wrp1.idsObject = oLead.Id;
        
        EventUtil.WrapperActivity wrp3 = new EventUtil.WrapperActivity();                
        wrp1.idAssignedTo = lUser[0].Id; //if there is an error, check TestDataFactoryUtil.createUser.
        wrp1.sNameActivityProcess = 'TECH_EventUtilTestV3';
        wrp1.idsObject = oLead.Id;

        EventUtil.WrapperActivity wrp4 = new EventUtil.WrapperActivity();                
        wrp4.idAssignedTo = lUser[0].Id; //if there is an error, check TestDataFactoryUtil.createUser.
        wrp4.sNameActivityProcess = 'TECH_EventUtilTestV4';
        wrp4.idsObject = oLead.Id; 

        EventUtil.WrapperActivity wrp5 = new EventUtil.WrapperActivity();                
        wrp5.idAssignedTo = lUser[0].Id; //if there is an error, check TestDataFactoryUtil.createUser.
        wrp5.sNameActivityProcess = 'TECH_EventUtilTestV5';
        wrp5.idsObject = oLead.Id;       
            
    	Test.startTest();
    		EventUtil.createActivity(new List<EventUtil.WrapperActivity>{wrp});
            EventUtil.createActivity(new List<EventUtil.WrapperActivity>{wrp1});
            EventUtil.createActivity(new List<EventUtil.WrapperActivity>{wrp2});
            EventUtil.createActivity(new List<EventUtil.WrapperActivity>{wrp3});
            EventUtil.createActivity(new List<EventUtil.WrapperActivity>{wrp4});
            EventUtil.createActivity(new List<EventUtil.WrapperActivity>{wrp5});
            EventUtil.createEventsFromLead(lstLeads);
    	Test.stopTest();

        
    }
}
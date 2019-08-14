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
	*   @Class : SendEmailOwnerChangedTest.cls
	*
	*   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
	*   @Created        :   19 Feb 2018
	*   @Description    :   Apex Unit test class for SendEmailOwnerChangedTest.cls
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description
	*	   Rubén Moreno				18 04 2018				 Creation.	
	*	   Ramesh Artham			22 02 2019				 Update
	*   ----------------------------------------------------------------------------------------------------------------------------
**/


@isTest
private class SendEmailOwnerChangedTest {

    @testSetup static void setup() {

        Account accB2B = new Account(
            Name                = 'TEST MATCH B2B2',
            phone               = '+8432434',
            BillingPostalCode   = '2345263',
            OwnerId             = UserInfo.getUserId(),
            RecordTypeId        = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B').getRecordTypeId()
        );

        insert accB2B;

        Contact cnt = new Contact (
            FirstName           = 'Contact_FirstName_Test',
            LastName            = 'Contact_LastName_Test',
            Salutation          = '1',
            Phone               = '56789867767',          
            AccountId           = accB2B.Id,
            OwnerId             = UserInfo.getUserId(),
            Email               = 'contact1@gmail.com'
        );

        insert cnt;

        Lead oLead = new Lead(
            FirstName                   = 'First Name 003',
            Salutation                  =  '1',
            LastName                    = 'LastName 003',
            Street                      = 'Calle Test 372',
            City                        = 'Madrid',
            Country                     = 'España', 
            PostalCode                  = '28012',
            Latitude                    =  39.9691,
            Longitude                   = -4.8237,
            Phone                       = '915001000',
            DestinationPOSCode__c       = '1237771',
            Company                     = 'DEALER TEST COMPANY_0031',
            PSABrand__c                 = 'AP',
            Email                       = 'test@leadexample.com',
            LeadRequestType__c          = '1',
            IdReservationVD__c          = '12345323X',
            Status                      = 'Qualified',
            OwnerId                     = UserInfo.getUserId(),
            RecordTypeId                = PAD.getObjRecordType('Lead','B2B')
        );

        insert oLead;

        List<User> lUser = new List<User>(TestDataFactoryUtil.createUser(
            new List<Contact>{cnt},
            'Salesman',
            'Partner',
            'Manager'
        ));

        insert lUser;

        if (!lUser.isEmpty()) {
            oLead.OwnerId = lUser[0].id;
            update oLead;
        }

        List<Profile> lstP = New List<Profile>([
            SELECT Id
            FROM Profile
            WHERE Name='System Administrator'
        ]);

        if (!lstP.isEmpty()) {
            User u = new User(
                LastName            = 'Test',
                Email               = 'sendemailownerchanged@testclass.com',
                Alias               = 'test',
                TimeZoneSidKey      = 'GMT',
                LocaleSidKey        = 'en_GB',
                EmailEncodingKey    = 'ISO-8859-1',
                ProfileId           = lstP.get(0).Id,
                LanguageLocaleKey   = 'en_US',
                UserName            = 'sapiwebhook@testclass.com',
                Country__c          = 'PL',
                Brand__c            = 'AC',
                VNRRDICode__c       = '12345'
            );

            insert u;

            Group q = new Group(
                Name = 'Dummy Queue SendEmailOwnerChanged',
                Type = 'Queue'
            );

            insert q;

            System.runAs(u) {
                insert new QueueSobject(
                    QueueId     = q.Id,
                    SobjectType = 'Lead'
                );
            }
        }
    }

    @isTest static void testMethod1(){
        List<Lead> lLeads = new List<Lead>([
            SELECT
                Id,
                OwnerId
            FROM Lead limit 1
        ]);
        Test.startTest();
            SendEmailOwnerChanged.sendEmail(
                lLeads, 
                new Map<Id, Lead>(lLeads)
            );
        Test.stopTest();
    }

    @isTest static void testMethod2(){
        List<Lead> lLeads = new List<Lead>([
            SELECT
                Id,
                OwnerId
            FROM Lead limit 1
        ]);
        
         Group q = new Group(
                Name = 'Dummy Queue SendEmailOwnerChanged',
                Type = 'Queue'
            );

            insert q;
   //Test.startTest();

       /* List<Group> lstQ = new List<Group>([
            SELECT Id,name
            FROM Group
            WHERE type ='queue' and name ='CEC Chile'
        ]);
        system.debug('lstQ' +lstQ.size());*/

//Test.stopTest();
        Map<Id, Lead> mapOldLeads = new  Map<Id, Lead>();

        for (Lead l : lLeads) 
		{
            mapOldLeads.put(l.Id,new Lead(Id = l.Id,OwnerId = l.OwnerId));
            l.OwnerId = q.Id;// Modified by Ramesh Artham regarding C1STRUN-1697
        }

       Test.startTest();
            SendEmailOwnerChanged.sendEmail(
                lLeads,
                mapOldLeads
            );
        Test.stopTest();
    }

}
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
    *   @Class : ManualSharingProcessTest.cls
    *
    *   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
    *   @Created        :   23 Feb 2018
    *   @Description    :   Apex Unit test class for ManualSharingProcessTest.cls
    
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description
    *      Rubén Moreno             23 Feb 2018              Creation.  
    *      
    *   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
public class ManualSharingProcessTest {

    static testMethod void myUnitTest() {

        Group testGroup = new Group();
        testGroup.Name = 'testGroup';
        testGroup.DeveloperName = 'ABC';
        insert testGroup;
        
        Account acc = new Account(
                Name                =   'TEST MATCH',
                phone               =   '+843434',
                BillingPostalCode   =   '23456',
                FiscalId__c         =   '30.686.957-4',
                RecordTypeiD        =   PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_DEALER),
                TECH_PublicGroups__c=   userInfo.getUserId(),
                TECH_PublicGroupsContract__c = testGroup.Id
        );
        
        insert acc;
        
        Contact cnt             =   new Contact (
                FirstName           =   'Contact_FirstName_Test',
                LastName            =   'Contact_LastName_Test',
                Salutation          =   '1',
                Phone               =   '9867767',
                AccountId           =   acc.Id,
                RecordTypeId        =   PAD.recordTypesMapByDeveloperName.get(Constants.RT_CONTACT_PARTNER_USER)
        );
        
        insert cnt;
        
        Map<String, Object> mapApiNameToFieldValueOpp = new Map<String, Object>();
        mapApiNameToFieldValueOpp.put('Name', 'Opportunity');
        mapApiNameToFieldValueOpp.put('StageName', 'New');
        mapApiNameToFieldValueOpp.put('Probability', 0.2);
        mapApiNameToFieldValueOpp.put('Amount', 100);
        mapApiNameToFieldValueOpp.put('CloseDate', System.today());
        mapApiNameToFieldValueOpp.put('Activity__c', 'VN');
        mapApiNameToFieldValueOpp.put('Country__c', 'PL');
        mapApiNameToFieldValueOpp.put('AccountId', acc.Id);
        mapApiNameToFieldValueOpp.put('CalculatedPOS__c', acc.Id);

        Opportunity opp = TestDataFactoryUtil.createOpportunities(mapApiNameToFieldValueOpp, true);
        List<Opportunity> opps = new List<Opportunity>();
        opps.add(opp);

        List<Opportunity> lOpp = TestDataFactoryUtil.createOpportunities(1, '', acc, 2, 'New', 30);
        
        Account acc2 = new Account(
            Name                        = 'Prueba',
            BillingStreet               = 'dsadsadad',
            BillingCity                 = 'Madrid',
            BillingCountry              = 'España', 
            BillingPostalCode           = '12345',
            Phone                       = '+56123456789',
            PdVInterne__c               = True,
            VNContractNumber__c         = 'dasdas',
            VNPrincipalSite__c          = True,
            RAContractNumber__c         = 'dasdas',
            RAPrincipalSite__c          = True,
            PRContractNumber__c         = 'dasdas',
            PRPrincipalSite__c          = True,
            AgentContractNumber__c      = 'dasdas',
            AgentPrincipalSite__c       = True,
            VNContractBeginDate__c      = date.today() - 5,
            VNContractEndDate__c        = date.today() + 5,
            RAContractBeginDate__c      = date.today() - 5,
            RAContractEndDate__c        = date.today() + 5,
            PRContractBeginDate__c      = date.today() - 5,
            PRContractEndDate__c        = date.today() + 5,
            AgentContractBeginDate__c   = date.today() - 5,
            AgentContractEndDate__c     = date.today() + 5,
            SiteGeoIdPK__c              = 'dsada',
            Brand__c                    = 'DS',
            Country__c                  = 'CL',
            PRFlag__c                   = True,
            RAFlag__c                   = True,
            VOActivity__c               = True,
            VNFlag__c                   = True,
            AgentFlag__c                = True,
            LicenseCode__c              = 'dsada',
            RecordTypeId                = PAD.getObjRecordType('Account','Dealer'),
            TECH_PublicGroups__c        = userInfo.getUserId(),
            TECH_PublicGroupsContract__c = testGroup.Id);
        
        insert acc2;

        List<Lead> lLead = TestDataFactoryUtil.createLead(1, 'B2B', 'acc', '', 'DS', 'FR', '', '');
        lLead[0].CalculatedPOS__c = acc2.id;
        insert lLead;   

        map<Id,List<id>> mapGrantAccess = new map<Id,List<id>>();
        mapGrantAccess.put(acc2.id,new List<Id>{acc2.id});
        mapGrantAccess.put(cnt.id,new List<Id>{cnt.id});
        mapGrantAccess.put(lLead[0].id,new List<Id>{lLead[0].id});
        mapGrantAccess.put(lOpp[0].id,new List<Id>{lOpp[0].id});
        
        test.startTest();
        ManualSharingProcess.ManualSharing(mapGrantAccess);
        ManualSharingProcess.ManualSharingAsync(mapGrantAccess,new List<Lead>()); 
        ManualSharingProcess.ManualSharing(ManualSharingProcess.setRecordToShare(new List<Account>{acc2}));
        ManualSharingProcess.ManualSharing(ManualSharingProcess.setRecordToShare(lLead));
        ManualSharingProcess.ManualSharing(ManualSharingProcess.setRecordToShare(lOpp));
        ManualSharingProcess.ManualSharing(ManualSharingProcess.setRecordToShare(lLead.get(0).id, UserInfo.getUserId()));
        ManualSharingProcess.setRecordToShare(lLead.get(0).id, UserInfo.getUserId());
        ManualSharingProcess.setRecordToShare(opps);
        test.stopTest(); 
                  
    }
    
}
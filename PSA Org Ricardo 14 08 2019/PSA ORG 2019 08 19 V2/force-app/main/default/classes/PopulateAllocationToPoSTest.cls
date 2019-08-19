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
	*   @Class : PopulateAllocationToPoSTest.cls
	*
	*   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
	*   @Created        :   19 Jul 2018
	*   @Description    :   Apex Unit test class for PopulateAllocationToPoS.cls
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description
	*	   Rubén Moreno				31 Jul 2018				 Creation.	
	*	   
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
private class PopulateAllocationToPoSTest {
    
    @isTest private static void mainTest(){

        
        Account acct = new Account(
            Name                        = 'DealerAccount_0001', 
            BillingStreet               = 'Calle de Sebastián Elcano 72',
            BillingCity                 = 'Madrid',
            BillingCountry              = 'España', 
            BillingPostalCode           = '28012 ',
            VNContractNumber__c         = '123777A',
            VNPrincipalSite__c          = true,
            RAContractNumber__c         = '1237771',
            SiteGeoIdPK__c				=	'12454',
            RAPrincipalSite__c          = false,
            PRContractNumber__c         = '1237772',
            PRPrincipalSite__c          = false,
            AgentContractNumber__c      = '1237773',
            AgentPrincipalSite__c		= false,
            VNContractBeginDate__c      = date.today() - 5,
            VNContractEndDate__c        = date.today() + 4,
            RAContractBeginDate__c      = date.today() - 5,
            RAContractEndDate__c        = date.today() - 4,
            PRContractBeginDate__c      = date.today() - 5,
            PRContractEndDate__c        = date.today() - 4,
            AgentContractBeginDate__c   = date.today() - 5,
            AgentContractEndDate__c     = date.today() - 4,
            Brand__c                    = 'AP',
            Country__c                  = 'ES',
            PRFlag__c                   = false,
            RAFlag__c                   = false,
            VOActivity__c               = false,
            VNFlag__c                   = true,
            LicenseCode__c              = 'J',
            RecordTypeId                = PAD.getObjRecordType('Account','Dealer'));
        
        insert acct;


        Lead oLead = new Lead(
            FirstName                   = 'First Name 003',
            Salutation					=  '1',
            LastName                    = 'LastName 003',
            CalculatedPOS__c       		= null,
            Company                     = 'DEALER TEST COMPANY_0031',
            PSABrand__c                 = 'AP',
            Email                       = 'test@leadexample.com',
            RecordTypeId                = PAD.getObjRecordType('Lead','B2B'));
        
        insert oLead;
        
        Test.startTest();
        oLead.CalculatedPOS__c = acct.id;
        update oLead;
		PopulateAllocationToPoS.populatePoSfields(new List<Lead> {oLead}, new map<id,Lead>{oLead.id => oLead});
		oLead.CalculatedPOS__c = null;
        update oLead;
        Test.stopTest();
    }
    @isTest private static void insertLeadTest(){

        
        Account acct = new Account(
            Name                        = 'DealerAccount_0001', 
            BillingStreet               = 'Calle de Sebastián Elcano 72',
            BillingCity                 = 'Madrid',
            BillingCountry              = 'España', 
            BillingPostalCode           = '28012 ',
            VNContractNumber__c         = '123777A',
            VNPrincipalSite__c          = true,
            RAContractNumber__c         = '1237771',
            SiteGeoIdPK__c				=	'12454',
            RAPrincipalSite__c          = false,
            PRContractNumber__c         = '1237772',
            PRPrincipalSite__c          = false,
            AgentContractNumber__c      = '1237773',
            AgentPrincipalSite__c		= false,
            VNContractBeginDate__c      = date.today() - 5,
            VNContractEndDate__c        = date.today() + 4,
            RAContractBeginDate__c      = date.today() - 5,
            RAContractEndDate__c        = date.today() - 4,
            PRContractBeginDate__c      = date.today() - 5,
            PRContractEndDate__c        = date.today() - 4,
            AgentContractBeginDate__c   = date.today() - 5,
            AgentContractEndDate__c     = date.today() - 4,
            Brand__c                    = 'AP',
            Country__c                  = 'ES',
            PRFlag__c                   = false,
            RAFlag__c                   = false,
            VOActivity__c               = false,
            VNFlag__c                   = true,
            LicenseCode__c              = 'J',
            RecordTypeId                = PAD.getObjRecordType('Account','Dealer'));
        
        insert acct;


        Lead oLead = new Lead(
            FirstName                   = 'First Name 003',
            Salutation					=  '1',
            LastName                    = 'LastName 003',
            CalculatedPOS__c       		= acct.id,
            Company                     = 'DEALER TEST COMPANY_0031',
            PSABrand__c                 = 'AP',
            Email                       = 'test@leadexample.com',
            RecordTypeId                = PAD.getObjRecordType('Lead','B2B'));
        
        
        Test.startTest();
        insert oLead;
        Test.stopTest();
    }
}
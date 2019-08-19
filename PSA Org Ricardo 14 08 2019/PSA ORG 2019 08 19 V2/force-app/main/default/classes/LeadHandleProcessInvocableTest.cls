@isTest
public class LeadHandleProcessInvocableTest {
/*
-- - Name         : LeadHandleProcessInvocableTest
-- - Author       : SFDC. Ruben Fernandez
-- - Date         : 01/03/2019
-- - Description  : Test class for LeadHandleProcessInvocableTest
--                  1. DealerInvocableTest.
--                  2. DealerAssignmentdDestinationCodeTest
--                  3. DealerAssignmentdGeoLocationTest
--                  4. BulkDealerAssignmentTest
-- - History:
-- Date         Author  Version  Comments
-- -----------  -----   -------  ---------------------------------------
-- 01/02/2018   DXC     1.0      Initial version Ruben Fernandez
-- 18/06/2019   PP      1.1      Pedro Párraga 
*/


	
@isTest static void DealerInvocableTest() {

	Account acct = new Account(
                Name                        = 'DealerAccount_0001', 
                BillingStreet               = 'Calle de Sebastián Elcano 72',
                BillingCity                 = 'Madrid',
                BillingCountry              = 'España', 
                BillingPostalCode           = '28012 ',
                Phone                       = '915000000',
                VNContractNumber__c         = '123777A',
                VNPrincipalSite__c          = true,
                RAContractNumber__c         = '1237771',
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
                RecordTypeId                = PAD.getObjRecordType('Account','Dealer')
    );
        
    insert acct;	
            
 	Lead oLead = new Lead(
                FirstName                   = 'First Name 001', 
                LastName                    = 'LastName 001',
                Street                      = 'Calle de Sebastián Elcano 72',
                City                        = 'Madrid',
                Country                     = 'España', 
                PostalCode                  = '28012',
                Latitude					=  39.9691,
                Longitude					= -4.8237,
                Phone                       = '915000000',
                NationalId__c               = '72000222H',
                DestinationGeographicalCode__c= '123777A',
                Company                     = 'DEALER TEST COMPANY_001',
                PSABrand__c                 = 'AP',
                Email                       = 'psatestlead001@leadexample.com',
                LeadCountry__c              = 'ES',
        		TECH_Web2Lead__c			= true,
                RecordTypeId                = PAD.getObjRecordType('Lead','B2B')
        );

    insert oLead;
		
	LeadHandleProcessInvocable.ObjectRequest oRecord			= new LeadHandleProcessInvocable.ObjectRequest();
	List<Id> lstAux 					= new List<Id>();

	oRecord.recordId 					= oLead.Id;
	lstAux.add(oLead.Id);

	List<LeadHandleProcessInvocable.ObjectRequest> lstObjects 	= new List<LeadHandleProcessInvocable.ObjectRequest>();
	lstObjects.add(oRecord);

    Test.startTest();        	
    	LeadHandleProcessInvocable.handleProcess(lstObjects);
		LeadHandleProcessInvocable.asyncHandleDealerAllocation(lstAux);
    Test.stopTest();

	}
}
/*
-- - Name         : CSResultAControllerTest
-- - Author       : DXC. Ruben Fernandez
-- - Date         : 01/01/2018
-- - Description  : Test class for LeadTriggerHandler. Dealer Assignment
--                  1. DealerAssignmentTest.
--                  2. DealerAssignmentdDestinationCodeTest
--                  3. DealerAssignmentdGeoLocationTest
--                  4. BulkDealerAssignmentTest
-- - History:
-- Date         Author  Version  Comments
-- -----------  -----   -------  ---------------------------------------
-- 01/02/2018   DXC     1.0      Initial version Ruben Fernandez
*/
@isTest
private class LeadDealerAllocationTest {
	
@isTest static void DealerAssignmentTest() {

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
                RecordTypeId                = PAD.getObjRecordType('Account','Dealer'));
        
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
                //DestinationPOSCode__c       = '123777A',
                Company                     = 'DEALER TEST COMPANY_001',
                PSABrand__c                 = 'AP',
                Email                       = 'psatestlead001@leadexample.com',
                LeadCountry__c              = 'ES',
                RecordTypeId                = PAD.getObjRecordType('Lead','B2B'));
        
      
            insert oLead;

		List<Id> lstLeads = new List<Id>();
		lstLeads.add(oLead.Id);
		// Perform test
        Test.startTest();
        	
        	LeadDealerAllocation.handleDealerAllocation(lstLeads);

        Test.stopTest();

	}
	@isTest static void DealerAssignmentBothTest() {

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
                RAPrincipalSite__c          = true,
                PRContractNumber__c         = '1237772',
                PRPrincipalSite__c          = true,
                AgentContractNumber__c      = '1237773',
                AgentPrincipalSite__c       = true,
                VNContractBeginDate__c      = date.today() - 5,
                VNContractEndDate__c        = date.today() + 4,
                RAContractBeginDate__c      = date.today() - 5,
                RAContractEndDate__c        = date.today() + 4,
                PRContractBeginDate__c      = date.today() - 5,
                PRContractEndDate__c        = date.today() + 4,
                AgentContractBeginDate__c   = date.today() - 5,
                AgentContractEndDate__c     = date.today() + 4,
                Brand__c                    = 'AP',
                Country__c                  = 'ES',
                PRFlag__c                   = true,
                RAFlag__c                   = true,
                VOActivity__c               = true,
                VNFlag__c                   = true,
                LicenseCode__c              = 'J',
                RecordTypeId                = PAD.getObjRecordType('Account','Dealer'));
        
            insert acct;    
            
    Lead oLead = new Lead(
                FirstName                   = 'First Name 001', 
                LastName                    = 'LastName 001',
                Street                      = 'Calle de Sebastián Elcano 72',
                City                        = 'Madrid',
                Country                     = 'España', 
                PostalCode                  = '28012',
                Latitude                    =  39.9691,
                Longitude                   = -4.8237,
                Phone                       = '915000000',
                NationalId__c               = '72000222H',
                DestinationGeographicalCode__c= '123777A',
                DestinationPOSCode__c       = '123777A',
                Company                     = 'DEALER TEST COMPANY_001',
                PSABrand__c                 = 'AP',
                Email                       = 'psatestlead001@leadexample.com',
                LeadCountry__c              = 'ES',
                RecordTypeId                = PAD.getObjRecordType('Lead','B2B'));
        
      
            insert oLead;

        List<Id> lstLeads = new List<Id>();
        lstLeads.add(oLead.Id);
        // Perform test
        Test.startTest();
            
            LeadDealerAllocation.handleDealerAllocation(lstLeads);

        Test.stopTest();

    }
	@isTest static void DealerAssignmentdDestinationCodeTest() {
	
	Account acct = new Account(
                Name                        = 'DealerAccount_0002', 
                BillingStreet               = 'Calle de Sebastián Elcano 70',
                BillingCity                 = 'Madrid',
                BillingCountry              = 'España', 
                BillingPostalCode           = '28012 ',
                Phone                       = '915000000',
                VNContractNumber__c         = '1237770',
                VNPrincipalSite__c          = false,
                RAContractNumber__c         = '1237771',
                RAPrincipalSite__c          = true,
                PRContractNumber__c         = '1237772',
                PRPrincipalSite__c          = false,
                AgentContractNumber__c      = '1237773',
                AgentPrincipalSite__c		= false,
                //VNContractBeginDate__c      = date.today() - 5,
                //VNContractEndDate__c        = date.today() - 4,
                RAContractBeginDate__c      = date.today() - 5,
                RAContractEndDate__c        = date.today() + 4,
                //PRContractBeginDate__c      = date.today() - 5,
                //AgentContractBeginDate__c   = date.today() - 5,
                //AgentContractEndDate__c     = date.today() - 4,
                Brand__c                    = 'AP',
                Country__c                  = 'ES',
                PRFlag__c                   = false,
                RAFlag__c                   = true,
                VOActivity__c               = false,
                VNFlag__c                   = false,
                LicenseCode__c              = 'J',
                RecordTypeId                = PAD.getObjRecordType('Account','Dealer'));
        
            insert acct;	
            
 	Lead oLead = new Lead(
                FirstName                   = 'First Name 002', 
                LastName                    = 'LastName 002',
                Street                      = 'Calle de Sebastián Elcano 72',
                City                        = 'Madrid',
                Country                     = 'España', 
                PostalCode                  = '28012',
                Latitude					=  39.9691,
                Longitude					= -4.8237,
                Phone                       = '915000000',
                NationalId__c               = '72000333H',
                //DestinationGeographicalCode__c= acct.Id,
                DestinationPOSCode__c       = '1237771',
                Company                     = 'DEALER TEST COMPANY_002',
                PSABrand__c                 = 'AP',
                Email                       = 'psatestlead002@leadexample.com',
                LeadCountry__c              = 'ES',
                RecordTypeId                = PAD.getObjRecordType('Lead','B2B'));
        
      
            insert oLead;

		List<Id> lstLeads = new List<Id>();
		lstLeads.add(oLead.Id);
		// Perform test
        Test.startTest();
        	
        	LeadDealerAllocation.handleDealerAllocation(lstLeads);

        Test.stopTest();

	}

	@isTest static void DealerAssignmentdGeoLocationTest() {
		// Distance > 0 Km (TALABERA DE LA REINA)
		Account acct = new Account(
                Name                        = 'DealerAccount_0003', 
                BillingStreet               = 'Calle de Sebastián Elcano 68',
                BillingCity                 = 'Madrid',
                BillingCountry              = 'España', 
                BillingPostalCode           = '28012 ',
                BillingLatitude				=  39.9690,
                BillingLongitude			= -4.8248,
                Phone                       = '917000000',
                VNContractNumber__c         = '1237774',
                VNPrincipalSite__c          = false,
                RAContractNumber__c         = '1237775',
                RAPrincipalSite__c          = true,
                PRContractNumber__c         = '1237776',
                PRPrincipalSite__c          = false,
                AgentContractNumber__c      = '1237777',
                AgentPrincipalSite__c		= false,
                //VNContractBeginDate__c      = date.today() - 5,
                //VNContractEndDate__c        = date.today() - 4,
                RAContractBeginDate__c      = date.today() - 5,
                RAContractEndDate__c        = date.today() + 4,
                //PRContractBeginDate__c      = date.today() - 5,
                //AgentContractBeginDate__c   = date.today() - 5,
                //AgentContractEndDate__c     = date.today() - 4,
                Brand__c                    = 'AP',
                Country__c                  = 'ES',
                PRFlag__c                   = false,
                RAFlag__c                   = true,
                VOActivity__c               = false,
                VNFlag__c                   = false,
                LicenseCode__c              = 'J',
                RecordTypeId                = PAD.getObjRecordType('Account','Dealer'));
     
            // Distance > 20 Km (GETAFE)
        Account acct1 = new Account(
                Name                        = 'DealerAccount_00031', 
                BillingStreet               = 'Calle de Sebastián Elcano 68',
                BillingCity                 = 'Madrid',
                BillingCountry              = 'España', 
                BillingPostalCode           = '28012 ',
                BillingLatitude				=  40.262760,
                BillingLongitude			= -3.7628173,
                Phone                       = '918000000',
                VNContractNumber__c         = '1237774',
                VNPrincipalSite__c          = false,
                RAContractNumber__c         = '1237775',
                RAPrincipalSite__c          = true,
                PRContractNumber__c         = '1237776',
                PRPrincipalSite__c          = false,
                AgentContractNumber__c      = '1237777',
                AgentPrincipalSite__c		= false,
                //VNContractBeginDate__c      = date.today() - 5,
                //VNContractEndDate__c        = date.today() - 4,
                RAContractBeginDate__c      = date.today() - 5,
                RAContractEndDate__c        = date.today() + 4,
                //PRContractBeginDate__c      = date.today() - 5,
                //AgentContractBeginDate__c   = date.today() - 5,
                //AgentContractEndDate__c     = date.today() - 4,
                Brand__c                    = 'AP',
                Country__c                  = 'ES',
                PRFlag__c                   = false,
                RAFlag__c                   = true,
                VOActivity__c               = false,
                VNFlag__c                   = false,
                LicenseCode__c              = 'P',
                RecordTypeId                = PAD.getObjRecordType('Account','Dealer'));
            
 		Lead oLead = new Lead(
                FirstName                   = 'First Name 003', 
                LastName                    =  'LastName 003',
                Street                      = 'Calle de Sebastián Elcano 72',
                City                        = 'Madrid',
                Country                     = 'España', 
                PostalCode                  = '28012',
                Latitude					=  39.9690,
                Longitude					= -4.8248,
                Phone                       = '915000000',
                NationalId__c               = '71000333H',
                //DestinationGeographicalCode__c= acct.Id,
                //DestinationPOSCode__c       = '',
                //Company                     = 'DEALER TEST COMPANY_003',
                PSABrand__c                 = 'AP',
                Email                       = 'psatestlead003@leadexample.com',
                LeadCountry__c                  = 'ES',
                Activity__c					= 'APV',
                RecordTypeId                = PAD.getObjRecordType('Lead','B2B'));
        
        // B2B -- COMPANY != null
        Lead oLead1 = new Lead(
                FirstName                   = 'FirstName B2B 003', 
                LastName                    = 'LastName B2B 003',
                Street                      = 'Calle de Sebastián Elcano 50',
                City                        = 'Madrid',
                Country                     = 'España', 
                PostalCode                  = '28012',
                Latitude					=  39.9691,
                Longitude					= -4.8237,
                Phone                       = '911000000',
                NationalId__c               = '72001332H',
                //DestinationGeographicalCode__c= acct.Id,
                //DestinationPOSCode__c       = '',
                Company                     = 'DEALER TEST COMPANY_0031',
                PSABrand__c                 = 'AP',
                Email                       = 'psatestlead0031@lead1example.com',
                LeadCountry__c                  = 'ES',
                Activity__c					= 'APV',
                RecordTypeId                = PAD.getObjRecordType('Lead','B2B'));
        
            

		List<Account> lstAccs = new List<Account>();
		lstAccs.add(acct);
		lstAccs.add(acct1);
		insert lstAccs;

		List<Lead> lstLeads = new List<Lead>();
        List<Id> lstLeadsIds = new List<Id>();
		lstLeads.add(oLead);
		lstLeads.add(oLead1);
        lstLeadsIds.add(oLead.Id);
        lstLeadsIds.add(oLead1.Id);
		insert lstLeads;
		// Perform test
        Test.startTest();
        	
        	LeadDealerAllocation.handleDealerAllocation(lstLeadsIds);
        	List<Lead> lstLeadsResult = new List<Lead>([Select Id, CalculatedPOS__c From Lead Where Id =:oLead.Id]);
        	//system.assertEquals(lstLeadsResult.get(0).CalculatedPOS__c, acct.Id);

        Test.stopTest();
	}

	@isTest static void DealerAssignmentdBulkTest() {
		
		List<Lead> lstLeads = new List<Lead>();
        List<Id> lstLeadsIds = new List<Id>();
		Account acct = new Account(
                Name                        = 'DealerAccount_0003', 
                BillingStreet               = 'Calle de Sebastián Elcano 68',
                BillingCity                 = 'Madrid',
                BillingCountry              = 'España', 
                BillingPostalCode           = '28012 ',
                BillingLatitude				=  39.9690,
                BillingLongitude			= -4.8248,
                Phone                       = '917000000',
                VNContractNumber__c         = '1237774',
                VNPrincipalSite__c          = false,
                RAContractNumber__c         = '1237775',
                RAPrincipalSite__c          = true,
                PRContractNumber__c         = '1237776',
                PRPrincipalSite__c          = false,
                AgentContractNumber__c      = '1237777',
                AgentPrincipalSite__c		= false,
                //VNContractBeginDate__c    = date.today() - 5,
                //VNContractEndDate__c      = date.today() - 4,
                RAContractBeginDate__c      = date.today() - 5,
                RAContractEndDate__c        = date.today() + 4,
                //PRContractBeginDate__c    = date.today() - 5,
                //AgentContractBeginDate__c = date.today() - 5,
                //AgentContractEndDate__c   = date.today() - 4,
                Brand__c                    = 'AP',
                Country__c                  = 'ES',
                PRFlag__c                   = false,
                RAFlag__c                   = true,
                VOActivity__c               = false,
                VNFlag__c                   = false,
                LicenseCode__c              = 'J',
                RecordTypeId                = PAD.getObjRecordType('Account','Dealer'));
        
            insert acct;
		String sKey = '00000000';
        for(Integer i=0;i<10;i++) {

	 		Lead oLead = new Lead(
	                FirstName                   = 'FN'+i, 
	                LastName                    = 'LN'+i,
	                Street                      = 'C'+i,
	                City                        = 'Madrid',
	                Country                     = 'España', 
	                PostalCode                  = '28012',
	                Latitude					=  39.9691,
	                Longitude					= -4.8237,
	                Phone                       = '91500000'+i,
	                NationalId__c               =  String.valueof(sKey + i).right(8) + 'C',
                    CalculatedPOS__c            = acct.Id,
	                //DestinationGeographicalCode__c= acct.Id,
	                //DestinationPOSCode__c       = '',
	                Company                     = 'D' + i,
	                //BrandOwnedVehicle__c        = 'PEUGEOT',
	                Email                       = 'l' + i +'@l.com',
	                LeadCountry__c              = 'ES',
	                Activity__c					= 'SE',
                    PSABrand__c                 = 'AP',
                    CustomerType__c             = '1',
                    LeadChannel__c              = '10',
                    LeadRequestType__c          = '1',
                    LeadSource                  = 'Partner',
                    LeadType__c                 = '1',
                    MarketingCode__c            = '01234567899876543210',
	                RecordTypeId                = PAD.getObjRecordType('Lead','B2B'));
        	lstLeads.add(oLead);
            
        }
		
		Insert lstLeads;

        //for(Lead o : lstLeads){
        //    lstLeadsIds.add(o.Id);
        //}
		// Perform test
        Test.startTest();
        	


        	LeadDealerAllocation.handleDealerAllocation(lstLeadsIds);

        Test.stopTest();	
	}
	
}
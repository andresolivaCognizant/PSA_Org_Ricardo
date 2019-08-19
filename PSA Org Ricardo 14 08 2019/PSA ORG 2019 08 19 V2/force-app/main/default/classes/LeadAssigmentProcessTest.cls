/*
-- - Name         : LeadAssigmentProcessTest
-- - Author       : DXC. Ruben Fernandez
-- - Date         : 06/02/2018
-- - Description  : Test class for LeadTriggerHandler. Dealer Assignment
--                  1. DealerAssignmentTest.
--                  2. DealerAssignmentdDestinationCodeTest
--                  3. DealerAssignmentdGeoLocationTest
--                  4. BulkDealerAssignmentTest
-- - History:
-- Date         Author  Version  Comments
-- -----------  -----   -------  ---------------------------------------
-- 06/02/2018   DXC     1.0      Initial version Ruben Fernandez
-- 13/06/2018   RML     2.0      Fix bugs.
*/
@isTest
private class LeadAssigmentProcessTest {
	
    /* QUEUE ASSIGMENT */
    @isTest static void Lead_QUEUE_AssignmentTest() {

        // Preparing the test conditions.
        List<String> lstActivities  =   new List<String>(); 
        lstActivities.add('VN');
        List<Account> lstAccounts   =   TestDataFactoryUtil.createDealers(1, 'Dealer', '133225511','1237770', 'EXTKEY0001','AP','ES', 'J',lstActivities,true);
        List<Lead> lstLeads         =   new List<Lead> {new Lead(
            FirstName                   = 'First Name LARP', 
            LastName                    =  'tEST LARP',
            Street                      = 'Calle de Sebastián Elcano 1',
            City                        = 'Madrid',
            Country                     = 'España', 
            
            Latitude                    =  39.9691,
            Longitude                   = -4.8237,
            PSABrand__c                 = 'AP',
            Email                       = 'psaLead@leadexample.com',
            CustomerType__c             = '1',
            LeadChannel__c              = '10',
            LeadRequestType__c          = '1',
            LeadSource                  = 'Partner',
            LeadType__c                 = '1',
            MarketingCode__c            = '01234567899876543210'
        )};

		// Perform test
        Test.startTest();
        	lstLeads.get(0).TreatmentDueDate__c = system.now();
        	Insert lstLeads;
        	//LeadAssigmentProcess.handleAssigmentProcess(lstLeads);
        	Id idOwnerId;
        	for(LeadAssignmentRuleProcess__mdt larp : [SELECT MasterLabel, QualifiedApiName, Active__c, Activity__c, Brand__c, Country__c, CustomerType__c, DealerGrouping__c, LeadChannel__c, LeadRequestType__c, LeadSource__c, LeadType__c, MarketingCode__c,  Sort__c,SiteGeoIdPK__c,PdVInternal__c,  TargetType__c, TargetValue__c,PrioritizeknownSalesman__c FROM LeadAssignmentRuleProcess__mdt where Active__c = false AND QualifiedApiName LIKE 'TECH_CONF%' ORDER BY Sort__c ASC]){
                if(larp.TargetType__c=='Queue'){        		
					idOwnerId = (ID)larp.TargetValue__c;
				}
			}
        	List<Lead> lstLeadsResult = new List<Lead>([Select Id, OwnerId From Lead Where Id =:lstLeads.get(0).Id]);

            // Record must be assigned to the Queue defined in the MetaData.
        	//System.assertEquals(lstLeadsResult.get(0).OwnerId, idOwnerId);

        Test.stopTest();

	}

    /* SALES MAN ASSIGMENT */
    @isTest static void Lead_SALESMAN_AssignmentTest() {

        // Preparing the test conditions.
        List<String> lstActivities  =   new List<String>(); 
        lstActivities.add('VN');
        List<Contact> lstConts      =   TestDataFactoryUtil.createPartnerUser(1, 1, 'Dealer', '133225511','1237770', 'EXTKEY0002','AP','PL', 'J',lstActivities,true);
        List<Account> lstAccts      =   new List<Account>([Select Id,Name From Account Where Id =:lstConts.get(0).AccountId]);
        List<Account> lstB2BAcc     =   TestDataFactoryUtil.createAccount(1,'B2B');
        List<Opportunity> lstOpps   =   TestDataFactoryUtil.createOpportunities(1, null ,lstB2BAcc.get(0), 1000.0 ,'Proposal', 75);
        List<User> lstUsers         =   TestDataFactoryUtil.createUser(lstConts,'Salesman','Partner','Manager');
        List<Lead> lstLeads         =   TestDataFactoryUtil.createLead(2, 'B2B', 'EXTKEY0002',null, 'AP','CL','VN', '22334455');
		lstLeads[0].fiscalid__c 	= '30686957-4';
        lstLeads[1].fiscalid__c 	= '30686957-4';
        System.debug('Results-->Lead:  OwnerId: ' + lstLeads.get(0).OwnerId + ' CalculatedPOS__c: ' + lstLeads.get(0).CalculatedPOS__c + ' Customer__c: ' + lstLeads.get(0).Customer__c );
        
        lstLeads.get(0).Customer__c = lstB2BAcc.get(0).Id;
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            Insert lstUsers;
        }

        lstOpps.get(0).OwnerId = lstUsers.get(0).Id;
        update lstOpps;
        
        // Perform test
        Test.startTest();
        lstLeads.get(0).TreatmentDueDate__c = system.now();
        lstLeads.get(1).TreatmentDueDate__c = system.now().adddays(2);
            Insert lstLeads;
            System.debug('Results-->Lead:  OwnerId: ' + lstLeads.get(0).OwnerId + ' CalculatedPOS__c: ' + lstLeads.get(0).CalculatedPOS__c + ' Customer__c: ' + lstLeads.get(0).Customer__c );
            //LeadAssigmentProcess.handleAssigmentProcess(lstLeads);
            List<Lead> lstLeadsResult = new List<Lead>([Select Id, OwnerId From Lead Where Id =:lstLeads.get(0).Id]);

            // Record must be assigned to the Saleman assigned to the Dealer.
            //System.assertEquals(lstLeadsResult.get(0).OwnerId, lstUsers.get(0).Id);
        
        	

        Test.stopTest();

    }

    /* SALES MAN ASSIGMENT */
    @isTest static void Lead_MANAGER_AssignmentTest() {

		User u = [Select id, country__c from user where profile.name = 'System Administrator' and isActive=true limit 1];
        u.Country__c = 'PL';
        update u;
        Set<id> setaccounts = new set<id>();
        // Preparing the test conditions.
        List<String> lstActivities  =   new List<String>(); 
        lstActivities.add('Agent');
        lstActivities.add('ACC');
        List<Contact> lstConts      =   TestDataFactoryUtil.createPartnerUser(1,3, 'Dealer', '133225511','1237770', 'EXTKEY0003','AP','BR', 'J',lstActivities,false);
        List<Account> lstAccts      =   new List<Account>([Select Id,Name,TECH_SalesManager__c,TECH_AfterSalesManager__c,TECH_SalesManagerAgent__c From Account Where Id =:lstConts.get(0).AccountId]);
        List<Account> lstB2BAcc     =   TestDataFactoryUtil.createAccount(1,'B2B');
        //List<Opportunity> lstOpps =   TestDataFactoryUtil.createOpportunities(1, null ,lstB2BAcc.get(0), 1000.0 ,'Proposal', 75);
        List<User> lstUsers         =   TestDataFactoryUtil.createUser(lstConts,'Salesman','Partner','Manager');
        List<Lead> lstLeads         =   TestDataFactoryUtil.createLead(2, 'B2B', 'EXTKEY0003',null, 'AP','BR','ACC', '21334455');        
        
        lstLeads.get(0).Customer__c = lstB2BAcc.get(0).Id;
        lstLeads.get(0).ownerid = u.Id;
        //lstLeads.get(0).CalculatedPOS__c = lstAccts.get(0).Id;
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            Insert lstUsers;
            System.debug('Results-->lstUsers Insert :  User 1: ' + lstUsers.get(0).Id + '  User 2: ' +lstUsers.get(1).Id + '  User 3: ' + lstUsers.get(2).Id );
        }
        lstAccts.get(0).AgentFlag__c                         = true;
        lstAccts.get(0).TECH_SalesManager__c                 = lstUsers.get(0).Id;
        lstAccts.get(0).TECH_AfterSalesManager__c            = lstUsers.get(1).Id;
        lstAccts.get(0).TECH_SalesManagerAgent__c            = lstUsers.get(2).Id;
		
        setaccounts.add(lstAccts.get(0).id);
        //lstOpps.get(0).OwnerId = lstUsers.get(0).Id;
        //update lstOpps;
        update lstAccts;
        System.debug('Results-->Account Update  Id: ' + lstAccts.get(0).Id + ' Sales Manager: ' + lstAccts.get(0).TECH_SalesManager__c + ' After Sales : ' + lstAccts.get(0).TECH_AfterSalesManager__c + ' Sales Agent: ' + lstAccts.get(0).TECH_SalesManagerAgent__c );

        // Perform test
        Test.startTest();
        	
        	System.runAs(u){
                lstLeads.get(1).TreatmentDueDate__c = system.now().adddays(2);
                lstLeads.get(0).TreatmentDueDate__c = system.now().adddays(1);
            	Insert lstLeads;
        	}
            
			LeadAssigmentProcess.AssignLeadBySalesMan(lstLeads, Userinfo.getUserId());
        	LeadAssigmentProcess.AssignLeadBySalesMan(lstLeads, '');
        	LeadAssigmentProcess.AssignLeadBySalesQueue(lstLeads, Userinfo.getUserId());
        	LeadAssigmentProcess.CheckFieldRuleValue('Test','Name',true);
        	LeadAssigmentProcess.getSalesManByDealer(setaccounts,lstLeads);

            List<Lead> lstLeadsResult = new List<Lead>([Select Id, OwnerId From Lead Where Id =:lstLeads.get(0).Id]);

            // Record must be assigned to the Saleman assigned to the Dealer.
            //System.assertEquals(lstLeadsResult.get(0).OwnerId, lstUsers.get(2).Id);

        Test.stopTest();

    }


    /* SALES MAN ASSIGMENT */
    @isTest static void Lead_RANDOM_AssignmentTest() {
		

        // Preparing the test conditions.
        List<String> lstActivities  =   new List<String>(); 
        lstActivities.add('Agent');
        lstActivities.add('ACC');
        List<Contact> lstConts      =   TestDataFactoryUtil.createPartnerUser(1,5, 'Dealer', '133225577','1247770', 'EXTKEY0004','AP','PT', 'J',lstActivities,false);
        List<Account> lstAccts      =   new List<Account>([Select Id,Name,TECH_SalesManager__c,TECH_AfterSalesManager__c,TECH_SalesManagerAgent__c From Account Where Id =:lstConts.get(0).AccountId]);
        List<Account> lstB2BAcc     =   TestDataFactoryUtil.createAccount(1,'B2B');
        List<Opportunity> lstOpps   =   TestDataFactoryUtil.createOpportunities(1, null ,lstAccts.get(0), 1000.0 ,'Proposal', 75);
        List<User> lstUsers         =   TestDataFactoryUtil.createUser(lstConts,'Salesman','Partner','Worker');
        List<Lead> lstLeads         =   TestDataFactoryUtil.createLead(2, 'B2B', 'EXTKEY0004',null, 'AP','PT','ACC', '12336655');        
        
        Integer rand = Math.round(Math.random()*1000);
        
        
        for(Contact oCont :lstConts){
            oCont.TECH_CounterSalesman__c = Math.mod(rand, 6);
            oCont.AvailableLeadTreatment__c = true;
        }
        
        
        
        //lstLeads.get(0).Customer__c = lstB2BAcc.get(0).Id;
        //lstLeads.get(0).CalculatedPOS__c = lstAccts.get(0).Id;
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            Insert lstUsers;
            System.debug('Results-->lstUsers Insert :  User 1: ' + lstUsers.get(0).Id + '  User 2: ' +lstUsers.get(1).Id + '  User 3: ' + lstUsers.get(2).Id );
        }
        lstAccts.get(0).AgentFlag__c                         = true;
        lstAccts.get(0).TECH_SalesManager__c                 = lstUsers.get(0).Id;
        lstAccts.get(0).TECH_AfterSalesManager__c            = lstUsers.get(1).Id;
        lstAccts.get(0).TECH_SalesManagerAgent__c            = lstUsers.get(4).Id;

        //lstOpps.get(0).OwnerId = lstUsers.get(0).Id;
        //update lstOpps;
        update lstAccts;
        System.debug('Results-->Account Update  Id: ' + lstAccts.get(0).Id + ' Sales Manager: ' + lstAccts.get(0).TECH_SalesManager__c + ' After Sales : ' + lstAccts.get(0).TECH_AfterSalesManager__c + ' Sales Agent: ' + lstAccts.get(0).TECH_SalesManagerAgent__c );
		User u = [Select id, country__c from user where profile.name = 'System Administrator' and isActive=true limit 1];
        u.Country__c = 'PL';
        update u;
        // Perform test
        Test.startTest();
        	System.runAs(u){
                lstLeads.get(0).ownerid = u.Id;
                lstLeads.get(0).TreatmentDueDate__c = system.now().adddays(1);
                lstLeads.get(1).TreatmentDueDate__c = system.now();
            Insert lstLeads;
            }
            System.debug('Results-->Lead:  Sales Manager: ' + lstLeads.get(0).CalculatedPOS__r.TECH_SalesManager__c + ' After Sales M: ' + lstLeads.get(0).CalculatedPOS__r.TECH_AfterSalesManager__c + ' Sales Agent: ' + lstLeads.get(0).CalculatedPOS__r.TECH_SalesManagerAgent__c );
            List<Lead> lstLeadsResult = new List<Lead>([Select Id, OwnerId,CalculatedPOS__c From Lead Where Id =:lstLeads.get(0).Id]);
            Map<Id,Id> mapCheckUser = new Map<Id,Id>();
            for(User auxUser : lstUsers){
                mapCheckUser.put(auxUser.Id,auxUser.Id);
            }
            // Record must be assigned to the Saleman assigned to the Dealer.
            //System.assertEquals(lstLeadsResult.get(0).OwnerId, mapCheckUser.get(lstLeadsResult.get(0).OwnerId));
			LeadAssigmentProcess.setSalesManagerOwner(lstLeadsResult.get(0),'VN');
        	LeadAssigmentProcess.UpdateRecords(lstLeadsResult);
        Test.stopTest();

    }
    
	/* QUEUE ASSIGMENT */
    @isTest static void Lead_QUEUE_AssignmentERRORTest() {

        // Preparing the test conditions.
        List<String> lstActivities  =   new List<String>(); 
        lstActivities.add('VN');
        List<Account> lstAccounts   =   TestDataFactoryUtil.createDealers(1, 'Dealer', '133225511','1237770', 'EXTKEY0001','AP','ES', 'J',lstActivities,true);
        List<Lead> lstLeads1         =   new List<Lead> {new Lead(
            FirstName                   = 'First Name LARP', 
            LastName                    =  'tEST LARP',
            Street                      = 'Calle de Sebastián Elcano 1',
            City                        = 'Madrid',
            Country                     = 'España',
            Latitude                    =  39.9691,
            Longitude                   = -4.8237,
            PSABrand__c                 = 'AP',
            Email                       = 'psaLead@leadexample.com',
            CustomerType__c             = '1',
            LeadChannel__c              = '10',
            LeadRequestType__c          = '1',
            LeadSource                  = 'Partner',
            LeadType__c                 = '1',
            MarketingCode__c            = '01234567899876543210'
        )};
       	List<Account> lstB2BAcc     =   TestDataFactoryUtil.createAccount(1,'B2B');
        List<Lead> lstLeads         =   TestDataFactoryUtil.createLead(2, 'B2B', 'EXTKEY0002',null, 'AP','CL','VN', '22334455');
		lstLeads[0].fiscalid__c 	= '30686957-4';
        lstLeads[1].fiscalid__c 	= '30686957-4';
        System.debug('Results-->Lead:  OwnerId: ' + lstLeads.get(0).OwnerId + ' CalculatedPOS__c: ' + lstLeads.get(0).CalculatedPOS__c + ' Customer__c: ' + lstLeads.get(0).Customer__c );
        
        lstLeads.get(0).Customer__c = lstB2BAcc.get(0).Id;
		// Perform test
        Test.startTest();
        	lstLeads.get(0).TreatmentDueDate__c = system.now();
        	LeadAssigmentProcess.UpdateRecords(lstLeads1);
        	LeadAssigmentProcess.UpdateRecords(new List<Lead>());
			LeadAssigmentProcess.AssignLeadBySalesmanLoad(lstLeads,true);
        Test.stopTest();

	}
}
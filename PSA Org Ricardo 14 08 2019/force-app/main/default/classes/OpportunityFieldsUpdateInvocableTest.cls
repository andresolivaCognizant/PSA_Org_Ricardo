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
*/
@IsTest
public with sharing class OpportunityFieldsUpdateInvocableTest {
	
	@isTest
    static void OpportunityFieldsUpdateVNTest() {

        // Preparing the test conditions.
        List<String> lstActivities  =   new List<String>(); 
        lstActivities.add('VN');

        List<Contact> lstConts      =   TestDataFactoryUtil.createPartnerUser(1, 1, 'Dealer', '133225512','B123770', 'EXTKEY0030','AP','ES', 'J',lstActivities,true);
        List<Account> lstAccounts   =   new List<Account>([SELECT Id, Name, VNContractNumber__c, AgentContractNumber__c From Account Where Id = :lstConts.get(0).AccountId]);
        //List<Account> lstAccounts =   TestDataFactoryUtil.createDealers(1, 'Dealer', '133225513','A123770', 'EXTKEY0033','AP','ES', 'J',lstActivities,true);
        //update lstAccounts;
        
        List<User> lstUsers			= 	TestDataFactoryUtil.createUser(lstConts ,'Salesman','Partner','Manager');
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            Insert lstUsers;
        }

        lstAccounts.get(0).OwnerId 	= lstUsers.get(0).Id;
        List<Opportunity> lstOpps   =   TestDataFactoryUtil.createOpportunities(1, null ,lstAccounts.get(0), 1000.0 ,'Proposal', 75);

        // Perform test
        Test.startTest();
            List<OpportunityFieldsUpdateInvocable.ObjectRequest> lWrActivity 	= new List<OpportunityFieldsUpdateInvocable.ObjectRequest>();
        	OpportunityFieldsUpdateInvocable.ObjectRequest wrp 					= new OpportunityFieldsUpdateInvocable.ObjectRequest();
	        wrp.recordId 	= lstOpps.get(0).Id;
        	lWrActivity.add(wrp);
			OpportunityFieldsUpdateInvocable.handleRecords(lWrActivity);
        Test.stopTest();

        List<Opportunity> lstOppResult = new List<Opportunity>([Select Id, VNContractNumber__c, AgentContractNumber__c From Opportunity Where Id =:lstOpps.get(0).Id]);
		System.assertEquals(lstOppResult.get(0).VNContractNumber__c, lstAccounts.get(0).VNContractNumber__c);
    }


    @isTest
    static void OpportunityFieldsUpdateAgentTest() {

        // Preparing the test conditions.
        List<String> lstActivities  =   new List<String>(); 
        lstActivities.add('Agent');
        
        List<Contact> lstConts      =   TestDataFactoryUtil.createPartnerUser(1, 1, 'Dealer', '033225512','C123770', 'EXTKEY0040','AP','ES', 'J',lstActivities,true);
        List<Account> lstAccounts   =   new List<Account>([SELECT Id, Name,  VNContractNumber__c, AgentContractNumber__c From Account Where Id = :lstConts.get(0).AccountId]);
        //List<Account> lstAccounts =   TestDataFactoryUtil.createDealers(1, 'Dealer', '133225513','A123770', 'EXTKEY0033','AP','ES', 'J',lstActivities,true);
        //update lstAccounts;
        
        List<User> lstUsers			= 	TestDataFactoryUtil.createUser(lstConts ,'Salesman','Partner','Manager');
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            Insert lstUsers;
        }

        lstAccounts.get(0).OwnerId 	= lstUsers.get(0).Id;
        List<Opportunity> lstOpps   =   TestDataFactoryUtil.createOpportunities(1, null ,lstAccounts.get(0), 1000.0 ,'Proposal', 75);

        // Perform test
        Test.startTest();
            List<OpportunityFieldsUpdateInvocable.ObjectRequest> lWrActivity 	= new List<OpportunityFieldsUpdateInvocable.ObjectRequest>();
        	OpportunityFieldsUpdateInvocable.ObjectRequest wrp 					= new OpportunityFieldsUpdateInvocable.ObjectRequest();
	        wrp.recordId 	= lstOpps.get(0).Id;
        	lWrActivity.add(wrp);
			OpportunityFieldsUpdateInvocable.handleRecords(lWrActivity);
        Test.stopTest();

        List<Opportunity> lstOppResult = new List<Opportunity>([Select Id, VNContractNumber__c, AgentContractNumber__c From Opportunity Where Id =:lstOpps.get(0).Id]);
		System.assertEquals(lstOppResult.get(0).AgentContractNumber__c, lstAccounts.get(0).AgentContractNumber__c);
    }

    @isTest
    static void OpportunityFieldsUpdateOtherVNTest() {

        // Preparing the test conditions.
        List<String> lstActivities  =   new List<String>(); 
        List<String>  lstActivitiesB=   new List<String>();
        lstActivities.add('PR');
        lstActivitiesB.add('VN');

        List<Contact> lstConts      =   TestDataFactoryUtil.createPartnerUser(1, 1, 'Dealer', '077776666','C444770', 'EXTKEY0077','AP','ES', 'J',lstActivities,true);
        List<Account> lstAccounts   =   new List<Account>([SELECT Id, Name,  VNContractNumber__c, AgentContractNumber__c From Account Where Id = :lstConts.get(0).AccountId]);
        List<Account> lstAccountsB  =   TestDataFactoryUtil.createDealers(1, 'Dealer', '990000000','Z123770', 'EXTKEY1021','AC','CL', '',lstActivitiesB,true);
        List<User> lstUsers			= 	TestDataFactoryUtil.createUser(lstConts ,'Salesman','Partner','Manager');
        User thisUser 				= [select Id from User where Id = :UserInfo.getUserId()];
        System.runAs ( thisUser ) {
            Insert lstUsers;
        }
        PartnerAccountLink__c pal 	= new PartnerAccountLink__c(SubscriberId__c=lstAccounts.get(0).Id,ProviderId__c=lstAccountsB.get(0).Id,BeginDate__c=Date.Today()-1,EndDate__c=Date.Today()+1);
        Insert pal;
        lstAccounts.get(0).OwnerId 	= lstUsers.get(0).Id;
        lstAccountsB.get(0).OwnerId = lstUsers.get(0).Id;
        List<Opportunity> lstOpps   = TestDataFactoryUtil.createOpportunities(1, null ,lstAccounts.get(0), 1000.0 ,'Proposal', 75);
        // Perform test
        Test.startTest();
            List<OpportunityFieldsUpdateInvocable.ObjectRequest> lWrActivity 	= new List<OpportunityFieldsUpdateInvocable.ObjectRequest>();
        	OpportunityFieldsUpdateInvocable.ObjectRequest wrp 					= new OpportunityFieldsUpdateInvocable.ObjectRequest();
	        wrp.recordId 			= lstOpps.get(0).Id;
        	lWrActivity.add(wrp);
			OpportunityFieldsUpdateInvocable.handleRecords(lWrActivity);
        Test.stopTest();

        List<Opportunity> lstOppResult = new List<Opportunity>([Select Id, VNContractNumber__c, AgentContractNumber__c From Opportunity Where Id =:lstOpps.get(0).Id]);
		System.assertEquals(lstOppResult.get(0).VNContractNumber__c, lstAccounts.get(0).VNContractNumber__c);
    }

    @isTest
    static void OpportunityFieldsUpdateOtherAgentTest() {

        // Preparing the test conditions.
        List<String> lstActivities  = new List<String>(); 
        List<String>  lstActivitiesB= new List<String>();
        lstActivities.add('VO');
        lstActivitiesB.add('Agent');

        List<Contact> lstConts      = TestDataFactoryUtil.createPartnerUser(1, 1, 'Dealer', '077771666','C444772', 'EXTKEY0072','AC','CL', '',lstActivities,true);
        List<Account> lstAccounts   = new List<Account>([SELECT Id, Name, VNContractNumber__c, AgentContractNumber__c From Account Where Id = :lstConts.get(0).AccountId]);
        List<Account> lstAccountsB  = TestDataFactoryUtil.createDealers(1, 'Dealer', '990034000','P123770', 'EXTKEY2022','AC','CL', '',lstActivitiesB,true);
        List<User> lstUsers			= TestDataFactoryUtil.createUser(lstConts ,'Salesman','Partner','Manager');
        User thisUser 				= [select Id from User where Id = :UserInfo.getUserId()];
        System.runAs ( thisUser ) {
            Insert lstUsers;
        }
        PartnerAccountLink__c palA 	= new PartnerAccountLink__c(SubscriberId__c=lstAccounts.get(0).Id,ProviderId__c=lstAccountsB.get(0).Id,BeginDate__c=Date.Today()-1,EndDate__c=Date.Today()+1);
        Insert palA;
        lstAccounts.get(0).OwnerId 	= lstUsers.get(0).Id;
        lstAccountsB.get(0).OwnerId = lstUsers.get(0).Id;
        List<Opportunity> lstOpps   = TestDataFactoryUtil.createOpportunities(1, null ,lstAccounts.get(0), 1000.0 ,'Proposal', 75);
        // Perform test
        Test.startTest();
            List<OpportunityFieldsUpdateInvocable.ObjectRequest> lWrActivity 	= new List<OpportunityFieldsUpdateInvocable.ObjectRequest>();
        	OpportunityFieldsUpdateInvocable.ObjectRequest wrp 					= new OpportunityFieldsUpdateInvocable.ObjectRequest();
	        wrp.recordId 			= lstOpps.get(0).Id;
        	lWrActivity.add(wrp);
			OpportunityFieldsUpdateInvocable.handleRecords(lWrActivity);
        Test.stopTest();

        List<Opportunity> lstOppResult = new List<Opportunity>([Select Id, VNContractNumber__c, AgentContractNumber__c From Opportunity Where Id =:lstOpps.get(0).Id]);
		System.assertEquals(lstOppResult.get(0).AgentContractNumber__c, lstAccounts.get(0).AgentContractNumber__c);
    }

}
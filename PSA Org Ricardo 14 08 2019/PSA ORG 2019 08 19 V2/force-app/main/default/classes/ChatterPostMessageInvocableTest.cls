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
@IsTest(SeeAllData=true)
public with sharing class ChatterPostMessageInvocableTest {
	
	@isTest( seeAllData = true )
    /* LeadChatterPostMessageTest */
    static void LeadChatterPostMessageTest() {

        // Preparing the test conditions.
        List<String> lstActivities  =   new List<String>(); 
        lstActivities.add('Agent');
        lstActivities.add('PR');
        List<Lead> lstLeads         =   TestDataFactoryUtil.createLead(1, 'B2B', 'EXTKEY0007',null, 'AP','ES','VN', '22334455');
        List<Contact> lstConts      =   TestDataFactoryUtil.createPartnerUser(1,3, 'Dealer', '133225511','1237770', 'EXTKEY0003','AP','ES', 'J',lstActivities,false);
        List<User> lstUsers			= 	TestDataFactoryUtil.createUser(lstConts ,'Salesman','Partner','Manager');
        Insert lstLeads;
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            Insert lstUsers;
        }

        
		lstLeads.get(0).OwnerId 	= lstUsers.get(0).Id;
        
        
        // Perform test
        Test.startTest();
            List<ChatterPostMessageInvocable.PostRequest> lWrActivity 	= new List<ChatterPostMessageInvocable.PostRequest>();
        	ChatterPostMessageInvocable.PostRequest wrp 				= new ChatterPostMessageInvocable.PostRequest();
	        wrp.fromId 		= lstUsers.get(0).Id;//UserInfo.getUserId();
	        wrp.toId 		= lstUsers.get(0).Id;
	        wrp.recordId 	= lstLeads.get(0).Id;
    	
        	lWrActivity.add(wrp);
            List<Lead> lstLeadsResult = new List<Lead>([Select Id, OwnerId From Lead Where Id =:lstLeads.get(0).Id]);
            update lstLeads;
			ChatterPostMessageInvocable.postMessage(lWrActivity);
            // Record must be assigned to the Saleman assigned to the Dealer.
            // System.assertEquals(lstLeadsResult.get(0).OwnerId, lstUsers.get(0).Id);

        Test.stopTest();

    }
}
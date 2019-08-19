/**
	*   @Class : LMAContainerControllerTest
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   12 April 2018
	*   @Description    :   Test for LMAContainerController
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Raul Barba				12/04/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
public class LMAContainerControllerTest {
    
    @isTest static void LMAContainerControllerTest(){
        // Test data setup
        List<String> lstActivities  =   new List<String>(); 
        lstActivities.add('VN');
        List<Contact> lstConts      =   TestDataFactoryUtil.createPartnerUser(1, 1, 'Dealer', '133225511','1237770', 'EXTKEY0002','AP','CL', 'J',lstActivities,true);
        List<Account> lstAccts      =   new List<Account>([Select Id,Name From Account Where Id =:lstConts.get(0).AccountId]);
        List<Account> lstB2BAcc     =   TestDataFactoryUtil.createAccount(1,'B2B');
        List<Opportunity> lstOpps   =   TestDataFactoryUtil.createOpportunities(1, null ,lstB2BAcc.get(0), 1000.0 ,'Proposal', 75);
        List<User> lstUsers         =   TestDataFactoryUtil.createUser(lstConts,'Salesman','Partner','Manager');
        List<Lead> lstLeads         =   TestDataFactoryUtil.createLead(1, 'B2B', 'EXTKEY0002',null, 'AP','CL','VN', '22122551-1');
        lstLeads.get(0).Phone       = '+56123456789';
        lstLeads.get(0).FiscalId__c = '22122551-1';
 		upsert lstLeads;
        lstLeads.get(0).Customer__c = lstB2BAcc.get(0).Id;
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            Insert lstUsers;
        }

		lstOpps.get(0).OwnerId = lstUsers.get(0).Id;
        update lstOpps;
        // Perform test
        Test.startTest();
        	LMAContainerController.getUserLeadCounts();
        	LMAContainerController.getUserPortalRole();
        	String sLeadsId ='[{"value":"'+lstLeads.get(0).Id + '"}]';
        	LMAContainerController.setTransferRecords(sLeadsId, lstUsers.get(0).Id);
        Test.stopTest();
        
    }

}
/**
	*   @Class : LMAResultControllerTest
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   12 April 2018
	*   @Description    :   Test for LMAResultController
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Raul Barba				12/04/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
public class LMAResultControllerTest {

    @isTest static void LMAResultControllerTest(){
        // Test data setup
        List<String> lstActivities  =   new List<String>(); 
        lstActivities.add('VN');
        List<Contact> lstConts      =   TestDataFactoryUtil.createPartnerUser(1, 1, 'Dealer', '133225511','1237770', 'EXTKEY0002','AP','CL', 'J',lstActivities,true);
        List<Account> lstAccts      =   new List<Account>([Select Id,Name From Account Where Id =:lstConts.get(0).AccountId]);
        List<Account> lstB2BAcc     =   TestDataFactoryUtil.createAccount(1,'B2B');
        List<Opportunity> lstOpps   =   TestDataFactoryUtil.createOpportunities(1, null ,lstB2BAcc.get(0), 1000.0 ,'Proposal', 75);
        List<User> lstUsers         =   TestDataFactoryUtil.createUser(lstConts,'Salesman','Partner','Manager');
        List<Lead> lstLeads         =   TestDataFactoryUtil.createLead(1, 'B2B', 'EXTKEY0002',null, 'AP','PL','VN', '22334455');
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
        	String sObj                 =   'Account';
            CSResultWrapper rwRecords   =   new CSResultWrapper();
        	String sLeadsId ='[{"value":"'+lstLeads.get(0).Id + '"}]';
        	LMAResultController.setTransferRecords(sLeadsId, lstUsers.get(0).Id);
            List<String> lstLabels      =   LMAResultController.getLabels(sObj,null,new String[]{'id','name','Owner.Name','UserRecordAccess.HasReadAccess'});
        	List<String> lstLabels2     =   LMAResultController.getLabels(sObj,'Account',new String[]{'id','name','Owner.Name','UserRecordAccess.HasReadAccess'});
        	LMAResultController.getUserLeadCounts(True);
        	LMAResultController.getUserLeadCounts(False);
        Test.stopTest();
        
    }
    
    @isTest 
    static void AccountSearchTest() {
        // Test data setup
        // Create one account by calling a utility method
        List<Account> lstAccts = TestDataFactoryUtil.createAccount(1,'B2B');
        
        // Perform test
        Test.startTest();
            List<String> aux            =   new List<String>();
            String sObj                 =   'Lead';
            CSResultWrapper rwRecords   =   new CSResultWrapper();
            rwRecords                   =   LMAResultController.getRecords(sObj,'Name','id,name,Owner.name',5,'10','LastViewedDate','',true,'','',true,'');
        	rwRecords                   =   LMAResultController.getRecords(sObj,'Name','id,name,Owner.name',5,'10','LastViewedDate','(\'Test\',\'Test2\')',true,'Test','Test',true,' WHERE Id != null ');
            rwRecords                   =   LMAResultController.getRecords(sObj,'Name','id,name,Owner.name',5,'10','LastViewedDate','(\'Test\',\'Test2\')',true,'Test','Test',false,' WHERE Id != null ');
            List<String> lstLabels      =   LMAResultController.getLabels(sObj,null,new String[]{'id','name','Owner.Name','UserRecordAccess.HasReadAccess'});
        Test.stopTest();

    } 

    @isTest 
    static void FechRecordsTest() {
      
        // Preparing the test conditions.
        List<String> lstActivities  =   new List<String>(); 
        lstActivities.add('VN');
        List<Contact> lstConts      =   TestDataFactoryUtil.createPartnerUser(1, 1, 'Dealer', '133225511','1237770', 'EXTKEY0002','AP','CL', 'J',lstActivities,true);
        List<Account> lstAccts      =   new List<Account>([Select Id,Name From Account Where Id =:lstConts.get(0).AccountId]);
        List<Account> lstB2BAcc     =   TestDataFactoryUtil.createAccount(1,'B2B');
        List<User> lstUsers         =   TestDataFactoryUtil.createUser(lstConts,'Salesman','Partner','Manager');
        List<Lead> lstLeads         =   TestDataFactoryUtil.createLead(1, 'B2B', 'EXTKEY0002',null, 'AP','PL','VN', '22334455');

        System.debug('Results-->Lead:  OwnerId: ' + lstLeads.get(0).OwnerId + ' CalculatedPOS__c: ' + lstLeads.get(0).CalculatedPOS__c + ' Customer__c: ' + lstLeads.get(0).Customer__c );
        
        lstLeads.get(0).Customer__c = lstB2BAcc.get(0).Id;
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            Insert lstUsers;
        }

        // Perform test
        Test.startTest();
            Insert lstLeads;

            LMAResultController.getfetchRecords('Lead','Id,Name','');
        	LMAResultController.getFieldLabels('Lead','Account', new List<String> {'Id','Name'});

        Test.stopTest();
    }

}
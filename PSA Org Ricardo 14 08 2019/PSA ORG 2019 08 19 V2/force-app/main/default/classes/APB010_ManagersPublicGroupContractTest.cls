/**
	*   @Class : APB010_ManagersPublicGroupContract
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   07 Jun 2018
	*   @Description    :   Test for APB010_ManagersPublicGroupContract batch
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Raul Barba				07 Jun 2018				 Creation.	
    *      Pedro Párraga            18/06/2019               Edit.  	
	*   ----------------------------------------------------------------------------------------------------------------------------
**/

@isTest
public class APB010_ManagersPublicGroupContractTest {
    
    @isTest static void createPublicGroup() {
        // Test data setup
        AccountTriggerHandler.dontRunTrigger();
        UserTriggerHandler.dontRunTrigger();
        List<Account> lstAccts = TestDataFactoryUtil.createAccount(7,'Dealer');
        for(Account acc : lstAccts){
            acc.VNContractBeginDate__c = date.today().addDays(-1);
            acc.VNContractEndDate__c = date.today().addDays(1);
            acc.RAContractBeginDate__c = date.today().addDays(-1);
            acc.RAContractEndDate__c = date.today().addDays(1);
            acc.AgentContractBeginDate__c = date.today().addDays(-1);
            acc.AgentContractEndDate__c = date.today().addDays(1);
            acc.IsPartner = true;
        }
        lstAccts.get(0).VNPrincipalSite__c = true;
        lstAccts.get(0).VNContractNumber__c = '1010';
        lstAccts.get(1).VNContractNumber__c = '1010';
        lstAccts.get(3).VNPrincipalSite__c = true;
        lstAccts.get(3).RAContractNumber__c = '1111';
        lstAccts.get(3).Country__c = 'CL';
        lstAccts.get(4).RAContractNumber__c = '1010';
        lstAccts.get(4).TECH_PublicGroupsContract__c = '0000000';
        lstAccts.get(5).RAContractNumber__c = '1111';
        lstAccts.get(5).TECH_PublicGroupsContract__c = '0000000';
        lstAccts.get(6).TECH_PublicGroupsContract__c = '0000000';
        lstAccts.get(6).AgentContractNumber__c = '1112';
        lstAccts.get(2).AgentContractNumber__c = '1112';
		update lstAccts;
        
        Contact cnt1             =   new Contact (
                    FirstName           =   'First Name 1',
                    LastName            =   'LastName_',
                    Salutation          =   '1',
                    Email               =   'psaContactFirstName1@contactexample.com',
                    NationalId__c       =   '30.686.957-4',
                    Phone               =   '123456789',
                    AccountId           =   lstAccts.get(0).Id
                    );
        Contact cnt2             =   new Contact (
                    FirstName           =   'First Name 2',
                    LastName            =   'LastName_',
                    Salutation          =   '1',
                    Email               =   'psaContactFirstName2@contactexample.com',
                    NationalId__c       =   '18.602.448-6',
                    Phone               =   '123456789',
                    AccountId           =   lstAccts.get(1).Id
                    );
        insert cnt1;
        insert cnt2;
        List<Contact> lstConts1 = new List<Contact>();
        List<Contact> lstConts2 = new List<Contact>();
        lstConts1.add(cnt1);
        lstConts2.add(cnt2);
        List<User> lstUsers1 =   TestDataFactoryUtil.createUser(lstConts1,'Sales_Manager','Partner','Manager');
        List<User> lstUsers2 =   TestDataFactoryUtil.createUser(lstConts2,'Salesman','Partner','Manager');
        
        Insert lstUsers1;
        Insert lstUsers2;
        
        lstAccts.remove(6);
        // Perform test
        Test.startTest();
        	APB010_ManagersPublicGroupContract b = new APB010_ManagersPublicGroupContract(); 
            Database.executeBatch(b,60);
            
            ManualSharingProcess.ManualSharing(ManualSharingProcess.setRecordToShare( lstAccts.get(3).id, lstUsers1.get(0).id));
            ManualSharingProcess.ManualSharing(ManualSharingProcess.setRecordToShare( lstAccts.get(3).id, lstUsers2.get(0).id));
            ManualSharingProcess.ManualSharing(ManualSharingProcess.setRecordToShare( lstAccts.get(1).id, lstUsers2.get(0).id));
        	
        Test.stopTest();
        
        System.assertEquals(7, [select id from account where isPartner = true 
                                    and RecordType.DeveloperName = 'Account_DealerPartner' and TECH_PublicGroupsContract__c != null 
                                    and TECH_PublicGroupsContract__c != '0000000'].size());

    }

}
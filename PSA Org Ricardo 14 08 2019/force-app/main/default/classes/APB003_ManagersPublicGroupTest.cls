/**
	*   @Class : APB003_ManagersPublicGroupTest
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   22 Feb 2018
	*   @Description    :   Test for APB003_ManagersPublicGroup batch
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Raul Barba				22/2/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/

@isTest
public class APB003_ManagersPublicGroupTest {
    
    @isTest static void createPublicGroup() {
        // Test data setup
        AccountTriggerHandler.dontRunTrigger();
        UserTriggerHandler.dontRunTrigger();
        List<Account> lstAccts = TestDataFactoryUtil.createAccount(7,'Dealer');
        for(Account acc : lstAccts){
            acc.VNContractBeginDate__c = date.today().addDays(-1);
            acc.VNContractEndDate__c = date.today().addDays(1);
            acc.IsPartner = true;
        }
        lstAccts.get(0).VNPrincipalSite__c = true;
        lstAccts.get(0).VNContractNumber__c = '1010';
        lstAccts.get(1).VNContractNumber__c = '1010';
        lstAccts.get(3).VNPrincipalSite__c = true;
        lstAccts.get(3).VNContractNumber__c = '1111';
        lstAccts.get(3).Country__c = 'ES';
        lstAccts.get(4).VNContractNumber__c = '1010';
        lstAccts.get(4).TECH_PublicGroups__c = '0000000';
        lstAccts.get(5).VNContractNumber__c = '1010';
        lstAccts.get(5).TECH_PublicGroups__c = '0000000';
        lstAccts.get(6).TECH_PublicGroups__c = '0000000';
        lstAccts.get(0).SiteGeoIdPK__c = '1010101';
        lstAccts.get(3).SiteGeoIdPK__c = '1111111';
		update lstAccts;
        PartnerAccountLink__c part = new PartnerAccountLink__c(
                ProviderId__c = lstAccts.get(0).Id, 
                SubscriberId__c = lstAccts.get(2).Id);
		insert part;
        part = new PartnerAccountLink__c(
                ProviderId__c = lstAccts.get(0).Id, 
                SubscriberId__c = lstAccts.get(5).Id);
		insert part;
        part = new PartnerAccountLink__c(
                ProviderId__c = lstAccts.get(0).Id, 
                SubscriberId__c = lstAccts.get(6).Id);
		insert part;
        
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
        List<User> lstUsers2 =   TestDataFactoryUtil.createUser(lstConts2,'Sales_Manager','Partner','Manager');
        
        Insert lstUsers1;
        Insert lstUsers2;
        
        lstAccts.remove(6);
        // Perform test
        Test.startTest();
        	APB003_ManagersPublicGroup b = new APB003_ManagersPublicGroup(); 
            Database.executeBatch(b,60);
        	
        Test.stopTest();
        
        System.assertEquals(7, [select id from account where isPartner = true 
                                    and RecordType.DeveloperName = 'Account_DealerPartner' and TECH_PublicGroups__c != null 
                                    and TECH_PublicGroups__c != '0000000'].size());

    }

}
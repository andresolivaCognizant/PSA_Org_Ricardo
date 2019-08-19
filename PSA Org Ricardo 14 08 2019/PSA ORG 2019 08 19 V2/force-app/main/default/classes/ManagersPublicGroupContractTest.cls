/**
	*   @Class : ManagersPublicGroupContractTest
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   07 Jun 2018
	*   @Description    :   Test for ManagersPublicGroupContract Apex class
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Raul Barba				07 Jun 2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/

@isTest
public class ManagersPublicGroupContractTest {
    
    @isTest static void createPublicGroup() {
        // Test data setup
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
        
        lstAccts.remove(6);
        
        // Perform test
        Test.startTest();
        	update lstAccts;
        	System.assertEquals(6, [select id from account where isPartner = true 
                                    and RecordType.DeveloperName = 'Account_DealerPartner' and TECH_PublicGroupsContract__c != null 
                                    and TECH_PublicGroupsContract__c != '0000000'].size());
            
            lstAccts.get(2).TECH_PublicGroupsContract__c  = null;      
            lstAccts.get(5).TECH_PublicGroupsContract__c  = '0000000';  
            lstAccts.get(4).TECH_PublicGroupsContract__c  = null; 
            lstAccts.get(1).TECH_PublicGroupsContract__c  = null;                
            update lstAccts;
            ManualSharingProcess.ManualSharing(ManualSharingProcess.setRecordToShare( lstAccts.get(3).id, UserInfo.getUserId()));
            AccountTriggerHandler.dontRunTrigger();
            List<User> lUsers = [select id, Profile.Name, Contact.Account.Id, Contact.Account.Country__c, profile.UserLicense.name, IsActive, 
                             Contact.Account.TECH_PublicGroups__c, Contact.Account.TECH_PublicGroupsContract__c, Contact.Account.RecordType.DeveloperName, 
                             Contact.Account.RecordTypeId, Contact.Account.isPartner, Contact.Account.VNPrincipalSite__c, 
                             Contact.Account.TECH_VNContractActive__c, Contact.Account.VNContractNumber__c, 
                             Contact.Account.SiteGeoIdPK__c, Contact.Account.BillingCountry 
                             from User Limit 100];
            ManagersPublicGroupContract.PopulatedPublicGroup(lUsers);

        Test.stopTest();

    }
}
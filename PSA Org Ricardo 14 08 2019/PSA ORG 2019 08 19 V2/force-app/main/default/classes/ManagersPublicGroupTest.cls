/**
	*   @Class : ManagersPublicGroupTest
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   22 Feb 2018
	*   @Description    :   Test for AccountPublicGroup Apex class
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Raul Barba				22/2/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/

@isTest
public class ManagersPublicGroupTest {
    
    @isTest static void createPublicGroup() {
        // Test data setup
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
        lstAccts.get(3).Country__c = 'CL';
        lstAccts.get(4).VNContractNumber__c = '1010';
        lstAccts.get(4).TECH_PublicGroups__c = '0000000';
        lstAccts.get(5).VNContractNumber__c = '1010';
        lstAccts.get(5).TECH_PublicGroups__c = '0000000';
        lstAccts.get(6).TECH_PublicGroups__c = '0000000';
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
        
        lstAccts.remove(6);
        
        // Perform test
        Test.startTest();
        	lstAccts.get(0).SiteGeoIdPK__c = '1010101';
        	lstAccts.get(3).SiteGeoIdPK__c = '1111111';
        	update lstAccts;
        	System.assertEquals(7, [select id from account where isPartner = true 
                                    and RecordType.DeveloperName = 'Account_DealerPartner' and TECH_PublicGroups__c != null 
                                    and TECH_PublicGroups__c != '0000000'].size());
            
            lstAccts.get(2).TECH_PublicGroups__c  = null;      
            lstAccts.get(5).TECH_PublicGroups__c  = '0000000';  
            lstAccts.get(4).TECH_PublicGroups__c  = null; 
            lstAccts.get(1).TECH_PublicGroups__c  = null;                
            update lstAccts;
            AccountTriggerHandler.dontRunTrigger();
        Test.stopTest();

    }
}
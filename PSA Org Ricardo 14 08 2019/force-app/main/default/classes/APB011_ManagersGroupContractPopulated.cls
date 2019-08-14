/**
	*   @Class : APB011_ManagersGroupContractPopulated
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   07 Jun 2018
	*   @Description    :   Batch to populated the public groups for contract number.
							Those who do process the previous batch (APB010_ManagersPublicGroupContract).
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Raul Barba				07 Jun 2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
public class APB011_ManagersGroupContractPopulated implements Database.Batchable<sObject>{
    
    public String sales = 'Sales_Manager';
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('## APB011_ManagersGroupContractPopulated START');
        String query = 'select id, Profile.Name, Contact.Account.Id, Contact.Account.Country__c, Contact.Account.TECH_PublicGroups__c, Contact.Account.TECH_PublicGroupsContract__c, profile.UserLicense.name, IsActive,' 
            + 'Contact.Account.RecordType.DeveloperName, Contact.Account.RecordTypeId, Contact.Account.isPartner, Contact.Account.VNPrincipalSite__c, '
            + 'Contact.Account.TECH_VNContractActive__c, Contact.Account.VNContractNumber__c, Contact.Account.SiteGeoIdPK__c, Contact.Account.BillingCountry'
            + ' from User ' 
            + 'where ContactID != null and Contact.Account.IsPartner = TRUE';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<User> scope){
        System.debug('## APB011_ManagersGroupContractPopulated EXECUTE');
        ManagersPublicGroupContract.PopulatedPublicGroup(scope);
    }   
    public void finish(Database.BatchableContext BC){ 
        System.debug('## APB011_ManagersGroupContractPopulated FINISH');
    }
}
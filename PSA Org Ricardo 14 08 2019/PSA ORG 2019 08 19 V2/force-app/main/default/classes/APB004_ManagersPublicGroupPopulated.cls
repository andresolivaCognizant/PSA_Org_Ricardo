/**
	*   @Class : APB004_ManagersPublicGroupPopulated
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   23 Feb 2018
	*   @Description    :   Batch to populated the public groups for dealer partner account.
							Those who do process the previous batch (APB003_ManagersPublicGroup).
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Raul Barba				23/2/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
public class APB004_ManagersPublicGroupPopulated implements Database.Batchable<sObject>{
    
    public String sales = 'Sales_Manager';
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('## APB004_ManagersPublicGroupPopulated START');
        String query = 'select id, Profile.Name, Contact.Account.Id, Contact.Account.Country__c, Contact.Account.TECH_PublicGroups__c, ' 
            + 'Contact.Account.RecordType.DeveloperName, Contact.Account.RecordTypeId, Contact.Account.isPartner, Contact.Account.VNPrincipalSite__c, '
            + 'Contact.Account.TECH_VNContractActive__c, Contact.Account.VNContractNumber__c, Contact.Account.SiteGeoIdPK__c, Contact.Account.BillingCountry'
            + ' from User ' 
            + 'where ContactID != null and Contact.Account.IsPartner = TRUE and Profile.Name = \''+sales+'\'';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<User> scope){
        System.debug('## APB004_ManagersPublicGroupPopulated EXECUTE');
        ManagersPublicGroup.PopulatedPublicGroup(scope);
    }   
    public void finish(Database.BatchableContext BC){ 
        System.debug('## APB004_ManagersPublicGroupPopulated FINISH');
    }
}
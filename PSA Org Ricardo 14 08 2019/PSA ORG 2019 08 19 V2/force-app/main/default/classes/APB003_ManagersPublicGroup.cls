/**
	*   @Class : APB003_ManagersPublicGroup
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   21 Feb 2018
	*   @Description    :   Batch to create the public group for dealer partner account and update the 
							TECH_PublicGroups__c field for all the dealer partner account that it's necessary.
							For populated the public groups in following bath process (APB004_ManagersPublicGroupPopulated)
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Raul Barba				21/2/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
public class APB003_ManagersPublicGroup implements Database.Batchable<sObject>{
    
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('## APB003_ManagersPublicGroup START');
        String query = 'select id, Country__c, TECH_PublicGroups__c, RecordType.DeveloperName, RecordTypeId, isPartner,' 
            + 'VNPrincipalSite__c, TECH_VNContractActive__c, VNContractNumber__c, SiteGeoIdPK__c, BillingCountry'  
            + ' from Account ' 
            + 'where isPartner = true and RecordType.DeveloperName = \'Account_DealerPartner\' and VNPrincipalSite__c = true  and TECH_VNContractActive__c = true and VNContractNumber__c != null and SiteGeoIdPK__c != null';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Account> scope){
        System.debug('## APB003_ManagersPublicGroup EXECUTE');  
        update ManagersPublicGroup.createPublicGroup(scope);
    }   
    public void finish(Database.BatchableContext BC){ 
        System.debug('## APB003_ManagersPublicGroup FINISH');
        Id batch2JobId = Database.executeBatch(new APB004_ManagersPublicGroupPopulated());
    }


}
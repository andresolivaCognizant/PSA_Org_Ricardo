/**
	*   @Class : APB010_ManagersPublicGroupContract
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   07 Jun 2018
	*   @Description    :   Batch to create the public group for contract number.
							For populated the public groups in following bath process (APB011_ManagersGroupContractPopulated)
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Raul Barba				 07 Jun 2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
public class APB010_ManagersPublicGroupContract implements Database.Batchable<sObject>{
    
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('## APB010_ManagersPublicGroupContract START');
        String query = 'select id, Country__c, TECH_PublicGroups__c, TECH_PublicGroupsContract__c, RecordType.DeveloperName, RecordTypeId, isPartner,' 
            + 'VNPrincipalSite__c, TECH_VNContractActive__c, VNContractNumber__c, SiteGeoIdPK__c, BillingCountry, RAContractNumber__c, TECH_RAContractActive__c, AgentContractNumber__c, TECH_AgentContractActive__c'  
            + ' from Account ' 
            + 'where isPartner = true and RecordType.DeveloperName = \'Account_DealerPartner\'  and ((TECH_VNContractActive__c = true and VNContractNumber__c != null) or (TECH_RAContractActive__c = true and RAContractNumber__c != null) or (TECH_AgentContractActive__c = true and AgentContractNumber__c != null)) ';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Account> scope){
        System.debug('## APB010_ManagersPublicGroupContract EXECUTE');  
        update ManagersPublicGroupContract.createPublicGroup(scope);
    }   
    public void finish(Database.BatchableContext BC){ 
        System.debug('## APB010_ManagersPublicGroupContract FINISH');
        Id batch2JobId = Database.executeBatch(new APB011_ManagersGroupContractPopulated());
    }


}
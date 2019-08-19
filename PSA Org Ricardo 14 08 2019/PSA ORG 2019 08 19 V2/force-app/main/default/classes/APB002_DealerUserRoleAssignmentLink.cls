/**
	*   @Class : APB002_DealerUserRoleAssignmentLink
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   07 Feb 2018
	*   @Description    :   Batch to get the Aftersales Manager, Sales Manager and Sales Manager Agent to the Account using
							the 3 custom fields TECH_SalesManager__c, TECH_AfterSalesManager__c and TECH_SalesManagerAgent__c.
							Those who do not find in the previous batch (APB001_DealerUserRoleAssigment) will be searched
							in the related partner accounts through the custom object PartnerAccountLink__c
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Raul Barba				07/2/2018				 Creation.		
	* 	   Sergio Lopez				12/12/2018               Modify: Now it is used as reference of principal Sales Manager, After Sales Manager 
	*															and Sales Manager Agent those who were flagged as principal.
	*															In case of NO After Sales Manager flagged as principal or active it is assigned the Sales Manager.
	*															In case of NO Sales MAnager Agent flagged or active it is assigned a Sales Manager from PartnerAccountLink__c (Provider).	
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
public class APB002_DealerUserRoleAssignmentLink  implements Database.Batchable<sObject>, Database.Stateful{
    
    public List<Account> lAccSMAgent;
    
    public APB002_DealerUserRoleAssignmentLink(List<Account> lAcc){
    	System.debug('## APB002_DealerUserRoleAssignmentLink lAcc: '+lAcc);
    	lAccSMAgent = lAcc;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('## APB002_DealerUserRoleAssignmentLink START');
        String query = 'select ProviderId__r.Id, ProviderId__r.Name, ProviderId__r.TECH_SalesManager__c, SubscriberId__r.VNContractNumber__c, ' 
            + 'ProviderId__r.TECH_AfterSalesManager__c, ProviderId__r.TECH_SalesManagerAgent__c, SubscriberId__r.Id, SubscriberId__r.Name, '
            + 'SubscriberId__r.TECH_SalesManager__c, SubscriberId__r.TECH_AfterSalesManager__c, SubscriberId__r.TECH_SalesManagerAgent__c'
            + ' from PartnerAccountLink__c ' 
            + 'where ProviderId__r.VNPrincipalSite__c = TRUE'; //and ProviderId__r.TECH_SalesManager__r.Contact.SetAsPrincipalManager__c = TRUE'
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<PartnerAccountLink__c> scope){
        System.debug('## APB002_DealerUserRoleAssignmentLink EXECUTE');  
        
        Map<String, Account> accountMap = new Map<String, Account> {};
        List<Account> lAccToUpd = new List<Account> ();

		try {          
	      	for(PartnerAccountLink__c part : scope){
	      		accountMap.put(part.SubscriberId__r.Id, part.ProviderId__r);
	      	}
	      	
	      	for (Account acc : lAccSMAgent){
	      		if (accountMap.containsKey(acc.Id)){	  
		      		if (accountMap.get(acc.Id).TECH_SalesManager__c != null){
		      			system.debug('## APB002_DealerUserRoleAssignmentLink SM: '+accountMap.get(acc.Id).TECH_SalesManager__c+' Acc: '+acc.Id);
		      			acc.TECH_SalesManagerAgent__c = accountMap.get(acc.Id).TECH_SalesManager__c;
		      		}
	      		}
	      		
	      		lAccToUpd.add(acc);
	         }
	         
	         if (!lAccToUpd.isEmpty()){
	         	update lAccToUpd;
	         }
	         
		} catch(dmlexception e) {
	    	string error = 'DMLexception ERROR APB002_DealerUserRoleAssignmentLink --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
	    	system.debug('Error: '+error);
        }  catch(exception e){
        	string error = 'Exception ERROR APB002_DealerUserRoleAssignmentLink --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
            system.debug('Error: '+error);
        } 
        
    }   
    
    public void finish(Database.BatchableContext BC){ 
        System.debug('## APB002_DealerUserRoleAssignmentLink FINISH');
    }
}
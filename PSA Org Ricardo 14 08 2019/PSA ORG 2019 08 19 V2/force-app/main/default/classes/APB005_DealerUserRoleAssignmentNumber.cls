/**
	*   @Class : APB005_DealerUserRoleAssignmentNumber
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   01 March 2018
	*   @Description    :   Batch to get the Aftersales Manager, Sales Manager and Sales Manager Agent to the Account using
							the 3 custom fields TECH_SalesManager__c, TECH_AfterSalesManager__c and TECH_SalesManagerAgent__c.
							Those who do not find in the previous batchs (APB001_DealerUserRoleAssignment and APB002_DealerUserRoleAssignmentLink) 
							will be searched in the related partner accounts through the VNContractNumber__c field.
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Raul Barba				01/3/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
public class APB005_DealerUserRoleAssignmentNumber   implements Database.Batchable<sObject>, Database.Stateful{
    
    public Map<String, List<String>> updateAccountFields;
    public String after = 'Aftersales_Manager';
    public String sales = 'Sales_Manager';
    public Map<String, Id> VNAccountsSales;
    public Map<String, Id> VNAccountsAfter;
    
    public APB005_DealerUserRoleAssignmentNumber(Map<String, List<String>> up, Map<String, Id> VNAfter, Map<String, Id> VNSales){
    	updateAccountFields= up;
		VNAccountsAfter = VNAfter;
        VNAccountsSales = VNSales;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('## APB005_LeadAssignmentNumber START');
        String query = 'select Id, Name, TECH_SalesManager__c, TECH_AfterSalesManager__c, TECH_SalesManagerAgent__c, VNContractNumber__c'
            + ' from Account ' 
            + 'where VNPrincipalSite__c = FALSE and IsPartner = TRUE and VNContractNumber__c != null and VNContractNumber__c != \'\' and (TECH_SalesManager__c = null or TECH_AfterSalesManager__c = null)';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Account> scope){
        System.debug('## APB005_LeadAssignmentNumber EXECUTE');  
          for(Account acc : scope){
              if(!updateAccountFields.get(sales).contains(acc.Id) && VNAccountsSales.containsKey(acc.VNContractNumber__c)){
                  acc.TECH_SalesManager__c = VNAccountsSales.get(acc.VNContractNumber__c);
              }
              if(!updateAccountFields.get(after).contains(acc.Id) && VNAccountsAfter.containsKey(acc.VNContractNumber__c)){
                  acc.TECH_AfterSalesManager__c = VNAccountsAfter.get(acc.VNContractNumber__c);
              }
         }
         update scope;
    }   
    public void finish(Database.BatchableContext BC){ 
        System.debug('## APB005_LeadAssignmentNumber FINISH');
    }

}
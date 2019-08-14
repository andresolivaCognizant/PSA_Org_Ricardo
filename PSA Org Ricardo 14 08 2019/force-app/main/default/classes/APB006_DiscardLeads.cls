/**
	*   @Class 			: 	APB006_DiscardLeads
	*
	*   @Author         :   Ruben Fernandez
	*   @Created        :   09 March 2018
	*   @Description    :   Discard Leads if not converted before due date time assigned
	*
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Ruben Fernandez			09/03/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
global class APB006_DiscardLeads implements Database.Batchable<sObject> {
	
	public final String LEAD_STATUS = 'Discarded';

	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		String query = 'SELECT Id,Status,TECH_DiscardTime__c,Customer__c,CustomerContact__c ' 
            + ' FROM Lead ' 
            + ' WHERE TECH_DiscardTime__c = TODAY ';
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Lead> scope) {
		List<Lead> lstToConvert = new List<Lead>();
		for(Lead l : scope){
			l.Status 			= LEAD_STATUS;
			if(l.Customer__c!=null){
				lstToConvert.add(l);	
			}
		}
		if(!lstToConvert.isEmpty()){
			LeadConversionProcess.ConvertLeadStatus(lstToConvert,true);
		}
		if(!scope.isEmpty()){
			Update scope;
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}
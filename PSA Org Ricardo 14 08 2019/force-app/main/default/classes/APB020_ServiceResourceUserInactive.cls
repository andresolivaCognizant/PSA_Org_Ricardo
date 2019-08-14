/**
*   @Class          :   APB020_ServiceResourceUserInactive.cls
*   @Author         :   Sergio López
*   @Created        :   22 Mar 2019
*   @Description    :   Called Batch to Inactive User realted to Service Resource
*
*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Author             Date             Description
*      Segio Lopez        22/03/2019       Creation.
*   ----------------------------------------------------------------------------------------------------------------------------
**/ 
global class APB020_ServiceResourceUserInactive implements Database.Batchable<sObject> {

    /*Set<Id> setUsers = new Set<Id>();

    global APB020_ServiceResourceUserInactive(Set<Id> setSrOw) {
        System.debug('## setSrOw: '+setSrOw);
        setUsers = setSrOw;
    }*/
	 
	global Database.QueryLocator start(Database.BatchableContext BC) { 
		String query = 'SELECT Id, RelatedRecordId';
            query += ' FROM ServiceResource ';            
           	query += ' WHERE IsActive = false AND RelatedRecord.IsActive = true';
             
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<ServiceResource> scope) { 

        Set<Id> setSrRldId     = new Set<Id>(); 
   		   		
		for(ServiceResource l : scope){  
			setSrRldId.add(l.RelatedRecordId);
		}
   		
        If (!setSrRldId.isEmpty()){
            ServiceResourceUtils.updUsers(setSrRldId);
        }
           					
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}
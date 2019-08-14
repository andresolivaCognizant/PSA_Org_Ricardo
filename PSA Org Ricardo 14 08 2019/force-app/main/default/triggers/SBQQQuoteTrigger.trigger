trigger SBQQQuoteTrigger on SBQQ__Quote__c (after delete, after insert, after update, before delete, before insert, before update) {
    
    
    
	 if(SBQQQuoteTriggerHandler.shouldRunTrigger()) {
    
	    /***************************************************
							* BEFORE *
		****************************************************/
	
		if (Trigger.isBefore){
			
			/* INSERT */
			if (Trigger.isInsert) {
                SBQQQuoteTriggerHandler.beforeInsert(trigger.new);
                                				
			}
	
			/* UPDATE */
			if(Trigger.isUpdate){
                SBQQQuoteTriggerHandler.beforeUpdate(trigger.new, Trigger.OldMap);
			}
	
			/* DELETE */
			if(Trigger.isDelete){
			}
	
	
		/***************************************************
							* AFTER *
		****************************************************/
	
		}else{
		
			/* INSERT */
			if(Trigger.isInsert){
                SBQQQuoteTriggerHandler.afterInsert(trigger.new);
			}
	
			/* UPDATE */
			if(Trigger.isUpdate){
                SBQQQuoteTriggerHandler.afterUpdate(trigger.new, Trigger.OldMap);
			}
	
			/* DELETE */
			if(Trigger.isDelete){
			}
	
			/* UNDELETE */
			if(Trigger.isUndelete){
			}
		}		
	}
}
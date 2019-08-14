trigger LeadTrigger on Lead (after delete, after insert, after update, before delete, before insert, before update) {
    
	 if(LeadTriggerHandler.shouldRunTrigger()) {
    
	    /***************************************************
							* BEFORE *
		****************************************************/
	
		if (Trigger.isBefore){
			
			/* INSERT */
			if (Trigger.isInsert) {
                LeadTriggerHandler.beforeInsert(trigger.new);
                                				
			}
	
			/* UPDATE */
			if(Trigger.isUpdate){
                LeadTriggerHandler.beforeUpdate(trigger.new, Trigger.OldMap);
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
                LeadTriggerHandler.afterInsert(trigger.new);
			}
	
			/* UPDATE */
			if(Trigger.isUpdate){
                LeadTriggerHandler.afterUpdate(trigger.new, Trigger.OldMap);
			}
			
			/* Marketing Cloud Connector */
			if (Trigger.isInsert || Trigger.isUpdate){
				if (PAD.canTrigger('Lead_MCTriggeredSends')) {
            		et4ae5.triggerUtility.automate('Lead');
        		}
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
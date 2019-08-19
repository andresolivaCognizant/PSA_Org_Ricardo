trigger ConsentTrigger on Consent__c (after delete, after insert, after update, before delete, before insert, before update) {

    if(ConsentTriggerHandler.shouldRunTrigger()) {
    
	    /***************************************************
							* BEFORE *
		****************************************************/
	
		if (Trigger.isBefore){
			
			/* INSERT */
			if (Trigger.isInsert) {
				/* Execute the process only if user is allowed to do it */
        		if(PAD.canTrigger('Consent_BeforeInsert')){
                	ConsentTriggerHandler.beforeInsert(Trigger.new);
				}
			}
	
			/* UPDATE */
			if(Trigger.isUpdate){				
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
				/* Execute the process only if user is allowed to do it */
        		if(PAD.canTrigger('Consent_AfterInsert')){
                	ConsentTriggerHandler.afterInsert(Trigger.new);
				}
			}
	
			/* UPDATE */
			if(Trigger.isUpdate){
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
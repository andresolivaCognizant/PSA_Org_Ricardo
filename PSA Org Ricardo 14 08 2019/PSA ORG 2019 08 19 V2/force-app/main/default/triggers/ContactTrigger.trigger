trigger ContactTrigger on Contact (after delete, after insert, after update, before delete, before insert, before update) {

    if(ContactTriggerHandler.shouldRunTrigger()) {
    
	    /***************************************************
							* BEFORE *
		****************************************************/
		System.debug('*** START EXECUTION CONTACT TRIGGER ***');
        
		if (Trigger.isBefore){
			
			/* INSERT */
			if (Trigger.isInsert) {
                ContactTriggerHandler.beforeInsert(Trigger.new);             
			}
	
			/* UPDATE */
			if(Trigger.isUpdate){	
                ContactTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldmap);
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
                ContactTriggerHandler.afterInsert(Trigger.new);
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
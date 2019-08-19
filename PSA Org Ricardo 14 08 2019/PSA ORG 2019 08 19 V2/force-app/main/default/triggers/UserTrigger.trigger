trigger UserTrigger on User (after delete, after insert, after update, before delete, before insert, before update) {

    if(UserTriggerHandler.shouldRunTrigger()) {
    
	    /***************************************************
							* BEFORE *
		****************************************************/
	
		if (Trigger.isBefore){
			
			/* INSERT */
			if (Trigger.isInsert) { 
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
          		if(PAD.canTrigger('User_AfterInsert')){
                	UserTriggerHandler.afterInsert(Trigger.newMap); 
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
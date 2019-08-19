trigger OpportunityTrigger on Opportunity (after delete, after insert, after update, before delete, before insert, before update) {

	if(OpportunityTriggerHandler.shouldRunTrigger()) {
	
		/***************************************************
							* BEFORE *
		****************************************************/
		
		if (Trigger.isBefore){
			
			/* INSERT */
			if (Trigger.isInsert) {
				/* Execute the process only if user is allowed to do it*/
				if(PAD.canTrigger('Opportunity_BeforeInsert')){
					OpportunityTriggerHandler.populateFleetDate(Trigger.new);
					OpportunityTriggerHandler.beforeInsert(Trigger.new);
				}
			}
	
			/* UPDATE */
			if(Trigger.isUpdate){
				/* Execute the process only if user is allowed to do it */
				if(PAD.canTrigger('Opportunity_BeforeUpdate')){
					OpportunityTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldmap);
				}
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
				/* Execute the process only if user is allowed to do it*/
				if(PAD.canTrigger('Opportunity_AfterInsert')){
					OpportunityTriggerHandler.afterInsert(Trigger.new);
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
trigger SBQQQuoteLineTrigger on SBQQ__QuoteLine__c (after delete, after insert, after update, before delete, before insert, before update) {
    
    if(SBQQQuoteLineTriggerHandler.shouldRunTrigger()) {
    
	    /***************************************************
							* BEFORE *
		****************************************************/
	
		if (Trigger.isBefore){
			
			/* INSERT */
			if (Trigger.isInsert) {
				if( PAD.canTrigger( 'SBQQQuoteLine_BeforeInsert' ) ){
                	SBQQQuoteLineTriggerHandler.beforeInsert(trigger.new);
				}
			}
	
			/* UPDATE */
			if(Trigger.isUpdate){
				if( PAD.canTrigger( 'SBQQQuoteLine_BeforeUpdate' ) ){
					SBQQQuoteLineTriggerHandler.beforeUpdate( trigger.new, trigger.oldMap );
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
				if( PAD.canTrigger( 'SBQQQuoteLine_AfterInsert' ) ){
                	SBQQQuoteLineTriggerHandler.afterInsert(trigger.new);
            	}
			}
	
			/* UPDATE */
			if(Trigger.isUpdate){
			}
	
			/* DELETE */
			if(Trigger.isDelete){
				if( PAD.canTrigger( 'SBQQQuoteLine_AfterDelete' ) ){
                	SBQQQuoteLineTriggerHandler.afterInsert(trigger.old);
            	}
			}
	
			/* UNDELETE */
			if(Trigger.isUndelete){
			}
		}		
	}
}
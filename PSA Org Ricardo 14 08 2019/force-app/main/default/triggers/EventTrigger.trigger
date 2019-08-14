trigger EventTrigger on Event (after delete, after insert, after update, before delete, before insert, before update) {
    
    if(EventTriggerHandler.shouldRunTrigger()) {
    
        /***************************************************
                            * BEFORE *
        ****************************************************/
    
        if (Trigger.isBefore){
            
            /* INSERT */
            if (Trigger.isInsert) {
                if (!PAD.canTrigger('Event_BeforeInsert')) {
                    return;
                }
                EventTriggerHandler.beforeInsert(Trigger.new);
            }
            
            /* UPDATE */
            if(Trigger.isUpdate){
                if (!PAD.canTrigger('Event_BeforeUpdate')) {
                    return;
                }
                EventTriggerHandler.beforeUpdate(
                    Trigger.old, Trigger.oldMap,
                    Trigger.new, Trigger.newMap
                );
            }
    
            /* DELETE */
            if(Trigger.isDelete){
                /* Execute the process only if user is allowed to do it */
                if(PAD.canTrigger('Event_BeforeDelete')){
                    EventTriggerHandler.beforeDelete(Trigger.old);
                }
            }
            /***************************************************
                                * AFTER *
            ****************************************************/
        }else{
        
            /* INSERT */
            if(Trigger.isInsert){
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
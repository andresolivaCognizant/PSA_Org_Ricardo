trigger TaskTrigger on Task (after delete, after insert, after update, before delete, before insert, before update) {

    if(TaskTriggerHandler.shouldRunTrigger()) {
    
        /***************************************************
                            * BEFORE *
        ****************************************************/
    
        if (Trigger.isBefore){
            
            /* INSERT */
            if (Trigger.isInsert) {
                /* Execute the process only if user is allowed to do it */
                if(PAD.canTrigger('Task_BeforeInsert')){
                    TaskTriggerHandler.beforeInsert(Trigger.New);
                }
            }

            /* UPDATE */
            if(Trigger.isUpdate){
                if(PAD.canTrigger('Task_BeforeUpdate')){
                    TaskTriggerHandler.beforeUpdate(trigger.new, Trigger.OldMap);
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
                if(PAD.canTrigger('Task_AfterInsert')){
                    TaskTriggerHandler.afterInsert(Trigger.new);
                    TaskTriggerHandler.dontRunTrigger();
                }
            }

            /* UPDATE */
            if(Trigger.isUpdate){
            }

            /* DELETE */
            if(Trigger.isDelete){
                if(PAD.canTrigger('Task_AfterDelete')){
                    TaskTriggerHandler.afterDelete(Trigger.old);
                }
            }

            /* UNDELETE */
            if(Trigger.isUndelete){
            }
        }
    }

}
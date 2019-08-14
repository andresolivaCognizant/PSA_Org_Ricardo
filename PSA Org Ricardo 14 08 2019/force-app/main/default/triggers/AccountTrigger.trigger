trigger AccountTrigger on Account (after delete, after insert, after update, before delete, before insert, before update) {

    if(AccountTriggerHandler.shouldRunTrigger()) {

        /***************************************************
                            * BEFORE *
        ****************************************************/

        if (Trigger.isBefore){

            /* INSERT */
            if (Trigger.isInsert) {
                AccountTriggerHandler.beforeInsert(Trigger.new);             
            }

            /* UPDATE */
            if(Trigger.isUpdate) {
                AccountTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldmap);
            }

            /* DELETE */
            if(Trigger.isDelete) {
                AccountTriggerHandler.beforeDelete(Trigger.old);
            }

        /***************************************************
                            * AFTER *
        ****************************************************/

        } else {
            /* INSERT */
            if(Trigger.isInsert){
                AccountTriggerHandler.afterInsert(Trigger.new);
            }

            /* UPDATE */
            if(Trigger.isUpdate){
                AccountTriggerHandler.afterUpdate(Trigger.new, Trigger.oldmap);
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
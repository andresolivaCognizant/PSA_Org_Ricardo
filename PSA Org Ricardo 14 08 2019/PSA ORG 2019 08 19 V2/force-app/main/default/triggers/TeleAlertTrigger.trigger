trigger TeleAlertTrigger on TeleAlert__c (
    after insert, before insert,
    after update, before update,
    after delete, before delete,
    after undelete
) {
    switch on Trigger.operationType {

        when BEFORE_UPDATE {
            TeleAlertTriggerHandler.beforeUpdate(
                Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap
            );
        }
        
        when AFTER_UPDATE {
            TeleAlertTriggerHandler.afterUpdate(
                Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap
            );
        }
        

        /*
        uncomment operation types as needed

        when AFTER_INSERT {}
        when AFTER_DELETE {}
        when AFTER_UNDELETE {}
        when BEFORE_INSERT {}
        when BEFORE_UPDATE {}
        when BEFORE_DELETE {}
        */
    }
}
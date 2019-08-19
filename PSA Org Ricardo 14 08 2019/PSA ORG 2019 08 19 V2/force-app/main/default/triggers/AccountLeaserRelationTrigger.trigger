trigger AccountLeaserRelationTrigger on AccountLeaserRelation__c (
    after insert, before insert,
    after update, before update,
    after delete, before delete,
    after undelete
) {
    switch on Trigger.operationType {

        when BEFORE_INSERT {
            AccountLeaserRelationTriggerHandler.beforeInsert(Trigger.new);
        }
        
        when BEFORE_UPDATE {
            AccountLeaserRelationTriggerHandler.beforeUpdate(
                Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap
            );
        }
    }
}
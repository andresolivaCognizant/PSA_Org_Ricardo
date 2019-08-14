/**
 * Name:            ServiceResourceTrigger
 * @author:         Diego Rincón (DR) href=<diego.rincon@ext.mpsa.com>
 * Project:         PSA
 * Description:     ServiceResource sObject main trigger.
 *
 * Changes (version)
 * -------------------------------------------------------------------------------------------------
 *              No.     Date            Author                  Description
 *              ----    ------------    --------------------    ------------------------------------
 * @version     1.0     2018-09-20      Diego Rincón (DR)       Class creation.
 *
 */

trigger ServiceResourceTrigger on ServiceResource (
    after insert, before insert,
    after update, before update,
    after delete, before delete,
    after undelete
) {

    ServiceResourceTriggerHandler h = new ServiceResourceTriggerHandler();

    switch on Trigger.operationType {
        when AFTER_UPDATE {
            if (!PAD.canTrigger('ServiceResource_AfterUpdate')) {
                return;
            }
            h.afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
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
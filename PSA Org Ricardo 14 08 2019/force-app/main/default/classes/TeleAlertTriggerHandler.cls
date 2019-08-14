/**
 * Name:            TeleAlertTriggerHandler
 * @author:         Diego Rincón (DR) href=<diego.rincon@ext.mpsa.com>
 * Project:         PSA
 * Description:     Helper class to dispatch actions for every operation type in
 *                  TeleAlert sObject main trigger.
 *
 * Changes (version)
 * -------------------------------------------------------------------------------------------------
 *              No.     Date            Author                  Description
 *              ----    ------------    --------------------    ------------------------------------
 * @version     1.0     2018-09-21      Diego Rincón (DR)       Class creation.
 *
 */

public class TeleAlertTriggerHandler {

    public static Boolean isAfterUndeleteFirstRun   = true;
    public static Boolean isBeforeInsertFirstRun    = true;
    public static Boolean isBeforeUpdateFirstRun    = true;
    public static Boolean isBeforeDeleteFirstRun    = true;
    public static Boolean isAfterInsertFirstRun     = true;
    public static Boolean isAfterUpdateFirstRun     = true;
    public static Boolean isAfterDeleteFirstRun     = true;

    private static Boolean beforeInsertHasRun() {
        if (isBeforeInsertFirstRun) {
            return isBeforeInsertFirstRun = false;
        }
        return true;
    }

    private static Boolean beforeUpdateHasRun() {
        if (isBeforeUpdateFirstRun) {
            return isBeforeUpdateFirstRun = false;
        }
        return true;
    }
    
    /*

    private Boolean beforeDeleteHasRun() {
        if (isBeforeDeleteFirstRun) {
            return isBeforeDeleteFirstRun = false;
        }
        return true;
    }

    private Boolean afterInsertHasRun() {
        if (isAfterInsertFirstRun) {
            return isAfterInsertFirstRun = false;
        }
        return true;
    }

    */

    private static Boolean afterUpdateHasRun() {
        if (isAfterUpdateFirstRun) {
            return isAfterUpdateFirstRun = false;
        }
        return true;
    }

    /*
    private Boolean afterDeleteHasRun() {
        if (isAfterDeleteFirstRun) {
            return isAfterDeleteFirstRun = false;
        }
        return true;
    }

    private Boolean afterUndeleteHasRun() {
        if (isAfterUndeleteFirstRun) {
            return isAfterUndeleteFirstRun = false;
        }
        return true;
    }
    */


    public static void beforeInsert(List<TeleAlert__c> lst_new) {
        if (beforeInsertHasRun() || !PAD.canTrigger('TeleAlert_BeforeInsert')) {
            return;
        }
        TeleAlertUtils.assignRecord(lst_new);
    }


    public static void beforeUpdate(
        List<TeleAlert__c> lstOldRows,
        List<TeleAlert__c> lstNewRows,
        Map<Id, TeleAlert__c> mapOldRows,
        Map<Id, TeleAlert__c> mapNewRows
    ) {
        if (beforeUpdateHasRun() || !PAD.canTrigger('TeleAlert_BeforeUpdate')) {
            return;
        }

        TeleAlertUtils.assignRecord(lstNewRows);
        TeleAlertUtils.setCallCount(mapNewRows);
        TeleAlertUtils.hasUserTakenOwnership(mapOldRows, mapNewRows);
    }


   public static void afterUpdate(
        List<TeleAlert__c> lstOldRows,
        List<TeleAlert__c> lstNewRows,
        Map<Id, TeleAlert__c> mapOldRows,
        Map<Id, TeleAlert__c> mapNewRows
    ) {
        if(afterUpdateHasRun() || !PAD.canTrigger('TeleAlert_AfterUpdate')) {
            return;
        }

        TeleAlertUtils.isStatusChanged(mapOldRows, mapNewRows);
        TeleAlertUtils.updateEvents(mapNewRows);
    }

}
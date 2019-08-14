/**
 * Salesforce
 * @author              Diego Rincón (DR) href=<diego.rincon@ext.mpsa.com>
 * Project:             PSA - Customer First
 * Description:         Helper class to dispatch actions for every operation
 *                      type in AccountLeaserRelation sObject main trigger.
 *
 * Changes (version)
 * -------------------------------------------------------------------------------------------------
 *              No.     Date            Author                  Description
 *              ----    ------------    --------------------    ------------------------------------
 * @version     1.0     2019-07-08      Diego Rincón (DR)       Class creation.
 *
 */
 public without sharing class AccountLeaserRelationTriggerHandler {

    public static Boolean is_before_insert_first_run    = true;
    public static Boolean is_before_update_first_run    = true;

    private static Boolean beforeInsertHasRun() {
        if (is_before_insert_first_run) {
            return is_before_insert_first_run = false;
        }
        return true;
    }

    private static Boolean beforeUpdateHasRun() {
        if (is_before_update_first_run) {
            return is_before_update_first_run = false;
        }
        return true;
    }

    public static void beforeInsert(List<AccountLeaserRelation__c> lst_new) {
        if (beforeInsertHasRun() || !PAD.canTrigger('AccountLeaserRelation_BeforeInsert')) {
            return;
        }

        AccountLeaserRelationUtils.markDuplicates(lst_new, new Map<Id, AccountLeaserRelation__c>());
        AccountLeaserRelationUtils.setUniqueId(lst_new);

    }


    public static void beforeUpdate(
        List<AccountLeaserRelation__c> lst_old,
        List<AccountLeaserRelation__c> lst_new,
        Map<Id, AccountLeaserRelation__c> map_old,
        Map<Id, AccountLeaserRelation__c> map_new
    ) {
        if (beforeUpdateHasRun() || !PAD.canTrigger('AccountLeaserRelation_BeforeUpdate')) {
            return;
        }

        AccountLeaserRelationUtils.markDuplicates(lst_new, map_old);
        AccountLeaserRelationUtils.setUniqueId(lst_new);
    }


}
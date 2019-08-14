/**
 * Salesforce
 * @author              Diego Rincón (DR) href=<diego.rincon@ext.mpsa.com>
 * Project:             PSA - Customer First
 * Description:         Helper class to handle bussiness logic related to the 
 *                      AccountLeaserRelation__c sObject.
 *
 * Changes (version)
 * -------------------------------------------------------------------------------------------------
 *              No.     Date            Author                  Description
 *              ----    ------------    --------------------    ------------------------------------
 * @version     1.0     2019-07-08      Diego Rincón (DR)       Class creation. Code coverage: 90%
 *
 */
public without sharing class AccountLeaserRelationUtils {

    public static void createAccounLeaserRelation(List<sObject> lst) {
        Map<Id, Set<Id>> map_leasers_by_account = new Map<Id, Set<Id>>();
        List<AccountLeaserRelation__c> lst_r = new List<AccountLeaserRelation__c>();

        for (SObject s : lst) {
            switch on String.valueof(s.getSObjectType()) {
                when 'Order' {
                    Order o = (Order) s;
                    if (String.isNotBlank(o.AccountId) && String.isNotBlank(o.Leaser__c)) {
                        if (map_leasers_by_account.containsKey(o.AccountId)) {
                            map_leasers_by_account.get(o.AccountId).add(o.Leaser__c);
                            continue;
                        }
                        map_leasers_by_account.put(
                            o.AccountId,
                            new Set<Id>{o.Leaser__c}
                        );
                    }
                }
                when 'SBQQ__Quote__c' {
                    SBQQ__Quote__c q = (SBQQ__Quote__c) s;
                    if (String.isNotBlank(q.SBQQ__Account__c) && String.isNotBlank(q.Leaser__c)) {
                        if (map_leasers_by_account.containsKey(q.SBQQ__Account__c)) {
                            map_leasers_by_account.get(q.SBQQ__Account__c).add(q.Leaser__c);
                            continue;
                        }
                        map_leasers_by_account.put(
                            q.SBQQ__Account__c,
                            new Set<Id>{q.Leaser__c}
                        );
                    }
                }
            }
        }

        for (Account a : [
            SELECT 
                Id,
                (
                    SELECT Id, LeaserAccount__c
                    FROM Account_Account_Relations2__r
                    WHERE
                        RelationEndDate__c = NULL OR
                        RelationEndDate__c > TODAY
                )
            FROM Account
            WHERE Id IN :map_leasers_by_account.keySet()
        ]) {
            for (AccountLeaserRelation__c r : a.Account_Account_Relations2__r) {
                if (map_leasers_by_account.get(a.Id).contains(r.LeaserAccount__c)) {
                    map_leasers_by_account.get(a.Id).remove(r.LeaserAccount__c);
                }
            }
        }

        Date RelationBeginDate = Date.today();
        for (Id key : map_leasers_by_account.keySet()) {
            if (!map_leasers_by_account.get(key).isEmpty()) {
                for(Id l : map_leasers_by_account.get(key)) {
                    lst_r.add(new AccountLeaserRelation__c(
                        KeyAccount__c       = key,
                        LeaserAccount__c    = l,
                        RelationBeginDate__c = RelationBeginDate
                    ));
                }
            }
        }

        insert lst_r;
    }

    public static void markDuplicates(
        List<AccountLeaserRelation__c> lst_new,
        Map<Id,AccountLeaserRelation__c> map_old
    ) {
        Map<Id, Set<Id>> map_leasers_by_account = new Map<Id, Set<Id>>();

        for (AccountLeaserRelation__c r : lst_new) {
            if (
                String.isNotBlank(r.KeyAccount__c) &&
                String.isNotBlank(r.LeaserAccount__c) &&
                (
                    null == r.Id ||
                    (
                        map_old.containsKey(r.Id) &&
                        (
                            map_old.get(r.Id).KeyAccount__c != r.KeyAccount__c ||
                            map_old.get(r.Id).LeaserAccount__c != r.LeaserAccount__c
                        )
                    )
                )
            ) {
                if (map_leasers_by_account.containsKey(r.KeyAccount__c)) {
                    map_leasers_by_account.get(r.KeyAccount__c).add(r.LeaserAccount__c);
                    continue;
                }
                map_leasers_by_account.put(
                    r.KeyAccount__c,
                    new Set<Id>{r.LeaserAccount__c}
                );
            }
        }

       Map<Id, Account> map_a = new Map<Id, Account>([
            SELECT
                Id,
                (
                    SELECT Id, LeaserAccount__c
                    FROM Account_Account_Relations2__r
                    WHERE
                        RelationEndDate__c = NULL OR
                        RelationEndDate__c > TODAY
                )
            FROM Account
            WHERE Id IN :map_leasers_by_account.keySet()
        ]);

        for (AccountLeaserRelation__c r : lst_new) {
            if (map_a.containsKey(r.KeyAccount__c)) {
                for (AccountLeaserRelation__c e : map_a.get(r.KeyAccount__c).Account_Account_Relations2__r) {
                    if (map_leasers_by_account.get(r.KeyAccount__c).contains(e.LeaserAccount__c)) {
                        r.addError(Label.DuplicateAccountLeaserRelationError);
                        break;
                    }
                }
            }
        }

    }

    public static void setUniqueId(List<AccountLeaserRelation__c> lst) {
        for (AccountLeaserRelation__c r : lst) {
            if (
                String.isNotBlank(r.KeyAccount__c) &&
                String.isNotBlank(r.LeaserAccount__c)
            ) {
                r.TechC1stKey__c = r.LeaserAccount__c + '-' + r.KeyAccount__c +
                    (null == r.RelationEndDate__c ? '' : '-' + ((Datetime) r.RelationEndDate__c).format('YYMMdd'));
            }
        }
    }
}
/**
 * Salesforce
 * @author              Diego Rincón (DR) href=<diego.rincon@ext.mpsa.com>
 * Project:             PSA - Customer First
 * Description:         Unit tests to validate the behavior of AccountLeaserRelation class.
 *
 * Changes (version)
 * -------------------------------------------------------------------------------------------------
 *              No.     Date            Author                  Description
 *              ----    ------------    --------------------    ------------------------------------
 * @version     1.0     2019-07-08      Diego Rincón (DR)       Class creation. Code coverage: 94%
 *
 */
 @isTest
private without sharing class AccountLeaserRelationUtilsTest {

    @testSetup
    static void setup() {

        List<Account> lst_a = Test.loadData(Account.sObjectType, 'CpqTestData_PersonAccount');
        Test.loadData(Contact.sObjectType, 'CpqTestData_PersonAccountContact');

        // merge to person account - begin
        List<Account> lst_b2c = new List<Account>();

        for(Account a : lst_a) {
            Account p = new Account(
                Id              = a.Id,
                RecordTypeId    = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId()
            );
            lst_b2c.add(p);
        }

        update lst_b2c;
        // merge to person account - end

        Test.loadData(Account.sObjectType, 'CpqTestData_DealerAccount');
        Test.loadData(Opportunity.sObjectType, 'CpqTestData_Opportunity');
        Test.loadData(SBQQ__Quote__c.sObjectType, 'CpqTestData_Quote');
        Test.loadData(Order.sObjectType, 'CpqTestData_Order');
    }

    @isTest
    static void createAccounLeaserRelationTest(){
        List<SBQQ__Quote__c> lst_q = new List<SBQQ__Quote__c>([
            SELECT Id, SBQQ__Account__c, Leaser__c FROM SBQQ__Quote__c
        ]);

        List<Order> lst_o = new List<Order>([
            SELECT Id, AccountId, Leaser__c FROM Order
        ]);

        List<Account> lst_l = Test.loadData(
            Account.sObjectType,
            'CpqTestData_LeaserAccount'
        );

        for (SBQQ__Quote__c q: lst_q) {
            q.Leaser__c = lst_l.get(0).Id;
        }

        for (Order o: lst_o) {
            o.Leaser__c = lst_l.get(0).Id;
        }

        System.assertEquals(0, [SELECT COUNT() FROM AccountLeaserRelation__c]);
        AccountLeaserRelationUtils.createAccounLeaserRelation(lst_q);
        System.assertEquals(1, [SELECT COUNT() FROM AccountLeaserRelation__c]);
        AccountLeaserRelationUtils.createAccounLeaserRelation(lst_q);
        System.assertEquals(1, [SELECT COUNT() FROM AccountLeaserRelation__c]);
        AccountLeaserRelationUtils.createAccounLeaserRelation(lst_o);
        System.assertEquals(1, [SELECT COUNT() FROM AccountLeaserRelation__c]);
    }

    @isTest
    static void markDuplicatesTest(){
        List<Account> lst_l = Test.loadData(
            Account.sObjectType,
            'CpqTestData_LeaserAccount'
        );

        List<Account> lst_a = [
            SELECT Id
            FROM Account
            WHERE IsPersonAccount = false
        ];

        AccountLeaserRelation__c r = new AccountLeaserRelation__c(
            KeyAccount__c       = lst_a.get(0).Id,
            LeaserAccount__c    = lst_l.get(0).Id
        );

        insert r;

        AccountLeaserRelation__c d = new AccountLeaserRelation__c(
            KeyAccount__c       = lst_a.get(0).Id,
            LeaserAccount__c    = lst_l.get(0).Id
        );

        AccountLeaserRelationUtils.markDuplicates(
            new List<AccountLeaserRelation__c>{d},
            new Map<Id,AccountLeaserRelation__c>()
        );

        d.Id                    = r.Id;
        d.LeaserAccount__c      = lst_l.get(1).Id;

        AccountLeaserRelationUtils.markDuplicates(
            new List<AccountLeaserRelation__c>{r,r},
            new Map<Id,AccountLeaserRelation__c>(new List<AccountLeaserRelation__c>{d})
        );
    }

    @isTest
    private static void markDuplicatesBulkTest() {
        List<Account> lst_l = Test.loadData(
            Account.sObjectType,
            'CpqTestData_LeaserAccount'
        );

        List<Account> lst_a = [
            SELECT Id
            FROM Account
            WHERE IsPersonAccount = false
        ];

        List<AccountLeaserRelation__c> lst_r = new List<AccountLeaserRelation__c>();

        for (Integer i = 0; i < 200; i++) {
            lst_r.add(new AccountLeaserRelation__c(
                KeyAccount__c           = lst_a.get(0).Id,
                RelationEndDate__c      = System.today().addDays(i),
                LeaserAccount__c        = lst_l.get(Math.mod(i,2)).Id
            ));
        }
 
        insert lst_r;

        System.assertEquals(200, [SELECT COUNT() FROM AccountLeaserRelation__c]);
    }

}
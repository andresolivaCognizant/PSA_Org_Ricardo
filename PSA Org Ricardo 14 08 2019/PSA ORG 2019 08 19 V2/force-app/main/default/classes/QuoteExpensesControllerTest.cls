/**
 * Salesforce
 * @author              Diego Rincón (DR) href=<diego.rincon@ext.mpsa.com>
 * Project:             PSA - Customer First
 * Description:         Unit tests to validate the behavior of QuoteExpensesController and
 *                      OrderFormLineWrapper classes.
 *
 * Changes (version)
 * -------------------------------------------------------------------------------------------------
 *              No.     Date            Author                  Description
 *              ----    ------------    --------------------    ------------------------------------
 * @version     1.0     2018-08-13      Diego Rincón (DR)       Class creation. Code coverage: 100%
 *
 */

@isTest
public class QuoteExpensesControllerTest {

    @testSetup static void setup() {

        List<Account> lstA = Test.loadData(Account.sObjectType, 'CpqTestData_PersonAccount');
        List<Contact> lstC = Test.loadData(Contact.sObjectType, 'CpqTestData_PersonAccountContact');

        // merge to person account - begin
        List<Account> lstB2C = new List<Account>();

        for(Account a : lstA) {
            Account p = new Account(
                Id              = a.Id,
                RecordTypeId    = Schema.SObjectType.ACCOUNT.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId()
            );
            lstB2C.add(p);
        }

        update lstB2C;
        // merge to person account - end

        Test.loadData(Account.sObjectType, 'CpqTestData_DealerAccount');
        Test.loadData(Opportunity.sObjectType, 'CpqTestData_Opportunity');
        Test.loadData(SBQQ__Quote__c.sObjectType, 'CpqTestData_Quote');
        Test.loadData(Expenses__c.sObjectType, 'CpqTestData_Expenses');
        Test.loadData(Product2.sObjectType, 'CpqTestData_Product');
        Test.loadData(OrderFormLine__c.sObjectType, 'CpqTestData_OrderFormLine');
        Test.loadData(Payment__c.sObjectType, 'CpqTestData_Payment');
    }

    @isTest static void testMethod1(){
        List<Account> lstA = [SELECT Id, RecordTypeId, RecordType.DeveloperName FROM Account];

        SBQQ__Quote__c q = [SELECT Id FROM SBQQ__Quote__c];
        PageReference p = Page.QuoteExpenses;

        Test.setCurrentPage(p);
        ApexPages.currentPage().getParameters().put('qid', q.Id);

        QuoteExpensesController c = new QuoteExpensesController();
    }
}
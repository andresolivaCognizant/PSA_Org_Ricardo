/*
-- - Name         : LookupUserControllerTest
-- - Author       : DXC. Ruben Fernandez
-- - Date         : 22/01/2018
-- - Description  : Test class for LookupAController
--                  1. lookupfechValuesTest.
--                  2. lookupDontfechValuesTest
-- - History:
-- Date         Author  Version  Comments
-- -----------  -----   -------  ---------------------------------------
-- 22/01/2018   DXC     1.0      Initial version Ruben Fernandez
*/
@isTest
public with sharing class LookupUserControllerTest {

    @isTest static void fetchLookUpValuesTest(){
        List<sObject> lst = new List<sObject>();

        lst = LookupUserController.fetchLookUpValues(
            'Test',
            'Contact',
            null
        );

        System.assertEquals(lst.size(), 0);

        lst = LookupUserController.fetchLookUpValues(
            'Test',
            'User',
            'AND IsActive = true'
        );

        System.assertEquals(lst.size(), 0);
    }

    public static testMethod void getUserLeadCountsTest() {
        // Preparing the test conditions.
        List<String> lstActivities  =   new List<String>(); 
        lstActivities.add('VN');
        List<Account> lstAccounts   =   TestDataFactoryUtil.createDealers(1, 'Dealer', '133225511','1237770', 'EXTKEY0001','AP','ES', 'J',lstActivities,true);
        List<Lead> lstLeads         =   TestDataFactoryUtil.createLead(3, 'B2B', 'EXTKEY0001',null, 'AP','ES','VN', '22334455');

        Test.startTest();
            Insert lstLeads;
            List <LookupUserController.leadCounts> aux  = LookupUserController.getUserLeadCounts(false);
        Test.stopTest();

        System.assertEquals(1, aux.size());
    }
}
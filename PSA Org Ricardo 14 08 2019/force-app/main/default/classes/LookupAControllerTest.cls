/*
-- - Name         : LookupAControllerTest
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
public class LookupAControllerTest {
	
    
    public static testMethod void lookupfechValuesTest() {

        List<Account> lstAccts = TestDataFactoryUtil.createAccount(8,'B2B');

        Test.startTest();
        	List <sObject> lstObjects =LookupAController.fetchLookUpValues('', 'Name', 'Account','Account',null);
        	System.assertEquals(5, lstObjects.size());
        Test.stopTest();
    }

    public static testMethod void lookupDontfechValuesTest() {

        List<Account> lstAccts  = TestDataFactoryUtil.createAccount(1,'B2B');
        String sPhone           = '98677892';
        Test.startTest();
        	List <sObject> lstObjects =LookupAController.fetchLookUpValues('', 'Name', 'DUMMY','Account',null);
            List <sObject> lstObjects2 =LookupAController.fetchLookUpValues('', 'Name', 'DUMMY','Account',' AND Phone=\''+sPhone+ '\'');
        	System.assertEquals(0, lstObjects.size());
        Test.stopTest();
    }

}
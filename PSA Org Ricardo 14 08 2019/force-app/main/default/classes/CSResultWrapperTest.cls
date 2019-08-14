/*
-- - Name         : CSResultWrapperTest
-- - Author       : DXC. Ruben Fernandez
-- - Date         : 22/01/2018
-- - Description  : Test class for CSResultWrapper
--                  1. NewResultWrapperTest.
-- - History:
-- Date         Author  Version  Comments
-- -----------  -----   -------  ---------------------------------------
-- 22/01/2018   DXC     1.0      Initial version Ruben Fernandez
*/
@isTest
private class CSResultWrapperTest {
	

	static testMethod void NewResultWrapperTest() {

  		List<Account> lstAccts = TestDataFactoryUtil.createAccount(1,'B2B');
		Map<Id,Boolean> mapAux = new Map<Id,Boolean>();
		
		Test.startTest();
        	CSResultWrapper ltw = new CSResultWrapper();
        	String queryString 	= 'SELECT Id, Name FROM Account';
        	ltw.sObjectrecords 	= database.query(queryString);
	        ltw.page			= 1;
	        ltw.total			= 1;

	        for(sObject o : ltw.sObjectrecords){
	        	mapAux.put(o.Id,true);
	        }
	        ltw.sObjectrecordAccess = mapAux;
        	System.assertEquals(lstAccts.size(), ltw.sObjectrecords.size());
        Test.stopTest();
	
	}
	
}
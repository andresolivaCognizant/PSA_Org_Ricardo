/******************************************************************************************
* Name: 			  RestInt91Test
* Author: 			  Borja Gay
* Description:		  Test class for RestInt91 class
* 
* Changes (Version)
* -----------------------------------------------------------------------------------------
*			No.		Date			          Author		       Description
*			-----	----------		      ----------------	     ---------------
* @version	1.0		2019-05-14		        Borja Gay 	         Initial definition.
*******************************************************************************************/
@isTest
public with sharing class RestInt91Test {
    @isTest
    private static void sendRequestTest() {
        Test.setMock( HttpCalloutMock.class, new RestInt91Mock( 200 ) );
        RestInt91.Int91Response res;
        Test.startTest();
        res = RestInt91.sendRequest('AAAAAAAAAAAAAAAAA', 'ES', 'ES', 'AP', 1500);
        System.assertEquals(res.result,200,'RestInt91Test - sendRequestTest');
        Test.stopTest();
    }
}
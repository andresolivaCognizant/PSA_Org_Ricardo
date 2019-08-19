/*
-- - Name         : AutocompleteAddressesControllerTest
-- - Author       : DXC. Ruben Fernandez
-- - Date         : 27/03/2018
-- - Description  : Test class for CSResultAController
--                  1. getAddressAutoComplete
--                  2. getAddressDetails
--                  3. setAddressDetails
--                  4. loadDefaultValues
-- - History:
-- Date         Author  Version  Comments
-- -----------  -----   -------  ---------------------------------------
-- 22/01/2018   DXC     1.0      Initial version Ruben Fernandez
*/
@isTest
public with sharing class AutocompleteAddressesControllerTest {
	
	//@isTest 
 //   static void AccountSearchTest() {
 //       // Test data setup
 //       // Create one account by calling a utility method
 //       List<Account> lstAccts = TestDataFactoryUtil.createAccount(1,'B2B');
        
 //       // Perform test
 //       Test.startTest();
  

 //           rwRecords                   =   CSResultAController.getRecords(sObj,'Name',5,'10','LastViewedDate','isPersonAccount=False',aux);
 //           List<String> lstLabels      =   CSResultAController.getLabels(sObj,null,new String[]{'id','name','Owner.Name','UserRecordAccess.HasReadAccess'});
 //       Test.stopTest();

 //   } 

    @isTest 
    static void testGooglePlaceCallout() {
        // Set mock callout class 

        AutocompleteAddressesController.loadDefaultValues();

        Test.setMock(HttpCalloutMock.class, new GooglePlaceMockHttpResponseGenerator());
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        String url 				= 'https://maps.googleapis.com/maps/api/place/';
        String actualValue 		= AutocompleteAddressesController.getHttp('');
        String expectedValue 	='{"predictions":[{'+
         '"description" : "France","id" : "a977cb95bbbf6d267fdbe3cc2f2c1abd582f5d8a",'+
         '"matched_substrings":[{"length" : 1,"offset" : 0}],'+
         '"place_id" : "ChIJMVd4MymgVA0R99lHx5Y__Ws",'+
         '"reference" : "CiQeAAAAtUNuFO2mEvSEC-wARAQ008AjzZnROKZ9I4xJE1q7Ak8SENWpwKCJZpoH5NdLDS8dc-saFEBHlM2x7hoyTadRjw86kYj0dp_k",'+
         '"structured_formatting":{"main_text" : "France","main_text_matched_substrings":[{"length" : 1,"offset" : 0}]},"terms":['+
         '{"offset" : 0,"value" : "France"}],"types" : [ "country", "political", "geocode"]}],"status" : "OK"}';
         
        System.assertEquals(actualValue, expectedValue);
    }
    @isTest 
    static void testGooglePlacePredict() {
        // Set mock callout class 
		// Test data setup
        // Create one account by calling a utility method
        AutocompleteAddressesController.loadDefaultValues();

        List<Account> lstAccts 	= TestDataFactoryUtil.createAccount(1,'B2B');
        Test.setMock(HttpCalloutMock.class, new GooglePlaceMockHttpResponseGenerator());
        String sResponse 		= AutocompleteAddressesController.getAddressAutoComplete('France','','EN');
        String sResponseB		= AutocompleteAddressesController.getAddressDetails('ChIJMVd4MymgVA0R99lHx5Y__Ws','EN');

        List<String> lstAddr	= new List<String>();
        lstAddr.add('s=Eduardo Barreiros 100');
        lstAddr.add('s=Madrid');
        lstAddr.add('s=Madrid');
        lstAddr.add('s=ES');
        lstAddr.add('s=28080');

        Boolean bStatus			= AutocompleteAddressesController.setAddressDetails(lstAccts.get(0).Id,lstAddr);
       
        System.assertEquals(true, bStatus);
    }
}
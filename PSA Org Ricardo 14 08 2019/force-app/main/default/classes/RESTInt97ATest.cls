/*
*   @Class : PopulateQuoteInformationTest.cls
*
*   @Author         :   ----
*   @Created        :   ----
*   @Description    :   ----

*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*       Developer               Date                    Description
*	    -------					---------			    Creation.
*       Nerea Leguinazabal		11 07 2019              #C1STAGILE-16994: Use TestDataFactoryUtil for Data creation  
*   ----------------------------------------------------------------------------------------------------------------------------
*/
@isTest
private class RESTInt97ATest {
	

	@isTest static void SendRequestNoMockTest() {

		List<Account> lstB2BAcc     =   TestDataFactoryUtil.createAccount(1,'B2B');
		List<Opportunity> lstOpps   =   TestDataFactoryUtil.createOpportunities(1, null ,lstB2BAcc.get(0), 1000.0 ,'FR1', 75);
		Test.startTest();
		Test.setMock( HttpCalloutMock.class, new RestInt97AMock( 200 ) ); 
		RestInt97A.SendRequest(lstOpps[0].id);
		Test.stopTest();
	}

	@isTest static void SendRequestOfferNoMockTest() {
		List<Account> lstB2BAcc     =   TestDataFactoryUtil.createAccount(1,'B2B');
		List<Opportunity> lstOpps   =   TestDataFactoryUtil.createOpportunities(1, null ,lstB2BAcc.get(0), 1000.0 ,'FR2', 75);
		Test.startTest();
		Test.setMock( HttpCalloutMock.class, new RestInt97AMock( 200 ) ); 
		RestInt97A.SendRequestOffer(lstOpps[0].id);
		Test.stopTest();
	}

	
	@isTest static void SendRequestTest() {

		List<Account> lstB2BAcc     =   TestDataFactoryUtil.createAccount(1,'B2B');
		List<Opportunity> lstOpps   =   TestDataFactoryUtil.createOpportunities(1, null ,lstB2BAcc.get(0), 1000.0 ,'FR1', 75);
		
		SBQQ__Quote__C quote = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
			'SBQQ__Account__c'			=> lstB2BAcc[0].id,
			'SBQQ__ExpirationDate__c'	=> system.today(),
			'SBQQ__Status__c'			=> '1',
			'SBQQ__Opportunity2__c'		=> lstOpps[0].id
		} ,true); 
		
		Test.startTest();
		Test.setMock( HttpCalloutMock.class, new RestInt97AMock( 200 ) ); 
		RestInt97A.SendRequest(lstOpps[0].id);
		Test.stopTest();
	}

	@isTest static void SendRequestOfferTest() {
		Id rtFleetReq = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('FleetRequestQuote').getRecordTypeId();
		List<Account> lstB2BAcc     =   TestDataFactoryUtil.createAccount(1,'B2B');
		List<Opportunity> lstOpps   =   TestDataFactoryUtil.createOpportunities(1, null ,lstB2BAcc.get(0), 1000.0 ,'FR2', 75);
		
		SBQQ__Quote__C quote = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
			'SBQQ__Account__c'			=> lstB2BAcc[0].id,
			'SBQQ__ExpirationDate__c'	=> system.today(),
			'SBQQ__Status__c'			=> '1',
			'SBQQ__Opportunity2__c'		=> lstOpps[0].id,
			'RecordTypeId' 				=> rtFleetReq
		} ,true); 
		Test.startTest();
		Test.setMock( HttpCalloutMock.class, new RestInt97AMock( 200 ) ); 
		RestInt97A.SendRequestOffer(lstOpps[0].id);
		RestInt97A.checkMandatoryFields( '{ "FleetCategory__c" : null }' );
		Test.stopTest();
	}

	@isTest static void SendRequestFailTest() {

		List<Account> lstB2BAcc     =   TestDataFactoryUtil.createAccount(1,'B2B');
		List<Opportunity> lstOpps   =   TestDataFactoryUtil.createOpportunities(1, null ,lstB2BAcc.get(0), 1000.0 ,'FR1', 75);
		Test.startTest();
		Test.setMock( HttpCalloutMock.class, new RestInt97AMock( null ) ); 
		RestInt97A.SendRequest(lstOpps[0].id);
		Test.stopTest();
	}

	@isTest static void SendRequestOfferFailTest() {
		List<Account> lstB2BAcc     =   TestDataFactoryUtil.createAccount(1,'B2B');
		List<Opportunity> lstOpps   =   TestDataFactoryUtil.createOpportunities(1, null ,lstB2BAcc.get(0), 1000.0 ,'FR2', 75);
		Test.startTest();
		Test.setMock( HttpCalloutMock.class, new RestInt97AMock( null ) ); 
		RestInt97A.SendRequestOffer(lstOpps[0].id);
		Test.stopTest();
	}
	
	@isTest static void getResourcesTest() {
		// Implement test code
	}
	
}
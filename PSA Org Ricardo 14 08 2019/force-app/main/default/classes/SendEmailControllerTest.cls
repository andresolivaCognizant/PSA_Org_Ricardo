/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			-
* Description:		Test class for SendEmailController class
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2019-06-05		Manuel Medina (MM)		Initial definition.
*      		1.1  	18/06/2019      Pedro Párraga . 		Edit
*********************************************************************************************************/
@isTest 
public class SendEmailControllerTest {

	/**
	* @Method: 		setup
	* @Description:	Returns useful data to component.
	* @author 		Manuel Medina - 05062019
	*/
	@testSetup 
	static void setup(){
		List<Account> lstAccounts								= TestDataFactoryUtil.createPersonAccount( 1 );

		update new Contact( Id = [SELECT Id FROM Contact LIMIT 1][0].Id, Email = 'test@test.com' );
		
		Opportunity objOpportunity								= new Opportunity();
		objOpportunity.Name										= 'Test Send Email';
		objOpportunity.CloseDate								= System.today().addDays( 30 );
		objOpportunity.StageName								= '1';
		objOpportunity.AccountId								= lstAccounts.get( 0 ).Id;
		objOpportunity.Country__c								= 'ES';
		insert objOpportunity;

		ServiceContract__c objServiceContract					= new ServiceContract__c();
		objServiceContract.Account__c							= lstAccounts.get( 0 ).Id;
		objServiceContract.ContractStatus__c					= 'A';
		objServiceContract.Brand__c								= 'AP';
		objServiceContract.ContractStartDate__c					= System.today().addDays( 1 );
		objServiceContract.ContractEndDate__c					= System.today().addDays( 30 );
		objServiceContract.Country__c							= 'ES';
		objServiceContract.ExternalId__c						= 'SCTEST1';
		objServiceContract.SubscribedDuration__c				= 10;
		objServiceContract.SubscribedMileage__c					= 10000;
		objServiceContract.ContractNumber__c					= '12345678912';
		insert objServiceContract;
	}

	/**
	* @Method: 		SendEmailController_getInitData
	* @Description:	Test for main flow executed when SendEmail component is loaded.
	* @author 		Manuel Medina - 05062019
	*/
	@isTest
	public static void SendEmailController_getInitData(){
		Test.startTest();
			String strRequest									= '{' +
																	'"strRecordId"		: "' + [SELECT Id FROM Opportunity LIMIT 1][0].Id + '"' +
																'}';

			String strRequestError								= '{' +
																	'"strRecordId"		: "InvalidId"' +
																'}';

			Map<String, Object> mapResponse						= new Map<String, Object>( SendEmailController.getInitData( strRequest ) );
			Map<String, Object> mapResponseError				= new Map<String, Object>( SendEmailController.getInitData( strRequestError ) );
			String strPDFBody									= SendEmailController.getPDF( String.valueOf( [SELECT Id FROM ServiceContract__c LIMIT 1][0].Id ) );
			
			System.assertEquals( true, mapResponse.containsKey( 'userInfo' ) );
			System.assertEquals( true, mapResponse.containsKey( 'owEmailAddress' ) );
			System.assertEquals( true, mapResponse.containsKey( 'accountField' ) );
			System.assertEquals( true, Boolean.valueOf( mapResponseError.get( 'hasError' ) ) );
			System.assertEquals( true, String.isNotBlank( strPDFBody ) );
		Test.stopTest();
	}

	/**
	* @Method: 		SendEmailController_getPDF
	* @Description:	Test to validate the merged template based on given WhatId and TemplatedId.
	* @author 		Manuel Medina - 06062019
	*/
	@isTest
	public static void SendEmailController_getMergedTemplate(){
		Test.startTest();
			String strRequest									= '{' +
																	'"strTemplateId"	: "' + [SELECT Id FROM EmailTemplate LIMIT 1][0].Id + '",' +
																	'"strWhatId"		: "' + [SELECT Id FROM ServiceContract__c LIMIT 1][0].Id + '"' +
																'}';

			String strRequestError								= '{' +
																	'"strTemplateId"	: "' + [SELECT Id FROM EmailTemplate LIMIT 1][0].Id + '",' +
																	'"strWhatId"		: "InvalidId"' +
																'}';

			Map<String, Object> mapResponse						= new Map<String, Object>( SendEmailController.getMergedTemplate( strRequest ) );
			Map<String, Object> mapResponseError				= new Map<String, Object>( SendEmailController.getMergedTemplate( strRequestError ) );
			
			System.assertEquals( true, mapResponse.containsKey( 'template' ) );
			System.assertEquals( true, Boolean.valueOf( mapResponseError.get( 'hasError' ) ) );
		Test.stopTest();
	}

	/**
	* @Method: 		SendEmailController_getPDF
	* @Description:	Test to validate the merged template based on given WhatId and TemplatedId.
	* @author 		Manuel Medina - 06062019
	*/
	@isTest
	public static void SendEmailController_sendEmail(){
		Test.startTest();
			Id idTemplate										= [SELECT Id FROM EmailTemplate LIMIT 1][0].Id;
			Id idContact										= [SELECT Id FROM Contact LIMIT 1][0].Id;
			Id idServiceContract								= [SELECT Id FROM ServiceContract__c LIMIT 1][0].Id;

			JSONGenerator reqJSONTemplate						= JSON.createGenerator( true );
			reqJSONTemplate.writeStartObject();
			reqJSONTemplate.writeStringField( 'strTemplateId', idTemplate );
			reqJSONTemplate.writeStringField( 'strFrom', UserInfo.getUserEmail() );
			reqJSONTemplate.writeStringField( 'strWhatId', idServiceContract );
			reqJSONTemplate.writeStringField( 'strWhoId', idContact );
			reqJSONTemplate.writeStringField( 'strPDFName', 'TestPDF' );
			reqJSONTemplate.writeStringField( 'strPDFData', EncodingUtil.base64Encode( Blob.toPdf( 'Test PDF Body' ) ) );
			reqJSONTemplate.writeStringField( 'strRecipients', '["' + idContact + '"]' );
			reqJSONTemplate.writeStringField( 'strSubject', 'Test Subject' );
			reqJSONTemplate.writeStringField( 'strBody', 'Test Body' );
			reqJSONTemplate.writeEndObject();

			JSONGenerator reqJSONWithoutTemplate				= JSON.createGenerator( true );
			reqJSONWithoutTemplate.writeStartObject();
			reqJSONWithoutTemplate.writeStringField( 'strTemplateId', '' );
			reqJSONWithoutTemplate.writeStringField( 'strFrom', 'usertest@test.com' );
			reqJSONWithoutTemplate.writeStringField( 'strWhatId', idServiceContract );
			reqJSONWithoutTemplate.writeStringField( 'strWhoId', idContact );
			reqJSONWithoutTemplate.writeStringField( 'strPDFName', 'TestPDF' );
			reqJSONWithoutTemplate.writeStringField( 'strPDFData', EncodingUtil.base64Encode( Blob.toPdf( 'Test PDF Body' ) ) );
			reqJSONWithoutTemplate.writeStringField( 'strRecipients', '["' + idContact + '"]' );
			reqJSONWithoutTemplate.writeStringField( 'strSubject', 'Test Subject' );
			reqJSONWithoutTemplate.writeStringField( 'strBody', 'Test Body' );
			reqJSONWithoutTemplate.writeEndObject();

			JSONGenerator reqJSONError							= JSON.createGenerator( true );
			reqJSONError.writeStartObject();
			reqJSONError.writeStringField( 'strTemplateId', '' );
			reqJSONError.writeStringField( 'strFrom', UserInfo.getUserEmail() );
			reqJSONError.writeStringField( 'strWhatId', 'InvalidId' );
			reqJSONError.writeStringField( 'strPDFName', 'TestPDF' );
			reqJSONError.writeStringField( 'strPDFData', EncodingUtil.base64Encode( Blob.toPdf( 'Test PDF Body' ) ) );
			reqJSONError.writeStringField( 'strRecipients', '["' + idContact + '"]' );
			reqJSONError.writeStringField( 'strSubject', 'Test Subject' );
			reqJSONError.writeStringField( 'strBody', 'Test Body' );
			reqJSONError.writeEndObject();

			Map<String, Object> mapResponseTemplate				= new Map<String, Object>( SendEmailController.sendEmail( reqJSONTemplate.getAsString() ) );
			Map<String, Object> mapResponseWithoutTemplate		= new Map<String, Object>( SendEmailController.sendEmail( reqJSONWithoutTemplate.getAsString() ) );
			Map<String, Object> mapResponseError				= new Map<String, Object>( SendEmailController.sendEmail( reqJSONError.getAsString() ) );

			System.assertEquals( false, Boolean.valueOf( mapResponseTemplate.get( 'hasError' ) ) );
			System.assertEquals( false, Boolean.valueOf( mapResponseWithoutTemplate.get( 'hasError' ) ) );
			System.assertEquals( true, Boolean.valueOf( mapResponseError.get( 'hasError' ) ) );
		Test.stopTest();
	}
}
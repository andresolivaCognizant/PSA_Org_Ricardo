/******************************************************************************************
* Name: 			ReportUtils
* Author: 			Diego Rincón
* Description:		Unit tests to validate the behavior of ReportUtils class.
* 
* Changes (Version)
* -----------------------------------------------------------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2018-12-17		Diego Rincon (DR)		Initial definition.
* @version	2.0		2019-07-09		Manuel Medina (MM)		Refactoring based on new scope.
*															- This version supports Visualforce.
*******************************************************************************************/
@isTest
private class ReportUtilsTest {

	/******************************************************************************************************
	* @Method			: getReportDataTest
	* @Author			: Manuel Medina
	* @Created			: 11/07/2019
	* @Description		: Test for getReportData method.
	*						NOTE: Method annotaded with @isTest(SeeAllData=true) on purpose,
	*						as reports cannot be inserted through Apex code
	******************************************************************************************************/
	@isTest	( SeeAllData='true' ) static void getReportDataTest(){
		Test.startTest();
			JSONGenerator jsRequest									= JSON.createGenerator(true);
			jsRequest.writeStartObject();
			jsRequest.writeStringField( 'strReportName', [SELECT Id, DeveloperName FROM Report LIMIT 1].DeveloperName );
			jsRequest.writeEndObject();

			JSONGenerator jsRequest_NotFound						= JSON.createGenerator(true);
			jsRequest_NotFound.writeStartObject();
			jsRequest_NotFound.writeStringField( 'strReportName', 'ReportNotFound' );
			jsRequest_NotFound.writeEndObject();

			Map<String, Object> mapResponse							= ReportUtils.getReportData( jsRequest.getAsString() );
			Map<String, Object> mapResponse_NotFound				= ReportUtils.getReportData( jsRequest_NotFound.getAsString() );

			System.assertEquals( true, Boolean.valueOf( mapResponse.get( 'hasReport' ) ) );
			System.assertEquals( false, Boolean.valueOf( mapResponse_NotFound.get( 'hasReport' ) ) );

		Test.stopTest();
	}
}
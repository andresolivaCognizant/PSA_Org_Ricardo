/******************************************************************************************
* Name: 			ReportUtils
* Author: 			Manuel Medina
* Description:		AccountFleetReport and AccountFleetReportContainer controller class.
* 
* Changes (Version)
* -----------------------------------------------------------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2018-12-17		Diego Rincon (DR)		Initial definition.
* @version	2.0		2019-07-09		Manuel Medina (MM)		Refactoring based on new scope.
*															- This version supports Visualforce.
*******************************************************************************************/
public class ReportUtils{

	/******************************************************************************************************
	* @Method			: getReportData
	* @Author			: Manuel Medina
	* @Created			: 09/07/2019
	* @Description		: Returns data based on given Report.DeveloperName.
	******************************************************************************************************/
	@AuraEnabled 
	public static Map<String, Object> getReportData( String strRequest ){
		Map<String, Object> mapRequest				= ( Map<String, Object> ) JSON.deserializeUntyped( strRequest );
		Map<String, Object> mapResponse				= new Map<String, Object>{
														'hasReport'		=> false,
														'reportId'		=> ''
													};

		List<Report> lstReports						= new List<Report>( [
														SELECT Id,
															Name,
															Owner.Name
														FROM Report
														WHERE DeveloperName =: String.valueOf( mapRequest.get( 'strReportName' ) )
													] );

		mapResponse.put( 'hasReport', !lstReports.isEmpty() );
		mapResponse.put( 'report', !lstReports.isEmpty() ?
			new Map<String, Object>{
				'id'	=> lstReports.get( 0 ).Id,
				'name'	=> lstReports.get( 0 ).Name
			} : null
		);

		return mapResponse;
	}
}
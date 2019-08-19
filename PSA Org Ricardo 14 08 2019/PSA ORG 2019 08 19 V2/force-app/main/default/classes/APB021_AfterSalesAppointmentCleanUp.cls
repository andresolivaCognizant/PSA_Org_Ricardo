/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			AfterSales
* Description:		Proccess which deletes all Workshop Appointmets records not confirmed by Service Box.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2019-07-02		Manuel Medina (MM)		Initial definition.
*********************************************************************************************************/
global class APB021_AfterSalesAppointmentCleanUp implements Database.Batchable<sobject>, Database.AllowsCallouts, Database.Stateful{

	/**
	* @Method: 		start
	* @param: 		Database.BatchableContext BC
	* @Description:	N/A
	* @author 		Manuel Medina - 02072019
	*/
	global Database.QueryLocator start( Database.BatchableContext BC ) {
		return Database.getQueryLocator(
			'SELECT Id ' +
			'FROM WorkshopAppointment__c ' +
			'WHERE TECH_SBConfirmation__c = false'
		);
	}
	
	/**
	* @Method: 		execute
	* @param: 		Database.BatchableContext BC
	* @param: 		List<SObject> scope
	* @Description:	N/A
	* @author 		Manuel Medina - 02072019
	*/
	global void execute( Database.BatchableContext BC, List<WorkshopAppointment__c> lstAppointments ){
		delete lstAppointments;
		Database.emptyRecycleBin( lstAppointments );
	}
	
	/**
	* @Method: 		finish
	* @param: 		Database.BatchableContext BC
	* @Description:	N/A
	* @author 		Manuel Medina - 02072019
	*/
	global void finish( Database.BatchableContext BC ){

	}
}
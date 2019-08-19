/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			AfterSales
* Description:		Vehicle Event batch which executes logic defined on AfterSalesVehicleEventHandler class.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------

* @version	1.0		2018-08-06		Manuel Medina (MM)		Initial definition.
*********************************************************************************************************/
global class APB012_AfterSalesVehicleEvent implements Database.Batchable<sobject>, Database.AllowsCallouts, Database.Stateful{
	
	/**
	* @Method: 		start
	* @param: 		Database.BatchableContext BC
	* @Description:	N/A
	* @author 		Manuel Medina - 06082018
	*/
	global Database.QueryLocator start( Database.BatchableContext BC ) {
		String strSOQL													= 'SELECT Id ' +
																			'FROM VehicleEvent__x ' +
																			'WHERE assetid__c != null ' +
																			'AND CreatedDate__c = TODAY';
		
		return Database.getQueryLocator( strSOQL );
	}
	
	/**
	* @Method: 		execute
	* @param: 		Database.BatchableContext BC
	* @param: 		List<SObject> scope
	* @Description:	N/A
	* @author 		Manuel Medina - 06082018
	*/
	global void execute( Database.BatchableContext BC, List<VehicleEvent__x> lstVehicleEvents ){
		AfterSalesVehicleEventHandler.validateVehicleEventRules( new Map<String, VehicleEvent__x>( lstVehicleEvents ) );
	}
	
	/**
	* @Method: 		finish
	* @param: 		Database.BatchableContext BC
	* @Description:	N/A
	* @author 		Manuel Medina - 06082018
	*/
	global void finish( Database.BatchableContext BC ){
		
	}
}
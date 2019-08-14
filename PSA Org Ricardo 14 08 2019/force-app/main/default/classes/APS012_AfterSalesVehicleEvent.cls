/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			AfterSales
* Description:		Vehicle Event scheduler which executes APB012_AfterSalesVehicleEvent batch.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------

* @version	1.0		2018-08-06		Manuel Medina (MM)		Initial definition.
*********************************************************************************************************/
global class APS012_AfterSalesVehicleEvent implements Schedulable{

	global void execute( SchedulableContext SC ) {
		Database.executeBatch( new APB012_AfterSalesVehicleEvent(), 200 );
	}
}
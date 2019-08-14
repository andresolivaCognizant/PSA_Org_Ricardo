/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			AfterSales
* Description:		Scheduler which executes APB013_PromoRefundingManagementFile batch.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2018-08-07		Manuel Medina (MM)		Initial definition.
*********************************************************************************************************/
global class APS013_PromoRefundingManagementFile implements Schedulable{
	
	global void execute( SchedulableContext SC ) {
		Database.executeBatch( new APB013_PromoRefundingManagementFile(), 200 );
	}
}
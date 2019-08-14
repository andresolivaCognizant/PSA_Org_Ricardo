/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			Distributed Marketing
* Description:		CampaignTrigger.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2019-01-28		Manuel Medina (MM)		Initial definition.
*********************************************************************************************************/
trigger CampaignTrigger on Campaign ( before insert ) {
	
	if( Trigger.isInsert ){
		CampaignTriggerHandler.beforeInsert( Trigger.new );
	}
}
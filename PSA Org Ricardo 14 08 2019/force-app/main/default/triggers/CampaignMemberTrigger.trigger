/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			Distributed Marketing
* Description:		CampaignMemberTrigger.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2019-01-29		Manuel Medina (MM)		Initial definition.
*********************************************************************************************************/
trigger CampaignMemberTrigger on CampaignMember ( before insert ) {

	if(Trigger.isBefore){
			CampaignMemberTriggerHandler.beforeInsert( Trigger.new );
	}
}
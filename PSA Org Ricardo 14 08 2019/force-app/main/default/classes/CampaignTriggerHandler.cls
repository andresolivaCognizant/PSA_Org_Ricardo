/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			Distributed Marketing
* Description:		CampaignTrigger handler.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2019-01-28		Manuel Medina (MM)		Initial definition.
*********************************************************************************************************/
public class CampaignTriggerHandler {
	
	private final static Id idRTDMCampaing				= Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get( 'DMCampaign' ).getRecordTypeId();
	private final static Id idRTDMCampaingTemplate		= Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get( 'DM_Campaign_Template' ).getRecordTypeId();
	
	/**
	* @Method: 		beforeInsert
	* @param: 		List<Campaign> lstCampaigns
	* @Description: NA
	* @author 		Manuel Medina - 28012019
	*/
	public static void beforeInsert( List<Campaign> lstCampaigns ){
		if( !PAD.canTrigger( 'Campaign_BeforeInsert' ) ){
			return;
		}
		
		changeRecordType( lstCampaigns );
	}
	
	/**
	* @Method: 		beforeUpdate
	* @param: 		List<Campaign> lstCampaigns
	* @Description: NA
	* @author 		Manuel Medina - 28012019
	*/
	public static void beforeUpdate( List<Campaign> lstCampaigns, Map<Id, Campaign> mapOldCampaignById ){
	}
	
	/**
	* @Method: 		changeRecordType
	* @param: 		List<Campaign> lstCampaigns
	* @Description: NA
	* @author 		Manuel Medina - 28012019
	*/
	public static void changeRecordType( List<Campaign> lstCampaigns ){
		Map<Id, Campaign> mapParentCampaignById			= new Map<Id, Campaign>();
		
		for( Campaign objCampaign : lstCampaigns ){
			if( String.isNotBlank( objCampaign.ParentId ) ){
				mapParentCampaignById.put( objCampaign.ParentId, new Campaign() );
			}
		}
		
		mapParentCampaignById							= new Map<Id, Campaign>( [
															SELECT Id,
																TECH_IsTemplate__c
															FROM Campaign
															WHERE Id IN: mapParentCampaignById.keySet()
															AND RecordType.DeveloperName = 'DM_Campaign_Template'
														] );
														
		for( Campaign objCampaign : lstCampaigns ){
			if( mapParentCampaignById.containsKey( objCampaign.ParentId )  ){
				objCampaign.RecordTypeId				= idRTDMCampaing;
			}
		}
	}
}
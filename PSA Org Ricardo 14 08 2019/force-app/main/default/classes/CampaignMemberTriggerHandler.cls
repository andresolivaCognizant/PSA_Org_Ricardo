/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			Distributed Marketing
* Description:		CampaignMemberTrigger handler.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2019-01-29		Manuel Medina (MM)		Initial definition.
*********************************************************************************************************/
public class CampaignMemberTriggerHandler {

	private final static Id idRTDMCampaing									= Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get( 'DMCampaign' ).getRecordTypeId();
	private final static Id idRTDMCampaingTemplate							= Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get( 'DM_Campaign_Template' ).getRecordTypeId();

	/**
	* @Method: 		afterInsert
	* @param: 		List<CampaignMember> lstCampaignMembers
	* @Description: NA
	* @author 		Manuel Medina - 29012019
	*/
	public static void beforeInsert( List<CampaignMember> lstCampaignMembers ){
		if( !PAD.canTrigger( 'CampaignMember_BeforeInsert' ) ){
			return;
		}
		
		gdprControl( lstCampaignMembers );
	}
	
	/**
	* @Method: 		gdprControl
	* @param: 		List<CampaignMember> lstCampaignMembers
	* @Description: NA
	* @author 		Manuel Medina - 29012019
	*/
	public static void gdprControl( List<CampaignMember> lstCampaignMembers ){
		Map<Id, Contact> mapContactById										= new Map<Id, Contact>();
		Map<Id, Campaign> mapCampaignIdById									= new Map<Id, Campaign>();
		List<CampaignMember> lstCampaignMembersToDelete						= new List<CampaignMember>();
		Set<Id> setEntityIds												= new Set<Id>();
		Set<String> setCampaignTypes										= new Set<String>();

		for( CampaignMember objCampaignMember : lstCampaignMembers ){
			mapContactById.put( objCampaignMember.ContactId, new Contact() );
			mapCampaignIdById.put( objCampaignMember.CampaignId, new Campaign() );
		}

		mapCampaignIdById													= new Map<Id, Campaign>( [
																				SELECT Id,
																					OwnerId,
																					Owner.AccountId,
																					Type,
																					RecordType.DeveloperName
																				FROM Campaign
																				WHERE Id IN: mapCampaignIdById.keySet()
																				AND RecordType.DeveloperName = 'DMCampaign'
																			] );

		for( Campaign objCampaign : mapCampaignIdById.values() ){
			setEntityIds.add( objCampaign.Owner.AccountId );
			setCampaignTypes.add( objCampaign.Type );
		}

		mapContactById														= new Map<Id, Contact>( [
																				SELECT Id,
																					(
																						SELECT Id,
																							Entity__c,
																							EntityID__c,
																							Channel__c,
																							Contact__c
																						FROM Contactability__r
																						WHERE Entity__c = 'POS'
																						AND EntityID__c IN: setEntityIds
																						AND ContactabilityStatus__c = true
																						AND Channel__c IN: setCampaignTypes
																					)
																				FROM Contact
																				WHERE Id IN: mapContactById.keySet()
																			] );

		for( CampaignMember objCampaignMember : lstCampaignMembers ){
			if( mapContactById.containsKey( objCampaignMember.ContactId ) && ( mapCampaignIdById.isEmpty() || mapContactById.get( objCampaignMember.ContactId ).Contactability__r == null || ( mapContactById.get( objCampaignMember.ContactId ).Contactability__r != null && mapContactById.get( objCampaignMember.ContactId ).Contactability__r.isEmpty() ) ) ){
				objCampaignMember.TECH_ToDelete__c							= true;
			}
			
			if( objCampaignMember.LeadId != null ){
				objCampaignMember.TECH_ToDelete__c							= true;
			}
		}
	}

	/**
	* @Method: 		deleteCampaignMembers
	* @param: 		List<CampaignMemberToDelete> lstCampaignMemberToDelete
	* @Description: Allow delete campaing members based on record ids received from process builder CampaignMember_PB001_GDPRControl.
	* @author 		Manuel Medina - 30012019
	*/
	@invocableMethod( label='Delete campaign members.' )
	public static void deleteCampaignMembers( List<CampaignMemberToDelete> lstCampaignMemberToDelete ){
		List<CampaignMember> lstToDelete									= new List<CampaignMember>();
		
		for( CampaignMemberToDelete clsCampaignMemberToDelete : lstCampaignMemberToDelete ){
			CampaignMember objCampaignMember								= new CampaignMember();
			objCampaignMember.Id											= clsCampaignMemberToDelete.idCampaignMember;
			
			lstToDelete.add( objCampaignMember );
		}
		
		
		delete lstToDelete;
		Database.emptyRecycleBin( lstToDelete );
	}
	
	/**
	* @Class: 		CampaignMemberToDelete
	* @param: 		NA
	* @Description: NA
	* @author 		Manuel Medina - 30012019
	*/
	public class CampaignMemberToDelete{
		@InvocableVariable( label='Campaign Member Id' )
		public Id idCampaignMember;
	}
}
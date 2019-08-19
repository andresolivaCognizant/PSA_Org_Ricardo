/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			CARE
* Description:		Extends functionalities for case creation form.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2019-04-01		Manuel Medina (MM)		Initial definition.
*********************************************************************************************************/
public with sharing class NewCaseOverrideController {

	/**
	* @Method: 		getCurrentUser
	* @param: 		N/A
	* @Description: Returns user object with required fields to manage visibility.
	* @author 		Manuel Medina - 01042019
	*/
	@AuraEnabled
	public static Map<String, Object> getCurrentUser(){
		Map<String, Object> mapResponse					= new Map<String, Object>();
		List<ProfilesCECUsers__mdt> lstProfilesCECUser	= new List<ProfilesCECUsers__mdt>();

		User objUser									= [SELECT Id,
																Name,
																TimeZoneSidKey,
																Username,
																Alias,
																Country,
																Email,
																IsActive,
																IsPortalEnabled,
																Profile.Name
															FROM User 
															WHERE Id =: UserInfo.getUserId()
														];

		lstProfilesCECUser								= [SELECT Label,
																DeveloperName
															FROM ProfilesCECUsers__mdt
															WHERE IsActive__c = true
															AND Label =: objUser.Profile.Name
															LIMIT 1
														];

		mapResponse.put( 'UserInfo', objUser );
		mapResponse.put( 'Profile', ( lstProfilesCECUser.isEmpty() ? '' : lstProfilesCECUser.get( 0 ).DeveloperName ) );

		return mapResponse;
	}
}
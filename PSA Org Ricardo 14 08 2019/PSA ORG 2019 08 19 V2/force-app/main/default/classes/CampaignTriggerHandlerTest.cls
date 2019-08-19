/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			Distributed Marketing
* Description:		CampaignTriggerHandler test class.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2019-01-29		Manuel Medina (MM)		Initial definition.
*********************************************************************************************************/
@isTest
private class CampaignTriggerHandlerTest {

	private final static Id idRTDMCampaing				= Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get( 'DMCampaign' ).getRecordTypeId();
	private final static Id idRTDMCampaingTemplate		= Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get( 'DM_Campaign_Template' ).getRecordTypeId();
	
	static testMethod void myUnitTest(){
		Campaign objCampaign							= new Campaign();
		objCampaign.Name								= 'Template Campaign';
		objCampaign.RecordTypeId						= idRTDMCampaingTemplate;
		insert objCampaign;

		Test.startTest();

		Campaign objSingUpCampaign						= new Campaign();
		objSingUpCampaign.Name							= 'Sing Up Campaign';
		objSingUpCampaign.RecordTypeId					= idRTDMCampaingTemplate;
		objSingUpCampaign.ParentId						= objCampaign.Id;
		insert objSingUpCampaign;

		Test.stopTest();
	}
}
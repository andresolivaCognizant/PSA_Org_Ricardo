/******************************************************************************************
* Name: 			CustomRelatedListControllerTest
* Author: 			Manuel Medina
* Description:		Test class for CustomRelatedListController class
* 
* Changes (Version)
* -----------------------------------------------------------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2019-05-27		Manuel Medina (MM)		Initial definition.
*******************************************************************************************/
@isTest 
public class CustomRelatedListControllerTest {

	/******************************************************************************************************
	 * @Method          : setup
	 * @Author          : Manuel Medina
	 * @Created         : 27/05/2019
	 * @Description     : Setup Method
	 ******************************************************************************************************/
	@testSetup 
	static void setup() {
		System.runAs( [SELECT Id FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1][0] ){
			List<et4ae5__SendDefinition__c> lstSendDefinitios	= Test.loadData( et4ae5__SendDefinition__c.sObjectType, 'DM_SendDefinitios' );
			List<Campaign> lstCampaigns							= Test.loadData( Campaign.sObjectType, 'DM_Campaigns' );
			List<et4ae5__IndividualEmailResult__c> lstIERs		= Test.loadData( et4ae5__IndividualEmailResult__c.sObjectType, 'DM_IndividualEmailResults' );
			List<Account> lstAccounts							= TestDataFactoryUtil.createPersonAccount( 5 );
			List<Contact> lstCotnacts							= [SELECT Id
																	FROM Contact
																	WHERE AccountId IN: lstAccounts
																];

			Integer i											= 0;
			for( Account objAccount : lstAccounts ){
				objAccount.FirstName							= 'CI_Account ' + i;
				i++;
			}
			
			update lstAccounts;

			for( et4ae5__IndividualEmailResult__c objIER : lstIERs ){
				Integer intIdex									= ( Math.random() * 5 ).intValue();

				objIER.et4ae5__Contact__c						= lstCotnacts.get( intIdex ).Id;
				objIER.et4ae5__DateSent__c						= System.now().addDays( intIdex - 10 );
			}

			update lstIERs;
		}
	}

	/******************************************************************************************************
	 * @Method          : campaignInfluenceProcessTest
	 * @Author          : Manuel Medina
	 * @Created         : 27/05/2019
	 * @Description     : Test for getRecords method. This method also covers:
	 *						- getColumns
	 *						- getFieldDescribe
	 *						- manageException
	 ******************************************************************************************************/
	@isTest
	public static void campaignInfluenceProcessTest(){
		List<Account> lstAccounts								= [SELECT Id
																	FROM Account
																	WHERE FirstName LIKE 'CI_Account%'
																];

		Opportunity objOpportunity								= new Opportunity();
		objOpportunity.Name										= 'CI_Opportunity';
		objOpportunity.AccountId								= lstAccounts.get( 0 ).Id;
		objOpportunity.StageName								= '1';
		objOpportunity.CloseDate								= System.today().addDays( 30 );
		objOpportunity.Country__c								= 'PT';
		objOpportunity.Brand__c									= 'AP';
		objOpportunity.Activity__c								= 'APV';
		objOpportunity.LCDVInterest__c							= 'TSC1';
		
		insert objOpportunity;

		Test.startTest();
			String strRequestFieldSet							= '{' +
																	'"strSObject"		: "CampaignInfluence",' +
																	'"strParentField"	: "OpportunityId",' +
																	'"strRecordId"		: "' + objOpportunity.Id + '",' +
																	'"strFieldSet"		: "DM_CampaignRelatedListFields",' +
																	'"strFields"		: "",' +
																	'"strFilter"		: "ContactId != null"' +
																'}';

			String strRequestFields								= '{' +
																	'"strSObject"		: "CampaignInfluence",' +
																	'"strParentField"	: "OpportunityId",' +
																	'"strRecordId"		: "' + objOpportunity.Id + '",' +
																	'"strFieldSet"		: "",' +
																	'"strFields"		: "Campaign.Name,Contact.Name,Influence",' +
																	'"strFilter"		: "ContactId != null"' +
																'}';

			String strRequestError								= '{' +
																	'"strSObject"		: "CampaignInfluence",' +
																	'"strParentField"	: "OpportunityId",' +
																	'"strRecordId"		: "' + objOpportunity.Id + '",' +
																	'"strFieldSet"		: "",' +
																	'"strFields"		: "CampaignName,Contact.Name,Influence",' +
																	'"strFilter"		: "ContactId != null"' +
																'}';

			Map<String, Object> mapResponse						= new Map<String, Object>( CustomRelatedListController.getRecords( strRequestFieldSet ) );
			Map<String, Object> mapResponseError				= new Map<String, Object>( CustomRelatedListController.getRecords( strRequestError ) );
			
			CustomRelatedListController.getRecords( strRequestFields );

			System.assertEquals( true, mapResponse.containsKey( 'records' ) );
			System.assertEquals( true, Boolean.valueOf( mapResponseError.get( 'hasError' ) ) );
		Test.stopTest();
	}
}
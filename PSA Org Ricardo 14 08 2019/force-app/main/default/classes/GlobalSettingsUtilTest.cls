/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			-
* Description:		Test class for GlobalSettingsUtil class
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2019-06-07		Manuel Medina (MM)		Initial definition.
*********************************************************************************************************/
@isTest 
public class GlobalSettingsUtilTest{

	/******************************************************************************************************
	* @Method			: GlobalSettingsUtil_methods
	* @Author			: Manuel Medina
	* @Created			: 08/07/2019
	* @Description		: Test for GlobalSettingsUtil methods.
	******************************************************************************************************/
	@isTest
	public static void GlobalSettingsUtil_methods(){
		Test.startTest();
			Map<String, Map<String, Object>> mapAttributesByName_1	= new Map<String, Map<String, Object>>(
																		GlobalSettingsUtil.getGlobalSettingAttributes(
																			new Set<String>{ 'SendEmail' },
																			new Set<String>()
																		)
																	);

			Map<String, Map<String, Object>> mapAttributesByName_2	= new Map<String, Map<String, Object>>(
																		GlobalSettingsUtil.getGlobalSettingAttributes(
																			'["SendEmail"]',
																			'[]'
																		)
																	);

			Map<String, Object> mapMetadataByName_1					= GlobalSettingsUtil.getCustomMetadataRecords(
																		'VehicleEventStatus__mdt',
																		new List<String>{ 'MasterLabel','Code__c' },
																		null,
																		true
																	);

			Map<String, Object> mapMetadataByName_2					= GlobalSettingsUtil.getCustomMetadataRecords(
																		'VehicleEventStatus__mdt',
																		'["MasterLabel", "Code__c"]',
																		null,
																		false
																	);

			Map<String, Object> mapMetadataByName_3					= GlobalSettingsUtil.getCustomMetadataRecords(
																		'ApvHeaderMaintenanceThresholds__mdt',
																		new List<String>{ 'Brand__c', 'Country__c', 'RedOrangeLimit__c', 'OrangeGreenLimit__c', 'VehicleAge__c' },
																		'ESAC'
																	);

			String strKey_1											= GlobalSettingsUtil.getCustomMetadataKey( new List<String>{ 'PL', 'AC' } );
			String strKey_2											= GlobalSettingsUtil.getCustomMetadataKey( 'ES', 'AP', '' );
			String strNullKey										= GlobalSettingsUtil.getCustomMetadataKey( new List<String>() );
			
			System.assertEquals( false, mapAttributesByName_1.get( 'SendEmail' ).isEmpty() );
			System.assertEquals( false, mapAttributesByName_2.get( 'SendEmail' ).isEmpty() );
			System.assertEquals( false, mapMetadataByName_1.get( 'MasterLabel' ) != null );
			System.assertEquals( false, mapMetadataByName_2.get( 'MasterLabel' ) != null );
			System.assertEquals( false, mapMetadataByName_3.get( 'MasterLabel' ) != null );
			System.assertEquals( 'PLAC', strKey_1 );
			System.assertEquals( 'ESAP', strKey_2 );
			System.assertEquals( 'All', strNullKey );
		Test.stopTest();
	}
}
/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			AfterSales
* Description:		Util class related to GlobalSetting__mdt custom metadata type.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------

* @version	1.0		2018-08-27		Manuel Medina (MM)		Initial definition.
*********************************************************************************************************/
public class GlobalSettingsUtil {

	public static Boolean blnIsKeyEmpty										= false;
	
	/**
	* @Method: 		getGlobalSettingAttributes
	* @param: 		Set<String> setGlobalSettings			: One or more Global Settings defined on GlobalSetting__mdt. (DeveloperName)
	* @param: 		Set<String> setGlobalSettingAttributes	: One or more Global Setting Attributes defined on GlobalSettingAttributes__mdt. (DeveloperName)
	* @Description:	Returns a map with all attributes related to given global settings.
	* @author 		Manuel Medina - 27082018
	*/
	public static Map<String, Map<String, Object>> getGlobalSettingAttributes( Set<String> setGlobalSettings, Set<String> setGlobalSettingAttributes ){
		Map<String, Map<String, Object>> mapAttributesByGlobalSetting		= new Map<String, Map<String, Object>>();
		
		Map<Id, GlobalSettingAttributes__mdt> mapGlobalSettingById			= new Map<Id, GlobalSettingAttributes__mdt>( [
																				SELECT Id,
																					DeveloperName,
																					GlobalSetting__c,
																					GlobalSetting__r.DeveloperName,
																					AttributeValue__c,
																					SObject__c
																				FROM GlobalSettingAttributes__mdt
																				WHERE GlobalSetting__r.DeveloperName IN: setGlobalSettings
																				AND DeveloperName IN: setGlobalSettingAttributes
																			] );

		mapGlobalSettingById.putAll( [
			SELECT Id,
				DeveloperName,
				GlobalSetting__c,
				GlobalSetting__r.DeveloperName,
				AttributeValue__c,
				SObject__c
			FROM GlobalSettingAttributes__mdt
			WHERE GlobalSetting__r.DeveloperName IN: setGlobalSettings
			AND SObject__c IN: setGlobalSettingAttributes
		] );

		if( setGlobalSettingAttributes.isEmpty() ){
			mapGlobalSettingById.putAll( [
				SELECT Id,
					DeveloperName,
					GlobalSetting__c,
					GlobalSetting__r.DeveloperName,
					AttributeValue__c,
					SObject__c
				FROM GlobalSettingAttributes__mdt
				WHERE GlobalSetting__r.DeveloperName IN: setGlobalSettings
			] );
		}

		for( GlobalSettingAttributes__mdt mdtGlobalSettingAttribute : mapGlobalSettingById.values() ){
			if( mapAttributesByGlobalSetting.containsKey( mdtGlobalSettingAttribute.GlobalSetting__r.DeveloperName ) ){
				Map<String, Object> mapAttributeValueByAttribute			= new Map<String, Object>( mapAttributesByGlobalSetting.get( mdtGlobalSettingAttribute.GlobalSetting__r.DeveloperName ) );

				mapAttributeValueByAttribute.put( mdtGlobalSettingAttribute.DeveloperName, mdtGlobalSettingAttribute.AttributeValue__c );

				if( String.isNotBlank( mdtGlobalSettingAttribute.SObject__c ) ){
					mapAttributeValueByAttribute.put( mdtGlobalSettingAttribute.SObject__c, mdtGlobalSettingAttribute.AttributeValue__c );
				}

				mapAttributesByGlobalSetting.put( mdtGlobalSettingAttribute.GlobalSetting__r.DeveloperName, mapAttributeValueByAttribute );

			}else if( !mapAttributesByGlobalSetting.containsKey( mdtGlobalSettingAttribute.GlobalSetting__r.DeveloperName ) ){
				Map<String, Object> mapAttributeValueByAttribute			= new Map<String, Object>();

				mapAttributeValueByAttribute.put( mdtGlobalSettingAttribute.DeveloperName, mdtGlobalSettingAttribute.AttributeValue__c );

				if( String.isNotBlank( mdtGlobalSettingAttribute.SObject__c ) ){
					mapAttributeValueByAttribute.put( mdtGlobalSettingAttribute.SObject__c, mdtGlobalSettingAttribute.AttributeValue__c );
				}

				mapAttributesByGlobalSetting.put( mdtGlobalSettingAttribute.GlobalSetting__r.DeveloperName, mapAttributeValueByAttribute );
			}
		}
		
		return mapAttributesByGlobalSetting;
	}
	
	/**
	* @Method: 		getGlobalSettingAttributes
	* @param: 		String strGlobalSettings			: JSON: One or more Global Settings defined on GlobalSetting__mdt. (DeveloperName)
	* @param: 		String strGlobalSettingAttributes	: JSON: One or more Global Setting Attributes defined on GlobalSettingAttributes__mdt. (DeveloperName)
	* @Description:	Returns a map with all attributes related to given global settings.
	* @author 		Manuel Medina - 27082018
	*/
	@AuraEnabled 
	public static Map<String, Map<String, Object>> getGlobalSettingAttributes( String strGlobalSettings, String strGlobalSettingAttributes ){
		return getGlobalSettingAttributes( ( Set<String> ) JSON.deserialize( strGlobalSettings, Set<String>.class ), ( Set<String> ) JSON.deserialize( strGlobalSettingAttributes, Set<String>.class ) );
	}
	
	/**
	* @Method: 		getCustomMetadataRecords
	* @param: 		String strCustomMetadataAPIName	: Custom metadata API name.
	* @param: 		String strFields				: JSON: One or more field API names related.
	* @param: 		String strKey					: If is informed returns a Map<Key, FieldValue> for the given key. (DeveloperName)
	* @param: 		Boolean blnGetAll				: If is true returns a Map<Key, Map<Field,FieldValue>> which represents all records in the custom metadata type.
	* @Description:	Returns a map with one or all attributes related to given custom metadata type.
	* @author 		Manuel Medina - 30082018
	*/
	@AuraEnabled 
	public static Map<String, Object> getCustomMetadataRecords( String strCustomMetadataAPIName, String strFields, String strKey, Boolean blnGetAll ){
		List<String> lstFields												= new List<String>( ( List<String> ) JSON.deserialize( strFields, List<String>.class ) );
		Map<String, Object> mapCustomMetadataRecordsByKey					= new Map<String, Object>();
		List<SObject> lstCustomMetadataRecords								= new List<SObject>(
																				Database.query(
																					'SELECT Id, DeveloperName, ' +
																						String.valueOf( lstFields ).replace( '(','' ).replace( ')','' ) + ' ' +
																					'FROM ' + strCustomMetadataAPIName + ' ' +
																					( blnGetAll ? '' : 'WHERE DeveloperName = \'' + strKey + '\'' )
																				)
																			);
																			
		for( SObject sObjMdtRecord : lstCustomMetadataRecords ){
			if( blnGetAll ){
				mapCustomMetadataRecordsByKey.put( String.valueOf( sObjMdtRecord.get( 'DeveloperName' ) ), new Map<String, Object>() );
				
				for( String strField : lstFields ){
					Map<String, Object> mapAttributeValueByFieldName		= ( Map<String, Object> ) mapCustomMetadataRecordsByKey.get( String.valueOf( sObjMdtRecord.get( 'DeveloperName' ) ) );
					mapAttributeValueByFieldName.put( strField, sObjMdtRecord.get( strField ) );
					mapCustomMetadataRecordsByKey.put( String.valueOf( sObjMdtRecord.get( 'DeveloperName' ) ), mapAttributeValueByFieldName );
				}
				
			}else{
				for( String strField : lstFields ){
					mapCustomMetadataRecordsByKey.put( strField, sObjMdtRecord.get( strField ) );
				}
			}
		}
		
		return mapCustomMetadataRecordsByKey;
	}

	/**
	* @Method: 		getCustomMetadataRecords
	* @param: 		String strCustomMetadataAPIName	: Custom metadata API name.
	* @param: 		String strFields				: JSON: One or more field API names related.
	* @param: 		String strKey					: If is informed returns a Map<Key, FieldValue> for the given key. (DeveloperName)
	* @param: 		Boolean blnGetAll				: If is true returns a Map<Key, Map<Field,FieldValue>> which represents all records in the custom metadata type.
	* @Description:	Returns a map with one or all attributes related to given custom metadata type.
	* @author 		Manuel Medina - 30082018
	*/
	public static Map<String, SObject> getCustomMetadataRecords( String strCustomMetadataAPIName, List<String> lstFields, String strKey ){
		Map<String, SObject> mapCustomMetadataRecordsByKey					= new Map<String, SObject>();
		List<SObject> lstCustomMetadataRecords								= new List<SObject>(
																				Database.query(
																					'SELECT Id, DeveloperName, ' +
																						String.valueOf( lstFields ).replace( '(','' ).replace( ')','' ) + ' ' +
																					'FROM ' + strCustomMetadataAPIName + ' ' +
																					( blnIsKeyEmpty ? '' : 'WHERE DeveloperName = \'' + strKey + '\'' )
																				)
																			);
																			
		for( SObject sObjMdtRecord : lstCustomMetadataRecords ){
			mapCustomMetadataRecordsByKey.put( String.valueOf( sObjMdtRecord.get( 'DeveloperName' ) ), sObjMdtRecord );
		}
		
		return mapCustomMetadataRecordsByKey;
	}
	
	/**
	* @Method: 		getCustomMetadataRecords
	* @param: 		String strCustomMetadataAPIName	: Custom metadata API name.
	* @param: 		String strFields				: One or more field API names related.
	* @param: 		String strKey					: If is informed returns a Map<Key, FieldValue> for the given key. (DeveloperName)
	* @param: 		Boolean blnGetAll				: If is true returns a Map<Key, Map<Field,FieldValue>> which represents all records in the custom metadata type.
	* @Description:	Returns a map with one or all attributes related to given custom metadata type.
	* @author 		Manuel Medina - 30082018
	*/
	public static Map<String, Object> getCustomMetadataRecords( String strCustomMetadataAPIName, List<String> lstFields, String strKey, Boolean blnGetAll ){
		return getCustomMetadataRecords( strCustomMetadataAPIName, JSON.serialize( lstFields ), strKey, blnGetAll );
	}

	/**
	* @Method: 		getCustomMetadataKey
	* @param: 		List<String> lstValues
	* @Description:	Returns a concatenated string which represents a valid key for a custom metadata type.
	* @author 		Manuel Medina - 30102018
	*/
	public static String getCustomMetadataKey( String strValue1, String strValue2, String strValue3 ){
		return getCustomMetadataKey( new List<String>{ strValue1, strValue2, strValue3 } );
	}

	/**
	* @Method: 		getCustomMetadataKey
	* @param: 		List<String> lstValues
	* @Description:	Returns a concatenated string which represents a valid key for a custom metadata type.
	* @author 		Manuel Medina - 30102018
	*/
	public static String getCustomMetadataKey( List<String> lstValues ){
		String strKey														= String.join( lstValues, '' );
		blnIsKeyEmpty														= String.isBlank( strKey );

		return String.isBlank( strKey ) ? 'All' : strKey;
	}
}
/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			Sales & B2B
* Description:		SendEmail controller class.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2019-05-23		Manuel Medina (MM)		Initial definition.
*********************************************************************************************************/
public without sharing class CustomRelatedListController {

	public static Map<String, Object> mapResponse							= new Map<String, Object>{
																				'hasError'		=> false,
																				'ERROR'			=> '',
																				'REQUEST'		=> ''
																			};

	public static Map<String, String> mapLightningDataTypeByApexDataType	= new Map<String, String>{
																				'BOOLEAN'		=> 'boolean',
																				'CURRENCY'		=> 'currency',
																				'DATETIME'		=> 'date',
																				'DATE'			=> 'date-local',
																				'EMAIL'			=> 'email',
																				'DOUBLE'		=> 'number',
																				'LONG'			=> 'number',
																				'PERCENT'		=> 'number',
																				'PHONE'			=> 'phone',
																				'STRING'		=> 'text',
																				'TEXTAREA'		=> 'text',
																				'PICKLIST'		=> 'text',
																				'MULTIPICKLIST'	=> 'text',
																				'REFERENCE'		=> 'url'
																			};
	
	public static String strSObject;

	public static List<String> lstFields									= new List<String>();
	
	/**
	* @Method: 		getRecords
	* @param: 		String strRequest
	* @Description:	Returns all records related to given SObject record id.
	* @author 		Manuel Medina - 23052019
	*/
	@AuraEnabled
	public static Map<String, Object> getRecords( String strRequest ){
		Map<String, Object> mapRequest										= new Map<String, Object>( ( Map<String, Object> ) JSON.deserializeUntyped( strRequest ) );
		mapResponse.put( 'REQUEST', mapRequest );
		
		try{
			strSObject														= String.valueOf( mapRequest.get( 'strSObject' ) );
			String strParentField											= String.valueOf( mapRequest.get( 'strParentField' ) );
			String strRecordId												= String.valueOf( mapRequest.get( 'strRecordId' ) );
			String strFieldSet												= mapRequest.containsKey( 'strFieldSet' ) ? String.valueOf( mapRequest.get( 'strFieldSet' ) ) : null;
			String strFields												= mapRequest.containsKey( 'strFields' ) ? String.valueOf( mapRequest.get( 'strFields' ) ) : null;
			String strFilter												= mapRequest.containsKey( 'strFilter' ) ? String.valueOf( mapRequest.get( 'strFilter' ) ) : null;
			String strSOQL													= 'SELECT Id, ';

			if( String.isNotBlank( strFieldSet ) ){
				Schema.FieldSet fsColumns									= Schema.getGlobalDescribe().get( strSObject ).getDescribe().fieldSets.getMap().get( strFieldSet );
			
				for( Schema.FieldSetMember fsMember : fsColumns.getFields() ){
					strSOQL													+= fsMember.getFieldPath() + ', ';

					lstFields.add( String.valueOf( fsMember.getFieldPath() ) );
				}

				strSOQL														= strSOQL.substringBeforeLast( ',' );

			}else{
				strSOQL														+= strFields;

				lstFields.addAll( strFields.split( ',' ) );
			}

			strSOQL															+= ' FROM ' + strSObject + ' WHERE ' + strParentField + ' = \'' + strRecordId + '\'';
			strSOQL															+= String.isNotBlank( strFilter ) ? ' AND ' + strFilter : '';

			mapResponse.put( 'records', Database.query( strSOQL ) );
			mapResponse.put( 'columns', getColumns() );

			return mapResponse;

		}catch( Exception e ){
			manageException( e );
			
			return mapResponse;
		}
	}

	/**
	* @Method: 		getColumns
	* @param: 		N/A
	* @Description:	Returns related list columns based on given fields.
	* @author 		Manuel Medina - 24052019
	*/
	public static Object getColumns(){
		Map<String, Schema.DescribeFieldResult> mapFieldTypeByField			= new Map<String, Schema.DescribeFieldResult>( getFieldDescribe() );
		List<Object> lstColumns												= new List<Object>();

		for( String strField : mapFieldTypeByField.keySet() ){
			lstColumns.add(
				new Map<String, String>{
					'label'		=> mapFieldTypeByField.get( strField ).getLabel(),
					'fieldName'	=> strField,
					'type'		=> mapLightningDataTypeByApexDataType.containsKey( String.valueOf( mapFieldTypeByField.get( strField ).getType() ) ) ? mapLightningDataTypeByApexDataType.get( String.valueOf( mapFieldTypeByField.get( strField ).getType() ) ) : 'text'
				}
			);
		}

		return lstColumns;
	}

	/**
	* @Method: 		getFieldDescribe
	* @param: 		N/A
	* @Description:	Returns field describe to given list of fields.
	* @author 		Manuel Medina - 24052019
	*/
	public static Map<String, Schema.DescribeFieldResult> getFieldDescribe(){
		Map<String, Schema.DescribeFieldResult> mapFieldTypeByField			= new Map<String, Schema.DescribeFieldResult>();

		for( String strField : lstFields ){
			List<String> lstLookupFields									= strField.replace( '.', ',' ).split( ',' );

			String strLookupSObject											= lstLookupFields.size() > 1 ? lstLookupFields.get( 0 ) : null;
			String strLookupSObjectField									= lstLookupFields.size() > 1 ? lstLookupFields.get( 1 ) : strField;

			Map<String, Schema.SObjectField> mapFieldDescribeByFieldName	= Schema.getGlobalDescribe().get( strLookupSObject != null ? strLookupSObject : strSObject ).getDescribe().fields.getMap();

			mapFieldTypeByField.put( strField, mapFieldDescribeByFieldName.get( strLookupSObjectField ).getDescribe() );
		}
		
		return mapFieldTypeByField;
	}
	

	/**
	* @Method: 		manageException
	* @param: 		Exception e
	* @Description:	Updates mapResponse with error details.
	* @author 		Manuel Medina - 23052019
	*/
	public static void manageException( Exception e ){
		System.debug( '\n\n\n\t<<<<<<<<< ExceptionType >>>>>>>>> \n\t\t@@--> getCause > ' + e.getCause() + '\n\t\t@@--> getLineNumber > ' + e.getLineNumber() + '\n\t\t@@--> getMessage > '+ e.getMessage() + '\n\t\t@@--> getStackTraceString > '+ e.getStackTraceString() + '\n\t\t@@--> getTypeName > ' + e.getTypeName() + '\n\n' );
			
		mapResponse.put( 'hasError', true );
		mapResponse.put(
			'ERROR',
			new Map<String, Object>{
				'cause'				=> e.getCause(),
				'lineNumber'		=> e.getLineNumber(),
				'message'			=> e.getMessage(),
				'stackTraceString'	=> e.getStackTraceString(),
				'typeName'			=> e.getTypeName()
			}
		);
	}
}
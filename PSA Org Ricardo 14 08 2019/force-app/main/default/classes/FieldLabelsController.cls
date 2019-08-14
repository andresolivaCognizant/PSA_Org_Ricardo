public class FieldLabelsController {
	
	@AuraEnabled 
	public static Map<String, Map<String, String>> getFieldLabel( String strFieldNames ){
		Map<String, Map<String, String>> mapFieldLabelByFieldName	= new Map<String, Map<String, String>>();
		Map<String, List<String>> mapFieldsBySObject				= new Map<String, List<String>>();
		
		try{
			for( Object obj : ( List<Object> ) System.JSON.deserializeUntyped( strFieldNames ) ){
				String strField										= String.valueOf( obj ).replace( '.', ',' ).split( ',' ).get( 1 );
				String strSObject									= String.valueOf( obj ).replace( '.', ',' ).split( ',' ).get( 0 );
				
				if( mapFieldsBySObject.containsKey( strSObject ) ){
					mapFieldsBySObject.get( strSObject ).add( strField );
					
				}else if( !mapFieldsBySObject.containsKey( strSObject ) ){
					mapFieldsBySObject.put( strSObject, new List<String>{ strField } );
				}
			}
			
			for( String strSObject : mapFieldsBySObject.keySet() ){
				Map<String, Schema.SObjectType> mapSFDCObjects			= Schema.getGlobalDescribe();
				Schema.DescribeSObjectResult sObjResult					= mapSFDCObjects.get( strSObject ).getDescribe();
				Map<String, Schema.SObjectField> mapFields				= sObjResult.fields.getMap();
				
				for( String strfieldName : mapFieldsBySObject.get( strSObject ) ){
					Schema.SObjectField field							= mapFields.get( strfieldName );
					
					if( field != null ){
						Schema.DescribeFieldResult fieldResult			= field.getDescribe();
					
						if( mapFieldLabelByFieldName.containsKey( strSObject ) ){
							mapFieldLabelByFieldName.get( strSObject ).put( strfieldName, String.valueOf( fieldResult.getLabel() ) );
							
						}else if( !mapFieldLabelByFieldName.containsKey( strSObject ) ){
							mapFieldLabelByFieldName.put( strSObject, new Map<String, String>{ strfieldName => String.valueOf( fieldResult.getLabel() ) } );
						}
						
					}else{
						mapFieldLabelByFieldName.get( strSObject ).put( strfieldName, strfieldName );
					}
				}
			}
			
			return mapFieldLabelByFieldName;
		}catch( Exception e ){
			System.debug( '\n\n\n\t<<<<<<<<< ExceptionType >>>>>>>>> \n\t\t@@--> getCause > ' + e.getCause() + '\n\t\t@@--> getLineNumber > ' + e.getLineNumber() + '\n\t\t@@--> getMessage > '+ e.getMessage() + '\n\t\t@@--> getStackTraceString > '+ e.getStackTraceString() + '\n\t\t@@--> getTypeName > ' + e.getTypeName() + '\n\n' );
			
			mapFieldLabelByFieldName.put( 'ERROR', new Map<String, String>{ 'E' => '\n\n\n\t<<<<<<<<< ExceptionType >>>>>>>>> \n\t\t@@--> getCause > ' + e.getCause() + '\n\t\t@@--> getLineNumber > ' + e.getLineNumber() + '\n\t\t@@--> getMessage > '+ e.getMessage() + '\n\t\t@@--> getStackTraceString > '+ e.getStackTraceString() + '\n\t\t@@--> getTypeName > ' + e.getTypeName() + '\n\n' } );
			return mapFieldLabelByFieldName;
		}
		
		return null;
	}
}
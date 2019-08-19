/*
-- - Name         : LookupAController
-- - Author       : DXC. Ruben Fernandez Lopez
-- - Date         : 22/01/2018
-- - Description  : This apex class returns the list of records and labels 
					for the specified sObject
--
-- - History:
-- Date         Author  Version  Comments
-- -----------  -----   -------  ---------------------------------------
-- 22/01/2018   DXC     1.0      Initial version rfernandezlo
*/
public with sharing class LookupAController {
	
	public static final string strBaseFields						= 'Id, Name';
	public static final string strEmailTemplateFields				= 'Id, Name, TemplateType, Subject, Markup, HtmlValue, Body';

	/**
	* This method is used to return a list of records from the specified object
	* @param ObjectName - The API name of object
	* @param searchKeyWord - The text to search
	* @param whereClause - Allow add any where clause to the query
	*/ 
	@AuraEnabled
	public static List <sObject> fetchLookUpValues( String strFields, String strFieldToFilterKeyWord, String searchKeyWord, String ObjectName, String whereClause ){
		
		String searchKey 		    = searchKeyWord + '%';
		List <sObject> returnList 	= new List <sObject>();
		String sQuery               =  '';

		/* BEGIN - Manuel Medina - C1STAGILE-5479 - Improvement to add new fields when ObjectName is EmailTemplate - 15042019 */
		String strSelectFields		= !ObjectName.equals( 'EmailTemplate' ) ? strBaseFields : strEmailTemplateFields;
		strSelectFields				= String.isNotBlank( strFields ) ? strFields : strSelectFields;

		if(whereClause==null){
			sQuery =  'select ' + strSelectFields + ' from ' + ObjectName + ' where ' + strFieldToFilterKeyWord + ' LIKE: searchKey order by createdDate DESC limit 5';
		}else{
			sQuery =  'select ' + strSelectFields + ' from ' + ObjectName + ' where ' + strFieldToFilterKeyWord + ' LIKE: searchKey ' + whereClause +  ' order by createdDate DESC limit 5';
		}
		/* END - Manuel Medina - 15042019 */
		
		List <sObject> lstOfRecords = Database.query(sQuery);
		
		for (sObject obj: lstOfRecords) {
			returnList.add(obj);
		}

		return returnList;
	}
}
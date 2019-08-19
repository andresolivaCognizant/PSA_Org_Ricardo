/**
*   @Class          : CustomerSearchAController.cls
*   @Author         :   Ruben Fernandez Lopez
*   @Created        :   17 Jan 2018
*   @Description    :   Apex Controller class for LC002_CustomerSearch.cmo
*
*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Author           		Date                     Description
*	   Rubén Fernandez			18/1/2018				 Creation.
*   ----------------------------------------------------------------------------------------------------------------------------
**/
public without sharing class CustomerSearchAController {

	/*
	* @Method          :   getLabels
	* @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	* @Created         :   22 Jan 2018
	* @Description     :   This method is used to return a map of the labels for the inputs
	* @param 			:	objectname : Specify the API name of object to get the labels from
	*/	
	@AuraEnabled
	public static Map<String, String> getLabels(String objectName) {
		Map<String, String> labelsToShow = new Map<String, String>();

		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Schema.SobjectType objSchema   = SchemaMap.get(objectname);

		Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();
		for (String fieldName: fieldMap.keySet()) {
			labelsToShow.put(fieldName,fieldMap.get(fieldName).getDescribe().getLabel());
		}
		return labelsToShow;
	}

	/*
	* @Method          :   getfetchRecords
	* @Author          :   Rubén Fernandez Lopez
	* @Created         :   23/02/2018
	* @Description     :   
	* @Params          :   
	* @Returns         :   
	*/ 
	@AuraEnabled 
	public static DataTableResponse getfetchRecords(String sObjectName, String sObjectType, String sWhereClause, List<String> whereSOSL, Boolean bAllowAccess){ //  Integer iLimits , Integer iOffsets){

		// System.debug('1º) sObjectName : ' + sObjectName + ' 2º) sObjectType : ' + sObjectType + ' 3º) sWhereClause : ' + sWhereClause + ' 4º) whereSOSL :' + whereSOSL);
		System.debug('START getfetchRecords ');
		
		/* BEGIN - Manuel Medina - C1STAGILE-6094 - Logic implemented to remove accents into WHERE clause - 12122018 */
		if( String.isNotBlank( sWhereClause ) ){
			sWhereClause										= GeneralUtils.removeAccents( sWhereClause ).toUpperCase();
		}
		
		if( whereSOSL != null && !whereSOSL.isEmpty() ){
			for( String strSOSL : whereSOSL ){
				strSOSL											= GeneralUtils.removeAccents( strSOSL ).toUpperCase();
			}
		}
		/* END - Manuel Medina - 12122018 */

		bAllowAccess= (bAllowAccess==null)?true:bAllowAccess;
		String sFieldstoget  = '';
		if(!String.isEmpty(sObjectType)){
			List<CustomerSearchSettings__mdt> lFields = [SELECT SearchFields__c FROM CustomerSearchSettings__mdt where QualifiedApiName = :sObjectType limit 1];
			if(!lFields.isEmpty()){
				sFieldstoget =  lFields[0].searchfields__c;
			}
		}
		DataTableResponse ltngTableWrapper                      = new DataTableResponse();
		if(!whereSOSL.isEmpty()){
			List<String> lstfieldstoget                         = sFieldstoget.split(',');
			List<String> lstfinalfields							= new List<String>();
			String sNewObject                                   = sObjectName;
			List<DataTableColumns> lstTableColumn               = new list<DataTableColumns> ();
			DescribeSObjectResult objResult                     = Schema.getGlobalDescribe().get(sObjectName).getDescribe();
			DescribeSObjectResult objResultAux;
			DescribeFieldResult fieldResultAux;
			// First Step. Columns
			for(String field : lstfieldstoget){
				System.debug('field :' + field );
				if(field.indexof('.')>0){
					List<String> auxobj = field.split('\\.');
					if(field=='UserRecordAccess.HasReadAccess'){
						lstfinalfields.add(field);
						objResultAux              	             = Schema.getGlobalDescribe().get(auxobj.get(0)).getDescribe();
						fieldResultAux                           = objResultAux.fields.getMap().get(auxobj.get(1)).getDescribe();
					}else if (field.indexof('Id__r')>0){
						String sVal = String.valueof(auxobj.get(0));
						sNewObject =  sVal.left(sVal.length()-5);
						lstfinalfields.add(auxobj.get(1));
						objResultAux              	             = Schema.getGlobalDescribe().get(sNewObject.trim()).getDescribe();
						fieldResultAux                           = objResultAux.fields.getMap().get(auxobj.get(1)).getDescribe();
					}else{
						sNewObject = auxobj.get(0);
						lstfinalfields.add(auxobj.get(1));
						objResultAux              	             = Schema.getGlobalDescribe().get(sNewObject.trim()).getDescribe();
						fieldResultAux                           = objResultAux.fields.getMap().get(auxobj.get(1)).getDescribe();
					}
					System.debug('field sNewObject:' + sNewObject );

					System.debug('field name:' + fieldResultAux.getName() );
					if(field!='UserRecordAccess.HasReadAccess'){
						lstTableColumn.add(new DataTableColumns(fieldResultAux.getLabel(),fieldResultAux.getName(),String.valueof(fieldResultAux.getType()).toLowerCase(),true,false));
					}
				}else{
					DescribeFieldResult fieldResult              = objResult.fields.getMap().get(field).getDescribe();
					lstTableColumn.add(new DataTableColumns(fieldResult.getLabel(),fieldResult.getName(),String.valueof(fieldResult.getType()).toLowerCase(),true,false));
					lstfinalfields.add(field);
				}
			}
			// Second Step, Values
			String queryString  = 'SELECT '+ String.escapeSingleQuotes(sFieldstoget) + 
							' FROM '+ String.escapeSingleQuotes(sObjectName);

			if (sWhereClause != null && sWhereClause != '') {
				queryString += ' WHERE ' + sWhereClause;
			}

			String sQuerySOSL   = 'FIND  {' + String.join(whereSOSL,' OR ').replaceAll( '([?&|!{}\\[\\]()^~:\\\\\'+-])', '\\\\$1' ) + '}  IN ALL FIELDS Returning ' +
								( sObjectType.equals( 'B2B' ) && sWhereClause.contains( 'Account.' ) ? ' Account, ' + sObjectName : sObjectName ) + ' ('+ String.escapeSingleQuotes(String.valueof(sFieldstoget).left(sFieldstoget.length()-31)) +
								' WHERE ' + sWhereClause + ')';

			System.debug('sWhereClause ' + sWhereClause);
			System.debug('sQuerySOSL ' + sQuerySOSL);
			List<SObject> lstObjectResult = new List<sObject>();
			try {
				List<List<SObject>>searchList=search.query(sQuerySOSL);
				if (!searchList.isEmpty()){lstObjectResult = searchList.get(0);}
				System.debug('## RESULTS : ' + lstObjectResult.get(0));
			} catch(dmlexception e) {
				System.debug('## getfetchRecords --> DML Error : ' + e.getMessage());
			} catch (Exception e){
				System.debug('### getfetchRecords--> Exception : ' + e.getMessage());
			}
			List<Id> lstRecords = new List<Id>();
			List<Id> lstAuxRecords = new List<Id>();
			for (sObject o : lstObjectResult){
				Map<String, Object> fieldsToValue = o.getPopulatedFieldsAsMap();
				lstRecords.add(o.Id);
				system.debug('AccountId    ' + fieldsToValue.containsKey('AccountId'));
				system.debug('AccountId__c ' + fieldsToValue.containsKey('AccountId__c'));
				if(fieldsToValue.containsKey('AccountId')){
					lstAuxRecords.add((Id)o.get('AccountId'));
				}else if(fieldsToValue.containsKey('AccountId__c')){
					lstAuxRecords.add((Id)o.get('AccountId__c'));
				}
			}
			
			if( lstRecords.isEmpty() && sObjectName.equalsIgnoreCase( 'ASSET' ) && sWhereClause.contains( 'OrderId__r.OrderNumber' ) ){
				String sRel = (sObjectName=='AccountContactAssetRelation__c')?'__c':'';
				queryString     = 'SELECT '+ String.join(lstfinalfields,',') + 
								' FROM '+ String.escapeSingleQuotes(sNewObject) +
								' WHERE Id IN (SELECT ' + String.escapeSingleQuotes(sNewObject) +'Id' + sRel + ' FROM ' + String.escapeSingleQuotes(sObjectName)  +
								' WHERE ' + sWhereClause + ')';
				
			}else if( lstRecords.isEmpty() && sWhereClause.contains( 'Owner.id' ) ){
				Pattern myPattern		= Pattern.compile('([\\\'][0][0][5][a-zA-Z0-9]{15,}[\\\'])'); 
				Matcher myMatcher		= myPattern.matcher( sWhereClause );
				
				String strOwnerId		= '';
				
				while( myMatcher.find() ){
					strOwnerId			= myMatcher.group();
				}
				
				queryString     = 'SELECT '+ String.join(lstfinalfields,',') + 
								' FROM '+ String.escapeSingleQuotes(sNewObject) +
								' WHERE Owner.Id = ' + strOwnerId + ' ';
								
			}else if( !lstRecords.isEmpty() && sWhereClause.contains( 'Owner.id' ) ){
				Pattern myPattern		= Pattern.compile('([\\\'][0][0][5][a-zA-Z0-9]{15,}[\\\'])'); 
				Matcher myMatcher		= myPattern.matcher( sWhereClause );
				
				String strOwnerId		= '';
				
				while( myMatcher.find() ){
					strOwnerId			= myMatcher.group();
				}
				
				queryString     = 'SELECT '+ String.join(lstfinalfields,',') + 
								' FROM '+ String.escapeSingleQuotes(sNewObject) +
								' WHERE Owner.Id = ' + strOwnerId + ' ' +
								' AND Id IN: lstRecords';
				
			}else if( sObjectType.equals( 'B2B' ) && sWhereClause.contains( 'Account.' ) ){
				queryString     = 'SELECT '+ String.join(lstfinalfields,',') + 
								' FROM '+ String.escapeSingleQuotes(sNewObject) +
								' WHERE Id IN: lstRecords';
								
			}else if(sObjectName!=sNewObject){
				String sRel = (sObjectName=='AccountContactAssetRelation__c')?'__c':'';
				queryString     = 'SELECT '+ String.join(lstfinalfields,',') + 
								' FROM '+ String.escapeSingleQuotes(sNewObject) +
								' WHERE Id IN (SELECT ' + String.escapeSingleQuotes(sNewObject) +'Id' + sRel + ' FROM ' + String.escapeSingleQuotes(sObjectName)  +
								' WHERE Id IN: lstRecords)';

			}else{
				queryString     = 'SELECT '+ String.join(lstfinalfields,',') + 
								' FROM '+ String.escapeSingleQuotes(sNewObject) +
								' WHERE Id IN: lstRecords';
			}
			System.debug('## Last Query : ' + queryString);
			List<SObject> lstAux;
			List<Id> lstOfRecords = (lstAuxRecords.isEmpty()?lstRecords:lstAuxRecords);
			
			Set<Id> setRecordIds						= new Set<Id>();
			if( lstOfRecords.size() >= 200 ){
				for( Integer i=0; i<200; i++ ){
					setRecordIds.add( lstOfRecords.get( i ) );
				}
			}else{
				setRecordIds.addAll( lstOfRecords );
			}
			
			Map<Id,UserRecordAccess> mapAux				= new Map<Id,UserRecordAccess>( [
															SELECT RecordID,
																HasReadAccess 
															FROM UserRecordAccess 
															WHERE UserId =: UserInfo.getUserId() 
															AND RecordID IN :setRecordIds
														] );
			
			system.debug('mapAux ' + mapAux.size());
			List<DataTableObject> lstValues = new List<DataTableObject>();
			try {
				lstAux = database.query(queryString);

				for(sObject o : lstAux ){
					String sId = String.valueof(o.get('Id'));
					for(String sField : lstfinalfields){
						System.debug('sField ' + sField + ' IndexOf: ' + sField.indexOf('Name') + ' sId: ' + sId);
						System.debug('Contains HasReadAccess ' + mapAux.containsKey(sId));
						if(sField.indexOf('HasReadAccess')<0 && mapAux.containsKey(sId)){
							if(sField.indexOf('Name')<0 && !mapAux.get(sId).HasReadAccess && bAllowAccess){
								String s = String.valueof(o.get(sField));
								o.put(sField, String.valueof(SecurityUtilsLib.setMask(s)));
							}
							system.debug('mapAux.get(sId).HasReadAccess: ' + mapAux.get(sId).HasReadAccess);
						}
					}
					Boolean bAccess = (mapAux.containsKey(sId))?mapAux.get(sId).HasReadAccess:false;
					lstValues.add(new DataTableObject(o,bAccess));
				}
				system.debug('## RESULTS : ' + lstAux.get(0));
			} catch(dmlexception e) {
				system.debug('## getfetchRecords --> DML Error : ' + e.getMessage());
			} catch (Exception e){
				System.debug('### getfetchRecords--> Exception : ' + e.getMessage());
			}

			ltngTableWrapper.lstDataTableData                   = lstValues; //lstAux;
			ltngTableWrapper.lstDataTableColumns                = lstTableColumn;
		}
		return ltngTableWrapper;   
	}


	//private static String setMask(String sValue){

	//   String sToBeMasked = '';
	//   String sStart = '';
	//   System.debug('setMask START ' + sValue);
	//   if(!String.isEmpty(sValue)){
	//       Integer iTotal      = sValue.length();
	//       Integer iPos        = Integer.valueOf(sValue.length()/3);
	//       sStart              = sValue.left(iPos);
	//       sToBeMasked         = sStart.rightPad(iTotal-iPos, '*');
	//   }    
	//   System.debug('setMask END ' + sToBeMasked);
	//   return sToBeMasked;
	//}

	/*
	* @Method          :   getfetchRecords
	* @Author          :   Rubén Fernandez Lopez
	* @Created         :   23/02/2018
	* @Description     :   Wrapper class to hold Columns with headers
	* @Params          :   
	* @Returns         :   
	*/ 
	public class DataTableColumns {
		@AuraEnabled
		public String label {get;set;}
		@AuraEnabled       
		public String fieldName {get;set;}
		@AuraEnabled
		public String type {get;set;}
		@AuraEnabled
		public Boolean sortable {get;set;}
		@AuraEnabled
		public DataTableCell cellAttributes {get;set;}

		//Create and set five variables label, fieldname and type as required by the lightning:datatable
		public DataTableColumns(String label, String fieldName, String sType,Boolean bSortable, Boolean bAttributes){
			this.label      = label;
			this.fieldName  = fieldName;
			this.type       = sType; 
			this.sortable   = bSortable;
			if(bAttributes){
				this.cellAttributes = new DataTableCell(fieldName,label,'right');
			}
		}
	}
	public class DataTableColumnsLink {
		@AuraEnabled
		public DataTableEntity label {get;set;}
		public DataTableColumnsLink(DataTableEntity slabel){
			this.label = slabel;
		}
	}
	public class DataTableCell {
		@AuraEnabled
		public DataTableEntity iconName {get;set;}
		public DataTableEntity iconLabel {get;set;}
		public String iconPosition {get;set;}

		//Create and set three variables label, fieldname and type as required by the lightning:datatable
		public DataTableCell(String sfieldname,String sfieldlabel, String sfieldPosition){
			this.iconName  		= new DataTableEntity('UserHasReadAccess');
			this.iconLabel 		= new DataTableEntity(sfieldlabel);
			this.iconPosition 	= sfieldPosition;
		}
	}
	public class DataTableEntity {
		@AuraEnabled
		public String fieldname {get;set;}

		//Create and set three variables label, fieldname and type as required by the lightning:datatable
		public DataTableEntity(String sfieldname){
			this.fieldname = sfieldname;
		}
	}
	//Wrapper calss to hold response - This response is used in the lightning:datatable component
	public class DataTableResponse {
		@AuraEnabled
		public List<DataTableColumns> lstDataTableColumns {get;set;}
		@AuraEnabled         
		public List<DataTableObject> lstDataTableData {get;set;}

		public DataTableResponse(){
			lstDataTableColumns     = new List<DataTableColumns>();
			lstDataTableData        = new List<DataTableObject>();
		}
	}

	public class DataTableObject {
		@AuraEnabled
		public sObject sObjectVal {get;set;}
		@AuraEnabled
		public boolean bHasReadAccess {get;set;}
		//Create and set three variables label, fieldname and type as required by the lightning:datatable
		public DataTableObject(sObject sobjname, boolean bHasRAccess){
			this.sObjectVal     = sobjname;
			this.bHasReadAccess = bHasRAccess;
		}
	}


	/**
	* This method is used to return a list of the labels for the fields
	* @param objectname - Specify the API name of object to get the labels from
	* @param fields - List of fields whose labels we need to return
	*/ 
	@AuraEnabled
	public static List<String> getLabelsAux(String objectname,String relobjectname, List<String> fields) {
		List<String> labelsToShow = new List<String>();

		system.debug('getLabelsAux.   Param1:objectname ' + objectname + ' Param2:relobjectname--> ' + relobjectname + ' Param3:fields ' + fields);

		if(objectname!=null){
			Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
			Schema.SobjectType objSchema    = SchemaMap.get(objectname);
			Schema.SobjectType usrSchema    = SchemaMap.get('UserRecordAccess');
			Schema.SobjectType relobjSchema;
			Map<String, Schema.SObjectField> fieldRelMap;
			if(relobjectname!=null && relobjectname.length()>0){
				relobjSchema = SchemaMap.get(relobjectname);
				fieldRelMap = relobjSchema.getDescribe().fields.getMap();
			}
			Map<String, Schema.SObjectField> fieldObjMap = objSchema.getDescribe().fields.getMap();
			Map<String, Schema.SObjectField> fieldUsrMap = usrSchema.getDescribe().fields.getMap();

			for (String fieldName : fields) {
				if(fieldObjMap.containsKey(fieldName.trim())){
					labelsToShow.add(fieldObjMap.get(fieldName.trim()).getDescribe().getLabel());
				}else if( fieldName == 'Owner.Name'){
					labelsToShow.add(fieldObjMap.get('OwnerId').getDescribe().getLabel());
				}else if( fieldName == 'UserRecordAccess.HasReadAccess'){
					labelsToShow.add(fieldUsrMap.get('HasReadAccess').getDescribe().getLabel());
				}else if (fieldRelMap!=null && !fieldRelMap.isEmpty()){
					system.debug('getLabelsAux.fieldRelMap.indexOf() --> ' + fieldName.indexOf('.')  + ' | ' + fieldName);
					if(fieldName.indexOf('.')> 0){
						String aux = fieldName.trim();
						List<String> lstFieldName = aux.split('\\.');
						if(!lstFieldName.isEmpty()){
							if(lstFieldName.size()>0 && fieldRelMap.containsKey(lstFieldName.get(1))){
								labelsToShow.add(fieldRelMap.get(lstFieldName.get(1)).getDescribe().getLabel());
							}
						}
					}
				}
			}
		}
		return labelsToShow;
	}
	/*
	* @Method          :   setSelect
	* @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
	* @Created         :   17 Jan 2018
	* @Description     :   This apex class returns the list of fields thats will be displayed in Customer Search.
	* @Params          :   sObjectType(String): Type of Object.
	* @Returns         :   string: list of fields to get from the object.
	*/ 
	@AuraEnabled 
	public static String setSelect(String sObjectType){
		if(sObjectType!=null && sObjectType!=''){

			List<CustomerSearchSettings__mdt> lFields = [SELECT SearchFields__c FROM CustomerSearchSettings__mdt where QualifiedApiName = :sObjectType limit 1];

			if(lFields!=null && !lFields.isEmpty()){
				return lFields[0].searchfields__c;
			}else{
				System.debug('The value '+sObjectType+' is not in CustomerSearchSettings__mdt.');
				return null; 
			} 

		}else{
			System.debug('Param null or empty.');
			return null;
		}   
	}
	private static Integer iExecution = 0;
	/**
	* getSecretQuestion -                                                             
	* @param sId            - Record selected
	* @param sObjectType    - Type of record (B2B, B2C or Dealer)
	* @param sObjectName    - Object name
	*/    
	@AuraEnabled
	public static String getSecretQuestion(String sId, String sObjectType, String sObjectName) {
		String sValue = '';
		if(sObjectType!=null && sObjectType!=''){
			List<CustomerSearchSettings__mdt> lstFields = [SELECT SearchFields__c FROM CustomerSearchSettings__mdt where QualifiedApiName = :sObjectType limit 1];            
			if(lstFields!=null && !lstFields.isEmpty()){
				sValue  = lstFields.get(0).searchfields__c;
			} 
		}
		List<String> aux    = sValue.split(',');    
		Integer iQuestion   = SecurityUtilsLib.randomWithLimit(aux.size());
		system.debug('### getSecretQuestion ' + sId + ' | ' + sObjectName + ' | ' + iQuestion  + ' | ' +  aux);

		/* BEGIN - Manuel Medina - C1STRUN-1963 - 15032019 */
		String queryString = 'SELECT '  + String.escapeSingleQuotes(aux.get(iQuestion)) + 
							' FROM '	+ String.escapeSingleQuotes(sObjectName) +
							//' WHERE Id =\''  + String.escapeSingleQuotes(sId) +'\'';
							( sObjectName.equals( 'Account' ) ? ' WHERE Id =\'' + String.escapeSingleQuotes(sId) + '\'' : ' WHERE AccountId =\'' + String.escapeSingleQuotes(sId) + '\'' );
		/* END - Manuel Medina - 15032019 */

		system.debug('### getSecretQuestion ' + queryString);
		List<sObject> sobjList = new List<sObject>();
		try {
			sobjList = database.query(queryString);
		} catch(dmlexception e) {
			system.debug('## getSecretQuestion --> ERROR : ' + e);
			return sValue;
		}
		System.debug('##--> getSecretQuestion.sobjList: ' + sobjList.get(0)); 
		System.debug('##--> getSecretQuestion.aux: ' + aux.get(iQuestion).trim());

		Boolean bRelation   = (aux.get(iQuestion).indexOf('.')>0)?true:false;
		String sRelObj;
		if(bRelation){
			List<String> lstaux    =  aux.get(iQuestion).split('\\.');
			sRelObj                =  lstaux.get(0);
			String sRelFld         =  lstaux.get(1);
			String squeryString    =  'SELECT '  + String.escapeSingleQuotes(sRelFld) + 
									' FROM '   + String.escapeSingleQuotes(sRelObj) +
									' WHERE Id =\''  + String.escapeSingleQuotes((String)sobjList.get(0).get(sRelObj + 'Id')) +'\'';
			System.debug('##--> getSecretQuestion.squeryString: ' + squeryString);
			List<sObject> srelobjList = new List<sObject>();
			try {
				srelobjList = database.query(squeryString);
				System.debug('##--> getSecretQuestion.srelobjList: ' + srelobjList);
				sValue = (String)srelobjList.get(0).get(sRelFld);
			} catch(dmlexception e) {
				system.debug('## getSecretQuestion --> ERROR : ' + e);
				return sValue;
			}
		}else{
			sValue = (String)sobjList.get(0).get(aux.get(iQuestion));
		}

		System.debug('##--> getSecretQuestion.sValue: ' + sValue ); 
		String sOriginalValue   = sValue;
		List<String> lstFields  = new List<String>();
		lstFields.add(aux.get(iQuestion));
		List<String> lstResult = getLabelsAux(sObjectName, sRelObj, lstFields);
		System.debug('##--> getSecretQuestion.lstResult: ' + lstResult );
		if(!lstResult.isEmpty() && sValue!=null && sValue.length()>0){
			if(sValue.indexOf('@')!=-1){
				sValue = sValue.substringBefore('@');
			}else {
				sValue =  (sValue.length()>3)?sValue.left(sValue.length()-3):sValue.left(sValue.length()-1);
			}
			sValue = sValue  +',' + lstResult.get(0) + ',' + SecurityUtilsLib.encryptData(sOriginalValue);
		}else{
			// If not value, let's search for another one till there is one
			// the maximun is the number of questions defined.
			System.debug('##--> iExecution : ' + iExecution + ' Size:' + aux.size());
			if(iExecution<=aux.size()){
				iExecution+=1;
				sValue = getSecretQuestion(sId, sObjectType, sObjectName);
			}
		}
		return sValue;
	}

	/**
	* getQuestionResponse -                                                             
	* @param sValue         - Original value
	* @param sResponse      - User response
	*/
	@AuraEnabled
	public static Boolean getQuestionResponse(String sValue, String sResponse, Id sId, Id sUserId) {     
		Boolean bResult = false;
		if(!String.isEmpty(sValue) && !String.isEmpty(sResponse)){
			sValue = SecurityUtilsLib.decryptData(sValue);
			if(sValue==sResponse){
				bResult = true;
				manualShareRecord(sId, sUserId, 'Read');
				ManualSharingProcess.ManualSharing(ManualSharingProcess.setRecordToShare(sId, sUserId));
			}
		}
		return bResult;
	}
	/**
	* randomWithLimit -                                                             
	* @param upperLimit - Limit ramdom value
	*/
	//public static Integer randomWithLimit(Integer upperLimit){
	//    Integer rand = Math.round(Math.random()*1000);
	//    return Math.mod(rand, upperLimit);
	//}

	public static boolean manualShareRecord(Id recordId, Id userOrGroupId, String sAccessLevel){

		AccountShare accShr           = new AccountShare();
		accShr.AccountId              = recordId;
		accShr.UserOrGroupId          = userOrGroupId;
		accShr.AccountAccessLevel     = sAccessLevel;
		accShr.OpportunityAccessLevel = 'None';
		accShr.CaseAccessLevel        = sAccessLevel; 
		// This line can be omitted as 'manual' is the default value for sharing objects.
		accShr.RowCause               = 'Manual'; 

		// Insert the sharing record and capture the save result. 
		// The false parameter allows for partial processing if multiple records passed 
		// into the operation.
		Database.SaveResult sr        = Database.insert(accShr,false);      
		// Process the save results.
		if(sr.isSuccess()){
			system.debug('sr : ' + sr);
			return true;
		}
		else {
			// Get first save result error.
			Database.Error err = sr.getErrors()[0];
			// Check if the error is related to trival access level.
			// Access level must be more permissive than the object's default.
			// These sharing records are not required and thus an insert exception is acceptable. 
			if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  err.getMessage().contains('AccessLevel')){
				// Indicates success.
				system.debug('sr err : ' + err.getMessage());
				return true;
			}
			else{
				system.debug('sr err : ' + err.getMessage());
				// Indicates failure.
				return false;
			}
		}
	}


	//private static final Blob crypto192Key          = EncodingUtil.base64Decode(PAD.getToken());  
	/**
	* encyptData -                                                             
	* @param decryptedString - String to be encrypted
	*/
	//public static string encryptData(String decryptedString){
	//    String base64EncryptedString = '';
	//    if(decryptedString!=null && decryptedString!=''){
	//        Blob data               = Blob.valueOf(decryptedString);
	//        Blob encryptedBlobData  = Crypto.encryptWithManagedIV('AES192', crypto192Key , data );
	//        base64EncryptedString   = EncodingUtil.base64Encode(encryptedBlobData);
	//    }
	//    return base64EncryptedString;
	//}    
	/**
	* decryptData -                                                            
	* @param encryptedString - SString to be decrypted
	*/
	//public static string decryptData(String encryptedString){
	//    String decryptedString  ='';
	//    if(encryptedString!=null && encryptedString!=''){
	//        Blob data               = EncodingUtil.base64Decode(encryptedString);
	//        Blob decryptedBlobData  = Crypto.decryptWithManagedIV('AES192', crypto192Key , data);
	//        decryptedString         = decryptedBlobData.toString();
	//    }
	//    return decryptedString;
	//}
}
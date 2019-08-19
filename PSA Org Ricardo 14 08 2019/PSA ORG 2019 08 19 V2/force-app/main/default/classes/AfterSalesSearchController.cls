/**
*   @Class          :   AfterSalesSearchController.cls
*   @Author         :   Ruben Fernandez Lopez
*   @Created        :   17 Jan 2018
*   @Description    :   Apex Controller class for LC002_CustomerSearch.cmo
*
*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Author               Date                     Description
*    Rubén Fernandez      18/1/2018        Creation.
*   ----------------------------------------------------------------------------------------------------------------------------
**/
public without sharing class AfterSalesSearchController {

	private static final String GLOBAL_SOSL_FIND					= 'FIND {';
	private static final String GLOBAL_SOSL_BODY					= '} IN ALL FIELDS Returning ';
	private static final String GLOBAL_SOQL_SELECT					= 'SELECT ';
	private static final String GLOBAL_SOQL_FROM					= ' FROM ';
	private static final String GLOBAL_SOQL_WHERE					= ' WHERE ';
	private static final String GLOBAL_SOQL_WHERECOUNTRY			= 'TECH_AccountCountry__c =: sUserCountry AND ';
	private static final String GLOBAL_SOQL_ORDER					= ' ORDER BY ';
	private static final String GLOBAL_SOQL_ORDERFIELD				= 'AssetId__r.LastKnownRegistrationNumber__c ASC NULLS LAST,AccountRole__c ASC NULLS LAST LIMIT 100';
	private static final String GLOBAL_SOQL_OBJECT					= 'AccountContactAssetRelation';
	private static final String GLOBAL_CMT_SOQLORDER				= 'QueryOrder';
	private static final String GLOBAL_SOSL_LIMIT					= ' LIMIT 200';
	private static final String FIELD_ASSET							= 'AssetId__c';
	private static final String FIELD_ACCOUNT						= 'AccountId__c';
	private static final String FIELD_ACCOUNTROLE					= 'AccountRole__c';
	private static final String FIELD_RELATION						= 'Id';
	private static final String EXT_RELATION						= '__r';
	private static final String EXT_FIELD							= '__c';
	private static final String GLOBAL_SOQL_AND						= ' AND ';
	private static final String GLOBAL_SOQL_OR						= ' OR ';
	private static final String GLOBAL_SOQL_COND0					= 'Id IN: lstRecords';
	private static final String sUserCountry						= PAD.sUserCountry;

	private static final Integer RECENT_WORKSHOP_VISIT_DAYS			= 1;

	private static Map<String, String> mapDrawFields				= new Map <String,String>();
	private static Map<String, String> mapObjectFields				= new Map <String,String>();
	private static map<String, String> mapSourceSystemCodeByType	= new Map <String,String>{
																		'QR'				=> '1',
																		'APPOINTMENT'		=> '2',
																		'OLB_APPOINTMENT'	=> '3'
																	};

	/*********************************************************************************************************
	* @Method          :   getfetchRecords
	* @Author          :   Rubén Fernandez Lopez
	* @Created         :   23/02/2018
	* @Description     :   Find all records in the system that match user's criteria.
	* @paramsArray     :   String. First search term(s).
	*     			   :   String. Second search term(s).
	*     			   :   Boolean. True, Extended search, False simply search (default)
	* @Returns         :   Full table with all records found. Records are securized before return them.
	**********************************************************************************************************/
	@AuraEnabled	
	public static DataTableResponse getfetchRecords(String searchCriteria1, String searchCriteria2, Boolean bFilter){
		System.debug('START getfetchRecords: --> 1º) searchCriteria1 : ' + searchCriteria1 + ' 2º) searchCriteria2 : ' + searchCriteria2);

		searchCriteria1							= String.isNotBlank( searchCriteria1 ) ? searchCriteria1.normalizeSpace() : searchCriteria1;
		searchCriteria2							= String.isNotBlank( searchCriteria2 ) ? searchCriteria2.normalizeSpace() : searchCriteria2;

		String sObjectName                      = GLOBAL_SOQL_OBJECT + EXT_FIELD;
		String  queryStringWhere                ='';
		Set<Id> lstRecords                      = new Set<Id>();
		List<String> whereSOSL                  = new List<String>();
		List<String> sQueryWhere                = new List<String>();
		List<SObject> lstObjectResult           = new List<sObject>();
		List<SObject> lstAux                    = new List<SObject>();
		List<SObject> lstAuxB                   = new List<SObject>();

		if(!String.isEmpty(searchCriteria1)){
			whereSOSL.addAll(fixValues(searchCriteria1));

		}if(!String.isEmpty(searchCriteria2)){
			whereSOSL.addAll(fixValues(searchCriteria2));
		}

		loadConfigData(sObjectName);

		String sNewQuery 						= '';
		for(String sObjFields : mapObjectFields.keySet()){
			if (sObjFields == sObjectName){
				sNewQuery  = String.escapeSingleQuotes(String.valueof(mapObjectFields.get(sObjFields)));
			}
		}

		sQueryWhere.add(sObjectName + ' ('+ sNewQuery + ')');
		String  sQuerySOSL                      = GLOBAL_SOSL_FIND + String.join(whereSOSL,GLOBAL_SOQL_AND) + GLOBAL_SOSL_BODY + String.join(sQueryWhere,' , ') + GLOBAL_SOSL_LIMIT;
		
		try {
			if(!whereSOSL.isEmpty()){
				List<List<SObject>>searchList   = search.query(sQuerySOSL);
				if(!searchList.isEmpty()){
					for(Integer iPos = 0; iPos<searchList.size() ;iPos++ ){
						lstObjectResult.addAll(searchList.get(iPos));
					}
				}
			}
		} catch(DMLException e) {
			System.debug('STEP3 --> DML Error : ' + e.getMessage());
		} catch (Exception e){
			System.debug('STEP3 --> Exception : ' + e.getMessage());
		}

		for (sObject o : lstObjectResult){
			Map<String, Object> fieldsToValue = o.getPopulatedFieldsAsMap();
			if(!lstRecords.contains(o.Id)){
				lstRecords.add(o.Id);
			}
		}

		queryStringWhere                    	= GLOBAL_SOQL_COND0;
		String sAuxWhere                        = (string.isEmpty(queryStringWhere))?'':GLOBAL_SOQL_WHERE + GLOBAL_SOQL_WHERECOUNTRY + queryStringWhere;
		String queryString                      = GLOBAL_SOQL_SELECT + mapDrawFields.get(sObjectName).replace( FIELD_ACCOUNTROLE, 'toLabel( ' +FIELD_ACCOUNTROLE + ' )' ) +
		GLOBAL_SOQL_FROM + String.escapeSingleQuotes(sObjectName) +
		sAuxWhere + GLOBAL_SOQL_ORDER + GLOBAL_SOQL_ORDERFIELD;

		try {
			if( String.isNotBlank( sAuxWhere ) ){
				lstAux                           = database.query(queryString);
				if(bFilter){
					List<String> auxID           = new List<String>();
					for(sObject o : lstAux ){
						auxID.add(String.valueof(o.get(FIELD_ASSET)));
					}
					queryString                  = GLOBAL_SOQL_SELECT + mapDrawFields.get(sObjectName).replace( FIELD_ACCOUNTROLE, 'toLabel( ' +FIELD_ACCOUNTROLE + ' )' ) +
					GLOBAL_SOQL_FROM + String.escapeSingleQuotes(sObjectName) +
					GLOBAL_SOQL_WHERE + FIELD_ASSET + ' IN: auxID' + GLOBAL_SOQL_ORDER + GLOBAL_SOQL_ORDERFIELD;
					System.debug('STEP6. Advance Query: ' + queryString );
					lstAuxB                      = database.query(queryString);
					if(!lstAuxB.isEmpty()){
						lstAux.clear();
						lstAux.addAll(lstAuxB);
					}
				}

				if(lstAux!=null && !lstAux.isEmpty()){
					for(sObject o : lstAux ){
						if(!lstRecords.contains(o.Id) && lstRecords.size()<200){
							lstRecords.add(o.Id);
						}
					}
				}
			}
		} catch(dmlexception e) {
			system.debug('STEP6. --> DML Error : ' + e.getMessage());
		} catch (Exception e){
			System.debug('STEP6. --> Exception : ' + e.getMessage());
		}

		return formatResponse(lstRecords,lstAux,sObjectName);
	}

	/*********************************************************************************************************
	* @Method          :   fixValues
	* @Author          :   Rubén Fernandez Lopez
	* @Created         :   23/02/2018
	* @Description     :   SOSL search term adjusted.
	* @Params          :   Search term.
	* @Returns         :   List of values adjustes.
	**********************************************************************************************************/
	private static List<String> fixValues(String sValue){
		List<String> lstValues = new List<String>();
		if(!String.isEmpty(sValue)){
			List<String> lstAuxValues = sValue.split('\\ ');
			for(Integer i = 0;i<lstAuxValues.size();i++){
				lstValues.add(SecurityUtilsLib.escapeSOSL(String.valueOf(lstAuxValues.get(i))) + '*');
			}
		}
		return lstValues;
	}

	/*********************************************************************************************************
	* @Method          :   loadConfigData
	* @Author          :   Rubén Fernandez Lopez
	* @Created         :   24/12/2018
	* @Description     :   pre-load config data into 2 maps
	* @Params          :   String. Object API Name
	* @Returns         :   void
	**********************************************************************************************************/
	private static void loadConfigData(String sObjectName){
		for(CustomerSearchSettings__mdt aux : [SELECT SearchFields__c,QualifiedApiName FROM CustomerSearchSettings__mdt where QualifiedApiName Like 'AS0%' Order by QualifiedApiName ASC limit 10]){
			String sObj = aux.QualifiedApiName;
			if(sObj.right(sObj.length() - (sObj.indexof('0')+2))!= GLOBAL_CMT_SOQLORDER){
				if(sObj.right(sObj.length() - (sObj.indexof('0')+2)) == GLOBAL_SOQL_OBJECT){
					mapObjectFields.put(sObj.right(sObj.length() - (sObj.indexof('0')+2)) + EXT_FIELD, aux.searchfields__c ); 
				}else{
					mapObjectFields.put(sObj.right(sObj.length() - (sObj.indexof('0')+2)), aux.searchfields__c );
				}
			}else{
				mapDrawFields.put(sObjectName, aux.searchfields__c );
			}
		}
	}

	/*********************************************************************************************************
	* @Method          :   getDataTableColumns
	* @Author          :   Rubén Fernandez Lopez
	* @Created         :   24/12/2018
	* @Description     :   Used to compose the datatable columns 
	* @Params          :   String. Object API Name
	* @Returns         :   List of Datatable Columns
	**********************************************************************************************************/
	private static List<DataTableColumns> getDataTableColumns(String sObjectName){
		List<DataTableColumns> lstTableColumn   = new List<DataTableColumns> ();
		String sNewObject                       = sObjectName;
		DescribeSObjectResult objResult         = Schema.getGlobalDescribe().get(sObjectName).getDescribe(); 
		DescribeSObjectResult objResultAux;
		DescribeFieldResult fieldResultAux;
		for(String field :(List<String>)String.valueOf(mapDrawFields.values()).split(',')){
			field = field.replaceAll( '\\(', '' ).trim();
			field = field.replaceAll( '\\)', '' ).trim();
			if(field.indexof('.')>0){
				String sVal                     = '';
				List<String> auxobj             = field.split('\\.');
				if (field.indexof(EXT_RELATION)>0){
					sVal                        = String.valueof(auxobj.get(0));
					sNewObject                  = sVal.left(sVal.length()-5);
				}else{
					sNewObject                  = auxobj.get(0);
				}
				objResultAux                	= Schema.getGlobalDescribe().get(sNewObject.trim()).getDescribe();
				fieldResultAux                  = objResultAux.fields.getMap().get(auxobj.get(1)).getDescribe();		
			}else{
				fieldResultAux                  = objResult.fields.getMap().get(field).getDescribe();			
			}
			lstTableColumn.add(new DataTableColumns(fieldResultAux.getLabel(),fieldResultAux.getName(),String.valueof(fieldResultAux.getType()).toLowerCase(),true,false));
		}
		return lstTableColumn;
	}

	/*********************************************************************************************************
	* @Method          :   formatResponse
	* @Author          :   Rubén Fernandez Lopez
	* @Created         :   24/12/2018
	* @Description     :   Used to compose the datatable 
	* @Params          :   String. Object API Name
	*				   :   Set< Id >. Set of Records found. Used to verify record visibility level. 
	*				   :   List< SObject > All results found.
	* @Returns         :   Full data table (Columns & Data)
	**********************************************************************************************************/	
	private static DataTableResponse formatResponse(Set<Id> lstRecords, List<SObject> lstAux, String sObjectName){
		DataTableResponse ltngTableWrapper      = new DataTableResponse(); 				// Final lightning datatable
		List<DataTableObject> lstValues         = new List<DataTableObject>();          // Wrapper to add to final response
		List<DataTableObjectWrapper> lstValuesW = new List<DataTableObjectWrapper>();   // Wrapper to add to final response

		try {
			Map<Id,UserRecordAccess> mapAux     = new Map<Id,UserRecordAccess>([SELECT RecordID,HasReadAccess FROM UserRecordAccess WHERE UserId = : UserInfo.getUserId() AND RecordID IN :lstRecords]);
			for(sObject o : lstAux ){
				String sId                      = String.valueof(o.get(FIELD_RELATION));
				String sIdObj1                  = String.valueof(o.get(FIELD_ACCOUNT));
				List<DataTableField>lstFieldsWrapper        = new List<DataTableField>();
				for(String sField : (List<String>)String.valueOf(mapDrawFields.values()).split(',')){
					if(sField.indexOf('HasReadAccess')<0){
						String sFieldValue      = '';
						String sNewObj          = '';
						List<String> auxobj;
						Boolean bAcc2           = (mapAux.containsKey(sId))?mapAux.get(sId).HasReadAccess:false;
						Boolean bAcc1           = (mapAux.containsKey(sIdObj1))?mapAux.get(sIdObj1).HasReadAccess:bAcc2;
						if(sField.indexOf('Name')<0 && !bAcc1){
							if (sField.indexof(EXT_RELATION)>0){
								auxobj          = sField.split('\\.');
								sNewObj         = String.valueof(auxobj.get(0));
								sFieldValue     = String.valueOf(o.getSObject(SecurityUtilsLib.escapeText(sNewObj)).get(auxobj.get(1)));
								if(sField.indexof('AssetId')<0){
									sFieldValue = SecurityUtilsLib.setMask(sFieldValue);
								}
							}else{
								sFieldValue     = String.valueof(o.get(sField));
							}
						}else{
							if (sField.indexof(EXT_RELATION)>0){
								auxobj          = sField.split('\\.');
								sNewObj         = String.valueof(auxobj.get(0));
								sFieldValue     = String.valueOf(o.getSObject(SecurityUtilsLib.escapeText(sNewObj)).get(String.valueOf(auxobj.get(1))));
							}else{
								sFieldValue     = String.valueof(o.get(sField));
							}
						}
						lstFieldsWrapper.add( new DataTableField(SecurityUtilsLib.escapeText(sField),sFieldValue));
					}  
				}
				lstFieldsWrapper.add( new DataTableField(FIELD_RELATION,sId));
				lstFieldsWrapper.add( new DataTableField(FIELD_ACCOUNT,sIdObj1));
				lstFieldsWrapper.add( new DataTableField(FIELD_ASSET,String.valueof(o.get(FIELD_ASSET))));
				Boolean bAccess2                = (mapAux.containsKey(sId))?mapAux.get(sId).HasReadAccess:false;
				Boolean bAccess1                = (mapAux.containsKey(sIdObj1))?mapAux.get(sIdObj1).HasReadAccess:bAccess2;
				lstFieldsWrapper.add( new DataTableField('UserRecordAccess.HasReadAccess',String.valueOf(bAccess1)));
				lstValues.add(new DataTableObject(o,bAccess1));
				lstValuesW.add(new DataTableObjectWrapper(lstFieldsWrapper ,bAccess1));
			}

			ltngTableWrapper.lstDataTableData       = lstValues;
			ltngTableWrapper.lstDataTableDataW      = lstValuesW;
			ltngTableWrapper.lstDataTableColumns    = getDataTableColumns(sObjectName);

		} catch(dmlexception e) {
			system.debug('formatResponse --> DML Error : ' + e.getMessage());
		} catch (Exception e){
			System.debug('formatResponse--> Exception : ' + e.getMessage());
		}

		return ltngTableWrapper;
	}

	/*
	* @Method          :   DataTableResponse
	* @Author          :   Rubén Fernandez Lopez
	* @Created         :   23/02/2018
	* @Description     :   Wrapper class to hold Columns & Data
	*/
	public class DataTableResponse {
		@AuraEnabled
		public List<DataTableColumns> lstDataTableColumns {get;set;}
		@AuraEnabled         
		public List<DataTableObject> lstDataTableData {get;set;}
		@AuraEnabled         
		public List<DataTableObjectWrapper> lstDataTableDataW {get;set;}
		public DataTableResponse(){
			lstDataTableColumns     = new List<DataTableColumns>();
			lstDataTableData        = new List<DataTableObject>();
			lstDataTableDataW       = new List<DataTableObjectWrapper>();
		}
	}

	public class DataTableColumns {
		@AuraEnabled
		public String label {get;set;}
		@AuraEnabled       
		public String fieldName {get;set;}
		@AuraEnabled
		public String type {get;set;}
		@AuraEnabled
		public Boolean sortable {get;set;}
		public DataTableColumns(String label, String fieldName, String sType,Boolean bSortable, Boolean bAttributes){ //, DataTableColumnsLink dtcAttributes){
			this.label      = label;
			this.fieldName  = fieldName;
			this.type       = sType; 
			this.sortable   = bSortable;
		}
	}

	public class DataTableObject {
		@AuraEnabled
		public sObject sObjectVal {get;set;}
		@AuraEnabled
		public boolean bHasReadAccess {get;set;}
		public DataTableObject(sObject sobjname, boolean bHasRAccess){
			this.sObjectVal     = sobjname;
			this.bHasReadAccess = bHasRAccess;
		}
	}

	public class DataTableObjectWrapper {
		@AuraEnabled
		public List<DataTableField> lstWrapperVal {get;set;}
		@AuraEnabled
		public boolean bHasReadAccess {get;set;}
		public DataTableObjectWrapper(List<DataTableField> lstFields, boolean bHasRAccess){
			this.lstWrapperVal   = lstFields;
			this.bHasReadAccess  = bHasRAccess;
		}
	}

	public class DataTableField {
		@AuraEnabled
		public String fieldName {get;set;}
		@AuraEnabled
		public String fieldvalue {get;set;}
		//Create and set three variables label, fieldname and type as required by the lightning:datatable
		public DataTableField(String sfieldname, String svalue){
			this.fieldName  = sfieldname;
			this.fieldvalue = String.isEmpty(svalue)?'':svalue;
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
			}
			else{
				System.debug('The value '+sObjectType+' is not in CustomerSearchSettings__mdt.');
				return null; 
			} 
		}else{
			System.debug('Param null or empty.');
			return null;
		}   
	}

	private static Integer iExecution = 0;
	private static Integer iSourcePos = 0;
	private static Boolean bFound 	  = false;

	/**
	* getSecretQuestion -                                                             
	* @param sId            - Record selected
	* @param sObjectType    - Type of record (B2B, B2C or Dealer)
	* @param sObjectName    - Object name
	*/    
	@AuraEnabled
	public static String getSecretQuestion(String sId, String sObjectType, String sObjectName) {

		List<sObject> sobjList                          = new List<sObject>();
		List<String> lstFields                          = new List<String>();
		String sValue                                   = '';
		String sRelObj;

		if(sObjectType!=null && sObjectType!=''){
			List<CustomerSearchSettings__mdt> lsAuxtFields = [SELECT SearchFields__c FROM CustomerSearchSettings__mdt where QualifiedApiName = :sObjectType limit 1];
			if(lsAuxtFields!=null && !lsAuxtFields.isEmpty()){
				sValue                                  = lsAuxtFields.get(0).searchfields__c;
			} 
		}
		List<String> aux                                = sValue.split(',');
		Integer iQuestion								= 0;
		if(iExecution==0){
			iQuestion                               	= SecurityUtilsLib.randomWithLimit(aux.size());
		}else{
			iQuestion									= (iSourcePos<aux.size()-1)?iSourcePos+1:0;
		}
		iSourcePos										= iQuestion;

		String queryString                              = 'SELECT '         + String.escapeSingleQuotes(aux.get(iQuestion)) + 
		' FROM '         + String.escapeSingleQuotes(sObjectName) +
		' WHERE Id =\''  + String.escapeSingleQuotes(sId) +'\'';

		try {
			sobjList                                    = database.query(queryString);
		} catch(dmlexception e) {
			system.debug('## getSecretQuestion --> ERROR : ' + e);
			return sValue;
		}
		
		Boolean bRelation                               = (aux.get(iQuestion).indexOf('.')>0)?true:false;

		if(bRelation){
			List<String> lstaux                         =  aux.get(iQuestion).split('\\.');
			sRelObj                                     =  lstaux.get(0);
			String sRelFld                              =  lstaux.get(1);
			String squeryString                         =  'SELECT '  + String.escapeSingleQuotes(sRelFld) + 
			' FROM '   + String.escapeSingleQuotes(sRelObj) +
			' WHERE Id =\''  + String.escapeSingleQuotes((String)sobjList.get(0).get(sRelObj + 'Id')) +'\'';
			List<sObject> srelobjList                   = new List<sObject>();
			try {
				srelobjList                             = database.query(squeryString);
				System.debug('##--> getSecretQuestion.srelobjList: ' + srelobjList);
				sValue                                  = (String)srelobjList.get(0).get(sRelFld);
			} catch(dmlexception e) {
				system.debug('## getSecretQuestion --> ERROR : ' + e);
				return sValue;
			}

		}else{
			if(!sobjList.isEmpty()){
				sValue = (String)sobjList.get(0).get(aux.get(iQuestion));
			}else{
				sValue = '';
			}
		}
		String sOriginalValue                           = sValue;
		lstFields.add(aux.get(iQuestion));

		if(String.isNotBlank(sValue)){
			List<String> lstResult                      = getLabelsAux(sObjectName, sRelObj, lstFields);
			if(sValue.indexOf('@')!=-1){
				sValue                                  = sValue.substringBefore('@');
			}else {
				sValue                                  =  (sValue.length()>3)?sValue.left(sValue.length()-3):sValue.left(sValue.length()-1);
			}
			sValue                                      = sValue  +',' + lstResult.get(0) + ',' + SecurityUtilsLib.encryptData(sOriginalValue);
			bFound 										= true;
		}else{
			if(iExecution<=aux.size()){
				iExecution                             += 1;
				sValue                                  = getSecretQuestion(sId, sObjectType, sObjectName);
			}else{
				if (String.isBlank(sValue) && iExecution<aux.size()+2 && !bFound){
					iExecution                          = 0;
					sValue                              = getSecretQuestion(sId, 'SecretQuestionFieldsASPublic', sObjectName);
				}
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
				ManualSharingProcess.ManualSharing(ManualSharingProcess.setRecordToShare(sId, sUserId));
				bResult = true;
			}
		}
		return bResult;
	}

	@AuraEnabled
	public static FieldResponse getselectOptions(sObject objObject, string fld) {
		FieldResponse ltngTableWrapper              = new FieldResponse();

		List<FieldOptions> lstValues                = new List<FieldOptions>();
		List <String> allOpts                       = new list <String>();
		Schema.sObjectType objType                  = objObject.getSObjectType();
		Schema.DescribeSObjectResult objDescribe    = objType.getDescribe();
		MAP <String, Schema.SObjectField> fieldMap  = objDescribe.fields.getMap();
		list < Schema.PicklistEntry > values        = fieldMap.get(fld).getDescribe().getPickListValues();
		for (Schema.PicklistEntry a: values) {
			lstValues.add(new FieldOptions(a.getValue(),a.getLabel()));
			allOpts.add(a.getValue());
		}
		ltngTableWrapper.lstOptions                 = lstValues;
		return ltngTableWrapper;
	}

	@AuraEnabled
	public static String setAccountRoleValue(String sRecordId, string sValue,Boolean bValue) {
		String bResult = 'true';
		System.debug('setAccountRoleValue: Record: ' + sRecordId + ' | Value: ' + sValue + ' | Flag: ' + bValue);

		try {
			List<AccountContactAssetRelation__c> lstAux = new List<AccountContactAssetRelation__c>([SELECT AccountRole__c,PosessionChangeConfirmation__c FROM AccountContactAssetRelation__c WHERE Id =:sRecordId]);
			if(!lstAux.isEmpty()){
				if(!String.isEmpty(sValue)){
					lstAux.get(0).AccountRole__c = sValue;
					lstAux.get(0).PosessionChangeConfirmation__c = bValue;
				}
			}
			update lstAux;
		} catch(DmlException e) {
			bResult = e.getMessage();
			System.debug('An unexpected error has occurred: ' + e.getMessage());
		}
		return bResult;
	}

	@AuraEnabled
	public static String setAccountAssetRelationship(String sAssetId, string sAccuntId,string sRoleName,boolean bUpdate) {
		String bResult = 'true';
		System.debug('setAccountAssetRelationship: AssetId: ' + sAssetId  + ' | Account: ' + sAccuntId+ ' | Role: ' + sRoleName + ' | bUpdate: ' + bUpdate);
		try {
			AccountContactAssetRelation__c bAux = new AccountContactAssetRelation__c(AccountId__c = sAccuntId, AssetId__c = sAssetId , AccountRole__c =sRoleName, PosessionChangeConfirmation__c=bUpdate);
			Insert bAux;
		} catch(DmlException e) {
			bResult = e.getMessage();
			System.debug('An unexpected error has occurred: ' + e.getMessage());
		}
		return bResult;
	}

	/*********************************************************************************************************
	* @Method          :   insertWorkshopAppointment
	* @Author          :   Manuel Medina
	* @Created         :   02/07/2019
	* @Description     :   Creates a new workshop appointment based on given data.
	* @Params          :   Id r, Boolean blnIsQuickReception, String strMyOResponse
	* @Returns         :   Map<String, Object>
	**********************************************************************************************************/
	@AuraEnabled
	public static Map<String, Object> insertWorkshopAppointment( Id idRelation, Boolean blnIsQuickReception, String strMyOResponse ) {
		Map<String, Object> mapResponse										= new Map<String, Object>{
																				'hasError'			=> false,
																				'ERROR'				=> '',
																				'appBookedToday'	=> false
																			};
		
		try{
			Map<String, Object> mapMyOAttributeByName						= new Map<String, Object>();
			Map<String, Object> mapAppointmetParamByName					= new Map<String, Object>();

			if( String.isNotBlank( strMyOResponse ) ){
				mapMyOAttributeByName										= ( Map<String, Object> ) JSON.deserializeUntyped( strMyOResponse );
				mapAppointmetParamByName									= ( Map<String, Object> ) mapMyOAttributeByName.get( 'paramsArray' );
			}

			String strEntityType											= !blnIsQuickReception && mapMyOAttributeByName.containsKey( 'EntityType' ) ? String.valueOf( mapMyOAttributeByName.get( 'EntityType' ) ) : 'QR';

			WorkshopAppointment__c objAppointment							= new WorkshopAppointment__c();
			objAppointment.TECH_AccountAssetRelation__c						= idRelation;
			objAppointment.AppointmentStatus__c								= '1';
			objAppointment.AppointmentSystemCreation__c						= mapSourceSystemCodeByType.containsKey( strEntityType ) ? mapSourceSystemCodeByType.get( strEntityType ) : '2';
			
			bookingDefaults( objAppointment );
			
			List<WorkshopAppointment__c> lstQuickReceptionBooked			= new List<WorkshopAppointment__c>( [
																				SELECT Id
																				FROM WorkshopAppointment__c
																				WHERE Owner__c =: objAppointment.Owner__c
																				AND Asset__c =: objAppointment.Asset__c
																				AND AppointmentType__c = '5'
																				AND AppointmentStatus__c = '2'
																				AND ReceptionDatetime__c = TODAY
																			] );

			if( !blnIsQuickReception || lstQuickReceptionBooked.isEmpty() ){
				for( String key : mapAppointmetParamByName.keySet() ){
					switch on key {
						when 'appointmentId' {
							objAppointment.AppointmentSBId__c				= ( String ) mapAppointmetParamByName.get( key );
						}

						when 'receptionDateTime' {
							objAppointment.ReceptionDatetime__c				= Datetime.valueOf( ( ( String ) mapAppointmetParamByName.get( key ) ).replaceFirst( '(?<=\\d)T(?=\\d)', ' ' ) );
						}
					}
				}
		
				if( blnIsQuickReception ){
					objAppointment.AppointmentStatus__c						= '2';
					objAppointment.AppointmentType__c						= '5';
					objAppointment.ReceptionDatetime__c						= System.now();
					objAppointment.AppointmentSBId__c						= System.now().format( 'ddMMyyyyHHmmssSSS' ) + String.valueOf( idRelation ).right( 3 );
				}

				if( blnIsQuickReception || strEntityType.equalsIgnoreCase( 'OLB_APPOINTMENT' ) ){
					objAppointment.TECH_SBConfirmation__c					= true;
				}

				insert objAppointment;

				mapResponse.put( 'Id', objAppointment.Id );
		
			}else{
				mapResponse.put( 'appBookedToday', true );
			}

			return mapResponse;
			
		}catch( Exception e ){
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
			
			return mapResponse;
		}
	
		return null;
	}

	private static void bookingDefaults(WorkshopAppointment__c w) {
		AccountContactAssetRelation__c a = [
			SELECT Id, AccountId__c, AssetId__c, AssetId__r.RealMileage__c
			FROM AccountContactAssetRelation__c
			WHERE Id = :w.TECH_AccountAssetRelation__c
		];
		
		w.RealMileage__c				= a.AssetId__c != null && a.AssetId__r.RealMileage__c != null ? a.AssetId__r.RealMileage__c : 0;

		for (AccountContactAssetRelation__c r : [
			SELECT Id, AccountRole__c, AccountId__c, AssetId__r.Brand__c, AssetId__c
			FROM AccountContactAssetRelation__c
			WHERE AssetId__c = :a.AssetId__c
			ORDER BY LastModifiedDate DESC
		]) {
			if (r.Id == w.TECH_AccountAssetRelation__c) {
				w.Driver__c = r.AccountId__c;
				w.Asset__c = r.AssetId__c;
			}

			if (r.AccountRole__c == 'APV_Payer' && null == w.APVPayer__c) {
				w.APVPayer__c = r.AccountId__c;
			}

			if (r.AccountRole__c == 'Owner' && null == w.Owner__c) {
				w.Owner__c = r.AccountId__c;
			}

			if (null != r.AssetId__r.Brand__c && null == w.Brand__c) {
				w.Brand__c = r.AssetId__r.Brand__c;
			}

			if (
				null != w.APVPayer__c &&
				null != w.Owner__c &&
				(
					null != w.Brand__c ||
					null == r.AssetId__r.Brand__c
					)
				) {
				break;
			}
		}

		User u = [
			SELECT Id, Contact.AccountId, Contact.Account.CurrencyIsoCode, CurrencyIsoCode
			FROM User
			WHERE Id = :UserInfo.getUserId()
		];

		if (null != u.Contact.AccountId) {
			w.Workshop__c = u.Contact.AccountId;
		}

		if (null != u.Contact.Account.CurrencyIsoCode) {
			w.CurrencyIsoCode = u.Contact.Account.CurrencyIsoCode;
			return;
		}

		if (null != u.CurrencyIsoCode) {
			w.CurrencyIsoCode = u.CurrencyIsoCode;
			return;
		}

		w.CurrencyIsoCode = UserInfo.getDefaultCurrency();
		return;
	}

	/*
	* @Method          :   Wrapper: DataTableResponse
	* @Author          :   Rubén Fernandez Lopez
	* @Created         :   23/02/2018
	* @Description     :   Wrapper class to hold header results
	*/ 
	public class FieldResponse {
		@AuraEnabled
		public List<FieldOptions> lstOptions {get;set;}

		public FieldResponse(){
			lstOptions        = new List<FieldOptions>();
		}
	}

	public class FieldOptions {
		@AuraEnabled
		public String Field {get;set;}
		@AuraEnabled
		public String Value  {get;set;}

		public FieldOptions(String Field,String Value){
			this.Field          = Field;
			this.Value          = Value;
		}
	}

	/*********************************************************************************************************
	* @Method          :   DMSWakeUpbyCORS
	* @Author          :   Rubén Fernandez Lopez
	* @Created         :   12/12/2018
	* @Description     :   Find all records in the system that match user's criteria.
	* @paramsArray     :   String. DMS call type (Only 1 is a valid value)
	* @Returns         :   Map< String,String >. Return map to compose CORS call
	**********************************************************************************************************/
	@AuraEnabled        
    public static Map<String,String> DMSWakeUpbyCORS(String sType){
        Map<String,String>  sCORS = new Map<String,String>();
        if(PAD.sUserDMSType=='1'){
           sCORS.put('body', 	SAPIWebhook.getRequestParams());
           sCORS.put('endpoint', SAPIWebhook.getFinalURL(PAD.sURLDMS,null));
        }
        return sCORS;
    }
}
public with sharing class DMSearchController {
	/**
	*   @Class          :   DMSearchController.cls
	*   @Author         :   Ruben Fernandez Lopez
	*   @Created        :   17 Jan 2018
	*   @Description    :   
	*
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Author             Date             Description
	*    Ruben Fernandez      18/1/2018        Creation.
	*   ----------------------------------------------------------------------------------------------------------------------------
	**/
   
	private static final String GLOBAL_SOQL_OBJECT              = 'Contact';
	private static final String GLOBAL_CMT_SOQLORDER            = 'ContactResult';
    //private static final String GLOBAL_SOSL_LIMIT            	= ' LIMIT 200';
    
	private static final String GLOBAL_SOQL_WHERE               = ' WHERE ';
	private static final String GLOBAL_SOQL_AND                 = ' AND ';

	private static final String GLOBAL_SOQL_B2C               	= '(Account.IsPersonAccount=true)';
	private static final String GLOBAL_SOQL_B2B               	= '((Professional__c = true AND Account.IsPersonAccount = true) OR Account.IsPersonAccount = false)';

	private static final Set<Id> CAMPAIGN_MEMBERS				= new Set<Id>();
	private static List<SObject> GLOBAL_RESULTS           		= new List<sObject>();
	private static String sCampaignChannel 						= '';
	private static String sCampaignType 						= '';

	/*
	* @Method          :   fixValues
	* @Author          :   Ruben Fernandez Lopez
	* @Created         :   23/02/2018
	* @Description     :   
	* @Params          :   
	* @Returns         :   
	*/ 
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
	/*
	* @Method          :   findRecords
	* @Author          :   Ruben Fernandez
	* @Created         :   23/11/2018
	* @Description     :   
	* @Params          :   
	* @Returns         :   
	*/ 
	@AuraEnabled 
	public static DataTableResponse findRecords(String searchCriteria1, String searchCriteria2, 
		String searchCriteria3, String searchCriteria4, String searchFilterF, String searchFilterD,
		String searchFilterC, String recordId, Boolean bFilter){ 
		System.debug('START findRecords: --> 1º) searchCriteria1 : ' + searchCriteria1 + 
			' 2º) searchCriteria2 : ' +  searchCriteria2 + 
			' 3º) searchCriteria3 : ' + searchCriteria3 + 
			' 4º) searchCriteria4 : ' + searchCriteria4 + 
			' 5º) searchFilterF : ' + searchFilterF +
			' 6º) searchFilterD : ' + searchFilterD +
			' 7º) searchFilterC : ' + searchFilterC +
			' 8º) recordId : ' 		+ recordId +
			' 9º) bFilter : '		+ bFilter);

		// DECLARING VARS
		String sObjectName                      = GLOBAL_SOQL_OBJECT;
		String sFieldstoget                     = '';

		Map <String,String> mapObjectFields     = new Map <String,String>();
		Map <String,String> mapDrawFields       = new Map <String,String>();
		List<String> whereSOSL                  = new List<String>();
		List<String> whereSOSLFLD01             = new List<String>();
		List<String> whereSOSLFLD02             = new List<String>();
		List<String> whereSOSLFLD03             = new List<String>();
		List<String> whereSOSLFLD04             = new List<String>();
		List<DataTableColumns> lstTableColumn   = new list<DataTableColumns> ();
		List<String> lstfinalfields             = new List<String>();
		List<String> sQueryWhere                = new List<String>();
		List<SObject> lstObjectResult           = new List<sObject>();
		Set<Id> lstRecords                      = new Set<Id>();
		Set<Id> lstAuxSOSLWhere                 = new Set<Id>();
		Map<Integer,List<String>> mapSOSL 		= new Map <Integer,List<String>>();
		List<SObject> lstLastRecords            = new List<SObject>();
		List<DataTableObject> lstValues         = new List<DataTableObject>();          // Wrapper to add to final response
		List<DataTableObjectWrapper> lstValuesW = new List<DataTableObjectWrapper>();   // Wrapper to add to final response
		DataTableResponse ltngTableWrapper      = new DataTableResponse();              // Returned data
		List<SObject> lstAux                    = new List<SObject>();
		List<SObject> lstAuxB                   = new List<SObject>();
		
		DescribeSObjectResult objResultAux;
		DescribeFieldResult fieldResultAux;
		
		// STEP 0: Making sure values are ready for SOSL searching. (Preventing injection)
		loadCampaignValues(recordId);
		//Integer iNumPos = 0;
		if(!String.isEmpty(searchCriteria1)){
			whereSOSLFLD01.addAll(fixValues(searchCriteria1));
			mapSOSL.put(1, fixValues(searchCriteria1));
			//iNumPos += 1;
		}if(!String.isEmpty(searchCriteria2)){
			whereSOSLFLD02.addAll(fixValues(searchCriteria2));
			mapSOSL.put(2, fixValues(searchCriteria2));
			//iNumPos += 1;
		}if(!String.isEmpty(searchCriteria3)){
			whereSOSLFLD03.addAll(fixValues(searchCriteria3));
			mapSOSL.put(3, fixValues(searchCriteria3));
			//iNumPos += 1;
		}if(!String.isEmpty(searchCriteria4)){
			whereSOSLFLD04.addAll(fixValues(searchCriteria4));
			mapSOSL.put(4, fixValues(searchCriteria4));
			//iNumPos += 1;
		}

		// STEP1: GET METADATA --> Return the list of fields to be use in the search for each Object included in the query
		System.debug('STEP1.Start');
		for(CustomerSearchSettings__mdt aux : [SELECT SearchFields__c,SOSL__c,QualifiedApiName FROM CustomerSearchSettings__mdt where QualifiedApiName Like 'DMSOSL0%' Order by QualifiedApiName ASC limit 10]){
			String sObj = aux.QualifiedApiName;
			System.debug('STEP1.MAP : ' + sObj.right(sObj.length() - (sObj.indexof('0')+2))  + ' FIELDS: ' + aux.SOSL__c );
			mapDrawFields.put(sObj.right(sObj.length() - (sObj.indexof('0')+2)), aux.SOSL__c );
			if(sObj.right(sObj.length() - (sObj.indexof('0')+2)) == GLOBAL_CMT_SOQLORDER){
				sFieldstoget = aux.SearchFields__c;
			}
		}
		// DECLARING NEW VARS
		List<String> lstfieldstoget             = sFieldstoget.split(',');
		String sNewObject                       = sObjectName;
		DescribeSObjectResult objResult         = Schema.getGlobalDescribe().get(GLOBAL_SOQL_OBJECT).getDescribe(); 
		// STEP2: ---> Setting data table columns
		System.debug('STEP2.Start');
		for(String field : lstfieldstoget){
			field = field.replaceAll( '\\(', '' ).trim();
			field = field.replaceAll( '\\)', '' ).trim();
			if(field.indexof('.')>0){
				String sVal                     = '';
				List<String> auxobj             = field.split('\\.');
				if (field.indexof('Id__r')>0){
					sVal                        = String.valueof(auxobj.get(0));
					sNewObject                  = sVal.left(sVal.length()-5);
					lstfinalfields.add(auxobj.get(1));
					objResultAux                = Schema.getGlobalDescribe().get(sNewObject.trim()).getDescribe();
				}else if (field.indexof('RecordType')>=0){
					sNewObject                  = GLOBAL_SOQL_OBJECT;
					lstfinalfields.add(field);
					objResultAux                = Schema.getGlobalDescribe().get(sNewObject.trim()).getDescribe();
				}else{
					sNewObject                  = auxobj.get(0);
					lstfinalfields.add(auxobj.get(1));
					objResultAux                = Schema.getGlobalDescribe().get(sNewObject.trim()).getDescribe();
				}
				if (field.indexof('RecordType')>=0){
					fieldResultAux              = objResultAux.fields.getMap().get('RecordTypeId').getDescribe();
				}else{
					fieldResultAux              = objResultAux.fields.getMap().get(auxobj.get(1)).getDescribe();
				}
				System.debug('V1: ' + fieldResultAux.getLabel()+'V1: ' + fieldResultAux.getName()+'V1: ' + String.valueof(fieldResultAux.getType()).toLowerCase());		

				/* BEGIN - Manuel Medina - C1STAGILE-9868 - - 31052019 */
				if(field.equalsIgnoreCase('Account.Name')){
					lstTableColumn.add( new DataTableColumns( fieldResultAux.getLabel(), field, String.valueof( fieldResultAux.getType() ).toLowerCase(), true, false ) );
				}else{
					lstTableColumn.add(new DataTableColumns(fieldResultAux.getLabel(),fieldResultAux.getName(),String.valueof(fieldResultAux.getType()).toLowerCase(),true,false));
				}
				//lstTableColumn.add(new DataTableColumns(fieldResultAux.getLabel(),fieldResultAux.getName(),String.valueof(fieldResultAux.getType()).toLowerCase(),true,false));
				/* END - Manuel Medina - 31052019 */
			}else{
				DescribeFieldResult fieldResult = objResult.fields.getMap().get(field).getDescribe();
				lstTableColumn.add(new DataTableColumns(fieldResult.getLabel(),fieldResult.getName(),String.valueof(fieldResult.getType()).toLowerCase(),true,false));
				lstfinalfields.add(field);
			}
		}
		System.debug('STEP2.End');
		// STEP3: ---> Dynamic SOSL queries. One per Search Field + Results Logic (AND | OR)
		System.debug('STEP3.Start');
		Set<Id> setAccountIds 		= new Set<Id>();
		Set<Id> setAccountAuxIds;
		Integer iCount = 1;
		Boolean bPosExec = false;
		for(String sSOSL : mapDrawFields.values()){
			setAccountAuxIds 	= new Set<Id>();
			if (bFilter){
				if(mapSOSL.containsKey(iCount)){
					setAccountIds.addAll(getSetIds(sSOSL,mapSOSL.get(iCount),searchFilterF,searchFilterD));
				}
			}else{
				if(mapSOSL.containsKey(iCount)){
					setAccountAuxIds.addAll(getSetIds(sSOSL,mapSOSL.get(iCount),searchFilterF,searchFilterD));
					if(setAccountIds.isEmpty() && iCount==1){
						setAccountIds.addAll(setAccountAuxIds);
					}else{
						if(!setAccountAuxIds.isEmpty() && setAccountAuxIds.size()>0){
							if(!setAccountIds.isEmpty() || bPosExec){
								setAccountIds.retainAll(setAccountAuxIds);
							}else{
								setAccountIds.addAll(setAccountAuxIds);
							}
						}else{
							setAccountIds.clear();
						}
					}
					bPosExec = true;
				}
			}
			iCount +=1;
		}
		System.debug('STEP3.End ' + setAccountIds.size());
		System.debug('STEP3.End ' + setAccountIds);
		System.debug('STEP3.End');
		// STEP4: ---> Getting all object IDs to compose the last query and retrieve the final results
		System.debug('STEP4.Start');
		Integer isMember 						= 0;
		String queryString                      = mapDrawFields.get(GLOBAL_CMT_SOQLORDER);
		try {
			queryString 						= setFilter(queryString,searchFilterF, searchFilterD);
			queryString 						= setContactType(queryString,sCampaignType);		
			queryString 						= cleanQuery(queryString);

			System.debug('STEP4.LastQuery ' + queryString);
			//System.debug('STEP4.iNumPos ' + iNumPos);
			//if(iNumPos>1 || GLOBAL_RESULTS.isEmpty()){
			lstAux                          	= database.query(queryString);			
			//}else{
			//	System.debug('STEP4.GLOBAL_RESULTS ' + GLOBAL_RESULTS);
			//	lstAux.addAll(GLOBAL_RESULTS);
			//}
			System.debug('STEP4.lstAux ' + lstAux.size());
			for(sObject o : lstAux ){
				String sId                      = String.valueof(o.get('Id'));
				String sIdObj1                  = String.valueof(o.get('AccountId'));
				List<DataTableField>lstFieldsWrapper        = new List<DataTableField>();
				for(String sField : lstfieldstoget){
					String sFieldValue      	= '';
					String sNewObj          	= '';
					List<String> auxobj;
					sField = sField.remove('(');
					sField = sField.remove(')');
					System.debug('STEP4.sField ' + sField);
					if(sField!=null){
						if (sField.indexof('.')>0 || sField.indexof('Id__r')>0){
							auxobj          	= sField.split('\\.');
							sNewObj         	= String.valueof(auxobj.get(0));
							if(sNewObj!='RecordType'){
								sFieldValue     = String.valueOf(o.getSObject(SecurityUtilsLib.escapeText(sNewObj)).get(String.valueOf(auxobj.get(1))));
							}else{
								System.debug('STEP4.sField ' + o.get('RecordTypeId'));
								sFieldValue     = String.valueof(o.get('RecordTypeId'));		
							}
						}else{
							sFieldValue      	= String.valueof(o.get(sField));
						}
						lstFieldsWrapper.add( new DataTableField(SecurityUtilsLib.escapeText(sField),sFieldValue));
					}
				}
				lstFieldsWrapper.add( new DataTableField('Id',sId));
				lstFieldsWrapper.add( new DataTableField('AccountId',sIdObj1));
				lstFieldsWrapper.add( new DataTableField('CampaignMember',String.valueOf(CAMPAIGN_MEMBERS.contains(sId))));
				isMember = (CAMPAIGN_MEMBERS.contains(sId))?isMember+1:isMember;
				lstValues.add(new DataTableObject(o));
				lstValuesW.add(new DataTableObjectWrapper(lstFieldsWrapper));
			}
			System.debug('STEP7.END_OK');
		} catch(dmlexception e) {
			system.debug('STEP7.getfetchRecords --> DML Error : ' + e.getMessage());
		} catch (Exception e){
			System.debug('STEP7.getfetchRecords--> Exception : ' + e.getMessage());
		}
		ltngTableWrapper.iCampaignMembers		= isMember;
		ltngTableWrapper.lstDataTableData       = lstValues;
		ltngTableWrapper.lstDataTableDataW      = lstValuesW;
		ltngTableWrapper.lstDataTableColumns    = lstTableColumn;
		return ltngTableWrapper;   
	}
	private static Set<Id> getSetIds(String sENDSOSL,List<String> lstValues, String sFILTERF, String sFILTERD){
		System.debug('getSetIds.Start');
		Set<Id> setIDs = new Set<Id>();
		List<SObject> lstObjectResult           = new List<sObject>();
		try {
			if(!lstValues.isEmpty()){
				String sQuerySOSL               = sENDSOSL.replace('*', String.join(lstValues,GLOBAL_SOQL_AND));
				sQuerySOSL = setFilter(sQuerySOSL,sFILTERF, sFILTERD);
				sQuerySOSL = cleanQuery(sQuerySOSL);
				System.debug('getSetIds.SOSL : ' + sQuerySOSL);
				List<List<SObject>>searchList   = search.query(sQuerySOSL);
				if(!searchList.isEmpty()){
					for(Integer iPos = 0; iPos<searchList.size() ;iPos++ ){
						lstObjectResult.addAll(searchList.get(iPos));
						GLOBAL_RESULTS.addAll(searchList.get(iPos));
						System.debug('getSetIds.searchList.get(iPos) : ' + searchList.get(iPos));
					}
				}
			}
			for(SObject obj : lstObjectResult ){
				if(obj.getSObjectType() ==  Schema.AccountContactAssetRelation__c.getSObjectType()){
					setIDs.add((ID)obj.get('AccountId__c'));
				}else if(obj.getSObjectType() ==  Schema.WorkshopAppointment__c.getSObjectType()){
					sObject oAux = (sObject)obj.getSObject('TECH_AccountAssetRelation__r');
					setIDs.add((ID)oAux.get('AccountId__c'));
					//setIDs.add((ID)obj.get('Driver__c')); //TECH_AccountAssetRelation__r.AccountId__c
				}else if(obj.getSObjectType() ==  Schema.SBQQ__Quote__c.getSObjectType()){
					setIDs.add((ID)obj.get('SBQQ__Account__c') );
				}else if(obj.getSObjectType() ==  Schema.InterventionFile__c.getSObjectType()){
					setIDs.add((ID)obj.get('Account__c') );
				}else if(obj.getSObjectType() ==  Schema.InterventionFileFamily__c.getSObjectType()){
					sObject oAux = (sObject)obj.getSObject('InterventionFile__r');
					setIDs.add((ID)oAux.get('Account__c'));
					//setIDs.add((ID)obj.get('InterventionFile__r.Account__c'));
				}else{
					setIDs.add((ID)obj.get('AccountId') );
				}
			}
			System.debug('getSetIds.END_OK');
		} catch(DMLException e) {
			System.debug('getSetIds.findRecords --> DML Error : ' + e.getMessage());
		} catch (Exception e){
			System.debug('getSetIds.findRecords--> Exception : ' + e.getMessage());
		}
		return setIDs;
	}
	private static void loadCampaignValues (String recordId){
		System.debug('STEP0.Start');
		for(Campaign cm : [SELECT Id,Type,CustomerType__c,(SELECT ContactId FROM CampaignMembers WHERE ContactId != null) FROM Campaign WHERE Id = :recordId] ){
			sCampaignChannel 	= cm.Type;
			sCampaignType		= cm.CustomerType__c;
			for(CampaignMember cmo : cm.CampaignMembers){
				CAMPAIGN_MEMBERS.add(cmo.ContactId);
				System.debug('cmo.ContactId ' + cmo.ContactId);
			}
			System.debug('Type ' + sCampaignChannel);
		}
		System.debug('STEP0.End');
	}
	private static String setContactType(String sQuerySOSL, String sType){
		if(String.isNotBlank(sQuerySOSL) && String.isNotBlank(sType)){
					String sCond 				= (sType=='2')?GLOBAL_SOQL_B2B:GLOBAL_SOQL_B2C;
					sQuerySOSL 					= sQuerySOSL.replace('{0:0}',GLOBAL_SOQL_AND + sCond );
		}
		return sQuerySOSL;
	}
	private static String setFilter(String sQuerySOSL, String sFilterField, String sFilterDate){
		if(String.isNotBlank(sFilterField) && String.isNotBlank(sFilterDate)){
					List<String> auxobj         = sFilterField.split('\\.');
					String sKey					= auxobj.get(0);
					String sVal					= sFilterField.removeStart(auxobj.get(0)+'.');
					String sCond 				= (sKey=='{1:1}')?GLOBAL_SOQL_AND:GLOBAL_SOQL_WHERE;
					sQuerySOSL 					= sQuerySOSL.replace(sKey, sCond + sVal + ' ' + sFilterDate);
		}
		return sQuerySOSL;
	}
	private static String cleanQuery(String sQuery){
		Matcher mentionMatcher = Pattern.compile( '(\\{[0-9]:[0-9]\\})' ).matcher( sQuery );
		while ( mentionMatcher.find() ){
			sQuery = mentionMatcher.replaceAll( '' );
		}
		return sQuery;
	}
	/*
	* @Method          :   DataTableResponse
	* @Author          :   Ruben Fernandez Lopez
	* @Created         :   23/02/2018
	* @Description     :   Wrapper class to hold Columns & Data
	*/ 
	public class DataTableResponse {
		@AuraEnabled
		public List<DataTableColumns> lstDataTableColumns {get;set;}
		@AuraEnabled         
		public List<DataTableObject> lstDataTableData {get;set;}
		@AuraEnabled         
		public Integer iCampaignMembers {get;set;}
		@AuraEnabled         
		public List<DataTableObjectWrapper> lstDataTableDataW {get;set;}
		public DataTableResponse(){
			lstDataTableColumns     = new List<DataTableColumns>();
			lstDataTableData        = new List<DataTableObject>();
			lstDataTableDataW       = new List<DataTableObjectWrapper>();
			iCampaignMembers		= 0;
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
		public DataTableObject(sObject sobjname){
			this.sObjectVal     = sobjname;
		}
	}
	public class DataTableObjectWrapper {
		@AuraEnabled
		public List<DataTableField> lstWrapperVal {get;set;}
		public DataTableObjectWrapper(List<DataTableField> lstFields){
			this.lstWrapperVal   = lstFields;
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
	@AuraEnabled
	public static boolean createNewRecords(String lstRecords, String sCampaignId){
	
		System.debug('CampaignId: ' + sCampaignId);
		System.debug('lstRecords: ' + lstRecords);
    	List<string> wrapperList = (List<string>) JSON.deserialize(lstRecords, Type.forName('List<string>'));

		List<CampaignMember> lstCM = new List<CampaignMember>();
		for(String s : wrapperList){
			CampaignMember cm 				= new CampaignMember(
			CampaignId						= sCampaignId,
			ContactId						= s
			//Status							= 'Sent'
			);
			lstCM.add(cm);
		}
		try{
			if(!lstCM.isEmpty()){
				Insert lstCM;
			}
			return true;
		}catch(Exception e){
			return false;
		}
	}
	private static Integer iExecution = 0;

	@AuraEnabled
	public static FieldResponse getselectOptions() {
		//$A.get("$Label.c.CustomerSearchErrorMessageLength")

		FieldResponse ltngTableWrapper              = new FieldResponse();
		List<FieldOptions> lstValues                = new List<FieldOptions>();
		for(UtilSetting__mdt aux : [SELECT MasterLabel,QualifiedApiName,Value__c,Value2__c,Value3__c FROM UtilSetting__mdt where QualifiedApiName Like 'DMFILTER%' Order by QualifiedApiName ASC limit 25]){
			if(aux.Value3__c!='DATE'){
				lstValues.add(new FieldOptions(aux.QualifiedApiName,aux.Value__c,aux.Value3__c));
			}else{
				lstValues.add(new FieldOptions(aux.QualifiedApiName,aux.Value2__c + ' ' + aux.Value__c,aux.Value3__c));
			}	
		}
		ltngTableWrapper.lstOptions                 = lstValues;
		return ltngTableWrapper;
	}
	
	/*
	* @Method          :   Wrapper: DataTableResponse
	* @Author          :   Ruben Fernandez Lopez
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
		@AuraEnabled
		public String Type  {get;set;}

		//Create and set three variables label, fieldname and type as required by the lightning:datatable
		public FieldOptions(String Field,String Value,String Type){
			this.Field          = Field;
			this.Value          = Value;
			this.Type 			= Type;
		}
	}
}
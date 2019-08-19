/*-----------------------------------------------------------------------------------------------------------//
* Class Name	: CustomListViewController
* Author 		: DXC: Ruben Fernandez
* Date 			: 22/06/2018
* Description 	: Custom List View controller class for Lightning Component
* Aura Methods 	
*				1. setTransferRecords. Change Records Owner
*				2. readListView. 		Get User List Views for a specific sObject
*				3. getFilteredRecords.  Search for the results and return a datatable
*				4. getRoleSubordinateUsers.  Look for all subordinates roles
* Private 		
*				1. refreshToken. 		oAuth2. Dummy operation to force token refresh if expired.
*				2. getAllSubRoleIds
*				3. AddQueryFilter
*-----------------------------------------------------------------------------------------------------------*/
public with sharing class CustomListViewController {
	
 
	private final static string CALLOUT_BASEURL = 'callout:CustomListView/services/';
	private final static string CALLOUT_VERSION = '42.0';
	private final static string CALLOUT_FULLVER	= 'v';
	private final static string CALLOUT_SOAP 	= 'Soap/m';
	private final static string CALLOUT_DATA 	= 'data';
	private final static string CALLOUT_SPLASH 	= '/';
	private final static string CALLOUT_TYPE_L 	= 'limits';
	private final static string CALLOUT_TYPE_D 	= 'describe';
	private final static string CALLOUT_TYPE_O 	= 'sobjects';
	private final static string CALLOUT_TYPE_V 	= 'listviews';
  	private final static string SOQL_C_WHERE	= 'WHERE';
	private final static string SOQL_C_ORDER	= 'ORDER BY';
	private final static string SOQL_C_AND		= ' AND ';
	private final static string SOQL_WHERE_IN	= 'OwnerId IN : allUserIds ';
	private final static string SOQL_SCOPE_IN	= 'USING SCOPE';
	private final static string SOQL_SCOPE_VAL	= ' mine ';
	private static Set<Id> allUserIds			= new Set<Id>() ;
    private static Map<String,String> FieldLabels= new Map<String,String>();
    
	/* BEGIN - Manuel Medina - Bug C1STAGILE-4028 - New logic to get SObject API name based on reference field - 31082018 */
	private static String strListViewSObject	= 'Opportunity';
	/* END - Manuel Medina - 31082018 */
    
    // Method to transfer rcord(s) to a new Owner 
	@AuraEnabled
	public static boolean setTransferRecords(String lstRecordsId, String sOwnerID){
		boolean bResult = false;
		system.debug('setTransferRecords ' + lstRecordsId + ' | ' + sOwnerID);
		List<String> selectedIdsList = new List<String>();
		if(lstRecordsId!=null && sOwnerID != null){
			//Object[] listToSave = (Object[])JSON.deserializeUntyped(lstRecordsId);
			List<ObjectIDs> c = (List<ObjectIDs>)JSON.deserializeStrict(lstRecordsId,List<ObjectIDs>.class);
			system.debug('setTransferRecords.values : ' + c);
			if(c.size()>0){         
			    for (ObjectIDs sId : c) {
			    	system.debug('setTransferRecords.values : ' + string.valueof(sId.value));
			        selectedIdsList.add(string.valueof(sId.value) );
			    }
			}
			List<Opportunity> lRecords = new List<Opportunity>([SELECT Id, OwnerId FROM Opportunity where Id IN :selectedIdsList]);
			for(Opportunity obj : lRecords){
				system.debug('setTransferRecords.obj.OwnerId : ' + sOwnerID);
				obj.OwnerId = sOwnerID;
			}
			if(!lRecords.isEmpty()){
				try{
					update lRecords;
					bResult = true;
				}catch(Exception e){
					system.debug('setTransferRecords.Update Error: ' + e.getMessage());
				}
			}
		}else{
            System.debug('setTransferRecords.Param null or empty.');
		}
		System.debug('setTransferRecords.bResult' + bResult);
		return bResult;
	}
    // Method to get all list view option available for the Account object 
    @AuraEnabled
    public static List<ListView> getListViews(String strObjectName){
    	System.debug('START getListViews');
        loadSettingValues();
        List<ListView> listviews = new List<ListView>();
        for(ListView lstObj : [SELECT Id, Name, DeveloperName FROM ListView WHERE SobjectType =:strObjectName order by name ASC]){
            if(SECURITY_VIEWS_AVAILABLE.contains(lstObj.DeveloperName)){  // GET DEFAULT VALUES, JUST IN CASE NO BRAND COUNTRY PAIR OF VALUES FOUND!!
               String sName = lstObj.DeveloperName; 
               if(sName.indexof('RecentlyViewed')==0 ){
                    List<ListView> auxlistviews = new List<ListView>();
                    auxlistviews.add(lstObj);
                    auxlistviews.addAll(listviews);
                    listviews                   = auxlistviews;
                    
               }else{
        	       listviews.add(lstObj);
               }
            }
        }        
        System.debug('END getListViews');
        return listviews; 
    }
    private static Map<String,String> SECURITY_MANAGER_PROFILES = new Map<string,string>();
    private static Set<String> SECURITY_VIEWS_AVAILABLE         = new Set<String>();


    private static void loadSettingValues(){
		for(UtilSetting__mdt larp : [SELECT MasterLabel, QualifiedApiName, Value__c,Value2__c FROM UtilSetting__mdt where QualifiedApiName LIKE 'CustomListView_%']){
			String sValue 	= larp.QualifiedApiName;
			String sAuxVal 	= larp.Value__c;
			if(sValue.indexof('MP')>0 ){
				for(String s : sAuxVal.split(';')){
					SECURITY_MANAGER_PROFILES.put(s,s);
				}
			}else if (sValue.indexof('LV' + PAD.sUserCountry + PAD.sUserBrand)>0 ){
                if(!SECURITY_VIEWS_AVAILABLE.isEmpty())
                    SECURITY_VIEWS_AVAILABLE.clear();
                for(String s : sAuxVal.split(';')){
                    SECURITY_VIEWS_AVAILABLE.add(s);
                }
            }else if (sValue.indexof('LVDEFAULT')>0){
                if(SECURITY_VIEWS_AVAILABLE.isEmpty()){
                    for(String s : sAuxVal.split(';')){
                        SECURITY_VIEWS_AVAILABLE.add(s);
                    }
                }
            }
		}
	}

    public static Set<ID> getRoleSubordinateUsers() {

    	// get requested user's role
    	String currentUserId 	= UserInfo.getUserID();
    	List<User> lstUser 		= new List<User>([SELECT Id, ProfileId, Profile.Name, UserRoleId FROM User WHERE Id = :currentUserId]);
    	Set<Id> allSubRoleIds 	= new set<Id>();

    	Id roleId = lstUser.get(0).UserRoleId; //[select UserRoleId, Profile.Name, from User where Id = :userId].UserRoleId;
    	// get all of the roles underneath the user
    	System.debug('START getRoleSubordinateUsers : ' + lstUser.get(0).Profile.Name);
    	
    	if(SECURITY_MANAGER_PROFILES.containsKey(lstUser.get(0).Profile.Name) ){
    		allSubRoleIds 		= getAllSubRoleIds(new Set<ID>{roleId});
    	}

    	//if(lstUser.get(0).Profile.Name == 'Sales_Manager'){
    	//	allSubRoleIds 		= getAllSubRoleIds(new Set<ID>{roleId});
    	//}
    	// get all of the ids for the users in those roles
    	Map<Id,User> users 		= new Map<Id, User>([Select Id, Name From User where UserRoleId IN :allSubRoleIds]);
    
    	if(!users.isEmpty()){
	    	if(!users.containsKey(lstUser.get(0).Id)){
	    		users.put(lstUser.get(0).Id, lstUser.get(0));
	    	}
    	}
    	// return the ids as a set so we can do what we want with them
    	System.debug('END getRoleSubordinateUsers users.isEmpty: ' + users.isEmpty());
    	System.debug('END getRoleSubordinateUsers allSubRoleIds: ' + allSubRoleIds);
    	return users.keySet(); //(users.isEmpty())?allSubRoleIds:users.keySet();
  	}

  	private static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {

    	Set<ID> currentRoleIds = new Set<ID>();
    	// get all of the roles underneath the passed roles
    	for(UserRole userRole :[select Id from UserRole where ParentRoleId IN :roleIds AND ParentRoleID != null])
    		currentRoleIds.add(userRole.Id);
    	// go fetch some more rolls!
    	if(currentRoleIds.size() > 0)
      		currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));

    	return currentRoleIds;
  	}

    public static String AddQueryFilter(String sQuery){
    	String sResult = sQuery;
		System.debug('START AddQueryFilter : ' + sQuery);
    	if(sQuery.indexOf(SOQL_SCOPE_IN)<=0){
			allUserIds 	= getRoleSubordinateUsers();
			Integer iPosWhere 	= sQuery.indexOf(SOQL_C_WHERE);
			Integer iPosOrder 	= sQuery.indexOf(SOQL_C_ORDER);
			String sFirst 		= '';
			String sLast 		= ''; 
			if(!allUserIds.isEmpty()){
				if(iPosWhere>0){
					if(iPosOrder>0){
						sFirst 		= sQuery.left(iPosOrder -1);
						sLast 		= sQuery.right(sQuery.length() - iPosOrder);
						sResult 	= sQuery.left(iPosOrder -1) + SOQL_C_AND  + SOQL_WHERE_IN  +  sLast ;
					}else{
						sFirst 		= sQuery.left(iPosWhere -1);
						sResult 	= sQuery + SOQL_C_AND  + SOQL_WHERE_IN;
					}
				}else if(iPosOrder>0){
					sFirst 			= sQuery.left(iPosOrder -1);
					sLast 			= sQuery.right(sQuery.length() - iPosOrder);
					sResult 		= sQuery.left(iPosOrder -1) + ' ' + SOQL_C_WHERE + ' ' +  SOQL_WHERE_IN +  sQuery.right(iPosOrder);
				}else{
					sResult 		= sQuery + ' ' + SOQL_C_WHERE + ' ' +  SOQL_WHERE_IN;
				}
			}else{
				if(iPosWhere>0){
					sFirst 			= sQuery.left(iPosWhere -1);
					sLast 			= sQuery.right(sQuery.length() - iPosWhere);
					sResult 		= sQuery.left(iPosWhere -1) + ' ' + SOQL_SCOPE_IN + SOQL_SCOPE_VAL + sLast;
				}else if(iPosOrder>0){
					sFirst 			= sQuery.left(iPosOrder -1);
					sLast 			= sQuery.right(sQuery.length() - iPosOrder);
					sResult 		= sQuery.left(iPosOrder -1) + ' ' + SOQL_SCOPE_IN + SOQL_SCOPE_VAL + sLast;
				}else{
					sResult 		= sQuery + ' ' + SOQL_SCOPE_IN + SOQL_SCOPE_VAL;
				}
			}
    	}
    	System.debug('END AddQueryFilter : ' + sResult);
    	return sResult;
    }
    
    //public class OAuth2 {
    //    public String id {get;set;}
    //    public String issued_at {get;set;}
    //    public String instance_url {get;set;}
    //    public String signature {get;set;}
    //    public String access_token {get;set;}    
    //}
    // Variables...

   //public static String getToken(){
   //     // Generate Request    
   //     String sTokenVal = '';  
   //     HttpRequest tokenRequest = new HttpRequest();
   //     tokenRequest.setMethod('POST');
   //     tokenRequest.setEndpoint(
   //         URL.getSalesforceBaseUrl().toExternalForm() + '/services/oauth2/token' +
   //         '?grant_type=password' +
   //         '&client_id=3MVG96mGXeuuwTZhx6bkpnoKPbD2CTvBJs8jh.czhw6x7_H6q4bn3kJvA.d4LUpzHFwf9_FrxG58welmM9Z5i' +
   //         '&client_secret=7924211896197445583' +
   //         '&username=' + 
   //         '&password='
   //      );
   //     // Get Response
   //     Http http = new Http();
   //     HttpResponse tokenResponse = http.send(tokenRequest);
   //     try {

   //         OAuth2 oaResult = (OAuth2) JSON.deserialize(tokenResponse.getBody(),OAuth2.class);
   //         sTokenVal = oaResult.access_token;
   //     } catch(Exception whoops){
   //         System.debug('OAuthException: ' + whoops.getTypeName() + ': ' + whoops.getMessage());
   //     }
   //     return sTokenVal;
   //}
    // Method to get the Account records based on the selected list view
    @AuraEnabled  
    public static DataTableResponse getFilteredRecords(String filterId, String sObjectName){
    	/* BEGIN - Manuel Medina - Bug C1STAGILE-4028 - New logic to get SObject API name based on reference field - 31082018 */
    	strListViewSObject						= sObjectName;
    	/* END - Manuel Medina - 31082018 */
    	
    	System.debug('getFilteredRecords' + filterId);
        HttpRequest req 						= new HttpRequest();
        HTTPResponse response 					= new HTTPResponse();
        List<sObject> objRecord 				= new List<sObject>();
        Http http 								= new Http();
        DataTableResponse dtrResponse 			= new DataTableResponse();
        List<DataTableColumns> lstDataColumns 	= new List<DataTableColumns>();
		String endPoinURL 						= CALLOUT_BASEURL + CALLOUT_DATA + CALLOUT_SPLASH + CALLOUT_FULLVER + CALLOUT_VERSION + CALLOUT_SPLASH + CALLOUT_TYPE_O + 
												CALLOUT_SPLASH + sObjectName  + CALLOUT_SPLASH + CALLOUT_TYPE_V +CALLOUT_SPLASH +filterId+ CALLOUT_SPLASH + CALLOUT_TYPE_D;
        req.setEndpoint(endPoinURL);
        req.setMethod('GET');
        try{
        	response 					= http.send(req);
    	}catch(Exception e){
    		if(!Test.isRunningTest()){refreshToken();response = http.send(req);}
    	}
        //Keyset:{columns, id, orderBy, query, scope, sobjectType, whereCondition}
		Map<String, Object> tokenResponse 		= (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        String query = (String) tokenResponse.get('query');
        System.debug('Query : ' + query);
        // update query
        query 									= AddQueryFilter(query);
        System.debug('Query Filter : ' + query);
        //System.debug('Keyset:' +tokenResponse.get('columns'));
        String lstObj  							= String.valueOf(tokenResponse.get('columns'));
        lstObj 									= lstObj.left(lstObj.length()-1);
        lstObj 									= lstObj.right(lstObj.length()-1);
        List<Object> responseColumns 			= (List<Object>) JSON.deserializeUntyped(JSON.serialize(tokenResponse.get('columns')));
        //System.debug('responseColumns: ' + responseColumns.size());
        FieldLabels = PAD.getFieldLabel(sObjectName);
 		for(Object o : responseColumns){
 			system.debug('o:' + o);
 			String sObj = String.valueOf(o);
 			sObj = sObj.removeStart('{');
 			sObj = sObj.removeStart('}');
 			List<String> aux = sObj.split(',');
 			System.debug(aux);
            System.debug(aux.get(3));
 			DataTableColumns datacolumns;
 			if(aux.get(3).Trim()=='hidden=false'){
                String fieldLabel               = aux.get(4).right(aux.get(4).length()-7).trim();
                String fieldName                = aux.get(2).right(aux.get(2).length()-17).trim();
                if(fieldName.indexOf('.')> 0){
                    String sAux                 = fieldName.trim();
                    List<String> lstFieldName   = sAux.split('\\.');
                    if(!lstFieldName.isEmpty() && lstFieldName.size()>0 ){
                        fieldLabel              = getRelFieldLabels(lstFieldName.get(0),lstFieldName.get(1),fieldLabel);
                    }
                }else{
                        fieldLabel              = (FieldLabels.containsKey(fieldName))?FieldLabels.get(fieldName):fieldLabel;    
                }    
 				//system.debug('sLabel ' +FieldLabels.keySet());
                system.debug('Column Type: ' + aux.get(9).right(aux.get(9).length()-6).trim() );
     //           system.debug('sLabel ' +aux.get(2).right(aux.get(2).length()-17).trim());
                datacolumns 					= new DataTableColumns(fieldLabel, 
                                                      fieldName, 
                                                      getColumnType(aux.get(9).right(aux.get(9).length()-6).trim()),
                                                      true);
				lstDataColumns.add(datacolumns);
 			}
 		}
        if(! lstDataColumns.isEmpty()){            
            dtrResponse.lstDataTableColumns 	= lstDataColumns;
            system.debug('###Query: ' + query );
            dtrResponse.lstDataTableData 		= Database.query(query);
        }
        return dtrResponse;     
    }
    private static String getColumnType (String sType){
        String sNewType = sType;
        if(sType == 'datetime'){
            sNewType = 'date';
        }
        return sNewType;
    }
    private static String getRelFieldLabels(String sObjectName, String sFieldName, String sFieldLabel){
        //system.debug('getRelFieldLable sObjectName: ' + sObjectName + ' | sFieldName: ' + sFieldName  + ' | sFieldLabel: ' + sFieldLabel);
        
		/* BEGIN - Manuel Medina - Bug C1STAGILE-4028 - New logic to get SObject API name based on reference field - 31082018 */
		//sObjectName = (sObjectName == 'Owner')? 'User':sObjectName;
		String strReferenceTo							= getReferenceTo( sObjectName, strListViewSObject );
		sObjectName										= String.isNotEmpty( strReferenceTo ) ? strReferenceTo : sObjectName;
		/* END - Manuel Medina - 31082018 */
        
        Map<String,String> mapFieldLabel = PAD.getFieldLabel(sObjectName);
        return mapFieldLabel.containsKey(sFieldName)?mapFieldLabel.get(sFieldName):sFieldLabel;

    }
    
    /* BEGIN - Manuel Medina - Bug C1STAGILE-4028 - New logic to get SObject API name based on reference field - 31082018 */
    
	/**
	* @Method: 		getReferenceTo
	* @param: 		String strReferenceFieldName
	* @param: 		String strSObjectType
	* @Description: Retunrs the SObject API name which field is related to.
	* @author		Manuel Medina - 31082018
	*/
	public static String getReferenceTo( String strReferenceFieldName, String strSObjectType ){
		strReferenceFieldName													= strReferenceFieldName.contains( '__r' ) ? strReferenceFieldName.replace( '__r', '__c' ) : ( strReferenceFieldName.contains( '__c' ) ? strReferenceFieldName : strReferenceFieldName + 'Id' );
		
		Map<String, Schema.SObjectType> mapSFDCObjects							= Schema.getGlobalDescribe();
		Schema.DescribeSObjectResult sObjResult									= mapSFDCObjects.get( strSObjectType ).getDescribe();
						 
		Map<String, Schema.SObjectField> mapFields								= sObjResult.fields.getMap();
		
		if( mapFields.containsKey( strReferenceFieldName ) ){
			Schema.SObjectField field 												= mapFields.get( strReferenceFieldName );
	
			Schema.DescribeFieldResult fieldResult									= field.getDescribe();
			
			List<Schema.sObjectType> lstSOjectRelated								= fieldResult.getReferenceTo();
			
			return !fieldResult.isNamePointing() && !lstSOjectRelated.isEmpty() ? String.valueOf( lstSOjectRelated.get( 0 ) ) : '';
		}
		
		return '';
	}    
    
    /* END - Manuel Medina - 31082018 */
    
    //We simply throw away the response, but this is enough to make sure the session is fresh.
    //Note: This wastes an extra API call, so beware if you are making multiple Metadata API callouts 
    //to stay within the governor and other platform limits.
    //'callout:CustomListView/services/data/v42.0/limits'
    private static void refreshToken(){
    	String restUrl = CALLOUT_BASEURL + CALLOUT_DATA + CALLOUT_SPLASH + CALLOUT_FULLVER + CALLOUT_VERSION + CALLOUT_SPLASH + CALLOUT_TYPE_L; 
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint(restUrl);
		req.setMethod('GET');
		try{
			HttpResponse res = h.send(req);
		}catch(Exception e){
			system.debug('refreshToken Error: ' + e.getMessage());
		}
    }
    public class ObjectIDs {
    	public String value;
	}
    //Wrapper class to hold Columns with headers
    public class DataTableColumns {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String fieldName {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public Boolean sortable {get;set;}

        public DataTableColumns(String label, String fieldName, String sType,Boolean bSortable){ 
            this.label      = label;
            this.fieldName  = fieldName;
            this.type       = sType; 
            this.sortable   = bSortable;
        }
    }
    //Wrapper calss to hold response - This response is used in the lightning:datatable component
    public class DataTableResponse {
        @AuraEnabled
        public List<DataTableColumns> lstDataTableColumns {get;set;}
        @AuraEnabled
        public List<sObject> lstDataTableData {get;set;}                
        
        public DataTableResponse(){
            lstDataTableColumns     = new List<DataTableColumns>();
            lstDataTableData        = new List<sObject>();
        }
    }
    
    @AuraEnabled
    public static boolean isProduction(){
    	
    	boolean retorno;
        
        List<organization> lstOrganization = [Select id,instanceName,isSandbox from Organization];
        
		if(lstOrganization.size()>0) {
			if(lstOrganization[0].isSandbox) {
				system.debug('Its Sandbox Instance');
			    retorno = false;
			} else {
			    system.debug('Its Production Instance');
			    retorno = true;
		   	}
		}
		
		return retorno;
		
    } 
}
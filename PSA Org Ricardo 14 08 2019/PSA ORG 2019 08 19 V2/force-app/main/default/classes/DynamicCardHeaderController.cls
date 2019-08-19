public with sharing class DynamicCardHeaderController {
	
	@AuraEnabled
    public static CSResultWrapper getObjectRecords (String whereClause,
		                                             String objectName,
		                                             String fields) {
	    System.debug('Start of DynamicCardHeaderController.getsObjectRecords...'); 
	    CSResultWrapper ltw = new CSResultWrapper(); 
	    List<String> valuesToShow = new List<String>(); 
	    System.debug(':::whereClause: ' + whereClause);  
	    System.debug(':::objectName: ' + objectName);  
	    fields = fields.replace('(','');
	    fields = fields.replace(')','');
	    System.debug(':::fields: ' + fields);
	    
	    String queryString = 'SELECT ' + fields + ' FROM ' + objectName;
	       	
	   	if (String.isNotBlank(whereClause)) {
	   		queryString = queryString + ' ' + whereClause;
		}
		queryString = queryString + ' LIMIT 1';
		System.debug(':::queryString: ' + queryString);
	    
	    ltw.page = 1;
	    
	    try {
	    	ltw.sObjectrecords = database.query(queryString);
	        system.debug('## RESULTS : ' + ltw.sObjectrecords);
	    } catch(dmlexception e) {
	        system.debug('## DML Exception : ' + e.getMessage());
	    } catch (Exception e){
	        System.debug('### Other Exception--> ' + e.getMessage());

	    }
	    
	    Map<Id,Boolean> mapAux = new Map<Id,Boolean>();
        List<Id> lstIds = new List<Id>();
        for(sObject obj : ltw.sObjectrecords){
            lstIds.add(obj.Id);
        }
        System.debug('getRecordAccess ' + getRecordAccess(lstIds));
        for(UserRecordAccess ura : getRecordAccess(lstIds)){
            System.debug('getRecordAccess ' + ura);
            mapAux.put(ura.RecordId,ura.HasReadAccess);
        }
        if(!mapAux.isEmpty()){
            ltw.sObjectrecordAccess = mapAux;
        }
        System.debug('GAS_DBG: ltw: ' + ltw);
        
        return ltw;
   }
	 
	/**
	* This method is used to return a list of the labels for the fields
	* @param objectname - Specify the API name of object to get the labels from
	* @param fields - List of fields whose labels we need to return
	*/                                      
    @AuraEnabled
    public static List<String> getLabels(String objectname,String relobjectname, List<String> fields) {
    	System.debug('Start of LMAResultController.getLabels...');
        List<String> labelsToShow = new List<String>();

        system.debug('LMAResultController.getLabels.   Param1:objectname ' + objectname + ' Param2:relobjectname--> ' + relobjectname + ' Param3:fields ' + fields);
       
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
            	System.debug('::::fieldName: ' + fieldName);
                if(fieldObjMap.containsKey(fieldName.trim())){
                    labelsToShow.add(fieldObjMap.get(fieldName.trim()).getDescribe().getLabel());
                }else if( fieldName == 'Owner.Name'){
                    labelsToShow.add(fieldObjMap.get('OwnerId').getDescribe().getLabel());
                }else if( fieldName == 'UserRecordAccess.HasReadAccess'){
                    labelsToShow.add(fieldUsrMap.get('HasReadAccess').getDescribe().getLabel());
                }else if (fieldRelMap!=null && !fieldRelMap.isEmpty()){
                    system.debug('getLabels.fieldRelMap.indexOf() --> ' + fieldName.indexOf('.')  + ' | ' + fieldName);
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
        System.debug('::::labelsToShow: ' + labelsToShow);
        return labelsToShow;
    }
    
    /**
     * This method is used to return a list of the labels for the fields
     * @param objectname - Specify the API name of object to get the labels from
     * @param fields - List of fields whose labels we need to return
     */ 
    public static List<UserRecordAccess> getRecordAccess(List<Id> lstRecords){
    	System.debug('Start of LMAResultController.getRecordAccess...');
        Id sUserId = UserInfo.getUserId();
        System.debug('getRecordAccess sUserId ' + sUserId);
        return new List<UserRecordAccess>([SELECT RecordId, HasReadAccess, HasTransferAccess, MaxAccessLevel FROM UserRecordAccess WHERE UserId =:sUserId AND RecordId IN :lstRecords]);
    }
}
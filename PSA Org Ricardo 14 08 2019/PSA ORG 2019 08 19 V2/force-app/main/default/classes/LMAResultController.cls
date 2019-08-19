public with sharing class LMAResultController {
/*
-- - Name         : LMAResultController
-- - Author       : rfernandezlo and gsmith
-- - Date         : 09/03/2018
-- - Description  : This apex class returns the list of records and labels 
					for the specified sObject and fields
--
-- - History:
-- Date         Author  Version  Comments
-- -----------  -----   -------  ---------------------------------------
-- 09/03/2018   G Smith 1.0      Cloned from CSResultAController created by
--                               rfernandezlo and refactored for Manual Lead 
--                               Assignment components.
*/	
	static final String LEAD_PRIORITY_ONTIME    = 'On Time';
	static final String LEAD_PRIORITY_URGENT    = 'Urgent';
	static final String LEAD_PRIORITY_OVERDUE   = 'Overdue';
	static final String LEAD_PRIORITY_ALL       = 'All';
	
	class leadCounts {
		
		    /*
		    @AuraEnabled
		    public Id id;
		
		    @AuraEnabled
		    public String userName;
		    */
		    
		    @AuraEnabled
		    public Integer countOnTime = 0;
		    
		    @AuraEnabled
		    public Integer countUrgent = 0;
		    
		    @AuraEnabled
		    public Integer countOverdue = 0;
		}
	    
   class FieldAndLabelWrapper {
        
        @AuraEnabled
        public String name;
        
        @AuraEnabled
        public String label;
        
    }
	
	@AuraEnabled
	public static Map<Id,leadCounts> getUserLeadCounts(Boolean fiterByCurrentUser) {
		Map<Id,leadCounts> userLeadCounts = new Map<Id,leadCounts>();
		List<Lead> Leads = [SELECT Id, 
									Name, 
				                    OwnerId, 
				                    TECH_TreatmentPriorityLabel__c 
		                    FROM Lead
		                    ORDER BY OwnerId];
		
		Integer countOnTime         = 0;
		Integer countUrgent         = 0;
		Integer countOverdue        = 0;
		
		Id currentUserId;
		
		for (Lead ld : Leads)         
		{
		    leadCounts lc = new leadCounts();
		    integer onTimeCount     = 0;
		    integer urgentCount     = 0;
		    integer overdueCount    = 0;
		    
		    if (ld.OwnerId == currentUserId){
		        if (ld.TECH_TreatmentPriorityLabel__c == LEAD_PRIORITY_ONTIME) {onTimeCount ++;}
		        else if (ld.TECH_TreatmentPriorityLabel__c == LEAD_PRIORITY_URGENT) {urgentCount ++;}
		        else {overdueCount ++;}
		    } 
		    else{
		        lc.countOnTime  = onTimeCount;
		        lc.countUrgent  = urgentCount;
		        lc.countOverdue = overdueCount;
		        userLeadCounts.put(ld.Id, lc);
		        currentUserId   = ld.OwnerId; 
		    }
		}
		System.debug('userLeadCounts: ' + userLeadCounts);
		return userLeadCounts;
	}    

    /**
     * This method is used to return a list of records from the specified object
     * @param ObjectName - The API name of object
     * @param fieldstoget - Fields to get from the object
     * @param pageNumber - Number of the page to display
     * @param pageSize - Number of records displayed per page
     * @param whereClause - Where clause
     */ 
    @AuraEnabled public static CSResultWrapper getRecords(String objectname, 
                                                          String fieldstoget,
                                                          String labelFields,
                                                          decimal pageNumber, 
                                                          String pageSize, 
                                                          String order, 
                                                          String filterByActivity,
                                                          Boolean filterByActivityIsList,
                                                          String filterByPriority,
                                                          String filterByStatus,
                                                          Boolean filterByCurrentUser,
                                                          String whereClause){
    	
    	System.debug('Start of LMAResultController.getRecords...');
    	System.debug(':::objectname: ' + objectname); 
        System.debug(':::fieldstoget: ' + fieldstoget);
        System.debug(':::pageNumber: ' + pageNumber);
        System.debug(':::pageSize: ' + pageSize);
        System.debug(':::order: ' + order);
        System.debug(':::filterByActivity: ' + filterByActivity);
        System.debug(':::filterByStatus: ' + filterByStatus);
        System.debug(':::filterByPriority: ' + filterByPriority);
        System.debug(':::filterByCurrentUser: ' + filterByCurrentUser);
        System.debug(':::whereClause: ' + whereClause);
    	
       	integer MAX_LIMIT       = 2000;
        CSResultWrapper ltw     = new CSResultWrapper();
        
       	if (integer.valueOf(pageSize) > MAX_LIMIT) {
           pageSize             = String.valueOf(MAX_LIMIT);
        }
        integer offset          = (integer.valueOf(pageNumber) - 1) * integer.valueof(pageSize);
        
        Map<String,Boolean> fieldLabelMap = new Map<String,Boolean>();
        List<String> fieldList  = fieldstoget.split(',');
        labelFields             = labelFields + ','; // prevent fatal error if field is empty
        List<String> fieldLabelList = labelFields.split(',');
        
        for (String field : fieldLabelList) {
        	fieldLabelMap.put(field,true);
        }

        Integer lastRow         = fieldList.size();
        Integer rowCount        = 0;
        
        String queryString      = 'SELECT ';
        for (String field : fieldList) {
            if (fieldLabelMap.ContainsKey(field)) {
                queryString     = queryString +  'toLabel(' + field + ')';
            } else {
                queryString     = queryString + field + '';
            }
            rowCount ++;
            if (rowCount < lastRow) queryString = queryString + ',';
        }
        
        queryString             = queryString + ' FROM '+ String.escapeSingleQuotes(objectname);
		
        if (String.isBlank(whereClause)) {
        	whereClause         = ' WHERE Id != null ';
        }
        if (String.isNotBlank(filterByActivity)) {
        	if (filterByActivityIsList) {
        		whereClause     = whereClause + ' AND Activity__c IN ' + filterByActivity + ' ';
        	} else {
        		whereClause     = whereClause + ' AND Activity__c = \'' + filterByActivity + '\' ';
        	}
        }
        if (String.isNotBlank(filterByPriority)) {
        	whereClause         = whereClause + ' AND TECH_TreatmentPriorityLabel__c = \'' + filterByPriority + '\' ';
        }
        if (String.isNotBlank(filterByStatus)) {
            /* Start: RFL - C1STAGILE-9109 Added support to multiple status */
            if (filterByStatus.indexOf(',')>1) {
        		whereClause     = whereClause + ' AND Status IN ' + filterByStatus + ' ';
        	} else {
        		whereClause     = whereClause + ' AND Status = \'' + filterByStatus + '\' ';
        	}
            /* End Change - C1STAGILE-9109 */
        }
        if (filterByCurrentUser) {
        	String currentUserId= UserInfo.getUserID();
        	whereClause         = whereClause + ' AND OwnerId =  \'' + currentUserId + '\' ';    
        } else{
          if(LeadMetricsHeaderController.getUserPortalRole()=='Manager' && String.isNotBlank(filterByPriority)){
            String currentUserId= UserInfo.getUserID();
            whereClause         = whereClause + ' AND OwnerId !=  \'' + currentUserId + '\' ';
          }
        }
        queryString = queryString + whereClause;
                                                         
        queryString += ' ORDER BY ' + order + ' NULLS last '  +
            ' Limit '+ String.escapeSingleQuotes(pageSize) +
            ' Offset '+offset; 
        System.debug('queryString: ' + queryString);
        if (String.isNotBlank(whereClause)) {
            ltw.total = database.countQuery('SELECT count() FROM ' + String.escapeSingleQuotes(objectname) + whereClause);
        } else {
            ltw.total = database.countQuery('SELECT count() FROM ' + String.escapeSingleQuotes(objectname));
        }
        ltw.page      = Integer.valueOf(pageNumber);
        //Newly addded for C1STRUN-627 --- Satya
        Integer pageStart       = 1;
        Integer pageSizeValue   = Integer.valueOf(pageSize) * ltw.page;
        Integer pageEnd         = ltw.total >= pageSizeValue ? pageSizeValue : ltw.total;
        ltw.pageEnd             = pageEnd;
        //Newly added end
        try {
            ltw.sObjectrecords = database.query(queryString);
            System.debug('## RESULTS : ' + ltw.sObjectrecords);
        } catch(dmlexception e) {
            System.debug('## getRecords --> ERROR : ' + e.getMessage());
        } catch (Exception e){
            System.debug('### getRecords Error--> ' + e.getMessage());
        }
        return ltw;
    }
     /**
     * This method is used to return a list of the labels for the fields
     * @param objectname - Specify the API name of object to get the labels from
     * @param fields - List of fields whose labels we need to return
     */ 
    @AuraEnabled
    public static List<FieldAndLabelWrapper> getFieldLabels(String objectname,String relobjectname, List<String> fields) {
    	System.debug('Start of LMAResultController.getLabels...');
        List<String> labelsToShow = new List<String>();

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
            	//System.debug('::::fieldName: ' + fieldName);
                if(fieldObjMap.containsKey(fieldName.trim())){
                    labelsToShow.add(fieldObjMap.get(fieldName.trim()).getDescribe().getLabel());
                }else if( fieldName == 'Owner.Name'){
                    labelsToShow.add(fieldObjMap.get('OwnerId').getDescribe().getLabel());
                }else if( fieldName == 'UserRecordAccess.HasReadAccess'){
                    labelsToShow.add(fieldUsrMap.get('HasReadAccess').getDescribe().getLabel());
                }else if (fieldRelMap!=null && !fieldRelMap.isEmpty()){
                    //system.debug('getLabels.fieldRelMap.indexOf() --> ' + fieldName.indexOf('.')  + ' | ' + fieldName);
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
        
		List<FieldAndLabelWrapper> fieldAndLabelRecords = new List<FieldAndLabelWrapper>();  
   
		Integer i = 0;
        for (String field : fields) {
        	FieldAndLabelWrapper FALRecord  = new FieldAndLabelWrapper();
            FALRecord.name                  = field;
            FALRecord.label                 = labelsToShow[i];
            fieldAndLabelRecords.add(FALRecord);
            i++;
        }
        //System.debug('::::labelsToShow: ' + fieldAndLabelRecords);
        return fieldAndLabelRecords;
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
            	//System.debug('::::fieldName: ' + fieldName);
                if(fieldObjMap.containsKey(fieldName.trim())){
                    labelsToShow.add(fieldObjMap.get(fieldName.trim()).getDescribe().getLabel());
                }else if( fieldName == 'Owner.Name'){
                    labelsToShow.add(fieldObjMap.get('OwnerId').getDescribe().getLabel());
                }else if( fieldName == 'UserRecordAccess.HasReadAccess'){
                    labelsToShow.add(fieldUsrMap.get('HasReadAccess').getDescribe().getLabel());
                }else if (fieldRelMap!=null && !fieldRelMap.isEmpty()){
                    //system.debug('getLabels.fieldRelMap.indexOf() --> ' + fieldName.indexOf('.')  + ' | ' + fieldName);
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

    @AuraEnabled 
    	 
    public static DataTableResponse getfetchRecords(String sObjectName, String sFieldstoget, String sWhereClause){
    	System.debug('Start of LMAResultController.getfetchRecords...');
        
        // First Step. Columns
        List<String> lstfieldstoget                         = sFieldstoget.split(',');
        List<DataTableColumns> lstTableColumn               = new list<DataTableColumns> ();
        
        DescribeSObjectResult objResult                     = Schema.getGlobalDescribe().get(sObjectName).getDescribe();

        for(String field : lstfieldstoget){
            DescribeFieldResult fieldResult                 = objResult.fields.getMap().get(field).getDescribe();
            lstTableColumn.add(new DataTableColumns(fieldResult.getLabel(),fieldResult.getName(),String.valueof(fieldResult.getType()).toLowerCase(),true));
        }
        // Second Step, Values

        String queryString = 'SELECT '+ String.escapeSingleQuotes(sFieldstoget) + 
                             ' FROM '+ String.escapeSingleQuotes(sObjectName);
        System.debug(sWhereClause);           
        if (sWhereClause != null && sWhereClause != '') {
            queryString += ' WHERE ' + sWhereClause;
        }
       
        System.debug(queryString);
       
        queryString     = 'SELECT '+ String.escapeSingleQuotes(sFieldstoget) + 
                             ' FROM '+ String.escapeSingleQuotes(sObjectName) +
                             ' WHERE Id IN: lstRecords';
        
        List<SObject> lstAux;
        try {
            lstAux = database.query(queryString);
        } catch(dmlexception e) {
            system.debug('## getRecords --> ERROR : ' + e.getMessage());
        } catch (Exception e){
            System.debug('### general Error--> ' + e.getMessage());
        }
    
        DataTableResponse ltngTableWrapper                  = new DataTableResponse();
        ltngTableWrapper.lstDataTableData                   = lstAux;
        ltngTableWrapper.lstDataTableColumns                = lstTableColumn;
       
        return ltngTableWrapper;
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

        //Create and set three variables label, fieldname and type as required by the lightning:datatable
        public DataTableColumns(String label, String fieldName, String sType,Boolean bSortable){ //, DataTableColumnsLink dtcAttributes){
            this.label      = label;
            this.fieldName  = fieldName;
            this.type       = sType; 
            this.sortable   = bSortable;
        }
    }
    public class DataTableColumnsLink {
        @AuraEnabled
        public DataTableEntity label {get;set;}
            
        public DataTableColumnsLink(DataTableEntity slabel){
            this.label = slabel;
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
        public List<sObject> lstDataTableData {get;set;}                
        
        public DataTableResponse(){
            lstDataTableColumns     = new List<DataTableColumns>();
            lstDataTableData        = new List<sObject>();
        }
    }
    
    /*
     * @Method          :   setTransferRecords
     * @Author          :   Rubén Fernandez Lopez
     * @Created         :   26/01/2018
     * @Description     :   Transfer selected records to new Owner.
     * @Params          :   sObjectType(String): Type of Object.
     * @Returns         :   string: list of fields to get from the object.
     */	
	
	@AuraEnabled
	public static boolean setTransferRecords(String lstRecordsId, String sOwnerID){
        System.debug('Start of LMAResultController.setTransferRecords...');
		boolean bResult = false;
		system.debug('setTransferRecords ' + lstRecordsId + ' | ' + sOwnerID);
		List<String> selectedIdsList = new List<String>();
		if(lstRecordsId!=null && sOwnerID != null){
			//Object[] listToSave = (Object[])JSON.deserializeUntyped(lstRecordsId);
			List<LeadIds> c = (List<LeadIds>)JSON.deserializeStrict(lstRecordsId,List<LeadIds>.class);
			system.debug('setTransferRecords.values : ' + c);
			if(c.size()>0){         
			    for (LeadIds sId : c) {
			    	system.debug('setTransferRecords.values : ' + string.valueof(sId.value));
			        selectedIdsList.add(string.valueof(sId.value) );
			    }
			}
			
			List<Lead> lRecords = new List<Lead>([SELECT Id, OwnerId FROM Lead where Id IN :selectedIdsList]);
			
			for(Lead obj : lRecords){
				system.debug('setTransferRecords.obj.OwnerId : ' + sOwnerID);
				obj.OwnerId = sOwnerID;
			}
			System.debug('lRecords: ' + lRecords);
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
	public class LeadIds {
    	public String value;
	}
}
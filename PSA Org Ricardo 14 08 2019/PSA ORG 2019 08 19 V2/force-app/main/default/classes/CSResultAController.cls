public without sharing class CSResultAController {
	
/*
-- - Name         : CSResultAController
-- - Author       : DXC. Ruben Fernandez
-- - Date         : 18/01/2018
-- - Description  : This apex class returns the list of records and labels 
					for the specified sObject and fields
--
-- - History:
-- Date         Author  Version  Comments
-- -----------  -----   -------  ---------------------------------------
-- 18/01/2018   DXC     1.0      Initial version rfernandezlo
-- 09/03/2018   GAS     1.2      Replaced SOSL query with database.query.
*/

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
                                                          decimal pageNumber, 
                                                          String pageSize, 
                                                          String order, 
                                                          String whereClause, 
                                                          List<String> whereSOSL){
    	System.debug('Start of CSResultAController.getRecords...');
       
       	integer MAX_LIMIT = 2000;
        CSResultWrapper ltw = new CSResultWrapper();
        
       	if (integer.valueOf(pageSize) > MAX_LIMIT) {
           pageSize = String.valueOf(MAX_LIMIT);
        }
        integer offset = (integer.valueOf(pageNumber) - 1) * integer.valueof(pageSize);
        
        String queryString = 'SELECT '+ String.escapeSingleQuotes(fieldstoget) + 
                             ' FROM '+ String.escapeSingleQuotes(objectname);
        System.debug('whereClause: ' + whereClause);           
        if (whereClause != null && whereClause != '') {
            queryString += ' WHERE ' + whereClause;
            // restrict query to logged in user
            String currentUserId = UserInfo.getUserID();
            queryString = queryString + ' and OwnerId =  \'' + currentUserId + '\' '; 
        }
                                                                                                                             
        queryString += ' ORDER BY ' + order + ' NULLS last '  +
            ' Limit '+ String.escapeSingleQuotes(pageSize) +
            ' Offset '+offset; 
        System.debug('queryString: ' + queryString);
        if (whereClause != null && whereClause != '') {
            ltw.total = database.countQuery('SELECT count() FROM '+String.escapeSingleQuotes(objectname)+ ' WHERE ' + whereClause);
        } else {
            ltw.total = database.countQuery('SELECT count() FROM '+String.escapeSingleQuotes(objectname));
        }
        ltw.page      = Integer.valueOf(pageNumber);
        
        /*
        String sFieldsSOSL  = String.valueof(fieldstoget).left(fieldstoget.length()-31);
        String sWhereSOSL = String.join(whereSOSL,'  OR '); 
        String sQuerySOSL = 'FIND  {' +sWhereSOSL + '}  IN ALL FIELDS Returning ' + objectname + '('+ String.escapeSingleQuotes(sFieldsSOSL) + ' WHERE ' + whereClause + ')'; 
        System.debug('sQuerySOSL: ' + sQuerySOSL);
        */
        
                                                                      
        try {
            ltw.sObjectrecords = database.query(queryString);
            /* List<List<SObject>>searchList=search.query(sQuerySOSL);
            if(!searchList.isEmpty()){
                ltw.sObjectrecords = searchList.get(0);
            }
			*/

             system.debug('## RESULTS : ' + ltw.sObjectrecords);
        } catch(dmlexception e) {
            system.debug('## getRecords --> ERROR : ' + e.getMessage());
        } catch (Exception e){
            System.debug('### getLabels Error--> ' + e.getMessage());
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
    public static List<UserRecordAccess> getRecordAccess(List<Id> lstRecords){
    	System.debug('Start of CSResultAController.getRecordAccess...');
        Id sUserId = UserInfo.getUserId();
        System.debug('getRecordAccess sUserId ' + sUserId);
        return new List<UserRecordAccess>([SELECT RecordId, HasReadAccess, HasTransferAccess, MaxAccessLevel FROM UserRecordAccess WHERE UserId =:sUserId AND RecordId IN :lstRecords]);
    }


     /**
     * This method is used to return a list of the labels for the fields
     * @param objectname - Specify the API name of object to get the labels from
     * @param fields - List of fields whose labels we need to return
     */ 
    @AuraEnabled
    public static List<String> getLabels(String objectname,String relobjectname, List<String> fields) {
    	System.debug('Start of CSResultAController.getLabels...');
        List<String> labelsToShow = new List<String>();

        system.debug('CSResultAController.getLabels.   Param1:objectname ' + objectname + ' Param2:relobjectname--> ' + relobjectname + ' Param3:fields ' + fields);
       
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
    * getSecretQuestion -                                                             
    * @param sId            - Record selected
    * @param sObjectType    - Type of record (B2B, B2C or Dealer)
    * @param sObjectName    - Object name
    */    
    @AuraEnabled
    public static String getSecretQuestion(String sId, String sObjectType, String sObjectName) {
    	System.debug('Start of CSResultAController.getsecretQuestion...');
        String sValue = '';
        if(sObjectType!=null && sObjectType!=''){
            List<CustomerSearchSettings__mdt> lstFields = [SELECT SearchFields__c FROM CustomerSearchSettings__mdt where QualifiedApiName = :sObjectType limit 1];            
            if(lstFields!=null && !lstFields.isEmpty()){
                sValue  = lstFields.get(0).searchfields__c;
            } 
        }
        List<String> aux    = sValue.split(',');    
        Integer iQuestion   = randomWithLimit(aux.size());
		system.debug('### getSecretQuestion ' + sId + ' | ' + sObjectName + ' | ' + iQuestion  + ' | ' +  aux);

        String queryString = 'SELECT '  + String.escapeSingleQuotes(aux.get(iQuestion)) + 
                             ' FROM '	+ String.escapeSingleQuotes(sObjectName) +
            				 ' WHERE Id =\''  + String.escapeSingleQuotes(sId) +'\'';
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
        List<String> lstResult = getLabels(sObjectName, sRelObj, lstFields);
        System.debug('##--> getSecretQuestion.lstResult: ' + lstResult );
        if(!lstResult.isEmpty() && sValue!=null && sValue.length()>0){
            if(sValue.indexOf('@')!=-1){
                sValue = sValue.substringBefore('@');
            }else {
                sValue =  (sValue.length()>3)?sValue.left(sValue.length()-3):sValue.left(sValue.length()-1);
            }
            sValue = sValue  +',' + lstResult.get(0) + ',' + encryptData(sOriginalValue);
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
    	System.debug('Start of CSResultAController.getQuestionResponse...');    
        Boolean bResult = false;
        if(sValue!=null && sValue.length()>0 && sResponse!=null && sResponse.length()>0){
            sValue = decryptData(sValue);
            if(sValue==sResponse){
                bResult = true;
                manualShareRecord(sId, sUserId, 'Read');
            }
        }
        return bResult;
    }
    /**
    * randomWithLimit -                                                             
    * @param upperLimit - Limit ramdom value
    */
    public static Integer randomWithLimit(Integer upperLimit){
    	System.debug('Start of CSResultAController.randomWithLimit...');
        Integer rand = Math.round(Math.random()*1000);
        return Math.mod(rand, upperLimit);
    }
    /**
    * getPartnerUserAccountId - Used to compose lookup filters
    * @param sUserId        - Current User Id
    */    
    
    /*
    @AuraEnabled
    public static String getPartnerUserAccountId(String sUserId) {

        String queryString = 'SELECT Contact.AccountId FROM User ' + 
                             'WHERE Id =\''  + String.escapeSingleQuotes(sUserId) +'\'';
        system.debug('### getPartnerUserAccountId ' + queryString);
        List<sObject> sobjList = new List<sObject>();
        try {
            sobjList = database.query(queryString);
        } catch(dmlexception e) {
            return null;
        }
        return (String)sobjList.get(0).get('AccountId');
    }*/



     public static boolean manualShareRecord(Id recordId, Id userOrGroupId, String sAccessLevel){
    	System.debug('Start of CSResultAController.manualShareRecord...');
      
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


    private static final Blob crypto192Key          = EncodingUtil.base64Decode(PAD.getToken());  
    /**
    * encyptData -                                                             
    * @param decryptedString - String to be encrypted
    */
    public static string encryptData(String decryptedString){
    	System.debug('Start of CSResultAController.encryptData...');
        String base64EncryptedString = '';
        if(decryptedString!=null && decryptedString!=''){
            Blob data               = Blob.valueOf(decryptedString);
            Blob encryptedBlobData  = Crypto.encryptWithManagedIV('AES192', crypto192Key , data );
            base64EncryptedString   = EncodingUtil.base64Encode(encryptedBlobData);
        }
        return base64EncryptedString;
    }    
    /**
    * decryptData -                                                            
    * @param encryptedString - SString to be decrypted
    */
    public static string decryptData(String encryptedString){
    	System.debug('Start of CSResultAController.decryptData...');
        String decryptedString  ='';
        if(encryptedString!=null && encryptedString!=''){
            Blob data               = EncodingUtil.base64Decode(encryptedString);
            Blob decryptedBlobData  = Crypto.decryptWithManagedIV('AES192', crypto192Key , data);
            decryptedString         = decryptedBlobData.toString();
        }
        return decryptedString;
    }

    @AuraEnabled 
    //public static DataTableResponse getfetchRecords(String sObjectName, String sFieldstoget, String sWhereClause, List<String> whereSOSL){
    	 
    public static DataTableResponse getfetchRecords(String sObjectName, String sFieldstoget, String sWhereClause){
    	System.debug('Start of CSResultAController.getfetchRecords...');
        
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
        
        /* 
        String sQuerySOSL   = 'FIND  {' + String.join(whereSOSL,'  OR ') + '}  IN ALL FIELDS Returning ' + 
                            sObjectName + ' ('+ String.escapeSingleQuotes(String.valueof(sFieldstoget).left(sFieldstoget.length()-31)) + 
                            ' WHERE ' + sWhereClause + ')'; 
        system.debug('sQuerySOSL ' + sQuerySOSL);
    
        
        List<SObject> lstObjectResult = new List<sObject>();
        try {
            List<List<SObject>>searchList=search.query(sQuerySOSL);
            if(!searchList.isEmpty()){
                lstObjectResult = searchList.get(0);
            }
             system.debug('## RESULTS : ' + lstObjectResult.size());
        } catch(dmlexception e) {
            system.debug('## getRecords --> ERROR : ' + e.getMessage());
        } catch (Exception e){
            System.debug('### getLabels Error--> ' + e.getMessage());
        }

        
        List<Id> lstRecords = new List<Id>();

        for (sObject o : lstObjectResult){
            lstRecords.add(o.Id);
        }
        
        */
        
        queryString     = 'SELECT '+ String.escapeSingleQuotes(sFieldstoget) + 
                             ' FROM '+ String.escapeSingleQuotes(sObjectName) +
                             ' WHERE Id IN: lstRecords';
        
        //Map<Id,Boolean> mapAux = new Map<Id,Boolean>();
        //for(UserRecordAccess ura : getRecordAccess(lstRecords)){
        //    System.debug('getRecordAccess ' + ura);
        //    mapAux.put(ura.RecordId,ura.HasReadAccess);
        //}
        List<SObject> lstAux;
        try {
            lstAux = database.query(queryString);
            //for(sObject o : lstAux){
            //    o.UserRecordAccess.HasReadAccess = (mapAux.containsKey(o.Id))?mapAux.get((o.Id):false;
            //    system.debug('## RESULTS : ' + ltw.sObjectrecords);
            //}
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
        //@AuraEnabled
        //public DataTableColumnsLink typeAttributes {get;set;}
        
        //Create and set three variables label, fieldname and type as required by the lightning:datatable
        public DataTableColumns(String label, String fieldName, String sType,Boolean bSortable){ //, DataTableColumnsLink dtcAttributes){
            this.label      = label;
            this.fieldName  = fieldName;
            this.type       = sType; 
            this.sortable   = bSortable;
            //if(dtcAttributes!=null){
            //    system.debug('dtcAttributes : ' + dtcAttributes);
            //    this.typeAttributes  = dtcAttributes;
            //}
        }
    }
    //public class DataTableColumnsLink {
    //    @AuraEnabled
    //     public DataTableEntity label {get;set;}
            
    //    //Create and set three variables label, fieldname and type as required by the lightning:datatable
    //    public DataTableColumnsLink(DataTableEntity slabel){
    //        this.label = slabel;
    //    }
    //}
    //public class DataTableEntity {
    //    @AuraEnabled
    //     public String fieldname {get;set;}
            
    //    //Create and set three variables label, fieldname and type as required by the lightning:datatable
    //    public DataTableEntity(String sfieldname){
    //        this.fieldname = sfieldname;
    //    }
    //}
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
}
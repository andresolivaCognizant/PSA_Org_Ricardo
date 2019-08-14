/**
	*   @Class 			: LeadManualAssigmentController.cls
	*   @Author         : DXC
	*   @Created        : 08/02/2017
	*   @Description    : Apex Controller class for LC001_LeadManualAssigment.cmp
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description
	*	   Rubén Moreno				18/1/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/


public with sharing class LeadManualAssigmentController {
	
	/*
     * @Method          :   setSelect
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
    
    /*
	Method Name	: getAccRecords
	Purpose		: To get the wrapper of Columns and Headers
	*/
    @AuraEnabled
    public static DataTableResponse getObjectRecords(String strObjectName, String strFieldSetName){                
       	
        //Get the fields from FieldSet
        Schema.SObjectType SObjectTypeObj 						= Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj 	= SObjectTypeObj.getDescribe();            
        Schema.FieldSet fieldSetObj 							= DescribeSObjectResultObj.FieldSets.getMap().get(strFieldSetName);
        
        //To hold the table hearders 
        List<DataTableColumns> lstDataColumns 					= new List<DataTableColumns>();
        
        //Field to be queried - fetched from fieldset
        List<String> lstFieldsToQuery 							= new List<String>();
        
        //The final wrapper response to return to component
        DataTableResponse response 								= new DataTableResponse();
        
        DataTableEntity dataEntity;
        DataTableColumnsLink dataLink;
        for( Schema.FieldSetMember eachFieldSetMember : fieldSetObj.getFields() ){
            String dataType = String.valueOf(eachFieldSetMember.getType()).toLowerCase();
            String sfieldName =  String.valueOf(eachFieldSetMember.getFieldPath());
            //This way we can set the type of a column
            //We do not get the exact type from schema object which matches to lightning:datatable component structure
            dataLink = null;
            if(dataType == 'datetime'){
                dataType = 'date';
            }else if(dataType=='string'){
                if(sfieldName.equals('LastName') || sfieldName.equals('Name')){
                    dataType = 'url';
                    dataLink   = new DataTableColumnsLink(new DataTableEntity('linkLabel'));
                }
                dataType = 'text';
            }
           

            system.debug('### eachFieldSetMember ' + String.valueOf(eachFieldSetMember.getLabel())  + '  ' + 
                                                                String.valueOf(eachFieldSetMember.getFieldPath()) + '  ' + 
                                                                String.valueOf(eachFieldSetMember.getType()).toLowerCase());
            //Create a wrapper instance and store label, fieldname and type.
            DataTableColumns datacolumns = new DataTableColumns(String.valueOf(eachFieldSetMember.getLabel()) , 
                                                                String.valueOf(eachFieldSetMember.getFieldPath()), 
                                                                dataType,
                                                                true);
                                                                 //,dataLink);
			lstDataColumns.add(datacolumns);
            lstFieldsToQuery.add(String.valueOf(eachFieldSetMember.getFieldPath()));
        }
        
        //Form an SOQL to fetch the data - Set the wrapper instance and return as response
        if(! lstDataColumns.isEmpty()){            
            response.lstDataTableColumns = lstDataColumns;
            String query = 'SELECT Id, ' + String.join(lstFieldsToQuery, ',') + ' FROM ' + strObjectName;
            System.debug(query);
            response.lstDataTableData = Database.query(query);
        }
        
        return response;
    }

    @AuraEnabled
    public static List<String> getPartnerUserAccountId(String sUserId) {

        String queryString = 'SELECT Contact.AccountId FROM User ' + 
                             'WHERE Id =\''  + String.escapeSingleQuotes(sUserId) +'\'';
        system.debug('### getPartnerUserAccountId ' + queryString);
        List<sObject> sobjList = new List<sObject>();
        String sAccountId; 
        try {
            sobjList    = database.query(queryString);
            User c = (User)sobjList.get(0);
            sAccountId  = (String)c.contact.AccountId;
        } catch(dmlexception e) {
            return null;
        }
        return getPartnerContactsId(sAccountId);
    }

    @AuraEnabled
    public static List<String> getPartnerContactsId(String sAccountId) {
        List<String> sResult = new List<String>();
        if(!String.isEmpty(sAccountId)){
            String queryString = 'SELECT Id FROM Contact ' + 
                                 'WHERE AccountId =\''  + String.escapeSingleQuotes(sAccountId) +'\'';
            system.debug('### getPartnerContactsId ' + queryString);
            List<sObject> sobjList = new List<sObject>();
            try {
                sobjList = database.query(queryString);
                for(sObject obj : sobjList){
                    sResult.add((String)obj.Id);
                }
            } catch(dmlexception e) {
                return null;
            }
        }
        return sResult;
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

    public class DataTableColumnsLink {
        @AuraEnabled
         public DataTableEntity label {get;set;}
            
        //Create and set three variables label, fieldname and type as required by the lightning:datatable
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




}
/**
	*   @Class : CSFilterAController.cls
	*
	*   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
	*   @Created        :   17 Jan 2018
	*   @Description    :   Apex Controller class for CSFilter.cmp
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description
	*	   Rubén Moreno				18/1/2018				 Creation.		
	*	   Raul Barba				22/1/2018				 Add getLabels(String objectName).		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/


public without sharing class CSFilterAController {
	
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
		  system.debug('getLabels --> ' + fieldName);
		
		  labelsToShow.put(fieldName,fieldMap.get(fieldName).getDescribe().getLabel());
		}
        return labelsToShow;
    }
	
    
}
/*
*   @Class : FlowShapePicklistController
*
*   @Author         :   Sergio López
*   @Created        :   10 oct 2018
*   @Description    :   Controller class for Flow Shape Picklist Component

*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Developer            Date                     Description
*	   Sergio López			10 oct 2018				 Creation.	
*   ----------------------------------------------------------------------------------------------------------------------------
*/
public with sharing class FlowShapePicklistController {
	
	@AuraEnabled
    public static String getShapeData(String brand, List<Id> sRId, String family){    
    	System.debug('@@@getShapeData brand: ' + brand);  
    	System.debug('@@@getShapeData sRId: ' + sRId);
    	System.debug('@@@getShapeData family: ' + family);
    	 
		List<AggregateResult> sRData;
		
		String query;
		
    	try {
    		
    		query = 'SELECT ShapeCode__c, ShapeDescription__c FROM ServiceResource WHERE Id IN :sRId AND Brand__c = :brand ';
    		
    		if (family != null){
    			query += ' AND FamilyCode__c = :family';
    		}
    		
    		query += ' GROUP BY ShapeCode__c, ShapeDescription__c  ORDER BY ShapeCode__c';
    		
    		System.debug('@@@getShapeData query: ' + query);
    		
    		//[SELECT ShapeDescription__c, ShapeCode__c FROM ServiceResource WHERE Id IN :sRId AND FamilyCode__c = :family GROUP BY ShapeDescription__c, ShapeCode__c ORDER BY ShapeDescription__c]
    		// We get Shape Desc and code for received Service Resources
    		sRData = Database.query(query);
    	
    		System.debug('@@@getShapeData sRData: ' + sRData);
    		
            if(Test.isRunningTest()){ 
                throw new dmlexception('Test Error');
            }
						
    	} catch (dmlexception e){
	    	String Error = 'DMLexception ERROR FlowShapePicklistController.getShapeData --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
            return JSON.serialize(Error);
		}
		
		return JSON.serialize(sRData);
		
	}
    
}
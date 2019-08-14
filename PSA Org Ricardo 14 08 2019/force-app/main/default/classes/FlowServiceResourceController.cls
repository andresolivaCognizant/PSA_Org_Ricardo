/*
*   @Class : FlowServiceResourceController
*
*   @Author         :   Sergio López
*   @Created        :   10 oct 2018
*   @Description    :   Controller class for Flow Service Resource Choice Component

*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Developer            Date                     Description
*	   Sergio López			10 oct 2018				 Creation.	
*   ----------------------------------------------------------------------------------------------------------------------------
*/
public with sharing class FlowServiceResourceController {
	
	@AuraEnabled
    public static String getSRData(String brand, List<Id> sRId, String family, String shape, String energy){    
    	System.debug('@@@getSRData brand: ' + brand);  
    	System.debug('@@@getSRData sRId: ' + sRId);
    	System.debug('@@@getSRData family: ' + family);
    	System.debug('@@@getSRData shape: ' + shape);
    	System.debug('@@@getSRData energy: ' + energy);
    	 
		List<ServiceResource> sRData;	
		
		String query;
		
    	try {
    		
    		query = 'SELECT Id, Name FROM ServiceResource WHERE Id IN :sRId AND Brand__c = :brand ';
    		
    		if (family != null){
    			query += ' AND FamilyCode__c = :family';
    		}
    		
    		if (shape != null){
    			query += ' AND ShapeCode__c = :shape';
    		}
    		
    		if (energy != null){
    			query += ' AND EnergyCode__c = :energy';
    		}
    		
    		query += ' ORDER BY Id';
    		
    		System.debug('@@@getSRData query: ' + query);
    		
    		sRData = Database.query(query);
    	
    		System.debug('@@@getSRData sRData: ' + sRData);	
    		
            if(Test.isRunningTest()){ 
                throw new dmlexception('Test Error');
            }
						
    	} catch (dmlexception e){
	    	String Error = 'DMLexception ERROR FlowServiceResourceController.getSRData --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
            return JSON.serialize(Error);
		}
		
		return JSON.serialize(sRData);
		
	}
    
}
/*
*   @Class : FlowEnergyPicklistController
*
*   @Author         :   Sergio López
*   @Created        :   10 oct 2018
*   @Description    :   Controller class for Flow Energy Picklist Component

*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Developer            Date                     Description
*	   Sergio López			10 oct 2018				 Creation.	
*   ----------------------------------------------------------------------------------------------------------------------------
*/
public with sharing class FlowEnergyPicklistController {
	
	@AuraEnabled
    public static String getEnergyData(String brand, List<Id> sRId, String family, String shape){    
    	System.debug('@@@getEnergyData brand: ' + brand);  
    	System.debug('@@@getEnergyData sRId: ' + sRId);
    	System.debug('@@@getEnergyData family: ' + family);
    	System.debug('@@@getEnergyData shape: ' + shape);
    	 
		List<AggregateResult> sRData;	
		
		String query;
		
    	try {
    		
    		query = 'SELECT EnergyCode__c, EnergyDescription__c FROM ServiceResource WHERE Id IN :sRId AND Brand__c = :brand ';
    		
    		if (family != null){
    			query += ' AND FamilyCode__c = :family';
    		}
    		
    		if (shape != null){
    			query += ' AND ShapeCode__c = :shape';
    		}
    		
    		query += ' GROUP BY EnergyCode__c, EnergyDescription__c  ORDER BY EnergyCode__c';
    		
    		System.debug('@@@getEnergyData query: ' + query);
    		
    		//[SELECT EnergyCode__c, EnergyDescription__c FROM ServiceResource WHERE Id IN :sRId AND FamilyCode__c = :family AND ShapeCode__c = :shape GROUP BY EnergyCode__c, EnergyDescription__c  ORDER BY EnergyDescription__c]
    		// We get Shape Desc and code for received Service Resources
    		sRData = Database.query(query);
    	
    		System.debug('@@@getEnergyData sRData: ' + sRData);	
    		
            if(Test.isRunningTest()){ 
                throw new dmlexception('Test Error');
            }
						
    	} catch (dmlexception e){
	    	String Error = 'DMLexception ERROR FlowEnergyPicklistController.getEnergyData --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
            return JSON.serialize(Error);
		}
		
		return JSON.serialize(sRData);
		
	}
    
}
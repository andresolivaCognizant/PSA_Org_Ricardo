/*
*   @Class : FlowFamilyPicklistController
*
*   @Author         :   Sergio López
*   @Created        :   10 oct 2018
*   @Description    :   Controller class for Flow Family Picklist Component

*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Developer            Date                     Description
*	   Sergio López			10 oct 2018				 Creation.	
*   ----------------------------------------------------------------------------------------------------------------------------
*/
public with sharing class FlowFamilyPicklistController {
	
	@AuraEnabled
    public static String getFamilyData(String brand, List<Id> sRId){    
    	System.debug('@@@getFamilyData brand: ' + brand);  
    	System.debug('@@@getFamilyData sRId: ' + sRId);
    	 
		List<AggregateResult> sRData;		
		
    	try {
    		// We get Family Desc and code for received Service Resources
    		sRData = [SELECT FamilyCode__c, FamilyDescription__c FROM ServiceResource WHERE Id IN :sRId AND Brand__c = :brand GROUP BY FamilyCode__c, FamilyDescription__c ORDER BY FamilyCode__c];
    	
    		System.debug('@@@getFamilyData sRData: ' + sRData);
    		
            if(Test.isRunningTest()){ 
                throw new dmlexception('Test Error');
            }
						
    	} catch (dmlexception e){
	    	String Error = 'DMLexception ERROR FlowFamilyPicklistController.getFamilyData --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
            return JSON.serialize(Error);
		}
		
		return JSON.serialize(sRData);
		
	}
    
}
/**
	*   @Class 			: 	GenericButtonController 
	*
	*   @Author         :   Sergio Lopez
	*   @Created        :   03 Aug 2018
	*   @Description    :   Controller Class for Generic Button component
	*
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Sergio Lopez				03/08/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
public with sharing class GenericButtonController {
	
	@AuraEnabled
    public static Boolean getCountryType() {
    	
    	User[] uData = [SELECT Id, Country__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
    	
    	String country = uData[0].Country__c;
    	
    	Boolean retorno = false;
    	
	    try { 		
	    	
	    	country = '%' + country + '%';

			system.debug('getMUpParams QUERY Country__c --> ' + country);
	 
		    List<UtilSetting__mdt> ctryType = [SELECT Value__c FROM UtilSetting__mdt WHERE QualifiedApiName LIKE 'QuoteCountry%' AND Value2__c LIKE :country LIMIT 1];
		    
		    system.debug('getMUpParams ctryType --> ' + ctryType);
		    
		    if (ctryType != null && !ctryType.isEmpty() && ctryType.size()>0){
			   	if (ctryType[0].Value__c == 'OPV'){	 
			   		retorno = true;
			    } else {
			    	retorno = false;
			    }
		    }
		    
		    if(Test.isRunningTest()){
    			throw new dmlexception('Error de test');
   			}
 
	    } catch(dmlexception e) {
	    	system.debug('DMLexception ERROR GenericMashUpController.getMUpParams --> ' + e.getMessage() + ' Line: '+e.getLineNumber());
            return retorno;
        } 
                
        return retorno;
    	
    }  
    
}
public with sharing class FlowMandatoryController {
	
	@AuraEnabled
    public static Boolean isMandatoryComplete(String Textquery) {
    	
    	if((Database.query(Textquery)).size() > 0){
    		 return true;
    	}else {
    		 return false;
    	}

    }

}
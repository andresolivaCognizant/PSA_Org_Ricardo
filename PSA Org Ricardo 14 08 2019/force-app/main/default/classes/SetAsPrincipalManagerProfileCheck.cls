global without sharing class SetAsPrincipalManagerProfileCheck {
	
	@InvocableMethod(
        label       = 'Set As Principal Manager Profile Check'
        description = 'Checks NO other Manager with same profile checked as Principal'
    )
    
	global static List<flowOutputs> checkProfile (List<flowInputs> requests){
		
		system.debug('## CheckProfile: '+requests);
		
		List<flowOutputs> lResult 	= new List<flowOutputs>();
		       
        for(flowInputs usr : requests){  
     		lResult.add(invokeLocalMethod(usr));
     	}
		
		return lResult;
		
	}
	
	public static flowOutputs invokeLocalMethod(flowInputs request){
		
		flowOutputs returnDetails 	= new flowOutputs();
		
		List<User> chkOthPpal 		= new List<User>();
		     			
		String userPrName;
		
		List<User> lUser = [SELECT Id, Profile.Name, Contact.AccountId FROM User WHERE ContactId = :request.recordId Limit 1]; 		
				
		if (!lUser.isEmpty()){
			String dealerId 	= lUser[0].Contact.AccountId;
			String profile 		= lUser[0].Profile.Name;		
			String vldProfile 	= '%'+profile+'%'; 
			
			//Check valid Profile to set as Principal
			UtilSetting__mdt[] util = [SELECT Value__c FROM UtilSetting__mdt WHERE DeveloperName = 'Principal_Manager_Valid_Profiles' AND Value__c LIKE :vldProfile Limit 1];
			
			if (!util.isEmpty()){
				chkOthPpal = [SELECT Id, Name FROM User WHERE Contact.AccountId = :dealerId AND Profile.Name = :profile AND Contact.SetAsPrincipalManager__c = true Limit 1];
			} else {
				returnDetails.ppalManagerName = 'Invalid Profile'; 
			}
		}
		
		if (!chkOthPpal.isEmpty()){
			if (lUser[0].Id != chkOthPpal[0].Id){
				for (User usr : chkOthPpal){
					returnDetails.ppalManagerName = usr.Name;
				}
			}
		}
		
		return returnDetails;
	}
	
	global class flowInputs {

        @InvocableVariable(
            label           = 'Record ID'
            description     = 'The record to be processed'
            required        = true
        )
        
        global String recordId;

    }
    
	global class flowOutputs {

        @InvocableVariable(
            label           = 'Principal Manager Name'
            description     = 'Principal Manager Name'
        )
        
        global String ppalManagerName;

    }    
    
}
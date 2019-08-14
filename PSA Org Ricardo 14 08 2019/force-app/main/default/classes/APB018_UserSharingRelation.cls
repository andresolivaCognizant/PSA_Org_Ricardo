/**
	*   @Class 			: 	APB018_UserSharingRelation 
	*
	*   @Author         :   Sergio Lopez
	*   @Created        :   08 Nov 2018
	*   @Description    :   Batch Class for Create or Modify User Sharing Relation with their public groups
	*
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Sergio Lopez				08/11/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/ 

global class APB018_UserSharingRelation implements Database.Batchable<sObject> {
	 
	global Database.QueryLocator start(Database.BatchableContext BC) { 
		String query = 'SELECT Id, Contact.Account.TECH_PublicGroupsContract__c';
            query += ' FROM User ';
            
            if  (Test.isRunningTest()){
            	query += + ' WHERE Contact.Account.RecordType.Name  = \'Dealer\' AND IsActive = true LIMIT 100';
            } else {
            	query += + ' WHERE Contact.Account.RecordType.Name  = \'Dealer\' AND Contact.Account.TECH_PublicGroupsContract__c != null AND IsActive = true ';
            }
             
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<User> scope) { 
   		
   		List<User> lUser = new List<User> (); 
        List<UserShare> uShare = new List<UserShare> ();
   		   		
		for(User l : scope){  
			lUser.add(l);   
		} 
		
		
		if(!lUser.isEmpty()){ 
			try { 
				system.debug('## lUser: '+lUser);
                String pGroup;
                String[] idGroup;
                
                if  (Test.isRunningTest()){
                	pGroup = [Select Id from Group Where DeveloperName = 'TestGroup' Limit 1].Id;
                }
                
				for (integer i=0;i<lUser.size();i++) {
					if  (!Test.isRunningTest()){
                    	pGroup = lUser[i].Contact.Account.TECH_PublicGroupsContract__c;
					}
					
                    system.debug('## pGroup: '+pGroup);
                    idGroup = pGroup.split(';');
                    system.debug('## idGroup: '+idGroup);
                    
                    for (integer ius=0;ius<idGroup.size();ius++) {
                        UserShare us = new UserShare ();
                        us.RowCause = 'Manual';
                        us.UserAccessLevel = 'Read';
                        us.UserId = lUser[i].Id;
                        us.UserOrGroupId = idGroup[ius];
                        
                        uShare.add(us);
                	}    
				}
				
                system.debug('## uShare: '+uShare);
				Database.SaveResult[] urList = Database.insert(uShare, false); 
				
				// Iterate through each returned result
				for (Database.SaveResult ur : urList) {
				    if (ur.isSuccess()) {
				        // Operation was successful, so get the ID of the record that was processed
				        System.debug('Successfully uShare ID: ' + ur.getId());
				        System.debug('Successfully ur: ' + ur);
				        System.debug('Successfully upsert uShare: ' + uShare);
				    }
				    else {
				        // Operation failed, so get all errors                
				        for(Database.Error err : ur.getErrors()) {
				            System.debug('The following error has occurred.');                    
				            System.debug(err.getStatusCode() + ': ' + err.getMessage());
				            System.debug('UShare fields that affected this error: ' + err.getFields());
				        }
				    }
				}
				
				
			} catch(dmlexception e) {
		    	string error = 'DMLexception ERROR APB018_UserSharingRelation --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
		    	system.debug('Error: '+error);
	        }  catch(exception e){
	        	string error = 'Exception ERROR APB018_UserSharingRelation --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
	            system.debug('Error: '+error);
	        } 
		}			
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}
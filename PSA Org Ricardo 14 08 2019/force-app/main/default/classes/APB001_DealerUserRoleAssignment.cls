/**
	*   @Class : APB001_DealerUserRoleAssignment
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   06 Feb 2018
	*   @Description    :   Batch to get the Aftersales Manager, Sales Manager and Sales Manager Agent to the Account using
							the 3 custom fields TECH_SalesManager__c, TECH_AfterSalesManager__c and TECH_SalesManagerAgent__c.
							Those who do not find will be searched in the following bath process (APB002_DealerUserRoleAssignmentLink) 
							in the related partner accounts through the custom object PartnerAccountLink__c
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Raul Barba				06/2/2018				 Creation.		
	* 	   Sergio Lopez				12/12/2018               Modify: Now it is used as reference of principal Sales Manager, After Sales Manager 
	*															and Sales Manager Agent those who were flagged as principal.
	*															In case of NO After Sales Manager flagged as principal or active it is assigned the Sales Manager.
	*															In case of NO Sales MAnager Agent flagged or active it is assigned a Sales Manager from PartnerAccountLink__c (Provider).
    *      Sergio Lopez             25/04/2019               C1STAGILE-7912: GeoSite with RAFlag_c = TRUE AND PRFlag_c= TRUE AND AgentFlag_c= TRUE and with a record in Partner Account Link where 
    *                                                        the Subscriber Id has VNFlag__c = TRUE and the relation is active--> 
    *                                                        update TECH_SalesManager with the TECH_SalesManager of the Subscriber
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
public class APB001_DealerUserRoleAssignment implements Database.Batchable<sObject>, Database.Stateful{
	    
	public List<Account> lAccAfterSM;
    public List<Account> lAccSMAgent;
       
    public Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('## APB001_DealerUserRoleAssignment START');
        
        String query = 'SELECT Id, Name, TECH_SalesManager__c, TECH_AfterSalesManager__c, TECH_SalesManagerAgent__c, TECH_AfterSalesManager__r.Profile.Name, TECH_SalesManagerAgent__r.Profile.Name, '
        			 + 'TECH_SalesManager__r.Contact.SetAsPrincipalManager__c, TECH_SalesManager__r.isActive, VNContractNumber__c, PRFlag__c, RAFlag__c, AgentFlag__c, '
        			 + 'TECH_AfterSalesManager__r.Contact.SetAsPrincipalManager__c, TECH_AfterSalesManager__r.isActive, TECH_SalesManagerAgent__r.Contact.SetAsPrincipalManager__c, TECH_SalesManagerAgent__r.isActive '
        			 + 'FROM Account '
        			 + 'WHERE IsPartner = TRUE ' 
        			 + 'AND ' 
        			 + '((TECH_SalesManager__c = null OR TECH_AfterSalesManager__c = null OR TECH_SalesManagerAgent__c = null) '
        			 + 'OR ' 
        			 + '((TECH_SalesManager__c != null AND TECH_SalesManager__r.Contact.SetAsPrincipalManager__c = false) OR '
        			 + ' (TECH_AfterSalesManager__c != null AND TECH_AfterSalesManager__r.Contact.SetAsPrincipalManager__c = false) OR '
        			 + ' (TECH_AfterSalesManager__c != null AND TECH_AfterSalesManager__r.Profile.Name != \'Aftersales_Manager\') OR '
        			 + ' (TECH_SalesManagerAgent__c != null AND TECH_SalesManagerAgent__r.Contact.SetAsPrincipalManager__c = false) OR '
        			 + ' (TECH_SalesManagerAgent__c != null AND TECH_SalesManagerAgent__r.Profile.Name != \'Sales_Manager_Agent\')) ' 
        			 + 'OR ' 
        			 + '(TECH_SalesManager__r.isActive = false OR TECH_AfterSalesManager__r.isActive = false OR TECH_SalesManagerAgent__r.isActive = false)'
        			 + ')';
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> scope){
    	
        System.debug('## APB001_DealerUserRoleAssignment EXECUTE');  
        
        Map<String, User> userMap = new Map<String, User> {};
        Map<String, User> userPpalSMMap = new Map<String, User> {}; 
        Map<String, User> userSMMap = new Map<String, User> {};   
        Map<String, User> userPpalAMMap = new Map<String, User> {};
        Map<String, User> userAMMap = new Map<String, User> {};
        Map<String, User> userSMAMap = new Map<String, User> {};
        Map<String, Account> accMap = new Map<String, Account> {};
        Map<String, User> vnPPSMCNMap = new Map<String, User> {};
        Map<String, User> vnSMCNMap = new Map<String, User> {};
        
        List<Account> lAccToUpd = new List<Account> ();
        List<Account> lASMToUpd = new List<Account> ();
        lAccAfterSM = new List<Account> ();
    	lAccSMAgent = new List<Account> ();
    	
    	Boolean sendToUpd;
    	Boolean sendToB2;
    	Boolean sendToASM;

        // C1STAGILE-7912 - B
        Map<String, Account> accountMap = new Map<String, Account> {};

        for (PartnerAccountLink__c pAccLink : [SELECT Id, SubscriberId__r.Id, ProviderId__r.Id, ProviderId__r.TECH_SalesManager__c 
                                                  FROM PartnerAccountLink__c 
                                                 WHERE SubscriberId__c IN :scope 
                                                   AND ProviderId__r.VNPrincipalSite__c = TRUE 
                                                   AND EndDate__c > TODAY]){
            accountMap.put(pAccLink.SubscriberId__r.Id, pAccLink.ProviderId__r); 
        }
        // C1STAGILE-7912 - E

        try {
	        for (User usr : [SELECT Id, Name, Profile.Name, Contact.Account.Id, Contact.Account.TECH_SalesManager__c, Contact.Account.TECH_AfterSalesManager__c, 
	        					Contact.Account.TECH_SalesManagerAgent__c , Contact.SetAsPrincipalManager__c, 
	        					Contact.Account.VNFlag__c, Contact.Account.VNPrincipalSite__c, Contact.Account.VNContractNumber__c
	        				   FROM User  
	            			  WHERE ContactID != null AND Contact.Account.IsPartner = TRUE AND IsActive = TRUE /*AND Contact.SetAsPrincipalManager__c = TRUE*/
	            		  	    AND Profile.Name IN ('Aftersales_Manager', 'Sales_Manager', 'Sales_Manager_Agent')]){
	            if (usr.Profile.Name == 'Sales_Manager'){
	            	if (usr.Contact.SetAsPrincipalManager__c == true){	            		
	            		userPpalSMMap.put(usr.Contact.Account.Id,usr);
	            			            	
	            		if (usr.Contact.Account.VNFlag__c == true && usr.Contact.Account.VNPrincipalSite__c == true && usr.Contact.Account.VNContractNumber__c != null) {
	            			vnPPSMCNMap.put(usr.Contact.Account.VNContractNumber__c,usr);
	            		}
	            	} else {
	            		userSMMap.put(usr.Contact.Account.Id,usr);
	            		
	            		if (usr.Contact.Account.VNFlag__c == true && usr.Contact.Account.VNPrincipalSite__c == true && usr.Contact.Account.VNContractNumber__c != null) {
	            			vnSMCNMap.put(usr.Contact.Account.VNContractNumber__c,usr);
	            		}
	            	}
	            } else if (usr.Profile.Name == 'Aftersales_Manager'){
	            	if (usr.Contact.SetAsPrincipalManager__c == true){	            		
	            		userPpalAMMap.put(usr.Contact.Account.Id,usr);
	            	} else {
	            		userAMMap.put(usr.Contact.Account.Id,usr);
	            	}
	            } else if (usr.Profile.Name == 'Sales_Manager_Agent'){
	            	userSMAMap.put(usr.Contact.Account.Id,usr);
	            }	 
	              	
			}
	        
	        for (Account acc : scope){
	        	
	        	sendToUpd = false;
	        	sendToB2  = false;
	        	sendToASM = false;
	        	
	        	//system.debug('## APB001_DealerUserRoleAssignment acc: '+acc); 
	        	
	        	// Add Sales Manager
	        	if (acc.TECH_SalesManager__c == null || (acc.TECH_SalesManager__c != null && acc.TECH_SalesManager__r.Contact.SetAsPrincipalManager__c == false) || acc.TECH_SalesManager__r.isActive == false){	        		
	        		// C1STAGILE-7912 - B
                    if (acc.PRFlag__c == true || acc.RAFlag__c == true || acc.AgentFlag__c == true){
                        if (accountMap.containsKey(acc.Id)){	  
                            if (accountMap.get(acc.Id).TECH_SalesManager__c != null){
                                system.debug('## APB001_DealerUserRoleAssignment SM: '+accountMap.get(acc.Id).TECH_SalesManager__c+' Acc: '+acc.Id);
                                acc.TECH_SalesManager__c= accountMap.get(acc.Id).TECH_SalesManager__c;
        			
        				        sendToUpd = true;
                            }
	      		        }
                    }
                    // C1STAGILE-7912 - E

                    // First look for Principal Sales Manager
	        		if (userPpalSMMap.containsKey(acc.Id) && !sendToUpd){
        				system.debug('## APB001_DealerUserRoleAssignment Add PpalSM: '+acc.Id+' Acc Name: '+acc.Name+' // '+userPpalSMMap.get(acc.Id).Id+' User Name: '+userPpalSMMap.get(acc.Id).Name);
        				acc.TECH_SalesManager__c = userPpalSMMap.get(acc.Id).Id;
        			
        				sendToUpd = true;
	        		}
	        		// If NO Sales Manager checked as principal, takes the first one that finds
        			if (userSMMap.containsKey(acc.Id) && !sendToUpd){
        				system.debug('## APB001_DealerUserRoleAssignment Add SM: '+acc.Id+' Acc Name: '+acc.Name+' // '+userSMMap.get(acc.Id).Id+' User Name: '+userSMMap.get(acc.Id).Name);
        				acc.TECH_SalesManager__c = userSMMap.get(acc.Id).Id;
        			
        				sendToUpd = true;
	        		}	  
	        		
	        		// If NO Sales Manager and is NOT Principal VN, search for Principal VN Contract Sales Manager set as PrincipalManager
	        		if (vnPPSMCNMap.containsKey(acc.VNContractNumber__c) && !sendToUpd){
	        			acc.TECH_SalesManager__c = vnPPSMCNMap.get(acc.VNContractNumber__c).Id;
        			
        				sendToUpd = true;
	        		}   	
	        		
	        		// If NO Sales Manager and is NOT Principal VN, search for Principal VN Contract First Sales Manager
	        		if (vnSMCNMap.containsKey(acc.VNContractNumber__c) && !sendToUpd){
	        			acc.TECH_SalesManager__c = vnSMCNMap.get(acc.VNContractNumber__c).Id;
        			
        				sendToUpd = true;
	        		}	
	        	}
	        	
	        	//Add After Sales Manager, if there is NO ASM flagged it is looked Sales Manager flagged for the Dealer, again if there is NO SM flagged a SM is looked into the Dealer 
	        	if (acc.TECH_AfterSalesManager__c == null || (acc.TECH_AfterSalesManager__c != null && acc.TECH_AfterSalesManager__r.Contact.SetAsPrincipalManager__c == false) || acc.TECH_AfterSalesManager__r.isActive == false || (acc.TECH_AfterSalesManager__c != null && acc.TECH_AfterSalesManager__r.Profile.Name != 'Aftersales_Manager')){
	        		sendToASM = true;
		        	// First look for Principal Aftersales Manager
		        	if (userPpalAMMap.containsKey(acc.Id)){
	        			system.debug('## APB001_DealerUserRoleAssignment Add AM: '+acc.Id+' Acc Name: '+acc.Name+' // '+userPpalAMMap.get(acc.Id).Id+' User Name: '+userPpalAMMap.get(acc.Id).Name);
	        			acc.TECH_AfterSalesManager__c = userPpalAMMap.get(acc.Id).Id;
	        			
	        			sendToUpd = true;
	        			sendToASM = false;
			        }
			        // If NO Aftersales Manager checked as principal, takes the first Aftersales Manager active that finds
			        if (sendToASM){
			        	if (userAMMap.containsKey(acc.Id)){
		        			system.debug('## APB001_DealerUserRoleAssignment Add AM: '+acc.Id+' Acc Name: '+acc.Name+' // '+userAMMap.get(acc.Id).Id+' User Name: '+userAMMap.get(acc.Id).Name);
		        			acc.TECH_AfterSalesManager__c = userAMMap.get(acc.Id).Id;
		        			
		        			sendToUpd = true;
		        			sendToASM = false;
				        }			        
				    }
				    // If no Aftersales Manager checked as principal and Aftersales Manager active, looks for a Sales Manager checked as Principal
		        	if (sendToASM){
		        		if (userPpalSMMap.containsKey(acc.Id)){
		        			system.debug('## APB001_DealerUserRoleAssignment Add AS//SM: '+acc.Id+' Acc Name: '+acc.Name+' // '+userPpalSMMap.get(acc.Id).Id+' User Name: '+userPpalSMMap.get(acc.Id).Name);
		        			acc.TECH_AfterSalesManager__c = userPpalSMMap.get(acc.Id).Id;
		        			
		        			sendToUpd = true;	
		        			sendToASM = false;	        			
			        	}
		        	}
				    // If no Aftersales Manager checked as principal, Aftersales Manager active, Sales Manager checked as Principal, looks for first Sales Manager active
		        	if (sendToASM){
		        		if (userSMMap.containsKey(acc.Id)){
		        			system.debug('## APB001_DealerUserRoleAssignment Add AS//SM: '+acc.Id+' Acc Name: '+acc.Name+' // '+userSMMap.get(acc.Id).Id+' User Name: '+userSMMap.get(acc.Id).Name);
		        			acc.TECH_AfterSalesManager__c = userSMMap.get(acc.Id).Id;
		        			
		        			sendToUpd = true;	
		        			sendToASM = false;	        			
			        	}
		        	}
	        	}
	        	
	        	// Add Sales Manager Agent, if there is NO Agent flagged it is looked at PartnerAccountLink__c in APB002_DealerUserRoleAssignmentLink process
	        	if (acc.TECH_SalesManagerAgent__c == null || (acc.TECH_SalesManagerAgent__c != null && acc.TECH_SalesManagerAgent__r.Contact.SetAsPrincipalManager__c == false) || acc.TECH_SalesManagerAgent__r.isActive == false || (acc.TECH_SalesManagerAgent__c != null && acc.TECH_SalesManagerAgent__r.Profile.Name != 'Sales_Manager_Agent')){
		   			if (userSMAMap.containsKey(acc.Id)){	
	        			system.debug('## APB001_DealerUserRoleAssignment Add AS//SM: '+acc.Id+' Acc Name: '+acc.Name+' // '+userSMAMap.get(acc.Id).Id+' User Name: '+userSMAMap.get(acc.Id).Name);
	        			acc.TECH_SalesManagerAgent__c = userSMAMap.get(acc.Id).Id;
	        			
	        			sendToUpd = true;
	        		} else {
	        			sendToB2 = true;
	        		}
	        	}  
	        	 
	        	if (sendToUpd == true){
					lAccToUpd.add(acc);	        		
	        	}
	        	/*if (sendToASM == true){
					lAccAfterSM.add(acc);	        		
	        	}*/
	        	if (sendToB2 == true){
					lAccSMAgent.add(acc);	        		
	        	}
	        }
	        
	        update lAccToUpd;
	        
	        // If No After SM or SM flagged as principal was found, the first SM is looked for the Dealer
	        /*if (!lAccAfterSM.isEmpty()){
	        	Account[] lAcc = [SELECT Id, TECH_SalesManager__c FROM Account WHERE Id = :lAccAfterSM];
	        	
		        for(Account oAcc: lAcc){
		            accMap.put(oAcc.Id, oAcc);
		        }
		        
		        for (Account acc : lAccAfterSM){
		        	if (accMap.containsKey(acc.Id)){
			        	if (accMap.get(acc.Id).TECH_SalesManager__c != null){
			        		acc.TECH_AfterSalesManager__c = accMap.get(acc.Id).TECH_SalesManager__c;
			        		
			        		lASMToUpd.add(acc);
			        	}
		        	}
		        }
	        }
	       
	        update lASMToUpd;*/
	        
		} catch(dmlexception e) {
	    	string error = 'DMLexception ERROR APB001_DealerUserRoleAssignment --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
	    	system.debug('Error: '+error);
        }  catch(exception e){
        	string error = 'Exception ERROR APB001_DealerUserRoleAssignment --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
            system.debug('Error: '+error);
        } 
    }   
    
    public void finish(Database.BatchableContext BC){ 
        System.debug('## APB001_DealerUserRoleAssignment FINISH');
        
        Id batch2JobId = Database.executeBatch(new APB002_DealerUserRoleAssignmentLink(lAccSMAgent));
        //Id batch5JobId = Database.executeBatch(new APB005_DealerUserRoleAssignmentNumber(lAccAfterSM));
    }

}
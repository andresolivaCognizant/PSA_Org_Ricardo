/**
	*   @Class 			: 	OppQuoteLiveProcess 
	*
	*   @Author         :   Sergio Lopez
	*   @Created        :   16 May 2018
	*   @Description    :   Change Opportunity Status taking into account the Quote Record Type
	*
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Sergio Lopez				16/05/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
global with sharing class OppQuoteLiveProcess {
	
	private final static string sSubject = 'The Last Quote for Opportunity has expired';
	
    global static void handleProcess(List<Opportunity> oppList, String rType) { 
    	
    	System.debug( 'OppQuoteLiveProcess oppList: ' + oppList );
    	System.debug( 'OppQuoteLiveProcess rType: ' + rType );
    	
    	List<Opportunity> oppLToUpd  = new List<Opportunity>();
    	
    	Set<Id> setAccId = new Set<Id>();
    	Set<Id> setQteId = new Set<Id>();
    	
    	System.debug( 'OppQuoteLiveProcess oppList: ' + oppList );
    	
    	Set<String> quoteStatus = new Set<String>{'7','6'};
    	Set<String> orderStatus = new Set<String>{'7'};
    	Set<String> quoteRType = new Set<String>{'CPQ Quote','OPV Quote'};
    	Set<String> orderRType = new Set<String>{'CPQ Order Form','OPV Order Form','OPV OrderForm VD','OPV OrderForm VN','OPV OrderForm VO'}; 

		Set<Opportunity> myset = new Set<Opportunity>();
		List<Opportunity> result = new List<Opportunity>();
		myset.addAll(oppList);
		result.addAll(myset);
		
        System.debug( 'OppQuoteLiveProcess myset: ' + myset );
        System.debug( 'OppQuoteLiveProcess result: ' + result );
        
        String qOpp = '';
        
        qOpp += 'SELECT Id,SBQQ__ExpirationDate__c,SBQQ__Status__c,	SBQQ__Account__c,SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.Name, SBQQ__Opportunity2__r.StageName, QuotesWithOrderForms__c';
        qOpp += ' FROM SBQQ__Quote__c';
        qOpp += ' WHERE SBQQ__Opportunity2__c IN :myset';
        
        if (rType == 'Quote'){
        	qOpp += ' AND RecordType.Name IN :quoteRType';
        	qOpp += ' AND (SBQQ__Opportunity2__r.StageName <> \'3\' OR SBQQ__Status__c NOT IN :quoteStatus)';
        } else if (rType == 'OForm'){
        	qOpp += ' AND RecordType.Name IN :orderRType';
        	qOpp += ' AND (SBQQ__Opportunity2__r.StageName <> \'4\' OR SBQQ__Status__c NOT IN :orderStatus)';
        }
        
        System.debug( 'OppQuoteLiveProcess qOpp: ' + qOpp );
        
        List<SBQQ__Quote__c> quoteList = (List<SBQQ__Quote__c>)Database.query(qOpp);
        /*List<SBQQ__Quote__c> quoteList = [SELECT Id,SBQQ__ExpirationDate__c,SBQQ__Status__c,SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.Name, SBQQ__Opportunity2__r.StageName 
        									FROM SBQQ__Quote__c  
        									WHERE SBQQ__Opportunity2__c IN :myset
        									  AND ((RecordType.Name IN :quoteRType AND (SBQQ__Opportunity2__r.StageName <> '3' OR SBQQ__Status__c NOT IN :quoteStatus))
        									   OR  (RecordType.Name IN :orderRType AND (SBQQ__Opportunity2__r.StageName <> '4' OR SBQQ__Status__c NOT IN :orderStatus)))];*/
     	
     	System.debug( 'OppQuoteLiveProcess quoteList: ' + quoteList );

		try {
			
	        if (quoteList.size() > 0){
	        	boolean match = false;
	            
	            for (integer i=0;i<result.size();i++) {
	            	match = false;
	            	
	                for (SBQQ__Quote__c q: quoteList){
	                	System.Debug('Result' + i + ' '+result[i].Id + ' '+ q.SBQQ__Opportunity2__c);
	                    if (q.SBQQ__Opportunity2__c == result[i].Id ){
	                        match = true;
	                        System.debug( 'OppQuoteLiveProcess q.SBQQ__Opportunity2__c: ' + q.SBQQ__Opportunity2__c );
	                		System.debug( 'OppQuoteLiveProcess result[i].Id: ' + result[i].Id );
	                		if (rType == 'OForm'){  
				        		setQteId.add(q.QuotesWithOrderForms__c);
	                		}	
	                    }
	                }                 
	                if (match == true && rType == 'OForm'){
				        /*if (rType == 'Quote'){
				        	result[i].StageName = '2';
				        } else if (rType == 'OForm'){
				        	result[i].StageName = '3';
				        	setAccId.add(result[i].AccountId);			        
				       	}*/
			        	result[i].StageName = '3';
			        	setAccId.add(result[i].AccountId);	
				        	
				        System.debug( 'OppQuoteLiveProcess result[i]: ' + result[i] + '//' + i );   	
	                	oppLToUpd.add(result[i]);
	                }
	                if(rType == 'Quote' && result[i].StageName == '3'){
	                	result[i].StageName = '2';
	                	oppLToUpd.add(result[i]);
	                }
	                
	            }
	
	            System.debug( 'OppQuoteLiveProcess oppLToUpd: ' + oppLToUpd );
	            List<Account> lstAcc = new List<Account> ();
	            
	            lstAcc = [SELECT id,Brand__c,APAccountStatus__c,ACAccountStatus__c,DSAccountStatus__c FROM Account WHERE id IN :setAccId];
	           	
	           	for(Account acc : lstAcc){
	           		if(acc.Brand__c == 'AP'){
	           			acc.APAccountStatus__c = 'Prospect';
	           		}
	           		else if(acc.Brand__c =='AC'){
	           			acc.ACAccountStatus__c = 'Prospect';
	           		}
	           		else if(acc.Brand__c =='DS'){
	           			acc.DSAccountStatus__c = 'Prospect';
	           		}
	           	}
	            
	            update oppLToUpd;
	            
	            System.debug( 'OppQuoteLiveProcess lstAcc: ' + lstAcc );
	            
	            update lstAcc;
	        	
		        // Begin US 12822
		        // If no more Order Forms active for the Quote, it will be moved to Active 
		        if (rType == 'OForm' && setQteId.size() > 0){
		        	// Quotes with other Order Form Active
		        	system.debug('## setQteId: '+setQteId);
		        	
		        	for (SBQQ__Quote__c qtesAct : [SELECT Id, QuotesWithOrderForms__c FROM SBQQ__Quote__c WHERE QuotesWithOrderForms__c IN :setQteId AND SBQQ__Status__c NOT IN :quoteStatus]){
		        		system.debug('## QuotesWithOrderForms__c: '+qtesAct.Id);
		        		setQteId.remove(qtesAct.QuotesWithOrderForms__c);
		        	}	
		        	
		        	if (setQteId.size() > 0){
		        		List <SBQQ__Quote__c> lQteFUpd = [SELECT Id, SBQQ__Status__c FROM SBQQ__Quote__c WHERE Id IN :setQteId];
		        		
		        		for (SBQQ__Quote__c qte : lQteFUpd){
		        			qte.SBQQ__Status__c = '2';
		        		}
		        		
		        		system.debug('## lQteFUpd: '+lQteFUpd);
		        		
		        		for (SBQQ__Quote__c qte : lQteFUpd){
		        			system.debug('## lQteFUpd SBQQ__Status__c: '+qte.SBQQ__Status__c);
		        		}
		        		
		        		update lQteFUpd;
		        	}
		        }
		        // End US 12822             
	            
	            if (rType == 'Quote'){	
		            String sBody = '';
		            
		           	System.debug( 'OppQuoteLiveProcess oppLToUpd: ' + oppLToUpd );
		            
		            for (Opportunity o : oppLToUpd){
		            		    		
		    			System.debug( 'OppQuoteLiveProcess o.Id 1: ' + o.Id );
		    			System.debug( 'OppQuoteLiveProcess Email 1: ' + o.Owner.Email );
		    			
		           		sBody = String.format(Label.QuotesRelatedToOppExpired, new String[]{o.Name});
		    		
		    			System.debug( 'OppQuoteLiveProcess sBody: ' + sBody );
		    			System.debug( 'OppQuoteLiveProcess o.Id 2: ' + o.Id );
		    			System.debug( 'OppQuoteLiveProcess Email 2: ' + o.Owner.Email );
		    		
		    			if (o.Owner.Email != null){
		    				GeneralUtils.sendEmail(o.Owner.Email, sSubject, sBody);
		    			} else {
		    				System.debug( 'OppQuoteLiveProcess Email Opportunity: ' + o.Owner.Email );
		    				System.debug( 'OppQuoteLiveProcess Email Owner: ' + o.OwnerId );
		    				System.debug( 'OppQuoteLiveProcess Opportunity: ' + o.Id );
		    			}
		            }
	            } 
	                 
	        } else {
	     		
	     		for(Opportunity o: result) {
	 				if (rType == 'Quote'){
	 					System.Debug('Opportunity = true');
			        	o.StageName = '2';
			        } else if (rType == 'OForm'){
			        	o.StageName = '3';
			        }   
	 			}
				
				System.debug( 'OppQuoteLiveProcess result: ' + result );
				update result;
				
				if (rType == 'Quote'){			
					String sBody = '';
					
					Set<Id> owners = new Set<Id>();
					
				    for (Opportunity o : result) {
				        owners.add(o.OwnerId);
				    }
				    
				    System.debug( 'OppQuoteLiveProcess owners: ' + owners );
				    
					Map<ID,user> users = new Map<ID,User>([SELECT ID, Email FROM USER WHERE ID IN :owners]);
					
					System.debug( 'OppQuoteLiveProcess users: ' + users );
					
					for (Opportunity o : result){
		           		sBody = String.format(Label.QuotesRelatedToOppExpired, new String[]{o.Name});
		    		
		    			System.debug( 'OppQuoteLiveProcess sBody result: ' + sBody );
		    			
		    			User u = users.get(o.OwnerID);
		    			
		    			System.debug( 'OppQuoteLiveProcess User: ' + u );
		    		
		    			if (u.Email != null){
		    				GeneralUtils.sendEmail(u.Email, sSubject, sBody);
		    			} else {
		    				System.debug( 'OppQuoteLiveProcess Email result: ' + u.Email );
		    				System.debug( 'OppQuoteLiveProcess ownerId result: ' + o.OwnerId );
		    			}
		    				
		            }
				}
				
		        // Begin US 12822
		        // If no more Order Forms active for the Quote, it will be moved to Active 
		        if (rType == 'OForm'){  
	        		List <SBQQ__Quote__c> lQteFUpd = [SELECT Id, QuotesWithOrderForms__c, SBQQ__Status__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c IN :myset AND SBQQ__Status__c NOT IN :quoteStatus];
	        		
	        		for (SBQQ__Quote__c qte : lQteFUpd){
	        			qte.SBQQ__Status__c = '2';
	        		}

	        		update lQteFUpd;
		        }
		        // End US 12822  				
	        }
        } catch (DMLexception e) {
            System.debug('OppQuoteLiveProcess.handleProcess ERROR -->' + e.getMessage() + ' Line: '+e.getLineNumber());
        } catch (Exception e){
            System.debug('OppQuoteLiveProcess.handleProcess ERROR --> ' + e.getMessage() + ' Line: '+e.getLineNumber());
        } 
    }

}
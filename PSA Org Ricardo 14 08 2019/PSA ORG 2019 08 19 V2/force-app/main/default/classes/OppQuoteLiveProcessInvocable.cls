/**
	*   @Class 			: 	OppQuoteLiveProcessInvocable 
	*
	*   @Author         :   Sergio Lopez
	*   @Created        :   27 Apr 2018
	*   @Description    :   Change Opportunity Status from Quote to Negotiation when all Quotes have Expired or Canceled Status
	*						and quote record type is CPQ Quote or OPV Quote
	*
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Sergio Lopez				27/04/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
global with sharing class OppQuoteLiveProcessInvocable {
	
	//private final static string sSubject = 'The Last Quote for Opportunity has expired';
	
	@InvocableMethod(
        label       = 'Opportunities without Live Quotes Process'
        description = 'Check Opps without Live Quotes and change Status from Quote to Negotiation'
    )

    global static void handleProcess(List<Opportunity> oppList) { 
    	
    	// Call process for change stage in opps when Quote Record type is CPQ_Quote or OPV_Quote 
    	
    	OppQuoteLiveProcess.handleProcess(oppList, 'Quote');
    	
    	/*List<Opportunity> oppLToUpd  = new List<Opportunity>();
    	
    	System.debug( 'OppQuoteLiveProcessInvocable oppList: ' + oppList );
    	
    	Set<String> quoteStatus = new Set<String>{'Denied','Expired'};

		Set<Opportunity> myset = new Set<Opportunity>();
		List<Opportunity> result = new List<Opportunity>();
		myset.addAll(oppList);
		result.addAll(myset);
		
        System.debug( 'OppQuoteLiveProcessInvocable myset: ' + myset );
        System.debug( 'OppQuoteLiveProcessInvocable result: ' + result );
        
        List<SBQQ__Quote__c> quoteList = [SELECT Id,SBQQ__ExpirationDate__c,SBQQ__Status__c,SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.Name, SBQQ__Opportunity2__r.StageName 
        									FROM SBQQ__Quote__c  
        									WHERE SBQQ__Opportunity2__c IN :myset
        									  AND (SBQQ__Opportunity2__r.StageName <> '3' OR SBQQ__Status__c NOT IN :quoteStatus)];
     	
     	System.debug( 'OppQuoteLiveProcessInvocable quoteList: ' + quoteList );

        if (quoteList.size() > 0){
        	boolean match = false;
            for (integer i=0;i<result.size();i++) {
            	match = false;
            	
                for (SBQQ__Quote__c q: quoteList){
                	System.debug( 'OppQuoteLiveProcessInvocable q.SBQQ__Opportunity2__c: ' + q.SBQQ__Opportunity2__c );
                	System.debug( 'OppQuoteLiveProcessInvocable result[i].Id: ' + result[i].Id );
                    if (q.SBQQ__Opportunity2__c == result[i].Id ){
                        match = true;
                    }
                }
                
                if (match != true){
                	result[i].StageName = '2';
                	oppLToUpd.add(result[i]);
                } 
                
            }
            System.debug( 'OppQuoteLiveProcessInvocable oppLToUpd: ' + oppLToUpd );
            
            update oppLToUpd;
            
            String sBody = '';
            
            for (Opportunity o : oppLToUpd){
           		sBody = String.format(Label.QuotesRelatedToOppExpired, new String[]{o.Id});
    		
    			System.debug( 'OppQuoteLiveProcessInvocable sBody: ' + sBody );
    			System.debug( 'OppQuoteLiveProcessInvocable Email: ' + o.Owner.Email );
    		
    			GeneralUtils.sendEmail(o.Owner.Email, sSubject, sBody);
            }
                        
        } else {
     		for(Opportunity o: result) {
 				o.StageName = '2';
			}
			
			System.debug( 'OppQuoteLiveProcessInvocable result: ' + result );
			update result;
			
			String sBody = '';
			
			Set<Id> owners = new Set<Id>();
			
		    for (Opportunity o : result) {
		        owners.add(o.OwnerId);
		    }
		    
			Map<ID,user> users = new Map<ID,User>([SELECT ID, Email FROM USER WHERE ID IN :owners]);
			
			for (Opportunity o : result){
           		sBody = String.format(Label.QuotesRelatedToOppExpired, new String[]{o.Id});
    		
    			System.debug( 'OppQuoteLiveProcessInvocable sBody result: ' + sBody );
    			
    			User u = users.get(o.OwnerID);
    			
    			System.debug( 'OppQuoteLiveProcessInvocable Email result: ' + u.Email );
    			System.debug( 'OppQuoteLiveProcessInvocable ownerId result: ' + o.OwnerId );
    		
    			GeneralUtils.sendEmail(u.Email, sSubject, sBody);	
            }
        }*/ 
        
    }

}
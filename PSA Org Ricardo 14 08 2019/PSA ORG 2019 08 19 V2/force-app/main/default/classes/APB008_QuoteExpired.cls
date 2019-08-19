/**
	*   @Class 			: 	APB008_QuoteExpired 
	*
	*   @Author         :   Sergio Lopez
	*   @Created        :   26 Apr 2018
	*   @Description    :   Change Status of Expired Quotes to Expired
	*
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Sergio Lopez				26/04/2018				 Creation.		
	*      Sergio Lopez				15/04/1979               C1STAGILE-8192: Quotes should expire only if its status is "Active". 
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
global class APB008_QuoteExpired implements Database.Batchable<sObject> {
	
	private final static String QUOTE_STATUS 		= '6';
	private final static string UTIL_SETTING 		= 'PSADealerCommunity';
	private final static string sSubject			= 'Last Quote for Opportunity expires the next day';
	 
	global Database.QueryLocator start(Database.BatchableContext BC) {
		String query = 'SELECT Id,SBQQ__ExpirationDate__c,SBQQ__Status__c,SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.StageName ' 
            + ' FROM SBQQ__Quote__c ' 
			// C1STAGILE-8192 - B
            //+ ' WHERE SBQQ__ExpirationDate__c <= TOMORROW AND SBQQ__Status__c NOT IN(\'Expired\', \'Canceled\', \'WithOrderForm\')' ;
			+ ' WHERE SBQQ__ExpirationDate__c <= TOMORROW AND SBQQ__Status__c = \'2\'' ;
			// C1STAGILE-8192 - E
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<SBQQ__Quote__c> scope) {
		System.debug( '@@ APB008_QuoteExpired: ' + scope);	
		
   		List<SBQQ__Quote__c> quotsExpd = new List<SBQQ__Quote__c> ();
   		set<Id> oppQNextExp = new set<Id> ();
		
		for(SBQQ__Quote__c l : scope){
			System.debug( 'l.SBQQ__ExpirationDate__c: ' + l.SBQQ__ExpirationDate__c);
			System.debug( 'l.SBQQ__Opportunity2__c: ' + l.SBQQ__Opportunity2__c);
			System.debug( 'System.today().addDays(1): ' + System.today().addDays(1));

			if (l.SBQQ__ExpirationDate__c < system.today()){
				l.SBQQ__Status__c 			= QUOTE_STATUS;
				quotsExpd.add(l);
			} else if (l.SBQQ__ExpirationDate__c == System.today().addDays(1) && !oppQNextExp.contains(l.SBQQ__Opportunity2__c)){
				oppQNextExp.add(l.SBQQ__Opportunity2__c); 
			}
		}
		
		if(!oppQNextExp.isEmpty()){
			
			System.debug( 'APB008_QuoteExpired oppQNextExp: ' + oppQNextExp);
			
			// Get a list of Opps with Quotes Live after Tomorrow
			List<SBQQ__Quote__c> lExpQuot = [SELECT Id, SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c IN :oppQNextExp AND SBQQ__ExpirationDate__c > TOMORROW AND SBQQ__Status__c NOT IN('Expired', 'Canceled', 'WithOrderForm')];
			
			System.debug( 'APB008_QuoteExpired lExpQuot: ' + lExpQuot);
			
			//Match both list to get opps without quotes live after tomorrow and remove id with quotes live after tomorrow
			for (SBQQ__Quote__c q : lExpQuot){
				System.debug( 'APB008_QuoteExpired q.SBQQ__Opportunity2__c: ' + q.SBQQ__Opportunity2__c );
				
				if (oppQNextExp.contains(q.SBQQ__Opportunity2__c)){
					oppQNextExp.remove(q.SBQQ__Opportunity2__c);
					System.debug( 'APB008_QuoteExpired oppQNextExp: ' + oppQNextExp);
				}
			}
			
			System.debug( 'APB008_QuoteExpired oppQNextExp: ' + oppQNextExp );	
			
			List<Opportunity> lOppToNot = [SELECT Id, Owner.Email FROM Opportunity WHERE Id IN :oppQNextExp];
    	
    		System.debug( 'APB008_QuoteExpired lOppToNot: ' + lOppToNot );
    	
    		String sBody = '';
    		String sLink = '';
    		
    		List<UtilSetting__mdt> lURLCommunity = [SELECT Value__c FROM UtilSetting__mdt where developername = :UTIL_SETTING];
    	
	    	for (Opportunity o : lOppToNot){ 
	    		sLink = (lURLCommunity!=null && !lURLCommunity.isEmpty())?lURLCommunity[0].Value__c+o.Id:'';
	    		sBody = String.format(Label.QuotesRelatedToOppNear, new String[]{sLink}); 
	    		
	    		System.debug( 'APB008_QuoteExpired sBody: ' + sBody );
	    		System.debug( 'APB008_QuoteExpired Email: ' + o.Owner.Email );
	    		
	    		GeneralUtils.sendEmail(o.Owner.Email, sSubject, sBody);
	    	}
			
		}
 
		if(!quotsExpd.isEmpty()){
			System.debug( 'APB008_QuoteExpired quotsExpd: ' + quotsExpd );
			Database.update(quotsExpd,false);
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}
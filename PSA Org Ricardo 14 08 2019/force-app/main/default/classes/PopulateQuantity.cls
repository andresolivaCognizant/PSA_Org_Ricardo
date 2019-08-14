public class PopulateQuantity {
    
    private final static string ORDERFORM_RECORDTYPEID 	= Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('CPQ_Order_Form').getRecordTypeId();
    
    public static void setQuantity(List<SBQQ__Quote__c> lNewQuote){
        List<SBQQ__Quote__c>  lCPQQuote = new List<SBQQ__Quote__c>();
        /*Set<Id> setIdQuote 				= new Set<Id>();
        Set<Id> setIdOpp 				= new Set<Id>();*/
        for(SBQQ__Quote__c oQuote : lNewQuote){
            
            if(oQuote.recordtypeid == ORDERFORM_RECORDTYPEID){
                oQuote.Quantity__C = 1;
                oQuote.SBQQ__Primary__c = false;
                lCPQQuote.add(new SBQQ__Quote__c(id=oQuote.QuotesWithOrderForms__c, SBQQ__Status__c = '5', SBQQ__Primary__c = true));                
				//setIdQuote.add(oQuote.QuotesWithOrderForms__c);
                //setIdOpp.add(oQuote.SBQQ__Opportunity2__c);
            }
            
        }
        /*System.debug('#RM PQ# QuoteTrue: ' +setIdQuote);
        System.debug('#RM PQ# setIdOpp: ' +setIdOpp);*/
        /*for(SBQQ__Quote__c oQuote : [SELECT id,SBQQ__Primary__c FROM SBQQ__Quote__c WHERE ID NOT IN :setIdQuote AND SBQQ__Opportunity2__c IN :setIdOpp  ]){
            System.debug('#RM PQ# QuoteFalse: ' +oQuote.id);
            oQuote.SBQQ__Primary__c = false;
            lCPQQuote.add(oQuote);
        }*/
        
        try{
            
            Database.update(lCPQQuote,true);
            System.debug('#RM PQ# lCPQQuote: ' +lCPQQuote);
        }catch(DmlException e){
			System.debug('DmlException ERROR PopulateQuantity.setQuantity -->' + e.getMessage() + ' Line: '+e.getLineNumber());
        }catch(Exception e){
            System.debug('Exception ERROR PopulateQuantity.setQuantity-->' + e.getMessage() + ' Line: '+e.getLineNumber());
        }
        
    }

}
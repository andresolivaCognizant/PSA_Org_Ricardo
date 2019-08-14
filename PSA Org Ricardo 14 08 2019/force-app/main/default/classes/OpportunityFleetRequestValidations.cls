public with sharing class OpportunityFleetRequestValidations {
    
    private final static id RT_OPPORTUNITYFLEET 				= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Label.RTOppFleetRequest).getRecordTypeId();
	private final static string OPPORTUNITY_OPEN_STAGENAME		= 'FR1';
    
    
        
    
    
    
    public static void blockEdition(List<Opportunity> lNewOpps, map<Id,Opportunity> mapOldOpps){//to call in before update
       
        map<String,String> stagenames = OpportunityUtils.getStages();
        for(Opportunity opp : lNewOpps){
			System.debug('___>> '+mapOldOpps.get(opp.id).Stagename);                        
            if(mapOldOpps.get(opp.id).Recordtypeid == RT_OPPORTUNITYFLEET && mapOldOpps.get(opp.id).Stagename != OPPORTUNITY_OPEN_STAGENAME){
                
                opp.addError(Label.ErrorOppFleetEditon+' '+stagenames.get(mapOldOpps.get(opp.id).Stagename));
                
            }
        }
        
        
    }
        
    public static void validateClone(List<Opportunity> lNewOpps){//to call in before insert
        
        for(Opportunity oOpp : lNewOpps){
            if(oOpp.RecordtypeId == RT_OPPORTUNITYFLEET && oOpp.Stagename != OPPORTUNITY_OPEN_STAGENAME){
                
                oOpp.Stagename = OPPORTUNITY_OPEN_STAGENAME;
                
            }
        }
        
    }
    
    
    
    

}
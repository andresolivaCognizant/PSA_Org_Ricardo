public with sharing class OpportunityFieldsUpdateInvocable {

	@InvocableMethod(
        label       = 'PB: Update Opportunities Fields'
        description = 'Update Opportunities Contract Numbers fields'
    )

	public static void handleRecords (List<ObjectRequest> requests) {
		//TODO: update method return type and input parameters (they do need to be List)
		System.debug( 'OpportunityhandleRecordsInvocable : ' + requests );
		
		Map<Id, Opportunity> mapOpp;
		Map<Id, List<Opportunity>> aux 	= new Map<Id, List<Opportunity>>();
		List<Opportunity> results 		= new List<Opportunity>();
        List<Id> lstRecords 			= new List<Id>();
        List<Opportunity> lstaux 		= new List<Opportunity>();
     	
     	for(ObjectRequest r : requests){
     		lstRecords.add(r.recordId);
     	}
     	
     	if(!lstRecords.isEmpty()){
			mapOpp 		= new Map <Id, Opportunity>([SELECT Id, AccountId, Account.VNContractNumber__c, Account.AgentContractNumber__c , OwnerId, VNContractNumber__c, AgentContractNumber__c FROM Opportunity Where Id IN : lstRecords]);
			lstRecords 	= new List<Id>();
			for(Opportunity opp : mapOpp.values()){
				SObject s = opp;
	     		if(s.getSobject('Account').get('VNContractNumber__c')!=null){
	     			opp.VNContractNumber__c 	= (String)s.getSobject('Account').get('VNContractNumber__c');
	     			results.add(opp);
	     		}else if (s.getSobject('Account').get('AgentContractNumber__c')!=null){
	     			opp.AgentContractNumber__c 	= (String)s.getSobject('Account').get('AgentContractNumber__c');
	     			results.add(opp);
	     		}else{
	     			lstRecords.add(opp.AccountId);
	     		}
	     		if(aux.containsKey(opp.AccountId) ){
	     			lstaux = aux.get(opp.AccountId);
	     		}
	     		lstaux.add(opp);
	     		aux.put(opp.AccountId, lstaux);
	     	}
	     	if(!lstRecords.isEmpty()){
	     		Map<Id,Id> mapAccRel = new Map<Id,Id>();
				for(PartnerAccountLink__c c : [SELECT ProviderId__c,SubscriberId__c From PartnerAccountLink__c Where BeginDate__c<=TODAY AND EndDate__c>=TODAY AND SubscriberId__c IN :lstRecords]){
					mapAccRel.put(c.SubscriberId__c,c.ProviderId__c);
				}

	     		for(Account a : [SELECT Id, VNContractNumber__c, AgentContractNumber__c FROM Account Where Id IN (SELECT ProviderId__c From PartnerAccountLink__c Where BeginDate__c<=TODAY AND EndDate__c>=TODAY AND SubscriberId__c IN :lstRecords)]){
	     			if(aux.containsKey(mapAccRel.get(a.Id))){
	     				for(Opportunity opp : aux.get(mapAccRel.get(a.Id))){
		     				if(a.VNContractNumber__c!=null){
		     					opp.VNContractNumber__c = a.VNContractNumber__c;
		     					results.add(opp);
		     				}else if (a.AgentContractNumber__c!=null){
		     					opp.AgentContractNumber__c = a.AgentContractNumber__c;
		     					results.add(opp);
		     				}
	     				}
	     			}
	     		} 	
	    	}
	    	if(!results.isEmpty()){
	    		Update results;
	    	}
	    }
    }

	public class ObjectRequest {

        @InvocableVariable(
            label           = 'Record ID'
            description     = 'The record to be processed'
            required        = true
        )
        public String recordId;

    }
}
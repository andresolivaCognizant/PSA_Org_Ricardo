public with sharing class PopulateAllocationToPoS {
    
    public static void populatePoSfields(List<Lead> lNewLeads, map<id,Lead> mapOldLeads){
        
        Set<Id> setIdAccounts = new Set<Id>();
        
        for(Lead oLead : lNewLeads){
            
            if(olead.CalculatedPOS__c != mapOldLeads.get(olead.id).CalculatedPOS__c && olead.CalculatedPOS__c !=null){
                
                setIdAccounts.add(olead.CalculatedPOS__c);
                
            }
            
            if(olead.CalculatedPOS__c == null && mapOldLeads.get(olead.id).CalculatedPOS__c != null){
                
                oLead.DestinationPOSCode__c 			= null;
                oLead.DestinationGeographicalCode__c 	= null;
                
                
            }
            
        }
        
        if(!setIdAccounts.isEmpty()){
            
        
            Map<Id, Account> mapAccountPoS = new map<Id, Account> ([SELECT id,SiteGeoIdPK__c,VNContractNumber__c FROM Account where id IN : setIdAccounts]);
            
            for(Lead oLead : lNewLeads){
                if(oLead.CalculatedPOS__c!= null && mapAccountPoS.get(oLead.CalculatedPOS__c)!=null){
                    
                    oLead.DestinationPOSCode__c 			= mapAccountPoS.get(oLead.CalculatedPOS__c).VNContractNumber__c;
                	oLead.DestinationGeographicalCode__c 	= mapAccountPoS.get(oLead.CalculatedPOS__c).SiteGeoIdPK__c;
                    
                } 
                	
                
            }
        
        }
        
    }

    public static void populatePoSfieldsOnInsert(List<Lead> lstLeads){
        Set<Id> setIdAccounts = new Set<Id>();
        for(Lead lea : lstLeads){
            if(lea.CalculatedPOS__c != null){
                
                setIdAccounts.add(lea.CalculatedPOS__c);
                lea.DestinationPOSCode__c = null;
                lea.DestinationGeographicalCode__c = null;   
            }  
        }
        if(!setIdAccounts.isEmpty()){
            Map<Id, Account> mapAccountPoS = new map<Id, Account> ([SELECT id,SiteGeoIdPK__c,VNContractNumber__c FROM Account where id IN : setIdAccounts]);
            for(Lead ld : lstLeads){
                ld.DestinationPOSCode__c             = mapAccountPoS.get(ld.CalculatedPOS__c).VNContractNumber__c;
                ld.DestinationGeographicalCode__c    = mapAccountPoS.get(ld.CalculatedPOS__c).SiteGeoIdPK__c;
            }
        }
    }

}
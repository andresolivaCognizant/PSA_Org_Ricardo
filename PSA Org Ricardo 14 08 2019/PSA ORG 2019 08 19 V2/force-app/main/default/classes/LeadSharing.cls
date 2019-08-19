public class LeadSharing {
    
    public static void grantAccessToLead(List<Lead> lNewLeads, Map<Id, Lead> mapOldLeads){
    	
    	system.debug('## grantAccessToLead: '+lNewLeads+' // '+mapOldLeads);
        
        map<Id,Lead> mapIdLeadChanged 	= new map<Id,Lead>();
        map<Id,Account> mapIdAcctChanged   = new map<Id,Account>();
        map<Id,List<id>> mapGrantAccess = new map<Id,List<id>>();
        Set<Id> setIdOldOwners 			= new Set<Id>();
        Set<Id> setIdOldOwnersDEL       = new Set<Id>();
        List<sObject> lLeadShareDelete 	= new List<sObject>();
        
        for(Lead oLead : lNewLeads){
            
            if(oLead.ownerId != mapOldLeads.get(oLead.id).OwnerId){
                mapIdLeadChanged.put(oLead.id, oLead);
            	setIdOldOwners.add(mapOldLeads.get(oLead.id).OwnerId);
            }	
            //--> NEW
            System.debug('sCalculatedPOS__c: '+oLead.CalculatedPOS__c);
            System.debug('sCalculatedPOS__c: '+mapOldLeads.get(oLead.id).CalculatedPOS__c);
            if(oLead.CalculatedPOS__c != mapOldLeads.get(oLead.id).CalculatedPOS__c){
                mapIdLeadChanged.put(oLead.id, oLead);
                mapIdAcctChanged.put(mapOldLeads.get(oLead.id).CalculatedPOS__c,mapOldLeads.get(oLead.id).CalculatedPOS__r);
                //System.debug(' mapOldLeads ' + mapOldLeads.get(oLead.id).CalculatedPOS__r.TECH_PublicGroups__c);
                //System.debug(' mapOldLeads ' + mapOldLeads.get(oLead.id).CalculatedPOS__r.TECH_PublicGroupsContract__c);
                //if(mapOldLeads.get(oLead.id).CalculatedPOS__r.TECH_PublicGroups__c!=null || mapOldLeads.get(oLead.id).CalculatedPOS__r.TECH_PublicGroupsContract__c!=null){
                //    String sPublicGroup = (mapOldLeads.get(oLead.id).CalculatedPOS__r.TECH_PublicGroups__c!=null)?mapOldLeads.get(oLead.id).CalculatedPOS__r.TECH_PublicGroups__c:mapOldLeads.get(oLead.id).CalculatedPOS__r.TECH_PublicGroupsContract__c;
                //    List<String> allGroups;
                //    if(!String.isEmpty(sPublicGroup)){
                //        System.debug('sPublicGroup: '+sPublicGroup);
                //        if(sPublicGroup.indexOf(';')>0){
                //            setIdOldOwnersDEL.addAll((List<ID>)sPublicGroup.split(';'));
                //        }else{
                //            setIdOldOwnersDEL.add((Id)sPublicGroup);
                //        }
                //    }
                //}
            }
            //--> NEW
        }
        System.debug(' STEP 2 --> FIND DEALERS : '+mapIdAcctChanged.keyset());
        Map<Id,Account> auxDealer = new Map<Id,Account>([SELECT Id, TECH_PublicGroups__c,TECH_PublicGroupsContract__c FROM Account WHERE Id IN : mapIdAcctChanged.keyset()]);
        System.debug(' STEP 2.0 --> FOUND DEALERS : '+auxDealer);
        for(Lead oLead : mapIdLeadChanged.values()){ 
            System.debug(' STEP 2.1 --> FIND DEALERS : '+auxDealer.containsKey(oLead.CalculatedPOS__c));
            if(auxDealer.containsKey(mapOldLeads.get(oLead.id).CalculatedPOS__c)){
                System.debug(' STEP 2.1 --> FIND DEALERS : '+auxDealer.containsKey(mapOldLeads.get(oLead.id).CalculatedPOS__c));
                if(auxDealer.get(mapOldLeads.get(oLead.id).CalculatedPOS__c).TECH_PublicGroups__c!=null || auxDealer.get(mapOldLeads.get(oLead.id).CalculatedPOS__c).TECH_PublicGroupsContract__c!=null){
                    String sPublicGroup = (auxDealer.get(mapOldLeads.get(oLead.id).CalculatedPOS__c).TECH_PublicGroups__c!=null)?auxDealer.get(mapOldLeads.get(oLead.id).CalculatedPOS__c).TECH_PublicGroups__c:auxDealer.get(mapOldLeads.get(oLead.id).CalculatedPOS__c).TECH_PublicGroupsContract__c;
                    List<String> allGroups;
                    if(!String.isEmpty(sPublicGroup)){
                        System.debug('sPublicGroup: '+sPublicGroup);
                        if(sPublicGroup.indexOf(';')>0){
                            setIdOldOwnersDEL.addAll((List<ID>)sPublicGroup.split(';'));
                        }else{
                            setIdOldOwnersDEL.add((Id)sPublicGroup);
                        }
                    }
                }
            }
        }

		System.debug('____setIdOldOwners: '+setIdOldOwners);
        
        for(LeadShare oLeadShare : [SELECT Id, LeadId,Lead.OwnerId, UserOrGroupId,UserOrGroup.name FROM LeadShare WHERE LeadId IN : mapIdLeadChanged.keyset()]){
            System.debug('____LEAD SHARE: ' +oLeadShare.UserOrGroup.name);
            
            if(!setIdOldOwners.contains(oLeadShare.UserOrGroupId)){
                System.debug('____LEAD SHARE NOT EQUALS: '+oLeadShare.UserOrGroup.name);
               
                if(!mapGrantAccess.containsKey(oLeadShare.LeadId)){
                    mapGrantAccess.put(oLeadShare.LeadId, new List<Id>{oLeadShare.UserOrGroupId});
                }else{
                    mapGrantAccess.get(oLeadShare.LeadId).add(oLeadShare.UserOrGroupId);
                }
                
            }
            
            
        }
        System.debug('setIdOldOwnersDEL: '+setIdOldOwnersDEL);
        lLeadShareDelete = [Select id FROM LeadShare where LeadId IN : mapIdLeadChanged.keyset() and UserOrGroupId IN :setIdOldOwnersDEL];
        System.debug('____lLeadShareDelete outside: '+lLeadShareDelete);
        
        
        //lLeadShareDelete = [Select id FROM LeadShare where LeadId IN : mapIdLeadChanged.keyset() and UserOrGroupId IN :setIdOldOwners];
        
        System.debug('____mapGrantAccess outside: '+mapGrantAccess);
        if(!mapGrantAccess.isEmpty()){
            // --> New 
            if(!lLeadShareDelete.isEmpty()){
            	SYSTEM.DEBUG('## GO BY 1');
                ManualSharingProcess.ManualSharingAsync(mapGrantAccess,lLeadShareDelete);
            }else{
            	SYSTEM.DEBUG('## GO BY 2');
                ManualSharingProcess.ManualSharingAsync(mapGrantAccess,null);
            }
        // --> New 
        }else if(!lLeadShareDelete.isEmpty()){
        	SYSTEM.DEBUG('## GO BY 3');
            ManualSharingProcess.ManualSharingAsync(null,lLeadShareDelete);
        }

    }
}
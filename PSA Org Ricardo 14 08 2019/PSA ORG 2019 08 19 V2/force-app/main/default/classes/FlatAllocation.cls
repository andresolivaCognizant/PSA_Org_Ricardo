/*
-- - Name         : FlatAllocation
-- - Author       : Ruben Moreno Leyva
-- - Date         : 15/02/2018
-- - Description  : FlatAllocation process
--
-- - History:
-- - Date       Author  Version  Comments
-- -----------  -----   -------  ---------------------------------------
-- 15/02/2018   RML     1.0      Creation

*/


public without sharing class FlatAllocation {
    
    /*
     * Casuisticas:
        Sumar +1 : 
		  C1: Cambiar el owner --> sumar a new owner.(update trigger)
          C2: Se inserta un nuevo lead --> + 1 owner(insert trigger)
	    Restar -1: 
		  C3: Pasan el lead a status descartado o isConverted pasa a true.(update trigger)
		  C4: Cambiar el owner --> restar a old owner(update trigger) 
     
    */
    
    
    
    public static void mainFunction(List<Lead> lNewLeads, map<Id,Lead> mapOldLeads){
        System.debug('________________** FlatAllocation **________________');
        System.debug('________________** lNewLeads **________________'+lNewLeads);
        Set<Id> setIdOwnerSubtract 		= new Set<Id>();
        Set<Id> setIdOwnerAdd 			= new Set<Id>();
        List<Contact> lContactsToUpdate = new List<Contact>();
        map<Id,Integer> mapIdSubtract 	= new map<Id,Integer>();
        map<Id,Integer> mapIdAdd 		= new map<Id,Integer>();
        Integer iContSub = 0;
        Integer iContAdd = 0;
		
        for(Lead oLead : lNewLeads){

            if(mapOldLeads!=null && oLead.Status!='New' && mapOldLeads.get(oLead.id).Status == 'New'){ //C3
                System.debug('##### C3 #####');
                setIdOwnerSubtract.add(oLead.OwnerId);
                if(mapIdSubtract.get(oLead.OwnerId)!=null){
                    iContSub = mapIdSubtract.get(oLead.OwnerId) + 1;
                    mapIdSubtract.put(oLead.OwnerId,iContSub);
                }else{
                	mapIdSubtract.put(oLead.OwnerId,1);    
                }
            }
            
            if(mapOldLeads!=null && oLead.OwnerId != mapOldLeads.get(oLead.id).OwnerId && mapOldLeads.get(oLead.id).ownerid != Label.TECH_WebToLead){// C1 Y C4
                System.debug('##### C1-4 #####');
                setIdOwnerSubtract.add(mapOldLeads.get(oLead.id).OwnerId);
                if(mapIdSubtract.get(mapOldLeads.get(oLead.id).OwnerId)!=null){
                    iContSub = mapIdSubtract.get(mapOldLeads.get(oLead.id).OwnerId) + 1;
                    mapIdSubtract.put(mapOldLeads.get(oLead.id).OwnerId,iContSub);
                }else{
                	mapIdSubtract.put(mapOldLeads.get(oLead.id).OwnerId,1);    
                }              
                
                setIdOwnerAdd.add(oLead.OwnerId);
                if(mapIdAdd.get(oLead.OwnerId)!=null){
                    iContAdd = mapIdAdd.get(oLead.OwnerId) + 1;
                    mapIdAdd.put(oLead.OwnerId,iContAdd);
                }else{
                	mapIdAdd.put(oLead.OwnerId,1);    
                }
            }
            
            if(mapOldLeads==null && oLead.ownerid != Label.TECH_WebToLead){//C2
                System.debug('##### C2 #####');
                if(mapIdAdd.get(oLead.OwnerId)!=null){
                    iContAdd = mapIdAdd.get(oLead.OwnerId) + 1;
                    mapIdAdd.put(oLead.OwnerId,iContAdd);
                }else{
                	mapIdAdd.put(oLead.OwnerId,1);    
                }
                
            }
            
        }
        
		System.debug('##### mapIdSubtract : '+mapIdSubtract);
        System.debug('##### mapIdAdd : '+mapIdAdd);
       
        for(User oUser : [Select Id, ContactId,Contact.TECH_CounterSalesman__c FROM User where (id IN :mapIdSubtract.keyset() OR id IN :mapIdAdd.keyset()) AND contactId != null]){
            if(mapIdSubtract.get(oUser.Id)!=null){
                Integer iContAuxSub = (oUser.Contact.TECH_CounterSalesman__c!=null)?(Integer)oUser.Contact.TECH_CounterSalesman__c - mapIdSubtract.get(oUser.Id):0;
                lContactsToUpdate.add(new Contact(id=oUser.ContactId, TECH_CounterSalesman__c=iContAuxSub));
            }
            
            if(mapIdAdd.get(oUser.Id)!=null){
                Integer iContAuxAdd = (oUser.Contact.TECH_CounterSalesman__c!=null)?(Integer)oUser.Contact.TECH_CounterSalesman__c + mapIdAdd.get(oUser.Id):1;
                lContactsToUpdate.add(new Contact(id=oUser.ContactId, TECH_CounterSalesman__c=iContAuxAdd));
            }
        }
        
        try{
            
            Database.update(lContactsToUpdate,true);
            
        }catch(System.DmlException e){
            System.debug('DmlException ERROR flatAllocation.mainFunction -->' + e.getMessage() + ' Line: '+e.getLineNumber());
        }catch(Exception e){
            System.debug('Exception ERROR flatAllocation.mainFunction-->' + e.getMessage() + ' Line: '+e.getLineNumber());
        }
                
    }

}
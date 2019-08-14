/*
-- - Name         : SetFlagAvailableLeadTreatment
-- - Author       : Ruben Moreno Leyva
-- - Date         : 08/05/2018
-- - Description  : Class to set AvailableLeadTreatment field
--
-- - History:
-- Date         Author  		Version  Comments
-- -----------  -----   		-------  ---------------------------------------
-- 08/05/2018   Ruben Moreno     1.0     Initial version ruben moreno leyva
*/


public without sharing class SetFlagAvailableLeadTreatment {
    
    
    public static void setFlag(List<Contact> lNewsContact, map<Id,Contact> mapOldContact){
        System.debug('##RM##  *** SetFlagAvailableLeadTreatment ***');
        for(Contact oContact : lNewsContact){
            
            if(oContact.TECH_EnableForLeadTreatment__C != mapOldContact.get(oContact.id).TECH_EnableForLeadTreatment__C){
                if(oContact.AvailableLeadTreatment__c == true){
                    oContact.AvailableLeadTreatment__c = false;
                }else{
                    oContact.AvailableLeadTreatment__c = true;
                }
            }
        }
        
    }

}
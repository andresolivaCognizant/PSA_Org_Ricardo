/**
	*   @Class : APS007_FlatAllocation
	*
	*   @Author         :   Ruben Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
	*   @Created        :   31/8/2018 
	*   @Description    :   to can schedule APB007_FlatAllocation batch.
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Ruben Moreno				31/8/2018				 Creation.
	*   ----------------------------------------------------------------------------------------------------------------------------
**/

global class APS007_FlatAllocation implements Schedulable{
       
    map<Id,Integer> mapIdvalue = new map<Id,Integer>();
    
    global void execute(SchedulableContext sc) {
        
        for(Lead olead : [SELECT Id,Ownerid,Owner.name FROM Lead Where Status = 'New' AND Owner.Profile.Name = 'Salesman' order by OwnerId desc]){
            if(!mapIdvalue.containskey(oLead.OwnerId)){
                mapIdvalue.put(oLead.OwnerId, 1);                
            }else{
                Integer iCont = mapIdvalue.get(oLead.OwnerId) + 1;
                mapIdvalue.put(oLead.OwnerId, iCont);
            }
        }
        
        for(Id idKey : mapIdvalue.keyset()){
            System.debug('Id: '+idkey+' - Value: '+mapIdvalue.get(idkey));
        }
        
        Database.executebatch(new APB007_FlatAllocation(mapIdvalue));
        
    }
        
}
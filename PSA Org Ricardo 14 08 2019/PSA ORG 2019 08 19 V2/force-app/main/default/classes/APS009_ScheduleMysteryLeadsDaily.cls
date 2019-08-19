/**
	*   @Class : APS009_ScheduleMysteryLeadsDaily
	*
	*   @Author         :   Ruben Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
	*   @Created        :   07 Feb 2018 
	*   @Description    :   
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Ruben Moreno				17/5/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/

public class APS009_ScheduleMysteryLeadsDaily implements Schedulable{
       
    
    public void execute(SchedulableContext sc) {
        		        
               
        List<MysteryLeadProcess__mdt> lRules = (!Test.isRunningTest())?[SELECT MasterLabel,ContactWay__c,NumberOfLeads__c,ShippingStartDate__c,ShippingEndDate__c,Country__c FROM MysteryLeadProcess__mdt WHERE ShippingStartDate__c <= TODAY AND ShippingEndDate__c >= TODAY]:[SELECT MasterLabel,ContactWay__c,NumberOfLeads__c,ShippingStartDate__c,ShippingEndDate__c FROM MysteryLeadProcess__mdt WHERE Label = 'TECH_TestRecord'];
        System.debug('lRules: '+lRules);
        for(MysteryLeadProcess__mdt oRule : lRules){
            
            List<String> lDate = String.valueof(System.now()).split(' ')[0].split('-');
            List<String> lTime = String.valueof(oRule.ShippingStartDate__c).split(' ')[1].split(':');//to extract the time.

            String sch = lTime[2]+ ' ' +lTime[1]+ ' ' +lTime[0]+ ' ' +lDate[2]+ ' ' +lDate[1] + ' ? ' + lDate[0];
            //String sch = '0 00 12 22 5 ? 2018';
			System.debug('NAME: '+'Mystery Lead: '+oRule.MasterLabel+' - Date: '+System.now());
            System.debug('sch: '+sch);
            
            try{
                String jobID = system.schedule('Mystery Lead: '+oRule.MasterLabel+' - Date: '+System.now(), (!Test.isRunningTest())?sch:'0 0 * * * ?', new APS009_ScheduleMysteryLeadsMain(oRule.ContactWay__c,oRule.Country__c,Integer.valueof(oRule.NumberOfLeads__c)));
            	System.debug('jobID: '+jobID);
                
            }catch(Exception e){
                System.debug('Exception ERROR APS009_ScheduleMysteryLeadsDaily-->' + e.getMessage() + ' Line: '+e.getLineNumber());
            }
            	
        }

       
    }
    

}
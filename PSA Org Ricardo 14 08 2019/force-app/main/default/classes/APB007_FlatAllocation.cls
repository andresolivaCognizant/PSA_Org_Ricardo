/**
	*   @Class : APB007_FlatAllocation
	*
	*   @Author         :   Ruben Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
	*   @Created        :   25 Apr 2018
	*   @Description    :   Batch to balance the lead assignments for the salesmans.
							
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Ruben Moreno				25 Apr 2018				 Creation.		
	*	   Ruben Moreno				18/10/2018				 Save result in the update.
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
public class APB007_FlatAllocation implements Database.Batchable<sObject>{
    
    List<Contact> lContactsToUpdate = new List<Contact>();
    map<Id,Integer> mapIdvalue = new map<Id,Integer>();
    
    public APB007_FlatAllocation(map<Id,Integer> mapIdvalue){
        this.mapIdvalue = mapIdvalue;
        
    }
    
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('## APB007_FlatAllocation START');
        String sLimit = Test.isRunningTest() ? ' LIMIT 1':'';
        String query = 'SELECT Id, ContactId,Contact.TECH_CounterSalesman__c,Contact.Name FROM User WHERE Profile.Name = \'Salesman\' AND contactId != null AND IsActive=true' + sLimit;
                 
        return Database.getQueryLocator(query);
    }
    
    
    public void execute(Database.BatchableContext BC, List<User> scope){
        System.debug('## APB007_FlatAllocation EXECUTE');
                
        for(User oUser : scope){
            Contact c = new Contact();
            c.id = oUser.ContactId;
            if(mapIdvalue.containsKey(oUser.id)){
            	c.TECH_CounterSalesman__c = mapIdvalue.get(oUser.id);
            }else{
                c.TECH_CounterSalesman__c = 0;
            }
            System.debug('Contact -> '+c);
            lContactsToUpdate.add(c);
        }
        
		
        for (Database.SaveResult sr : Database.update(lContactsToUpdate,false)) {
            if (sr.isSuccess()) {
                System.debug('Successfully updated contact. ID: ' + sr.getId());
            }
            else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.'+ err.getStatusCode() + ': ' + err.getMessage()+ ' due to this fields: '+ err.getFields());
                }
            }
		}
        
        
        lContactsToUpdate.clear();

        
    }   
    
    
    public void finish(Database.BatchableContext BC){ 

    }


}
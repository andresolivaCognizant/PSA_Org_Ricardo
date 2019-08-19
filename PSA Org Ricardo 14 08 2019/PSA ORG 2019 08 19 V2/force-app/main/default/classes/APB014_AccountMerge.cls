/**
*   @Class : APB014_AccountMerge
*
*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
*   @Created        :   27 08 2018
*   @Description    :   Batch to merge the account in the Customer Merge Entry

*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Developer           		Date                     Description	
*	   Raul Barba				27/8/2018				 Creation.		
*   ----------------------------------------------------------------------------------------------------------------------------
**/
public class APB014_AccountMerge implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('## APB014_AccountMerge START');
        
        String query = 'select id, Status__c, MergeResult__c, MasterCustomer__r.Id, SlaveCustomer__r.Id, MasterCustomer__r.ispersonaccount, MasterCustomer__r.personcontactid'  
            + ' from CustomerMergeEntry__c ' 
            + 'where Status__c = \'0\' and MasterCustomer__c != null and SlaveCustomer__c != null';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<CustomerMergeEntry__c> scope){
        System.debug('## APB014_AccountMerge EXECUTE');
        Database.MergeResult result;
        List<id> masterIds = new List<id>();
        List<id> masterIdsB2C = new List<id>();
        List<CustomerMergeEntry__c> mergeResults = new List<CustomerMergeEntry__c>();
        for(CustomerMergeEntry__c cme : scope){
            //**BEGIN** change lookup from AccountExternalRef to Account
            //masterIds.add(cme.MasterCustomer__r.Account__c);
            masterIds.add(cme.MasterCustomer__c);
            //**END** change lookup from AccountExternalRef to Account
        }
        Map<ID, Account> masterAccounts = new Map<ID, Account>([select id from account where id in :masterIds]);
        for(CustomerMergeEntry__c cme : scope){
            try{
                //**BEGIN** change lookup from AccountExternalRef to Account
            	//result = Database.merge(masterAccounts.get(cme.MasterCustomer__r.Account__c), cme.SlaveCustomer__r.Account__c);
                result = Database.merge(masterAccounts.get(cme.MasterCustomer__c), cme.SlaveCustomer__c);
                //**END** change lookup from AccountExternalRef to Account
            }catch(Exception e){
                cme.MergeResult__c = 'Exception caught: ' + e.getMessage();
                cme.Status__c = '3';
            }
            if(result != null && result.isSuccess()){
                cme.Status__c = '2';
                //**BEGIN** change lookup from AccountExternalRef to Account
                //if(cme.MasterCustomer__r.Account__r.ispersonaccount){
                    //masterIdsB2C.add(cme.MasterCustomer__r.Account__r.personcontactid);
                //}
                if(cme.MasterCustomer__r.ispersonaccount){
                    masterIdsB2C.add(cme.MasterCustomer__r.personcontactid);
                }
                //**END** change lookup from AccountExternalRef to Account
                /* Slave Customer is deleted after merge the accounts so we need 
                cleaning the field to prevent an error */
                cme.SlaveCustomer__c = null;
            }
            mergeResults.add(cme);
        }
        update mergeResults;
        
        List<Contactability__c> lContactability = [select id, Contact__c, Brand__c, CalculationDate__c, Channel__c, Country__c, Entity__c, EntityID__c, Purpose__c from Contactability__c where Contact__c in :masterIdsB2C];
        Map<String, Contactability__c> mapContactability = new Map<String, Contactability__c>();
        List<Contactability__c> lRemoveContactability = new List<Contactability__c>();
        String keyContactability;
        for(Contactability__c cont : lContactability){
            keyContactability = cont.Contact__c + cont.Brand__c + cont.Channel__c + cont.Country__c + cont.Entity__c + cont.EntityID__c + cont.Purpose__c;
            if(!mapContactability.containsKey(keyContactability)){
                mapContactability.put(keyContactability,cont);
            }else{
                if(cont.CalculationDate__c < mapContactability.get(keyContactability).CalculationDate__c){
                    lRemoveContactability.add(cont);
                }else{
                    lRemoveContactability.add(mapContactability.get(keyContactability));
                }
            }
        }
        delete lRemoveContactability;
    }   
    public void finish(Database.BatchableContext BC){ 
        System.debug('## APB014_AccountMerge FINISH');
    }

}
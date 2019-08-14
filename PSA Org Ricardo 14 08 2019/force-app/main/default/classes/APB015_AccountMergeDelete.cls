/**
	*   @Class : APB015_AccountMergeDelete
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   27 08 2018
	*   @Description    :   Batch to delete the done Customer Merge Entry
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Raul Barba				27/8/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
public class APB015_AccountMergeDelete implements Database.Batchable<sObject>, Database.Stateful{
    
    integer monthDiff;
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('## APB015_AccountMergeDelete START');
        UtilSetting__mdt[] utilMonth = [select id, Value__c, DeveloperName from UtilSetting__mdt where DeveloperName = 'AccountMergeMonthDelete'];
        if(utilMonth != null){
            monthDiff = Integer.valueOf(utilMonth[0].Value__c);
        }
        String query = 'select id, Status__c, RequestDate__c'  
            + ' from CustomerMergeEntry__c ' 
            + 'where Status__c = \'2\'';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<CustomerMergeEntry__c> scope){
        System.debug('## APB015_AccountMergeDelete EXECUTE');
        List<CustomerMergeEntry__c> cmeDelete = new List<CustomerMergeEntry__c>();
        for(CustomerMergeEntry__c cme : scope){
            System.Debug(monthDiff);
            if(cme.RequestDate__c.monthsBetween(date.today()) >= monthDiff && cme.RequestDate__c < date.today()){
                cmeDelete.add(cme);
            }
        }
        
        delete cmeDelete;
    }   
    public void finish(Database.BatchableContext BC){ 
        System.debug('## APB015_AccountMergeDelete FINISH');
        
    }

}
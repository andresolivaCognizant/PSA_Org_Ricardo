/**
*   @Class          :   APB020_CheckDealerEndActivity.cls
*   @Author         :   Sergio López
*   @Created        :   22 Mar 2019
*   @Description    :   Daily Batch to Check if Dealer End Contract Date meets yesterday date
*
*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Author             Date             Description
*      Segio Lopez        22/03/2019       Creation.
*   ----------------------------------------------------------------------------------------------------------------------------
**/ 
global class APB020_CheckDealerEndActivity implements Database.Batchable<sObject> {
	 
	global Database.QueryLocator start(Database.BatchableContext BC) { 
		String query = 'SELECT Id';
            query += ' FROM Account ';            
           	query += ' WHERE RecordType.name = \'Dealer\' AND VNContractEndDate__c = YESTERDAY ';
             
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Account> scope) { 

        List<Account> lAcc = new List<Account> (); 
   		   		
		for(Account l : scope){  
			lAcc.add(l);   
		}
   		
        If (!lAcc.isEmpty()){
            DealerPlacaChangeFSL.endSecTerrRelation(lAcc,true);
        }
           					
	}
	
	global void finish(Database.BatchableContext BC) {
		APB020_ServiceResourceUserInactive bch = new APB020_ServiceResourceUserInactive();
        ID batchprocessid = Database.executeBatch(bch);
	}
	
}
/**
    *   @Class : ChangeAccountStatusBatch
    *
    *   @Author         :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    *   @Created        :   28 Feb 2019
    *   @Description    :   Batch class to bulk update the 'XXAccountStatus__c' fields of the accounts.
    * 					:	Run Account Asset Relation 	ex: Database.executeBatch(new ChangeAccountStatusBatch('AccAssetRel'), 20);
    * 					:	Run Order 					ex:	Database.executeBatch(new ChangeAccountStatusBatch('Order'), 20);
    * 					:	Run Quote & Order Form		ex:	Database.executeBatch(new ChangeAccountStatusBatch('OrderForm'), 20);
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description    
    *      Carmen Hernandez         2/27/2019                Creation.      
    * 	   Carmen Hernandez		    5/14/2019				 #C1STAGILE-9723: Apex CPU time limit exceeded: Refactored Query
    *   ----------------------------------------------------------------------------------------------------------------------------
**/
global class ChangeAccountStatusBatch implements Database.Batchable<sObject> {
    
    private static final String QUERY_ORDER 		= 'SELECT Id, Brand__c, AccountId, Status FROM Order WHERE Status != \'0\'';
    private static final String QUERY_ORDER_FORM 	= 'SELECT Id, Brand__c, SBQQ__Account__c, SBQQ__Status__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c != \'7\'';
    private static final String QUERY_ASSET_REL 	= 'SELECT Id, AssetId__r.Brand__c, RelationEndDate__c, AccountId__c FROM AccountContactAssetRelation__c';
    
    private String strQuery;

    /*********************************************************************************************************
    * @Method          :   ChangeAccountStatusBatch
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   5/14/2019
    * @Description     :   Default Constructor -> Set Query: Asset
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/     
    public ChangeAccountStatusBatch() {
        strQuery = QUERY_ASSET_REL;
    }
    
    /*********************************************************************************************************
    * @Method          :   ChangeAccountStatusBatch
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   5/14/2019
    * @Description     :   Constructor -> Set Query: Depending on the input parameter
	* @params	       :   String typeObject: {'Order', 'OrderForm', 'AccAssetRel'}
    * @Returns         :   void
    **********************************************************************************************************/           
    public ChangeAccountStatusBatch(String typeObject) {
        switch on typeObject {
            when 'Order' {
                strQuery = QUERY_ORDER;
            }
            when 'OrderForm' {
                strQuery = QUERY_ORDER_FORM;
            }
            when 'AccAssetRel' {
                strQuery = QUERY_ASSET_REL;                
            }
            when else{
                strQuery = QUERY_ASSET_REL;                  
            }
        }     
    }
    
    /*********************************************************************************************************
    * @Method          :   start
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   5/14/2019
    * @Description     :   This method executes a dynamic query of some of these objects: {Order, SBQQ__Quote__c, 
    * 					   AccountContactAssetRelation__c}, depending on the input parameter
	* @params	       :   Database.BatchableContext BC
    * @Returns         :   Database.QueryLocator: Result Query
    **********************************************************************************************************/       
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(strQuery);
	}
    
    /*********************************************************************************************************
    * @Method          :   execute
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   5/14/2019
    * @Description     :   This method executes the method ChangeAccountStatus.mainFunction(resultQuery)
	* @params	       :   Database.BatchableContext BC, List<sObject> sObjectList
    * @Returns         :   void
    **********************************************************************************************************/       
   	global void execute(Database.BatchableContext BC, List<sObject> sObjectList) {
		ChangeAccountStatus.mainFunction(sObjectList);
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}
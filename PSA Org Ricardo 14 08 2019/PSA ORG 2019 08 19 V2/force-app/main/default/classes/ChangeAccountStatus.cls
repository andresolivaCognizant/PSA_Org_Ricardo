/*-----------------------------------------------------------------------------------------------------------//
  * Class Name    : ChangeAccountStatus
  * Project       : PSA - C1ST - Sales
  * Author        : Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
  * Date          : 02/27/2019
  * Description   : Class to update the 'XXAccountStatus__c' fields of Account depending on the { Order / 
  *                 OrderForm / AccountAssetRelation} records
  *                       
  *-----------------------------------------------------------------------------------------------------------
  *      Modification Log :
  *-----------------------------------------------------------------------------------------------------------
  *      Developer                Date                     Description    
  *      Carmen Hernandez         02/27/2019               Creation.
  *      Carmen Hernandez         07/02/2019               Refactor: Add methods classifyAccounts, checkAccountsToUpdate
  *      Nerea Leguinazabal       07/12/2019               Add SalesConstants RT_OPV_ORDER_FORM_VN,RT_OPV_ORDER_FORM_VO,RT_OPV_ORDER_FORM_VD  
  *      Carmen Hernandez         07/16/2019               Refactor
  *-----------------------------------------------------------------------------------------------------------*/
public class ChangeAccountStatus {
    
    //Constants
    private static final String STATUS_FIELD_API_NAME = 'AccountStatus__c';
    private static final Set<String> BRAND_CODES = new Set<String>{
                                                        Constants.BRAND_CITROEN, 
                                                        Constants.BRAND_PEUGEOT, 
                                                        Constants.BRAND_DSAUTOMOBILES};
    private static final Map<String, String> mapAccountFields = new Map<String,String>{
                                                        Constants.SOT_ORDER =>'AccountId', 
                                                        Constants.SOT_SBQQ_QUOTE => 'SBQQ__Account__c', 
                                                        Constants.SOT_ASSET_RELATION => 'AccountId__c'};
    private static final Map<String, String> mapBrandFields =new Map<String,String>{
                                                        Constants.SOT_ORDER =>'Brand__c', 
                                                        Constants.SOT_SBQQ_QUOTE => 'Brand__c', 
                                                        Constants.SOT_ASSET_RELATION => 'AssetId__r.Brand__c'};
    private static final Set<Id> setRecordTypesOrderFormOPV = new Set<Id>{
                                                        PAD.recordTypesMapByDeveloperName.get(Constants.RT_SBQQ_QUOTE_OPV_VD),
                                                        PAD.recordTypesMapByDeveloperName.get(Constants.RT_SBQQ_QUOTE_OPV_VN),
                                                        PAD.recordTypesMapByDeveloperName.get(Constants.RT_SBQQ_QUOTE_OPV_VO)};
    //Variables
    private static String typeSObject = '';
    private static String accountFieldAPINm = '';
    private static String brandFieldAPINm = '';
    private static Map<Id, Set<String>> mapActiveBrandsByAccount = new Map<Id, Set<String>>();
    private static Map<Id, Set<String>> mapOldActiveBrandsByAccount = new Map<Id, Set<String>>(); 
    private static Map <Id, String> mapAssetBrands = new Map <Id, String>();  

    /*********************************************************************************************************
    * @Method          :   mainFunction
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   02/13/2019
    * @Description     :   This method updates the 'XXAccountStatus__c' fields of Account depending on the 
    *                      { Order / OrderForm / AccountAssetRelation} records that exist in the account
    * @params	       :   List<sObject> lSObjects: List of objects to analyze, different types 
    *                      {Order/OrderForm/AccountAssetRelation}
    * @Returns         :   void
    **********************************************************************************************************/       
    public static void mainFunction(List<sObject> lSObjects){
        try{

            //P0. Determine Object Type, account APIName & brand APIName
            typeSObject = String.valueOf(lSObjects.getSObjectType()); 
            accountFieldAPINm = mapAccountFields.get(typeSObject);
            brandFieldAPINm = mapBrandFields.get(typeSObject);

            //P1. Get Id Accounts from {Orders/OrderForms/AssetRelations}
            Set<Id> setIdAccounts = new Set<Id>();
            for(sObject oObject : lSObjects){
                setIdAccounts.add((Id)oObject.get(accountFieldAPINm));
            }
            setIdAccounts.remove(null);

            //P2. Queries (Get Orders, OrderForms, AssetContactRelation) & Create Maps{idAccount, Set<Brands>} 
            //Map that stores the brands of the active elements in each account {Order != Cancelled || OrderForm != Cancelled || AssetRelation.EndDate == null}  
            mapActiveBrandsByAccount = new Map<Id, Set<String>>();
            //Map that stores the brands of the old active elements in each account {AssetRelation.EndDate != null}  
            mapOldActiveBrandsByAccount = new Map<Id, Set<String>>();   
            //2.1 Query Order, Update mapActiveBrandsByAccount 
            getActiveBrandsByAccount(mapAccountFields.get(Constants.SOT_ORDER), mapBrandFields.get(Constants.SOT_ORDER), 
                [SELECT AccountId, Brand__c FROM Order 
                    WHERE (Status !=: SalesConstants.ORDER_STATUS_CANCELLED AND AccountId IN: setIdAccounts) 
                        GROUP BY AccountId, Brand__c]);  
            //2.2 Query OrderForm, Update mapActiveBrandsByAccount 
            getActiveBrandsByAccount(mapAccountFields.get(Constants.SOT_SBQQ_QUOTE), mapBrandFields.get(Constants.SOT_SBQQ_QUOTE), 
                [SELECT SBQQ__Account__c, Brand__c FROM SBQQ__Quote__c 
                    WHERE (SBQQ__Status__c !=: SalesConstants.SBQQ_QUOTE_STATUS_CANCELED AND SBQQ__Account__c IN: setIdAccounts AND RecordTypeId IN: setRecordTypesOrderFormOPV) 
                        GROUP BY SBQQ__Account__c, Brand__c]);                                
            //2.3 Query AssetRelation, Update mapActiveBrandsByAccount, mapOldActiveBrandsByAccount, mapAssetBrands
            mapAssetBrands = new Map <Id, String>();
            getActiveBrandsByAccount([SELECT AccountId__c, AssetId__r.Brand__c, AssetId__c, RelationEndDate__c FROM AccountContactAssetRelation__c 
                    WHERE (AssetId__r.Brand__c != null AND AccountId__c IN: setIdAccounts)]);

            //P3. Final loop to create the list of accounts that have to be updated
            List<Account> accountList = checkAccountsToUpdate(lSObjects);  

            //P4. Update Accounts with bypass Account Trigger                                   
            if(!accountList.isEmpty()){
                AccountTriggerHandler.dontRunTrigger();
                update accountList;
                AccountTriggerHandler.runTrigger();
            } 
        }catch(Exception e){
            System.debug('Exception ERROR ChangeAccountStatus -->' + e.getMessage() + ' Line: '+e.getLineNumber());
        }
    }
    
    


    /*********************************************************************************************************
    * @Method          :   getActiveBrandsByAccount
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/17/2019
    * @Description     :   Update the map of active elements depending on the list of input records
    * @params	       :   String accountField: Account Field API Name
    *                  :   String brandField: Brand Field API Name
    *                  :   List <AggregateResult> AggrResults: List of input records {Orders, OrderForms}
    * @Returns         :   void
    **********************************************************************************************************/  
    public static void getActiveBrandsByAccount(String accountField, String brandField, List <AggregateResult> AggrResults ){
        for (AggregateResult oAggrResult : AggrResults)  {
            Id accountTmp = (Id)oAggrResult.get(accountField);
            String brandTmp = (String)oAggrResult.get(brandField);
            if(String.isNotBlank(brandTmp)){
                if(!mapActiveBrandsByAccount.containskey(accountTmp)){
                    mapActiveBrandsByAccount.put(accountTmp, new Set<String>());
                }
                mapActiveBrandsByAccount.get(accountTmp).add(brandTmp); 
            }
        }            
    }

    /*********************************************************************************************************
    * @Method          :   getActiveBrandsByAccount
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/17/2019
    * @Description     :   Update the map of active/inactive elements depending on the list of input records
    * @params	       :   List <AccountContactAssetRelation__c> lstAssetRelations:  List of input records {AssetRelations}
    * @Returns         :   void
    **********************************************************************************************************/  
    public static void getActiveBrandsByAccount(List <AccountContactAssetRelation__c> lstAssetRelations ){
        for(AccountContactAssetRelation__c oAccountAssetRel : lstAssetRelations){
            //Active brands {AssetRelation.EndDate == null}
            if(oAccountAssetRel.RelationEndDate__c == null){
                if(!mapActiveBrandsByAccount.containskey(oAccountAssetRel.AccountId__c)){
                    mapActiveBrandsByAccount.put(oAccountAssetRel.AccountId__c, new Set<String>());
                }
                mapActiveBrandsByAccount.get(oAccountAssetRel.AccountId__c).add(oAccountAssetRel.AssetId__r.Brand__c);                     
            }
            //Old Active brands {AssetRelation.EndDate != null}
            else{
                if(!mapOldActiveBrandsByAccount.containskey(oAccountAssetRel.AccountId__c)){
                    mapOldActiveBrandsByAccount.put(oAccountAssetRel.AccountId__c, new Set<String>());
                }
                mapOldActiveBrandsByAccount.get(oAccountAssetRel.AccountId__c).add(oAccountAssetRel.AssetId__r.Brand__c); 
            }
            mapAssetBrands.put(oAccountAssetRel.AssetId__c, oAccountAssetRel.AssetId__r.Brand__c);
        }  
    }
    
    /*********************************************************************************************************
    * @Method          :   checkAccountsToUpdate
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   06/28/2019
    * @Description     :   This method checks which account needs to be updated
    * @params	       :   List<sObject> lSObjects: List of objects to analyze, different types 
    *                      {Order/OrderForm/AccountAssetRelation}
    * @Returns         :   void
    **********************************************************************************************************/      
    public static List<Account> checkAccountsToUpdate(List<sObject> lSObjects){
        Id accountIdTmp;
        String brandTmp, newStatus = '';
        Boolean hasActiveElements, hasOldActiveElements, isBrandAll = false;
        Account accountTmpToUpdate = new Account();                        
        Map	<Id, Account> accountsToUpdateMap = new Map <Id, Account>();
        Set <String> processedAccounts = new Set <String>();
        
        Boolean isAccountAssetRelationObject = (typeSObject == Constants.SOT_ASSET_RELATION);

        for(sObject oObject : lSObjects){

            //Determine accounId & brand in each record
            accountIdTmp = (Id)oObject.get(accountFieldAPINm);
            brandTmp = isAccountAssetRelationObject? mapAssetBrands.get((Id)oObject.get('AssetId__c')): (String)oObject.get(brandFieldAPINm);
            isBrandAll = (brandTmp == Constants.BRAND_ALL);
            
            //If accountIdTmp or brandTmp is empty the account wont be updated
            if(accountIdTmp != null && String.isNotBlank(brandTmp) && !processedAccounts.contains(accountIdTmp+brandTmp) && (BRAND_CODES.contains(brandTmp) || isBrandAll)){
                
                //Calculate if the account has active elements {orders.Status!=Cancelled / orderForms.Status!=Cancelled / accAssetRelation.EndDate == null} 
                hasActiveElements = mapActiveBrandsByAccount.containskey(accountIdTmp) && (isBrandAll || mapActiveBrandsByAccount.get(accountIdTmp).contains(brandTmp) || mapActiveBrandsByAccount.get(accountIdTmp).contains(Constants.BRAND_ALL));
                //Calculate if the account has old active elements {accAssetRelation.EndDate != null}
                hasOldActiveElements = mapOldActiveBrandsByAccount.containskey(accountIdTmp) && (isBrandAll || mapOldActiveBrandsByAccount.get(accountIdTmp).contains(brandTmp) || mapOldActiveBrandsByAccount.get(accountIdTmp).contains(Constants.BRAND_ALL)); 

                //Change Status - CASE 1: Accounts to change to 'Customer'
                if(hasActiveElements){
                    newStatus = AccountConstants.ACCOUNT_TYPE_CUSTOMER;
                }
                //Change Status - CASE 2: Accounts to change to 'Prospect' / 'Old Customer'
                else if(!hasActiveElements && !hasOldActiveElements){
                    newStatus = (isAccountAssetRelationObject)? AccountConstants.ACCOUNT_TYPE_OLDCUSTOMER: AccountConstants.ACCOUNT_TYPE_PROSPECT;
                }
                //Change Status - CASE 3: Accounts to change to Old Customer'
                else if(!hasActiveElements && hasOldActiveElements){
                    newStatus = AccountConstants.ACCOUNT_TYPE_OLDCUSTOMER;
                }
                                
                //Add new changes to the accounts
                accountTmpToUpdate = new Account();
                if(accountsToUpdateMap.containskey(accountIdTmp)){
                    accountTmpToUpdate = accountsToUpdateMap.get(accountIdTmp);
                }
                else{
                    accountTmpToUpdate.Id = accountIdTmp;
                }

                if(!isBrandAll){
                     accountTmpToUpdate.put(brandTmp+STATUS_FIELD_API_NAME, newStatus);
                } 
                else{
                    for(String brand : BRAND_CODES){
                        accountTmpToUpdate.put(brand+STATUS_FIELD_API_NAME, newStatus);
                    }
                }  
                accountsToUpdateMap.put(accountIdTmp, accountTmpToUpdate);

                processedAccounts.add(accountIdTmp+brandTmp);
            }
        }//END P3. Final loop to create the list of accounts that have to be updated
        
        return (accountsToUpdateMap.values());
        
    }
}
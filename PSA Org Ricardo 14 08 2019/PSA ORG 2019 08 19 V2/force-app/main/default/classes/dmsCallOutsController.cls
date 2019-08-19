/*----------------------------------------------------------------------
-- - Name         : dmsCallOutsController
-- - Author       : Ruben Fernandez
-- - Date         : 25/02/2019
-- - Description  : Controller for dmsCallOuts lightning component
-- -			
-- - History:
-- - Date       Author  Version  Comments
-- -----------  -----   -------  ---------------------------------------
-- 25/02/2019   SFDC    1.0      Initial version
------------------------------------------------------------------------
*/
public class dmsCallOutsController {

    private static final String ASSET_ITEM_KEY_PREFIX 	= Asset.sObjectType.getDescribe().getKeyPrefix();
	private static final String ORDER_ITEM_KEY_PREFIX   = Order.sObjectType.getDescribe().getKeyPrefix();
    private static final String QUOTE_ITEM_KEY_PREFIX   = SBQQ__Quote__c.sObjectType.getDescribe().getKeyPrefix();
    private static final String ACCNT_ITEM_KEY_PREFIX   = Account.sObjectType.getDescribe().getKeyPrefix();
    private static final String CONAC_ITEM_KEY_PREFIX   = AccountContactAssetRelation__c.sObjectType.getDescribe().getKeyPrefix();
    
	/* CORS CALL */
    @AuraEnabled        
    public static Map<String,String> DMSWakeUpbyCORS(String sRecordId_A, String sRecordId_B){
        Map<String,String>  sCORS = new Map<String,String>();
        if(PAD.sUserDMSType=='1'){
           sCORS.put('body',SAPIWebhook.getRequestCustomParams(sRecordId_A,sRecordId_B));
           sCORS.put('endpoint',SAPIWebhook.getFinalURL(PAD.sURLDMS,null));
        }
        return sCORS;
    }
    /* SERVER TO SERVER CALL */
    @AuraEnabled        
    public static boolean DMSWakeUpbyServer(String sRecordId){
        Boolean bResult = false;
		if(PAD.sUserDMSType=='2'){
        	List<sObject> lstObjs = getListObjects(getSOQL(sRecordId),sRecordId);
            if(null != lstObjs && !lstObjs.isEmpty()){
        		SAPIWebhook.ProcessRecords(lstObjs, 0);
                bResult = true;
            }
        }
        return bResult;
    }
    /* Passing a SOQL query return a list of sObjects*/
    private static List<sObject> getListObjects (String queryString,String sRecordId){
        try {
			return database.query(queryString);
		} catch(Exception e) {
			system.debug('## getListObjects --> ERROR : ' + e);
			return null;
		}
    }
    /* From an Id, it return a SOQL query */
    private static String getSOQL(String sRecordId){
        String sQuery = 'SELECT Id';
        String sObj = String.valueOf(sRecordId).left(3);
        
        If(sObj == ASSET_ITEM_KEY_PREFIX) {
        	sQuery += ',AccountId FROM Asset';
        }else if(sObj ==  ACCNT_ITEM_KEY_PREFIX) {
        	sQuery += ' FROM Account';
        }else if(sObj ==   ORDER_ITEM_KEY_PREFIX) {
            sQuery += ',AccountId FROM Order';
        }else if(sObj ==   QUOTE_ITEM_KEY_PREFIX) {
            sQuery += ',SBQQ__Account__c FROM SBQQ__Quote__c';
        }else if(sObj ==   CONAC_ITEM_KEY_PREFIX) {
            sQuery += ',AccountId__c,AssetId__c FROM AccountContactAssetRelation__c';
        }
        sQuery += ' WHERE Id =: sRecordId';
		return sQuery;
    }
}
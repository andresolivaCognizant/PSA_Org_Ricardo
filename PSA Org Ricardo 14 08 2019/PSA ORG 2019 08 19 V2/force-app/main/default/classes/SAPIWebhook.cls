/*
-- - Name         : SAPIWebhook
-- - Author       : DXC. Ruben Fernandez
-- - Date         : 30/12/2018
-- - Description  : Manage all Connections to any DMS system
-- - History:
-- Date         Author  Version  Comments
-- -----------  -----   -------  ---------------------------------------
-- 30/12/2018   DXC     1.0      Initial version rfernandezlo
-- 28/01/2019   SFDC    1.1      C1STAGILE-6493,C1ST-7129
-- 19/01/2019   SFDC    1.2		 Added support to a new Topic & CORS integration
*/
public with sharing class SAPIWebhook {

    private static final String ASSET_ITEM_KEY_PREFIX 	= Asset.sObjectType.getDescribe().getKeyPrefix();
	private static final String ORDER_ITEM_KEY_PREFIX   = Order.sObjectType.getDescribe().getKeyPrefix();
    private static final String QUOTE_ITEM_KEY_PREFIX   = SBQQ__Quote__c.sObjectType.getDescribe().getKeyPrefix();
    private static final String QUOTE_ITEM_KEY_RECTYP   = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get( 'CPQ_Order_Form' ).getRecordTypeId();
    private static final String ACCNT_ITEM_KEY_PREFIX   = Account.sObjectType.getDescribe().getKeyPrefix();
    private static final String CONAC_ITEM_KEY_PREFIX   = AccountContactAssetRelation__c.sObjectType.getDescribe().getKeyPrefix();
    private static final String USER_ID                 = userInfo.getUserId();

    public static List<DMSWebhook__c> dmsEntries;
    public static Map<Id,User> mapRecordOwners;
    public static String sObjType                       = ACCNT_ITEM_KEY_PREFIX;
    //28/01/2019 RFL: C1STAGILE-6493. Replace CreatedById by OwnerId
    public static String PAD_sUserBrand                 = PAD.sUserBrand;
    public static String PAD_sUserDMSPort               = PAD.sUserDMSPort;
    public static String PAD_sIdWorkshop                = PAD.sIdWorkshop;
    public static String PAD_sURLDMS                    = PAD.sURLDMS;
    public static String PAD_sUserTypeCode              = PAD.sUserTypeCode;
    public static String PAD_sUserDMSType               = PAD.sUserDMSType;
    // END C1STAGILE-6493
    
    //Control Recursion
    public static Set <Id> processedRecords 			= new Set<Id>();

    /*
    -- - Name         : ProcessRecords
    -- - Author       : DXC
    -- - Date         : 30/12/2018
    -- - Type         : Public
    -- - Description  : Make the call to the DMS systems
    -- - Params       : List<sObject> lstObjts 
    -- -                Integer iOperation. Create / Update
    -- - Return       : void    	
    */
	public static void ProcessRecords(List<sObject> lstObjts, Integer iOperation){
		System.debug('SAPIWebhook: ProcessRecords');
        //Control duplicated records
        Set<Id> newProcessedRecords = new Set<Id>();
        //Filter the records and return the records that have never been processed
        lstObjts = checkProcessedRecords(lstObjts);
        if(lstObjts.isEmpty()){
            return;
        }

        Set<Id> allOwnersId = new Set<Id>();
        dmsEntries          = new List<DMSWebhook__c>();
        for(sObject obj : lstObjts){
            if(String.valueOf(obj.Id).left(3) == QUOTE_ITEM_KEY_PREFIX){
                allOwnersId.add((ID)obj.get('OwnerId'));
            }
        }
        if(!allOwnersId.isEmpty() && allOwnersId.size()>0){
            mapRecordOwners = getRecordOwners(allOwnersId);
        }
		for(sObject obj : lstObjts){
            
            //28/01/2019 RFL: C1STAGILE-6493. Replace CreatedById by OwnerId
            if(String.valueOf(obj.Id).left(3) == QUOTE_ITEM_KEY_PREFIX){
                String sId           = (STRING)obj.get('OwnerId');
                User uOwner          =  mapRecordOwners.get(sId);
                //if(uOwner != null) {
                PAD_sUserBrand       = (uOwner != null && String.isNotBlank(uOwner.Brand__c))?uOwner.Brand__c:'';
                PAD_sUserDMSPort     = (uOwner != null && String.isNotBlank(uOwner.Contact.Account.DMSport__c))?uOwner.Contact.Account.DMSport__c:'';
                PAD_sIdWorkshop      = (uOwner != null && String.isNotBlank(uOwner.VNRRDICode__c))?uOwner.VNRRDICode__c:uOwner.RAorAgentRRDICode__c;
                PAD_sURLDMS          = (uOwner != null && String.isNotBlank(uOwner.Contact.Account.UrlDMS__c))?uOwner.Contact.Account.UrlDMS__c:'';
                Integer iVal         = PAD.sSalesProfiles.indexOf(uOwner.Profile.Name);
                //if(PAD.sSalesProfiles.indexOf(uOwner.Profile.Name)>=0){
                PAD_sUserTypeCode    = (iVal>=0)?'0':'';
                PAD_sUserDMSType     = (iVal>=0)?'2':'';
                //}else{
                //    PAD_sUserTypeCode    = '';
                //    PAD_sUserDMSType     = '';
                //}
                //}else{
                //    PAD_sUserBrand           = '';
                //    PAD_sUserDMSPort         = '';
                //    PAD_sIdWorkshop          = '';
                //    PAD_sURLDMS              = '';
                //    PAD_sUserTypeCode        = '';
                //    PAD_sUserDMSType         = '';
                //}
            }
            // END C1STAGILE-6493
            Integer iMethod = CalculateMethod(iOperation);
            System.debug('SAPIWebhook.iMethod: ' + iMethod);
            if( iMethod == 2 || iMethod == 4){
            	// Create & Edit. Server to Server
            	addWebhookEntry(obj,iOperation);
        	} 
            //Add new processed record
            newProcessedRecords.add(obj.Id);
        }
        if(!dmsEntries.isEmpty()){
        	Insert dmsEntries;
        }
        
        //Add records to control the recursion
        processedRecords.addAll(newProcessedRecords);
    }

    /*********************************************************************************************************
    * @Method          :   checkProcessedRecords
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/09/2019
    * @Description     :   This method is used to detect records that have already been processed, returns 
    *                      records that have never been processed.
    * @params	       :   List<sObject>: Records that need to be checked
    * @Returns         :   List<sObject>: Records that have never been processed
    **********************************************************************************************************/    
    private static List<sObject> checkProcessedRecords (List<sObject>lstObjts){
        List<sObject> newRecordsToProcess = new List<sObject>();
        for(sObject oObject : lstObjts){
            if(!processedRecords.contains(oObject.Id)){
                newRecordsToProcess.add(oObject);  
            }
        }
        return newRecordsToProcess;
    }        
    
    /*
    -- - Name         : CalculateMethod
    -- - Author       : DXC
    -- - Date         : 30/12/2018
    -- - Description  : Based on the Operation and Type it returns the 
    -- -              : method to be used during the Integration
    -- - Type         : Private
    -- - Params       : Integer iOperation. 0 = Create & 1 = Update
    -- - Return       : Integer. COORS = 1 OR 3, S2S = 2 OR 4
    */
    private static Integer CalculateMethod (Integer iOperation){
    	Integer iResult = 0;
        /*if (iOperation == 0 ){
    		if(PAD_sUserDMSType=='1'){
    			return 1;
    		}else if(PAD_sUserDMSType == '2'){
    			iResult = 2;
    		}
    	}else if (iOperation == 1){
    		if(PAD_sUserDMSType=='1'){
    			return 3;
    		}else if(PAD_sUserDMSType == '2'){
    			iResult = 4;
    		}
    	}*/
        if (iOperation == 0 || iOperation == 1 ){
            if(PAD_sUserDMSType == '2'){
    			iResult = 2;
    		}
        }
    	return iResult;
    }
    // ********* ******** ******* ******* ******* ******* ******* ********* ********* **** //
    // ********* ******** ******* --> SERVER TO SERVER  <-- ********* ********* ********** //
    // ********* ******** ******* ******* ******* ******* ******* ********* ********* **** //
    /*
    -- - Name         : addWebhookEntry
    -- - Author       : DXC
    -- - Date         : 30/12/2018
    -- - Description  : Adds a new WebHook__c entry in dmsEntries global list.
    -- - Type         : Private
    -- - Params       : sObject obj. Record to be added
                        Integer iOperation. 0 = Create & 1 = Update
    -- - Return       : void
    */
    private static void addWebhookEntry(sObject obj, Integer iOperation){
    	sRecordValues aux 		= getObjectValue(obj);
        /* C1ST-7129. IDWorkshop &  SfCustomerId are mandatory */
        if(!String.isEmpty(PAD_sIdWorkshop) && !String.isEmpty(PAD_sUserBrand) && !String.isEmpty(aux.sAccntId)){
        	DMSWebhook__c dmsw 		= new DMSWebhook__c();
    		dmsw.Brand__c 			= PAD_sUserBrand;
    		dmsw.DMSport__c 		= PAD_sUserDMSPort;
    		dmsw.IdWorkshop__c 		= PAD_sIdWorkshop;
    		dmsw.ObjectName__c 		= aux.sName;
    		dmsw.SfCustomerId__c 	= aux.sAccntId;
    		dmsw.SfVehicleId__c 	= aux.sAssetId;
            dmsw.SfQuoteId__c 	    = aux.sQuoteId;
    		dmsw.UrlDMS__c 			= getFinalURL(PAD_sURLDMS,String.valueOf(obj.Id).left(3)); 
            dmsw.UserAction__c  	= String.valueOf(iOperation);
    		dmsw.UserType__c  		= PAD_sUserTypeCode;
    		dmsEntries.add(dmsw);
        }
    }
    /*
    -- - Name         : getRecordOwners
    -- - Author       : DXC
    -- - Date         : 28/02/2018
    -- - Description  : Calculate the Users related with the record owners. (QUOTES)
    -- - Type         : Private
    -- - Params       : Set<Id>. Set of Owner IDs
    -- - Return       : A Map<Id,User> of Active Users for a set of Record Owners.
    */
    private static Map<Id,User> getRecordOwners(Set<Id> allOwners){
       return new Map<Id,User>([SELECT Id,Country__c,Brand__c,LDAPId__c,VNRRDICode__c,RAorAgentRRDICode__c,LanguageLocaleKey,LocaleSidKey,Profile.Name,ContactId,Contact.Account.DMSConnectedToC1st__c, 
            Contact.Account.CommunicationMode__c, Contact.Account.DMSport__c,Contact.Account.Id, Contact.Account.UrlDMS__c FROM User where Id IN : allOwners AND IsActive = true]);
    }
    /*
    -- - Name         : getFinalURL
    -- - Author       : DXC
    -- - Date         : 28/02/2018
    -- - Description  : Calculate the endpoint for the integration. It uses a metadata
    -- -                to get the Subdomain part and add it to dealer url.
    -- - Type         : Public
    -- - Params       : String. URL Protocol + Domain
    -- -                String. SF Object Name. 
    -- - Return       : A Map<Id,User> of Active Users for a set of Record Owners.
    */
    public static String getFinalURL(String sURL, String sObj){
        String sNewURL = ( String.isNotBlank( sURL ) && sURL.right(1)=='/')?sURL:sURL +'/';
        sObj = (String.isBlank(sObj))?sObjType:sObj;
        if (sObj == QUOTE_ITEM_KEY_PREFIX){
            sNewURL = sNewURL + PAD.getDMSEndpoint(QUOTE_ITEM_KEY_PREFIX);
        }else {
            if(String.isNotBlank(PAD.getDMSEndpoint(sObj))){
                sNewURL = sNewURL + PAD.getDMSEndpoint(sObj);
            }else{
                sNewURL = sNewURL + PAD.getDMSEndpoint(ACCNT_ITEM_KEY_PREFIX);
            }
        }
        return sNewURL;
    }
	/*
    -- - Name         : getObjectValue
    -- - Author       : DXC
    -- - Date         : 28/02/2018
    -- - Description  : Calculate the values to be used from each object type
    -- - Type         : Private
    -- - Params       : sObject
    -- - Return       : A new record of sRecordValues custom wrapper.
    */
 	private static sRecordValues getObjectValue(sObject obj){
 		
 		sRecordValues aux;
 		if(String.valueOf(obj.Id).left(3) == ASSET_ITEM_KEY_PREFIX){
 			aux				= new sRecordValues('Asset',(String)obj.get('AccountId'),obj.Id,'','','');
 		}else if (String.valueOf(obj.Id).left(3) == ACCNT_ITEM_KEY_PREFIX){
 			aux				= new sRecordValues('Account',obj.Id,'','','','');
 		}else if (String.valueOf(obj.Id).left(3) == ORDER_ITEM_KEY_PREFIX){
 			aux				= new sRecordValues('Order',(String)obj.get('AccountId'),'',obj.Id,'','');
 		}else if (String.valueOf(obj.Id).left(3) == QUOTE_ITEM_KEY_PREFIX){
            aux             = new sRecordValues('SBQQ__Quote__c',(String)obj.get('SBQQ__Account__c'),'','',obj.Id,'');
        }else if (String.valueOf(obj.Id).left(3) == CONAC_ITEM_KEY_PREFIX){
            aux             = new sRecordValues('AccountContactAssetRelation__c',(String)obj.get('AccountId__c'),(String)obj.get('AssetId__c'),'','',obj.Id);
        }
 		return aux;
 	}
	/*
    -- - Name         : sRecordValues
    -- - Author       : DXC
    -- - Date         : 28/02/2018
    -- - Description  : Custom wrapper. Used to create dms request body
    */
 	public class sRecordValues{
 		public String sName;
 		public String sAccntId;
 		public String sAssetId;
 		public String sOrderId;
        public String sQuoteId;
        public String sAccountContactId;

 		public sRecordValues(String sName, String sAccntId, String sAssetId, String sOrderId, String sQuoteId, String sAccountContactId){
 			this.sName              = sName;
 			this.sAccntId           = sAccntId;
 			this.sAssetId           = sAssetId;
 			this.sOrderId           = sOrderId;
            this.sQuoteId           = sQuoteId;
            this.sAccountContactId  = sAccountContactId;
 		}
 	}
    // ********* ******** ******* --> COORS  <-- ********* ********* ********** //

 	/*
    -- - Name         : setRequestBody
    -- - Author       : DXC
    -- - Date         : 28/02/2018
    -- - Description  : Calculate request body
    -- - Type         : Public
    -- - Params       : sRecordValues. Values to include in the request
    -- - Return       : String. Request body.
    */   
    public static String setRequestBody(sRecordValues aux ){
    	String sJSON;
        /* C1ST-7129. IDWorkshop &  SfCustomerId are mandatory */
        if(!String.isEmpty(PAD.sIdWorkshop) && !String.isEmpty(PAD.sUserBrand) && !String.isEmpty(aux.sAccntId)){
            sJSON='brand=' + PAD.sUserBrand + '&idWorkshop=' +PAD.sIdWorkshop+'&sfCustomerId='+ aux.sAccntId + '&sfVehicleId=' +aux.sAssetId + '&sfQuoteId=' +aux.sQuoteId;
        }
    	return sJSON;
    }
	/*
    -- - Name         : ObjectWrapper
    -- - Author       : DXC
    -- - Date         : 28/02/2018
    -- - Description  : Custom wrapper. Used to compare records.
    */    
    public class ObjectWrapper implements Comparable {
        public Datetime sfLastModifiedDate;
        public String sfCustomerId;
        public String sfVehicleId;
        public String sfQuoteId;
        public ObjectWrapper(Datetime sfLastModifiedDate, String sfCustomerId, String sfVehicleId, String sfQuoteId) {
            this.sfLastModifiedDate = sfLastModifiedDate;
            this.sfCustomerId       = sfCustomerId;
            this.sfVehicleId        = sfVehicleId;
            this.sfQuoteId          = sfQuoteId;
        }
        public Integer compareTo(Object compareTo) {
            ObjectWrapper ctA = (ObjectWrapper) compareTo;
            if (ctA.sfLastModifiedDate > this.sfLastModifiedDate){ return +1;}
            if (ctA.sfLastModifiedDate < this.sfLastModifiedDate){ return -1;}
            return 0; 
        }
    }
 	/*
    -- - Name         : getRequestParams
    -- - Author       : DXC
    -- - Date         : 28/02/2018
    -- - Description  : Return the request body
    -- - Type         : Public
    -- - Params       : -
    -- - Return       : String. The final boby.
    */   
    public static String getRequestParams(){
        
        sRecordValues aux;

        List<ObjectWrapper> lstAux = (PAD.sUserTypeCode == '1')?getAfterSalesRecords():getSalesRecords();

        if(!lstAux.isEmpty()){
            lstAux.sort();
            aux = new sRecordValues('',lstAux.get(0).sfCustomerId,lstAux.get(0).sfVehicleId,'','','');
        }else{
            aux = new sRecordValues('','','','','','');
            //aux = new sRecordValues('',lstAux.get(0).sfCustomerId,lstAux.get(0).sfVehicleId,'',lstAux.get(0).sfQuoteId,'');
        }
        return  setRequestBody(aux);
    }
 	/*
    -- - Name         : getRequestCustomParams
    -- - Author       : SF
    -- - Date         : 28/02/2019
    -- - Description  : Return the dms request body. This method is used only for AfterSaels Appoitment.
    -- - Type         : Public
    -- - Params       : String. Account Id 
    -- -                String. Asset Id
    -- - Return       : String. The final boby.
    */  
    public static String getRequestCustomParams(String sRecordId_A,String sRecordId_B){
        sRecordValues aux = new sRecordValues('',sRecordId_A,sRecordId_B,'','','');
        return setRequestBody(aux);
    }
 	/*
    -- - Name         : getSalesRecords
    -- - Author       : SF
    -- - Date         : 28/02/2019
    -- - Description  : Get the last records created / edited by the current user.
                        Records: SBQQ__Quote__c and Order
    -- - Type         : Private
    -- - Params       : None
    -- - Return       : List<ObjectWrapper>. Records found.
    */  
    private static List<ObjectWrapper> getSalesRecords(){
        List<ObjectWrapper> lstAux = new List<ObjectWrapper>();
        // SALES: PAD.sUserTypeCode == '0' only creation
        List<SBQQ__Quote__c> lstQuotes = new List<SBQQ__Quote__c>([
                                SELECT SBQQ__Account__c,LastModifiedDate 
                                FROM SBQQ__Quote__c 
                                WHERE OwnerId =: USER_ID 
                                AND LastModifiedDate >= : Datetime.now().addSeconds(-10)
                                AND RecordTypeId =: QUOTE_ITEM_KEY_RECTYP
                                Order by LastModifiedDate DESC Limit 1]);
        List<Order> lstOrders = new List<Order>([
                                SELECT AccountId,AssetId__c,LastModifiedDate 
                                FROM Order 
                                WHERE LastModifiedById =:USER_ID 
                                AND CreatedDate >= :Datetime.now().addSeconds(-5) Order by LastModifiedDate DESC Limit 1]);
        if(!lstQuotes.isEmpty()){
            lstAux.add(new ObjectWrapper(lstQuotes.get(0).LastModifiedDate,lstQuotes.get(0).SBQQ__Account__c,'',lstQuotes.get(0).Id));
            sObjType = QUOTE_ITEM_KEY_PREFIX;
        }    
        if(!lstOrders.isEmpty()){
            lstAux.add(new ObjectWrapper(lstOrders.get(0).LastModifiedDate,lstOrders.get(0).AccountId,lstOrders.get(0).AssetId__c,''));
        }
        return lstAux;
    }
    /*
    -- - Name         : getAfterSalesRecords
    -- - Author       : SF
    -- - Date         : 28/02/2019
    -- - Description  : Get the last records created / edited by the current user
                        Records: Account, Asset and AccountContactAssetRelation__c
    -- - Type         : Private
    -- - Params       : None
    -- - Return       : List<ObjectWrapper>. Records found.
    */  
    private static List<ObjectWrapper> getAfterSalesRecords(){
        List<ObjectWrapper> lstAux = new List<ObjectWrapper>();
        //AFTER SALE:  PAD.sUserTypeCode == '1'
        List<Account> lstAccnt                  = new List<Account>([
                                SELECT Id,LastModifiedDate 
                                FROM Account 
                                WHERE LastModifiedById =:USER_ID 
                                AND LastModifiedDate >= :Datetime.now().addSeconds(-5) Order by LastModifiedDate DESC Limit 1]);
        List<Asset> lstAsset                    = new List<Asset>([
                                SELECT Id,AccountId,LastModifiedDate
                                FROM Asset 
                                WHERE LastModifiedById =:USER_ID 
                                AND LastModifiedDate >= :Datetime.now().addSeconds(-5) Order by LastModifiedDate DESC Limit 1]);
        List<AccountContactAssetRelation__c> lstAccAss = new List<AccountContactAssetRelation__c>([
                                SELECT AccountId__c,AssetId__c,LastModifiedDate 
                                FROM AccountContactAssetRelation__c 
                                WHERE LastModifiedById =:USER_ID 
                                AND LastModifiedDate >= :Datetime.now().addSeconds(-5) Order by LastModifiedDate DESC Limit 1]);
        if(!lstAccnt.isEmpty()){
            lstAux.add(new ObjectWrapper(lstAccnt.get(0).LastModifiedDate,lstAccnt.get(0).Id,'',''));
        }
        if(!lstAsset.isEmpty()){
            lstAux.add(new ObjectWrapper(lstAsset.get(0).LastModifiedDate,lstAsset.get(0).AccountId,lstAsset.get(0).Id,'')); 
        }
        if(!lstAccAss.isEmpty()){
            lstAux.add(new ObjectWrapper(lstAccAss.get(0).LastModifiedDate,lstAccAss.get(0).AccountId__c,lstAccAss.get(0).AssetId__c,''));
        }
        return lstAux;
    }
}
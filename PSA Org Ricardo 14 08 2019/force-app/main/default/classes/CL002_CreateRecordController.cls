public with sharing class CL002_CreateRecordController {

	public static Map<Id, String> recordtypeMap {get;set;}
	public static Map<String, Schema.RecordTypeInfo> recordTypeInfoMap = new Map<String, Schema.RecordTypeInfo>();
    
   	@AuraEnabled        
    public static List<String> fetchRecordTypeValues(String sObjectName){
    	sObject auxObj;
    	Schema.SObjectType auxSObjectType = Schema.getGlobalDescribe().get(sObjectName);
    	if(auxSObjectType!=null){
    		auxObj = auxSObjectType.newSObject();
    		Schema.DescribeSObjectResult auxSObjectResult= auxObj.getSObjectType().getDescribe();
    		if(auxSObjectResult!=null){
				recordtypeMap = new Map<Id, String>();
		        for(RecordTypeInfo auxRTI : auxSObjectResult.getRecordTypeInfos()){
		            if(!auxRTI.isMaster() && auxRTI.isActive() && auxRTI.isAvailable()){
		            	recordtypeMap.put(auxRTI.getRecordTypeId(), auxRTI.getName());
                    }
		        }        
		        return recordtypemap.values();
    		}
    	}
		return new List<String>();
    }

    @AuraEnabled        
    public static String fetchDefaultRecordType(String sObjectName){
        sObject auxObj;
        String defaultRecordType = '';
        Schema.SObjectType auxSObjectType = Schema.getGlobalDescribe().get(sObjectName);
        if(auxSObjectType!=null){
            auxObj = auxSObjectType.newSObject();
            Schema.DescribeSObjectResult auxSObjectResult= auxObj.getSObjectType().getDescribe();
            if(auxSObjectResult!=null){
                recordtypeMap = new Map<Id, String>();
                for(RecordTypeInfo auxRTI : auxSObjectResult.getRecordTypeInfos()){
                    if(!auxRTI.isMaster() && auxRTI.isActive() && auxRTI.isAvailable() && auxRTI.isDefaultRecordTypeMapping()){
                        defaultRecordType = auxRTI.getName();
                    }
                }
            }
        }
        return defaultRecordType;
    }
    
    
    @AuraEnabled
    public static Id getRecordTypeId(String sObjectName, String recordTypeLabel){

		sObject auxObj;
    	Schema.SObjectType auxSObjectType = Schema.getGlobalDescribe().get(sObjectName);
    	if(auxSObjectType!=null && recordTypeLabel!=null){
    		auxObj = auxSObjectType.newSObject();
    		Schema.DescribeSObjectResult auxSObjectResult= auxObj.getSObjectType().getDescribe();
    		if(auxSObjectResult!=null){
				recordTypeInfoMap	= auxSObjectResult.getRecordTypeInfosByName();
				if(recordTypeInfoMap.containsKey(recordTypeLabel)){
		        	return recordTypeInfoMap.get(recordTypeLabel).getRecordTypeId();        
        		}
    		}
    	}
    	return null;
    }
    @AuraEnabled        
    public static Map<String,String> DMSWakeUpbyCORS(String sType){
        Map<String,String>  sCORS = new Map<String,String>();
        if(PAD.sUserDMSType=='1'){
            sCORS.put('body',SAPIWebhook.getRequestParams());
            sCORS.put('endpoint',SAPIWebhook.getFinalURL(PAD.sURLDMS,null));
        }
        return sCORS;
    }
    //@TestVisible
    //private static String getObjectValue(String sType){
    //    String usrId = userInfo.getUserId();
    //    SAPIWebhook.sRecordValues aux;
    //    List<Account> lstAccnt                  = new List<Account>([
    //                            SELECT Id,LastModifiedDate 
    //                            FROM Account 
    //                            WHERE CreatedById =:usrId 
    //                            AND CreatedDate >= : Datetime.now().addSeconds(-10) 
    //                            Order by CreatedDate DESC Limit 1]);
    //    List<Asset> lstAsset                    = new List<Asset>([
    //                            SELECT Id,AccountId,LastModifiedDate
    //                            FROM Asset 
    //                            WHERE CreatedById =:usrId 
    //                            AND CreatedDate >= : Datetime.now().addSeconds(-10) 
    //                            Order by CreatedDate DESC Limit 1]);
    //    List<AccountContactAssetRelation__c> lstAccAss = new List<AccountContactAssetRelation__c>([
    //                            SELECT AccountId__c,AssetId__c,LastModifiedDate 
    //                            FROM AccountContactAssetRelation__c 
    //                            WHERE CreatedById =:usrId 
    //                            AND CreatedDate >= : Datetime.now().addSeconds(-10) 
    //                            Order by CreatedDate DESC Limit 1]);
    //    List<SAPIWebhook.ObjectWrapper> lstAux = new List<SAPIWebhook.ObjectWrapper>();
    //    if(!lstAccnt.isEmpty()){
    //        lstAux.add(new SAPIWebhook.ObjectWrapper(lstAccnt.get(0).LastModifiedDate,lstAccnt.get(0).Id,''));
    //    }
    //    if(!lstAsset.isEmpty()){
    //        lstAux.add(new SAPIWebhook.ObjectWrapper(lstAsset.get(0).LastModifiedDate,lstAsset.get(0).AccountId,lstAsset.get(0).Id)); 
    //    }
    //    if(!lstAccAss.isEmpty()){
    //        lstAux.add(new SAPIWebhook.ObjectWrapper(lstAccAss.get(0).LastModifiedDate,lstAccAss.get(0).AccountId__c,lstAccAss.get(0).AssetId__c));
    //    }
    //    if(!lstAux.isEmpty()){
    //        lstAux.sort();
    //        aux = new SAPIWebhook.sRecordValues('',lstAux.get(0).sfCustomerId,lstAux.get(0).sfVehicleId,'','','');
    //    }else{
    //        aux = new SAPIWebhook.sRecordValues('','','','','','');
    //    }
    //    return  SAPIWebhook.setRequestBody(aux);
    //}
}
/*
-- -----------  -----   -------  ------------------------------------------------------
-- - Name         : PAD
-- - Author       : DXC. Ruben Fernandez
-- - Date         : 18/01/2018
-- - Description  : Static Methods.
--                  getToken. Return the Security token to decrypt the secret quetion
--                            to get access to a specific record.
--                  getObjRecordType. Return the record type ID select for any object
-- - History:
-- Date         Author  Version  Comments
-- -----------  -----   -------  ------------------------------------------------------
-- 18/01/2018   DXC     1.0      Initial version rfernandezlo
*/
public with sharing class PAD {

    public static final string bypassTrigger;                           //List of triggers that can be bypassed
    public static final string sTokenValue;	                            //Token vaulue
    public static final string sUserCountry;                            //Current User Country
    public static final string sUserBrand;                              //Current User Brand
    public static final string sUserType;                               //Current User Type
    public static final string sUserTypeCode;                           //Current User Type
    public static final Boolean sUserDMS;                               //Current Dealer DMS   
    public static final string sUserDMSType;                            //Current Dealer Type
    public static final string sUserDMSPort;                            //Current Dealer DMS Port   
    public static final string sIdWorkshop;                             //Current User Brand
    public static final string sURLDMS;                                 //Current User DMS URL
    public static final User uCurrentUserName;                          //Current User
    public static final String sSalesProfiles;
    public static final String sASalesProfiles;
    public static final String sApiUsers;

    public static Set<Id> SetOfRecordIDs = new Set<Id>();               // Recursive
    public static boolean bRunWebHook    = true;

    public static final List<RecordType> recordTypes;                   //cached record types
    public static final map<String, Id> recordTypesMapByDeveloperName;  //cached record types in a map <String, Id> with key like Sobjecttype concat with record type's developer name ie: Account_Account_B2B
    public static final Map<String, String> mapDMSEndpoints;            //cached enpoints in a map <Id, DeveloperName>

    static{
        System.Debug('## >>> PAD constructor :BEGIN <<< run by ' + UserInfo.getName());
        recordTypes                     = [SELECT id,Name,DeveloperName,SobjectType FROM recordtype WHERE isActive = true AND SobjectType IN ('Account','Lead','Contact','Asset','Opportunity','Order','SBQQ__Quote__c','Campaign')];
        recordTypesMapByDeveloperName   = new Map<String, Id>();
        mapDMSEndpoints                 = new Map<String, String>();

        List<CustomerSearchSettings__mdt> lstFields = [SELECT SearchFields__c FROM CustomerSearchSettings__mdt where QualifiedApiName = 'SecretQuestionToken' limit 1]; 
        Map<String, Schema.SObjectType> SchemaMap = Schema.getGlobalDescribe();

        for(UtilSetting__mdt larp : [
            SELECT MasterLabel, QualifiedApiName, Value__c,Value2__c, Value3__c
            FROM UtilSetting__mdt
            where QualifiedApiName IN ('Webhook_AllProfiles', 'DMSEndpointAccount', 'DMSEndpointQuote')]
        ){
            if(String.valueOf(larp.QualifiedApiName).indexOf('Webhook_All') > -1){
                sSalesProfiles      = larp.Value__c;
                sASalesProfiles     = larp.Value2__c;
                sApiUsers           = larp.Value3__c;
            }else{
                Schema.SobjectType objSchema = SchemaMap.get(larp.Value2__c);
                mapDMSEndpoints.put( objSchema.getDescribe().getKeyPrefix(), larp.Value__c);
            }
        }

        for (User aux : [
            SELECT
                Id,
                Country__c,
                Brand__c,
                LDAPId__c,
                VNRRDICode__c,
                RAorAgentRRDICode__c,
                LanguageLocaleKey,
                LocaleSidKey,
                Profile.Name,
                ContactId,
                Contact.Account.DMSConnectedToC1st__c, 
                Contact.Account.CommunicationMode__c,
                Contact.Account.DMSport__c,
                Contact.Account.Id,
                Contact.Account.UrlDMS__c,
                ByPassApexTriggers__c,
                UserRole.Name,
                AccountId,
                TECH_ProcessBuilderBypass__c
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ]){
            bypassTrigger           = aux.BypassApexTriggers__c == null ? '' : aux.BypassApexTriggers__c;
            sUserCountry            = aux.Country__c;
            sUserBrand              = aux.Brand__c;
            sIdWorkshop             = (!String.isBlank(aux.RAorAgentRRDICode__c))?aux.RAorAgentRRDICode__c:aux.VNRRDICode__c;
            sURLDMS                 = aux.Contact.Account.UrlDMS__c;
            if(aux.Profile != null && sSalesProfiles.indexOf(aux.Profile.Name)>=0){
                sUserType           = 'Sales';
                sUserTypeCode       = '0';
            }else if (aux.Profile!= null && sASalesProfiles.indexOf(aux.Profile.Name)>=0){
                sUserType           = 'AfterSales';
                sUserTypeCode       = '1';
            }else if (aux.Profile!= null && sApiUsers.indexOf(aux.Profile.Name)>=0){
                sUserType           = 'ApiUser';
                sUserTypeCode       = '3';
            }else{
                sUserType           = 'Other';
                sUserTypeCode       = '2';
            }
            if(aux.ContactId != null){
                if(aux.Contact.Account!=null){
                    sUserDMS        = aux.Contact.Account.DMSConnectedToC1st__c; 
                    sUserDMSType    = aux.Contact.Account.CommunicationMode__c; 
                    sUserDMSPort    = aux.Contact.Account.DMSport__c;    
                }
            }else{
                sUserDMS            = false;
                sUserDMSType        = '0';
                sUserDMSPort        = '';
            }
            uCurrentUserName        = aux;
        }
        if(lstFields!=null && !lstFields.isEmpty()){
            sTokenValue             = lstFields.get(0).searchfields__c;
        } 
        // Deprecated. To be removed. Must be replace by the new method 
        // getRecordTypeIdByDeveloperName
        for(RecordType rt : recordTypes){
            //recordTypesMapById.put(rt.Id, rt.DeveloperName);
            // Deprecated
            recordTypesMapByDeveloperName.put(rt.SobjectType + '_' + rt.DeveloperName, rt.Id);
        }
        System.Debug('## >>> PAD constructor :END <<< ');
    }

    public static String getDMSEndpoint(String sObjName){
        String sResult = '';
        if(mapDMSEndpoints.containsKey(sObjName)){
            sResult = mapDMSEndpoints.get(sObjName);
        }
        return sResult;
    }
    /**
     * This method is used to return if the current user is allowed to  
     * execute a trigger.
     * @param:  Name of the trigger method to validate.
     * @return: True if can be executed, otherwise it return false;
     */
    public static boolean canTrigger(string ApexName){
        return !bypassTrigger.contains(ApexName);
    }

    /**
     * This method is used to return a the secret token
     */ 
    public static string getToken(){
        return sTokenValue;
    }
    /**
     * This method is used to return the sobject record type ID. 
     * Note: Deprecated, use getRecordTypeIdByDeveloperName;
     */
     
    public static String getObjRecordType(String objName,String prefixName){
        String sRT  =  '';
        for(RecordType r: recordTYpes){
            if(r.name.startsWith(prefixName) && r.SobjectType==objName) {return r.Id;}
        }
        return sRT;
    }
    /**
     * This method is used to return the sobject record type ID. 
     * Note: It must be active and visible to the current user.
     * @param:  Name of the sObject.
     * @param:  Record type name (developer name).
     * @return: The record type id
     */
    public static Id getRecordTypeIdByDeveloperName(String sObjName, String sRecordTypeName){
    
        if(String.isNotBlank(sObjName) && String.isNotBlank(sRecordTypeName)){
            Schema.SObjectType oSchemaSObjectType           = Schema.getGlobalDescribe().get(sObjName);
            if (oSchemaSObjectType != null) {
                Schema.DescribeSObjectResult oDesSObjectRes = oSchemaSObjectType.newSObject().getSObjectType().getDescribe(); 
                if (oDesSObjectRes != null){
                    Map<String,Schema.RecordTypeInfo> mRType= oDesSObjectRes.getRecordTypeInfosByDeveloperName();
                    if (mRType != null && mRType.containsKey(sRecordTypeName)) {
                        Schema.RecordTypeInfo orecTypeRes   = mRType.get(sRecordTypeName);
                        // return only if is active and visible to the current user
                        if (orecTypeRes != null && orecTypeRes.isAvailable() && orecTypeRes.isActive()) {
                            return orecTypeRes.getRecordTypeId();
                        }
                    }
                }
            }
        }
        return null;
    }
    public static Map<String, String> getFieldLabel(String sObjectName) {
        Map<String, Schema.SObjectType> mapGlobalD      = Schema.getGlobalDescribe();
        Schema.SObjectType systemObjectType             = mapGlobalD.get(sObjectName);
        // the map to be returned with the final data
        Map<String,String> finalMap                     = new Map<String, String>();
        
        for(Schema.SObjectField fieldAPI : systemObjectType.getDescribe().fields.getMap().values()) {
            finalMap.put(fieldAPI.getDescribe().getName(),fieldAPI.getDescribe().getLabel());
        }
        return finalMap;
    }
}
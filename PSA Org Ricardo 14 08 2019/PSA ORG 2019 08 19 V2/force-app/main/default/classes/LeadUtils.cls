/*
-- - Name         : LeadUtils
-- - Author       : DXC. Ruben Fernandez
-- - Date         : 17/02/2018
-- - Description  : Util Class.
--
-- - History:
-- Date         Author  Version  Comments
-- -----------  -----   -------  ---------------------------------------
-- 17/02/2018   DXC     1.0      Initial version rfernandezlo
-- 18/10/2018   DXC     1.1      Fixed an issue with custom metadata and soql with OR clause
-- 27/05/2019   DR      1.2      Added getSubsidiaryConfig and setCallCount methods
*/
public with sharing class LeadUtils {

    private static Map <String, String> ACTIVITY_MAPPING;

    //private static final String ACTIVITY_GROUP_KEY1   = '1';  
    //private static final String ACTIVITY_GROUP_KEY2   = '2';
    private static final string SOQL_WHERE_AND          = ' AND ';
    private static final string SOQL_WHERE_OR           = ' OR ';
    private static final string SOQL_CONF_SELECT        = 'SELECT ';
    private static final string SOQL_CONF_FROM          = 'FROM ';
    private static final string SOQL_CONF_WHERE         = 'WHERE ';
    private static final string SOQL_CONF_OWNER         = 'OwnerId';
    private static final string SOQL_CONF_CPOSF         = 'CalculatedPOS__c';
    private static string SOQL_TYPE_SLA                 = '';
    private static string SOQL_BH_QUERY                 = '';
    private static string SOQL_CONF_FIELDS              = '';
    private static string SOQL_CONF_FROMOBJ             = '';
    private static String CEC_STR                       = 'CEC';
    private static String TYPE_QUEUE                    = 'Queue';
    private static String TASK_SUBTYPE_CALL             = 'Call';
    private static final String QUEUE_ITEM_KEY_PREFIX   = Group.sObjectType.getDescribe().getKeyPrefix();
    private static List<String> LSTFIELDNAMES;
    private static List<String> LSTFIELDNAMEM;

    private static final Set<String> NO_DEALER_CEC_FROFILES = new Set<String>{
        'CEC_Agent',
        'CEC_Supervisor'
    };

    private static Map<String,Schema.RecordTypeInfo> LEAD_RT_MAP
        = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName();

    private static final List<String> CONVERSION_STATUS
        = new List<String>{'Nurturing', 'Qualified'};

    private static final Map<String, String> LEAD_ACT_USER_MAP = 
        new Map<String, String>();

    private static final Map<String, List<String>> RELEVANT_EVENT_TYPES =
        new Map<String, List<String>>();

    private static final Map<String, LeadCallSetting__mdt> CALL_MD = 
        new Map<String, LeadCallSetting__mdt>();

    static {
        for (UserLeadActivityAssignment__mdt m : [
            SELECT DeveloperName, ActivityTypes__c
            FROM UserLeadActivityAssignment__mdt
        ]) {
            LEAD_ACT_USER_MAP.put(m.DeveloperName, m.ActivityTypes__c);
        }

        for (RelevantEventTypes__mdt m : [
            SELECT DeveloperName, Type__c
            FROM RelevantEventTypes__mdt
        ]) {
            RELEVANT_EVENT_TYPES.put(m.DeveloperName, m.Type__c.split(';'));
        }

        for (LeadCallSetting__mdt m : [
            SELECT DeveloperName, CallAttempts__c, FallbackQueueId__c
            FROM LeadCallSetting__mdt
        ]) {
            CALL_MD.put(m.DeveloperName, m);
        }
    }

    /*  Name        : AssignLeadBySalesManager
        Description : Assign Lead Owner based on Sales Manager
        @PARAM      : Lead --> Record to be assigned
                    : sTargetValue --> New Owner / Criteria
        @OUTPUT     : Lead OwnerId updated with the new value
    */
    public static void dtDueDate(list<Lead> lstLeads, String function){
        
        List<String> lstName                = new List<String>();
        List<WhereCriteria> allCriterias   = new List<WhereCriteria>();
        List<String> fullCriterias         = new List<String>();
        List<String> lstEndCriterias        = new List<String>();
        // Start Change
        Map<String,Set<String>> auxWhere = new Map<String,Set<String>>();
        // End Change
        ACTIVITY_MAPPING = new Map<String,String>();
        for(UtilSetting__mdt larp : [SELECT MasterLabel, QualifiedApiName, Value__c,Value2__c FROM UtilSetting__mdt where QualifiedApiName LIKE 'LeadSLAConfiguration%']){
            String sValue = larp.QualifiedApiName;
            String sAuxVal = larp.Value__c;
            if(sValue.indexof('BH')>0 ){
                SOQL_BH_QUERY = sAuxVal + ' ';
            }else if(sValue.indexof('MD')>0){
                SOQL_CONF_FIELDS = sAuxVal;
            }else if(sValue.indexof('MF')>0){
                LSTFIELDNAMEM= sAuxVal.split(',');
            }else if(sValue.indexof('LF')>0){
                LSTFIELDNAMES = sAuxVal.split(',');
            }else if(sValue.indexof('OB')>0){
                SOQL_TYPE_SLA = sAuxVal;
            }else if(sValue.indexof('CO')>0){
                SOQL_CONF_FROMOBJ = sAuxVal;
            }else if(sValue.indexof('T')>0){
                ACTIVITY_MAPPING.put(larp.Value__c,larp.Value2__c);
            }
        }

        //setActivityMapping();
        for(sObject obj : lstLeads){
            String sID = (String.valueOf(obj.get(LSTFIELDNAMES.get(4))).left(3)!=QUEUE_ITEM_KEY_PREFIX)?(String)obj.get(SOQL_CONF_CPOSF):(String)obj.get(LSTFIELDNAMES.get(4));
            lstName.add(SOQL_TYPE_SLA + (String)obj.get(LSTFIELDNAMES.get(0))+(String)obj.get(LSTFIELDNAMES.get(1))+ACTIVITY_MAPPING.get((String)obj.get(LSTFIELDNAMES.get(2)))+(String)obj.get(LSTFIELDNAMES.get(3))+sID);
            allCriterias   = new List<WhereCriteria>();
            Integer iPos    = 0;
            for(String fieldName : LSTFIELDNAMES) {
                Set<String> auxLst = new Set<String>();
                String sFieldValue = (String)obj.get(fieldName);
                    /* BEGIN - Manuel Medina - C1STAGILE-5236 - Logic to avoid Null Pointer Exception when auxWhere returs null for an specific key - 19102018 */
                    //if( LSTFIELDNAMEM.get( iPos ) != null && auxWhere.containsKey( LSTFIELDNAMEM.get( iPos ) ) && fieldName != SOQL_CONF_OWNER ){
                    /* END - Manuel Medina - 19102018 */
                    if( LSTFIELDNAMEM.get( iPos ) != null && fieldName != SOQL_CONF_OWNER ) {
                        if(auxWhere.containsKey(LSTFIELDNAMEM.get(iPos))) {
                            auxLst= auxWhere.get(LSTFIELDNAMEM.get(iPos));
                        }
                        if (!String.isBlank(sFieldValue)) {
                            if( fieldName.equals( 'Activity__c' ) ){
                                auxLst.add( ACTIVITY_MAPPING.get( sFieldValue ) );
                            } else {
                                auxLst.add(sFieldValue);
                            }
                            auxWhere.put(LSTFIELDNAMEM.get(iPos), auxLst);
                        }
                    } else {

                        /* BEGIN - Manuel Medina - C1STAGILE-5236 - Logic to avoid Null Pointer Exception - 19102018 */
                        //sID = (String.valueOf(obj.get(fieldName)).left(3)!=QUEUE_ITEM_KEY_PREFIX)?(String)obj.get(SOQL_CONF_CPOSF):(String)obj.get(fieldName);
                        sID             = ( sFieldValue != null && sFieldValue.left( 3 ) != QUEUE_ITEM_KEY_PREFIX ) ? ( String ) obj.get( SOQL_CONF_CPOSF ) : sFieldValue;
                        /* END - Manuel Medina - 19102018 */

                        if (!String.isBlank(sID)) {
                            auxLst.add(sID);
                            auxWhere.put(LSTFIELDNAMEM.get(iPos), auxLst);
                        }
                    }
                iPos+=1;
            }
            // Start Change
            for(String s : auxWhere.keyset()){

                allCriterias.add(new WhereCriteria(s,auxWhere.get(s), 'IN'));
            }
            // End Change
        }
        // Start Change
        String strCriterias = generateWhereQuery(allCriterias);

        if(strCriterias != null && strCriterias != ''){
            fullCriterias.add('(' + generateWhereQuery(allCriterias) +')');
        }
        // END Change

        Map<String,LeadSLAConfiguration__mdt> mapSLAs   = loadSLAValues(String.join(fullCriterias, SOQL_WHERE_AND));
        List<BusinessHours> lstBH                       = SearchRecords(SOQL_BH_QUERY+quoteKeyList(lstName));
        Map<String,BusinessHours> mapBH                 = new Map<String,BusinessHours>();
        for(BusinessHours bh : lstBH){
            mapBH.put(bh.Name, bh);
        }

        Set<Id> lst_owner = new Set<Id>();
        for(Lead l : lstLeads){
            lst_owner.add(l.OwnerId);
        }

        Map<Id, Group> mapQueues = new Map<Id, Group>([
            SELECT Id, Name
            FROM Group
            WHERE
                Id IN : lst_owner AND
                Type =: TYPE_QUEUE
        ]);

        Map<Id, Lead> mapLeadsToUpdateFromTask = new Map<Id, Lead>();
        Integer iTimeToAdd = 0;
        for(Lead l : lstLeads){ 
            mapLeadsToUpdateFromTask.put(l.Id, l);
            String sID = (Group.sObjectType != l.OwnerId.getSObjectType()) ? l.CalculatedPOS__c : l.OwnerId;

            if(mapSLAs.containsKey(l.LeadCountry__c + l.PSABrand__c + ACTIVITY_MAPPING.get(l.Activity__c) + l.LeadType__c + sID )){
                iTimeToAdd = (Integer)mapSLAs.get(l.LeadCountry__c + l.PSABrand__c + ACTIVITY_MAPPING.get(l.Activity__c) + l.LeadType__c + sID).SLAFirstAction__c *60000;

                if(mapBH.containsKey(SOQL_TYPE_SLA +l.LeadCountry__c + l.PSABrand__c + ACTIVITY_MAPPING.get(l.Activity__c) + l.LeadType__c + sID)){
                    try{
                        BusinessHours leadBH    = mapBH.get(SOQL_TYPE_SLA +l.LeadCountry__c + l.PSABrand__c + ACTIVITY_MAPPING.get(l.Activity__c) + l.LeadType__c + sID);


                        // Datetime dtNewTime  = BusinessHours.addGmt(mapBH.get(SOQL_TYPE_SLA +l.LeadCountry__c + l.PSABrand__c + ACTIVITY_MAPPING.get(l.Activity__c) + l.LeadType__c +  sID).Id, l.CreatedDate, iTimetoAdd);
                        Datetime dtNewTime      = BusinessHours.addGmt(leadBH.Id, l.CreatedDate, iTimetoAdd);
                        String ownerId          = l.OwnerId;
                        if(function == 'process'){
                            if(
                                mapQueues.containskey(ownerId) &&
                                !mapSLAs.get(l.LeadCountry__c + l.PSABrand__c + ACTIVITY_MAPPING.get(l.Activity__c) + l.LeadType__c + sID).IsDealerQueue__c
                            ){
                                //l.CECTreatmentDueDate__c = dtAdjustTimeZone(dtNewTime,mapBH.get(SOQL_TYPE_SLA +l.LeadCountry__c + l.PSABrand__c + ACTIVITY_MAPPING.get(l.Activity__c) + l.LeadType__c + sID).TimeZoneSidKey);
                                l.CECTreatmentDueDate__c = dtAdjustTimeZone(dtNewTime,leadBH.TimeZoneSidKey);
                                l.TECH_CECSLAFirstAction__c = mapSLAs.get(l.LeadCountry__c + l.PSABrand__c + ACTIVITY_MAPPING.get(l.Activity__c) + l.LeadType__c + sID ).SLAFirstAction__c;
                            } else {//if(ownerId.startsWith('005')){

                                //l.TreatmentDueDate__c = dtAdjustTimeZone(dtNewTime,mapBH.get(SOQL_TYPE_SLA +l.LeadCountry__c + l.PSABrand__c + ACTIVITY_MAPPING.get(l.Activity__c) + l.LeadType__c + sID).TimeZoneSidKey);
                                l.TreatmentDueDate__c = dtAdjustTimeZone(dtNewTime,leadBH.TimeZoneSidKey);
                                l.TECH_SLAFirstAction__c = mapSLAs.get(l.LeadCountry__c + l.PSABrand__c + ACTIVITY_MAPPING.get(l.Activity__c) + l.LeadType__c + sID ).SLAFirstAction__c;
                            }

                        } else if(function == 'task'){
                            if(l.ActualFirstEmailSentDate__c == null){
                                /* START CHANGE: --> RUBEN <-- */
                                /* Get the right Lead Treatment Due Date, Queue or User */
                                Datetime firstEmailSendDateBH = (String.valueOf(l.OwnerId).left(3)==QUEUE_ITEM_KEY_PREFIX && mapQueues.containskey(ownerId) && mapQueues.get(ownerId).Name.startsWith(CEC_STR)) ?
                                    l.CECTreatmentDueDate__c : l.TreatmentDueDate__c;

                                if (firstEmailSendDateBH != null) {
                                    /* Calculate the difference in milliseconds between Treatmeant Due Date and Now. Based on Owner's B.Hours */
                                    Long dif = BusinessHours.diff(leadBH.Id, System.now(),firstEmailSendDateBH);

                                    /* Milliseconds to minutes conversion */
                                    Integer timeSentEmail = (((iTimetoAdd - dif) / 1000) / 60).intValue();

                                    /* Returning the result. A negative means its processed outside SLA range */
                                    l.TimeFirstEmailSent__c = (timeSentEmail<0)?0:timeSentEmail;
                                }
                                l.ActualFirstEmailSentDate__c = System.now();
                                /* END CHANGE: --> RUBEN <-- */
                                mapLeadsToUpdateFromTask.put(l.Id, l);
                            }
                        } 
                    }catch(Exception e){
                        System.debug('Exception dtDueDate e: ' + e);
                    }
                }//end if BHs
            }//end if SLAs

        }//End Loop Leads

        //Update Leads (Case Task)
        if(function == 'task'){
            //Set Actual Treatment Date when a user log a call
            List <Lead> listLeadsToUpdateFromTask = setActualTreatmentDate(null, mapLeadsToUpdateFromTask.values(), 'INSERT_TASK');
            if(listLeadsToUpdateFromTask!= null && listLeadsToUpdateFromTask.size()>0){
                update listLeadsToUpdateFromTask;
            }
        }
    }
    
    /*  Name        : Default
        Description : Activity Mapping.
        @OUTPUT     : void
    */
    private static Map<String,LeadSLAConfiguration__mdt> loadSLAValues(String sWhereCond){

        Map<String,LeadSLAConfiguration__mdt> mapSLA = new Map<String,LeadSLAConfiguration__mdt>();
        if(!String.isEmpty(sWhereCond) && sWhereCond != '()') {

            List<LeadSLAConfiguration__mdt> lValues = SearchRecords(SOQL_CONF_FIELDS + ' ' + SOQL_CONF_FROM + SOQL_CONF_FROMOBJ + ' ' + SOQL_CONF_WHERE + sWhereCond);
            for(LeadSLAConfiguration__mdt aux : lValues) {
                String sKey = aux.Country__c + aux.Brand__c + aux.CategoryType__c + aux.Type__c + aux.RecordOwner__c;
                if(!mapSLA.containsKey(sKey)){
                    mapSLA.put(sKey, aux);
                }
            }
        }
        return mapSLA;
    }
    /*  Name        : quoteKeyList
        Description : Convert a List into a String,
        @OUTPUT     : String
    */
    private static String quoteKeyList(list<String> lstKeySet){
        String sNewString = '' ;
        for(String str : lstKeySet){
            sNewString += '\'' + str + '\',';
        }
        sNewString = sNewString.lastIndexOf(',') > 0 ? '(' + sNewString.substring(0,sNewString.lastIndexOf(',')) + ')' : sNewString ;
        return sNewString;
    }
    /*  Name        : dtAdjustTimeZone
        Description : Adjust . 
        @OUTPUT     : Datetime
    */
    public static Datetime dtAdjustTimeZone(Datetime dateToAdjust, String sTimeZone){
        TimeZone systemTimeZone         = TimeZone.getTimeZone('GMT');      
        integer offsetToSystemTimeZone  = systemTimeZone.getOffset(dateToAdjust);
        // Here you might like to explicitly use 'GMT'
        TimeZone tz                     = TimeZone.getTimeZone(sTimeZone);//UserInfo.getTimeZone();
        // During daylight saving time for the Europe/Paris time zone
        integer offsetToBHTimeZone      = tz.getOffset(dateToAdjust);
        // Figure out correct to go from Customers DateTime to GMT and then from GMT to BH TimeZone
        integer correction              = offsetToBHTimeZone - offsetToSystemTimeZone;

        // Note: Potential issues for TimeZone differences less than a minute
        DateTime correctedDateTime      = dateToAdjust.addMinutes(correction / (1000 * 60));
        // In the users Pacific/Auckland timezone the time should be moved forward 21 hours
        return dateToAdjust; //correctedDateTime;
    }
    /*  Name        : generateWhereQuery
        Description :
        @INPUT      : void
        @OUTPUT     : String
    */
    public static String generateWhereQuery(List<WhereCriteria> lstCriterias) {
        List<String> lstConditions = new List<String>();
        String tempCriteria;
        for(WhereCriteria sCriteria : lstCriterias) {
            if (sCriteria.IsFieldValueEmpty()) {
                tempCriteria = sCriteria.getSOQLCriteria();
                if(tempCriteria != null){
                    lstConditions.add(tempCriteria);
                }
            }
        }
        return String.join(lstConditions, SOQL_WHERE_AND);
    }
    /*  Name        : SearchRecords
        Description : 
        @INPUT      : String
        @OUTPUT     : List<sObject>
    */
    private static List<sObject> SearchRecords(String sQuery){
        List<sObject> lstSearchResult   = new List<sObject>();

        if(sQuery!=''){
            try {
                lstSearchResult = database.query(sQuery);

            } catch(dmlexception e) {
                system.debug('## SearchRecords Error dml : ' + e.getMessage());
            } catch (Exception e){
                System.debug('## SearchRecords Error generla: ' + e.getMessage());
            }
        }
        return lstSearchResult;
    }
    /*  Name        : WhereCriteria
        Description : Wrapper
        Changes     : Updated to work with IN clause and AND operators
    */
    public class WhereCriteria {
   
        public String sFieldName;
        public String sOperator;
        //public String sFieldValue;
        public Set<String> sFieldValue;
        
        //public WhereCriteria(String s_fieldname, String s_value, String s_operator) {
        public WhereCriteria(String s_fieldname, Set<String> s_value, String s_operator) {
           sFieldName   = s_fieldname;
           sFieldValue  = s_value;
           sOperator    = s_operator;
        }
        public String getSOQLCriteria() {
           //return sFieldName + ' '  + sOperator + ' \'' + sFieldValue + '\'';
            String sNewString = '';
            Integer iCount = 1;
            for(String str : sFieldValue) {

                String sSeparator = (iCount<sFieldValue.size())?',':'';
                sNewString += '\'' + str + '\'' + sSeparator;                
                iCount +=1;
            }
            if(sFieldName == null || sFieldValue == null || sOperator == null){
                return null;
            }else{
               return sFieldName + ' '  + sOperator + ' (' + sNewString + ')';
            }
        }
        public Boolean IsFieldValueEmpty() {
           //return !String.isEmpty(sFieldValue);
           return !sFieldValue.isEmpty();
        }
    }

    /**
     * Kick off lead conversion for records' status relevant changes or when explicitly
     * requested by an user. This method replaces both Lead_PB002_LeadConversion and
     * Lead_PB007_LeadManualConversion process builder.
     *
     * @author              Diego Rincón
     * @date                2019-01-24
     * @param   mapOldLeadsById     map of lead records with old values
     * @param   lstNewRecords     list of records with new values
     * @return              none
     */
    public static void startConversion(Map<Id, Lead> mapOldLeadsById, List<Lead> lstNewRecords) {
        // leads to be converted
        List<Lead> lstLeads = new List<Lead>();

        for (Lead l : lstNewRecords) {
            if (
                l.TECH_ManualConversion__c != mapOldLeadsById.get(l.Id).TECH_ManualConversion__c ||
                (
                    !l.IsConverted &&
                    !l.TECH_NurturingLead__c &&
                    l.LeadSource2__c != '329' &&
                    CONVERSION_STATUS.contains(l.Status) &&
                    !CONVERSION_STATUS.contains(mapOldLeadsById.get(l.Id).Status)
                )
            ) {
                lstLeads.add(l);
            }
        }

        LeadConversionProcess.ConvertLead(lstLeads);
    }

    /**
     * Populate actual treatment date as soon as the records' status is changed.
     * This method replaces Lead_PB004_ChangeStatus process builder.
     *
     * @author              Diego Rincón
     * @date                2019-01-24
     * @param   mapOldLeadsById     map of lead records with old values
     * @param   lstNewRecords     list of records with new values
     * @param   invocatType If it is an event Lead: UPDATE_LEAD, event TASK: INSERT_TASK
     * @return              List<Lead>: It is only necessary in tasks, We need the list of Leads to be able to update it
     */
    public static List<Lead> setActualTreatmentDate (Map<Id, Lead> mapOldLeadsById, List<Lead> lstNewRecords, String invocationType) {

        // list of leads which need treatment due date recalculation
        List<Lead> lstLeads = new List<Lead>();

        //1. LOOP Leads: Add all owners{new, old} and currentUser to the list to filter the queries
        Set<Id> listOwners = new Set<Id>();
        for(Lead currentLead : lstNewRecords){
            listOwners.add(currentLead.OwnerId);
            if(invocationType == 'UPDATE_LEAD'){
                listOwners.add(mapOldLeadsById.get(currentLead.Id).OwnerId);
            }
        }
        listOwners.add(UserInfo.getUserId());

        // 2. Get Data - Queries {Group, User, ProfilesCECUsers__mdt}
        // Get the name of the CEC queues
        Map<Id, Group> mapCECQueues = new Map<Id, Group>([SELECT Id,
                                                                 Name
                                                          FROM Group
                                                          WHERE Id IN : listOwners
                                                          AND Type =: TYPE_QUEUE
                                                          AND Name LIKE 'CEC%']);

        // Query users to know if the owners are Partners or CEC Users
        Map<Id, User> mapUser = new Map<Id, User>([SELECT Id,
                                                          TECH_PartnerAccountId__c,
                                                          Profile.Name
                                                   FROM User
                                                   WHERE Id IN : listOwners]);

        // Get CEC Profiles from Custom Metadata
        Set <String> validCECProfiles = new Set<String>();

        for (ProfilesCECUsers__mdt profileCECUser : [SELECT Label
                                                     FROM ProfilesCECUsers__mdt
                                                     WHERE IsActive__c = true]) {
            validCECProfiles.add(profileCECUser.Label);
        }

        // Create Map Lead-Task {key: idLead, Value:Task}
        Map<Id, Sobject> mapLeadTask = new Map <Id, Sobject>();
        if (invocationType == 'INSERT_TASK') {
            for(Sobject task : Trigger.new) {
                mapLeadTask.put((Id)task.get('WhoId'), task);
            }
        }

        //3. LOOP Leads: Update fields {CECActualTreatmentDate__c, ActualTreatmentDate__c}
        Boolean isCurrentOwnerCEC;
        Boolean isOldOwnerCEC;
        Boolean isCurrentOwnerPartner;
        Boolean isCurrentUserCEC = false;

        List<Lead> listLeadsToUpdateFromTasks = new List<Lead>();

        for (Lead currentLead : lstNewRecords) {

            if(invocationType == 'UPDATE_LEAD') {
                Lead oldLead = mapOldLeadsById.get(currentLead.Id);
                Id oldLeadOwnerId = oldLead.OwnerId;

                //Current CEC Owner => CEC Queue OR Current Owner has profile CEC : CEC Agent, CEC Supervisor...
                isCurrentOwnerCEC = (mapCECQueues.containskey(currentLead.OwnerId)||
                                    (mapUser.containsKey(currentLead.OwnerId) && validCECProfiles.contains(mapUser.get(currentLead.OwnerId).Profile.Name)));
                //Before CEC Owner => CEC Queue OR Before Owner has profile CEC : CEC Agent, CEC Supervisor...
                isOldOwnerCEC = (invocationType == 'UPDATE_LEAD') && mapOldLeadsById.containskey(currentLead.Id) &&
                                 (mapCECQueues.containskey(oldLeadOwnerId) ||
                                (mapUser.containsKey(oldLeadOwnerId) && validCECProfiles.contains(mapUser.get(oldLeadOwnerId).Profile.Name)));
                //Current Partner Owner
                isCurrentOwnerPartner = mapUser.containskey(currentLead.OwnerId) && mapUser.get(currentLead.OwnerId).TECH_PartnerAccountId__c != null;
                //Current CEC User
                isCurrentUserCEC = mapUser.containskey(UserInfo.getUserId()) && validCECProfiles.contains(mapUser.get(UserInfo.getUserId()).Profile.Name);

                //Invocation from UPDATE LEAD (Event Before Update)
                if(invocationType == 'UPDATE_LEAD'){

                    Boolean statusHasChanged = currentLead.Status != oldLead.Status;
                    Boolean ownerHasChanged = currentLead.OwnerId != oldLeadOwnerId;

                    //Case 1: Change Status
                    // if (currentLead.Status != oldLead.Status) {
                    if (statusHasChanged) {
                        //If it is a CECOwner OR Before Owner = Queue & Current Status Converted (Case: Lead Conversion Process)
                        if (
                            isCurrentUserCEC && currentLead.CECActualTreatmentDate__c == null &&
                            (isCurrentOwnerCEC || (isOldOwnerCEC && currentLead.IsConverted))
                        ) {
                            currentLead.CECActualTreatmentDate__c = System.now();
                        //If it is an User
                        } else if (
                            !mapCECQueues.containskey(currentLead.OwnerId) &&
                            currentLead.ActualTreatmentDate__c == null
                        ) {
                            currentLead.ActualTreatmentDate__c = System.now();
                        }
                    }
                    //Case 2: Change owner to partner user
                    if (
                        // currentLead.OwnerId != oldLeadOwnerId &&
                        ownerHasChanged &&
                        isCurrentUserCEC &&
                        isOldOwnerCEC &&
                        isCurrentOwnerPartner
                    ) {
                        if (null == currentLead.CECActualTreatmentDate__c) {
                            currentLead.CECActualTreatmentDate__c = System.now();
                        }

                        String profileName = '';

                        if (mapUser.containsKey(oldLeadOwnerId)) {
                            profileName = mapUser.get(oldLeadOwnerId).Profile.Name;
                        }

                        if (!string.isBlank(profileName) && NO_DEALER_CEC_FROFILES.contains(profileName)) {
                            lstLeads.add(currentLead);
                        }
                    }
                }

                //Invocation INSERT TASK (Event After Insert)
                else if (invocationType == 'INSERT_TASK') {

                    Boolean taskSubtypeIsCall = false;

                    if (mapLeadTask.containskey(currentLead.Id)) {
                        taskSubtypeIsCall = mapLeadTask.get(currentLead.Id).get('TaskSubtype') == TASK_SUBTYPE_CALL;
                    }

                    //Case 3: Log a Call
                    if (isCurrentUserCEC && isCurrentOwnerCEC && taskSubtypeIsCall) {
                        if (currentLead.CECActualTreatmentDate__c == null){
                            currentLead.CECActualTreatmentDate__c = System.now();
                        }

                        listLeadsToUpdateFromTasks.add(currentLead);
                    }
                    else {
                        listLeadsToUpdateFromTasks.add(currentLead);
                    }
                }
            }
        }//End 3. LOOP Leads:

        // C1STAGILE-8650 - begin
        LeadTreatmentTime.setTreatmentDueDate(lstLeads);
        // C1STAGILE-8650 - end

        return listLeadsToUpdateFromTasks;
    }

    /**
     * Kick off lead allocation when geocode data is updated from the Data.com
     * service. This method replaces Lead_PB005_Allocation and
     * Lead_PB008_Web2LeadAllocation process builder.
     *
     * @author              Diego Rincón
     * @date                2019-01-24
     * @param   mapOldLeadsById     map of lead records with old values
     * @param   lstNewRecords     list of records with new values
     * @return              none
     */
    public static void fireAllocation(Map<Id, Lead> mapOldLeadsById, List<Lead> lstNewRecords) {
        List<Id> lstLeadIds = new List<Id>();

        for (Lead l : lstNewRecords) {
            if (
                l.CalculatedPOS__c == null &&
                null == mapOldLeadsById.get(l.Id).Longitude &&
                null == mapOldLeadsById.get(l.Id).Latitude &&
                l.Longitude != null &&
                l.Latitude != null
            ) {
                lstLeadIds.add(l.Id);
            }
        }

        if (lstLeadIds.isEmpty()) {
            return;
        }

        LeadDealerAllocation.handleDealerAllocation(lstLeadIds);

    }

    /**
     * Populate lead records' fields values based on their owners' dealer data.
     * This method replaces both Lead_PB009_Fill_Mobile_Country_Code and
     * Lead_PB006_Populate_TECH_IdLEAD process builder.
     *
     * @author              Diego Rincón
     * @date                2019-01-24
     * @param   lstNewRecords     list of new records
     * @return              none
     */
    public static void calcFields(List<Lead> lstNewRecords) {
        Set<Id> set_o = new Set<Id>();

        for (Lead l : lstNewRecords) {
            if (String.isNotBlank(l.OwnerId)) {
                set_o.add(l.OwnerId);
            }
        }

        Map<Id, User> map_o = new Map<Id, User>([
            SELECT
                Id,
                ContactId,
                UserRoleId,
                Country__c,
                Contact.AccountId,
                Contact.Account.Brand__c,
                Contact.Account.Country__c,
                Contact.Account.SiteGeoIdPK__c
            FROM User
            WHERE Id = :set_o
        ]);

        for (Lead l : lstNewRecords) {
            if (String.isBlank(l.OwnerId)) {
                continue;
            }

            if (Group.sObjectType == l.OwnerId.getSObjectType()) {
                continue;
            }

            l.TECH_IdLead__c = l.Id;

            if (
                User.sObjectType == l.OwnerId.getSObjectType() &&
                map_o.containsKey(l.OwnerId) &&
                null != map_o.get(l.OwnerId).ContactId
            ) {
                l.LeadCountry__c                    = map_o.get(l.OwnerId).Country__c;
                l.PSABrand__c                       = map_o.get(l.OwnerId).Contact.Account.Brand__c;
                l.DestinationGeographicalCode__c    = map_o.get(l.OwnerId).Contact.Account.SiteGeoIdPK__c;

                if (
                    !l.TECH_Web2Lead__c &&
                    null != map_o.get(l.OwnerId).UserRoleId &&
                    (
                        l.RecordTypeId == LEAD_RT_MAP.get('B2B').getRecordTypeId() ||
                        l.RecordTypeId == LEAD_RT_MAP.get('B2C').getRecordTypeId()
                    )
                ) {
                    if (null == l.et4ae5__Mobile_Country_Code__c) {
                        l.et4ae5__Mobile_Country_Code__c =
                            map_o.get(l.OwnerId).Contact.Account.Country__c;
                    }

                    l.CalculatedPOS__c  = map_o.get(l.OwnerId).Contact.AccountId;

                    continue;
                }
            }

            if (
                l.TECH_Web2Lead__c &&
                null == l.et4ae5__Mobile_Country_Code__c &&
                l.RecordTypeId == LEAD_RT_MAP.get('B2C').getRecordTypeId()
            ) {
                l.et4ae5__Mobile_Country_Code__c = l.LeadCountry__c;
            }
        }
    }

    /**
     * Insert event records and chatter posts record when a lead owner is
     * changed. This method replaces Lead_PB001 and Lead_PB002_PostChatter
     * process builder.
     *
     * @author              Diego Rincón
     * @date                2019-01-24
     * @param   mapOldLeadsById     map of lead records with old values
     * @param   lstNewRecords     list of lead records with new values
     * @return              none
     */
    public static void changedOnwnerNotifications(Map<Id, Lead> mapOldLeadsById, List<Lead> lstNewRecords) {
        // list of leads whose owner has changed
        List<Lead> lstLeads = new List<Lead>();

        // list of chatter post request to be inserted
        List<ChatterPostMessageInvocable.PostRequest> lst_r = 
            new List<ChatterPostMessageInvocable.PostRequest>();

        for (Lead l : lstNewRecords) {
            if (l.OwnerId != mapOldLeadsById.get(l.Id).OwnerId) {
                lstLeads.add(l);

                ChatterPostMessageInvocable.PostRequest r =
                    new ChatterPostMessageInvocable.PostRequest();
                    r.fromId    = Label.ChatterPostDefaultCreatedById;
                    r.toId      = l.OwnerId;
                    r.recordId  = l.Id;
                lst_r.add(r);
            }
        }

        EventUtil.createEventsFromLead(lstLeads);
        ChatterPostMessageInvocable.postMessage(lst_r);
    }
 
    /**
     * Filter leads' potential owners based on users' activity types. If no
     * match is found the original list remains unchanged.
     *
     * @author                              Diego Rincón
     * @date                                2019-02-11
     * @param       lst                     lead records to be assigned
     * @param       map_dealer_contacts     potential owners (contact id)
     *                                      grouped by dealer
     * @return      map_ret                 potential owners (user id)
     *                                      grouped by lead
     */
    public static Map<Id, Set<Id>> activityQualifyingOwners(
        List<Lead> lst,
        Map<Id, List<Id>> map_dealer_contacts
    ) {
        Map<Id, Set<Id>> map_ret = new Map <Id, Set<Id>>();
        Set<Id> set_o = new Set<Id>();

        for (Id key : map_dealer_contacts.keySet()) {
            set_o.addAll(map_dealer_contacts.get(key));
        }

        // retrieve data from potential owners
        Map<Id, User> map_u = new Map<Id, User>();
        
        for (User u : [
            SELECT Id, Activity__c, ContactId
            FROM User
            WHERE ContactId IN :set_o
        ]) {
            map_u.put(u.ContactId, u);
        }

        for (Lead l : lst) {
            if (
                map_dealer_contacts.containsKey(l.CalculatedPOS__c) &&
                !String.isBlank(l.CustomerType__c) &&
                !String.isBlank(l.Activity__c) &&
                LEAD_ACT_USER_MAP.containsKey(l.Activity__c.trim() + l.CustomerType__c.trim())
            ) {
                for (Id key : map_dealer_contacts.get(l.CalculatedPOS__c)) {
                    if (
                        String.isNotEmpty(map_u.get(key).Activity__c) &&
                        map_u.get(key).Activity__c.contains(
                            LEAD_ACT_USER_MAP.get(l.Activity__c.trim() + l.CustomerType__c.trim())
                        )
                    ) {
                        if (map_ret.containsKey(l.Id)) {
                            map_ret.get(l.Id).add(map_u.get(key).Id);
                            continue;
                        }
                        map_ret.put(l.Id, new Set<Id>{map_u.get(key).Id});
                    }
                }
            }

            // keep all potential owners if no suitable users are found for the lead
            if (!map_ret.containsKey(l.Id)) {
                Set<Id> tmp_set = new Set<Id>();
                for (Id key : map_dealer_contacts.get(l.CalculatedPOS__c)) {
                    if (map_u.containsKey(key)) {
                        tmp_set.add(map_u.get(key).Id);
                    }
                }
                map_ret.put(l.Id, tmp_set);
            }
        }

        return map_ret;
    }

    /**
     * Filter leads' potential owners based on users' sheduled events. If no
     * match is found the original list remains unchanged.
     *
     * @author                          Diego Rincón
     * @date                            2019-02-12
     * @param       lst                 lead records to be assigned
     * @param       map_lead_owner      potential owners (user id) to be
     *                                  filtered grouped by lead
     * @return      map_ret             filtered potential owners (user id)
     *                                  grouped by lead
     */
    public static Map<Id, Set<Id>> eventsQualifyingOwners(
        List<Lead> lst,
        Map<Id, Set<Id>> map_lead_owner
    ) {
        Set<Id> set_o = new Set<Id>();
        Map<Id, Set<Id>> map_ret = new Map<Id, Set<Id>>();
        Map<Id, List<Event>> map_user_event = new Map<Id, List<Event>>();

        for (Id key : map_lead_owner.keySet()) {
            map_ret.put(key, new Set<Id>(map_lead_owner.get(key)));
            set_o.addAll(map_lead_owner.get(key));
        }

        for (Event e : [
            SELECT Id, StartDateTime, Type, OwnerId
            FROM Event
            WHERE
                OwnerId IN :set_o AND
                StartDateTime >= TODAY
            ORDER BY StartDateTime ASC NULLS LAST
        ]) {
            if (map_user_event.containsKey(e.OwnerId)) {
                map_user_event.get(e.OwnerId).add(e);
                continue;
            }
            map_user_event.put(e.OwnerId, new List<Event>{e});
        }

        for (Lead l : lst) {
            String md_key = 
                (String.isBlank(l.LeadCountry__c) ? '' : l.LeadCountry__c.trim()) +
                (String.isBlank(l.PSABrand__c) ? '' : l.PSABrand__c.trim());

            if (
                map_lead_owner.containsKey(l.Id) &&
                RELEVANT_EVENT_TYPES.containsKey(md_key)
            ) {
                // validation could not be performed when
                // treatment due date is unavailable
                if (l.TreatmentDueDate__c == null) {
                    map_ret.remove(l.Id);
                    continue;
                }

                for (Id o_id : map_lead_owner.get(l.Id)) {
                    if (map_user_event.containsKey(o_id)) {
                        for (Event e : map_user_event.get(o_id)) {
                            // evaluate relevant events
                            if (
                                RELEVANT_EVENT_TYPES.get(md_key).contains(e.Type) &&
                                e.StartDateTime < l.TreatmentDueDate__c
                            ) {
                                // user is not free, remove it from list
                                map_ret.get(l.Id).remove(o_id);
                                break;
                            }
                        } 
                    }

                    // remove lead entry if no suitable owners are left
                    if (
                        map_ret.containsKey(l.Id) &&
                        map_ret.get(l.Id).isEmpty()
                    ) {
                        map_ret.remove(l.Id);
                        break;
                    }
                }
            }

            if (!map_ret.containsKey(l.Id)) {
                Set<Id> tmp_set = new Set<Id>();
                tmp_set.addAll(map_lead_owner.get(l.Id));
                map_ret.put(l.Id, tmp_set);
            }
        }

        return map_ret;
    }

    /**
     * Choose a lead owner from a pool of users, prioritizing the users which
     * have less records assigned.
     *
     * @author                          Diego Rincón
     * @date                            2019-02-13
     * @param       lst                 lead records to be assigned
     * @param       map_lead_owner      potential owners' ids grouped by lead
     * @return                          none
     */
    public static void flatAssignment(
        List<Lead> lst,
        Map<Id, Set<Id>> map_lead_owner
    ) {
        Set<Id> set_u = new Set<Id>();
        for (Id l_id : map_lead_owner.keySet()) {
            set_u.addAll(map_lead_owner.get(l_id));
        }

        Map<Id, LoadPerUserWrapper> map_u = new Map<Id, LoadPerUserWrapper>();

        for (User u : [
            SELECT Id, Contact.TECH_CounterSalesman__c
            FROM User
            WHERE Id IN :set_u
        ]) {
            map_u.put(
                u.Id,
                new LoadPerUserWrapper(u)
            );
        }

        for (Lead l : lst) {
            if (map_lead_owner.containsKey(l.Id)) {
                List<Id> lst_tmp = new List<Id>();
                lst_tmp.addAll(map_lead_owner.get(l.Id));

                if (lst_tmp.isEmpty()) {
                    continue;
                }

                if (lst_tmp.size() == 1) {
                    l.OwnerId = lst_tmp.get(0);
                    map_u.get(lst_tmp.get(0)).lead_count++;
                    continue;
                }

                // flat allocation is run only when several ownership candidates are found
                List<LoadPerUserWrapper> lst_usr_lead = new List<LoadPerUserWrapper>();
                for (Id u_id : lst_tmp) {
                    lst_usr_lead.add(map_u.get(u_id));
                }

                lst_usr_lead.sort();
                Integer randomNumber = Integer.valueof((Math.random() * (lst.size()-1)));
                System.Debug('Usuario Random!'+lst_usr_lead.get(randomNumber).user_id + ' Número Random:'+lst.size());
                l.OwnerId = lst_usr_lead.get(randomNumber).user_id;
                lst_usr_lead.get(randomNumber).lead_count++;
            }
        }
    }

    /**
     * Fire lead allocation for web-to-lead records as the initial allocation
     * is overwritten with the configured default lead owner. This method
     * replaces Lead_PB008_Web2LeadAllocation process builder.
     *
     * @author                  Diego Rincón
     * @date                    2019-03-21
     * @param       lstNewRecords     list of records with new values
     * @return                  none
     */
    public static void allocateWebToLeadRecords(List<Lead> lstNewRecords) {
        List<Id> lst_id = new List<Id>();

        for (Lead l : lstNewRecords) {
            if (l.TECH_Web2Lead__c) {
                lst_id.add(l.Id);
            } 
        }

        if (lst_id.isEmpty()) {
            return;
        }

        asyncHandleDealerAllocation(lst_id);
    }

    @future
    public static void asyncHandleDealerAllocation(List<Id> lst) {
        LeadDealerAllocation.handleDealerAllocation(lst);
    }

    /**
     * Populate treatment due date as soon as the records' status is changed.
     *
     * @author
     * @date
     * @param   lstLeads    list of records which needs treatment due to recalculation.
     * @return              void
     */
    public static void setTreatmentDueDate(List<Lead> lstLeads) {
        Map<String, String> mapAct = new Map<String, String>();

        for (UtilSetting__mdt a : [
            SELECT MasterLabel, QualifiedApiName, Value__c, Value2__c
            FROM UtilSetting__mdt
            WHERE QualifiedApiName LIKE 'LeadSLAConfigurationT%'
        ]) {
            mapAct.put(a.Value__c, a.Value2__c);
        }

        Set<Id> set_owner = new Set<Id>();

        for (Lead currentLead : lstLeads) {
            set_owner.add(currentLead.OwnerId);
        }

        Map<Id, User> mapUsersById = new Map<Id, User>([
            SELECT Id, Contact.AccountId
                FROM User
                WHERE
                    Id IN :set_owner AND
                    Contact.AccountId != null
        ]);

        Map<Id, String> mapSlaKeysById = new Map<Id, String>();
        Map<Id, String> mapBhrKeysById = new Map<Id, String>();

        for (Lead currentLead : lstLeads) {
            if (mapUsersById.containsKey(currentLead.OwnerId)) {
                mapSlaKeysById.put(
                    currentLead.Id,
                    currentLead.LeadCountry__c +
                    currentLead.PSABrand__c +
                    mapAct.get(currentLead.Activity__c) +
                    currentLead.LeadType__c +
                    mapUsersById.get(currentLead.OwnerId).Contact.AccountId
                );
                mapBhrKeysById.put(
                    currentLead.Id,
                    'LEAD' +
                    currentLead.LeadCountry__c +
                    currentLead.PSABrand__c +
                    mapAct.get(currentLead.Activity__c) +
                    currentLead.LeadType__c +
                    mapUsersById.get(currentLead.OwnerId).Contact.AccountId
                );
            }
        }

        Map<String, LeadSLAConfiguration__mdt> mapSlasByDeveloperName =
            new Map<String, LeadSLAConfiguration__mdt>();

        for (LeadSLAConfiguration__mdt sla : [
            SELECT Id, DeveloperName, SLAFirstAction__c
            FROM LeadSLAConfiguration__mdt
            WHERE DeveloperName IN :mapSlaKeysById.values()
        ]) {
            mapSlasByDeveloperName.put(sla.DeveloperName, sla);
        }

        Map<String, BusinessHours> mapBusinessHoursByName = new Map<String, BusinessHours>();

        for (BusinessHours bh : [
            SELECT Id, Name
            FROM BusinessHours
            WHERE Name IN :mapBhrKeysById.values()
        ]) {
            mapBusinessHoursByName.put(bh.Name, bh);
        }

        for (Lead currentLead : lstLeads) {

            Boolean slaKeyExist = mapSlaKeysById.containsKey(currentLead.Id);
            Boolean bhrKeyExist = mapBhrKeysById.containsKey(currentLead.Id);

            String slaKey = slaKeyExist ? mapSlaKeysById.get(currentLead.Id) : '';
            String bhrKey = bhrKeyExist ? mapBhrKeysById.get(currentLead.Id) : '';

            if ( !String.isBlank(slaKey) && !string.isBlank(bhrKey)) {
                if ( mapBusinessHoursByName.containsKey(bhrKey) && mapSlasByDeveloperName.containsKey(slaKey) ) {
                    currentLead.TreatmentDueDate__c = BusinessHours.add(
                        mapBusinessHoursByName.get(bhrKey).Id,
                        System.now(),
                        (6 * (10.0.pow(4)) * mapSlasByDeveloperName.get(slaKey).SLAFirstAction__c).intValue()
                    );
                }
            }
        }

    }

    /**
     * Retrieve log calling automation settings for a lead record.
     * Lead_PB008_Web2LeadAllocation process builder.
     *
     * @author              Diego Rincón
     * @date                2019-05-27
     * @param       l       lead record
     * @return              matching metadata record, default if no match is found
     */

    public static LeadCallSetting__mdt getSubsidiaryConfig(Lead l) {
        String str_b = String.isNotBlank(l.PSABrand__c) ? l.PSABrand__c.trim() : null;
        String str_c = String.isNotBlank(l.LeadCountry__c) ? l.LeadCountry__c.trim() : null;
        String str_a = String.isNotBlank(l.Activity__c) ? l.Activity__c.trim() : null;

        if (
            null != str_b && null != str_c && null != str_a &&
            CALL_MD.containsKey(str_c + str_b + str_a)
        ) {
            return CALL_MD.get(str_c + str_b + str_a);
        }

        if (
            null != str_b && null != str_c &&
            CALL_MD.containsKey(str_c + str_b)
        ) {
            return CALL_MD.get(str_c + str_b);
        }

        if (null != str_b && CALL_MD.containsKey(str_b)) {
            return CALL_MD.get(str_b);
        }

        if (null != str_c && CALL_MD.containsKey(str_c)) {
            return CALL_MD.get(str_c);
        }

        if (CALL_MD.containsKey('ALL')) {
            return CALL_MD.get('ALL');
        }

        return null;
    }

    /**
     * Call attempts rollup field logic. C1STAGILE-305.
     *
     * @author                  Diego Rincón
     * @date                    2019-05-27
     * @param       map_l       map of Lead records being updated
     * @return                  none
     */
    public static void setCallCount(Map<Id, Lead> map_l) {
        Map<Id, AggregateResult> map_ar = new Map<Id, AggregateResult>([
            SELECT WhoId Id, COUNT(Id)
            FROM Task
            WHERE
                WhoId IN :map_l.keySet() AND
                TaskSubtype = 'Call' AND
                CallStatus__c = '1'
            GROUP BY WhoId
        ]);

        for (Id key : map_l.keySet()) {
            if (map_ar.containsKey(key)) {
                map_l.get(key).LeadAttemptCalls__c = (Decimal) map_ar.get(key).get('expr0');
                continue;
            }
            map_l.get(key).LeadAttemptCalls__c = 0;
        }
    }

}
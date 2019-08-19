/*-----------------------------------------------------------------------------------------------------------//
  * Class Name    : CaseTriggerHandler
  * Project       : PSA - C1ST - Care
  * Author        : Borja Gay Flores    <gayflores.borja@ext.mpsa.com>
  * Date          : 10/18/2018
  * Description   : To manage case trigger methods.
  *
  *-----------------------------------------------------------------------------------------------------------
  *      Modification Log :
  *-----------------------------------------------------------------------------------------------------------
  *      Developer                Date                     Description    
  *      Borja Gay Flores         10/18/2018               Creation.      
  *      Carmen Hernandez         03/20/2019               Refactor: Add methods & comments
  *                                                        	- shouldRunTrigger/dontRunTrigger/setContactIdCaseB2C
  *                                                         - beforeInsert/afterInsert/beforeUpdate/afterUpdate                                                              
  *      Manuel Medina            03/28/2019               Add methods - setAccountAddresses
  *      Carmen Hernandez         05/23/2019			   Refactor method matchCaseAsset
  *      Marcos Garcia            06/05/2019               Fill MobilePersonalTelephone__pc when Case origin WebForm
  * 	 Carmen Hernandez		  06/10/2019			   Refactor: Add comments & method:
  * 														- createConsentFromCase
  *      Carmen Hernandez         06/16/2019               Refactor: Add methods :
  *                                                         - createPersonAccountFromCase/createAccountB2BFromCase
  *                                                         - createContactB2BFromCase            
  *                                                        Delete method: setAccountAddresses (unified)
  *      Martin De Leon           07/01/2019               Refactored method matchCaseAccountFromChat
  *      Carmen Hernandez         07/04/2019               Delete methods: matchCaseAccountFromWebform/matchCaseAsset 
  *                                                        Add method: populateFieldsFromAsset(replaces 'Fill_VIN' WorkFlow)
  *                                                        Change the (create...()) methods to the CareUtils class
  *      Carmen Hernandez         07/15/2019               Add method setDealer, runAssignmentRulesForDealers, runTrigger
  *-----------------------------------------------------------------------------------------------------------*/
public without sharing class CaseTriggerHandler {

    //Instance careMethods
    private static final CareStaticVariables instanceCare = CareStaticVariables.getInstance();   
    
    //Attributes
    private static Boolean runtrigger = true;
    
    /*********************************************************************************************************
    * @Method          :   shouldRunTrigger
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   03/20/2019
    * @Description     :   This method is used to get the flag that indicate if the trigger should run or not
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/
    public static boolean shouldRunTrigger() {
        return runtrigger;
    }

    /*********************************************************************************************************
    * @Method          :   dontRunTrigger
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   03/20/2019
    * @Description     :   This method is used to indicate that the trigger should not run
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/
    public static void dontRunTrigger() {
        runtrigger = false;
    }
    

    /*********************************************************************************************************
    * @Method          :   runTrigger
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/12/2019
    * @Description     :   This method is used to indicate that the trigger should run
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/
    public static void runTrigger() {
        runtrigger = true;
    }

    /*********************************************************************************************************
    * @Method          :   beforeInsert
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   03/20/2019
    * @Description     :   This method is used to call the actions that handle the before insert trigger.
    * @params	       :   List<Case> : Trigger.new
    * @Returns         :   void
    **********************************************************************************************************/
    public static void beforeInsert(List<Case> listCases){
        if(PAD.canTrigger('Case_Matching')){
            matchCaseAccountFromChat(listCases);
        }
		if(PAD.canTrigger('Case_SetBH')){
            setBussinesHours(listCases);
        }
        if(PAD.canTrigger('Case_SetContactId')){
            setContactIdCaseB2C(listCases);
        }
        if(PAD.canTrigger('Case_SetInitStatus')){
            initializeStatus(listCases);
        }
        if(PAD.uCurrentUserName.AccountId!= null){
            setDealer(listCases);
        }
        checkTeleAlert(listCases);
        populateFieldsFromAsset(listCases, null);        
    }

    /*********************************************************************************************************
    * @Method          :   afterInsert
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   03/20/2019
    * @Description     :   This method is used to call the actions that handle the after insert trigger.
    * @params	       :   List <Case> : Trigger.new
    * @Returns         :   void
    **********************************************************************************************************/
    public static void afterInsert(List<Case> listCases){  
        if(PAD.canTrigger('Case_SetAccountOngoing')){
            changeOngoingInsert(listCases);
        }
        if(PAD.uCurrentUserName.AccountId!= null){
            runAssignmentRulesForDealers(listCases);
        }
    } 

    /*********************************************************************************************************
    * @Method          :   beforeUpdate
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   03/20/2019
    * @Description     :   This method is used to call the actions that handle the before update trigger.
    * @params	       :   List<Case> : Trigger.new 
    * @params          :   Map<Id,Case> : Trigger.oldMap
    * @Returns         :   void
    **********************************************************************************************************/
    public static void beforeUpdate(List<Case> listCases, Map<Id,Case> mapOldCases){
        if(PAD.canTrigger('Case_SetContactId')){
            setContactIdCaseB2C(listCases);
        }
        populateFieldsFromAsset(listCases, mapOldCases);
    } 

    /*********************************************************************************************************
    * @Method          :   afterUpdate
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   03/20/2019
    * @Description     :   This method is used to call the actions that handle the after update trigger.
    * @params	       :   List<Case> : Trigger.new
    * @params          :   Map<Id,Case> : Trigger.oldMap
    * @Returns         :   void
    **********************************************************************************************************/
    public static void afterUpdate(List<Case> listCases, Map<Id,Case> mapOldCases){
        if(PAD.canTrigger('Case_SetAccountOngoing')){
            changeOngoingUpdate(listCases, mapOldCases);
        }
    }
    

    /*********************************************************************************************************
    * @Method          :   setBussinesHours
    * @Author          :   Borja Gay Flores <gayflores.borja@ext.mpsa.com>
    *                  :   Refactorized by Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   XX/XX/XX
    * @Description     :   This method replaces the 'Case_PB001_PopulateBusinessHours' process builder, this 
    *                  :   sets the busines hours (depends on Brand__c, Country__c, CategoryL1__c)
    * @params	       :   List<Case> : case records before insert
    * @Returns         :   void
    * TO DO: IMPORTANT :   The names of the Business Hours must be changed (If the 'Brand__c' & 'Country__c' 
    *                      fields are translated, this method won't work)
    **********************************************************************************************************/
    private static void setBussinesHours(List<Case> lstCase){
        //Get values & labels from the picklist Case.Brand__c, Case.Country__c
		instanceCare.getPicklistValues(CareConstants.BRAND_FIELD, CareConstants.KEY_PICKLIST_BRAND, false);
        Map<String, String> mapPicklistValues = instanceCare.getPicklistValues(CareConstants.COUNTRY_FIELD, 
                                                                               CareConstants.KEY_PICKLIST_COUNTRY, false);
        //Create map with the business hours
        Map<String,String> mapBH = instanceCare.getBusinessHoursByName(CareConstants.BH_CEC+'%', false);
        
        for(Case caseIt : lstCase){
            if(String.isNotBlank(caseIt.Country__c) && String.isNotBlank(caseIt.Brand__c)){
                String keyBH = CareConstants.BH_CEC+((mapPicklistValues.get(CareConstants.KEY_PICKLIST_COUNTRY+caseIt.Country__c)) + '-' +
                                       				(mapPicklistValues.get(CareConstants.KEY_PICKLIST_BRAND+caseIt.Brand__c))).toUpperCase();
                if(caseIt.CategoryL1__c == CareConstants.CASE_CATEGORYL1_SAVING_PLAN_FI){
                    keyBH += CareConstants.BH_SAVING_PLAN_AR;
                }                       
                caseIt.BusinessHoursId = mapBH.get(keyBH);
            }
        }
    }

    /*********************************************************************************************************
    * @Method          :   changeOngoingInsert
    * @Author          :   Borja Gay Flores <gayflores.borja@ext.mpsa.com>
    * @Created         :   XX/XX/XX
    * @Description     :   This method sets the OngoingClaim__c field of the associated account when a case with 
    *                  :   Status != 'Closed' is created.
    * @params	       :   List<Case> : case records before insert
    * @Returns         :   void
    **********************************************************************************************************/
    private static void changeOngoingInsert(List<Case> lstCase){

        Map<Id,Account> mapAccToUpdate = new Map<Id,Account>();

        for(Case caseIt : lstCase){
            if(caseIt.AccountId != null && !mapAccToUpdate.containsKey(caseIt.AccountId)  &&
               caseIt.Reason == CareConstants.CASE_REASON_COMPLAINT  && caseIt.Status != CareConstants.CASE_STATUS_CLOSED ){
                mapAccToUpdate.put(caseIt.AccountId, (new Account(Id = caseIt.AccountId, OngoingClaim__c = true)));
            }
        }

        if(!mapAccToUpdate.isEmpty()){
            update (mapAccToUpdate.values());
        }
    }    

    /*********************************************************************************************************
    * @Method          :   changeOngoingUpdate
    * @Author          :   Borja Gay Flores <gayflores.borja@ext.mpsa.com>
    * @Created         :   XX/XX/XX
    * @Description     :   This method sets the OngoingClaim__c field of the associated account when a case 
    *                  :   is updated.
    * @params	       :   List<Case> : case records before insert
    * @params          :   Map<Id, Case> : case old Map 
    * @Returns         :   void
    **********************************************************************************************************/
    private static void changeOngoingUpdate(List<Case> lstNewCase, Map<Id, Case> mapOldCase){

        Map<string,Account> mapAccClosed = new Map<string,Account>();
        Map<string,Account> mapAccOpen = new Map<string,Account>();
        List<Account> lstAccToUpdate = new List<Account>();
        //Classify in: Open/Close Accounts
        for(Case caseIt : lstNewCase){
            if(caseIt.AccountId != null && caseIt.Reason == CareConstants.CASE_REASON_COMPLAINT && caseIt.Status != mapOldCase.get(caseIt.id).Status){
                if(caseIt.Status == CareConstants.CASE_STATUS_CLOSED){
                    mapAccClosed.put(caseIt.AccountId, new Account(Id = caseIt.AccountId, OngoingClaim__c = false));
                }
                else{
                    mapAccOpen.put(caseIt.AccountId, new Account(Id = caseIt.AccountId, OngoingClaim__c = true));
                }
            }
        }
        
        if(!mapAccOpen.isEmpty() && !mapAccClosed.isEmpty()){
            for(Case caseIt : [SELECT Id,AccountId FROM Case WHERE AccountId IN :mapAccClosed.keySet() AND 
                            Status !=: CareConstants.CASE_STATUS_CLOSED]){
                mapAccOpen.put(caseIt.AccountId, new Account(Id = caseIt.AccountId, OnGoingClaim__c = true));
            }
            for(Account acc :mapAccOpen.values()){
                if(mapAccClosed.containsKey(acc.id)){
                    mapAccClosed.remove(acc.id);
                }
            }
            lstAccToUpdate.addAll(mapAccOpen.values());
            lstAccToUpdate.addAll(mapAccClosed.values());
        }
        else{
            if(!mapAccOpen.isEmpty()){
                lstAccToUpdate.addAll(mapAccOpen.values());
            }
            if(!mapAccClosed.isEmpty()){
                List<Case> lstAccCaseOpen = new list<Case>();
                lstAccCaseOpen = [SELECT Id,AccountId FROM Case WHERE AccountId IN :mapAccClosed.keySet() AND 
                                  Status !=: CareConstants.CASE_STATUS_CLOSED];
                if(!lstAccCaseOpen.isEmpty()){
                    for(Case open : lstAccCaseOpen){
                        if(mapAccClosed.containsKey(open.id)){
                            mapAccClosed.get(open.id).OngoingClaim__c = true;
                        }
                    }
                }
                lstAccToUpdate.addAll(mapAccClosed.values());
            }
        }
        if(!lstAccToUpdate.isEmpty()){
            update lstAccToUpdate;
        }
    }

    /*********************************************************************************************************
    * @Method          :   matchCaseAccountFromChat
    * @Author          :   Pedro Parraga <parragabornez.pedrojesus@ext.mpsa.com>
    *                  :   Refactorized by Martin de Leon & Carmen <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   XX/XX/XX
    * @Description     :   This method links the case with an anonymous account (depending on the Country__c)
    *                  :   (Executed when Case.Origin = Chat)
    * @params	       :   lstCase: case records before insert
    * @Returns         :   void
    **********************************************************************************************************/
 	public static void matchCaseAccountFromChat(List<Case> lstCases) {

        Set<String> accountKeys = new Set<String>();
        Map<String, Id> accountIdByCountryName = new Map<String, Id>();

        for(Case caseIt : lstCases) {
            if(caseIt.Origin == CareConstants.CASE_ORIGIN_CHAT && caseIt.Country__c != null){
                accountKeys.add(CareConstants.ANONYMOUS+caseIt.Country__c);
            }
        }
        if(!accountKeys.isEmpty()){
            //Query Anonymous Accounts
            accountIdByCountryName = instanceCare.getAnonymousAccsByCountry(accountKeys, false);
            
            //Populate AccountId & Subject
            for(Case caseIt : lstCases) {
                if(caseIt.Origin == CareConstants.CASE_ORIGIN_CHAT && caseIt.AccountId == null) {
                    if(accountIdByCountryName.containskey(caseIt.Country__c)) {
                        caseIt.AccountId  = accountIdByCountryName.get(caseIt.Country__c);
                    }
                    caseIt.Subject = Label.Chat_conversation;
                }
            }
        }
    }
    
    /*********************************************************************************************************
    * @Method          :   setContactIdCaseB2C
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   03/20/2019
    * @Description     :   This method is used to update the ContactId field with the contact of a person account
    * @params	       :   List<Case> : case records before update/insert
    * @Returns         :   void
    **********************************************************************************************************/
    public static void setContactIdCaseB2C(List<Case> listCases){
       
        //Store all idAccounts in order to filter the query
        Set<Id> setAccountsIds = new Set<Id>();
        for(Case caseIt : listCases){
            setAccountsIds.add(caseIt.AccountId);
        }

        if(setAccountsIds != null && setAccountsIds.size()>0){
            //Get Contacts from Person Accounts
            Map<Id, Account> mapPersonAccounts = new Map<Id, Account>([SELECT Id, PersonContactId FROM Account
                WHERE Id IN: setAccountsIds AND RecordTypeId =: PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA)]);
            //Update ContactId field
            for(Case caseIt : listCases){
                if(mapPersonAccounts.containskey(caseIt.AccountId)){
                    if(caseIt.ContactId != mapPersonAccounts.get(caseIt.AccountId).PersonContactId){
                        caseIt.ContactId = mapPersonAccounts.get(caseIt.AccountId).PersonContactId;
                    }
                }
            }
        }
    }

    /*********************************************************************************************************
    * @Method          :   initializeStatus
    * @Author          :   Pedro Parraga <parragabornez.pedrojesus@ext.mpsa.com>
    * @Created         :   04/22/2019
    * @Description     :   Puts the status of the case to taken into account when it is created by an agent
    *                      Exceptions: cases created from webform & Partner Community
    * @params	       :   List<Case> lstNewCases : case records before insert
    * @Returns         :   void
    **********************************************************************************************************/
    public static void initializeStatus(List<Case> lstNewCases){
        
        for(Case cas : lstNewCases){
            if(cas.Origin != CareConstants.CASE_ORIGIN_WEBFORM && PAD.uCurrentUserName.AccountId == null){
                cas.Status = CareConstants.CASE_STATUS_TAKEN_INTO_ACCOUNT;
            }
        }
    }

    /*********************************************************************************************************
    * @Method          :   checkTeleAlert
    * @Author          :   Diego Rincón
    * @Created         :   2019-04-24
    * @Description     :   Check if a case record being inserted is the first for the related telealert. 
    *                  :   Result is stored in TECH_IsTeleAlertFirstCase__c field.
    * @params	       :   List<Case> lst :  list of case records inserted
    * @Returns         :   void
    **********************************************************************************************************/      
    public static void checkTeleAlert(List<Case> lst) {
        
        Set<Id> set_ta = new Set<Id>();

        for (Case c : lst) {
            if (null != c.TeleAlertId__c) {
                set_ta.add(c.TeleAlertId__c);
            }
        }

        Map<Id, AggregateResult> map_count = new Map<Id, AggregateResult>([
            SELECT COUNT(Id) rec_count, TeleAlertId__c Id
            FROM Case
            WHERE TeleAlertId__c IN :set_ta
            GROUP BY TeleAlertId__c
        ]);

        for (Case c : lst) {
            if (null != c.TeleAlertId__c) {
                c.TECH_IsTeleAlertFirstCase__c = 
                    map_count.containsKey(c.TeleAlertId__c) ? false : true;
            }
        }

    }
    
    /*********************************************************************************************************
    * @Method          :   populateFieldsFromAsset
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/05/2019
    * @Description     :   This method replaces the 'Fill_VIN' workflow Rule, this updates the VIN and 
    *                  :   Registration Number fields from the Asset
    * @params	       :   List<Case> lstCase: case records before insert/update
    * @Returns         :   void
    **********************************************************************************************************/    
    private static void populateFieldsFromAsset(List<Case> lstCase, Map<Id,Case> mapOldCases){
        
        //Evaluate the rule when a case is created, and every time the AssetId fiel is edited
        Set<Id> setAssetIds = new Set<Id>();
        for(Case caseIt : lstCase){
            if((mapOldCases == null && caseIt.AssetId != null) || 
               (mapOldCases != null && (caseIt.AssetId != mapOldCases.get(caseIt.Id).AssetId))){
                setAssetIds.add(caseIt.AssetId);
            }
        }     
        
        if(!setAssetIds.isEmpty()){
            //Get values VIN__c, LastKnownRegistrationNumber__c from Asset
            Map<Id,Asset> mapAssets = new Map<Id,Asset>([SELECT Id, VIN__c, LastKnownRegistrationNumber__c 
                                                         FROM Asset WHERE Id IN: setAssetIds]);
            //Populate the VIN__c & RegistrationNumber__c fields from the assets
            for(Case caseIt : lstCase){
                if(mapAssets.containskey(caseIt.AssetId) && ((mapOldCases == null) || 
                                                             (caseIt.AssetId != mapOldCases.get(caseIt.Id).AssetId))){
                    caseIt.VIN__c = mapAssets.get(caseIt.AssetId).VIN__c;
                    caseIt.RegistrationNumber__c = mapAssets.get(caseIt.AssetId).LastKnownRegistrationNumber__c;                       
                }
            } 
        }
    }

    /*********************************************************************************************************
    * @Method          :   setDealer
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/12/2019
    * @Description     :   This method updates the Dealer__c field for cases created from the Partner community
    * @params	       :   List<Case> lstCase: case records before insert
    * @Returns         :   void
    **********************************************************************************************************/    
    private static void setDealer(List<Case> lstCase){
        for(Case caseIt: lstCase){
            caseIt.Dealer__c = PAD.uCurrentUserName.AccountId;
        } 
    }

    /*********************************************************************************************************
    * @Method          :   runAssignmentRulesForDealers
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/12/2019
    * @Description     :   This method executes the assignment rules for cases created from the Partner community
    * @params	       :   List<Case> lstCase: case records after insert
    * @Returns         :   void
    **********************************************************************************************************/    
    private static void runAssignmentRulesForDealers(List<Case> lstCase){
                
		//Get Case_FO_Assignation Assignment Rule 
        Map<String, AssignmentRule> mapCaseAssignmentRules = instanceCare.getCaseAssignmentRules(CareConstants.CASE_ASSIGNMENT_RULE_FO, false);

        //Specifies the ID of the assignment rule to run for the case.                              
        if(mapCaseAssignmentRules.containskey(CareConstants.CASE_ASSIGNMENT_RULE_FO)){ 
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId = mapCaseAssignmentRules.get(CareConstants.CASE_ASSIGNMENT_RULE_FO).Id;        
            List<Case> casesToUpdateList = [Select Id FROM Case WHERE ID IN: lstCase];
            for(case caseIt: casesToUpdateList ){
                caseIt.setOptions(dmlOpts );
            }
            //Avoid executing the trigger in this update
            dontRunTrigger();
            update casesToUpdateList; 
            runTrigger();
        }
    }

}
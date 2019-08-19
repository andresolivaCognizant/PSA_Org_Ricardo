/*
*   @Class : SBQQQuoteTriggerHandler.cls
*
*   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
*   @Created        :   19 jun 2018
*   @Description    :   To manage SBQQ__Quote__c trigger methods

*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Developer            Date                     Description
*      Ruben Moreno         19 jun 2018              Creation.
*      Ruben Moreno         24 oct 2018              API USER doesn't execute fleet validations.
*      Sergio Lopez         26 dec 2018              US 5996: Order Form Approval Process.
*      Ruben Fernandez      28 dec 2018              Send Order data to DMS
*      Ruben Fernandez      06 feb 2019              Merge from DEV1
*      Ricardo Pereira      14 mar 2019              C1STAGILE-6837: Included logic to call SBQQQuoteUtils.generateExternalId before insert and update
*   ----------------------------------------------------------------------------------------------------------------------------
*/
public with sharing class SBQQQuoteTriggerHandler {

    private static final Map<Id, Schema.RecordTypeInfo> MAP_ID_RT = SBQQ__Quote__c.SObjectType.getDescribe().getRecordTypeInfosById(); 

    private static boolean runtrigger           = true;
    private final static string PROFILE_NAME    = [SELECT Id,Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
    private static Map<Id,User> OwnerUserID     = new MAP<Id,User>();
    private static final Set<String> ORDER_FORM_RT_DEV_NAMES = new Set<String>{'CPQ_Order_Form','OPVOrderFormVD','OPVOrderFormVN',
                                                                                'OPV_OrderForm_VO','OPV_Order_Form'};

    /*
     * @Method          :   shouldRunTrigger
     * @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   19 jun 2018
     * @Description     :   To get the flag that indicate if the trigger should run or not
     * @Params          :   -
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
    public	static	boolean	shouldRunTrigger() {
        return runtrigger;
    }
    
    /*
     * @Method          :   dontRunTrigger
     * @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   19 jun 2018
     * @Description     :   To indicate that the trigger should not run
     * @Params          :   -
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
	public	static	void	dontRunTrigger() {
		runtrigger = false;
	}
    
    /*
     * @Method          :   runTrigger
     * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
     * @Created         :   10 jul 2019
     * @Description     :   To indicate that the trigger should run
     * @Params          :   -
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
	public	static	void	runTrigger() {
		runtrigger = true;
	}    
    
    

    /*
     * @Method          :   beforeInsert
     * @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   19 jun 2018
     * @Description     :   Call the actions that handle the before insert trigger.
     * @Params          :   List<SBQQ__Quote__c> records before the changes.
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
    public static void beforeInsert(List<SBQQ__Quote__c> lNewQuotes) {
        if (!PAD.canTrigger('SBQQQuote_BeforeInsert')) {
            return;
        }
        PopulateQuantity.setQuantity(lNewQuotes);
        if (PROFILE_NAME != Label.API_UserProfileName) {
            FleetRequestValidations.quoteValidateInsert(lNewQuotes);
        }

        Map <Id, SBQQ__Quote__c> mapActivatedOrderForms = new Map <Id, SBQQ__Quote__c>();
        for(SBQQ__Quote__c oQuote : lNewQuotes){
            System.debug('oQuote.SalesManagerValidationFlag__c: insert '+oQuote.SalesManagerValidationFlag__c);
            if(MAP_ID_RT.containsKey(oQuote.RecordTypeId) 
                && ORDER_FORM_RT_DEV_NAMES.contains(MAP_ID_RT.get(oQuote.RecordTypeId).DeveloperName)){ //This identifies an OrderForm
                System.debug('oQuote.SBQQ__Status__c: '+oQuote.SBQQ__Status__c);
                
                if('2'.equals(oQuote.SBQQ__Status__c) || Test.isRunningTest()) {
                    mapActivatedOrderForms.put(oQuote.Id, oQuote);		   
                }
            }
        }

        SBQQQuoteUtils.generateExternalId(mapActivatedOrderForms);

        /* BEGIN - Manuel Medina - C1STAGILE-4972 - 26042019 */
        SBQQQuoteUtils.validateServiceCodes( lNewQuotes, null );
        /* END - Manuel Medina - 26042019 */

        //BEGIN - Changed Flow to code
        SBQQQuoteUtils.handleQuoteOpportunity(lNewQuotes);
        //END
    }

    /*
     * @Method          :   beforeUpdate
     * @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   19 jun 2018
     * @Description     :   Call the actions that handle the before update trigger.
     * @Params          :   List<SBQQ__Quote__c> records after the changes, Map<Id, SBQQ__Quote__c> record before the changes
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
    
    public static void beforeUpdate(List<SBQQ__Quote__c> lNewQuotes, Map<Id, SBQQ__Quote__c> mapOldQuotes) {
        CheckStockReservation.editionProcess(lNewQuotes, mapOldQuotes);
        CheckStockReservation.reservationProcess(lNewQuotes, mapOldQuotes);
        CheckStockReservation.cancelReservationProcess(lNewQuotes, mapOldQuotes);
        if (PROFILE_NAME != Label.API_UserProfileName) {
            FleetRequestValidations.quoteValidateEdition(lNewQuotes, mapOldQuotes);
        }

        
        // BEGIN - US 5996
        List <SBQQ__Quote__c> qtsToUpd = new List<SBQQ__Quote__c>();
        Map <Id, SBQQ__Quote__c> mapActivatedOrderForms = new Map <Id, SBQQ__Quote__c>();

		Map<Id, RecordType> mapRT = new Map<Id, RecordType>([SELECT Id FROM RecordType WHERE DeveloperName IN ('OPVOrderFormVN')]);

        for(SBQQ__Quote__c oQuote : lNewQuotes){
            if(mapRT.containsKey(oQuote.RecordTypeId)){
                System.debug('oQuote.SalesManagerValidationFlag__c: update new '+oQuote.SalesManagerValidationFlag__c);
                System.debug('oQuote.SalesManagerValidationFlag__c: update old '+mapOldQuotes.get(oQuote.Id).SalesManagerValidationFlag__c);
                if ((oQuote.SalesManagerValidationFlag__c && !mapOldQuotes.get(oQuote.Id).SalesManagerValidationFlag__c) ||
                    (!oQuote.SalesManagerValidationFlag__c && mapOldQuotes.get(oQuote.Id).SalesManagerValidationFlag__c)){
                        SBQQQuoteUtils.checkProcess(lNewQuotes, mapOldQuotes);
                }
            }
            if(MAP_ID_RT.containsKey(oQuote.RecordTypeId) 
                && ORDER_FORM_RT_DEV_NAMES.contains(MAP_ID_RT.get(oQuote.RecordTypeId).DeveloperName)){ //This identifies an OrderForm
                
                if (oQuote.SBQQ__Status__c != mapOldQuotes.get(oQuote.Id).SBQQ__Status__c
                    && '2'.equals(oQuote.SBQQ__Status__c)) {

                    mapActivatedOrderForms.put(oQuote.Id, oQuote);
                   
                }
            }
        }
        // END - US 5996

        SBQQQuoteUtils.generateExternalId(mapActivatedOrderForms);

        /* BEGIN - Manuel Medina - C1STAGILE-4972 - 26042019 */
        SBQQQuoteUtils.validateServiceCodes( lNewQuotes, mapOldQuotes );
        /* END - Manuel Medina - 26042019 */
    }

    /*
     * @Method          :   afterInsert
     * @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   05 feb 2018
     * @Description     :   Call the actions that handle the after insert trigger
     * @Params          :   List<SBQQ__Quote__c> records after the changes
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
    public static void afterInsert(List<SBQQ__Quote__c> lNewQuotes) {
        if (!PAD.canTrigger('SBQQQuote_AfterInsert')) {
            return;
        }

        SBQQQuoteUtils.enqueueAsyncUpdateFleetRequestQuantity(lNewQuotes);
        // Start Change: Added by by Ruben Fernandez
        if (!lNewQuotes.isEmpty()) {
            callDMS(lNewQuotes);
        }
        // End Change.
        
        //Change the XXAccountStatus__c field in Account
        ChangeAccountStatus.mainFunction(lNewQuotes);

        //Create new AccountLeaserRelation for SBQQQuotes with leaser field
        AccountLeaserRelationUtils.createAccounLeaserRelation(lNewQuotes);

        // Create automatic contacts
        List<SBQQ__Quote__c> activedQuotes = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c quote : lNewQuotes){
            if(quote.SBQQ__Status__c == '2' && 
            quote.RecordTypeId == PAD.getRecordTypeIdByDeveloperName(Constants.SOT_SBQQ_QUOTE,'OPV_Quote')){// TODO use constants
            activedQuotes.add(quote);

            }
        }
    SBQQQuoteUtils.createAutomaticContacts(activedQuotes);
    }

    /*
     * @Method          :   afterUpdate
     * @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   19 jun 2018
     * @Description     :   Call the actions that handle the after update trigger.
     * @Params          :   List<SBQQ__Quote__c> records after the changes, Map<Id, SBQQ__Quote__c> record before the changes
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
    public static void afterUpdate(List<SBQQ__Quote__c> lNewQuotes, Map<Id, SBQQ__Quote__c> mapOldQuotes) {
        CancelOrderForm.mainFunction(lNewQuotes, mapOldQuotes);
        SBQQQuoteUtils.enqueueAsyncUpdateFleetRequestQuantity(lNewQuotes);
        // Start Change C1STAGILE-4950: Added by by Ruben Fernandez
        if(!lNewQuotes.isEmpty()){
            callDMS(lNewQuotes);
        }
        
        List<SBQQ__Quote__c> lOrderFormsToChangeAccountStatus = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> activedQuotes = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c ordForm : lNewQuotes){
            if(ordForm.SBQQ__Status__c != mapOldQuotes.get(ordForm.id).SBQQ__Status__c){
                lOrderFormsToChangeAccountStatus.add(ordForm);
                if(ordForm.SBQQ__Status__c == '2' && ordForm.RecordTypeId == PAD.getRecordTypeIdByDeveloperName(Constants.SOT_SBQQ_QUOTE,'OPV_Quote')){ // TODO use constants
                    activedQuotes.add(ordForm);
                }
            }
        } 

        SBQQQuoteUtils.createAutomaticContacts(activedQuotes);

        //Change the XXAccountStatus__c field in Account
        if(lOrderFormsToChangeAccountStatus != null && lOrderFormsToChangeAccountStatus.size()>0){
            ChangeAccountStatus.mainFunction(lOrderFormsToChangeAccountStatus);
        }
        
        // End Change C1STAGILE-4950.
        runtrigger = false;
        
    }
    /*
     * @Method          :   callDMS
     * @Author          :   Ruben Fernandez
     * @Created         :   28 dec 2018
     * @Description     :   Calling to DMS if needed.
     * @Params          :   List of SBQQ__Quote__c records
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */
    private static void callDMS(List<SBQQ__Quote__c> lNewQuotes){  
        System.debug('SBQQ__Quote__c callDMS' + lNewQuotes.size());
        List<SBQQ__Quote__c> lstQuoteDMS    = new List<SBQQ__Quote__c>();
        Set<Id> AllOwnerIds                 = new Set<Id>();
        for(SBQQ__Quote__c l : lNewQuotes){
            //System.debug('Cond 1: ' +  PAD.sUserTypeCode + ' : ' + PAD.sUserDMS );
            if( PAD.sUserTypeCode == '0' && PAD.sUserDMS){
                //System.debug('Cond 2: ' +  l.recordtypeid + ' : ' + PAD.getObjRecordType('SBQQ__Quote__c','CPQ Order Form') + ' : ' +Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('CPQ_Order_Form').getRecordTypeId() );
                if(l.recordtypeid == Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('CPQ_Order_Form').getRecordTypeId()){
                   lstQuoteDMS.add(l);
                }
            //28/01/2019 RFL: C1STAGILE-6493. Replace CreatedById by OwnerId
            }else{
                AllOwnerIds.add(l.OwnerId);
            }
            // END Change
        }
        //28/01/2019 RFL: C1STAGILE-6493. Replace CreatedById by OwnerId
        if(!AllOwnerIds.isEmpty()){
            getOwnerIds(AllOwnerIds);
            for(SBQQ__Quote__c l : lNewQuotes){
                if(OwnerUserID.containsKey(l.OwnerId)){
                    lstQuoteDMS.add(l);
                }
            }
        }
        
        if(!lstQuoteDMS.isEmpty()){
            System.debug('SBQQ__Quote callDMS SAPIWebhook');
            SAPIWebhook.ProcessRecords(lstQuoteDMS,0);
        } 
    }
    /*
     * @Method          :   getOwnerIds
     * @Description     :   Get List of users for each record Owner.
     * @Params          :   Set<Id> Record Owners
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */     
    private static void getOwnerIds(Set<Id> allOwners){
        System.debug('getOwnerIds START : ' + allOwners.size());
        for(User aux : [SELECT Id,Country__c,Brand__c,LDAPId__c,VNRRDICode__c,RAorAgentRRDICode__c,LanguageLocaleKey,LocaleSidKey,Profile.Name,ContactId,Contact.Account.DMSConnectedToC1st__c, 
            Contact.Account.CommunicationMode__c, Contact.Account.DMSport__c,Contact.Account.Id, Contact.Account.UrlDMS__c FROM User where Id IN : allOwners AND IsActive = true]){
            //System.debug('Cond 1: ' +  PAD.sSalesProfiles.indexOf(aux.Profile.Name) );
            if(PAD.sSalesProfiles.indexOf(aux.Profile.Name)>=0){
                if(aux.ContactId != null){
                    if(aux.Contact.Account!=null){
                        OwnerUserID.put(aux.Id,aux);
                    }
                }
            }
            
        }
    }
    
}
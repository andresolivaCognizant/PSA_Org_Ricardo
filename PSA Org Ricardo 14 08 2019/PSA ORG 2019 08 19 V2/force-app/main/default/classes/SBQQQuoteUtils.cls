public class SBQQQuoteUtils {

	private static final String         FLEET_REQUEST_RT    = 'FleetRequestOpportunity';
	private static final Set<String>    IRRELEVANT_STATUS   = new Set<String>{'6', '7'};

	public static void updateFleetRequestQuantity(List<SBQQ__Quote__c> lstNewRows) {

		Set<Id> lstIds = new Set<Id>();

		// set of quotes' parent opportunity ids
		//Set<Id> setO = new Set<Id>();

		// list of fleet request opportunities to be updated
		List<Opportunity> lstUpd = new List<Opportunity>();

		for (SBQQ__Quote__c q : lstNewRows) {
			if (null != q.SBQQ__Opportunity2__c) {
				//setO.add(q.SBQQ__Opportunity2__c);
				lstIds.add(q.Id);
			}
		}

		if (lstIds.isEmpty()) {
			return;
		}

		// map of quotes' parent opportunities fleet requests
		Map<Id, Opportunity> mapFR = new Map<Id, Opportunity>();
		for (SBQQ__Quote__c q : [
			SELECT
				SBQQ__Opportunity2__r.ParentOpportunity__c,
				SBQQ__Opportunity2__r.ParentOpportunity__r.NumberOfOrderedVehicles__c
			FROM SBQQ__Quote__c
			WHERE
				SBQQ__Opportunity2__r.ParentOpportunity__r.RecordType.DeveloperName = :FLEET_REQUEST_RT AND
				Id IN :lstIds
		]) {
			mapFR.put(
				q.SBQQ__Opportunity2__r.ParentOpportunity__c,
				new Opportunity(
					Id                          = q.SBQQ__Opportunity2__r.ParentOpportunity__c,
					NumberOfOrderedVehicles__c  = q.SBQQ__Opportunity2__r.ParentOpportunity__r.NumberOfOrderedVehicles__c
				)
			);
		}

		// map of fleet requests' aggregate results
		Map<Id, AggregateResult> mapAR = new Map<Id, AggregateResult>([
			SELECT
				SBQQ__Opportunity2__r.ParentOpportunity__c Id,
				SUM(Quantity__c) realQ
			FROM SBQQ__Quote__c
			WHERE
				SBQQ__Status__c NOT IN :IRRELEVANT_STATUS AND
				SBQQ__Opportunity2__r.ParentOpportunity__c IN :mapFR.values()
			GROUP BY SBQQ__Opportunity2__r.ParentOpportunity__c
		]);

		for (Opportunity fr : mapFR.values()) {
			Integer newQ = null != mapAR.get(fr.Id).get('realQ') ?
				((Decimal) mapAR.get(fr.Id).get('realQ')).intValue() : 0;

			if (fr.NumberOfOrderedVehicles__c != newQ) {
				fr.NumberOfOrderedVehicles__c = newQ;
				lstUpd.add(fr);
			}
		}

		update lstUpd;
	}

	public class AsyncUpdateFleetRequestQuantity implements System.Queueable {
		private List<SBQQ__Quote__c> lstQ = new List<SBQQ__Quote__c>();

		public AsyncUpdateFleetRequestQuantity(List<SBQQ__Quote__c> lstNewRows) {
			this.lstQ = lstNewRows;
		}

		public void execute(QueueableContext context) {
			updateFleetRequestQuantity(lstQ);
		}
	}

	public static void enqueueAsyncUpdateFleetRequestQuantity(List<SBQQ__Quote__c> lstNewRows) {
		if (System.isQueueable()) {
			return;
		}
		AsyncUpdateFleetRequestQuantity j = new AsyncUpdateFleetRequestQuantity(lstNewRows);
		System.enqueueJob(j);
		return;
	}

	/*
	*   @Author         :   Sergio Lopez
	*   @Created        :   27 dec 2018
	*   @Description    :   Checks Approval Process Requirements US-5996

	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer            Date                     Description
	*      Sergio Lopez         27 dec 2018              Creation.
	*   ----------------------------------------------------------------------------------------------------------------------------
	*/
	public static void checkProcess(List<SBQQ__Quote__c> lNewQuotes, map<id,SBQQ__Quote__c> mapOldQuotes){
		// Validations before process
		try {
			List<User> currentUser = [
				SELECT Id, Profile.Name, Contact.Account.OrderFormValidation__c
				FROM User
				WHERE Id = :UserInfo.getUserId()
			];

			for (SBQQ__Quote__c oQuote : lNewQuotes) {
				if (!Label.Order_Form_Approval_Profiles.contains(currentUser[0].Profile.Name)){
					oQuote.addError(Label.Order_Form_Approval_Error);
				}

				if (currentUser[0].Contact.Account.OrderFormValidation__c == false){
					oQuote.addError(Label.Dealer_OForm_Approval_Error);
				}
			}
		} catch (System.DmlException e) {
			System.debug('DmlException ERROR CheckApprovalRequirement.checkProcess -->' + e.getMessage() + ' Line: '+e.getLineNumber());
		} catch (Exception e) {
			System.debug('Exception ERROR CheckApprovalRequirement.checkProcess-->' + e.getMessage() + ' Line: '+e.getLineNumber());
		}
	}

	/*
	*   @Author         :   Ricardo Pereira
	*   @Created        :   13 Mar 2019
	*   @Description    :   Stores the ExternalId__c fallowing this criteria: 
		<LCDV14>_<Status>_<Activity__c>_​<DealerId__r.ShortVNContractNumber__c>_​<AgentId__c.TECH_ShortAgentContractNumber>_​<AccountId>​

	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer            Date                     Description
	*      Ricardo Pereira      13 Mar 2019              Creation.
	*   ----------------------------------------------------------------------------------------------------------------------------
	*/
	public static void generateExternalId(Map<Id,SBQQ__Quote__c> mapNewQuotes){
		
		Map<String, SBQQ__Quote__c> mapOFormsByExtId = new Map<String, SBQQ__Quote__c>();// Map<ExternalId__c, OrderForm>

		// Generate the externalId for all of the OrderForms and store them together
		// as the inserted Oforms cant be queried yet, 
		// and the updated ones Lookups might have change in runtime
		// Better to query the accounts info.

		Set<Id> setRelAccountsIds = new Set<Id>();
		Set<Id> setRelOppIds = new Set<Id>();

		for(SBQQ__Quote__c oForm: mapNewQuotes.values()){
			setRelAccountsIds.add(oForm.Agent__c);
			setRelAccountsIds.add(oForm.SBQQ__Partner__c);
			setRelOppIds.add(oForm.SBQQ__Opportunity2__c);
		}

		Map<Id, Account> mapRelAccounts = new Map<Id, Account>([
			SELECT Id, ShortVNContractNumber__c, TECH_ShortAgentContractNumber__c 
			FROM Account 
			WHERE Id IN :setRelAccountsIds]);
		
		Map<Id, Opportunity> mapRelOpp = new Map<Id, Opportunity>([
			SELECT Id, Activity__c
			FROM Opportunity 
			WHERE Id IN :setRelOppIds]);

		for(SBQQ__Quote__c oForm: mapNewQuotes.values()){ 

			mapOFormsByExtId.put(getExternalIdFromOrderForm(oForm, mapRelAccounts, mapRelOpp),
								oForm);

		}

		// Avoid the external Ids that are aready existing
		for(SBQQ__Quote__c oForm: [SELECT ExternalId__c FROM SBQQ__Quote__c WHERE ExternalId__c IN :mapOFormsByExtId.keySet()]){
			
			mapOFormsByExtId.remove(oForm.ExternalId__c);
		}

		// Store the external Id to the right Order Forms
		for(String extId: mapOFormsByExtId.keySet()){
			SBQQ__Quote__c oForm = mapOFormsByExtId.get(extId);
			mapNewQuotes.get(oForm.Id).ExternalId__c = extId;
		}
	}

	/*
	*   @Author         :   Ricardo Pereira
	*   @Created        :   13 Mar 2019
	*   @Description    :   Generates the external Id from an OrderForm​
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer            Date                     Description
	*      Ricardo Pereira      13 Mar 2019              Creation.
	*   ----------------------------------------------------------------------------------------------------------------------------
	*/
	private static String getExternalIdFromOrderForm(SBQQ__Quote__c oForm, Map<Id, Account> mapRelAccounts, Map<Id, Opportunity> mapRelOpp){
		String extId = '';

		if(String.isNotBlank(oForm.LCDV16__c) && oForm.LCDV16__c.length() >= 14){
			extId += oForm.LCDV16__c.left(14);
		}

		extId += '_';
		extId += oForm.SBQQ__Status__c!= null? oForm.SBQQ__Status__c: '';
		extId += '_';
		
		if(mapRelOpp.containsKey(oForm.SBQQ__Opportunity2__c)
			&& mapRelOpp.get(oForm.SBQQ__Opportunity2__c).Activity__c != null){
			
			extId += mapRelOpp.get(oForm.SBQQ__Opportunity2__c).Activity__c;
		}
		
		extId += '_';
		
		if(mapRelAccounts.containsKey(oForm.SBQQ__Partner__c)
			&& mapRelAccounts.get(oForm.SBQQ__Partner__c).ShortVNContractNumber__c != null){
			
			extId += mapRelAccounts.get(oForm.SBQQ__Partner__c).ShortVNContractNumber__c;
		}
		extId += '_';

		if(mapRelAccounts.containsKey(oForm.Agent__c)
			&& mapRelAccounts.get(oForm.Agent__c).TECH_ShortAgentContractNumber__c != null){
			
			extId += mapRelAccounts.get(oForm.Agent__c).TECH_ShortAgentContractNumber__c;
		}

		extId += '_';
		if( oForm.SBQQ__Account__c != null )
		{  
			extId += oForm.SBQQ__Account__c ;
		}
		return extId;
	}

	/*
	*   @Author         :   Manuel Medina
	*   @Created        :   26 Apr 2019
	*   @Description    :   Updates TECH_HasServiceCodes field based on ServiceCodes__c field.
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer            Date                     Description
	*      Manuel Medina        26 Apr 2019              Creation.
	*   ----------------------------------------------------------------------------------------------------------------------------
	*/
	public static void validateServiceCodes( List<SBQQ__Quote__c> lstNewQuotes, Map<Id, SBQQ__Quote__c> mapOldQuoteById ){
		for( SBQQ__Quote__c objQuote : lstNewQuotes ){
			if( ( mapOldQuoteById != null && mapOldQuoteById.containsKey( objQuote.Id ) && objQuote.ServiceCodes__c != mapOldQuoteById.get( objQuote.Id ).ServiceCodes__c ) || mapOldQuoteById == null ){
				objQuote.TECH_HasServiceCodes__c					= String.isNotBlank( objQuote.ServiceCodes__c );
			}
		}
	}

	/*********************************************************************************************************
	* @Method			:	getAutomaticContactDaysToDue
	* @Author			:	Ricardo Pereira
	* @Created			:	29/07/2019
	* @Description		:	// TODO 
	* @params			:	// TODO
	* @Returns			:	// TODO
	**********************************************************************************************************/
	public static void createAutomaticContacts(List<SBQQ__Quote__c> parentQuotes){
		Set<Id> setRelatedOppIds = new Set<Id>();
		for(SBQQ__Quote__c quote: parentQuotes){
			setRelatedOppIds.add(quote.SBQQ__Opportunity2__c);
		}

		Map<String, AutomaticContactConfig__mdt> mapConfigs = OrderUtils.getAutoContactConfig();

		// Retrieve all quotes in the needed opps
		List<SBQQ__Quote__c> lstQuotesInOpps = [
			SELECT Id, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.Owner.Brand__c, SBQQ__Opportunity2__r.Owner.Country__c,
			SBQQ__Opportunity2__r.OwnerId,  
			SBQQ__Account__c, SBQQ__Account__r.IsPersonAccount, SBQQ__Account__r.PersonContactId, SBQQ__PrimaryContact__c
			FROM SBQQ__Quote__c
			WHERE SBQQ__Opportunity2__c IN: setRelatedOppIds
			AND SBQQ__Status__c = '2'];

		// Create a banned opps list
		Set<Id> setAllowedOpps = new Set<Id>();
		Set<Id> setBannedOpps = new Set<Id>();

		for(SBQQ__Quote__c quote: lstQuotesInOpps){
			if(setAllowedOpps.contains(quote.SBQQ__Opportunity2__c)){
				setBannedOpps.add(quote.SBQQ__Opportunity2__c);
			}else{
				setAllowedOpps.add(quote.SBQQ__Opportunity2__c);
			}
		}

		List<Task> lstTasksToCreate = new List<Task>();

		for(SBQQ__Quote__c quote: lstQuotesInOpps){
			if(!setBannedOpps.contains(quote.SBQQ__Opportunity2__c)){
				String configMapKey = quote.SBQQ__Opportunity2__r.Owner.Country__c 
										+ quote.SBQQ__Opportunity2__r.Owner.Brand__c 
										+ 'Quote Activation';
                System.debug('##RP## configMapKey: ' + configMapKey);

				if(mapConfigs.containsKey(configMapKey)){ 

					Decimal daysToDue = mapConfigs.get(configMapKey).DaysToDue__c;
					String customerContactId = quote.SBQQ__Account__r.IsPersonAccount?
									quote.SBQQ__Account__r.PersonContactId:
									quote.SBQQ__PrimaryContact__c;


					lstTasksToCreate.add(
						new Task(
							Subject = Label.AutomaticContactTaskSubjectQuote, 
							OwnerId = quote.SBQQ__Opportunity2__r.OwnerId,
							WhoId = customerContactId,
							WhatId = quote.SBQQ__Opportunity2__c,
							ActivityDate = System.today().addDays(daysToDue.round(System.RoundingMode.UP).intValue()),
							// Andrés Oliva 12/08/2019  manage type with custom metadata							
							Type =   mapConfigs.get(configMapKey).Type__c , //  'Call', 
							Priority = SalesConstants.TASK_PRIORITY_NORMAL, //'Normal', 
							Status = SalesConstants.TASK_STATUS_0, // 0,
							CallStatus__c = SalesConstants.TASK_CALLSTATUS_1 //'1' 
							));

				}
			}
		}

		insert lstTasksToCreate;
	}

	/*********************************************************************************************************
	* @Method			:	handleQuoteOpportunity
	* @Author			:	Borja Gay
	* @Created			:	9/08/2019
	* @Description		: Method to create or update opportunities for the quotes created  
	* @params			:	lstQuote list of Quotes created
	* @Returns			: void
	**********************************************************************************************************/
    public static void handleQuoteOpportunity(List<SBQQ__Quote__c> lstQuote) {
		List<SBQQ__Quote__c> lstQuotesWithoutOpp = new List<SBQQ__Quote__c>();
		List<SBQQ__Quote__c> lstQuotesWithOpp = new List<SBQQ__Quote__c>();
		List<String> lstFamilyCodes = new List<String>();
		Set<Id> setOpportunityId = new Set<Id>();
		Set<Id> setOwnerId = new Set<Id>();
		Map<Id,Opportunity> mapOppToUpsert = new Map<Id,Opportunity>();
		Map<String,String> mapPSARangeDesc = new MAP<String,String>();
		for(SBQQ__Quote__c quote : lstQuote){
			if(quote.SBQQ__Opportunity2__c == null){
				lstQuotesWithoutOpp.add(quote);
				setOwnerId.add(quote.OwnerId);
				if(quote.Family__c != null){
					lstFamilyCodes.add(quote.Family__c);
				}
			}
			else{
				lstQuotesWithOpp.add(quote);
				setOpportunityId.add(quote.SBQQ__Opportunity2__c);
			}
		}
		if(!lstQuotesWithOpp.isEmpty()){
			mapOppToUpsert.putAll(updateOpportunites(lstQuotesWithOpp,setOpportunityId));
		}
		if(!lstQuotesWithoutOpp.isEmpty()){
			if(!lstFamilyCodes.isEmpty()){
				mapPSARangeDesc = getFamilyCodes(lstFamilyCodes);
			}
			mapOppToUpsert.putAll(createNewOpportunities(lstQuotesWithoutOpp, setOwnerId, mapPSARangeDesc));
		}

		upsert mapOppToUpsert.values();

		for(SBQQ__Quote__c quote : lstQuotesWithoutOpp){
			if(mapOppToUpsert.containsKey(quote.TECH_OPVId__c)){
				quote.SBQQ__Opportunity2__c = mapOppToUpsert.get(quote.TECH_OPVId__c).Id;
			}
		}
	}
	/*********************************************************************************************************
	* @Method			:	updateOpportunites
	* @Author			:	Borja Gay
	* @Created			:	9/08/2019
	* @Description		:   Method to update opportunities for the quotes created  
	* @params			:	lstQuotesWithOpp list of Quotes created with opportunity
	* @params			:	setOpportunityId set of OpportunityId
	* @Returns			: 	map<Id,Opportunity> map with the opportunities updated
	**********************************************************************************************************/
	private static Map<Id,Opportunity> updateOpportunites (List<SBQQ__Quote__c> lstQuotesWithOpp, Set<Id> setOpportunityId){
		Map<Id,Opportunity> mapOppToUpsert = new Map<Id,Opportunity>();
		Map<Id,Opportunity> mapOpp = new Map<Id,Opportunity>();
		mapOpp = new Map<Id,Opportunity>([SELECT id, StageName FROM Opportunity WHERE Id IN :setOpportunityId]);
		for(SBQQ__Quote__c quote : lstQuotesWithOpp){
			if((quote.RecordTypeId == PAD.getRecordTypeIdByDeveloperName(Constants.SOT_SBQQ_QUOTE,'CPQ_Quote') || 
			quote.RecordTypeId == PAD.getRecordTypeIdByDeveloperName(Constants.SOT_SBQQ_QUOTE,'OPV_Quote')) &&
			(mapOpp.get(quote.SBQQ__Opportunity2__c).StageName == SalesConstants.OPP_STAGE_NEEDS_ANALYSIS ||
			mapOpp.get(quote.SBQQ__Opportunity2__c).StageName == SalesConstants.OPP_STAGE_NEGOTIATION)){
				Opportunity opp = new Opportunity();
				opp.Id = quote.SBQQ__Opportunity2__c;
				opp.StageName = SalesConstants.OPP_STAGE_QUOTE;
				mapOppToUpsert.put(quote.TECH_OPVId__c,opp);
			}
			else if(quote.RecordTypeId == PAD.getRecordTypeIdByDeveloperName(Constants.SOT_SBQQ_QUOTE,'OPVOrderFormVN') || 
			quote.RecordTypeId == PAD.getRecordTypeIdByDeveloperName(Constants.SOT_SBQQ_QUOTE,'CPQ_Order_Form') ||
			quote.RecordTypeId == PAD.getRecordTypeIdByDeveloperName(Constants.SOT_SBQQ_QUOTE,'OPVOrderFormVD')){
				Opportunity opp = new Opportunity();
				opp.Id = quote.SBQQ__Opportunity2__c;
				opp.StageName = SalesConstants.OPP_STAGE_CONTRACT;
				mapOppToUpsert.put(quote.TECH_OPVId__c,opp);
			}
		}
		return mapOppToUpsert;
	}
	/*********************************************************************************************************
	* @Method			:	getFamilyCodes
	* @Author			:	Borja Gay
	* @Created			:	12/08/2019
	* @Description		:   Method to get the description of each PSARangeDescription with matching familyCodes  
	* @params			:	lstFamilyCodes list of family codes in the quotes
	* @Returns			: 	map<String,String> map with all Family Codes
	**********************************************************************************************************/
	private static Map<String,String> getFamilyCodes(List<String> lstFamilyCodes){
		List<PSARangeDescription__c> lstPSARange = new List<PSARangeDescription__c>();
		Map<String,String> mapPSARangeDesc = new Map<String,String>();
		lstPSARange = [SELECT id,Brand__c,Country__c,Code__c,Description__c FROM PSARangeDescription__c WHERE Code__c IN :lstFamilyCodes AND Type__c = 'LCDV4'];
		if(!lstPSARange.isEmpty()){
			for(PSARangeDescription__c psaRange : lstPSARange){
				mapPSARangeDesc.put(psaRange.Brand__c+psaRange.Country__c+psaRange.Code__c,psaRange.Description__c);
			}
		}
		return mapPSARangeDesc;
	}

	/*********************************************************************************************************
	* @Method			:	createNewOpportunities
	* @Author			:	Borja Gay
	* @Created			:	12/08/2019
	* @Description		:   Method to create the new opportunities for the quotes
	* @params			:	lstFamilyCodes list of family codes in the quotes
	* @Returns			: 	map<String,String> map with all Family Codes
	**********************************************************************************************************/
	private static Map<Id,Opportunity> createNewOpportunities (List<SBQQ__Quote__c> lstQuotesWithoutOpp, Set<Id> setOwnerId,Map<String,String> mapPSARangeDesc){
		Map<Id,Opportunity> mapOppToUpsert = new Map<Id,Opportunity>();
		String userId = UserInfo.getUserId();
		setOwnerId.add(userId);
		Map<Id,User> mapOwner = new Map<Id,User>();
		mapOwner = new Map<Id,User>([SELECT id, Country__c, Brand__c FROM User WHERE Id IN :setOwnerId]);
		for(SBQQ__Quote__c quote : lstQuotesWithoutOpp){
			String country = '';
			String brand = '';
			if(mapOwner.get(userId).Brand__c != null && mapOwner.get(userId).Country__c != null){
				country = mapOwner.get(userId).Country__c;
				brand = mapOwner.get(userId).Brand__c;
			}
			else if(mapOwner.get(quote.OwnerId).Brand__c != null && mapOwner.get(quote.OwnerId).Country__c != null){
				country = mapOwner.get(quote.OwnerId).Country__c;
				brand = mapOwner.get(quote.OwnerId).Brand__c;
			}
			else{
				country = quote.Country__c;
				brand = quote.Brand__c;
			}
			Opportunity opp = new Opportunity();
			opp.AccountId = quote.SBQQ__Account__r.id;
			opp.CloseDate = Date.today().addDays(180);
			opp.Country__c = country;
			opp.CurrencyIsoCode = quote.CurrencyIsoCode;
			opp.OwnerId = quote.OwnerId;
			opp.StageName = SalesConstants.OPP_STAGE_QUOTE;
			if(mapPSARangeDesc.containsKey(brand+country+quote.Family__c)){
				opp.Name = mapPSARangeDesc.get(brand+country+quote.Family__c)+' '+quote.OfferType__c+' '+Date.today();
			}
			else{
				opp.Name = quote.OfferType__c+' '+Date.today();
			}
			mapOppToUpsert.put(quote.TECH_OPVId__c,opp);
		}
		return mapOppToUpsert;
	}
	
}
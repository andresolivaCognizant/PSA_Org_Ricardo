public class OpportunityUtils {
	
	private final static Id RT_OPP_STANDARD		= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get( 'Opportunity_Record_Type' ).getRecordTypeId();
	private final static Id RT_OPP_QUICK		= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get( 'QuickOpportunity' ).getRecordTypeId();

	public static Map<Id, Contact> mapIERsByContactId;
	public static Map<Id, Account> mapAccountById;
	
	public static Map<String,String> getStages(){
		
		Schema.DescribeFieldResult fieldResult = Opportunity.Stagename.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		Map<String,String> stages = new Map<String,String>();

		
		for(Schema.PicklistEntry f : ple){
			stages.put(f.getValue(),f.getLabel());
		}       
		return stages;
	}
	
	
	public static void getDestinationDealer(List<Opportunity> lstO) {
		
		Set<Id> setOwnerId = new Set<Id>();
		Map<Id, User> mapU = new Map<Id, User>();
		
		for (Opportunity o : lstO) {
			setOwnerId.add(o.OwnerId);
		}
		
		if (!setOwnerId.isEmpty()) {
			mapU = new Map<Id, User>([
				SELECT Id, Contact.AccountId
				FROM User
				WHERE Id IN :setOwnerId
			]);
		}
		
		for (Opportunity o : lstO) {
			if (mapU.containsKey(o.OwnerId)) {
				o.DestinationDealerId__c = mapU.get(o.OwnerId).Contact.AccountId;
			}
		}        
		
		
		
	}    

	// US C1STRUN-1266 - BEGIN
	public static void shareOAccWthUser(List<Opportunity> lstO) {
		system.debug('@@ shareOAccWthUser: '+lstO);
		
		List<Account> lAccId = new List<Account> ();
		List<AccountShare> accToShare = new List<AccountShare> (); 

		String userId = userInfo.getUserId();

		for (Opportunity opp : lstO){
			Account acc  = new Account(); 
			acc.Id = opp.AccountId;
			lAccId.add(acc);
		}

		if (lAccId.size() > 0){
			for (Account acc:lAccId){
				AccountShare accShr  = new AccountShare();// Create new sharing object  
				accShr.AccountId = acc.Id;//Set the ID of record being shared. 
				accShr.UserOrGroupId = userId;// Set the ID of user being granted access  
				accShr.AccountAccessLevel = 'Edit';// Set the access level.
				accShr.RowCause = Schema.AccountShare.RowCause.Manual;// Set rowCause to 'manual' for manual sharing.
				/* C1STRUN-1800 - begin
				accShr.OpportunityAccessLevel = 'Read';
				*/
				accShr.OpportunityAccessLevel = 'None';
				/* C1STRUN-1800 - end */
				accToShare.add(accShr);
			}
		}

		try{
			
			// The false parameter allows for partial processing if multiple records passed  
			if (!accToShare.isEmpty()){
				System.debug('ACC TO SHARE: '+accToShare);
				Database.insert(accToShare,true);// Insert the sharing record. 
			}
			
		}catch(DMLexception e) {
			System.debug('OpportunityUtils.ManualSharing ERROR -->' + e.getMessage() + ' Line: '+e.getLineNumber());
		} catch (Exception e){
			System.debug('OpportunityUtils.ManualSharing ERROR --> ' + e.getMessage() + ' Line: '+e.getLineNumber());
		} 
 
	}
	// US C1STRUN-1266 - END
	
	/*
	* @Method		: changeRecordTypeToStandardOpp
	* @Author		: Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
	* @Created		: 15 march 2019
	* @Description	: This method makes the change of RecordType (Quick -> Standard)Opp
	* @Params		: List<Opportunity> Opp->Trigger.New
	* @Returns		: void
	* @MaxSoqls		: 0
	* @MaxDmls		: 0
	*/
	public static void changeRecordTypeToStandardOpp(List<Opportunity> oppList){
		for(Opportunity opp : oppList){
			if(opp.RecordTypeId == RT_OPP_QUICK){
				opp.RecordTypeId = RT_OPP_STANDARD;
			}
		}
	}

	/*
	 * @Method          :   createOrderFromOrderForm
	 * @Description     :   This methods creates Orders retrieving info from an OrderForm.
	 * @Params          :   SBQQ__Quote__c Order Form to be processed
	 * @Returns         :   List<Order> Created orders
	 */ 
	public static List<Order> createOrderFromOrderForm(SBQQ__Quote__c ordForm) {
		
		List<Order> lstCreatedOrders = new List<Order>();
		Order newOrder = new Order(
			Brand__c = ordForm.Brand__c,
			Country__c = ordForm.Country__c,
			AccountId = ordForm.SBQQ__Account__c,
			OpportunityId = ordForm.SBQQ__Opportunity2__c,
			AgentId__c = ordForm.Agent__c,
			OrderFormId__c = ordForm.Id,
			LCDV16__c = ordForm.LCDV16__c,
			OrderCreationDate__c = System.today(),
			DialogDeliveryDate__c = System.today(),
			RealDeliveryDate__c = System.today(),
			FamilyCode__c = ordForm.Family__c,
			ExteriorTrimColorCode__c = ordForm.ColorCode__c,
			InteriorTrimColorCode__c = ordForm.InteriorTrimCode__c,
			Options__c = ordForm.OptionCodes__c,
			CARNumber__c = ordForm.CARNumber__c,
			VIN__c = ordForm.VIN__c,
			Status = '9',
			Order_Type__c = ordForm.OfferType__c,
			RegistrationDate__c = ordForm.FirstRegistrationDate__c,
			CompletedSaleDate__c = System.today(),
			RegistrationNumber__c = ordForm.RegistrationNumber__c,
			VehicleStatus__c = '8',
			Leaser__c = ordForm.Leaser__c,
			Driver__c = ordForm.Driver__c,
			ShipToContactId = ordForm.SBQQ__PrimaryContact__c,
			TradeInCar__c = ordForm.TradeInCar__c,
			LeaserContact__c = ordForm.LeaserContact__c,
			LCDVDescription__c = ordForm.VersionDescription__c,
			InteriorTrimColorDescription__c = ordForm.InteriorTrimDescription__c,
			ExteriorTrimColorDescription__c = ordForm.ColorDescription__c,
			OrderId__c = 'OR_' + ordForm.OPV_OfferCode__c,
			CurrencyIsoCode = ordForm.CurrencyIsoCode,
			DealerId__c = ordForm.SBQQ__Partner__c,
			OptionsAndPacks__c = ordForm.OptionCodes__c,
			AvailabilityDate__c = ordForm.ProductionYear__c == null ? null : Date.newInstance(Integer.valueOf(ordForm.ProductionYear__c), 12, 31),
			EffectiveDate = System.today()
		);

		/* TODO ONLY FOR WAVE 3: Include fields ProtocolId__c, ProtocolDiscountId__c, ProtocolAccountId__c
		newOrder.ProtocolId__c = ordForm.ProtocolId__c; 
		newOrder.ProtocolDiscountId__c = ordForm.ProtocolDiscountId__c;
		newOrder.ProtocolAccountId__c = ordForm.ProtocolAccountId__c; */
		
		// Fill LCDV16 related fields
		if(ordForm.LCDV16__c != null && ordForm.LCDV16__c.length() == 16){
			
			if ( !Schema.sObjectType.PSARangeDescription__c.fields.Description__c.isAccessible() 
				|| !Schema.sObjectType.PSARangeDescription__c.fields.VPVU__c.isAccessible()){ // CRUD Enforcement needed due to PMD rule
				throw new CRUDException('No read access of PSARangeDescription__c');
			}
			//Obtain the description from LCDV16 codes
			Map<String, PSARangeDescription__c> mapPSARangeDescriptions = new Map<String, PSARangeDescription__c>(); // Map<desc.Type__c, Object>
			for(PSARangeDescription__c rangeDesc: [SELECT Description__c, VPVU__c 
						FROM PSARangeDescription__c
						WHERE Country__c =: ordForm.Country__c 
						AND Brand__c =: ordForm.Brand__c 
						AND Language__c =: UserInfo.getLanguage()
						AND Active__c = true
						AND ((Code__c =: ordForm.LCDV16__c.left(4) AND Type__c = 'LCDV4' AND RefersTo__c = null)
							OR (Code__c =: ordForm.LCDV16__c AND  Type__c = 'LCDV16' AND RefersTo__c = null)
						) ]){

				mapPSARangeDescriptions.put(rangeDesc.Type__c, rangeDesc);
			}

			newOrder.FamilyDescription__c = mapPSARangeDescriptions.containsKey('LCDV4')? mapPSARangeDescriptions.get('LCDV4').Description__c : '';
			newOrder.VPVU__c = mapPSARangeDescriptions.containsKey('LCDV16')? mapPSARangeDescriptions.get('LCDV16').VPVU__c : '';


		}
		
		lstCreatedOrders.add(newOrder);
		return lstCreatedOrders;
	}

	/*
	 * @Method          :   processBUIndividualOpp
	 * @Description     :   Calls all methods for a single opoortunity DML operation (Before Update)
	 * @Params          :   SBQQ__Quote__c Order Form to be processed
	 */ 
	public static void processBUIndividualOpp(Opportunity newOpp, Opportunity oldOpp) {

		if('6'.equals(newOpp.StageName) && newOpp.StageName != oldOpp.StageName){

			List<SBQQ__Quote__c> lstOrdForm = getOrderFormFromOpp(newOpp.Id);

			if(!lstOrdForm.isEmpty() && lstOrdForm.size() == 1){

				List<Order> lstOrder = createOrderFromOrderForm(lstOrdForm[0]);

				if (!lstOrder.isEmpty()) {
					insert lstOrder;

					lstOrdForm[0].SBQQ__Status__c = '4';
					update lstOrdForm;
				}
			}
		}
	}

	/*
	 * @Method          :   getOrderFormFromOpp
	 * @Description     :   Calls all methods for a single opoortunity DML operation (Before Update)
	 * @Params          :   Id Parent opportunity Id
	 */ 
	@SuppressWarnings('PMD.CyclomaticComplexity')
	//Warning supressed: CRUD enforcement causes great Cyclomatic Complexity
	private static List<SBQQ__Quote__c> getOrderFormFromOpp(Id oppId) {

		if ( !Schema.sObjectType.SBQQ__Quote__c.fields.Agent__c.isAccessible() 
			|| !Schema.sObjectType.SBQQ__Quote__c.fields.Brand__c.isAccessible()
			|| !Schema.sObjectType.SBQQ__Quote__c.fields.CARNumber__c.isAccessible()
			|| !Schema.sObjectType.SBQQ__Quote__c.fields.ColorCode__c.isAccessible()
			|| !Schema.sObjectType.SBQQ__Quote__c.fields.ColorDescription__c.isAccessible()
			|| !Schema.sObjectType.SBQQ__Quote__c.fields.Country__c.isAccessible()
			|| !Schema.sObjectType.SBQQ__Quote__c.fields.CurrencyIsoCode.isAccessible()
			|| !Schema.sObjectType.SBQQ__Quote__c.fields.DealerFiscalId__c.isAccessible()
			|| !Schema.sObjectType.SBQQ__Quote__c.fields.Driver__c.isAccessible()
			|| !Schema.sObjectType.SBQQ__Quote__c.fields.Family__c.isAccessible()
			|| !Schema.sObjectType.SBQQ__Quote__c.fields.FirstRegistrationDate__c.isAccessible()
			|| !Schema.sObjectType.SBQQ__Quote__c.fields.Id.isAccessible()
			|| !Schema.sObjectType.SBQQ__Quote__c.fields.InteriorTrimCode__c.isAccessible()
			|| !Schema.sObjectType.SBQQ__Quote__c.fields.InteriorTrimDescription__c.isAccessible()
			|| !Schema.sObjectType.SBQQ__Quote__c.fields.LCDV16__c.isAccessible()
			|| !Schema.sObjectType.SBQQ__Quote__c.fields.Leaser__c.isAccessible()
			|| !Schema.sObjectType.SBQQ__Quote__c.fields.LeaserContact__c.isAccessible()
			|| !Schema.sObjectType.SBQQ__Quote__c.fields.OfferType__c.isAccessible()
			|| !Schema.sObjectType.SBQQ__Quote__c.fields.OptionCodes__c.isAccessible()
			|| !Schema.sObjectType.SBQQ__Quote__c.fields.OPV_OfferCode__c.isAccessible()
			|| !Schema.sObjectType.SBQQ__Quote__c.fields.ProductionYear__c.isAccessible()
			|| !Schema.sObjectType.SBQQ__Quote__c.fields.RegistrationNumber__c.isAccessible()
			|| !Schema.sObjectType.SBQQ__Quote__c.fields.SBQQ__Account__c.isAccessible()
			|| !Schema.sObjectType.SBQQ__Quote__c.fields.SBQQ__Opportunity2__c.isAccessible()
			|| !Schema.sObjectType.SBQQ__Quote__c.fields.SBQQ__Partner__c.isAccessible()
			|| !Schema.sObjectType.SBQQ__Quote__c.fields.SBQQ__PrimaryContact__c.isAccessible()
			|| !Schema.sObjectType.SBQQ__Quote__c.fields.TradeInCar__c.isAccessible()
			|| !Schema.sObjectType.SBQQ__Quote__c.fields.VersionDescription__c.isAccessible()
			|| !Schema.sObjectType.SBQQ__Quote__c.fields.VIN__c.isAccessible()){ // CRUD Enforcement needed due to PMD rule
			
			throw new CRUDException('No read access of PSARangeDescription__c');
		}
		
		List<SBQQ__Quote__c> lstOrdForm = [
			SELECT Agent__c, Brand__c, CARNumber__c, ColorCode__c, ColorDescription__c, Country__c, CurrencyIsoCode, DealerFiscalId__c, 
			Driver__c, Family__c, FirstRegistrationDate__c, Id, InteriorTrimCode__c, InteriorTrimDescription__c, LCDV16__c, Leaser__c, 
			LeaserContact__c, OfferType__c, OptionCodes__c, OPV_OfferCode__c, ProductionYear__c, RegistrationNumber__c, SBQQ__Account__c, SBQQ__Opportunity2__c, 
			SBQQ__Partner__c, SBQQ__PrimaryContact__c, TradeInCar__c, VersionDescription__c, VIN__c
			FROM SBQQ__Quote__c
			WHERE SBQQ__Opportunity2__c = :oppId
			AND SBQQ__Status__c = '2'
			AND RecordType.DeveloperName = 'OPVOrderFormVD'];
		
		return lstOrdForm;
	}

	/*
	* @Method		: campaignInfluenceProcess
	* @Author		: Manuel Medina <manuel.medinaperez@ext.mpsa.com>
	* @Created		: 20 may 2019
	* @Description	: C1STAGILE-7889 - Assigns the primary campaign field based on Campaign Influence process.
	* @Param		: List<Opportunity> lstOpportunities
	* @Param		: Boolean isBeforeInsert
	* @Returns		: void
	* @MaxSoqls		: -
	* @MaxDmls		: -
	*/
	public static void campaignInfluenceProcess( List<Opportunity> lstOpportunities, Boolean isBeforeInsert ){
		Map<Id, Opportunity> mapOpportunityToProcessById			= new Map<Id, Opportunity>();
		List<Opportunity> lstOpportunitiesToProcess					= new List<Opportunity>();

		if( isBeforeInsert ){
			mapAccountById											= new Map<Id, Account>();

			for( Opportunity objOpportunity : lstOpportunities ){
				mapAccountById.put( objOpportunity.AccountId, null );
			}

			getAdditionalInfo();
		}

		for( Opportunity objOpportunity : lstOpportunities ){
			if( mapAccountById.containsKey( objOpportunity.AccountId ) ){
				lstOpportunitiesToProcess.add( objOpportunity );
			}
		}

		if( !lstOpportunitiesToProcess.isEmpty() ){
			if( !isBeforeInsert ){
				createContactRole( mapAccountById, lstOpportunitiesToProcess );
			}

			setCampaignFromIER( mapAccountById, lstOpportunitiesToProcess, isBeforeInsert );
		}
	}

	/*
	* @Method		: getAdditionalInfo
	* @Author		: Manuel Medina <manuel.medinaperez@ext.mpsa.com>
	* @Created		: 22 may 2019
	* @Description	: C1STAGILE-7889 - Get additional data to related accounts and Individual Email Results.
	* @Params		: -
	* @Returns		: void
	* @MaxSoqls		: -
	* @MaxDmls		: -
	*/
	public static void getAdditionalInfo(){
		mapAccountById												= new Map<Id, Account>( [
																		SELECT Id,
																			RecordTypeId,
																			RecordType.DeveloperName,
																			PersonContactId
																		FROM Account
																		WHERE Id IN: mapAccountById.keySet()
																		AND RecordType.DeveloperName = 'PersonAccount_B2C'
																	] );

		mapIERsByContactId											= new Map<Id, Contact>( [
																		SELECT Id,
																			(
																				SELECT Id,
																					Name,
																					CampaignID__c,
																					CampaignID__r.Name,
																					CampaignID__r.Brand__c,
																					CampaignID__r.Country__c,
																					CampaignID__r.Activity__c,
																					CampaignID__r.PSAVehiculeModelSearch__c,
																					CampaignID__r.PSAVehiculeModelSearch__r.Type__c,
																					CampaignID__r.PSAVehiculeModelSearch__r.Code__c,
																					OpportunityID__c,
																					et4ae5__Contact__c,
																					et4ae5__DateSent__c
																				FROM et4ae5__IndividualEmailResults__r
																				WHERE et4ae5__DateSent__c = LAST_90_DAYS
																				AND CampaignID__r.Brand__c != null
																				AND CampaignID__r.Country__c != null
																				AND CampaignID__r.Activity__c != null
																				AND CampaignID__c != null
																				ORDER BY et4ae5__DateSent__c ASC
																			)
																		FROM Contact
																		WHERE AccountId IN: mapAccountById.keySet()
																	] );
	}

	/*
	* @Method		: createContactRole
	* @Author		: Manuel Medina <manuel.medinaperez@ext.mpsa.com>
	* @Created		: 20 may 2019
	* @Description	: C1STAGILE-7889 - Creates an Opporunity Contact Role based on Account Contact.
	* @Params		: Map<Id, Account> mapAccountById
	* @Params		: List<Opportunity> lstOpportunitiesToProcess
	* @Returns		: void
	* @MaxSoqls		: -
	* @MaxDmls		: -
	*/
	public static void createContactRole( Map<Id, Account> mapAccountById, List<Opportunity> lstOpportunitiesToProcess ){
		List<OpportunityContactRole> lstOppContactRoles				= new List<OpportunityContactRole>();

		for( Opportunity objOpportunity : lstOpportunitiesToProcess ){
			if( mapAccountById.containsKey( objOpportunity.AccountId ) && String.isNotBlank( mapAccountById.get( objOpportunity.AccountId ).PersonContactId ) ){
				OpportunityContactRole objOppContactRole			= new OpportunityContactRole();
				objOppContactRole.OpportunityId						= objOpportunity.Id;
				objOppContactRole.Role								= 'Decision Maker';//TODO: Is a valid picklist API value.
				objOppContactRole.ContactId							= mapAccountById.get( objOpportunity.AccountId ).PersonContactId;
				objOppContactRole.IsPrimary							= true;

				lstOppContactRoles.add( objOppContactRole );
			}
		}

		insert lstOppContactRoles;
	}

	/*
	* @Method		: setCampaignFromIER
	* @Author		: Manuel Medina <manuel.medinaperez@ext.mpsa.com>
	* @Created		: 20 may 2019
	* @Description	: C1STAGILE-7889 - Creates Campaign Influence records only in after insert.
	* @Param		: Map<Id, Account> mapAccountById
	* @Param		: Map<Id, Opportunity> mapOpportunityToProcessById
	* @Returns		: void
	* @MaxSoqls		: -
	* @MaxDmls		: -
	*/
	public static void setCampaignFromIER( Map<Id, Account> mapAccountById, List<Opportunity> lstOpportunitiesToProcess, Boolean isBeforeInsert ){
		Map<Id, Set<Id>> mapCampaignsByOpportunityId				= new Map<Id, Set<Id>>();

		for( Opportunity objOpportunity : lstOpportunitiesToProcess ){
			Set<Id> setCampaignIds									= new Set<Id>();
			List<et4ae5__IndividualEmailResult__c> LstIERS			= ( mapAccountById.containsKey( objOpportunity.AccountId ) && mapIERsByContactId.containsKey( mapAccountById.get( objOpportunity.AccountId ).PersonContactId ) ? mapIERsByContactId.get( mapAccountById.get( objOpportunity.AccountId ).PersonContactId ).et4ae5__IndividualEmailResults__r : new List<et4ae5__IndividualEmailResult__c>() );

			Id idPrymaryCampaign;

			for( et4ae5__IndividualEmailResult__c objIER : LstIERS ){
				Boolean blnValidation								= mapAccountById.containsKey( objOpportunity.AccountId )
																		&& String.isNotBlank( mapAccountById.get( objOpportunity.AccountId ).PersonContactId )
																		&& mapAccountById.get( objOpportunity.AccountId ).PersonContactId.equals( objIER.et4ae5__Contact__c )
																		&& String.isNotBlank( objOpportunity.Brand__c )
																		&& String.isNotBlank( objOpportunity.Country__c )
																		&& String.isNotBlank( objOpportunity.Activity__c )
																		&& objOpportunity.Brand__c.equals( objIER.CampaignID__r.Brand__c )
																		&& objOpportunity.Country__c.equals( objIER.CampaignID__r.Country__c )
																		&& objOpportunity.Activity__c.equals( objIER.CampaignID__r.Activity__c );

				if( blnValidation
					&& String.isNotBlank( objOpportunity.TECH_ModelCode__c )
					&& String.isNotBlank( objIER.CampaignID__r.PSAVehiculeModelSearch__c )
					&& objOpportunity.TECH_ModelCode__c.equals( objIER.CampaignID__r.PSAVehiculeModelSearch__r.Code__c )
				){
					idPrymaryCampaign								= objIER.CampaignID__c;
					setCampaignIds.add( objIER.CampaignID__c );

					if( isBeforeInsert ){
						break;
					}
					
				}else if( blnValidation ){
					idPrymaryCampaign								= idPrymaryCampaign == null ? objIER.CampaignID__c : idPrymaryCampaign;
					setCampaignIds.add( objIER.CampaignID__c );
				}
			}

			if( isBeforeInsert ){
				objOpportunity.CampaignId							= idPrymaryCampaign;
			}

			mapCampaignsByOpportunityId.put( objOpportunity.Id, setCampaignIds );
		}

		if( !isBeforeInsert ){
			createCampaignInfluence( mapCampaignsByOpportunityId, mapAccountById, new Map<Id, Opportunity>( lstOpportunitiesToProcess ) );
		}
	}

	/*
	* @Method		: createCampaignInfluence
	* @Author		: Manuel Medina <manuel.medinaperez@ext.mpsa.com>
	* @Created		: 22 may 2019
	* @Description	: C1STAGILE-7889 - Creates Campaign Influence records.
	* @Param		: Map<Id, Set<Id>> mapCampaignsByOpportunityId
	* @Param		: Map<Id, Account> mapAccountById
	* @Param		: Map<Id, Opportunity> mapOpportunityToProcessById
	* @Returns		: void
	* @MaxSoqls		: -
	* @MaxDmls		: -
	*/
	public static void createCampaignInfluence( Map<Id, Set<Id>> mapCampaignsByOpportunityId, Map<Id, Account> mapAccountById, Map<Id, Opportunity> mapOpportunityToProcessById ){
		List<CampaignInfluence> lstCampaignInfluence				= new List<CampaignInfluence>();
		CampaignInfluenceModel objCampaignInfluenceModel			= new CampaignInfluenceModel();
		objCampaignInfluenceModel									= [SELECT Id,
																			DeveloperName
																		FROM CampaignInfluenceModel
																		WHERE DeveloperName = 'DM_CampaignInfluenceModel'
																		LIMIT 1
																	];

		for( Id idOpportunity : mapCampaignsByOpportunityId.keySet() ){
			for( Id idCampaign : mapCampaignsByOpportunityId.get( idOpportunity ) ){
				CampaignInfluence objCampaignInfluence				= new CampaignInfluence();
				objCampaignInfluence.CampaignId						= idCampaign;
				objCampaignInfluence.ContactId						= mapAccountById.get( mapOpportunityToProcessById.get( idOpportunity ).AccountId ).PersonContactId;
				objCampaignInfluence.OpportunityId					= idOpportunity;
				objCampaignInfluence.ModelId						= objCampaignInfluenceModel.Id;
				objCampaignInfluence.Influence						= String.isNotBlank( mapOpportunityToProcessById.get( idOpportunity ).CampaignId ) && mapOpportunityToProcessById.get( idOpportunity ).CampaignId.equals( idCampaign ) ? 100 : 0;

				lstCampaignInfluence.add( objCampaignInfluence );
			}
		}

		insert lstCampaignInfluence;
	}
}
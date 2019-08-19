/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			AfterSales
* Description:		AfterSalesHeaderAsset controller.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	2.0		2018-11-22		Manuel Medina (MM)		Initial definition.
*********************************************************************************************************/
public without sharing class AfterSalesHeaderAssetController {

	public static Map<String, Object> mapResponse							= new Map<String, Object>{
																				'hasError'		=> false,
																				'ERROR'			=> '',
																				'REQUEST'		=> ''
																			};

	public static Map<Boolean, String> mapBinaryValueByBoolean				= new Map<Boolean, String>{
																				true			=> '1',
																				false			=> '0'
																			};

	public static Map<Id, List<String>> mapAlertsByAppointmentId			= new Map<Id, List<String>>();
	public static Map<Id, Boolean> mapHasAppointmentsByAssetId				= new Map<Id, Boolean>();
	public static Map<Id, WorkshopAppointment__c> mapAppointmentById;
	public static Map<String, SObject> mapWarrantyThresholdByKey;
	public static Map<String, SObject> mapMaintenanceThresholdByKey;
	public static Map<String, SObject> mapRenewalPeriodByKey;
	public static Map<String, SObject> mapWorkshopVisitByKey;

	public static Boolean blnIsMassive										= false;

	/**
	* @Method: 		getInitData
	* @param: 		Set<Id> setAppointmentIds
	* @param: 		String strCountry
	* @param: 		String strBrand
	* @param: 		String strType
	* @Description: Updates mapWarrantyThresholdByKey, mapMaintenanceThresholdByKey, mapRenewalPeriodByKey and mapWorkshopVisitByKey
					based on given key (country + brand + type*).
					*type; is optional in some custom metadata types.
	* @author 		Manuel Medina - 03072018
	*/
	public static void getInitData( Set<Id> setAppointmentIds ){
		getInitData( setAppointmentIds, '', '', '' );
	}

	/**
	* @Method: 		getInitData
	* @param: 		Set<Id> setAppointmentIds
	* @param: 		String strCountry
	* @param: 		String strBrand
	* @param: 		String strType
	* @Description: Updates mapWarrantyThresholdByKey, mapMaintenanceThresholdByKey, mapRenewalPeriodByKey and mapWorkshopVisitByKey
					based on given key (country + brand + type*).
					*type; is optional in some custom metadata types.
	* @author 		Manuel Medina - 03072018
	*/
	public static void getInitData( Set<Id> setAppointmentIds, String strCountry, String strBrand, String strType ){
		mapWarrantyThresholdByKey											= new Map<String, SObject>(
																				GlobalSettingsUtil.getCustomMetadataRecords(
																					'ApvHeaderWarrantyThresholds__mdt',
																					new List<String>{ 'Brand__c', 'Country__c', 'RedOrangeLimit__c', 'OrangeGreenLimit__c', 'FromDays__c', 'ToDays__c' },
																					GlobalSettingsUtil.getCustomMetadataKey( strCountry, strBrand, '' )
																				)
																			);

		mapMaintenanceThresholdByKey										= new Map<String, SObject>(
																				GlobalSettingsUtil.getCustomMetadataRecords(
																					'ApvHeaderMaintenanceThresholds__mdt',
																					new List<String>{ 'Brand__c', 'Country__c', 'RedOrangeLimit__c', 'OrangeGreenLimit__c', 'VehicleAge__c' },
																					GlobalSettingsUtil.getCustomMetadataKey( strCountry, strBrand, '' )
																				)
																			);

		mapRenewalPeriodByKey												= new Map<String, SObject>(
																				GlobalSettingsUtil.getCustomMetadataRecords(
																					'ApvHeaderRenewalPeriods__mdt',
																					new List<String>{ 'Brand__c', 'Country__c', 'Type__c', 'From__c', 'To__c' },
																					GlobalSettingsUtil.getCustomMetadataKey( strCountry, strBrand, strType )
																				)
																			);

		mapWorkshopVisitByKey												= new Map<String, SObject>(
																				GlobalSettingsUtil.getCustomMetadataRecords(
																					'ApvHeaderAPVWorkshopVisits__mdt',
																					new List<String>{ 'Brand__c', 'Country__c', 'DaysBeforeFirstVisit__c', 'ReturnWarranty__c' },
																					GlobalSettingsUtil.getCustomMetadataKey( strCountry, strBrand, '' )
																				)
																			);

		mapAppointmentById													= new Map<Id, WorkshopAppointment__c>( [
																				SELECT Id,
																					Driver__c,
																					Owner__c,
																					Asset__r.Brand__c,
																					Asset__r.Country__c,
																					Asset__r.AssetType__c,
																					Asset__r.FirstRegistrationDate__c,
																					Asset__r.LastAPVVisitDate__c,
																					Asset__r.WarrantyEndDate__c,
																					Asset__r.NextMaintenanceDate__c,
																					Asset__r.ProductionDate__c,
																					Asset__r.OrderId__c,
																					Asset__r.OrderId__r.CompletedSaleDate__c
																				FROM WorkshopAppointment__c
																				WHERE Id IN: setAppointmentIds
																			] );

		Set<Id> setAssetIds													= new Set<Id>();
		for( WorkshopAppointment__c objAppointment : mapAppointmentById.values() ){
			setAssetIds.add( objAppointment.Asset__c );
			mapAlertsByAppointmentId.put( objAppointment.Id, new List<String>{ '0', '0', '0', '0' } );
		}

		List<Asset> lstAssets												= new List<Asset>( [
																				SELECT Id,
																					Country__c,
																					Brand__c,
																					(
																						SELECT Id,
																							Asset__c,
																							Asset__r.Country__c,
																							Asset__r.Brand__C,
																							RestitutionDateTime__c,
																							ReceptionDateTime__c
																						FROM Workshop_Appointments__r
																						WHERE Id NOT IN: setAppointmentIds
																						AND AppointmentStatus__c IN ( '5', '6' )
																						AND( 
																							RestitutionDateTime__c != null
																							OR(
																								RestitutionDateTime__c = null
																								AND ReceptionDateTime__c != null
																							)
																						)
																						ORDER BY RestitutionDateTime__c, ReceptionDateTime__c
																					)
																				FROM Asset
																				WHERE Id IN: setAssetIds
																			] );

		for( Asset objAsset : lstAssets ){
			List<WorkshopAppointment__c> lstRelatedAppointments				= new List<WorkshopAppointment__c>( objAsset.Workshop_Appointments__r );
			mapHasAppointmentsByAssetId.put( objAsset.Id, false );

			Integer intIndex												= 0;
			while( intIndex < lstRelatedAppointments.size() && !mapHasAppointmentsByAssetId.get( objAsset.Id ) ){
				Boolean blnIsReturn_RestitutionDateTime						= lstRelatedAppointments.get( intIndex ).RestitutionDateTime__c != null && isWorkshopReturn( lstRelatedAppointments.get( intIndex ), 'RestitutionDateTime__c' );
				Boolean blnIsReturn_ReceptionDateTime						= lstRelatedAppointments.get( intIndex ).RestitutionDateTime__c == null && isWorkshopReturn( lstRelatedAppointments.get( intIndex ), 'ReceptionDateTime__c' );

				mapHasAppointmentsByAssetId.put( objAsset.Id, ( blnIsReturn_RestitutionDateTime || blnIsReturn_ReceptionDateTime ) );

				intIndex++;
			}
		}
	}

	/**
	* @Method: 		isWorkshopReturn
	* @param: 		SObject sObjRecord
	* @param: 		String strDateField
	* @Description:	Returs if given appointment is 
	* @author 		Manuel Medina - 01072019
	*/
	public static Boolean isWorkshopReturn( SObject sObjRecord, String strDateField ){
		String strCountry													= sObjRecord.getSobject( 'Asset__r' ).get( 'Country__c' ) != null ? String.valueOf( sObjRecord.getSobject( 'Asset__r' ).get( 'Country__c' ) ) : '';
		String strBrand														= sObjRecord.getSobject( 'Asset__r' ).get( 'Brand__c' ) != null ? String.valueOf( sObjRecord.getSobject( 'Asset__r' ).get( 'Brand__c' ) ) : '';

		return Datetime.valueOf( String.valueOf( sObjRecord.get( strDateField ) ) ) >= System.today().addDays( -1 * Integer.valueOf( mapWorkshopVisitByKey.get( GlobalSettingsUtil.getCustomMetadataKey( strCountry, strBrand, '' ) ).get( 'ReturnWarranty__c' ) ) ) && Datetime.valueOf( String.valueOf( sObjRecord.get( strDateField ) ) ) <= System.today();
	}

	/**
	* @Method: 		getAssetProperties
	* @param: 		String Id assetId
	* @Description: Returs al data related to an asset based on given asset id.
	* @author 		Diego Rincon - 03072018
	*/
	@AuraEnabled
	public static WrapperVehicleProperties getAssetProperties(Id assetId) {
		Set<Id> setAccountIds												= new Set<Id>();
		WrapperVehicleProperties w = new WrapperVehicleProperties();

		for (AccountContactAssetRelation__c r : [
			SELECT Id, AccountRole__c, AccountId__r.Name, AccountId__c
			FROM AccountContactAssetRelation__c
			WHERE
				AssetId__c = :assetId AND
				AccountRole__c != null
			ORDER BY CreatedDate DESC
		]) {
			switch on r.AccountRole__c {
				when 'Owner' {
					if (null == w.owner.Id) {
						w.owner = r;
						setAccountIds.add( r.AccountId__c );
					}
				}
				when 'Keeper' {
					if (null == w.keeper.Id) {
						w.keeper = r;
						setAccountIds.add( r.AccountId__c );
					}
				}
			}
			
			if (null != w.owner.Id && null != w.keeper.id) {
				break;
			}
		}
		
		w.lstServiceContracts												= new List<ServiceContract>( getServiceContracts( assetId, w.owner.AccountId__r.Id ) );

		Map<Id, AccountExtRef__c> mapAccountExtRefByAccountId				= new Map<Id, AccountExtRef__c>( DMSCustomerDataController.getRelatedAccExtRef( setAccountIds ) );
		w.strOwnerIdDMS														= mapAccountExtRefByAccountId.containsKey( w.owner.AccountId__r.Id ) ? mapAccountExtRefByAccountId.get( w.owner.AccountId__r.Id ).ExternalId__c : null;
		w.strKeeperIdDMS													= mapAccountExtRefByAccountId.containsKey( w.keeper.AccountId__r.Id ) ? mapAccountExtRefByAccountId.get( w.keeper.AccountId__r.Id ).ExternalId__c: null;

		return w;
	}
	
	/**
	* @Method: 		getServiceContracts
	* @param: 		String strAssetId
	* @param: 		String strAccountId
	* @Description: Returs a list with all active service contracts.
	* @author 		Manuel Medina - 03072018
	*/
	public static List<ServiceContract> getServiceContracts( String strAssetId, String strAccountId ){
		List<ServiceContract> lstServiceContracts							= new List<ServiceContract>( [
																				SELECT Id,
																					Name,
																					Asset__c,
																					AccountId,
																					Dealer__c,
																					ContractType__c,
																					StartDate,
																					EndDate,
																					SubscribedMileage__c,
																					ContractStatus__c,
																					toLabel( ContractStatus__c ) contractStatus,
																					(
																						SELECT Id,
																							Product2.Name,
																							LineItemNumber,
																							FORMAT( StartDate ) fStartDate,
																							FORMAT( EndDate ) fEndDate,
																							SubscribedDuration__c,
																							SubscribedMileage__c,
																							Quantity,
																							Quantity__c
																						FROM ContractLineItems
																					)
																				FROM ServiceContract
																				WHERE Asset__c =: strAssetId
																				AND AccountId =: strAccountId
																				AND ContractStatus__c =: 'A'
																			] );
		
		return lstServiceContracts;
	}
	
	/**
	* @Method: 		getAlerts
	* @param: 		Set<Id> setAppointmentIds
	* @Description: Returns an object with hasAlert1 and hasAlert2 attributes to indicate if the Asset has alerts related
	*				to renewal period or if has more than N visit registered in the last X years, 
	*				base on ApvHeaderRenewalPeriods__mdt and ApvHeaderAPVVisits__mdt respectively.
	* @author 		Manuel Medina - 24062019
	*/
	public static void getAlerts( Set<Id> setAppointmentIds ){
		blnIsMassive														= true;
		Map<String, Object> mapResponse										= new Map<String, Object>();

		getInitData( setAppointmentIds );

		for( Id idAppointment : setAppointmentIds ){
			JSONGenerator jsRequest											= JSON.createGenerator( true );
			jsRequest.writeStartObject();
			jsRequest.writeStringField( 'strCurrentAppointmentId', idAppointment );
			jsRequest.writeStringField( 'strCountry', String.isNotBlank( mapAppointmentById.get( idAppointment ).Asset__r.Country__c ) ? mapAppointmentById.get( idAppointment ).Asset__r.Country__c : '' );
			jsRequest.writeStringField( 'strBrand', String.isNotBlank( mapAppointmentById.get( idAppointment ).Asset__r.Brand__c ) ? mapAppointmentById.get( idAppointment ).Asset__r.Brand__c : '' );
			jsRequest.writeStringField( 'strType', String.isNotBlank( mapAppointmentById.get( idAppointment ).Asset__r.AssetType__c ) ? mapAppointmentById.get( idAppointment ).Asset__r.AssetType__c : '' ); 
			jsRequest.writeEndObject();

			getAlerts( jsRequest.getAsString() );
		}

		updateAppointmentIcons( setAppointmentIds );
	}

	/**
	* @Method: 		updateAppointmentIcons
	* @param: 		Set<Id> setAppointmentIds
	* @Description:	Updates WorkshopAppointment__c.TECH_InfoIconsCode__c based on alerts process.
	* @author 		Manuel Medina - 01072019
	*/
	public static void updateAppointmentIcons( Set<Id> setAppointmentIds ){
		List<WorkshopAppointment__c> lstAppointments						= new List<WorkshopAppointment__c>();

		for( Id idAppointment : setAppointmentIds ){
			WorkshopAppointment__c objAppointment							= new WorkshopAppointment__c();
			objAppointment.Id												= idAppointment;
			objAppointment.TECH_InfoIconsCode__c							= String.join( mapAlertsByAppointmentId.get( idAppointment ), '' );

			lstAppointments.add( objAppointment );
		}

		//TODO: Add byPass to avoid trigger execution from this process.

		update lstAppointments;
	}

	/**
	* @Method: 		getAlerts
	* @param: 		String strRequest
	* @Description: Returns an object with hasAlert1 and hasAlert2 attributes to indicate if the Asset has alerts related
	*				to renewal period or if has more than N visit registered in the last X years, 
	*				base on ApvHeaderRenewalPeriods__mdt and ApvHeaderAPVVisits__mdt respectively.
	* @author 		Manuel Medina - 28052018
	*/
	@AuraEnabled
	public static Map<String, Object> getAlerts( String strRequest ){
		Map<String, Object> mapRequest										= new Map<String, Object>( ( Map<String, Object> ) JSON.deserializeUntyped( strRequest ) );
		Map<String, Object> mapResponse										= new Map<String, Object>{
																				'hasError'		=> false,
																				'ERROR'			=> '',
																				'REQUEST'		=> mapRequest,
																				'hasAlert1'		=> false,
																				'hasAlert2'		=> false,
																				'hasAlert3'		=> false,
																				'alert1Tooltip'	=> System.Label.AfterSalesVehicleBetweenRenewalPeriod,
																				'alert3Tooltip'	=> '',
																				'isReturn'		=> false
																			};
		try{
			Id idAppointment												= Id.valueOf( String.valueOf( mapRequest.get( 'strCurrentAppointmentId' ) ) );
			String strCountry												= mapRequest.containsKey( 'strCountry' ) ? String.valueOf( mapRequest.get( 'strCountry' ) ) : '';
			String strBrand													= mapRequest.containsKey( 'strBrand' ) ? String.valueOf( mapRequest.get( 'strBrand' ) ) : '';
			String strType													= mapRequest.containsKey( 'strType' ) ? String.valueOf( mapRequest.get( 'strType' ) ) : '';

			if( !blnIsMassive ){
				getInitData( new Set<Id>{ idAppointment }, strCountry, strBrand, strType );
			}

			Id idAsset														= mapAppointmentById.get( idAppointment ).Asset__c;
			Date dtWarrantyDate												= mapAppointmentById.get( idAppointment ).Asset__r.WarrantyEndDate__c;
			Date dtMaintenanceDate											= mapAppointmentById.get( idAppointment ).Asset__r.NextMaintenanceDate__c;
			Date dtProductionDate											= mapAppointmentById.get( idAppointment ).Asset__r.ProductionDate__c;
			Date dtFirstRegistration										= mapAppointmentById.get( idAppointment ).Asset__r.FirstRegistrationDate__c;
			
			List<ApvHeaderRenewalPeriods__mdt> lstMTDRenewals				= new List<ApvHeaderRenewalPeriods__mdt>{ ( ApvHeaderRenewalPeriods__mdt ) mapRenewalPeriodByKey.get( GlobalSettingsUtil.getCustomMetadataKey( strCountry, strBrand, strType ) ) };
			List<ApvHeaderAPVWorkshopVisits__mdt> lstMTDWorkshopVisits		= new List<ApvHeaderAPVWorkshopVisits__mdt>{ ( ApvHeaderAPVWorkshopVisits__mdt ) mapWorkshopVisitByKey.get( GlobalSettingsUtil.getCustomMetadataKey( strCountry, strBrand, '' ) ) };
			List<ApvHeaderMaintenanceThresholds__mdt> lstMTDMaintenances	= new List<ApvHeaderMaintenanceThresholds__mdt>{ ( ApvHeaderMaintenanceThresholds__mdt ) mapMaintenanceThresholdByKey.get( GlobalSettingsUtil.getCustomMetadataKey( strCountry, strBrand, '' ) ) };
			
			mapResponse														= addAlert(
																				idAppointment,
																				'isReturn',
																				mapHasAppointmentsByAssetId.get( idAsset ),
																				0
																			);

			if( !lstMTDWorkshopVisits.isEmpty() && mapAppointmentById.get( idAppointment ).Asset__r.OrderId__c != null ){
				mapResponse													= addAlert(
																				idAppointment,
																				'hasAlert3',
																				mapAppointmentById.get( idAppointment ).Asset__r.OrderId__r.CompletedSaleDate__c.daysBetween( System.Today() ) <= lstMTDWorkshopVisits.get( 0 ).DaysBeforeFirstVisit__c,
																				1
																			);
				
				mapResponse.put( 'alert3Tooltip', System.Label.AfterSalesDeliveryFirstVisitTooltip.replace( '{0}', String.valueOf( System.Math.floor( lstMTDWorkshopVisits.get( 0 ).DaysBeforeFirstVisit__c / 30 ) ) ) );
			}

			if( !lstMTDRenewals.isEmpty() && dtFirstRegistration != null ){
				mapResponse													= addAlert(
																				idAppointment,
																				'hasAlert1',
																				lstMTDRenewals.get( 0 ).From__c <= dtFirstRegistration.daysBetween( System.Today() ) && lstMTDRenewals.get( 0 ).To__c >= dtFirstRegistration.daysBetween( System.Today() ),
																				2
																			);
			}
			
			if( !lstMTDMaintenances.isEmpty() && dtProductionDate != null && dtProductionDate.daysBetween( System.today() ) >= lstMTDMaintenances.get( 0 ).VehicleAge__c ){
				mapResponse													= addAlert(
																				idAppointment,
																				'oldVehicle',
																				true,
																				3
																			);

				mapResponse.put( 'oldVehicle_referenceValue', String.valueOf( lstMTDMaintenances.get( 0 ).VehicleAge__c ) );
			}
			
			Map<String, String> mapClassNameByParam							= new Map<String, String>( getHighlightedIconColors( strCountry, strBrand, dtWarrantyDate, dtMaintenanceDate ) );

			for( String strKey : mapClassNameByParam.keySet() ){
				mapResponse.put( strKey, mapClassNameByParam.get( strKey ) );
			}

			if( !blnIsMassive ){
				updateAppointmentIcons( new Set<Id>{ idAppointment } );
			}

			return mapResponse;
			
		}catch( Exception e ){
			return manageException( e );
		}
	}

	/**
	* @Method: 		addAlert
	* @param: 		Id idAppointment
	* @param: 		String strAlert
	* @param: 		Boolean blnAlertStatus
	* @param: 		Integer intPosition
	* @Description:	Adds a new alert to individual appointment response and global mapAlertsByAppointmentId.
	* @author 		Manuel Medina - 01082019
	*/
	public static Map<String, Object> addAlert( Id idAppointment, String strAlert, Boolean blnAlertStatus, Integer intPosition ){
		mapResponse.put( strAlert, blnAlertStatus );
		mapAlertsByAppointmentId.get( idAppointment ).set( intPosition, mapBinaryValueByBoolean.get( blnAlertStatus ) );

		return mapResponse;
	}
	
	/**
	* @Method: 		getHighlightedIconColors
	* @param: 		String strCountry
	* @param: 		String strBrand
	* @param: 		Date dtWarrantyDate
	* @param: 		Date dtMaintenanceDate
	* @Description: Returns CSS class complement name to {!v.warrantyColor} and {!v.maintenanceColor} attributes
	*				based on ApvHeaderWarrantyThresholds__mdt and ApvHeaderMaintenanceThresholds__mdt respectively.
	* @author 		Manuel Medina - 23052018
	*/
	public static Map<String, String> getHighlightedIconColors( String strCountry, String strBrand, Date dtWarrantyDate, Date dtMaintenanceDate ){
		Map<String, String> mapClassNameByParam								= new Map<String, String>{
																				'warrantyColor'				=> '',
																				'maintenanceColor'			=> '',
																				'closeToWarrantyEndDate'	=> 'false'
																			};

		List<ApvHeaderWarrantyThresholds__mdt> lstMTDWarranties				= new List<ApvHeaderWarrantyThresholds__mdt>{ ( ApvHeaderWarrantyThresholds__mdt ) mapWarrantyThresholdByKey.get( GlobalSettingsUtil.getCustomMetadataKey( strCountry, strBrand, '' ) ) };
		List<ApvHeaderMaintenanceThresholds__mdt> lstMTDMaintenances		= new List<ApvHeaderMaintenanceThresholds__mdt>{ ( ApvHeaderMaintenanceThresholds__mdt ) mapMaintenanceThresholdByKey.get( GlobalSettingsUtil.getCustomMetadataKey( strCountry, strBrand, '' ) ) };

		if( !lstMTDWarranties.isEmpty() && dtWarrantyDate != null ){
			mapClassNameByParam												= validateDate( mapClassNameByParam, 'warrantyColor', lstMTDWarranties.get( 0 ), dtWarrantyDate );
			
			if( lstMTDWarranties.get( 0 ).FromDays__c <= System.today().daysBetween( dtWarrantyDate ) && lstMTDWarranties.get( 0 ).ToDays__c >= System.today().daysBetween( dtWarrantyDate ) ){
				mapClassNameByParam.put( 'closeToWarrantyEndDate', 'true' );
			}
		}
		
		if( !lstMTDMaintenances.isEmpty() && dtMaintenanceDate != null ){
			mapClassNameByParam												= validateDate( mapClassNameByParam, 'maintenanceColor', lstMTDMaintenances.get( 0 ), dtMaintenanceDate );
		}
		
		return mapClassNameByParam;
	}

	/**
	* @Method: 		validateDate
	* @param: 		Map<String, String> mapClassNameByParam
	* @param: 		String strAttribute
	* @param: 		SObject sObjMTDRecord
	* @param: 		Date dtDateToValidate
	* @Description: Validates each limit based on given Custom Medatada Record and date.
	* @author 		Manuel Medina - 28052018
	*/
	public static Map<String, String> validateDate( Map<String, String> mapClassNameByParam, String strAttribute, SObject sObjMTDRecord, Date dtDateToValidate ){
		if( Integer.valueOf( sObjMTDRecord.get( 'RedOrangeLimit__c' ) ) >= System.today().daysBetween( dtDateToValidate ) ){
			mapClassNameByParam.put( strAttribute, 'error' );
			
		}else if( Integer.valueOf( sObjMTDRecord.get( 'RedOrangeLimit__c' ) ) < System.today().daysBetween( dtDateToValidate ) && Integer.valueOf( sObjMTDRecord.get( 'OrangeGreenLimit__c' ) ) >= System.today().daysBetween( dtDateToValidate ) ){
			mapClassNameByParam.put( strAttribute, 'warning' );
			
		}else if( Integer.valueOf( sObjMTDRecord.get( 'OrangeGreenLimit__c' ) ) < System.today().daysBetween( dtDateToValidate ) ){
			mapClassNameByParam.put( strAttribute, 'success' );
		}
		
		return mapClassNameByParam;
	}

	public class WrapperVehicleProperties {
		@AuraEnabled
		public List<ServiceContract> lstServiceContracts					{get; set;}
		
		@AuraEnabled 
		public AccountContactAssetRelation__c owner							{get; set;}

		@AuraEnabled
		public AccountContactAssetRelation__c keeper						{get; set;}
		
		@AuraEnabled 
		public Boolean blnIsWorkshopReturn									{get; set;}

		@AuraEnabled 
		public String strOwnerIdDMS											{get; set;}

		@AuraEnabled 
		public String strKeeperIdDMS										{get; set;}

		public WrapperVehicleProperties(){
			this.owner	  													= new AccountContactAssetRelation__c();
			this.keeper	 													= new AccountContactAssetRelation__c();
			this.blnIsWorkshopReturn										= false;
		}
	}
	
	/**
	* @Method: 		getVINInfoFromERECA
	* @param: 		String strVIN
	* @param: 		String strBrand
	* @Description:	Get VIN info from ERECA via webservice.
	* @author 		Manuel Medina - 13072018
	*/
	@AuraEnabled
	public static Map<String, Object> getVINInfoFromERECA( String strVIN, String strBrand ){
		Map<String, Object> mapResponse										= new Map<String, Object>{
																				'hasError'		=> false,
																				'ERROR'			=> '',
																				'isSameBrand'	=> false,
																				'result'		=> ''
																			};
		
		try{
			List<Account> lstDealers										= new List<Account>();
			lstDealers														= [SELECT Id,
																					Brand__c
																				FROM Account
																				WHERE Id IN (
																					SELECT AccountId
																					FROM User
																					WHERE Id =: System.UserInfo.getUserId()
																				)
																				LIMIT 1
																			];
																			
			if( !lstDealers.isEmpty() ){
				mapResponse.put( 'isSameBrand', String.isNotBlank( lstDealers.get( 0 ).Brand__c ) ? lstDealers.get( 0 ).Brand__c.equals( strBrand ) : false  );
			}
																			
			Map<String, String> mapColorByStatus							= new Map<String, String>();
																
			List<APVHeaderERECACampaignsStatusColors__mdt> lstStatusColor	= new List<APVHeaderERECACampaignsStatusColors__mdt>( [
																				SELECT Id,
																					Status__c,
																					Color__c
																				FROM APVHeaderERECACampaignsStatusColors__mdt
																			] );
																			
			for( APVHeaderERECACampaignsStatusColors__mdt mdtCampaign : lstStatusColor ){
				mapColorByStatus.put( mdtCampaign.Status__c, mdtCampaign.Color__c );
			}
			
			Map<String, Map<String, Object>> mapERECAAttributesByName		= new Map<String, Map<String, Object>>(
																				GlobalSettingsUtil.getGlobalSettingAttributes(
																					new Set<String>{ 'ERECA' },
																					new Set<String>{ 'Endpoint', 'XClientSecret', 'XSourceSystem', 'XSourceUser', 'ClientCertificateName' }
																				)
																			);
			
			strVIN															= strVIN.toUpperCase();
			
			HttpRequest req													= new HttpRequest();
			req.setEndpoint( String.valueOf( mapERECAAttributesByName.get( 'ERECA' ).get( 'Endpoint' ) ).replace( '{strVIN}', strVIN ).replace( '{strBrand}', ( strBrand.equals( 'DS' ) ? 'AC' : strBrand ) ) );
			req.setMethod( 'GET' );
			req.setClientCertificateName( String.valueOf( mapERECAAttributesByName.get( 'ERECA' ).get( 'ClientCertificateName' ) ) );
			req.setHeader( 'Content-Type', 'application/json' );
			req.setHeader( 'X-SourceSystem', String.valueOf( mapERECAAttributesByName.get( 'ERECA' ).get( 'XSourceSystem' ) ) );
			req.setHeader( 'X-SourceUser', String.valueOf( mapERECAAttributesByName.get( 'ERECA' ).get( 'XSourceUser' ) ) );
			req.setHeader( 'X-Timestamp', System.now().format( 'yyyy-MM-dd' ) + 'T' + System.now().format( 'hh:mm:ss' ) );
			req.setHeader( 'X-ClientSecret', String.valueOf( mapERECAAttributesByName.get( 'ERECA' ).get( 'XClientSecret' ) ) );
			req.setHeader( 'Accept-Language', UserInfo.getLanguage() );
			req.setTimeout( 120000 );
			
			Http http														= new Http();
			HTTPResponse res												= http.send( req );
			
			if( res.getStatusCode() != 200 ){
				throw new APVException( String.valueOf( res.getStatusCode() ) + ' ' + res.getStatus() );
			}
			
			String strResponse												= res.getBody();
			
			List<Object> lstCampaigns										= ( List<Object> ) JSON.deserializeUntyped( strResponse );
			for( Integer i=0; i<lstCampaigns.size(); i++ ){
				Map<String, Object> mapCampaignValuesByAttribute			= ( Map<String, Object> ) lstCampaigns.get( i );
				String strStatusValue										= String.valueOf( mapCampaignValuesByAttribute.get( 'status' ) != null ? mapCampaignValuesByAttribute.get( 'status' ) : '' );
				mapCampaignValuesByAttribute.put( 'statusColor', strStatusValue.replace( strStatusValue, mapColorByStatus.containsKey( strStatusValue ) ?  mapColorByStatus.get( strStatusValue ) : strStatusValue ) );
				lstCampaigns.set( i, mapCampaignValuesByAttribute );
			}
			
			mapResponse.put( 'result', lstCampaigns );
			
			return mapResponse;
			
		}catch( APVException e ){
			return manageException( e );
			
		}catch( Exception e ){
			return manageException( e );
		}
	}
	
	/**
	* @Method: 		allowOpportunities
	* @param: 		String strRequest
	* @Description:	Validates if it's possible to create opportunities when the warranty its near to expire.
	* @author 		Manuel Medina - 23072018
	*/
	@AuraEnabled
	public static Map<String, Object> allowOpportunities( String strRequest ){
		Map<String, Object> mapRequest										= new Map<String, Object>( ( Map<String, Object> ) JSON.deserializeUntyped( strRequest ) );
		Map<String, Object> mapResponse										= new Map<String, Object>{
																				'hasError'		=> false,
																				'ERROR'			=> '',
																				'REQUEST'		=> mapRequest,
																				'warrantyOpp'	=> false,
																				'maintOpp'		=> false
																			};
																			
		try{
			List<Opportunity> lstOpportunities								= [SELECT Id
																				FROM Opportunity
																				WHERE IsClosed = false
																				AND AccountId =: String.valueOf( mapRequest.get( 'strAccountId' ) )
																				AND VINOwnedVehicle__c =: String.valueOf( mapRequest.get( 'strVIN' ) )
																				AND LeadRequestType__c IN ( '100', '101' )
																			];
			if( lstOpportunities.isEmpty() ){
				ApvHeaderWarrantyThresholds__mdt mdtWarranty				= [SELECT Id,
																					Brand__c,
																					Country__c,
																					VehicleAgeFrom__c,
																					VehicleAgeTo__c,
																					SecondaryFromDays__c,
																					SecondaryToDays__c
																				FROM ApvHeaderWarrantyThresholds__mdt
																				WHERE DeveloperName =: GlobalSettingsUtil.getCustomMetadataKey( new List<String>{ String.valueOf( mapRequest.get( 'strCountry' ) ), String.valueOf( mapRequest.get( 'strBrand' ) ) } )
																				LIMIT 1
																			];
																					
				ApvHeaderMaintenanceThresholds__mdt mdtMaintenance			= [SELECT Id,
																					Brand__c,
																					Country__c,
																					PurchasedFrom__c,
																					PurchasedTo__c
																				FROM ApvHeaderMaintenanceThresholds__mdt
																				WHERE DeveloperName =: GlobalSettingsUtil.getCustomMetadataKey( new List<String>{ String.valueOf( mapRequest.get( 'strCountry' ) ), String.valueOf( mapRequest.get( 'strBrand' ) ) } )
																				LIMIT 1
																			];
				
				Date dtPurchase												= mapRequest.get( 'strPurchaseDate' ) != null ? Date.valueOf( String.valueOf( mapRequest.get( 'strPurchaseDate' ) ) ) : null;
				Date dtWarrantyStart										= mapRequest.get( 'strWarrantyStartDate' ) != null ? Date.valueOf( String.valueOf( mapRequest.get( 'strWarrantyStartDate' ) ) ) : null;
				Date dtWarrantyEnd											= mapRequest.get( 'strWarrantyEndDate' ) != null ? Date.valueOf( String.valueOf( mapRequest.get( 'strWarrantyEndDate' ) ) ) : null;
				Date dtLastMaintenance										= mapRequest.get( 'strLastMaintenanceDate' ) != null ? Date.valueOf( String.valueOf( mapRequest.get( 'strLastMaintenanceDate' ) ) ) : null;
				
				if(
					dtLastMaintenance == null &&
					dtPurchase != null &&
					mdtMaintenance.PurchasedFrom__c <= dtPurchase.daysBetween( System.today() ) &&
					dtPurchase.daysBetween( System.today() ) <= mdtMaintenance.PurchasedTo__c
				){
					mapResponse.put( 'warrantyOpp', true );
					mapResponse.put( 'maintOpp', true );
				
				}else if(
					System.today().daysBetween( dtWarrantyEnd ) >= mdtWarranty.SecondaryFromDays__c &&
					System.today().daysBetween( dtWarrantyEnd ) <= mdtWarranty.SecondaryToDays__c && (
						dtPurchase.daysBetween( System.today() ) > mdtMaintenance.PurchasedTo__c ||
						dtLastMaintenance != null
					)
				){
					mapResponse.put( 'warrantyOpp', true );
					mapResponse.put( 'maintOpp', false );
				}
			}else{
				mapResponse.put( 'warrantyOpp', false );
				mapResponse.put( 'maintOpp', false );
			}
		
			return mapResponse;
		
		}catch( Exception e ){
			return manageException( e );
		}
	}
	
	/**
	* @Method: 		createOpportunities
	* @param: 		String strRequest
	* @Description:	Create opportunities.
	* @author 		Manuel Medina - 20072018
	*/
	@AuraEnabled
	public static Map<String, Object> createOpportunities( String strRequest ){
		Map<String, Object> mapRequest										= new Map<String, Object>( ( Map<String, Object> ) JSON.deserializeUntyped( strRequest ) );
		Map<String, Object> mapResponse										= new Map<String, Object>{
																				'hasError'		=> false,
																				'ERROR'			=> '',
																				'REQUEST'		=> mapRequest
																			};
																			
		try{
			Opportunity objOpportunity										= new Opportunity();
			Integer intDaysToAdd											= 0;
			Date dtWarrantyEnd												= Date.valueOf( String.valueOf( mapRequest.get( 'strWarrantyEndDate' ) ) );
			
			if( Boolean.valueOf( mapRequest.get( 'blnWarratyOpp' ) ) && Boolean.valueOf( mapRequest.get( 'blnMaintOpp' ) ) ){
				objOpportunity.Name											= System.Label.AfterSalesHeaderMaintenanceWarrantyOpp;
				objOpportunity.LeadRequestType__c							= '100';
				
			}else if( Boolean.valueOf( mapRequest.get( 'blnWarratyOpp' ) ) ){
				objOpportunity.Name											= System.Label.AfterSalesHeaderWarrantyOpp;
				objOpportunity.LeadRequestType__c							= '101';
			}
			
			objOpportunity.RecordTypeId										= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get( 'Opportunity_Record_Type' ).getRecordTypeId();
			objOpportunity.StageName										= '1';
			objOpportunity.AccountId										= String.valueOf( mapRequest.get( 'strAccountId' ) );
			objOpportunity.Type												= System.Label.AfterSalesHeaderOpportunityType;
			objOpportunity.Activity__c										= System.Label.AfterSalesHeaderOpportunityActivity;
			objOpportunity.CloseDate										= dtWarrantyEnd.addDays( intDaysToAdd );
			objOpportunity.CurrencyIsoCode									= String.valueOf( mapRequest.get( 'strCurrencyIsoCode' ) );
			objOpportunity.Brand__c											= String.valueOf( mapRequest.get( 'strBrand' ) );
			objOpportunity.Description										= System.Label.AfterSalesOpportunityDescription.replace( '{0}', objOpportunity.Name ).replace( '{1}', dtWarrantyEnd.format() ).replace( '{2}', mapRequest.get( 'strLastKnownRegNumber' ) != null ? String.valueOf( mapRequest.get( 'strLastKnownRegNumber' ) ) : '' );
			objOpportunity.OwnerId											= assignOpportunity(  String.valueOf( mapRequest.get( 'strCountry' ) ), String.valueOf( mapRequest.get( 'strBrand' ) ) );
			objOpportunity.VINOwnedVehicle__c								= String.valueOf( mapRequest.get( 'strVIN' ) );
			
			insert objOpportunity;
			
			mapResponse.put( 'opp', objOpportunity );

			return mapResponse;
			
		}catch( DMLException e ){
			return manageException( e );
			
		}catch( Exception e ){
			return manageException( e );
		}
	}
	
	/**
	* @Method: 		assignOpportunity
	* @param: 		String strCountry
	* @param: 		String strBrand
	* @Description:	Assign opportunity to dealer Sales Manager or queue.
	* @author 		Manuel Medina - 31072018
	*/
	public static Id assignOpportunity( String strCountry, String strBrand ){
		Map<Id, Integer> mapCurrentSettingsByUserId							= new Map<Id, Integer>();
		List<Account> lstDealerAccounts										= new List<Account>();
		lstDealerAccounts													= [SELECT Id,
																					TECH_SalesManager__c
																				FROM Account
																				WHERE Id IN (
																					SELECT AccountId
																					FROM User
																					WHERE Id =: System.UserInfo.getUserId()
																				)
																				LIMIT 1
																			];
																			
		if( !lstDealerAccounts.isEmpty() && String.isNotBlank( lstDealerAccounts.get( 0 ).TECH_SalesManager__c ) ){
			return lstDealerAccounts.get( 0 ).TECH_SalesManager__c;
		}
		
		APVHeaderOpportunitySettings__mdt mdtOpportunitySettings			= new APVHeaderOpportunitySettings__mdt();
		mdtOpportunitySettings												= [SELECT Id,
																					Country__c,
																					Brand__c,
																					QueueName__c
																				FROM APVHeaderOpportunitySettings__mdt
																				WHERE DeveloperName =: GlobalSettingsUtil.getCustomMetadataKey( new List<String>{ strCountry, strBrand } )
																			];
																			
		List<User> lstQueueUsers											= new List<User>( [
																				SELECT Id
																				FROM User
																				WHERE IsActive = true
																				AND Id IN (
																					SELECT UserOrGroupId
																					FROM GroupMember
																					WHERE Group.DeveloperName =: mdtOpportunitySettings.QueueName__c
																				)
																			] );
																			
		for( User objUser : lstQueueUsers ){
			mapCurrentSettingsByUserId.put( objUser.Id, 0 );
		}
																			
		List<AggregateResult> lstCurrentOppsSettings						= new List<AggregateResult>( [
																				SELECT COUNT( Id ) TotalOppsAssigned,
																					OwnerId
																				FROM Opportunity
																				WHERE LeadRequestType__c IN ( '100', '101' )
																				AND IsClosed = false
																				AND OwnerId IN: lstQueueUsers
																				GROUP BY OwnerId
																				ORDER BY COUNT( Id ) ASC
																			] );
																			
		if( lstCurrentOppsSettings.isEmpty() && !lstQueueUsers.isEmpty() ){
			return lstQueueUsers.get( 0 ).Id;
		}
		
		for( AggregateResult aggCurrentSettings : lstCurrentOppsSettings ){
			mapCurrentSettingsByUserId.put( Id.valueOf( String.valueOf( aggCurrentSettings.get( 'OwnerId' ) ) ), Integer.valueOf( aggCurrentSettings.get( 'TotalOppsAssigned' ) ) );
		}
		
		Id idUserWithLowestSettings											= System.UserInfo.getUserId();
		Integer intLowestAssigment											= -1;
		
		for( User objUser : lstQueueUsers ){
			if( intLowestAssigment == -1 ){
				intLowestAssigment											= mapCurrentSettingsByUserId.get( objUser.Id );
				idUserWithLowestSettings									= objUser.Id;
				
			}else if( mapCurrentSettingsByUserId.get( objUser.Id ) < intLowestAssigment ){
				intLowestAssigment											= mapCurrentSettingsByUserId.get( objUser.Id );
				idUserWithLowestSettings									= objUser.Id;
			}
		}
		
		return idUserWithLowestSettings;
	}
	
	/**
	* @Method: 		createVehicleEvent
	* @param: 		String strRequest
	* @Description:	Create a new vehicle event.
	* @author 		Manuel Medina - 20072018
	*/
	@AuraEnabled 
	public static Map<String, Object> createVehicleEvent( String strRequest ){
		Map<String, Object> mapRequest										= new Map<String, Object>( ( Map<String, Object> ) JSON.deserializeUntyped( strRequest ) );
		Map<String, Object> mapResponse										= new Map<String, Object>{
																				'hasError'		=> false,
																				'ERROR'			=> '',
																				'REQUEST'		=> mapRequest
																			};
																			
		try{
			VehicleEvent__x objVehicleEvent									= new VehicleEvent__x();
			objVehicleEvent.assetid__c										= String.valueOf( mapRequest.get( 'strAssetId' ) );
			objVehicleEvent.realmileage__c									= Double.valueOf( mapRequest.get( 'strRealMileage' ) );
			objVehicleEvent.realmileagesource__c							= 'APV';
			objVehicleEvent.realmileagedate__c								= System.today();
			objVehicleEvent.pdvid__c										= [SELECT AccountId
																				FROM User
																				WHERE Id =: System.UserInfo.getUserId()
																				LIMIT 1
																			].AccountId;
			Database.SaveResult dbSaveResult;
			if( !Test.isRunningTest() ){
				dbSaveResult												= Database.insertImmediate( objVehicleEvent );
			}
			
			if( dbSaveResult != null && !dbSaveResult.isSuccess () ){
				String strDBError											= '';
				
				for( Database.Error dbError : dbSaveResult.getErrors() ){
					strDBError												+= dbError.getFields() + ' ' + dbError.getMessage() + '\n';
				}
				
				throw new APVException( strDBError );
			}
			
			mapResponse.put( 'result', objVehicleEvent );
			
			AfterSalesVehicleEventHandler.validateVehicleEventRules( new Map<String, VehicleEvent__x>{ objVehicleEvent.Id => objVehicleEvent } );

			return mapResponse;
			
		}catch( APVException e ){
			return manageException( e );
			
		}catch( DMLException e ){
			return manageException( e );
			
		}catch( Exception e ){
			return manageException( e );
		}
	}

	/**
	* @Method: 		getDMSData
	* @param: 		String strRequest
	* @Description:	Get DMS customer data given the accountId.
	* @author 		Manuel Medina - 20022019
	*/
	@AuraEnabled
	public static Map<String, Object> getDMSData( String strRequest ){
		Map<String, Object> mapRequest										= new Map<String, Object>( ( Map<String, Object> ) JSON.deserializeUntyped( strRequest ) );
		Map<String, Object> mapResponse										= new Map<String, Object>{
																				'hasError'		=> false,
																				'ERROR'			=> '',
																				'REQUEST'		=> mapRequest
																			};
																			
		try{
			Id idAccount													= Id.valueOf( String.valueOf( mapRequest.get( 'strAccountId' ) ) );
			String strIdDMSType												= String.valueOf( mapRequest.get( 'strIdDMSType' ) );

			Map<Id, AccountExtRef__c> mapAccountExtRefByAccountId			= new Map<Id, AccountExtRef__c>( DMSCustomerDataController.getRelatedAccExtRef( new Set<Id>{ idAccount } ) );
			
			mapResponse.put( strIdDMSType, mapAccountExtRefByAccountId.containsKey( idAccount ) ? mapAccountExtRefByAccountId.get( idAccount ).ExternalId__c : null );

			return mapResponse;

		}catch( Exception e ){
			return manageException( e );
		}
	}

	@AuraEnabled
	public static Map<String,String> DMSWakeUp(String sRecordId_A, String sRecordId_B){
		return dmsCallOutsController.DMSWakeUpbyCORS(sRecordId_A,sRecordId_B);
	}

	@AuraEnabled
	public static boolean DMSWakeUpbyServer(String sRecordId){
		return dmsCallOutsController.DMSWakeUpbyServer(sRecordId);
	}

	/**
	* @Method: 		manageException
	* @param: 		APVException e
	* @Description:	Updates mapResponse with error details.
	* @author 		Manuel Medina - 14062019
	*/
	public static Map<String, Object> manageException( APVException e ){
		mapResponse.put( 'hasError', true );
		mapResponse.put(
			'ERROR',
			new Map<String, Object>{
				'cause'				=> e.getCause(),
				'lineNumber'		=> e.getLineNumber(),
				'message'			=> e.getMessage(),
				'stackTraceString'	=> e.getStackTraceString(),
				'typeName'			=> e.getTypeName()
			}
		);

		return mapResponse;
	}

	/**
	* @Method: 		manageException
	* @param: 		DMLException e
	* @Description:	Updates mapResponse with error details.
	* @author 		Manuel Medina - 14062019
	*/
	public static Map<String, Object> manageException( DMLException e ){
		mapResponse.put( 'hasError', true );
		mapResponse.put(
			'ERROR',
			new Map<String, Object>{
				'DMLId'				=> e.getDmlId(0),
				'cause'				=> e.getDmlType(0),
				'DMLFieldNames'		=> e.getDmlFieldNames(0),
				'message'			=> e.getDmlMessage(0)
			}
		);

		return mapResponse;
	}

	/**
	* @Method: 		manageException
	* @param: 		Exception e
	* @Description:	Updates mapResponse with error details.
	* @author 		Manuel Medina - 14062019
	*/
	public static Map<String, Object> manageException( Exception e ){
		mapResponse.put( 'hasError', true );
		mapResponse.put(
			'ERROR',
			new Map<String, Object>{
				'cause'				=> e.getCause(),
				'lineNumber'		=> e.getLineNumber(),
				'message'			=> e.getMessage(),
				'stackTraceString'	=> e.getStackTraceString(),
				'typeName'			=> e.getTypeName()
			}
		);

		return mapResponse;
	}

	public class APVException extends Exception{}
}
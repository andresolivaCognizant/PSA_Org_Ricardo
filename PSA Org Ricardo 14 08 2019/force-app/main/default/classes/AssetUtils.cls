/*-----------------------------------------------------------------------------------------------------------//
  * Class Name    : AssetUtils
  * Project       : PSA - C1ST
  * Author        : Ruben Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
  * Date          : 04/11/2018
  * Description   : Description .....
  *
  *-----------------------------------------------------------------------------------------------------------
  *      Modification Log :
  *-----------------------------------------------------------------------------------------------------------
  *      Developer                Date                     Description    
  *	     Ruben Moreno		     11 Apr 2018			   Creation.		  
  *-----------------------------------------------------------------------------------------------------------*/
public class AssetUtils {

	private final static String OWNER_ROLE                  	= 'Owner';
	private final static String APV_MD_DEFAULT_VALUE            = 'ALL';
	private final static Map<String, ApvPredictiveMaintenanceSetting__mdt> CONFIG = getSettingsPerSubsidiary(); 
	private static final String ACCNT_ITEM_KEY_PREFIX           = Account.sObjectType.getDescribe().getKeyPrefix();
	
	public static Boolean blnAllowChangeAccountId				= false;

    /*********************************************************************************************************
    * @Method          :   createAssetAccountRelation
    * @Author          :   xx <xx@ext.mpsa.com>
    * @Created         :   04/11/2018
    * @Description     :   This method is ......
    * @params	       :   Map<Id,Asset> : Trigger.newMap 
    * @params          :   Map<Id,Asset> : Trigger.oldMap
    * @Returns         :   void
    **********************************************************************************************************/    
	public static void createAssetAccountRelation(List<Asset> lNewAsset){

		// do nothing is user has a bypass assigned
        if(!PAD.canTrigger('AllObjects_All_Interfaces')) {
			return;
		}

		List<AccountContactAssetRelation__c> lRelationsToInsert =  new List<AccountContactAssetRelation__c>();

		for(Asset oAsset : lNewAsset){
			if (oAsset.AccountId != null){
				System.debug('oAsset.Account.Name:'+oAsset.Account.Name);
				lRelationsToInsert.add(
					//populate fields on creation
					new AccountContactAssetRelation__c(
						AccountId__c    = oAsset.AccountId,
						AssetId__c      = oAsset.id ,
						AccountRole__c  = OWNER_ROLE,
						TECH_AssetVIN__c                            = oAsset.VIN__c,
						TECH_AssetModel__c                          = oAsset.Name + ' ' + oAsset.Model__c,
						TECH_AssetLastKnownRegistrationNumber__c    = oAsset.LastKnownRegistrationNumber__c,
						TECH_AccountName__c                         = oAsset.Account.Name,
						TECH_AccountFiscalID__c                     = oAsset.Account.TECH_FiscalId__c + ' ' +oAsset.Account.TECH_NationalId__c,
						TECH_AccountPhone__c                    	= String.valueOf(oAsset.Account.LandlinePersonalTelephone__pc + ' ' + oAsset.Account.LandlineProfessionalTelephone__pc + ' ' + oAsset.Account.MobilePersonalTelephone__pc + ' ' + oAsset.Account.MobileProfessionalTelephone__pc + ' ' + oAsset.Account.Phone).replace( 'null', '' ).trim(),
						TECH_AccountEmail__c                    	= oAsset.Account.PersonEmail,
						TECH_AccountBillingPostalCode__c            = oAsset.Account.BillingPostalCode
						
						
					)
				);
			}
		}

		try {
			Database.insert(lRelationsToInsert);
		} catch (Exception e){
			System.debug('Exception ERROR AssetUtils.createAssetAccountRelation-->' + e.getMessage() + ' Line: '+e.getLineNumber());
		}
	}

    
    /*********************************************************************************************************
    * @Method          :   getAgeDate
    * @Author          :   xx <xx@ext.mpsa.com>
    * @Created         :   04/11/2018
    * @Description     :   This method is to get vehicle age in days from known date
    * @params	       :   Map<Id,Asset> : Trigger.newMap 
    * @params          :   Map<Id,Asset> : Trigger.oldMap
    * @Returns         :   void
    **********************************************************************************************************/       
	private static Decimal getAgeDate(Asset a) {
		Date dateKnown = a.LastMaintenanceDate__c != null ? a.LastMaintenanceDate__c : a.TECH_DebutDate__c;

		if (null != dateKnown && dateKnown < System.today()) {
			return dateKnown.daysBetween(System.today());
		}

		return 0;
	}

    /*********************************************************************************************************
    * @Method          :   getAgeKm
    * @Author          :   xx <xx@ext.mpsa.com>
    * @Created         :   04/11/2018
    * @Description     :   This method is used to get estimated current mileage
    * @params	       :   Map<Id,Asset> : Trigger.newMap 
    * @params          :   Map<Id,Asset> : Trigger.oldMap
    * @Returns         :   void
    **********************************************************************************************************/       
	private static Decimal getAgeKm(Asset a) {
		if (null != a.DailyEstimatedMileage__c) {
			if (null != a.LastMaintenanceDate__c && null!= a.LastMaintenanceMileage__c) {
				return a.LastMaintenanceMileage__c + ((a.LastMaintenanceDate__c.daysBetween(System.today())) * a.DailyEstimatedMileage__c);
			}

			if (null != a.TECH_DebutDate__c) {
				return (a.TECH_DebutDate__c.daysBetween(System.today())) * a.DailyEstimatedMileage__c;
			}
		}

		return 0;
	}
    
    /*********************************************************************************************************
    * @Method          :   calcNextManteinanceDate
    * @Author          :   xx <xx@ext.mpsa.com>
    * @Created         :   04/11/2018
    * @Description     :   This method is used to establish if next maintenance is going to be calculated is initial or cyclic
    * @params	       :   Map<Id,Asset> : Trigger.newMap 
    * @params          :   Map<Id,Asset> : Trigger.oldMap
    * @Returns         :   void
    **********************************************************************************************************/  
	private static void calcNextManteinanceDate(Asset a) {
		if (
				null != a.TECH_DebutDate__c  &&
				a.InitialStepYear__c != null &&
				a.InitialStepKm__c != null &&
				(
					null != a.LastMaintenanceDate__c ||
					getAgeDate(a) >= a.InitialStepYear__c * 365 ||
					getAgeKm(a) >= a.InitialStepKm__c
				)
		) {
			// go to calculate cyclic
			if (null != cyclicManteinanceAge(a) && null != cyclicManteinanceKm(a)) {
				a.NextMaintenanceDate__c = cyclicManteinanceAge(a) <= cyclicManteinanceKm(a) ? cyclicManteinanceAge(a) : cyclicManteinanceKm(a);
				return;
			}

			if (null != cyclicManteinanceAge(a)) {
				a.NextMaintenanceDate__c = cyclicManteinanceAge(a);
				return;
			}

			if (null != cyclicManteinanceKm(a)) {
				a.NextMaintenanceDate__c = cyclicManteinanceKm(a);
				return;
			}

		}

		if (
			null != a.TECH_DebutDate__c &&
			a.InitialStepKm__c != null &&
			a.InitialStepYear__c != null &&
			getAgeKm(a) < a.InitialStepKm__c &&
			getAgeDate(a) < a.InitialStepYear__c * 365
		) {
			if (null != initialManteinanceAge(a) && null != initialManteinanceKm(a)) {
				a.NextMaintenanceDate__c = initialManteinanceAge(a) <= initialManteinanceKm(a) ? initialManteinanceAge(a) : initialManteinanceKm(a);
				return;
			}

			if (null != initialManteinanceAge(a)) {
				a.NextMaintenanceDate__c = initialManteinanceAge(a);
				return;
			}

			if (null != cyclicManteinanceKm(a)) {
				a.NextMaintenanceDate__c = initialManteinanceKm(a);
				return;
			}
		}
	}

    /*********************************************************************************************************
    * @Method          :   cyclicManteinanceAge
    * @Author          :   xx <xx@ext.mpsa.com>
    * @Created         :   04/11/2018
    * @Description     :   This method is used to ...
    * @params	       :   Map<Id,Asset> : Trigger.newMap 
    * @params          :   Map<Id,Asset> : Trigger.oldMap
    * @Returns         :   void
    **********************************************************************************************************/     
	private static Date cyclicManteinanceAge(Asset a) {
		Date dateNext = null;
		Integer minDays = 0;

		if (null != a.CyclicStepYear__c) {
			if (null != a.LastMaintenanceDate__c) {
				dateNext = a.LastMaintenanceDate__c.addYears(a.CyclicStepYear__c.intValue());
				
			} else if( a.TECH_DebutDate__c != null ) {
				dateNext = a.TECH_DebutDate__c.addYears(a.CyclicStepYear__c.intValue());
			}

			while (dateNext < System.today()) {
				dateNext = dateNext.addYears(a.CyclicStepYear__c.intValue());
			}

			System.debug('### Next date by age: ' + dateNext);

			return dateNext;
		}

		return null;
	}

    /*********************************************************************************************************
    * @Method          :   cyclicManteinanceAge
    * @Author          :   xx <xx@ext.mpsa.com>
    * @Created         :   04/11/2018
    * @Description     :   This method is used to ...
    * @params	       :   Map<Id,Asset> : Trigger.newMap 
    * @params          :   Map<Id,Asset> : Trigger.oldMap
    * @Returns         :   void
    **********************************************************************************************************/      
	private static Date cyclicManteinanceKm(Asset a) {
		System.debug('Current mileage ' + a.EstimatedCurrentMileage__c);
		
		Date dateNext = null;
		if (null != a.DailyEstimatedMileage__c) {
			Decimal todayMileage = a.TECH_DebutDate__c.daysBetween(System.today()) * a.DailyEstimatedMileage__c;
			
			// expected days remaining to reach next km cycle
			Long daysLeft = 0;

			// when last manteninance date is known calculate next step
			if (null != a.LastMaintenanceMileage__c && null != a.LastMaintenanceDate__c && a.CyclicStepKm__c != null ) {
				// expected days remaining to reach next km cycle
				daysLeft = (a.CyclicStepKm__c/a.DailyEstimatedMileage__c).round(System.RoundingMode.UP);
				dateNext = a.LastMaintenanceDate__c.addDays(daysLeft.intValue());
			} else if (todayMileage != null && a.InitialStepKm__c != null && 0 < (todayMileage - a.InitialStepKm__c) && a.CyclicStepKm__c != null ){
				// additional mileage from last manteinance step
				Integer excessKm = Math.mod((todayMileage - a.InitialStepKm__c).intValue(), a.CyclicStepKm__c.intValue());
				daysLeft = ((a.CyclicStepKm__c - excessKm) / a.DailyEstimatedMileage__c).round(System.RoundingMode.UP);
				dateNext = System.today().addDays(daysLeft.intValue());

			} else if (todayMileage != null){

				dateNext = initialManteinanceKm(a);

			}
		}

		if (null != dateNext && a.CyclicStepKm__c != null && a.DailyEstimatedMileage__c != null ) {
			// next maintenance date must be in the future
			while (dateNext < System.today()) {
				System.debug('### next date: ' + dateNext);
				System.debug('days per cicle: ' + a.CyclicStepKm__c / a.DailyEstimatedMileage__c);
				dateNext = dateNext.addDays((a.CyclicStepKm__c / a.DailyEstimatedMileage__c).round(System.RoundingMode.UP).intValue());
			}
		}

		System.debug('### Next date by km: ' + dateNext);
		return dateNext;
	}

    /*********************************************************************************************************
    * @Method          :   initialManteinanceAge
    * @Author          :   xx <xx@ext.mpsa.com>
    * @Created         :   04/11/2018
    * @Description     :   This method is used to ...
    * @params	       :   Map<Id,Asset> : Trigger.newMap 
    * @params          :   Map<Id,Asset> : Trigger.oldMap
    * @Returns         :   void
    **********************************************************************************************************/      
	private static Date initialManteinanceAge(Asset a) {
		Date dateNext = null;
		if (null != a.CyclicStepYear__c && null != a.InitialStepYear__c && a.TECH_DebutDate__c != null ) {
			dateNext = a.TECH_DebutDate__c.addYears(a.InitialStepYear__c.intValue());
			a.NextMaintenanceStep__c = 1;

			while (dateNext < System.today() && a.CyclicStepYear__c.intValue() > 0) {
				dateNext = dateNext.addYears(a.CyclicStepYear__c.intValue());
				System.debug('### initialManteinanceAge next date: ' + dateNext);
				a.NextMaintenanceStep__c += 1;
			}
		}
		return dateNext;
	}
    

    /*********************************************************************************************************
    * @Method          :   initialManteinanceKm
    * @Author          :   xx <xx@ext.mpsa.com>
    * @Created         :   04/11/2018
    * @Description     :   This method is used to ...
    * @params	       :   Map<Id,Asset> : Trigger.newMap 
    * @params          :   Map<Id,Asset> : Trigger.oldMap
    * @Returns         :   void
    **********************************************************************************************************/  
	private static Date initialManteinanceKm(Asset a) {
		Date dateNext = null;
		if (null != a.InitialStepKm__c && null != a.CyclicStepKm__c && a.TECH_DebutDate__c != null && a.DailyEstimatedMileage__c != null ) {
			dateNext = a.TECH_DebutDate__c.addDays((a.InitialStepKm__c / a.DailyEstimatedMileage__c).intValue());
			while (dateNext < System.today()) {
				dateNext = dateNext.addDays((a.CyclicStepKm__c / a.DailyEstimatedMileage__c).intValue());
			}
		}
		System.debug('Intial maintentenance date: ' + dateNext);
		return dateNext;
	}

    /*********************************************************************************************************
    * @Method          :   calcNextManteinanceStep
    * @Author          :   xx <xx@ext.mpsa.com>
    * @Created         :   04/11/2018
    * @Description     :   This method is used to ...
    * @params	       :   Map<Id,Asset> : Trigger.newMap 
    * @params          :   Map<Id,Asset> : Trigger.oldMap
    * @Returns         :   void
    **********************************************************************************************************/      
	public static void calcNextManteinanceStep(List<Asset> lstNewRows) {
		for (Asset a : lstNewRows) {
			a.NextMaintenanceStep__c = null;

			if (null != a.NextMaintenanceDate__c) {
				if (null != stepKm(a) && null != stepAge(a)) {
					a.NextMaintenanceStep__c = stepKm(a) >= stepAge(a) ? stepKm(a) : stepAge(a);
					return;
				}

				if (null != stepKm(a)) {
					a.NextMaintenanceStep__c = stepKm(a);
					return;
				}

				if (null != stepAge(a)) {
					a.NextMaintenanceStep__c = stepAge(a);
					return;
				}
			}
		}
	}

    /*********************************************************************************************************
    * @Method          :   stepKm
    * @Author          :   xx <xx@ext.mpsa.com>
    * @Created         :   04/11/2018
    * @Description     :   This method is used to ...
    * @params	       :   Map<Id,Asset> : Trigger.newMap 
    * @params          :   Map<Id,Asset> : Trigger.oldMap
    * @Returns         :   void
    **********************************************************************************************************/         
	private static Integer stepKm(Asset a) {
		if (null != a.CyclicStepKm__c && null != a.InitialStepKm__c && a.TECH_DebutDate__c != null && a.DailyEstimatedMileage__c != null && a.NextMaintenanceDate__c != null ) {
			Decimal nextKm = a.TECH_DebutDate__c.daysBetween(a.NextMaintenanceDate__c) * a.DailyEstimatedMileage__c;
			if (nextKm - a.InitialStepKm__c < 0) {
				return 1;
			} else {
				// next step (+1) should account for already done initial step (+1) 
				return ((nextKm - a.InitialStepKm__c) / a.CyclicStepKm__c).round(System.RoundingMode.FLOOR).intValue() + 1;
			}
		}
		return null;
	}

    /*********************************************************************************************************
    * @Method          :   stepAge
    * @Author          :   xx <xx@ext.mpsa.com>
    * @Created         :   04/11/2018
    * @Description     :   This method is used to ...
    * @params	       :   Map<Id,Asset> : Trigger.newMap 
    * @params          :   Map<Id,Asset> : Trigger.oldMap
    * @Returns         :   void
    **********************************************************************************************************/          
	private static Integer stepAge(Asset a) {
		if (null != a.CyclicStepYear__c && null != a.InitialStepYear__c && null != a.TECH_DebutDate__c && a.NextMaintenanceDate__c != null ) {
			if (a.NextMaintenanceDate__c <= a.TECH_DebutDate__c.addYears(a.InitialStepYear__c.intValue())) {
				return 1;
			} else {
				return ((a.TECH_DebutDate__c.addYears(a.InitialStepYear__c.intValue()).daysBetween(a.NextMaintenanceDate__c)) / (365 * a.CyclicStepYear__c)).round(System.RoundingMode.FLOOR).intValue() + 1;
			}
		}
		return null;
	}

    /*********************************************************************************************************
    * @Method          :   stepAge
    * @Author          :   xx <xx@ext.mpsa.com>
    * @Created         :   04/11/2018
    * @Description     :   This method is used to ...
    * @params	       :   Map<Id,Asset> : Trigger.newMap 
    * @params          :   Map<Id,Asset> : Trigger.oldMap
    * @Returns         :   void
    **********************************************************************************************************/     
	public class AssetQualifying implements System.Queueable {

		private final Set<Id> setIncomingAssets;
		private final Set<Id> setQualifiedAssetsIds = new Set<Id>();

		public AssetQualifying(Set<Id> assetIds) {
			this.setIncomingAssets = assetIds;
		}

		public void execute(QueueableContext context) {
			for (Asset a : [
				SELECT Id, Brand__c, Country__c, TECH_DebutDate__c, LastAPVVisitDate__c
				FROM Asset
				WHERE 
				Id IN :setIncomingAssets AND
				TECH_DebutDate__c != null
			]) {

				ApvPredictiveMaintenanceSetting__mdt s = matchingConfig(a);

				// vehicle age validation
				if (a.TECH_DebutDate__c.addMonths(s.MaxAge__c.intValue()) < System.today()) {
					continue;
				}

				// workshop activity validation
				if (
						null != a.LastAPVVisitDate__c &&
						a.LastAPVVisitDate__c.addMonths(s.MaxWorkshopActivity__c.intValue()) < System.today()
						) {
					continue;
				}

				setQualifiedAssetsIds.add(a.Id);
			}

			// chain queueable jobs in not allowed on an Apex test class
			if (!setQualifiedAssetsIds.isEmpty() && !Test.isRunningTest()) {
				// go to next job
				AssetUtils.AssetMaintenance nextJob
				= new AssetUtils.AssetMaintenance(setQualifiedAssetsIds);
				Id jobID = System.enqueueJob(nextJob);
				System.debug('Chained next maintenance job ID: ' + jobId);
			}
		}

	}

    /*********************************************************************************************************
    * @Method          :   AssetMaintenance
    * @Author          :   xx <xx@ext.mpsa.com>
    * @Created         :   04/11/2018
    * @Description     :   This method is used to ...
    * @params	       :   Map<Id,Asset> : Trigger.newMap 
    * @params          :   Map<Id,Asset> : Trigger.oldMap
    * @Returns         :   void
    **********************************************************************************************************/     
	public class AssetMaintenance implements System.Queueable {

		private final Set<Id> setQualifiedAssetsIds;
		private final List<Asset> lstAssetsToUpdate = new List<Asset>();

		public AssetMaintenance(Set<Id> assetIds) {

			this.setQualifiedAssetsIds = assetIds;
		}

		public void execute(QueueableContext context) {
			for (Asset a : [
				SELECT
					Id,
					Brand__c,
					Country__c,
					TECH_DebutDate__c,
					LastMaintenanceDate__c,
					LastMaintenanceMileage__c,
					InitialStepYear__c,
					InitialStepKm__c,
					CyclicStepYear__c,
					CyclicStepKm__c,
					DailyEstimatedMileage__c,
					EstimatedCurrentMileage__c,
					TECH_MileageRoundingBase__c
				FROM Asset
				WHERE Id IN :setQualifiedAssetsIds
			]) {
				calcNextManteinanceDate(a);
				lstAssetsToUpdate.add(a);
			}

			if (!lstAssetsToUpdate.isEmpty()) {
				calcNextManteinanceStep(lstAssetsToUpdate);
				calcNextMaintenanceMileage(lstAssetsToUpdate);

				update lstAssetsToUpdate;
			}
		}

	}

    /*********************************************************************************************************
    * @Method          :   calcNextMaintenanceMileage
    * @Author          :   xx <xx@ext.mpsa.com>
    * @Created         :   04/11/2018
    * @Description     :   This method is used to ...
    * @params	       :   Map<Id,Asset> : Trigger.newMap 
    * @params          :   Map<Id,Asset> : Trigger.oldMap
    * @Returns         :   void
    **********************************************************************************************************/   
	public static void calcNextMaintenanceMileage(List<Asset> lstA) {
		for (Asset a : lstA) {
			a.TECH_NextMaintenanceMileage__c = null;
			a.TECH_ClosestMileageStep__c = null;

			if (null != a.NextMaintenanceDate__c && null != a.TECH_MileageRoundingBase__c && a.CyclicStepKm__c != null && a.DailyEstimatedMileage__c != null && a.TECH_DebutDate__c != null && a.NextMaintenanceDate__c != null ) {
				a.TECH_NextMaintenanceMileage__c = a.DailyEstimatedMileage__c * a.TECH_DebutDate__c.daysBetween(a.NextMaintenanceDate__c);

				a.TECH_ClosestMileageStep__c = a.TECH_MileageRoundingBase__c + a.CyclicStepKm__c * ((a.TECH_NextMaintenanceMileage__c - a.TECH_MileageRoundingBase__c + a.DailyEstimatedMileage__c)/a.CyclicStepKm__c).round(System.RoundingMode.FLOOR);

			}

		}
	}
    
    /*********************************************************************************************************
    * @Method          :   callingWebhook
    * @Author          :   xx <xx@ext.mpsa.com>
    * @Created         :   04/11/2018
    * @Description     :   This method is used to ...
    * @params	       :   Map<Id,Asset> : Trigger.newMap 
    * @params          :   Map<Id,Asset> : Trigger.oldMap
    * @Returns         :   void
    **********************************************************************************************************/   
	public static void callingWebhook(Map<Id, Asset> mapOldRows, Map<Id, Asset> mapNewRows){

		List<Asset> lstAssetDMS = new List<Asset>();
		for(Asset l : mapNewRows.values()){
			if( PAD.sUserTypeCode == '1' && PAD.sUserDMS){
				//if(l.CreatedById == PAD.uCurrentUserName.Id){
				lstAssetDMS.add(l);
				//}
			}
		}
		if( !lstAssetDMS.isEmpty() ){
			SAPIWebhook.ProcessRecords(lstAssetDMS,0);
		}
	}
    
    
    /*********************************************************************************************************
    * @Method          :   setDefaultMaintenancePlan
    * @Author          :   xx <xx@ext.mpsa.com>
    * @Created         :   04/11/2018
    * @Description     :   This method is used to ...
    * @params	       :   Map<Id,Asset> : Trigger.newMap 
    * @params          :   Map<Id,Asset> : Trigger.oldMap
    * @Returns         :   void
    **********************************************************************************************************/     
	public static void setDefaultMaintenancePlan(List<Asset> lstNewRows) {
		for (Asset a : lstNewRows) {
			if(
				null == a.InitialStepYear__c ||
				null == a.InitialStepKm__c ||
				null == a.CyclicStepYear__c ||
				null == a.CyclicStepKm__c
			) {
				ApvPredictiveMaintenanceSetting__mdt d = matchingConfig(a);
				a.InitialStepYear__c    = a.InitialStepYear__c  == null ? d.InitialStepYear__c  : a.InitialStepYear__c;
				a.InitialStepKm__c      = a.InitialStepKm__c    == null ? d.InitialStepKm__c    : a.InitialStepKm__c;
				a.CyclicStepYear__c     = a.CyclicStepYear__c   == null ? d.CyclicStepYear__c   : a.CyclicStepYear__c;
				a.CyclicStepKm__c       = a.CyclicStepKm__c     == null ? d.CyclicStepKm__c     : a.CyclicStepKm__c;
			}
		}
	}

    /*********************************************************************************************************
    * @Method          :   dispatchNextMaintenanceCalc
    * @Author          :   xx <xx@ext.mpsa.com>
    * @Created         :   04/11/2018
    * @Description     :   This method is used to enroute records to the proper calculation for predictive 
    * 				   :   mileage and / or maintenance step
    * @params	       :   Map<Id,Asset> : Trigger.newMap 
    * @params          :   Map<Id,Asset> : Trigger.oldMap
    * @Returns         :   void
    **********************************************************************************************************/  
	public static void dispatchNextMaintenanceCalc(Map<Id, Asset> mapOldRows, Map<Id, Asset> mapNewRows) {
		// records which need to have predictive mileage updated
		Set<Id> setK = new Set<Id>();
		// records which need to have next maintenance step updated
		Set<Id> setM = new Set<Id>();

		// retrieve field sets from Asset sObject
		Map<String, Schema.FieldSet> fs = Asset.sObjectType.getDescribe().fieldSets.getMap();
		FieldSet fsPredictiveMileage = fs.get('PredictiveMileageTrackedFields');
		FieldSet fsNextMaintenance = fs.get('NextMaintenanceTrackedFields');

		for (Id key : mapOldRows.keySet()) {
			if (
				hasRelevantChanges(
					mapOldRows.get(key),
					mapNewRows.get(key),
					fsPredictiveMileage
				)
			) {
				setK.add(key);
				continue;
			}

			if (
				hasRelevantChanges(
					mapOldRows.get(key),
					mapNewRows.get(key),
					fsNextMaintenance
				)
			) {
				setM.add(key);
				continue;
			}
		}

		if (!setK.isEmpty() && !System.isQueueable()) {
			PredictiveMileageAsync k = new PredictiveMileageAsync(setK);
			Id jobID = System.enqueueJob(k);
		}

		if (!setM.isEmpty() && !System.isQueueable()) {
			AssetQualifying j = new AssetQualifying(setM);
			Id jobID = System.enqueueJob(j);
		}
	}

	// method to check if the value of any field in the set has changed for the
	// specified sObject
	public static Boolean hasRelevantChanges(Asset oldRec, Asset newRec, FieldSet f) {
		for (FieldSetMember m : f.getFields()) {
			if (oldRec.get(m.getFieldPath()) != newRec.get(m.getFieldPath())) {
				return true;
			}
		}
		return false;
	}

    /*********************************************************************************************************
    * @Method          :   PredictiveMileageAsync
    * @Author          :   xx <xx@ext.mpsa.com>
    * @Created         :   04/11/2018
    * @Description     :   This method is used to enroute records to the proper calculation for predictive 
    * 				   :   mileage and / or maintenance step
    * @params	       :   Map<Id,Asset> : Trigger.newMap 
    * @params          :   Map<Id,Asset> : Trigger.oldMap
    * @Returns         :   void
    **********************************************************************************************************/     
	public class PredictiveMileageAsync implements System.Queueable {
		
		// ids of vehicles that may have their daily mileage refreshed
		private final Set<Id> setAssetsIds;

		// map to store values to perform mileage calculations per asset
		private final Map<Id, AfterSalesUtils.WrapperMileageInfo> mapWrp;
		private final Map<String, APV_Mileage_Per_Energy__mdt> APV_MILEAGE_PER_ENERGY;
		private final Map<Id, Asset> mapUpd;

		// class constructor
		public PredictiveMileageAsync(Set<Id> s) {
			this.setAssetsIds = s;

			this.mapWrp = new Map<Id, AfterSalesUtils.WrapperMileageInfo>();
			this.mapUpd = new Map<Id, Asset>();
			this.APV_MILEAGE_PER_ENERGY = new Map<String, APV_Mileage_Per_Energy__mdt>();

			for (APV_Mileage_Per_Energy__mdt m : [
				SELECT Id, DeveloperName, Energy_Code__c, Daily_Estimated_Mileage__c
				FROM APV_Mileage_Per_Energy__mdt
			]) {
				this.APV_MILEAGE_PER_ENERGY.put(m.DeveloperName, m);
			}

		}

		public void execute(QueueableContext context) {
			for (Asset a : [
				SELECT
					Id,
					Brand__c,
					EnergyCode__c,
					RealMileageDate__c,
					LastAPVVisitDate__c,
					RealMileage__c,
					LastAPVVisitMileage__c,
					WarrantyBeginDate__c,
					TECH_DebutDate__c,
					FirstRegistrationDate__c
				FROM Asset
				WHERE Id IN :setAssetsIds
			]) {
				mapWrp.put(a.Id, new AfterSalesUtils.WrapperMileageInfo(a));
				AfterSalesUtils.setMileageValues(
				mapWrp.get(a.Id),
				a,
				APV_MILEAGE_PER_ENERGY
				);
				mapUpd.put(a.Id, a);
			}

			if (!mapUpd.isEmpty()) {
				update mapUpd.values();

				if (!Test.isRunningTest()) {
					AssetQualifying j = new AssetQualifying(mapUpd.keySet());
					Id jobID = System.enqueueJob(j);
					System.debug('Chained next maintenance job Id: ' + jobId);
				}
			}
		}
	}

    /*********************************************************************************************************
    * @Method          :   getSettingsPerSubsidiary
    * @Author          :   xx <xx@ext.mpsa.com>
    * @Created         :   04/11/2018
    * @Description     :   This method is ....
    * @params	       :   Map<Id,Asset> : Trigger.newMap 
    * @params          :   Map<Id,Asset> : Trigger.oldMap
    * @Returns         :   void
    **********************************************************************************************************/    
	private static Map<String, ApvPredictiveMaintenanceSetting__mdt> getSettingsPerSubsidiary() {
		Map<String, ApvPredictiveMaintenanceSetting__mdt> result = 
		new Map<String, ApvPredictiveMaintenanceSetting__mdt>();

		for (ApvPredictiveMaintenanceSetting__mdt m : [
			SELECT
				Id,
				DeveloperName,
				Brand__c,
				Country__c,
				InitialStepKm__c,
				InitialStepYear__c,
				CyclicStepKm__c,
				CyclicStepYear__c,
				MaxAge__c,
				MaxLastActivity__c,
				MaxWorkshopActivity__c
			FROM ApvPredictiveMaintenanceSetting__mdt
		]) {
			result.put(m.DeveloperName, m);
		}

		return result;
	}

    /*********************************************************************************************************
    * @Method          :   matchingConfig
    * @Author          :   xx <xx@ext.mpsa.com>
    * @Created         :   04/11/2018
    * @Description     :   This method is ....
    * @params	       :   Map<Id,Asset> : Trigger.newMap 
    * @params          :   Map<Id,Asset> : Trigger.oldMap
    * @Returns         :   void
    **********************************************************************************************************/      
	public static ApvPredictiveMaintenanceSetting__mdt matchingConfig(Asset a) {
		String  strB  = String.isNotBlank(a.Brand__c) ? a.Brand__c.trim() : null;
		String  strC  = String.isNotBlank(a.Country__c) ? a.Country__c.trim() : null;

		if (
			null != strB &&
			null != strC &&
			null != CONFIG.get(strC + strB)
		) {
			return CONFIG.get(strC + strB);
		}

		if (null != strB && null != CONFIG.get(strB)) {
			return CONFIG.get(strB);
		}

		if (null != strC && null != CONFIG.get(strC)) {
			return CONFIG.get(strC);
		}

		return CONFIG.get(APV_MD_DEFAULT_VALUE);
	}

    
	

	/**
	* @Method: 		transformFields
	* @param: 		List<Asset> lstAssets
	* @Description:	Apply transformation over specific fields.
	* @author 		Manuel Medina - 21012018
	*/
	public static void transformFields( List<Asset> lstAssets ){
		transformFields( lstAssets, null );
	}

	/**
	* @Method: 		transformFields
	* @param: 		List<Asset> lstAssets
	* @param: 		Map<Id, Asset> mapOldAssetById
	* @Description:	Apply transformation over specific fields.
	* @author 		Manuel Medina - 21012018
	*/
	public static void transformFields( List<Asset> lstAssets, Map<Id, Asset> mapOldAssetById ){
		for( Asset objAsset : lstAssets ){
			objAsset.VIN__c									= String.isNotBlank( objAsset.VIN__c ) ? objAsset.VIN__c.toUpperCase() : objAsset.VIN__c;
			
			if( mapOldAssetById != null && String.isNotBlank( objAsset.VIN__c ) && objAsset.VIN__c != mapOldAssetById.get( objAsset.Id ).VIN__c ){
				objAsset.VIS__c									= objAsset.VIN__c.right( 8 );
				
			}else if( String.isNotBlank( objAsset.VIN__c ) ){
				objAsset.VIS__c									= objAsset.VIN__c.right( 8 );
			}
		}
	}
	
	/**
	* @Method: 		validateAccountId
	* @param: 		List<Asset> lstAssets
	* @param: 		Map<Id, Asset> mapOldAssetById
	* @Description:	Validate if the Asset.AccountId field can be changed.
	* @author 		Manuel Medina - 30012019
	*/
	public static void validateAccountId( List<Asset> lstAssets, Map<Id, Asset> mapOldAssetById ){
		for( Asset objAsset : lstAssets ){
			if( !blnAllowChangeAccountId && mapOldAssetById.containsKey( objAsset.Id ) && objAsset.AccountId != mapOldAssetById.get( objAsset.Id ).AccountId ){
				objAsset.AccountId.addError( System.Label.AfterSalesAssetAccountIdValidation );
			}
		}
	}

	/**
	* @Method: 		assingRealMileageSource
	* @param: 		List<Asset> lstAssets
	* @param: 		Map<Id, Asset> mapOldAssetById
	* @Description:	Assigns APV as a RealMileageSource when the RealMileage is informed by an AfterSales user.
	* @author 		Manuel Medina - 02182019
	*/
	public static void assingRealMileageSource( List<Asset> lstAssets, Map<Id, Asset> mapOldAssetById ){
		for( Asset objAsset : lstAssets ){
			if( PAD.sUserTypeCode.equals( '1' ) && objAsset.RealMileage__c != mapOldAssetById.get( objAsset.Id ).RealMileage__c && String.isNotBlank( objAsset.RealMileageSource__c ) && !objAsset.RealMileageSource__c.equals( 'APV' ) && objAsset.RealMileageSource__c.equals( mapOldAssetById.get( objAsset.Id ).RealMileageSource__c ) ){
				objAsset.RealMileageSource__c					= 'APV';
				objAsset.RealMileageDate__c						= System.today();
			}
		}
	}
    

    /*********************************************************************************************************
    * @Method          :   changeVINAndLastKnownRegistrationNumber
    * @Author          :   xx <xx@ext.mpsa.com>
    * @Created         :   04/11/2018
    * @Description     :   This method is used to enroute records to the proper calculation for predictive 
    * 				   :   mileage and / or maintenance step
    * @params	       :   Map<Id,Asset> : Trigger.newMap 
    * @params          :   Map<Id,Asset> : Trigger.oldMap
    * @Returns         :   void
    **********************************************************************************************************/     
    public static void changeVINAndLastKnownRegistrationNumber(Map<Id, Asset> map_asset_new, Map<Id, Asset> map_asset_old){
        System.debug('##########changeVINAndLastKnownRegistrationNumber');
        Set<Id> set_id_asset = new Set<Id>();
        
        for(Asset asse : map_asset_new.values()){
            if(asse.VIN__c != map_asset_old.get(asse.Id).VIN__c 
               || asse.LastKnownRegistrationNumber__c != map_asset_old.get(asse.Id).LastKnownRegistrationNumber__c){
                   set_id_asset.add(asse.Id);
               }
        }
        
        List<Case> lst_cases = [SELECT Id, VIN__c, RegistrationNumber__c FROM Case WHERE AssetId IN : set_id_asset];
        
        update lst_cases;
    }    
    
    
}
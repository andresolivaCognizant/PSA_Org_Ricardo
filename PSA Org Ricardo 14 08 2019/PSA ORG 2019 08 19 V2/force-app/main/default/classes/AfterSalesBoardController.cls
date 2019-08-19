/*
* @Name            :   AfterSalesBoardController
* @Author          :   Rubén Fernandez Lopez
* @Created         :   23/05/2018
* @Methods (aura)    
	-  getRecordDetails. Return a wrapper using the record passed as paramenter.
	-  getRelatedRecords. Return a list of records linked to the record.
*  @Methods (private)   
	-  getLastNDays. Calculate the days used to filter the queries. Use a Metadata.
	-  getAllCampaigns.  Return a list of campaings linked to a record.
	-  getAllOpportunities.  Return a list of opportunities linked to a record.
	-  getAllRecords.  Generic function to retur a list of sObjects linked to a record.
*/ 
public with sharing class AfterSalesBoardController {

	private static final Integer DEFAULT_LASTNDAYS = 30;                // Default value, just in case no metadata found.

	/*
	* @Method          :   getRecordDetails
	* @Description     :   Returns the data for the selected record.
	* @Params          :   sObjectType(String): Type of Object.
	* @Returns         :   string: list of fields to get from the object.
	*/ 
	@AuraEnabled 
	public static DataTableResponse getRecordDetails(String sRecordId) {
		List<sObject> auxRecords        = new List<sObject>();
		List<DataTableObject> lstValues = new List<DataTableObject>();
		List<sObject> auxC              = new List<sObject>();
		List<sObject> auxO              = new List<sObject>();
		if(!String.isEmpty(sRecordId)){
			for(AccountContactAssetRelation__c ob : [SELECT AssetId__r.SerialNumber,AssetId__r.Model__c,AssetId__r.VIN__c,AccountId__r.FirstName,AccountId__r.LastName,AccountId__r.NationalId__pc,
														AccountId__r.PersonEmail,AccountId__r.MobilePersonalTelephone__pc,AccountRole__c,AssetId__r.Brand__c,AccountId__r.LoyaltyCardId__pc,
														AccountId__r.CustomerSpaceACStatus__c,AccountId__r.CustomerSpaceAPStatus__c,AccountId__r.CustomerSpaceDSStatus__c ,AccountId__r.Name,AccountId__r.TECH_Phone__c,
														AccountId__r.TECH_FiscalId__c, AccountId__r.LastModifiedDate,AccountId__r.SystemModstamp, AccountId__c, AccountId__r.PersonContactId, AccountId__r.Phone, AccountId__r.PersonMobilePhone, AccountId__r.IsPersonAccount,
														AccountId__r.MobileProfessionalTelephone__pc, AccountId__r.Email__c
														From AccountContactAssetRelation__c Where Id =: sRecordId LIMIT 1 ]){
				lstValues.add(new DataTableObject(ob,0,0,0));
			}
		}
		DataTableResponse ltngTableWrapper     = new DataTableResponse();
		ltngTableWrapper.lstDataTableData      = lstValues;
		return ltngTableWrapper;
	}
	/*
	* @Method          :   getRelatedRecords
	* @Description     :   Returns the records for the selected record and object type.
	* @Params          :   sType(String): Type of Object.
	*                  :   sAccountId(Id): Account Id to filter the results.
	* @Returns         :   List<sObject>: list of records found.
	*/     
	@AuraEnabled   
	public static List<sObject> getRelatedRecords(Id sAccountId,String sType){
		List<sObject> lstAux  = new List<sObject>();
		if(sType=='Campaign'){
			lstAux  = getAllCampaigns(sAccountId);

		}else if(sType=='Opportunity'){
			lstAux  = getAllOpportunities(sAccountId);

		}else if(sType=='TestDrive'){
			//lstAux  = getAllTestDrives(sAccountId);

		}else if (sType == 'Consents') {
			lstAux = getAllConsents(sAccountId);

		}else if( sType.equals( 'DMS' ) ){
			lstAux.add( DMSCustomerDataController.getDMSData( sAccountId ) );
		}

		return lstAux;
	}
	/*
	* @Method          :   getRelatedRecords
	* @Description     :   Calculates the number of days for current user
	* @Params          :   None
	* @Returns         :   Integer. Number of days.
	*/      
	private static Integer getLastNDays(){
		Integer iDefualtDays    =   DEFAULT_LASTNDAYS;
		String skey             = 'AfterSalesCampaigns' + PAD.sUserCountry + PAD.sUserBrand;
		System.debug('getLastNDays: ' + skey);
		for(UtilSetting__mdt aux : [SELECT Value__c,QualifiedApiName FROM UtilSetting__mdt where QualifiedApiName =: skey  Order by QualifiedApiName ASC limit 10]){
			iDefualtDays        = Integer.valueOf(aux.value__c);
			System.debug('getLastNDays: ' + iDefualtDays);
		}
		return iDefualtDays;
	}
	/*
	* @Method          :   getAllCampaigns
	* @Description     :   Returns a list of records (Campaigns) for the selected Id.
	* @Params          :   sAccountId(Id): Account Id to filter the results.
	* @Returns         :   List<sObject>: list of campaigns which meet the conditions requested.
	*/         
	private static List<sObject> getAllCampaigns(Id sAccountId){
		return getAllRecords('SELECT Id,Name,et4ae5__DateOpened__c,et4ae5__DateSent__c,et4ae5__Email__c FROM et4ae5__IndividualEmailResult__c WHERE et4ae5__Contact__c =\'' + sAccountId +'\'  AND et4ae5__DateSent__c >= LAST_N_DAYS:' + getLastNDays());
	}
	
	/*
	* @Method          :   getAllOpportunities
	* @Description     :   Returns a list of records (Opportunities) for the selected Id.
	* @Params          :   sAccountId(Id): Account Id to filter the results.
	* @Returns         :   List<sObject>: list of opportunities which meet the conditions requested.
	*/     
	private static List<sObject> getAllOpportunities(Id sAccountId){
		/* BEGIN - Gets Asset data to filter custom metadata APVHeaderOpportunitySettings__mdt - 24072018 */
		List<AccountContactAssetRelation__c> lstAssetOwnerRelations		= new List<AccountContactAssetRelation__c>();
		lstAssetOwnerRelations											= [SELECT Id,
																				AccountId__c,
																				AssetId__c,
																				AssetId__r.Brand__c,
																				AssetId__r.Country__c
																			FROM AccountContactAssetRelation__c
																			WHERE AssetId__c =: sAccountId
																			AND AccountRole__c = 'Owner'
																			LIMIT 1
																		];

		if( !lstAssetOwnerRelations.isEmpty() ){
			List<APVHeaderOpportunitySettings__mdt> lstMdtOppSettings	= new List<APVHeaderOpportunitySettings__mdt>();
			lstMdtOppSettings											= [SELECT Id,
																				Brand__c,
																				Country__c,
																				Stage__c,
																				CreatedDateLastNDays__c
																			FROM APVHeaderOpportunitySettings__mdt
																			WHERE DeveloperName =: GlobalSettingsUtil.getCustomMetadataKey( new List<String>{ lstAssetOwnerRelations.get( 0 ).AssetId__r.Country__c, lstAssetOwnerRelations.get( 0 ).AssetId__r.Brand__c } )
																		];

			if( lstMdtOppSettings.isEmpty() ){
				return new List<SObject>();
			}

			return getAllRecords(
				'SELECT Id, Name, toLabel(StageName), Amount, CloseDate, CreatedDate ' +
					'FROM Opportunity ' +
					'WHERE AccountId =\'' + lstAssetOwnerRelations.get( 0 ).AccountId__c + '\' ' +
					( String.isNotBlank( lstMdtOppSettings.get( 0 ).Stage__c )  ? 'AND StageName = \'' + lstMdtOppSettings.get( 0 ).Stage__c + '\' ' : '' ) +
					'AND CreatedDate >= LAST_N_DAYS:' + Integer.valueOf( lstMdtOppSettings.get( 0 ).CreatedDateLastNDays__c )
			);
		}else{
			return new List<SObject>();
		}
		//return getAllRecords('SELECT Id,Name,StageName,Amount,CloseDate,CreatedDate FROM Opportunity WHERE AccountId =\'' + sAccountId +'\' AND CloseDate >= LAST_N_DAYS:' + getLastNDays());
		/* END - Gets Asset data to filter custom metadata APVHeaderOpportunitySettings__mdt - 24072018 */
	}
	/*
	* @Method          :   getAllTestDrives
	* @Description     :   Returns a list of records (Test Drives) for the selected Id.
	* @Params          :   sAccountId(Id): Account Id to filter the results.
	* @Returns         :   List<sObject>: list of test drives which meet the conditions requested.
	*/       
	//private static List<sObject> getAllTestDrives(Id sAccountId){
	//    return getAllRecords(sAccountId,'Select Id,Name,StageName,Amount,CloseDate,CreatedDate WHERE AccountId =:sAccountId AND CloseDate >= LAST_N_DAYS:' + getLastNDays());
	//} 
	
	/*
	* @Method          :   getAllRecords
	* @Description     :   Returns a list of records.
	* @Params          :   sQuery(String): Any SOQL query.
	* @Returns         :   List<sObject>: list of records found.
	*/       
	private static List<sObject> getAllRecords(String sQuery){
		List<sObject> lstAux  = new List<sObject>();
		try {
			System.debug('getAllRecords : ' + sQuery);
			lstAux = Database.query(sQuery);
		} catch(Exception e) {
			System.debug('getAllRecords. An unexpected error has occurred: ' + e.getMessage());
		}
		return lstAux;
	}   
	 
	/*
	* @Method          :   Wrapper: DataTableResponse
	* @Author          :   Rubén Fernandez Lopez
	* @Created         :   23/02/2018
	* @Description     :   Wrapper class to hold header results
	*/ 
	public class DataTableResponse {
		@AuraEnabled         
		public List<DataTableObject> lstDataTableData {get;set;}

		public DataTableResponse(){
			lstDataTableData        = new List<DataTableObject>();
		}
	}
	public class DataTableObject {
		@AuraEnabled
		public sObject sObjectVal {get;set;}
		@AuraEnabled
		public Integer campaigns  {get;set;}
		@AuraEnabled
		public Integer opportunities  {get;set;}
		@AuraEnabled
		public Integer testdrives  {get;set;}
		//Create and set three variables label, fieldname and type as required by the lightning:datatable
		public DataTableObject(sObject sobjname,Integer iCampaigns, Integer iOpportunities, Integer iTestDrives){
			this.sObjectVal     = sobjname;
			this.campaigns      = iCampaigns;
			this.opportunities  = iOpportunities;
			this.testdrives     = iTestDrives;
		}
	} 
	
	/*@AuraEnabled 
	public static String getCalloutResponseContents(String sURL) {
		Http h              = new Http();
		HttpRequest req     = new HttpRequest();
		req.setEndpoint(sURL);
		req.setMethod('GET');
		HttpResponse res    = h.send(req);
		return 'data:'+res.getHeader('Content-Type')+';base64,'+EncodingUtil.base64Encode(res.getBodyAsBlob());
	}*/

	/*
	* @Method          :   getAllConsents
	* @Author          :   Rubén Fernandez Lopez
	* @Updated         :   29/11/2018
	* @Description     :   Method to return applicable consents to a given Workshop Appointment record
	*/
	private static List<sObject> getAllConsents(Id r){
		List<Consent__c> lstConsents							= new List<Consent__c>();
		WorkshopAppointment__c objAppointment					= [SELECT Id,
																		ReceptionDatetime__c,
																		Driver__c,
																		TECH_ConsentCount__c
																	FROM WorkshopAppointment__c
																	WHERE Id = :r
																];

		lstConsents												= [SELECT Id,
																		CreatedDate,
																		FORMAT( CreatedDate ) formatedCreatedDate
																	FROM Consent__c
																	WHERE Contact__r.AccountId =: objAppointment.Driver__c
																	AND (
																		CreatedDate <=: objAppointment.ReceptionDatetime__c OR
																		CreatedDate = TODAY
																	)
																	ORDER BY CreatedDate DESC
																];

		return lstConsents;
	}

	@AuraEnabled
	public static Map<String, Object> myBrandElegibility(Id recordId) {

		// map to be returned
		Map<String, Object> m = new Map<String, Object>();
		Map<String, Object> m_0 = new Map<String, Object>();
		Map<String, Object> m_1 = new Map<String, Object>();


		WorkshopAppointment__c w = [
			SELECT
				Id,
				MyM_Invitation__c,
				ReceptionDatetime__c,
				Driver__r.RecordType.DeveloperName,
				Driver__r.PersonEmail,
				Asset__r.Brand__c,
				Driver__r.PersonMobilePhone,
				Driver__r.CustomerSpaceACStatus__c,
				Driver__r.CustomerSpaceAPStatus__c,
				Driver__r.CustomerSpaceDSStatus__c
			FROM WorkshopAppointment__c
			WHERE Id = :recordId
		];

		User u = [
			SELECT Id, Account.Brand__c 
			FROM User
			WHERE Id = :UserInfo.getUserId()
		];

		// set defaults
		m_0.put('checked', w.MyM_Invitation__c);
		m_0.put('visible', true);
		m_0.put('disabled', false);
		m_0.put('help', System.Label.MyBrandInvitationMessage5);

		m_1.put('checked', true);
		m_1.put('visible', true);
		m_1.put('disabled', false);
		m_1.put('help', System.Label.MyBrandInvitationMessage5);

		m.put('myBrand', m_0);
		m.put('reminder', reminderElegibility(m_1, w));

		// if customer already has a MyM account no invitation is required
		switch on w.Asset__r.Brand__c {
			when 'AC' {
				if (w.Driver__r.CustomerSpaceACStatus__c == '1') {
					m_0.put('checked', true);
					m_0.put('disabled', true);
					m_0.put(
						'help',
						System.Label.WorkshopAppointmentReminderMessage3	
					);
					return m;
				}
			}

			when 'AP' {
				if (w.Driver__r.CustomerSpaceAPStatus__c == '1') {
					m_0.put('checked', true);
					m_0.put('disabled', true);
					m_0.put(
						'help',
						System.Label.MyBrandInvitationMessage1
					);
					return m;
				}
			}

			when 'DS' {
				if (w.Driver__r.CustomerSpaceDSStatus__c == '1') {
					m_0.put('checked', true);
					m_0.put('disabled', true);
					m_0.put(
						'help',
						System.Label.MyBrandInvitationMessage1
					);
					return m;
				}
			}
		}

		// to send an invitation, dealer and asset brand should coincide 
		if (w.Asset__r.Brand__c != u.Account.Brand__c) {
			m_0.put('disabled', true);
			m_0.put(
				'help',
				System.Label.MyBrandInvitationMessage2
			);
			return m;
		}

		// action is only available to B2C accounts
		if ('PersonAccount_B2C' != w.Driver__r.RecordType.DeveloperName) {
			m_0.put('disabled', true);
			m_0.put(
				'help',
				System.Label.MyBrandInvitationMessage3
			);
			return m;
		}

		// an email address is mandatory to send an invitation
		if (String.isBlank(w.Driver__r.PersonEmail)) {
			m_0.put('disabled', true);
			m_0.put(
				'help',
				System.Label.MyBrandInvitationMessage4
			);
			return m;
		}

		return m;
	}

	private static Map<String, Object> reminderElegibility(
		Map<String, Object> m_1,
		WorkshopAppointment__c w
	) {
		if (null != w.ReceptionDatetime__c && w.ReceptionDatetime__c <= System.today()) {
			m_1.put('disabled', true);
			m_1.put('help', System.Label.WorkshopAppointmentReminderMessage1);
			return m_1;
		}

		if (String.isBlank(w.Driver__r.PersonMobilePhone)) {
			m_1.put('disabled', true);
			m_1.put('help', System.Label.WorkshopAppointmentReminderMessage2);
			return m_1;
		}

		return m_1;
	}

	@AuraEnabled
	public static Map<Id, WorkshopAppointment__c> getAppointmentInfo(String req) {
		List<Id> lst = new List<Id>();

		Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(req);
		for (Object o : (List<Object>) m.get('ids')) {
			lst.add((Id) o);
		}



		if (lst.isEmpty()) {
			return new Map<Id, WorkshopAppointment__c>([
				SELECT Id, AppointmentStatus__c, Driver__c
				FROM WorkshopAppointment__c
				ORDER BY LastModifiedDate DESC
				LIMIT 50
			]);
		}

		return new Map<Id, WorkshopAppointment__c>([
			SELECT Id, AppointmentStatus__c, Driver__c
			FROM WorkshopAppointment__c
			WHERE Id IN :lst
			ORDER BY LastModifiedDate DESC
		]);
	}
	@AuraEnabled        
	public static Map<String,String> DMSWakeUp(String sRecordId_A, String sRecordId_B){
		return dmsCallOutsController.DMSWakeUpbyCORS(sRecordId_A,sRecordId_B);
	}

	@AuraEnabled
	public static boolean DMSWakeUpbyServer(String sRecordId){
		return dmsCallOutsController.DMSWakeUpbyServer(sRecordId);
	}
	/*
	@AuraEnabled        
	public static Map<String,String> DMSWakeUpbyCORS(String recordId){
		Map<String,String>  sCORS = new Map<String,String>();
		if(PAD.sUserDMSType=='1'){
			sCORS.put('body',getObjectValue(recordId) );
			sCORS.put('endpoint',PAD.sURLDMS);
		}
		return sCORS;
	}
	@TestVisible
	private static String getObjectValue(String recordId){
		String usrId = userInfo.getUserId();
		SAPIWebhook.sRecordValues aux;
		if(!String.isBlank(recordId)){
			List<WorkshopAppointment__c> lstAccAss = new List<WorkshopAppointment__c>([
				SELECT Driver__c,Asset__c 
				FROM WorkshopAppointment__c 
				WHERE Id =:recordId ]);
			if(!lstAccAss.isEmpty()){
				aux = new SAPIWebhook.sRecordValues('',lstAccAss.get(0).Driver__c,lstAccAss.get(0).Asset__c,'','','');
			}else{
				aux = new SAPIWebhook.sRecordValues('','','','','','');
			}
		}

		return  SAPIWebhook.setRequestBody(aux);
	}*/
}
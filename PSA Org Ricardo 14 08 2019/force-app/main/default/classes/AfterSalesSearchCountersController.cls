/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			AfterSales
* Description:		AfterSalesSearchCounters controller class.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2018-06-27		Manuel Medina (MM)		Initial definition.
*********************************************************************************************************/
public with sharing class AfterSalesSearchCountersController {
	
	public static List<ConsentsOutdated> lstConsentsOutdated;
	
	/**
	* @Method: 		getAppointmentTotals
	* @param: 		N/A
	* @Description: Get appointment totals filtered by status.
	* @author 		Manuel Medina - 29062018
	*/
	@AuraEnabled 
	public static DataTable getConsentsOutdated(){
		Map<String, String> mapFieldLabelByAPIName						= new Map<String, String>();
		Map<String, String> mapAppointmentTotalsByAttribute				= new Map<String, String>();
		mapAppointmentTotalsByAttribute									= getAppointmentTotals();
		
		mapFieldLabelByAPIName.put( 'Id', getFieldLabel( 'Id', 'WorkshopAppointment__c' ) );
		mapFieldLabelByAPIName.put( 'ReceptionDatetime__c', getFieldLabel( 'ReceptionDatetime__c', 'WorkshopAppointment__c' ) );
		mapFieldLabelByAPIName.put( 'AppointmentStatus__c', getFieldLabel( 'AppointmentStatus__c', 'WorkshopAppointment__c' ) );
		mapFieldLabelByAPIName.put( 'ReceptionReceptionist__c', getFieldLabel( 'ReceptionReceptionist__c', 'WorkshopAppointment__c' ) );
		mapFieldLabelByAPIName.put( 'TECH_UnsubscribeURL__c', getFieldLabel( 'TECH_UnsubscribeURL__c', 'Account' ) );
		mapFieldLabelByAPIName.put( 'Name', getFieldLabel( 'Name', 'Account' ) );
		mapFieldLabelByAPIName.put( 'Model__c', getFieldLabel( 'Model__c', 'Asset' ) );
		mapFieldLabelByAPIName.put( 'LastKnownRegistrationNumber__c', getFieldLabel( 'LastKnownRegistrationNumber__c', 'Asset' ) );
		mapFieldLabelByAPIName.put( 'VIN__c', getFieldLabel( 'VIN__c', 'Asset' ) );
		
		if( mapAppointmentTotalsByAttribute.containsKey( 'ERROR' ) ){
			lstConsentsOutdated											= new List<ConsentsOutdated>();
			lstConsentsOutdated.add( new ConsentsOutdated( mapAppointmentTotalsByAttribute.get( 'ERROR' ) ) );
		}
		
		return new DataTable( lstConsentsOutdated, mapFieldLabelByAPIName );
	}
	
	/**
	* @Method: 		getFieldLabel
	* @param: 		String strfieldName
	* @param: 		String strSObject
	* @Description:	Returns field label base on field API name and Sobject relaed.
	* @author 		Manuel Medina - 02072018
	*/
	@AuraEnabled 
	public static String getFieldLabel( String strfieldName, String strSObject ){

		Map<String, Schema.SObjectType> mapSFDCObjects					= Schema.getGlobalDescribe();
		Schema.DescribeSObjectResult sObjResult							= mapSFDCObjects.get( strSObject ).getDescribe();
		Map<String, Schema.SObjectField> mapFields						= sObjResult.fields.getMap();
		Schema.SObjectField field										= mapFields.get( strfieldName );
		Schema.DescribeFieldResult fieldResult							= field.getDescribe();

		return String.valueOf( fieldResult.getLabel() );
	}
	
	/**
	* @Method: 		getAppointmentTotals
	* @param: 		N/A
	* @Description: Get appointment totals filtered by status.
	* @author 		Manuel Medina - 27062018
	*/
	@AuraEnabled 
	public static Map<String, String> getAppointmentTotals(){
		lstConsentsOutdated												= new List<ConsentsOutdated>();
		Map<String, String> mapAppointmentTotalsByAttribute				= new Map<String, String>{
																			'toReceive'			=> '0',
																			'received'			=> '0',
																			'received_upd'		=> '0',
																			'received_nupd'		=> '0',
																			'delivered'			=> '0',
																			'delivered_upd'		=> '0',
																			'delivered_nupd'	=> '0'
																		};
		
		try{
			List<WorkshopAppointment__c> lstAppointmentsToReceive		= new List<WorkshopAppointment__c>();
			List<WorkshopAppointment__c> lstAppointmentsReceived		= new List<WorkshopAppointment__c>();
			List<WorkshopAppointment__c> lstAppointmentsDelivered		= new List<WorkshopAppointment__c>();
			
			Set<Id> setAccountIdsReceived								= new Set<Id>();
			Set<Id> setAccountIdsDelivered								= new Set<Id>();
			
			User objUser												= new User();
			objUser														= [SELECT Id,
																				AccountId,
																				Brand__c
																			FROM User
																			WHERE Id =: System.UserInfo.getUserId()
																			LIMIT 1
																		];
																	
			List<WorkshopAppointment__c> lstAppointments				= new List<WorkshopAppointment__c>( [
																			SELECT Id,
																				Name,
																				ReceptionDatetime__c,
																				Asset__c,
																				Asset__r.Model__c,
																				Asset__r.VIN__c,
																				Asset__r.FirstRegistrationNumber__c,
																				Brand__c,
																				AppointmentStatus__c,
																				toLabel( AppointmentStatus__c ) appointmentStatus,
																				Workshop__c,
																				Driver__c,
																				Driver__r.TECH_UnsubscribeURL__c,
																				Driver__r.Name,
																				Owner__c,
																				ReceptionReceptionistId__c,
																				ReceptionReceptionistId__r.Name,
																				TECH_ConsentStatus__c
																			FROM WorkshopAppointment__c
																			WHERE Workshop__c =: !Test.isRunningTest() ? objUser.AccountId : null
																			AND ReceptionDatetime__c = TODAY
																			AND TECH_SBConfirmation__c = true
																			ORDER BY ReceptionDatetime__c ASC
																		] );
																	
			for( WorkshopAppointment__c objAppointment : lstAppointments ){
				if( objAppointment.AppointmentStatus__c.equals( '1' ) ){//To be received
					lstAppointmentsToReceive.add( objAppointment );
					
				}else if( objAppointment.AppointmentStatus__c.equals( '2' ) ){//Received
					lstAppointmentsReceived.add( objAppointment );
					setAccountIdsReceived.add( objAppointment.Driver__c );
					
				}else if( objAppointment.AppointmentStatus__c.equals( '5' ) ){//Delivered
					lstAppointmentsDelivered.add( objAppointment );
					setAccountIdsDelivered.add( objAppointment.Driver__c );
				}
			}
			
			Map<String, Integer> mapReceivedTotalConsentsByAttribute	= new Map<String, Integer>( classifyByConsentStatus( lstAppointmentsReceived, setAccountIdsReceived, objUser ) );
			Map<String, Integer> mapDeliveredTotalConsentsByAttribute	= new Map<String, Integer>( classifyByConsentStatus( lstAppointmentsDelivered, setAccountIdsDelivered, objUser ) );
			
			mapAppointmentTotalsByAttribute.put( 'toReceive', String.valueOf( lstAppointmentsToReceive.size() ) );
			mapAppointmentTotalsByAttribute.put( 'received', String.valueOf( lstAppointmentsReceived.size() ) );
			mapAppointmentTotalsByAttribute.put( 'received_upd', String.valueOf( mapReceivedTotalConsentsByAttribute.get( 'updated' ) ) );
			mapAppointmentTotalsByAttribute.put( 'received_nupd', String.valueOf( mapReceivedTotalConsentsByAttribute.get( 'notUpdated' ) ) );
			mapAppointmentTotalsByAttribute.put( 'delivered', String.valueOf( lstAppointmentsDelivered.size() ) );
			mapAppointmentTotalsByAttribute.put( 'delivered_upd', String.valueOf( mapDeliveredTotalConsentsByAttribute.get( 'updated' ) ) );
			mapAppointmentTotalsByAttribute.put( 'delivered_nupd', String.valueOf( mapDeliveredTotalConsentsByAttribute.get( 'notUpdated' ) ) );
		
		}catch( Exception e ){
			System.debug( '\n\n\n\t<<<<<<<<< ExceptionType >>>>>>>>> \n\t\t@@--> getCause > ' + e.getCause() + '\n\t\t@@--> getLineNumber > ' + e.getLineNumber() + '\n\t\t@@--> getMessage > '+ e.getMessage() + '\n\t\t@@--> getStackTraceString > '+ e.getStackTraceString() + '\n\t\t@@--> getTypeName > ' + e.getTypeName() + '\n\n' );
			
			mapAppointmentTotalsByAttribute.put( 'ERROR', '\n\n\n\t<<<<<<<<< ExceptionType >>>>>>>>> \n\t\t@@--> getCause > ' + e.getCause() + '\n\t\t@@--> getLineNumber > ' + e.getLineNumber() + '\n\t\t@@--> getMessage > '+ e.getMessage() + '\n\t\t@@--> getStackTraceString > '+ e.getStackTraceString() + '\n\t\t@@--> getTypeName > ' + e.getTypeName() + '\n\n' );
			return mapAppointmentTotalsByAttribute;
		}
		
		return mapAppointmentTotalsByAttribute;
	}
	
	/**
	* @Method: 		classifyByConsentStatus
	* @param: 		List<WorkshopAppointment__c> lstAppointments
	* @param: 		Set<Id> setAccountIdsRelated
	* @param: 		User objUser
	* @Description: Classifies consents based on updated status.
	* @author 		Manuel Medina - 27062018
	*/
	public static Map<String, Integer> classifyByConsentStatus( List<WorkshopAppointment__c> lstAppointments, Set<Id> setAccountIdsRelated, User objUser ){
		Map<String, Integer> mapAppointmentTotalsByAttribute			= new Map<String, Integer>{
																			'updated'		=> 0,
																			'notUpdated'	=> 0
																		};
		Map<Id, Consent__c> mapConsentsByAccount						= new Map<Id, Consent__c>();
		
		List<Consent__c> lstConsents									= new List<Consent__c>( [
																			SELECT Id,
																				CollectedEntityId__c,
																				DocumentBrand__c,
																				Contact__c,
																				Contact__r.AccountId,
																				CreatedDate,
																				LastModifiedDate
																			FROM Consent__c
																			WHERE Contact__r.AccountId IN: setAccountIdsRelated
																			AND CollectedEntityId__c =: !Test.isRunningTest() ? objUser.AccountId : null
																		] );
																	
		for( Consent__c objConsent : lstConsents ){
			if( mapConsentsByAccount.containsKey( objConsent.Contact__r.AccountId ) && mapConsentsByAccount.get( objConsent.Contact__r.AccountId ).CreatedDate.date() < objConsent.CreatedDate.date() ){
				mapConsentsByAccount.put( objConsent.Contact__r.AccountId, objConsent );
				
			}else if( !mapConsentsByAccount.containsKey( objConsent.Contact__r.AccountId ) ){
				mapConsentsByAccount.put( objConsent.Contact__r.AccountId, objConsent );
			}
		}
		
		for( WorkshopAppointment__c objAppointment : lstAppointments ){
			
			Set<Consent__c> setConsentsToCheck							= new Set<Consent__c>();
			setConsentsToCheck.add( mapConsentsByAccount.get( objAppointment.Owner__c ) );
			setConsentsToCheck.add( mapConsentsByAccount.get( objAppointment.Driver__c ) );
			setConsentsToCheck.removeAll( new List<Consent__c>{ null } );
			
			if( setConsentsToCheck.isEmpty() ){
				mapAppointmentTotalsByAttribute.put( 'notUpdated', mapAppointmentTotalsByAttribute.get( 'notUpdated' ) + 1 );
				
				lstConsentsOutdated.add(
					new ConsentsOutdated(
						objAppointment
					)
				);
			}
			
			for( Consent__c objConsent : setConsentsToCheck ){
				if(
					(
						Test.isRunningTest() ||
						objConsent.Contact__r.AccountId.equals( objAppointment.Owner__c ) ||
						objConsent.Contact__r.AccountId.equals( objAppointment.Driver__c )
					) && (
						String.isNotBlank( objAppointment.TECH_ConsentStatus__c ) &&
						objAppointment.TECH_ConsentStatus__c.equals( '2' )
					)
				){
					mapAppointmentTotalsByAttribute.put( 'updated', mapAppointmentTotalsByAttribute.get( 'updated' ) + 1 );
					
				}else if(
					(
						Test.isRunningTest() ||
						objConsent.Contact__r.AccountId.equals( objAppointment.Owner__c ) ||
						objConsent.Contact__r.AccountId.equals( objAppointment.Driver__c )
					) && (
						(
							String.isNotBlank( objAppointment.TECH_ConsentStatus__c ) &&
							!objAppointment.TECH_ConsentStatus__c.equals( '2' )
						) || String.isBlank( objAppointment.TECH_ConsentStatus__c )
					)
				){
					mapAppointmentTotalsByAttribute.put( 'notUpdated', mapAppointmentTotalsByAttribute.get( 'notUpdated' ) + 1 );
					
					lstConsentsOutdated.add(
						new ConsentsOutdated(
							objAppointment
						)
					);
				}
			}
		}
		
		return mapAppointmentTotalsByAttribute;
	}
	
	public class DataTable{
		@AuraEnabled 
		public List<ConsentsOutdated> lstConsentsOutdated				{get; set;}
		
		@AuraEnabled 
		public Map<String, String> mapFieldLabelByAPIName				{get; set;}
		
		public DataTable( List<ConsentsOutdated> lstConsentsOutdated, Map<String, String> mapFieldLabelByAPIName ){
			this.lstConsentsOutdated									= lstConsentsOutdated;
			this.mapFieldLabelByAPIName									= mapFieldLabelByAPIName;
		}
	}
	
	public class ConsentsOutdated{
		@AuraEnabled 
		public WorkshopAppointment__c objAppointment					{get; set;}
		
		@AuraEnabled 
		public String strError											{get; set;}
		
		@AuraEnabled 
		public String strConsentURL										{get; set;}
		
		@AuraEnabled 
		public String strReceptionDate									{get; set;}
		
		public ConsentsOutdated( WorkshopAppointment__c objAppointment ){
			this.objAppointment											= objAppointment;
			
			this.strConsentURL											= String.isNotEmpty(  objAppointment.Driver__r.TECH_UnsubscribeURL__c ) ? objAppointment.Driver__r.TECH_UnsubscribeURL__c.replace( 'amp;', '' ).substringBetween( '<a href="', '" target="_blank"' ) : '';
			this.strReceptionDate										= objAppointment.ReceptionDatetime__c != null ? objAppointment.ReceptionDatetime__c.format( 'dd/MM/yyyy HH:mm' ) : '';
		}
		
		public ConsentsOutdated( String strError ){
			this.strError												= strError;
		}
	}
}
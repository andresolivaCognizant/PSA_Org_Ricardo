/**
* Salesforce
* @author 			Ruben Fernandez Lopez
* Project:			AfterSales
* Description:		MyOEventsListener controller class.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2018-##-##		Ruben Fernandez (RF)		Initial definition.
*********************************************************************************************************/
public with sharing class MyOEventsListenerController {
	
	/**
	* @Method: 		MyOParams
	* @param: 		NA
	* @Description:	Wrapper which contains all MyO attributes.
	* @author 		Ruben Fernandez - ####2018
	*/
	public class MyOParams {
			@AuraEnabled
			public String idWorkshop;
		
			@AuraEnabled
			public String brand;
			
			@AuraEnabled
			public String idUser;
			
			@AuraEnabled
			public String locale;
			
			@AuraEnabled
			public String host;

			@AuraEnabled
			public String appointmentId;
			
			@AuraEnabled
			public String idCustomerSF;

			@AuraEnabled
			public String idVehicleSF;

			@AuraEnabled
			public String idVINSF;
	}
	
	/**
	* @Method: 		getUserDetails
	* @param: 		String sHostType
	* @param: 		String sRecordId
	* @param: 		String strMode
	* @Description:	Returns all MyO required attributes.
	* @author 		Ruben Fernandez - ####2018
	*/
	@AuraEnabled
	public static MyOParams getUserDetails( String sHostType, String sRecordId, String strMode ){
		MyOParams sUserDetails 	= new MyOParams();
		List<WorkshopAppointment__c> lws;

		if(!String.isEmpty(sRecordId)){
			lws = new List<WorkshopAppointment__c>([SELECT Id,Driver__r.Id,Brand__c,Asset__r.Id,Asset__r.VIN__c, AppointmentSBId__c FROM WorkshopAppointment__c WHERE Id =: sRecordId]);
		}

		String sAux 					= PAD.uCurrentUserName.LocaleSidKey;
		sUserDetails.idWorkshop 		= PAD.sIdWorkshop;
		sUserDetails.brand 				= PAD.sUserBrand;
		sUserDetails.idUser 			= PAD.uCurrentUserName.LDAPId__c;
		sUserDetails.locale 			= sAux.left(5);
		sUserDetails.host				= getMyOHost( sHostType, strMode );

		if(lws!= null && !lws.isEmpty() && !String.isEmpty(sRecordId)){
			sUserDetails.brand 			= lws.get(0).Brand__c;
			sUserDetails.appointmentId 	= lws.get(0).AppointmentSBId__c;
			sUserDetails.idCustomerSF 	= lws.get(0).Driver__r.Id;
			sUserDetails.idVehicleSF	= lws.get(0).Asset__r.Id;
			sUserDetails.idVINSF 		= lws.get(0).Asset__r.VIN__c;
		}

		return sUserDetails;
	} 
	
	/**
	* @Method: 		getMyOHost
	* @param: 		String sHostType
	* @param: 		String strMode
	* @Description:	Returns the MyO URL.
	* @author 		Ruben Fernandez - ####2018
	*/
	private static String getMyOHost( String sHostType, String strMode ){
		String sKey = 'NewAgenda_URL';

		if(sHostType!='Agenda'){
			sKey = 'NewAppointment_URL';
		}
		
		if( String.isNotBlank( strMode ) && strMode.equals( 'edit' ) && !sHostType.equals( 'Agenda' ) ){
			sKey							= 'EditAppointment_URL';
		}
		
		Map<String, Map<String, Object>> aux = GlobalSettingsUtil.getGlobalSettingAttributes(new Set<String>{'MyOApp'},new Set<String>{'NewAgenda_URL','NewAppointment_URL', 'EditAppointment_URL'});
		
		return  (String) aux.get('MyOApp').get(sKey);
	}

	/**
	* @Method: 		getAppointmentId
	* @param: 		String sExternalId
	* @Description:	Returns the Salesforce appointment Id based on given Service Box Id.
	* @author 		Ruben Fernandez - ####2018
	*/
	@AuraEnabled
	public static Id getAppointmentId(String sExternalId) {
		List<String> sAux = new List<String>();
		sAux.add(sExternalId);
		List<WorkshopAppointment__c> lObjs 	= new List<WorkshopAppointment__c>([SELECT Id,AppointmentSBId__c FROM WorkshopAppointment__c WHERE AppointmentSBId__c IN : sAux LIMIT 1]);
		return (lObjs.isEmpty()?'':lObjs.get(0).Id);
	}

	/**
	* @Method: 		cancelAppointment
	* @param: 		String strRequest
	* @Description:	Update an appointment with Canceled status.
	* @author 		MAnuel Medina - 04072019
	*/
	@AuraEnabled
	public static Map<String, Object> cancelAppointment( String strRequest ){
		Map<String, Object> mapRequest										= new Map<String, Object>( ( Map<String, Object> ) JSON.deserializeUntyped( strRequest ) );
		Map<String, Object> mapResponse										= new Map<String, Object>{
																				'hasError'		=> false,
																				'ERROR'			=> '',
																				'REQUEST'		=> mapRequest
																			};
		try{
			WorkshopAppointment__c objAppointment							= new WorkshopAppointment__c();
			objAppointment.Id												= mapRequest.get( 'strRecordId' ) != null ? String.valueOf( mapRequest.get( 'strRecordId' ) ) : getAppointmentId( String.valueOf( mapRequest.get( 'strAppointmentId' ) ) );
			objAppointment.AppointmentStatus__c								= '9';
			objAppointment.AppointmentCancellationDate__c					= System.now();
			objAppointment.AppointmentCancellationUser__c					= UserInfo.getUserId();

			update objAppointment;

			return mapResponse;

		}catch( Exception e ){
			System.debug( '\n\n\n\t<<<<<<<<< ExceptionType >>>>>>>>> \n\t\t@@--> getCause > ' + e.getCause() + '\n\t\t@@--> getLineNumber > ' + e.getLineNumber() + '\n\t\t@@--> getMessage > '+ e.getMessage() + '\n\t\t@@--> getStackTraceString > '+ e.getStackTraceString() + '\n\t\t@@--> getTypeName > ' + e.getTypeName() + '\n\n' );
			
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
	}
}
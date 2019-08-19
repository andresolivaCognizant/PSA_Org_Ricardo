/**
* Salesforce
* @author 			
* Project:			AfterSales
* Description:		AfterSalesSearchCounters controller class.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2018-12-06								Initial definition.
*********************************************************************************************************/
public with sharing class DMSearchCountersController {
		
	/**
	* @Method: 		getMetrics
	* @param: 		N/A
	* @Description: Get results totals.
	* @author 		
	*/
	@AuraEnabled 
	public static Map<String, String> getMetrics(){
		//lstConsentsOutdated												= new List<C>();
		Map<String, String> mapAppointmentTotalsByAttribute				= new Map<String, String>{
																			'toReceive'			=> '0'
		//																	'received'			=> '0',
		//																	'received_upd'		=> '0',
		//																	'received_nupd'		=> '0',
		//																	'delivered'			=> '0',
		//																	'delivered_upd'		=> '0',
		//																	'delivered_nupd'	=> '0'
																		};
		
		//try{
		//	List<WorkshopAppointment__c> lstAppointmentsToReceive		= new List<WorkshopAppointment__c>();
		//	List<WorkshopAppointment__c> lstAppointmentsReceived		= new List<WorkshopAppointment__c>();
		//	List<WorkshopAppointment__c> lstAppointmentsDelivered		= new List<WorkshopAppointment__c>();
			
		//	Set<Id> setAccountIdsReceived								= new Set<Id>();
		//	Set<Id> setAccountIdsDelivered								= new Set<Id>();
			
		//	User objUser												= new User();
		//	objUser														= [SELECT Id,
		//																		AccountId,
		//																		Brand__c
		//																	FROM User
		//																	WHERE Id =: System.UserInfo.getUserId()
		//																	LIMIT 1
		//																];
																	
		//	List<WorkshopAppointment__c> lstAppointments				= new List<WorkshopAppointment__c>( [
		//																	SELECT Id,
		//																		ReceptionDatetime__c,
		//																		Asset__c,
		//																		Asset__r.Model__c,
		//																		Asset__r.VIN__c,
		//																		Asset__r.FirstRegistrationNumber__c,
		//																		Brand__c,
		//																		AppointmentStatus__c,
		//																		toLabel( AppointmentStatus__c ) appointmentStatus,
		//																		Workshop__c,
		//																		Driver__c,
		//																		Driver__r.TECH_UnsubscribeURL__c,
		//																		Driver__r.Name,
		//																		Owner__c,
		//																		ReceptionReceptionistId__c,
		//																		ReceptionReceptionistId__r.Name
		//																	FROM WorkshopAppointment__c
		//																	WHERE Workshop__c =: !Test.isRunningTest() ? objUser.AccountId : null
		//																	/*AND Brand__c =: !Test.isRunningTest() ? objUser.Brand__c : null*/
		//																	AND ReceptionDatetime__c = TODAY
		//																	ORDER BY ReceptionDatetime__c ASC
		//																] );
																	
		//	for( WorkshopAppointment__c objAppointment : lstAppointments ){
		//		if( objAppointment.AppointmentStatus__c.equals( '1' ) ){//To be received
		//			lstAppointmentsToReceive.add( objAppointment );
					
		//		}else if( objAppointment.AppointmentStatus__c.equals( '2' ) ){//Received
		//			lstAppointmentsReceived.add( objAppointment );
		//			setAccountIdsReceived.add( objAppointment.Driver__c );
					
		//		}else if( objAppointment.AppointmentStatus__c.equals( '5' ) ){//Delivered
		//			lstAppointmentsDelivered.add( objAppointment );
		//			setAccountIdsDelivered.add( objAppointment.Driver__c );
		//		}
		//	}
			
		//	Map<String, Integer> mapReceivedTotalConsentsByAttribute	= new Map<String, Integer>( classifyByConsentStatus( lstAppointmentsReceived, setAccountIdsReceived, objUser ) );
		//	Map<String, Integer> mapDeliveredTotalConsentsByAttribute	= new Map<String, Integer>( classifyByConsentStatus( lstAppointmentsDelivered, setAccountIdsDelivered, objUser ) );
			
		//	mapAppointmentTotalsByAttribute.put( 'toReceive', String.valueOf( lstAppointmentsToReceive.size() ) );
		//	mapAppointmentTotalsByAttribute.put( 'received', String.valueOf( lstAppointmentsReceived.size() ) );
		//	mapAppointmentTotalsByAttribute.put( 'received_upd', String.valueOf( mapReceivedTotalConsentsByAttribute.get( 'updated' ) ) );
		//	mapAppointmentTotalsByAttribute.put( 'received_nupd', String.valueOf( mapReceivedTotalConsentsByAttribute.get( 'notUpdated' ) ) );
		//	mapAppointmentTotalsByAttribute.put( 'delivered', String.valueOf( lstAppointmentsDelivered.size() ) );
		//	mapAppointmentTotalsByAttribute.put( 'delivered_upd', String.valueOf( mapDeliveredTotalConsentsByAttribute.get( 'updated' ) ) );
		//	mapAppointmentTotalsByAttribute.put( 'delivered_nupd', String.valueOf( mapDeliveredTotalConsentsByAttribute.get( 'notUpdated' ) ) );
		
		//}catch( Exception e ){
		//	System.debug( '\n\n\n\t<<<<<<<<< ExceptionType >>>>>>>>> \n\t\t@@--> getCause > ' + e.getCause() + '\n\t\t@@--> getLineNumber > ' + e.getLineNumber() + '\n\t\t@@--> getMessage > '+ e.getMessage() + '\n\t\t@@--> getStackTraceString > '+ e.getStackTraceString() + '\n\t\t@@--> getTypeName > ' + e.getTypeName() + '\n\n' );
			
		//	mapAppointmentTotalsByAttribute.put( 'ERROR', '\n\n\n\t<<<<<<<<< ExceptionType >>>>>>>>> \n\t\t@@--> getCause > ' + e.getCause() + '\n\t\t@@--> getLineNumber > ' + e.getLineNumber() + '\n\t\t@@--> getMessage > '+ e.getMessage() + '\n\t\t@@--> getStackTraceString > '+ e.getStackTraceString() + '\n\t\t@@--> getTypeName > ' + e.getTypeName() + '\n\n' );
		//	return mapAppointmentTotalsByAttribute;
		//}
		
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
/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			AfterSales
* Description:		Server side controller to AfterSalesVehicleInterventions lightning component.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2018-10-01		Diego Rincon (DR)		Initial definition.
*********************************************************************************************************/
public with sharing class AfterSalesAppointmentPlanningController {
	
	/**
	* @Method: 		getAppointmentList
	* @param: 		String strRequest
	* @Description: Gets the appointments required to the an specific dealer planning.
	* @author 		Manuel Medina - 19062018
	*/
	@AuraEnabled 
	public static Map<String, Object> getAppointmentList( String strRequest ){
		Map<String, Object> mapRequest									= new Map<String, Object>( ( Map<String, Object> ) JSON.deserializeUntyped( strRequest ) );
		Map<Id, WorkshopAppointment__c> mapAppointmentToShowById		= new Map<Id, WorkshopAppointment__c>();
		Map<String, Object> mapResponse									= new Map<String, Object>{
																			'request'		=> mapRequest,
																			'hasError'		=> false,
																			'ERROR'			=> '',
																			'payload'		=> new List<WorkshopAppointment__c>()
																		};
																		
		mapRequest.put( 'strStartDate', ( String.isBlank( String.valueOf( mapRequest.get( 'strStartDate' ) ) ) ? System.today().addDays( 1 ) : mapRequest.get( 'strStartDate' ) ) );
		mapRequest.put( 'strEndDate', ( String.isBlank( String.valueOf( mapRequest.get( 'strEndDate' ) ) ) ? System.today().addDays( 2 ) : mapRequest.get( 'strEndDate' ) ) );
		
		mapResponse.put( 'request', mapRequest );
		mapResponse.put( 'strStartDate', mapRequest.get( 'strStartDate' ) );
		mapResponse.put( 'strEndDate', mapRequest.get( 'strEndDate' ) );
		
		try{
			User objUser												= new User();
			objUser														= [SELECT
																				Id,
																				Name,
																				Contact.AccountId
																			FROM User
																			WHERE Id =: UserInfo.getUserId()
																			LIMIT 1
																		];
																		
			List<User> lstReceptionists									= new List<User>();
			lstReceptionists.add( new User() );
			lstReceptionists.add( objUser );
			
			lstReceptionists.addAll( [
				SELECT Id,
					Name
				FROM User
				WHERE Contact.AccountId =: objUser.Contact.AccountId
				AND IsActive = true
				AND Id !=: objUser.Id
			] );
																		
			Map<Id, WorkshopAppointment__c> mapAppointmentById			= new Map<Id, WorkshopAppointment__c>( [
																			SELECT Id,
																				OwnerId,
																				Asset__c
																			FROM WorkshopAppointment__c
																			WHERE Workshop__c =: objUser.Contact.AccountId
																			AND ReceptionDatetime__c >=: Datetime.newInstanceGmt( Date.valueOf( String.valueOf( mapRequest.get( 'strStartDate' ) ) ), Time.newInstance( 0, 0, 0, 0 ) )
																			AND ReceptionDatetime__c <=: Datetime.newInstanceGmt( Date.valueOf( String.valueOf( mapRequest.get( 'strEndDate' ) ) ), Time.newInstance( 0, 0, 0, 0 ) )
																			AND AppointmentStatus__c IN: new Set<String>( ( Set<String> ) JSON.deserialize( String.valueOf( mapRequest.get( 'strStatusSelected' ) ), Set<String>.class ) )
																			AND TECH_SBConfirmation__c = true
																			ORDER BY ReceptionDatetime__c ASC
																		] );
																		
			Set<Id> setAssetIds											= new Set<Id>();
			for( WorkshopAppointment__c objAppointment : mapAppointmentById.values() ){
				setAssetIds.add( objAppointment.Asset__c );
			}
																		
			Map<Id, UserRecordAccess> mapAppointmentAccessById			= new Map<Id, UserRecordAccess>( [
																			SELECT RecordId,
																				HasReadAccess
																			FROM UserRecordAccess
																			WHERE UserId =: UserInfo.getUserId()
																			AND RecordId IN: setAssetIds
																		] );
																		
			for( WorkshopAppointment__c objAppointment : mapAppointmentById.values() ){
				if( ( mapRequest.get( 'strReceptionistSelected' ) != null && ( String.valueOf( mapRequest.get( 'strReceptionistSelected' ) ).equals( 'all' ) || ( !String.valueOf( mapRequest.get( 'strReceptionistSelected' ) ).equals( 'all' ) ) && String.valueOf( mapRequest.get( 'strReceptionistSelected' ) ).startsWith( objAppointment.OwnerId ) ) ) && mapAppointmentAccessById.containsKey( objAppointment.Asset__c ) && mapAppointmentAccessById.get( objAppointment.Asset__c ).HasReadAccess ){
					mapAppointmentToShowById.put( objAppointment.Id, objAppointment );
				}
			}

			AfterSalesHeaderAssetController.getAlerts( mapAppointmentToShowById.keySet() );
			
			mapResponse.put(
				'payload',
				[
					SELECT Id,
						Name,
						OwnerId,
						AppointmentStatus__c,
						toLabel( AppointmentStatus__c ) appointmentStatus,
						AppointmentType__c,
						toLabel( AppointmentType__c ) appointmentType,
						ReceptionDatetime__c,
						FORMAT( ReceptionDatetime__c ) receptionDatetime,
						RestitutionDatetime__c,
						FORMAT( RestitutionDatetime__c ) restitutionDatetime,
						ReceptionReceptionist__c,
						ReceptionReceptionistId__c,
						ReceptionReceptionistId__r.Name,
						NextBestActions__c,
						FileId__c,
						Driver__c,
						Driver__r.Name,
						Asset__c,
						Asset__r.Brand__c,
						Asset__r.Model__c,
						Asset__r.LastKnownRegistrationNumber__c,
						Asset__r.RealMileage__c
					FROM WorkshopAppointment__c
					WHERE Id IN: mapAppointmentToShowById.keySet()
				]
			);
			mapResponse.put( 'receptionists', lstReceptionists );
			
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
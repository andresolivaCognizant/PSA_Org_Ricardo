({
	doInit : function(component, event, helper){
		debugger;
		var action										= component.get( "c.getConsentsOutdated" );
		
		action.setCallback( this, function( response ) {
			var state									= response.getState();
			
			if(state === "SUCCESS") {
				if( response.getReturnValue().lstConsentsOutdated[0].strError != undefined ){
					console.log( "doInit > Error message: " + response.getReturnValue()[0].strError );
					
				}else{
					component.set( "v.columns", [
						{
							label: $A.get( "$Label.c.AfterSalesConsentManagement" ),
							fieldName: "id",
							type: "url",
							typeAttributes: {
								label: {
									fieldName: "name"
								},
								target: "_self"
							}
						},
						{
							label: response.getReturnValue().mapFieldLabelByAPIName.Name,
							fieldName: "accountId",
							type: "url",
							typeAttributes: {
								label: {
									fieldName: "accountName"
								},
								target: "_self"
							}
						},
						{
							label: response.getReturnValue().mapFieldLabelByAPIName.AppointmentStatus__c,
							fieldName: "status",
							type: "text"
						},
						{
							label: response.getReturnValue().mapFieldLabelByAPIName.ReceptionReceptionist__c,
							fieldName: "receptionist",
							type: "text"
						},
						{
							label: response.getReturnValue().mapFieldLabelByAPIName.Model__c,
							fieldName: "model",
							type: "text"
						},
						{
							label: response.getReturnValue().mapFieldLabelByAPIName.LastKnownRegistrationNumber__c,
							fieldName: "registrationNumber",
							type: "text"
						},
						{
							label: response.getReturnValue().mapFieldLabelByAPIName.VIN__c,
							fieldName: "vin",
							type: "text"
						}
					] );
				
					var consentsOutdated					= [];
				
					for( var i=0; i < response.getReturnValue().lstConsentsOutdated.length; i++ ){
						var consentOutdated					= {
																id					: "/PSADealer/s/detail/" + response.getReturnValue().lstConsentsOutdated[i].objAppointment.Id,
																name				: response.getReturnValue().lstConsentsOutdated[i].objAppointment.Name,
																receptionDate		: response.getReturnValue().lstConsentsOutdated[i].strReceptionDate != undefined ? response.getReturnValue().lstConsentsOutdated[i].strReceptionDate : "",
																status				: response.getReturnValue().lstConsentsOutdated[i].objAppointment.appointmentStatus != undefined ? response.getReturnValue().lstConsentsOutdated[i].objAppointment.appointmentStatus : "",
																receptionist		: response.getReturnValue().lstConsentsOutdated[i].objAppointment.ReceptionReceptionist__c != undefined ? response.getReturnValue().lstConsentsOutdated[i].objAppointment.ReceptionReceptionist__c : "",
																accountName			: response.getReturnValue().lstConsentsOutdated[i].objAppointment.Driver__c != undefined ? response.getReturnValue().lstConsentsOutdated[i].objAppointment.Driver__r.Name : "",
																accountId			: response.getReturnValue().lstConsentsOutdated[i].objAppointment.Driver__c != undefined ? "/PSADealer/s/detail/" + response.getReturnValue().lstConsentsOutdated[i].objAppointment.Driver__c : "",
																model				: response.getReturnValue().lstConsentsOutdated[i].objAppointment.Asset__c != undefined ? response.getReturnValue().lstConsentsOutdated[i].objAppointment.Asset__r.Model__c : "",
																registrationNumber	: response.getReturnValue().lstConsentsOutdated[i].objAppointment.Asset__c != undefined ? response.getReturnValue().lstConsentsOutdated[i].objAppointment.Asset__r.LastKnownRegistrationNumber__c : "",
																vin					: response.getReturnValue().lstConsentsOutdated[i].objAppointment.Asset__c != undefined ? response.getReturnValue().lstConsentsOutdated[i].objAppointment.Asset__r.VIN__c : ""
															};
					
						consentsOutdated.push( consentOutdated );
					}
	
					component.set( "v.consentsOutdated", consentsOutdated );
				}
				
			}else if (state === "ERROR") {
				var errors				= response.getError();
				
				if( errors ){
					if( errors[0] && errors[0].message ) {
						console.log( "doInit > Error message: " + errors[0].message );
					}
				}else {
					console.log( "doInit > Unknown error" );
				}
			}
		});

		$A.enqueueAction( action );
	},
	
	showSpinner:  function(component, event, helper){
		var divSpinner											= component.find( "divSpinnerConsents" );
		
		$A.util.removeClass( divSpinner, "slds-hide" );
		$A.util.addClass( divSpinner, "slds-show" );
	},
	
	hideSpinner: function(component, event, helper){
		var divSpinner											= component.find( "divSpinnerConsents" );
		
		$A.util.removeClass( divSpinner, "slds-show" );
		$A.util.addClass( divSpinner, "slds-hide" );
	}
})
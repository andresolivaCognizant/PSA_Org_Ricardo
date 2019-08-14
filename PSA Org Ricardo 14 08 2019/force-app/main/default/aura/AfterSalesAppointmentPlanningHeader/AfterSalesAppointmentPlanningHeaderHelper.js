({
	getDataTableColumns : function() {
		var cols = [
			{
				"label"     : $A.get( "$Label.c.AfterSalesPlanningColumn1" ) //receptionDateTime
			},
			{
				"label"     : $A.get( "$Label.c.AfterSalesPlanningColumn2" ) //receptionist
			},
			{
				"label"     : $A.get( "$Label.c.AfterSalesPlanningColumn11" ) //restitutionDatetime
			},
			{
				"label"     : $A.get( "$Label.c.AfterSalesPlanningColumn3" ) //status
			},
			{
				"label"     : $A.get( "$Label.c.AfterSalesPlanningColumn4" ) //brand + model
			},
			{
				"label"     : $A.get( "$Label.c.AfterSalesPlanningColumn5" ) //registrationNumber
			},
			{
				"label"     : $A.get( "$Label.c.AfterSalesPlanningColumn6" ) //mileage
			},
			{
				"label"     : $A.get( "$Label.c.AfterSalesPlanningColumn7" ) //type
			},
			{
				"label"     : $A.get( "$Label.c.AfterSalesPlanningColumn8" ) //accountName
			},
			{
				"label"     : $A.get( "$Label.c.AfterSalesPlanningColumn9" ) //dossier
			},
			{
				"label"     : $A.get( "$Label.c.AfterSalesPlanningColumn10" ) //nextBestActions
			}
		];

		return cols;
	},
	
	getStatusList : function() {
		var status = [
			{
				"label": $A.get( "$Label.c.AfterSalesPlanningStatus1" ),
				"value": "[1,2,3,4,5,6,7,8]"
			},
			{
				"label": $A.get( "$Label.c.AfterSalesPlanningStatus2" ),
				"value": "[1]"
			},
			{
				"label": $A.get( "$Label.c.AfterSalesPlanningStatus3" ),
				"value": "[2,3,4,7,8]"
			},
			{
				"label": $A.get( "$Label.c.AfterSalesPlanningStatus4" ),
				"value": "[5,6]"
			}
		];
		
		return status;
	},
	
	jsGetAppointmentList : function( component, event ) {
		var action							= component.get( "c.getAppointmentList" );
		var startDate						= component.get( "v.startDate" ) != undefined ? new Date( component.get( "v.startDate" ) ) : undefined;
		var endDate							= component.get( "v.endDate" ) != undefined ? new Date( component.get( "v.endDate" ) ) : undefined;

		if( startDate != undefined && endDate != undefined && endDate < startDate ){
			this.showToast( "", $A.get( "$Label.c.AfterSalesPlanningMessage1" ), "error", "dismissible" );
			
			component.set( "v.endDate", component.get( "v.endDate_tmp" ) );
			
			return;
		}else{
			component.set( "v.endDate_tmp", component.get( "v.endDate" ) );
		}

		var request							= {
												strStartDate			: component.get( "v.startDate" ),
												strEndDate				: component.get( "v.endDate" ),
												strStatusSelected		: component.get( "v.statusSelected" ),
												strReceptionistSelected	: component.get( "v.receptionistSelected" ) != undefined ? component.get( "v.receptionistSelected" ) : $A.get( "$SObjectType.CurrentUser.Id" )
											};
		
		action.setParams( {
			"strRequest": JSON.stringify( request )
		} );

		action.setCallback( this, function( response ){
			this.handleResponse( component, response );
		} );
		
		$A.enqueueAction( action );
	},
	
	handleResponse : function( component, response ){
		var state							= response.getState();
		
		switch( state ){

			case "SUCCESS":
				if( response.getReturnValue().hasError ){
					console.log( response.getReturnValue() );
					
				}else{
					var appointments			= [];
					
					for( var i=0; i < response.getReturnValue().payload.length; i++ ){
						var appointment			= {
													id						: "/PSADealer/s/workshopappointment/" + response.getReturnValue().payload[i].Id,
													receptionDateTime		: response.getReturnValue().payload[i].receptionDatetime,
													receptionist			: response.getReturnValue().payload[i].ReceptionReceptionist__c,
													restitutionDatetime		: response.getReturnValue().payload[i].RestitutionDatetime__c != undefined ? response.getReturnValue().payload[i].restitutionDatetime : "",
													status					: response.getReturnValue().payload[i].AppointmentStatus__c != undefined ? response.getReturnValue().payload[i].appointmentStatus : "",
													brand					: response.getReturnValue().payload[i].Asset__c != undefined && response.getReturnValue().payload[i].Asset__r.Brand__c != undefined ? response.getReturnValue().payload[i].Asset__r.Brand__c : "",
													model					: response.getReturnValue().payload[i].Asset__c != undefined && response.getReturnValue().payload[i].Asset__r.Model__c != undefined ? response.getReturnValue().payload[i].Asset__r.Model__c : "",
													registrationNumber		: response.getReturnValue().payload[i].Asset__c != undefined && response.getReturnValue().payload[i].Asset__r.LastKnownRegistrationNumber__c != undefined ? response.getReturnValue().payload[i].Asset__r.LastKnownRegistrationNumber__c : "",
													mileage					: response.getReturnValue().payload[i].Asset__c != undefined && response.getReturnValue().payload[i].Asset__r.RealMileage__c != undefined ? response.getReturnValue().payload[i].Asset__r.RealMileage__c : "",
													type					: response.getReturnValue().payload[i].AppointmentType__c != undefined ? response.getReturnValue().payload[i].appointmentType : "",
													accountName				: response.getReturnValue().payload[i].Driver__c != undefined ? response.getReturnValue().payload[i].Driver__r.Name : "",
													accountId				: response.getReturnValue().payload[i].Driver__c != undefined ? "/PSADealer/s/detail/" + response.getReturnValue().payload[i].Driver__c : "",
													dossier					: response.getReturnValue().payload[i].FileId__c != undefined ? response.getReturnValue().payload[i].FileId__c : "",
													nextBestActions			: response.getReturnValue().payload[i].NextBestActions__c != undefined ? response.getReturnValue().payload[i].NextBestActions__c.replace( new RegExp( "resource", "g" ), "PSADealer/resource" ) : ""
												};
					
						appointments.push( appointment );
					}
					
					response.getReturnValue().receptionists[0]		= { Name : $A.get( "$Label.c.AfterSalesPlanningStatus1" ), Id : "all" };
	
					component.set( "v.data", appointments );
					component.set( "v.startDate", response.getReturnValue().strStartDate );
					component.set( "v.endDate", response.getReturnValue().strEndDate );
					component.set( "v.endDate_tmp", response.getReturnValue().strEndDate );
					
					if( component.get( "v.receptionists" ) == undefined || component.get( "v.receptionists" ) == "" ){
						component.set( "v.receptionists", response.getReturnValue().receptionists );
					}
				}
				
				break;
	
			case "INCOMPLETE":
				// do something
				break;
	
			case "ERROR":
				var errors					= response.getError();
				
				if( errors ){
					if( errors[0] && errors[0].message ) {
						console.log( "Error message: " + errors[0].message );
					} 
				} else {
					console.log( "Unknown error" );
				}
		}

		this.hideSpinner( component );
	},
	
	showToast : function( msgTitle, msg, msgType, msgMode ) {
		var toastEvent						= $A.get( "e.force:showToast" );
		var availableModes					= "dismissible&pester&sticky";
		var availableTypes					= "info&success&warning&error";
		
		toastEvent.setParams( {
			title : msgTitle,
			message: msg,
			duration: "5000",
			key: "info_alt",
			type: availableTypes.includes( msgType ) ? msgType : "info",
			mode: availableModes.includes( msgMode ) ? msgMode : "pester"
		} );
		
		toastEvent.fire();
	},

	addPrintButton : function( component ){
		var headerCard_btnContainer					= component.find( "headerCard" ).find( "buttonContainer" );
		
		$A.createComponent(
			"lightning:button",
			{
				"aura:id": "btnPrint",
				"label": $A.get( "$Label.c.AfterSalesPlanningPrintButton" ),
				"variant": "neutral",
				"value": "Print",
				"onclick": component.getReference( "c.print" )
			},
			function( newButton, status, errorMessage ){
				if (status === "SUCCESS") {
					var body						= headerCard_btnContainer.get( "v.body" );
					body.push( newButton );
					headerCard_btnContainer.set( "v.body", body );
					$A.util.addClass( headerCard_btnContainer, "noprint" );
				}
				else if (status === "INCOMPLETE") {
					console.log( "No response from server or client is offline." );
				}
				else if (status === "ERROR") {
					console.log( "Error: " + errorMessage );
				}
			}
		);
	},

	showSpinner : function( component ){
		$A.util.removeClass( component.find( "LoadingSpinner" ), "slds-hide" );
		$A.util.addClass( component.find( "LoadingSpinner" ), "slds-show" );
	},
	
	hideSpinner : function( component ){
		$A.util.removeClass( component.find( "LoadingSpinner" ), "slds-show" );
		$A.util.addClass( component.find( "LoadingSpinner" ), "slds-hide" );
	}
})
({
	handleRecordUpdated: function(component, event, helper) {
		var changeType = event.getParams().changeType;

		if (changeType === "ERROR") { /* handle error */ }
		else if (changeType === "LOADED") { /* handle record load */
			component.find( "customMetadataRecords" ).getRecords(
				"APVHeaderConsentsActions__mdt",
				[ 'ShowToast__c', 'ShowHighlightedIcon__c' ],
				"",
				true,
				function( result ) {
					component.set( "v.activeActionsByName", result );
				}
			);
			
			component.find( "fieldLabels" ).getFieldLabels(
				[ 'Account.MobilePersonalTelephone__pc', 'Account.MobileProfessionalTelephone__pc', 'Account.PersonEmail', 'Opportunity.Name', 'et4ae5__IndividualEmailResult__c.et4ae5__DateSent__c', 'et4ae5__IndividualEmailResult__c.et4ae5__DateOpened__c' ],
				function( result ) {
					component.set( "v.fieldLabels", result );
				}
			);

			helper.ldsOnLoad(component);
			helper.getMyBrandSettings(component);
			
			if( component.get( "v.wa.fields.AppointmentType__c.value" ) === "5" ){
				helper.addCustomerReceptionButton( component, event, helper );
			}
			
			component.find( "appointmentURLs" ).getRecords(
				[ 'APPOINTMENT' ],
				[ 'QuickReception_URL', 'Estimation_URL' ],
				function( result ) {
					component.set( "v.attributesByGlobalSetting", result );
				}
			);

			var action = component.get("c.getAppointmentInfo");
			action.setParams({
				"req": JSON.stringify({
					"ids": [component.get("v.wa.fields.Id.value")]
				})
			});

			action.setCallback(this, function(response) {
				helper.hasChanged(component, response, null);
				var js_action = component.get("c.setPolling");
				$A.enqueueAction(js_action);
			});
			$A.enqueueAction(action);

		}
	},

	onViewDetail : function ( component, event, helper ) {
		var htmlId    = event.target.id;
		var urlEvent  = $A.get("e.force:navigateToURL");
		urlEvent.setParams({
			"url": "/", /* To complete. Waiting for MKT team to provide the way to get the picture */
		});
		urlEvent.fire();
	},

	updateContactAcceptance: function(component, event, helper) {
		var e = component.find("_contactAcceptance").getElement();
		component.set("v.wa.fields.ContactAcceptance__c.value", e.checked)

		e.setAttribute("disabled", "true");

		component.find("forceRecord").saveRecord();
	},

	showConsentModal: function(component, event, helper) {
		event.preventDefault();

		if (null != component.get("v.timerId")) {
			clearInterval(component.get("v.timerId"));
		}
		
		helper.createConsentModal(component, component.get("v.wa.fields.Driver__c.value"))
		
		var t = window.setInterval(
			$A.getCallback(function() {
				component.set("v.timerId", t);
				helper.getAllRecords( component, 'Consents', component.get("v.recordId"), true );
				
				if (component.get("v.metricsData")[0].Consentement > 0) {
					clearInterval(t);
				}
			}),
			5000
		);

	},

	redirectToRecord : function( component, event, helper ){
		var htmlId  = event.target.id;
		var navEvt  = $A.get( "e.force:navigateToSObject" );
		var objId   = "";

		if( htmlId.includes( "opp_" ) ){
			objId = component.get( "v.Opportunities" )[ htmlId.split( "_" )[1] ].Id;
		}

		if( objId != "" ){
			navEvt.setParams( {
				"recordId": objId,
				"slideDevName": "detail"
			} );

			navEvt.fire();
		}
	},

	reloadOpportunities : function( component, event, helper ) {
		if( event.getParam( "reloadOpps" ) ){
			helper.getAllRecords( component, 'Opportunity', event.getParam( "assetId" ) );
		}
	},

	updateMyBrandInvitation: function(component, event, helper) {
		var e = component.find("_boxMyM").getElement();
		component.set("v.wa.fields.MyM_Invitation__c.value", e.checked)

		e.setAttribute("disabled", "true");
		component.find("forceRecord").saveRecord(function() {
			component.find("forceRecord").reloadRecord();
		});

	},

	setPolling : function(component, event, helper) {
		var t = window.setInterval(
			$A.getCallback(function() { 

				var action = component.get("c.getAppointmentInfo");
	
				if (action) {
					action.setParams({
						"req": JSON.stringify({
							"ids": [component.get("v.wa.fields.Id.value")]
						})
					});
					action.setCallback(this, function(response) {
						helper.hasChanged(component, response, t);
					});
					$A.enqueueAction(action);
				}
			}),
			10000
		);
	},

	redirectToPanier : function( component, event ) {
		event.preventDefault();
		
		var navURL			= $A.get( "e.force:navigateToURL" );
				
		navURL.setParams( {
			"url" : component.get( "v.attributesByGlobalSetting.APPOINTMENT.QuickReception_URL" )
		} );
		
		navURL.fire();
	},
	
	handleDates : function( component, event, helper ){
		var changeType = event.getParams().changeType;

		if(changeType === "ERROR") { /* handle error */ }
		else if(changeType === "LOADED") { /* handle record load */
			component.set( "v.objAccount.fields.LastModifiedDate.formatedDate", component.get( "v.objAccount.fields.LastModifiedDate.displayValue" ).split( " " )[0] );
			component.set( "v.objAccount.fields.SystemModstamp.formatedDate", component.get( "v.objAccount.fields.SystemModstamp.displayValue" ).split( " " )[0] );
		}
	},
	
	editRecord : function( component, event, helper ){
		event.preventDefault();
	
		var htmlId								= event.target != undefined ? event.target.id : event.getSource().getLocalId();
		var objId								= "";
		var editRecordEvent						= $A.get( "e.force:editRecord" );
		
		if( htmlId == "editAccount" ){
			objId								= component.get( "v.metricsData[0].Id" );
		}
		
		editRecordEvent.setParams( {
			"recordId": objId
		} );
		
		editRecordEvent.fire();
	},
	callDMS : function( component, event, helper ){
		helper.startDMScall(component);
	}
})
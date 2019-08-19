( {
	dataServiceOnLoad : function( component, event ) {
		var self						= this;
		var action						= component.get( "c.getAssetProperties" );

		action.setParams( {
			"assetId": component.get( "v.currentRecord" ) != undefined ? component.get( "v.currentRecord" ).fields.Id.value : component.get( "v.recordId" )
		} );

		action.setCallback( this, function( response ) {
			var state = response.getState();
			if ( state === "SUCCESS" ) {
				component.set( "v.relatedRecordData", response.getReturnValue() );
				console.log( "Server data " + JSON.stringify( component.get( "v.relatedRecordData" ) ) );
				component.set( 
					"v.carURL", 
					this.setCarURL( 
						component.get( "v.carURL" ), 
						component.get( "v.currentRecord.fields.Brand__c.displayValue" ), 
						component.get( "v.currentRecord.fields.LCDV16__c.value" ), 
						component.get( "v.currentRecord.fields.ExteriorTrimColorCode__c.value" )
					 )
				);
				
				var lstServiceContracts					= component.get( "v.relatedRecordData.lstServiceContracts" );
				 
				lstServiceContracts.forEach( function( serviceContract ){
					serviceContract.ContractLineItems.forEach( function( lineItem ) {
						lineItem.productName			= lineItem.Product2.Name;
					} );
				} );
				
				component.set( "v.relatedRecordData.lstServiceContracts", lstServiceContracts );
				component.set( "v.showOwnerIdDMSIcon", response.getReturnValue().strOwnerIdDMS === undefined );
				component.set( "v.showKeeperIdDMSIcon", response.getReturnValue().strKeeperIdDMS === undefined );

				self.handleWARecord( component, event );
			}
			else if ( state === "INCOMPLETE" ) {
			}
			else if ( state === "ERROR" ) {
				var errors = response.getError();
				if ( errors ) {
					if ( errors[0] && errors[0].message ) {
						console.log( "Error message: " + errors[0].message );
					}
				} else {
					console.log( "Unknown error" );
				}
			}
		} );

		$A.enqueueAction( action );
	},
	
	getAlerts : function( component ) {
		var self						= this;
		var action						= component.get( "c.getAlerts" );
		var request						= {
											strCurrentAppointmentId	: component.get( "v.wa.fields.Id.value" ),
											strCountry				: component.get( "v.currentRecord.fields.Country__c" ) != undefined ? component.get( "v.currentRecord.fields.Country__c.value" ) : null,
											strBrand				: component.get( "v.currentRecord.fields.Brand__c" ) != undefined ? component.get( "v.currentRecord.fields.Brand__c.value" ) : null,
											strType					: component.get( "v.currentRecord.fields.AssetType__c" ) != undefined ? component.get( "v.currentRecord.fields.AssetType__c.value" ) : null
										};
		
		action.setParams( {
			"strRequest": JSON.stringify( request )
		} );
		
		action.setCallback( this, function( response ) {
			var state					= response.getState();

			if( state === "SUCCESS" ) {
				console.log( response.getReturnValue() );
			
				if( response.getReturnValue().hasError ){
					console.log( response.getReturnValue().ERROR );
					
				}else{
					component.set( "v.alerts.hasAlert1", response.getReturnValue().hasAlert1 );
					component.set( "v.alerts.hasAlert2", response.getReturnValue().hasAlert2 );
					component.set( "v.alerts.hasAlert3", response.getReturnValue().hasAlert3 );
					component.set( "v.alerts.alert1Tooltip", response.getReturnValue().alert1Tooltip );
					component.set( "v.alerts.alert3Tooltip", response.getReturnValue().alert3Tooltip );
					component.set( "v.isReturn", response.getReturnValue().isReturn );
					component.set( "v.warrantyColor", response.getReturnValue().warrantyColor );
					component.set( "v.maintenanceColor", response.getReturnValue().maintenanceColor );
					component.set( "v.closeToWarrantyEndDate", response.getReturnValue().closeToWarrantyEndDate == "true" );
					component.set( "v.oldVehicle", response.getReturnValue().oldVehicle == "true" );

					if( component.get( "v.closeToWarrantyEndDate" ) ){
						self.getOppAllowed( component );
					}
				}
				
			}else if ( state === "ERROR" ) {
				var errors				= response.getError();
				
				if( errors ){
					if( errors[0] && errors[0].message ) {
						console.log( "getAlerts > Error message: " + errors[0].message );
					}
				}else {
					console.log( "getAlerts > Unknown error" );
				}
			}
		} );

		$A.enqueueAction( action );
	},
	
	getOppAllowed : function( component ) {
		var action						= component.get( "c.allowOpportunities" );
		var request						= {
											strAccountId			: component.get( "v.wa.fields.Owner__c.value" ),
											strVIN					: component.get( "v.currentRecord.fields.VIN__c.value" ),
											strBrand				: component.get( "v.currentRecord.fields.Brand__c" ) != undefined ? component.get( "v.currentRecord.fields.Brand__c.value" ) : null,
											strCountry				: component.get( "v.currentRecord.fields.Country__c" ) != undefined ? component.get( "v.currentRecord.fields.Country__c.value" ) : null,
											strPurchaseDate			: component.get( "v.currentRecord.fields.PurchaseDate" ) != undefined ? component.get( "v.currentRecord.fields.PurchaseDate.value" ) : null,
											strWarrantyStartDate	: component.get( "v.currentRecord.fields.WarrantyBeginDate__c" ) != undefined ? component.get( "v.currentRecord.fields.WarrantyBeginDate__c.value" ) : null,
											strWarrantyEndDate		: component.get( "v.currentRecord.fields.WarrantyEndDate__c" ) != undefined ? component.get( "v.currentRecord.fields.WarrantyEndDate__c.value" ) : null,
											strLastMaintenanceDate	: component.get( "v.currentRecord.fields.LastMaintenanceDate__c" ) != undefined ? component.get( "v.currentRecord.fields.LastMaintenanceDate__c.value" ) : null
										};
		
		action.setParams( {
			"strRequest": JSON.stringify( request )
		} );
		
		action.setCallback( this, function( response ) {
			var state					= response.getState();

			if( state === "SUCCESS" ){
				console.log( response.getReturnValue() );
			
				if( response.getReturnValue().hasError ){
					console.log( response.getReturnValue().ERROR );
					
				}else{
					component.set( "v.warrantyOpp", response.getReturnValue().warrantyOpp );
					component.set( "v.maintOpp", response.getReturnValue().maintOpp );
				}
			
			}else if( state === "INCOMPLETE" ){
			
			}else if( state === "ERROR" ){
				var errors						= response.getError();
				
				if( errors && errors[0] && errors[0].message ){
					console.log( "Error message: " + errors[0].message );
				}else{
					console.log( "Unknown error" );
				}
			}
		} );

		$A.enqueueAction( action );
	},
	
	getUrlParameter : function getUrlParameter( sParam ) {
		var sPageURL = decodeURIComponent( window.location.search.substring( 1 ) ),
			sURLVariables = sPageURL.split( "&" ),
			sParameterName,
			i;
		
		for( i = 0; i < sURLVariables.length; i++ ){
			sParameterName = sURLVariables[i].split( "=" );
			if ( sParameterName[0] === sParam ) {
				return sParameterName[1] === undefined ? true : sParameterName[1];
			}
		}
	},
	
	setCarURL : function( baseURL, brand, version, color ) {
		baseURL												= baseURL.replace( "{!BRAND}", brand ).replace( "{!VERSION}", version ).replace( "{!COLOR}", color );
		
		return baseURL;
	},
	
	getContractLineItemsColumns : function( component ){
		return [
			{
				label: component.get( "v.fieldLabels.Product2.Name" ),
				fieldName: "productName",
				type: "text"
			},
			{
				label: component.get( "v.fieldLabels.ContractLineItem.LineItemNumber" ),
				fieldName: "LineItemNumber",
				type: "text"
			},
			{
				label: component.get( "v.fieldLabels.ContractLineItem.StartDate" ),
				fieldName: "fStartDate",
				type: "text"
			},
			{
				label: component.get( "v.fieldLabels.ContractLineItem.EndDate" ),
				fieldName: "fEndDate",
				type: "text"
			},
			{
				label: component.get( "v.fieldLabels.ContractLineItem.SubscribedDuration__c" ),
				fieldName: "SubscribedDuration__c",
				type: "number"
			},
			{
				label: component.get( "v.fieldLabels.ContractLineItem.SubscribedMileage__c" ),
				fieldName: "SubscribedMileage__c",
				type: "number"
			},
			{
				label: component.get( "v.fieldLabels.ContractLineItem.Quantity" ),
				fieldName: "Quantity",
				type: "number"
			},
			{
				label: component.get( "v.fieldLabels.ContractLineItem.Quantity__c" ),
				fieldName: "Quantity__c",
				type: "number"
			}
		];
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
	
	showSpinner : function( component ){
		var divSpinner						= component.find( "divSpinner" );
		
		$A.util.removeClass( divSpinner, "slds-hide" );
		$A.util.addClass( divSpinner, "slds-show" );
	},
	
	hideSpinner : function( component ){
		var divSpinner						= component.find( "divSpinner" );
		
		$A.util.removeClass( divSpinner, "slds-show" );
		$A.util.addClass( divSpinner, "slds-hide" );
	},
	
	fireOppEvent : function( component ){
		var appEvent						= $A.get( "e.c:AfterSalesOpportunityEvent" );
		
		appEvent.setParams( {
			"reloadOpps" : true,
			"assetId" : component.get( "v.currentRecord.fields.Id.value" )
		} );
		
		appEvent.fire();
	},
	
	handleSaveRecord : function( component, event, validateNewRealMileage, fromAssetPopup, caseNum ){
		var self												= this;
		var waRealMileage										= component.get( "v.wa.fields.RealMileage__c.value" );
		var assetRealMileage									= component.get( "v.currentRecord.fields.RealMileage__c.value" );
		var assetRealMileageSource								= component.get( "v.currentRecord.fields.RealMileageSource__c.value" );
		var assetRealMileageDate								= component.get( "v.currentRecord.fields.RealMileageDate__c.value" );
		var today												= new Date();
		var todayString											= today.getFullYear() + "-" + ( ( today.getMonth() + 1 ) < 10 ? "0" + ( today.getMonth() + 1 ) : today.getMonth() + 1 ) + "-" + ( today.getDate() < 10 ? "0" + today.getDate() : today.getDate() );
		
		if( validateNewRealMileage && (
				(
					!fromAssetPopup &&
					waRealMileage < assetRealMileage &&
					assetRealMileageSource === "APV"
				) || (
					fromAssetPopup &&
					waRealMileage > assetRealMileage &&
					assetRealMileageSource === "APV"
				) || (
					assetRealMileageDate === todayString &&
					waRealMileage > assetRealMileage && (
						assetRealMileageSource === 'BTA' || assetRealMileageSource === 'DIA'
					)
				)
			)
		){
			if( fromAssetPopup ){
				this.editModeOn( component, null );
				component.set( "v.waOldRealMileage", component.get( "v.wa.fields.RealMileage__c.value" ) );
				component.set( "v.wa.fields.RealMileage__c.value", assetRealMileage );
			}
			component.set( "v.recordError", $A.get( "$Label.c.AfterSalesNewRealMileageMessage" ) );
			component.set( "v.showErrors", true );
			component.set( "v.validateRealMileage", true );
			
			return;
			
		}else{
			if( window.location.search.includes( "vld=1" ) && component.get( "v.wa.fields.RealMileage__c.value" ) != undefined && component.get( "v.waOldRealMileage" ) == undefined ){
				component.set( "v.wa.fields.RealMileage__c.value", assetRealMileage );
				component.find( "forceWorkshopAppointment" ).saveRecord(
					$A.getCallback(
						function( saveResult ){
							if( saveResult.state === "SUCCESS" || saveResult.state === "DRAFT" ){
								component.find( "forceWorkshopAppointment" ).reloadRecord( true );
								component.find( "forceRecord" ).reloadRecord( true );
							}
						}
					)
				);
			}
			component.set( "v.recordError", "" );
			component.set( "v.showErrors", false );
			component.set( "v.validateRealMileage", false );
		}

		if( ( caseNum === 0 && !window.location.search.includes( "vld=1" ) && component.get( "v.wa.fields.RealMileage__c.value" ) != undefined && component.get( "v.wa.fields.RealMileage__c.value" ) == assetRealMileage ) ||
			( window.location.search.includes( "vld=1" ) && component.get( "v.wa.fields.RealMileage__c.value" ) != undefined && component.get( "v.waOldRealMileage" ) == undefined ) ){
			return;
		}
	
		var divSpinner											= component.find( "divSpinner" );
		
		$A.util.removeClass( divSpinner, "slds-hide" );
		$A.util.addClass( divSpinner, "slds-show" );
	
		var reloadRecord										= setTimeout(
			$A.getCallback( function(){
				component.find( "forceWorkshopAppointment" ).reloadRecord( true );
				component.find( "forceRecord" ).reloadRecord( true, self.hideSpinner( component ) );
			} ),
			10000
		);
		
		this.createVehicleEvent( component, component.get( "v.wa.fields.RealMileage__c.value" ), reloadRecord );
	},
	
	createVehicleEvent : function( component, realMileage, reloadRecord ){
		var self								= this;
		var action								= component.get( "c.createVehicleEvent" );
		var request								= {
													strAssetId		: component.get( "v.wa.fields.Asset__c.value" ),
													strRealMileage	: realMileage
												};

		action.setParams( {
			"strRequest": JSON.stringify( request ),
		} );
		
		action.setCallback( this, function( response ){
			var state							= response.getState();
			
			if( state === "SUCCESS" ){
				console.log( response.getReturnValue() );
			
				if( response.getReturnValue().hasError ){
					console.log( "ERROR " + response.getReturnValue().ERROR );
					
					component.set( "v.recordError", response.getReturnValue().ERROR.message );
					component.set( "v.showErrors", true );
					
					clearTimeout( reloadRecord );
					
					self.editModeOn( component, null );
					self.hideSpinner( component );
					
				}else{
					self.updateAppointment( component );
				}
				
			}else if( state === "INCOMPLETE" ){
			
			}else if( state === "ERROR" ){
				var errors						= response.getError();
				
				if( errors && errors[0] && errors[0].message ){
					console.log( "Error message: " + errors[0].message );
				}else{
					console.log( "Unknown error" );
				}
			}
		} );

		$A.enqueueAction( action );
	},
	
	updateAppointment : function( component ){
		var self												= this;
	
		component.find( "forceWorkshopAppointment" ).saveRecord(
			$A.getCallback( 
				function( saveResult ){
					var divSpinner								= component.find( "divSpinner" );
				
					if( saveResult.state === "SUCCESS" || saveResult.state === "DRAFT" ){
						var cmpEdit								= component.find( "kmEditButtons" );
						var cmpEditField						= component.find( "editField" );
						var cmpEditButton						= component.find( "editButton" );
						
						$A.util.removeClass( cmpEdit, "slds-show" );
						$A.util.addClass( cmpEdit, "slds-hide" );
						
						$A.util.removeClass( cmpEditField, "slds-show" );
						$A.util.addClass( cmpEditField, "slds-hide" );
						
						$A.util.removeClass( cmpEditButton, "slds-hide" );
						$A.util.addClass( cmpEditButton, "slds-show" );
						
						component.set( "v.recordError", "" );
						
					}else if( saveResult.state === "INCOMPLETE" ){
						console.log( "User is offline, device doesn't support drafts." );
						
					}else if( saveResult.state === "ERROR" ){
						self.hideSpinner( component );
						
						console.log( "Problem saving record, error: " + JSON.stringify( saveResult.error ) );
						
						if( saveResult.error && saveResult.error[0] && saveResult.error[0].message ){
							component.set( "v.recordError", saveResult.error[0].message );
							
						}else if( saveResult.error && saveResult.error[0] && saveResult.error[0].pageErrors && saveResult.error[0].pageErrors[0] && saveResult.error[0].pageErrors[0].message ){
							component.set( "v.recordError", saveResult.error[0].pageErrors[0].message );
						}
						
						component.set( "v.showErrors", true );
						
					}else{
						console.log( "Unknown problem, state: " + saveResult.state + ", error: " + JSON.stringify( saveResult.error ) );
					}
				}
			 ) 
		 );
	},
	
	editModeOn : function( component, event ){
		var cmpEdit								= component.find( "kmEditButtons" );
		var cmpEditField						= component.find( "editField" );
		var cmpEditButton						= component.find( "editButton" );

		if( event != undefined ){
			component.set( "v.waOldRealMileage", component.get( "v.wa.fields.RealMileage__c.value" ) );
		}
		
		$A.util.removeClass( cmpEdit, "slds-hide" );
		$A.util.addClass( cmpEdit, "slds-show" );
		
		$A.util.removeClass( cmpEditField, "slds-hide" );
		$A.util.addClass( cmpEditField, "slds-show" );
		
		$A.util.removeClass( cmpEditButton, "slds-show" );
		$A.util.addClass( cmpEditButton, "slds-hide" );
	},
	
	editModeOff : function( component ){
		var cmpEdit								= component.find( "kmEditButtons" );
		var cmpEditField						= component.find( "editField" );
		var cmpEditButton						= component.find( "editButton" );
		
		$A.util.removeClass( cmpEdit, "slds-show" );
		$A.util.addClass( cmpEdit, "slds-hide" );
		
		$A.util.removeClass( cmpEditField, "slds-show" );
		$A.util.addClass( cmpEditField, "slds-hide" );
		
		$A.util.removeClass( cmpEditButton, "slds-hide" );
		$A.util.addClass( cmpEditButton, "slds-show" );
		
		this.handleAssetRecord( component );
		
		component.set( "v.recordError", "" );
		component.set( "v.showErrors", false );
		component.set( "v.validateRealMileage", false );
	},
	
	addEditLink : function( component ){
		var headerLine1									= component.find( "assetHeader" ).find( "headerLine1" );
		var registrationNumber							= component.get( "v.currentRecord.fields.LastKnownRegistrationNumber__c.value" ) != undefined ? component.get( "v.currentRecord.fields.LastKnownRegistrationNumber__c.value" ) : "";
		
		$A.createComponent(
			"lightning:formattedText",
			{
				"aura:id"	: "editAsset",
				"value"		: $A.get( "$Label.c.AfterSalesAssetCardTittle1" ) + " " + registrationNumber,
				"title"		: $A.get( "$Label.c.AfterSalesEditTooltip" ),
				"onclick"	: component.getReference( "c.editRecord" ),
				"class"		: "edit_link"
			},
			function( e, status, errorMessage ){
				if (status === "SUCCESS") {
					var body							= [];
					body.push( e );
					headerLine1.set( "v.body", body );
				}
				else if (status === "INCOMPLETE") {
					console.log("No response from server or client is offline.")
				}
				else if (status === "ERROR") {
					console.log("Error: " + errorMessage);
				}
			}
		);
	},

	handleWARecord : function( component, event ){
		if( window.location.search.includes( "vld=1" ) && component.get( "v.validateRealMileagePopup" ) ){
			this.handleSaveRecord( component, event, true, true, 0 );
			component.set( "v.validateRealMileagePopup", false );

		}else if( !window.location.search.includes( "vld=1" ) && component.get( "v.validateRealMileagePopup" ) && component.get( "v.currentRecord.fields.RealMileage__c.value" ) != component.get( "v.wa.fields.RealMileage__c.value" ) ){
			this.handleSaveRecord( component, event, true, true, 1 );
			component.set( "v.validateRealMileagePopup", false );
		}
	},

	handleAssetRecord : function( component ){
		if( component.get( "v.waOldRealMileage" ) != undefined && component.get( "v.currentRecord.fields.RealMileage__c.value" ) != component.get( "v.waOldRealMileage" ) ){
			component.set( "v.currentRecord.fields.RealMileage__c.value", component.get( "v.waOldRealMileage" ) );

			component.find( "forceRecord" ).saveRecord(
				$A.getCallback(
					function( saveResult ){
						if( saveResult.state === "SUCCESS" || saveResult.state === "DRAFT" ){
							component.find( "forceWorkshopAppointment" ).reloadRecord( true );
							component.find( "forceRecord" ).reloadRecord( true );
						}
					}
				)
			);
		}

		if( component.get( "v.waOldRealMileage" ) != undefined ){
			component.set( "v.wa.fields.RealMileage__c.value", component.get( "v.waOldRealMileage" ) );
			component.find( "forceWorkshopAppointment" ).saveRecord(
				$A.getCallback(
					function( saveResult ){
						if( saveResult.state === "SUCCESS" || saveResult.state === "DRAFT" ){
							component.find( "forceWorkshopAppointment" ).reloadRecord( true );
							component.find( "forceRecord" ).reloadRecord( true );
						}
					}
				)
			);
			component.set( "v.waOldRealMileage", undefined );
		}
	},

	initDMS : function( component, dmsType ){
		if( dmsType === "showOwnerIdDMSIcon" ){
			this.callDMS( component, dmsType, component.get( "v.relatedRecordData.owner.AccountId__c" ) );
		}else if( dmsType === "showKeeperIdDMSIcon" ){
			this.callDMS( component, dmsType, component.get( "v.relatedRecordData.keeper.AccountId__c" ) );
		}
	},
	callDMS : function( component, dmsType, accountId ){
		var action								= component.get( "c.getDMSData" );
		var request								= {
													strAccountId	: accountId,
													strIdDMSType	: dmsType
												};

		action.setParams( {
			"strRequest": JSON.stringify( request ),
		} );
		
		action.setCallback( this, function( response ){
			var state							= response.getState();
			
			if( state === "SUCCESS" ){
				if( response.getReturnValue().hasError ){
					console.log( "ERROR " + response.getReturnValue().ERROR );
					
				}else{
					component.set( "v." + dmsType, response.getReturnValue()[ dmsType ] === undefined );
				}
				
			}else if( state === "INCOMPLETE" ){
			
			}else if( state === "ERROR" ){
				var errors						= response.getError();
				
				if( errors && errors[0] && errors[0].message ){
					console.log( "Error message: " + errors[0].message );
				}else{
					console.log( "Unknown error" );
				}
			}
		} );

		$A.enqueueAction( action );
	},
	startDMScall: function(component,sRecordId_A,sRecordId_B) {
		var action = component.get("c.DMSWakeUp");
		action.setParams({
			"sRecordId_A" : sRecordId_A,
			"sRecordId_B" : sRecordId_B
		});
        action.setCallback(this, function(response) {
           if (response.getState() === "SUCCESS") {
              var allValues = response.getReturnValue();
              if(!$A.util.isUndefinedOrNull(allValues) && !$A.util.isEmpty(allValues)){
              	this.executeCORScall(allValues.body,allValues.endpoint);
              }else{
                this.executeServerCall(component,sRecordId);
              }
           }
        });
        $A.enqueueAction(action);
    },
    executeServerCall : function(component,sRecordId) { 
        var action = component.get("c.DMSWakeUpbyServer");
        action.setParams({
			"sRecordId" : sRecordId
		});
        action.setCallback(this, function(response) {
           if (response.getState() === "SUCCESS") {
           		//console.log('Ok');
           }
        });
        $A.enqueueAction(action);
    },
    executeCORScall : function(message,url) { 
        if(!$A.util.isUndefinedOrNull(message) && !$A.util.isEmpty(message)){
            this.fixCORScallIE11(url);
            var xmlHttp = new XMLHttpRequest();
            console.log('body: ' + message + ' · URL: ' + url);
            xmlHttp.open( "POST", url, true );
            xmlHttp.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xmlHttp.responseType = 'text';
            xmlHttp.onload = function () {
                if (xmlHttp.readyState === 4) {
                    if (xmlHttp.status === 200) {}
                }
            };
            xmlHttp.send( message );
        }
    },
    fixCORScallIE11 : function(url) { 
        try{
            var xmlHttp = new XMLHttpRequest();
            xmlHttp.open('GET', url, true);
            xmlHttp.withCredentials = true;
            xmlHttp.send();
        }catch(e){}
    }
} )
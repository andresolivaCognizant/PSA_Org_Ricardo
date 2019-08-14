( {
	doInit : function( component, event, helper ){
		var interval			= window.setTimeout(
			$A.getCallback( function(){
				var loadingSpinner		= component.find( "LoadingSpinner" );
				$A.util.removeClass( loadingSpinner, "slds-show" );
				$A.util.addClass( loadingSpinner, "slds-hide" );
			} ),
			10000
		);
	},
	
	recordUpdated : function( component, event, helper ){
		var changeType = event.getParams().changeType;
		
		if ( changeType === "ERROR" ){
		} else if ( changeType === "LOADED" && component.get( "v.reloadRecord" ) ){
			component.find( "fieldLabels" ).getFieldLabels(
				[ 'Asset.FirstRegistrationNumber__c', 'Asset.FirstRegistrationDate__c', 'Asset.WarrantyEndDate__c', 'Asset.RealMileage__c', 'Asset.RealMileageDate__c', 'Asset.EstimatedCurrentMileage__c', 'Asset.LastMaintenanceDate__c', 'Asset.LastAPVVisitDate__c', 'Asset.NextMaintenanceDate__c', 'Asset.Eurorepar__c', 'ServiceContract.Name', 'ServiceContract.ContractType__c', 'ServiceContract.StartDate', 'ServiceContract.EndDate', 'ServiceContract.SubscribedMileage__c', 'ServiceContract.ContractStatus__c', 'Product2.Name', 'ContractLineItem.LineItemNumber', 'ContractLineItem.StartDate', 'ContractLineItem.EndDate', 'ContractLineItem.SubscribedDuration__c', 'ContractLineItem.SubscribedMileage__c', 'ContractLineItem.Quantity', 'ContractLineItem.Quantity__c' ],
				function( result ) {
					component.set( "v.fieldLabels", result );
				}
			);
		
			helper.dataServiceOnLoad( component, event );
			helper.getAlerts( component );
			helper.addEditLink( component );

			component.set( "v.carURL", 
				helper.setCarURL( 
					component.get( "v.carURL" ), 
					component.get( "v.currentRecord.fields.Brand__c.displayValue" ), 
					component.get( "v.currentRecord.fields.LCDV16__c.value" ), 
					component.get( "v.currentRecord.fields.ExteriorTrimColorCode__c.value" )
				 )
			 );
			
		} else if ( changeType === "REMOVED" ){
		} else if ( changeType === "CHANGED" ){
			component.set( "v.carURL", 
				helper.setCarURL( 
					component.get( "v.carURL" ), 
					component.get( "v.currentRecord.fields.Brand__c.displayValue" ), 
					component.get( "v.currentRecord.fields.LCDV16__c.value" ), 
					component.get( "v.currentRecord.fields.ExteriorTrimColorCode__c.value" )
				 )
			 );
		}
	},
	
	handleSaveRecord : function( component, event, helper ){
		helper.handleSaveRecord( component, event, true, false, 1 );
	},
	
	confirmRealMileage : function( component, event, helper ){
		helper.handleSaveRecord( component, event, false, false, 1 );
	},
	
	editOnMouseOver : function( component, event, helper ){
		var cmpEdit								= component.find( "editRealMieage" );
		
		$A.util.removeClass( cmpEdit, "lightningIconsClassName-light" );
	},
	
	editOnMouseOut : function( component, event, helper ){
		var cmpEdit								= component.find( "editRealMieage" );
		
		$A.util.addClass( cmpEdit, "lightningIconsClassName-light" );
	},
	
	editModeOn : function( component, event, helper ){
		helper.editModeOn( component, event );
	},
	
	editModeOff : function( component, event, helper ){
		helper.editModeOff( component );
	},
	
	redirect : function( component, event, helper ){
		var htmlId								= event.target.id;
		var navEvt								= $A.get( "e.force:navigateToSObject" );
		var objId								= "";
		
		if( htmlId == "miniPgLayoutOwner" ){
			objId								= "v.relatedRecordData.owner.AccountId__r.Id";
			
		}else if( htmlId == "miniPgLayoutKeeper" ){
			objId								= "v.relatedRecordData.keeper.AccountId__r.Id";
			
		}else if( htmlId.includes( "service_" ) ){
			component.set( "v.serviceSelected", undefined );
			component.set( "v.contractLineItemsColumns", undefined );
			component.set( "v.serviceSelected", component.get( "v.relatedRecordData" ).lstServiceContracts[ htmlId.split( "_" )[2] ] );
			component.set( "v.contractLineItemsColumns", helper.getContractLineItemsColumns( component ) );
			component.find( "serviceContractModal" ).openModal();
		}
		
		if( objId != "" ){
			navEvt.setParams( {
				"recordId": component.get( objId ),
				"slideDevName": "detail"
			} );
			
			navEvt.fire();
		}
	},
	
	onClose : function( component, event, helper ){
		component.set( "v.serviceSelected", undefined );
		component.set( "v.contractLineItemsColumns", undefined );
		component.find( "serviceContractModal" ).closeModal();
	},
	
	createOpp : function( component, event, helper ){
		helper.showSpinner( component, event, helper );
		
		var action								= component.get( "c.createOpportunities" );
		var request								= {
													strAccountId			: component.get( "v.wa.fields.Owner__c.value" ),
													strVIN					: component.get( "v.currentRecord.fields.VIN__c.value" ),
													strCurrencyIsoCode		: component.get( "v.wa.fields.CurrencyIsoCode.value" ),
													strBrand				: component.get( "v.currentRecord.fields.Brand__c" ) != undefined ? component.get( "v.currentRecord.fields.Brand__c.value" ) : null,
													strCountry				: component.get( "v.currentRecord.fields.Country__c" ) != undefined ? component.get( "v.currentRecord.fields.Country__c.value" ) : null,
													strWarrantyEndDate		: component.get( "v.currentRecord.fields.WarrantyEndDate__c" ) != undefined ? component.get( "v.currentRecord.fields.WarrantyEndDate__c.value" ) : null,
													strLastKnownRegNumber	: component.get( "v.currentRecord.fields.LastKnownRegistrationNumber__c" ) != undefined ? component.get( "v.currentRecord.fields.LastKnownRegistrationNumber__c.value" ) : null,
													blnWarratyOpp			: component.get( "v.warrantyOpp" ),
													blnMaintOpp				: component.get( "v.maintOpp" )
												};

		action.setParams( {
			"strRequest": JSON.stringify( request ),
		} );

		action.setCallback( this, function( response ){
			var state							= response.getState();
			
			if( state === "SUCCESS" ){
				console.log( response.getReturnValue() );
			
				if( response.getReturnValue().hasError ){
					helper.showToast( response.getReturnValue().ERROR.cause, response.getReturnValue().ERROR.message, "error", "dismissible" );
					
					component.set( "v.createOpp", false );
					
				}else{
					component.set( "v.hasOpp", true );
					component.set( "v.opportunity", response.getReturnValue().opp );
					
					helper.showToast( "", $A.get( "$Label.c.AfterSalesHeaderOpportunitiesMsg" ).replace( "{0}", component.get( "v.opportunity.Name" ) ), "success", "dismissible" );
					helper.fireOppEvent( component );
				}
			
			}else if( state === "INCOMPLETE" ){
			
			}else if( state === "ERROR" ){
				var errors						= response.getError();
				
				if( errors && errors[0] && errors[0].message ){
					console.log( "Error message: " + errors[0].message );
				}else{
					console.log( "Unknown error" );
				}
				
				helper.showToast( "Error", errors, "error", "dismissible" );
			}
			
			helper.hideSpinner( component );
		} );

		$A.enqueueAction( action );
	},
	
	editRecord : function( component, event, helper ){
		event.preventDefault();
	
		var htmlId								= event.target != undefined ? event.target.id : event.getSource().getLocalId();
		var objId								= "";
		var editRecordEvent						= $A.get( "e.force:editRecord" );
		
		if( htmlId == "editOwner" ){
			objId								= component.get( "v.relatedRecordData.owner.AccountId__r.Id" );
			
		}else if( htmlId == "editKepper" ){
			objId								= component.get( "v.relatedRecordData.keeper.AccountId__r.Id" );
			
		}else if( htmlId == "editAsset" ){
			objId								= component.get( "v.currentRecord.fields.Id.value" );
		}
		
		editRecordEvent.setParams( {
			"recordId": objId
		} );
		
		editRecordEvent.fire();
	},
	
	handleToastEvent : function( component, event, helper ){
		var currentPage							= window.location.href;
	
		if( event.getParams().type === "SUCCESS" ){
			if( window.location.search.includes( "vld=1" ) ){
				window.open( currentPage, "_self" );

			}else if( !window.location.search.includes( "?" ) ){
				window.open( currentPage + "?vld=1", "_self" );

			}else if( window.location.search.includes( "?" ) ){
				window.open( currentPage + "&vld=1", "_self" );
			}
		}
	},

	initDMSInterval : function( component, event, helper ){
		event.preventDefault();
		//debugger;
		//var dmsType							= ( event.target || arguments[1].currentTarget ).id;
		var dmsType							= arguments[1].currentTarget.id;
		if( dmsType === "showOwnerIdDMSIcon" ){
			helper.startDMScall(component,component.get( "v.relatedRecordData.owner.AccountId__c" ),component.get( "v.currentRecord.fields.Id.value" ));
			var ownerInterval				= window.setInterval(
												$A.getCallback(
													function(){
														helper.initDMS( component, dmsType );

														if( !component.get( "v.showOwnerIdDMSIcon" ) ){
															clearInterval( ownerInterval );
														}
													}
												),
												5000
											);
		}else if( dmsType === "showKeeperIdDMSIcon" ){
			helper.startDMScall(component,component.get( "v.relatedRecordData.keeper.AccountId__c" ),component.get( "v.currentRecord.fields.Id.value" ));
			var keeperInterval				= window.setInterval(
												$A.getCallback(
													function(){
														helper.initDMS( component, dmsType );

														if( !component.get( "v.showKeeperIdDMSIcon" ) ){
															clearInterval( keeperInterval );
														}
													}
												),
												5000
											);
		}
	}
} )
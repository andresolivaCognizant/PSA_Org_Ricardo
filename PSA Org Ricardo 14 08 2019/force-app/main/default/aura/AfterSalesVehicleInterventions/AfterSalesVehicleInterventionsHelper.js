( {
	updatePath : function( component ) {
		var steps = component.get( "v.path_setting" );
		var current_step = component.get( "v.step" );

		steps.forEach( function( s, i ) {
			if ( i == current_step ) {
				s.class = "path_layer slds-path__item slds-is-current slds-is-active";
			}

			if ( i > current_step ) {
				s.class = "path_layer slds-path__item slds-is-incomplete";
			}

			if ( i < current_step ) {
				s.class = "path_layer slds-path__item slds-is-incomplete slds-is-active";
			}
		} );

		component.set( "v.path_setting", steps );
	},

	fetchInterventions : function( component, event ) {
		var action = component.get( "c.getVehicleInterventions" );
		var request = {
			"strVIN": component.get( "v.isFromAsset" ) ? component.get( "v.objAsset.fields.VIN__c.value" ) : component.get( "v.wa" ).fields.Asset__r.value.fields.VIN__c.value
		};

		action.setParams( {
			"strRequest": JSON.stringify( request )   
		} );

		action.setCallback( this, function( response ){
			var state	= response.getState();

			if( state === "SUCCESS" ){
				var spinner = component.find( "_spinner" );
				var main = component.find( "_main" );

				console.log( response.getReturnValue() );

				if( response.getReturnValue().hasError ){
					this.showErrorDiv( component );
					$A.util.toggleClass( spinner, "slds-hide" );
					$A.util.toggleClass( main, "slds-hide" );
				}
				else {
					component.set( "v.data", response.getReturnValue().result );
					this.createInvoicesTable( component );
					$A.util.toggleClass( spinner, "slds-hide" );
					$A.util.toggleClass( main, "slds-hide" );
				}

			} else if ( state === "INCOMPLETE" ){

			} else if ( state === "ERROR" ){
				var errors = response.getError();
				if( errors && errors[0] && errors[0].message ){
					console.log( "Error message: " + errors[0].message );
				} else {
					console.log( "Unknown error" );
				}

				this.showToast( "Error", errors, "error", "dismissible" );
			}
		} );

		$A.enqueueAction( action );
	},

	refreshDataTable : function( component, rows, cols ) {
		var body = [];

		$A.createComponent( 
			"lightning:datatable",
			{
				"keyField"            : "id",
				"data"                : component.getReference( "v.data" ),
				"columns"             : component.getReference( "v.columns" ),
				"hideCheckboxColumn"  : true,
				"onrowaction"         : component.getReference( "c.handleRowAction" ),
			},
			function( e, status, errorMessage ) {
				if ( status === "SUCCESS" ) {
					body.push( e );
					component.find( "_dataTable" ).set( "v.body", body );
				}
				else if ( status === "INCOMPLETE" ) {
					console.log( "No response from server or client is offline." )
					// Show offline error
				}
				else if ( status === "ERROR" ) {
					console.log( "Error: " + errorMessage );
					// Show error message
				}
			}
		);
	},

	createInvoicesTable : function( component ) {
		var self = this;
		var body = [];
		$A.createComponent( 
			"lightning:datatable",
			{
				"keyField"            : "id_bkp",
				"data"                : component.get( "v.data.factures" ),
				"columns"             : component.get( "v.columns[0]" ),
				"hideCheckboxColumn"  : true,
				"onrowaction"         : component.getReference( "c.handleRowAction" ),
			},
			function( e, status, errorMessage ) {
				if ( status === "SUCCESS" ) {
					body.push( e );
					if( e.get( "v.data" ).length == 0 ){
						self.showEmptyDiv( component, $A.get( "$Label.c.AfterSalesBVVNoInterventionsMsg" ), "_dataTable" );
					}else{
						component.find( "_dataTable" ).set( "v.body", body );
					}
				}
				else if ( status === "INCOMPLETE" ) {
					console.log( "No response from server or client is offline." )
					// Show offline error
				}
				else if ( status === "ERROR" ) {
					console.log( "Error: " + errorMessage );
					// Show error message
				}
			}
		);
	},

	createInterventionsTable : function( component, lst_data ) {
		var body = [];
		$A.createComponent( 
			"lightning:datatable",
			{
				"keyField"            : "id",
				"data"                : lst_data,
				"columns"             : component.get( "v.columns[1]" ),
				"hideCheckboxColumn"  : true,
				"onrowaction"         : component.getReference( "c.handleRowAction" ),
			},
			function( e, status, errorMessage ) {
				if ( status === "SUCCESS" ) {
					body.push( e );
					component.find( "_dataTable" ).set( "v.body", body );
				}
				else if ( status === "INCOMPLETE" ) {
					console.log( "No response from server or client is offline." )
					// Show offline error
				}
				else if ( status === "ERROR" ) {
					console.log( "Error: " + errorMessage );
					// Show error message
				}
			}
		);
	},

	createPiecesTable : function( component, row_obj ) {
		var self = this;
		var body = [];
		$A.createComponents( 
			[
				[
					"lightning:datatable",
					{
						"keyField"            : "id",
						"data"                : row_obj.pieces.piece,
						"columns"             : component.getReference( "v.columns[2]" ),
						"hideCheckboxColumn"  : true,
						"onrowaction"         : component.getReference( "c.handleRowAction" ),
					}
				],
				[
					"lightning:datatable",
					{
						"keyField"            : "id",
						"data"                : row_obj.operations.operation,
						"columns"             : component.getReference( "v.columns[3]" ),
						"hideCheckboxColumn"  : true,
						"onrowaction"         : component.getReference( "c.handleRowAction" ),
					}
				],
				[
					"aura:text",
					{
						"value" : row_obj.strOperationsTotal
					}
				],
				[
					"aura:text",
					{
						"value" : row_obj.strPiecesTotal
					}
				]
			],
			function( e, status, errorMessage ) {
				if ( status === "SUCCESS" ) {
	
					body.push( e[0] );
					if( e[0].get( "v.data" ).length == 0 ){
						$A.util.toggleClass( component.find( "_parts" ), "slds-is-open" );
						self.showEmptyDiv( component, $A.get( "$Label.c.AfterSalesBVVNoParts" ), "_pieces" );
					}else{
						component.find( "_pieces" ).set( "v.body", body );
					}
	
					body = [];
					body.push( e[1] );
					if( e[1].get( "v.data" ).length == 0 ){
						$A.util.toggleClass( component.find( "_ops" ), "slds-is-open" );
						self.showEmptyDiv( component, $A.get( "$Label.c.AfterSalesBVVNoOperationsMsg" ), "_operations" );
					}else{
						component.find( "_operations" ).set( "v.body", body );
					}
	
					body = [];
					body.push( e[2] );
					component.find( "ops_sub_total" ).set( "v.body", body );
	
					body = [];
					body.push( e[3] );
					component.find( "pcs_sub_total" ).set( "v.body", body );
				}
	
				else if ( status === "INCOMPLETE" ) {
					console.log( "No response from server or client is offline." )
					// Show offline error
				}
	
				else if ( status === "ERROR" ) {
					console.log( "Error: " + errorMessage );
					// Show error message
				}
			}
		);
	},

	showToast : function( msgTitle, msg, msgType, msgMode ) {
		var toastEvent      = $A.get( "e.force:showToast" );
		var availableModes  = "dismissible&pester&sticky";
		var availableTypes  = "info&success&warning&error";

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

	showErrorDiv : function( component ) {
		$A.createComponent(
			"aura:html", {
				tag             : "div",
				body            : $A.get( "$Label.c.GenericInterfaceErrorMessage" ),
				HTMLAttributes  : {
					class : "slds-align_absolute-center",
					style : "height: 300px;"
				}
			},
			function( e, status, errorMessage ){
				var container = component.find( '_main' );
				if ( status === 'SUCCESS' ) {
					var body = [];
					body.push( e );
					container.set( "v.body", body );
				}
			}
		);
	},
	
	showEmptyDiv : function( component, message, table ) {
		$A.createComponent(
			"aura:html", {
				tag             : "div",
				body            : message,
				HTMLAttributes  : {
					class : "slds-align_absolute-center",
					style : "height: 20px;"
				}
			},
			function( e, status, errorMessage ){
				var container = component.find( table );
				if ( status === 'SUCCESS' ) {
					var body = [];
					body.push( e );
					container.set( "v.body", body );
				}
			}
		);
	},
	
	getColumns : function(){
		var columns							= {
												"0": [
													{
														"label": $A.get( "$Label.c.AfterSalesBVVDate" ),
														"type": "button",
														"typeAttributes": {
															"label": {
																"fieldName": "strDate"
															},
															"title": $A.get( "$Label.c.AfterSalesBVVLinkHelpText" ),
															"name": "view_interventions",
															"class": "btn_next",
															"variant": "base"
														},
														"cellAttributes": {
															"alignment": "right"
														}
													},
													{
														"label": $A.get( "$Label.c.AfterSalesBVVMileage" ),
														"type": "number",
														"fieldName": "kilometrage",
														"cellAttributes": {
															"alignment": "right"
														}
													},
													{
														"label": $A.get( "$Label.c.AfterSalesBVVDescription" ),
														"type": "text",
														"fieldName": "strDescription"
													},
													{
														"label": $A.get( "$Label.c.AfterSalesBVVDossierId" ),
														"type": "text",
														"fieldName": "idDms"
													},
													{
														"label": $A.get( "$Label.c.AfterSalesBVVInvoiceId" ),
														"type": "text",
														"fieldName": "id"
													},
													{
														"label": $A.get( "$Label.c.AfterSalesBVVAmount" ),
														"type": "text",
														"fieldName": "strAmount",
														"cellAttributes": {
															"alignment": "right"
														}
													},
													{
														"label": $A.get( "$Label.c.AfterSalesBVVImputation" ),
														"type": "text",
														"fieldName": "strImputation"
													}
												],
												"1": [
													{
														"label": $A.get( "$Label.c.AfterSalesBVVInterventionNumber" ),
														"type": "button",
														"typeAttributes": {
															"label": {
																"fieldName": "id"
															},
															"title": $A.get( "$Label.c.AfterSalesBVVLinkHelpText" ),
															"name": "view_parts",
															"class": "btn_next",
															"variant": "base"
														},
														"cellAttributes": {
															"alignment": "right"
														}
													},
													{
														"label": $A.get( "$Label.c.AfterSalesBVVDescription" ),
														"type": "text",
														"fieldName": "libelle"
													},
													{
														"label": $A.get( "$Label.c.AfterSalesBVVImputationType" ),
														"type": "text",
														"fieldName": "imputationType"
													},
													{
														"label": $A.get( "$Label.c.AfterSalesBVVAmountHtc" ),
														"type": "text",
														"fieldName": "prixHt",
														"cellAttributes": {
															"alignment": "right"
														}
													},
													{
														"label": $A.get( "$Label.c.AfterSalesBVVAmountTtc" ),
														"type": "text",
														"fieldName": "prixTtc",
														"cellAttributes": {
															"alignment": "right"
														}
													}
												],
												"2": [
													{
														"label": $A.get( "$Label.c.AfterSalesBVVDescription" ),
														"type": "text",
														"fieldName": "libelle"
													},
													{
														"label": $A.get( "$Label.c.AfterSalesBVVReference" ),
														"type": "text",
														"fieldName": "reference"
													},
													{
														"label": $A.get( "$Label.c.AfterSalesBVVQuantity" ),
														"type": "number",
														"fieldName": "quantite",
														"cellAttributes": {
															"alignment": "right"
														}
													},
													{
														"label": $A.get( "$Label.c.AfterSalesBVVUnitPrice" ),
														"type": "text",
														"fieldName": "prixTtc",
														"cellAttributes": {
															"alignment": "right"
														}
													},
													{
														"label": $A.get( "$Label.c.AfterSalesBVVTotalPrice" ),
														"type": "text",
														"fieldName": "strSubTotal",
														"cellAttributes": {
															"alignment": "right"
														}
													}
												],
												"3": [
													{
														"label": $A.get( "$Label.c.AfterSalesBVVDescription" ),
														"type": "text",
														"fieldName": "libelle"
													},
													{
														"label": $A.get( "$Label.c.AfterSalesBVVCode" ),
														"type": "text",
														"fieldName": "code"
													},
													{
														"label": $A.get( "$Label.c.AfterSalesBVVType" ),
														"type": "text",
														"fieldName": "type"
													},
													{
														"label": $A.get( "$Label.c.AfterSalesBVVTime" ),
														"type": "number",
														"fieldName": "tempsFacture",
														"cellAttributes": {
															"alignment": "right"
														}
													},
													{
														"label": $A.get( "$Label.c.AfterSalesBVVAmountHtc" ),
														"type": "text",
														"fieldName": "prixHt",
														"cellAttributes": {
															"alignment": "right"
														}
													},
													{
														"label": $A.get( "$Label.c.AfterSalesBVVAmountTtc" ),
														"type": "text",
														"fieldName": "prixTtc",
														"cellAttributes": {
															"alignment": "right"
														}
													}
												]
											};
											
		return columns;
	}
} )
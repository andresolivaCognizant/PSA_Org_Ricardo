({
	getInitData : function( component ){
		var action								= component.get( "c.getInitData" );

		var request								= {
													strRecordId		: component.get( "v.recordId" )
												};

		action.setParams( {
			"strRequest": JSON.stringify( request )
		} );

		action.setCallback( this, function( response ){
			var state							= response.getState();
			
			if( state === "SUCCESS" ){

				if( !response.getReturnValue().hasError ){
					var fromList 				= [
													{
														"label": response.getReturnValue().userInfo.name + " <" + response.getReturnValue().userInfo.email + ">",
														"value": response.getReturnValue().userInfo.email
													}
												];

					if( !$A.util.isUndefinedOrNull( response.getReturnValue().owEmailAddress ) ){
						fromList.push(
							{
								"label": response.getReturnValue().owEmailAddress.name + " <" + response.getReturnValue().owEmailAddress.email + ">",
								"value": response.getReturnValue().owEmailAddress.email
							}
						);
					}

					var accountField			= response.getReturnValue().accountField;

					if( accountField.includes( "__c" ) ){
						accountField			= accountField.replace( "__c", "__r" );

					}else{
						accountField			= accountField.replace( "Id", "" );
					}
					
					var fields			= [];
					fields.push( "Name" );
					fields.push( response.getReturnValue().accountField );
					fields.push( accountField + ".IsPersonAccount" );

					component.set( "v.fromList", fromList );
					component.set( "v.from", fromList[0].value );
					component.set( "v.accountField", response.getReturnValue().accountField );
					component.set( "v.isPersonAccountField", accountField + ".IsPersonAccount" );
					component.set( "v.fields", fields );

				}else{
					console.log( response.getReturnValue() );
				}

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

	getPDF : function( component ){
		var self								= this;
		var action								= component.get( "c.getPDF" );

		action.setParams( {
			"strRecordId": component.get( "v.recordId" )
		} );

		action.setCallback( this, function( response ){
			var state							= response.getState();
			
			if( state === "SUCCESS" ){
				component.set( "v.pdfData", response.getReturnValue() );

			}else if( state === "ERROR" ){
				var errors						= response.getError();
				
				if( errors && errors[0] && errors[0].message ){
					console.log( "Error message: " + errors[0].message );
				}else{
					console.log( "Unknown error" );
				}
			}
			
			if( $A.util.isUndefinedOrNull( component.get( "v.pdfData" ) ) ){
				component.set( "v.pdfResponse", $A.get( "$Label.c.SendEmailMessage1" ));
			}

			self.hideSpinner( component, "spinner" );

		} );

		$A.enqueueAction( action );
	},

	sendEmail : function( component ) {
		this.showSpinner( component, "cmpSpinner" );
		var self								= this;
		var action								= component.get( "c.sendEmail" );
		
		var recipientIds						= component.get( "v.selectedRecipients" ).split( ";" );
		var request								= {
													strTemplateId	: component.get( "v.emailTemplate.Id" ),
													strFrom			: component.get( "v.from" ),
													strWhatId		: component.get( "v.recordId" ),
													strPDFName		: component.get( "v.record.fields.Name.value" ),
													strPDFData		: component.get( "v.pdfData" ),
													strRecipients	: JSON.stringify( recipientIds ),
													strSubject		: component.get( "v.templateSubject" ),
													strBody			: component.get( "v.templateBody" )
												};

		action.setParams( {
			"strRequest": JSON.stringify( request )
		} );

		action.setCallback( this, function( response ){
			var state							= response.getState();
			
			if( state === "SUCCESS" ){
				console.log( response.getReturnValue() );
			
				if( response.getReturnValue().hasError ){

				}else{
					self.closeAction( component );
				}
			
			}else if( state === "ERROR" ){
				var errors						= response.getError();
				
				if( errors && errors[0] && errors[0].message ){
					console.log( "Error message: " + errors[0].message );
				}else{
					console.log( "Unknown error" );
				}
			}

			self.hideSpinner( component, "cmpSpinner" );
		} );

		$A.enqueueAction( action );
	},
	
	validateField : function( component, componentName ){
		var field								= component.find( componentName );
		var field_help							= component.find( componentName + "_help" );

		if( ( !componentName.includes( "lkpContacts" ) && $A.util.isUndefinedOrNull( field.get( "v.value" ) ) ) || ( componentName.includes( "lkpContacts" ) && component.get( "v.recipients" ).length === 0 ) ){
			$A.util.addClass( field, "slds-has-error" );
			$A.util.addClass( field_help, "slds-show" );
			$A.util.removeClass( field_help, "slds-hide" );

			return 1;
		}

		this.removeRequiredStyles( component, componentName );

		return 0;
	},

	removeRequiredStyles : function( component, componentName ){
		var field								= component.find( componentName );
		var field_help							= component.find( componentName + "_help" );

		$A.util.removeClass( field, "slds-has-error" );
		$A.util.removeClass( field_help, "slds-show" );
		$A.util.addClass( field_help, "slds-hide" );
	},

	addRecipient : function( component ) {
		if( !$A.util.isUndefinedOrNull( component.get( "v.selectedRecipients" ) ) && component.get( "v.selectedRecipients" ).includes( component.get( "v.selectedRecipient." + component.get( "v.recipientIdField" ) ) ) ){
			this.clearSelectedRecipient( component );

			return;
		}

		if( !$A.util.isUndefinedOrNull( component.get( "v.selectedRecipient." + component.get( "v.recipientIdField" ) ) ) ){
			var recipients				= component.get( "v.recipients" );
			
			recipients.push( this.getRecipientPill( component ) );

			if( $A.util.isUndefinedOrNull( component.get( "v.selectedRecipients" ) ) ) {
				component.set( "v.selectedRecipients", ";" + component.get( "v.selectedRecipient." + component.get( "v.recipientIdField" ) ) );
			}else{
				component.set( "v.selectedRecipients", component.get( "v.selectedRecipients" ) + ";" + component.get( "v.selectedRecipient." + component.get( "v.recipientIdField" ) ) );
			}
			
			component.set( "v.recipients", recipients );
		
			this.clearSelectedRecipient( component );
		}
	},

	getRecipientPill : function( component ){
		var recipientPill						= {
													type: "avatar",
													href: "",
													label: component.get( "v.selectedRecipient.Name" ),
													name: component.get( "v.selectedRecipient." + component.get( "v.recipientIdField" ) ),
													src: "",
													fallbackIconName: "standard:contact",
													alternativeText: ""
												};

		return recipientPill;
	},

	clearSelectedRecipient : function( component ){
		window.setTimeout(
			$A.getCallback( function(){
				var parentField_isPersonAccount	= "v.parentFields." + component.get( "v.isPersonAccountField" );

				component.find( "lkpContacts" + ( component.get( parentField_isPersonAccount ) ? "_b2c" : "_b2b" ) ).clear();
			} ),
			500
		);
	},

	setTemplateDefaults : function( component ){
		var templateType						= component.get( "v.emailTemplate.TemplateType" ) == "text" ? "Body" : "HtmlValue";

		component.set( "v.templateBody", component.get( "v.emailTemplate." + templateType ) );
		component.set( "v.templateSubject", component.get( "v.emailTemplate.Subject" ) );
	},

	showSpinner : function( component, spinnerName ){
		var divSpinner							= component.find( spinnerName );
		
		$A.util.removeClass( divSpinner, "slds-hide" );
		$A.util.addClass( divSpinner, "slds-show" );
	},
	
	hideSpinner : function( component, spinnerName ){
		var spinner								= component.find( spinnerName );
		var divSpinner							= component.find( "divSpinner" );
		
		$A.util.removeClass( spinner, "slds-show" );
		$A.util.addClass( spinner, "slds-hide" );

		if( spinnerName == "spinner" ){
			$A.util.addClass( divSpinner, "slds-hide" );
		}
	},

	closeAction : function( component ) {
		if( component.get( "v.isQuickAction" ) ){
			$A.get( "e.force:closeQuickAction" ).fire();
			$A.get( "e.force:refreshView" ).fire();

		}else{
			var appEvent						= $A.get( "e.c:SendEmailEvent" );
		
			appEvent.setParams( {
				"event" : "CLOSE"
			} );

			appEvent.fire();
		}
	},

	addMessage : function( component, message, reset ){
		var messages							= $A.util.isUndefinedOrNull( component.get( "v.messages" ) ) || reset ? [] : component.get( "v.messages" );
		messages.push( message );
		
		component.set( "v.messages", messages );
		component.set( "v.showErrors", true );
	}
})
({
	doInit : function(component, event, helper) {
		helper.getInitData( component );
	},

	recordUpdated : function( component, event, helper ) {
		var changeType						= event.getParams().changeType;
		var parentField_accountField		= "v.record.fields." + component.get( "v.accountField" ) + ".value";
		var parentField_isPersonAccount		= "v.parentFields." + component.get( "v.isPersonAccountField" );
		
		if( changeType === "ERROR" ){
		}else if ( changeType === "LOADED" ){
			helper.getPDF( component );
			
			component.set( "v.recipientSOQLWHERE", "AND AccountId = '" + component.get( parentField_accountField ) + "' AND ( Contact.PersonalEmail__c != null OR Contact.Email != null ) AND Contact.RecordType.DeveloperName != 'PartnerUser' " + ( component.get( parentField_isPersonAccount ) ? "" : "AND IsActive = true" ) );
			component.set( "v.recipientIdField", component.get( parentField_isPersonAccount ) ? "Id" : "ContactId" );
			component.set( "v.isPersonAccount", component.get( parentField_isPersonAccount ) );

			$A.util.addClass( component.find( "lkpContacts" + ( component.get( parentField_isPersonAccount ) ? "_b2c" : "_b2b" ) ).find( "searchLabel" ), "customRequired" );
			
			if( component.get( parentField_isPersonAccount ) ){
				component.find( "lkpContacts_b2c" ).getRecords(
					"Id, Name, Email, PersonalEmail__c",
					"Name",
					component.get( "v.recipientSOQLWHERE" ),
					"Contact",
					true,
					function( result ) {
						if( result != undefined && result.length != 0 ){
							component.set( "v.selectedRecipient", result[0] );
							component.set( "v.defaultRecipient", result[0] );
							helper.addRecipient( component );
							
						}else{
							component.set( "v.disableRecipienstLookup", false );
							helper.addMessage( component, $A.get( "$Label.c.SendEmailRecipientMessage" ), true );
						}

						helper.hideSpinner( component, "cmpSpinner" );
					}
				);

			}else{
				helper.hideSpinner( component, "cmpSpinner" );
			}
				
		}else if ( changeType === "REMOVED" ){
		}else if ( changeType === "CHANGED" ){
		}
	},

	addRecipient : function( component, event, helper ) {
		var parentField_isPersonAccount		= "v.parentFields." + component.get( "v.isPersonAccountField" );

		helper.addRecipient( component );
		helper.removeRequiredStyles( component, "lkpContacts" + ( component.get( parentField_isPersonAccount ) ? "_b2c" : "_b2b" ) );
	},

	handleRemove : function( component, event ) {
		var recipients						= component.get( "v.recipients" );
		var item							= event.getParam( "index" );
		
		component.set( "v.selectedRecipients", component.get( "v.selectedRecipients" ).replace( ";" + recipients[ item ].name, "" ) );

		recipients.splice( item, 1 );
		component.set( "v.recipients", recipients );
	},

	validateBody : function( component, event, helper ) {
		if( !$A.util.isUndefinedOrNull( component.get( "v.emailTemplate.Id" ) ) ){
			helper.showSpinner( component, "cmpSpinner" );

			var action						= component.get( "c.getMergedTemplate" );

			var request						= {
												strTemplateId	: component.get( "v.emailTemplate.Id" ),
												strWhatId		: component.get( "v.recordId" )
											};

			action.setParams( {
				"strRequest": JSON.stringify( request )
			} );

			action.setCallback( this, function( response ){
				var state				= response.getState();
				
				if( state === "SUCCESS" ){
					console.log( response.getReturnValue() );
				
					if( response.getReturnValue().hasError ){
						helper.setTemplateDefaults( component );

					}else{
						var templateType	= component.get( "v.emailTemplate.TemplateType" ) == "text" ? "plainTextBody" : "htmlBody";

						component.set( "v.templateSubject", response.getReturnValue().template.subject );
						component.set( "v.templateBody", response.getReturnValue().template[ templateType ] );
					}
				
				}else if( state === "ERROR" ){
					var errors			= response.getError();
					
					if( errors && errors[0] && errors[0].message ){
						console.log( "Error message: " + errors[0].message );
					}else{
						console.log( "Unknown error" );
					}

					helper.setTemplateDefaults( component );
				}

				helper.hideSpinner( component, "cmpSpinner" );
			} );

			$A.enqueueAction( action );
		}else{
			helper.setTemplateDefaults( component );
		}

		helper.removeRequiredStyles( component, "Subject" );
	},

	validateRequiredFields : function( component, event, helper ){
		var parentField_isPersonAccount	= "v.parentFields." + component.get( "v.isPersonAccountField" );
		var submitForm						= 0;
		
		submitForm							+= helper.validateField( component, "lkpContacts" + ( component.get( parentField_isPersonAccount ) ? "_b2c" : "_b2b" ) );
		submitForm							+= helper.validateField( component, "Subject" );

		if( submitForm === 0 ){
			helper.sendEmail( component );
			
		}else if( submitForm != 0 ){
			helper.addMessage( component, $A.get( "$Label.c.SendEmailMandatoryFieldsMessage" ), !$A.util.isUndefinedOrNull( component.get( "v.selectedRecipient" ) ) );
		}
	},

	removeRequiredStyles : function( component, event, helper ){
		var field							= event.getSource().getLocalId();

		helper.removeRequiredStyles( component, field );
	},

	cancel : function( component, event, helper ) {
		helper.closeAction( component );
	}
})
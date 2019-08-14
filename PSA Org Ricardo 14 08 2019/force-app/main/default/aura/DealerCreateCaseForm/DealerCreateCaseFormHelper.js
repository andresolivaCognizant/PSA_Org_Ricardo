({
	showToast: function(component, title, msg, variant){
        component.find('notifLib').showToast({
            "title": title,
            "message": msg,
            "variant": variant
        });
    },
    
	validateField : function( component, componentName ){
		var field						= component.find( componentName );
		var field_help					= component.find( componentName + "_help" );

		if( field.get( "v.value" ) == undefined || field.get( "v.value" ) == "" ){
			$A.util.addClass( field, "slds-has-error" );
			$A.util.addClass( field_help, "slds-show" );
			$A.util.removeClass( field_help, "slds-hide" );

			return 1;
		}

		this.removeRequiredStyles( component, componentName );

		return 0;
	},

	removeRequiredStyles : function( component, componentName ){
		var field						= component.find( componentName );
		var field_help					= component.find( componentName + "_help" );

		$A.util.removeClass( field, "slds-has-error" );
		$A.util.removeClass( field_help, "slds-show" );
		$A.util.addClass( field_help, "slds-hide" );
	}    

})
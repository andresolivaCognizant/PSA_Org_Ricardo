({
	manageButtonLabels : function( component ){
		var labelName						= component.get( "v.title" );
		var labelName_tmp					= "";
		
		try{
			if( !$A.util.isUndefinedOrNull( labelName ) ){
				labelName_tmp				= labelName;
				component.set( "v.title", ( this.isCustomLabel( labelName ) ? $A.getReference( labelName ) : labelName ) );
			}

		}catch( error ){
			console.log( error );
			console.log( "The " + labelName_tmp + " custom label given doesn't exist." );
		}
	},
	
	isCustomLabel : function( labelName ){
		var regex							= /\$[Ll][Aa][Bb][Ee][Ll][.][c][.]\w{0,}/m;
		var patt							= new RegExp( regex );
		
		return patt.test( labelName );
	},

	showSpinner : function( component ){
		var spinner						= component.find( "cmpSpinner" );
		
		$A.util.removeClass( spinner, "slds-hide" );
		$A.util.addClass( spinner, "slds-show" );
	},
	
	hideSpinner : function( component ){
		var spinner						= component.find( "cmpSpinner" );
		
		$A.util.removeClass( spinner, "slds-show" );
		$A.util.addClass( spinner, "slds-hide" );
	},
})
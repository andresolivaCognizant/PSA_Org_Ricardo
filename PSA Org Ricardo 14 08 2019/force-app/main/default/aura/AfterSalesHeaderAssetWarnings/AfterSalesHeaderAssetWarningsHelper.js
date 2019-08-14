({
	showErrorToast : function( msgTitle, msg, msgType, msgMode ) {
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
})
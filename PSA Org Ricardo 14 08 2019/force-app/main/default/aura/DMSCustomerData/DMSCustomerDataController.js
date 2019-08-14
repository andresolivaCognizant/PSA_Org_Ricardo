({
	doInit : function(component, event, helper) {
		var action						= component.get( "c.getDMSCustomerData" );

		action.setParams( {
			"strAccountId" : component.get( "v.recordId" )
		} );
		
		action.setCallback(this, function( response ) {
			var state					= response.getState();
			
			if(state === "SUCCESS") {
				if( response.getReturnValue() != undefined && response.getReturnValue().includes( "ERROR" ) ){
					console.log( response.getReturnValue() );
					
				}else{
					component.set( "v.externalAccountId", response.getReturnValue() );
					component.set( "v.loadFields", true );
				}
			
			}else if (state === "ERROR") {
				var errors				= response.getError();
				
				if( errors ){
					if( errors[0] && errors[0].message ) {
						console.log( "getHighlightedIconColors > Error message: " + errors[0].message );
					}
				}else {
					console.log( "getHighlightedIconColors > Unknown error" );
				}
			}
		});

		$A.enqueueAction( action );
	}
})
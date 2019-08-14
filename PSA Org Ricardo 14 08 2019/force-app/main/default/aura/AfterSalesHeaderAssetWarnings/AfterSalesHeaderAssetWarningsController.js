({
	doInit : function(component, event, helper) {
		var callERECA									= true;
	
		if( component.get( "v.brand" ) == undefined || component.get( "v.brand" ) === "" ){
			helper.showErrorToast( "", $A.get( "$Label.c.AfterSalesAssetWithoutBrand" ), "warning", "dismissible" );
			callERECA									= false;
		}
		
		if( component.get( "v.vin" ) == undefined || component.get( "v.vin" ) === "" ){
			helper.showErrorToast( "", $A.get( "$Label.c.AfterSalesAssetWithoutVIN" ), "warning", "dismissible" );
			callERECA									= false;
		}
		
		if( !callERECA ){
			return;
		}
		
		window.setTimeout(
			$A.getCallback( function(){
				var action										= component.get( "c.getVINInfoFromERECA" );
				action.setParams( {
					"strVIN" : component.get( "v.vin" ),
					"strBrand" : component.get( "v.brand" )
				} );
				
				action.setCallback( this, function( response ) {
					var state									= response.getState();
					
					if(state === "SUCCESS") {
						console.log( "AfterSalesHeaderAssetWarnings SUCCESS " + response.getReturnValue() );
					
						if( response.getReturnValue().hasError ){
							helper.showErrorToast( "ERECA Error", $A.get( "$Label.c.GenericInterfaceErrorMessage" ), "error", "dismissible" );
							
						}else{
							component.set( "v.warnings", response.getReturnValue().result );
							component.set( "v.hasWarnings", response.getReturnValue().result.length > 0 );
							component.set( "v.isSameBrand", response.getReturnValue().isSameBrand );
						}
						
					}else if(state === "ERROR") {
						var errors								= response.getError();
						
						if( errors ){
							if( errors[0] && errors[0].message ) {
								console.log( "AfterSalesHeaderAssetWarnings doInit > Error message: " + errors[0].message );
							}
						}else {
							console.log( "AfterSalesHeaderAssetWarnings doInit > Unknown error" );
						}
					}
				});

				$A.enqueueAction( action );
			} ),
			1000
		);
	}
})
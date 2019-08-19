({
	getCounters : function( component, fromInit, event ){
		var action						= component.get( "c.getAppointmentTotals" );

		action.setCallback( this, function( response ) {
			var state					= response.getState();
			
			if(state === "SUCCESS") {
				if( response.getReturnValue().ERROR != undefined ){
					console.log( "doInit > Error message: " + response.getReturnValue().ERROR );
					
				}else{
				
					if( fromInit ){
						if( response.getReturnValue().ERROR != undefined && response.getReturnValue().ERROR.E != undefined ){
							console.log( response.getReturnValue().ERROR.E );
							
						}else{
							component.set( "v.metricsData", response.getReturnValue() );
						}
					
					}else{
						component.set( "v.metricsData", response.getReturnValue() );
						event.getParam( "arguments" ).callback( response.getReturnValue() );
					}
				}
				
			}else if (state === "ERROR") {
				var errors				= response.getError();
				
				if( errors ){
					if( errors[0] && errors[0].message ) {
						console.log( "doInit > Error message: " + errors[0].message );
					}
				}else {
					console.log( "doInit > Unknown error" );
				}
			}
		});

		$A.enqueueAction( action );
	}
})
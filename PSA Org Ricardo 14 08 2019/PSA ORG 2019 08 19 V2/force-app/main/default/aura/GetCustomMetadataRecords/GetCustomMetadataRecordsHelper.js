({
	getRecords : function( component, fromInit, event ) {
		var action								= component.get( "c.getCustomMetadataRecords" );
		
		action.setParams( { 
			"strCustomMetadataAPIName" : component.get( "v.customMetadata" ),
			"strFields" : JSON.stringify( component.get( "v.fields" ) ),
			"strKey" : component.get( "v.key" ),
			"blnGetAll" : component.get( "v.getAll" )
		});
		
		action.setCallback( this, function( response ){
			var state							= response.getState();
			
			if( state === "SUCCESS" ){
				if( fromInit ){
					component.set( "v.targetResult", response.getReturnValue() );
					
				}else{
					event.getParam( "arguments" ).callback( response.getReturnValue() );
				}
			
			}else{
				component.set( "v.targetResult", undefined );
			}
		} );
		
		$A.enqueueAction( action );
	}
})
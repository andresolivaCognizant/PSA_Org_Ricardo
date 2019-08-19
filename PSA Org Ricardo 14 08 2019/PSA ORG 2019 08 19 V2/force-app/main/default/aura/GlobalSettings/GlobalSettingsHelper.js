({
	getRecords : function( component, fromInit, event ) {
		var strGlobalSettings					= component.get( "v.globalSettings" );
		var strAttributes						= component.get( "v.attributes" );
		var action								= component.get( "c.getGlobalSettingAttributes" );
		
		action.setParams( { 
			"strGlobalSettings" : JSON.stringify( strGlobalSettings ),
			"strGlobalSettingAttributes" : JSON.stringify( strAttributes )
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
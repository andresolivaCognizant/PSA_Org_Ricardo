({
	doInit : function( component, event, helper ) {
		if( component.get( "v.runInit" ) ){
			helper.getRecords( component, false, event );
		}
	},
	
	getRecords : function( component, event, helper ) {
		var attributes					= event.getParam( "arguments" );
		component.set( "v.customMetadata", attributes.customMetadata );
		component.set( "v.fields", attributes.fields );
		component.set( "v.key", attributes.key );
		component.set( "v.getAll", attributes.getAll );
	
		helper.getRecords( component, true, event );
	}
})
({
	doInit : function( component, event, helper ) {
		if( component.get( "v.runInit" ) ){
			helper.getRecords( component, false, event );
		}
	},
	
	getRecords : function( component, event, helper ) {
		var attributes					= event.getParam( "arguments" );
		component.set( "v.globalSettings", attributes.globalSettings );
		component.set( "v.attributes", attributes.attributes );
	
		helper.getRecords( component, true, event );
	}
})
({
	doInit : function( component, event, helper ) {
		if( component.get( "v.runInit" ) ){
			helper.getFieldLabels( component, false, event );
		}
	},
	
	getFieldLabels : function( component, event, helper ) {
		var attributes					= event.getParam( "arguments" );
		component.set( "v.fieldNames", attributes.fieldNames );
	
		helper.getFieldLabels( component, true, event );
	}
})
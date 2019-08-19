({
	doInit : function( component, event, helper ){
		if( component.get( "v.runInit" ) ){
			helper.getCounters( component, true, event );
		}
	},
	
	reloadCounters : function( component, event, helper ){
		helper.getCounters( component, false, event );
	}
})
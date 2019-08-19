({
	doInit : function( component, event, helper ) {
		var MyOAppModeAttribute					= window.location.search.substring( 1 );
		
		if( MyOAppModeAttribute != undefined && MyOAppModeAttribute != "" ){
			component.set( "v.MyOAppMode", MyOAppModeAttribute.split( "=" )[ 1 ] );
		}
	},
	
    handleRecordUpdated : function( component, event, helper ) {
		var changeType = event.getParams().changeType;

		if (changeType === "ERROR") { }
		else if (changeType === "LOADED") { 
			component.set( "v.defaultTab", component.get( "v.wa.fields.AppointmentType__c.value" ) === "5" ? "interventions" : "appointment" );
		}
	},
    
	changeTab : function( component, event, helper ) {
		var tab				= event._params.id;
		component.set( "v.defaultTab", tab );
	}
})
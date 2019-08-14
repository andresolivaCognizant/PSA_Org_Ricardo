({
	manageEvent : function(component, event, helper) {
		if( event.getParam( "event" ) == "OPEN" ){
			component.set( "v.launchModal", true );
			component.find( "sendEmail" ).openModal();

		}else if( event.getParam( "event" ) == "CLOSE" ){
			component.set( "v.launchModal", false );
			component.find( "sendEmail" ).closeModal();
			$A.get( "e.force:refreshView" ).fire();
		}
	}
})
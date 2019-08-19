({
	goTo: function(component, event, helper) {
		helper.goToURL( component.get( "v." + event.target.name ) );
	}
})
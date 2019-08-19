({
	doInit : function( component, event, helper ) {
		component.set( "v.columns", helper.getDataTableColumns() );
		component.set( "v.status", helper.getStatusList() );

		helper.addPrintButton( component );

		window.setTimeout(
			$A.getCallback( function(){
				$A.util.removeClass( component.find( "LoadingSpinner" ), "slds-show" );
				$A.util.addClass( component.find( "LoadingSpinner" ), "slds-hide" );

				component.find( "sl_receptionist" ).set( "v.value", $A.get( "$SObjectType.CurrentUser.Id" ) );
				component.find( "sl_status" ).set( "v.value", "[1]" );
				component.set( "v.statusSelected", "[1,2,3,4,5,6,7,8]" );
			} ),
			3000
		);

		helper.jsGetAppointmentList( component );
	},
	
	onChange : function( component, event, helper ) {
		helper.showSpinner( component );
		helper.jsGetAppointmentList( component, event );
	},

	print : function( component, event, helper ) {
		window.print();
	}
})
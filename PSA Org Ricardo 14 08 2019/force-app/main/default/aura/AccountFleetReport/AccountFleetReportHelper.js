({
	jsGetReportData: function(component) {
		var action						= component.get( "c.getReportData" );
		
		action.setParams( {
			"strRequest": JSON.stringify( {
				"strReportName" : "My_Accounts_Fleet_Qmt"
			} )
		} );

		action.setCallback( this, function( response ){
			if( response.getState() == "SUCCESS" && response.getReturnValue().hasReport ){
				var openReport				= $A.get( "e.force:navigateToURL" );
				
				openReport.setParams( {
					"url" : "/report/" + response.getReturnValue().report.id
				} );
				
				openReport.fire();

			}else{
				$A.get( "e.force:closeQuickAction" ).fire();

				var toastEvent						= $A.get( "e.force:showToast" );
				
				toastEvent.setParams( {
					title : "",
					message: $A.get( "$Label.c.AccountFleetReportError" ),
					duration: "5000",
					key: "info_alt",
					type: "error",
					mode: "dismissible"
				} );
				
				toastEvent.fire();
			}
		} );

		$A.enqueueAction( action );
	}
})
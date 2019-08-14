({
	searchHelper : function(component,event,getInputkeyWord,getWhereClause) {
		var action = component.get("c.fetchLookUpValues");
		 
		action.setParams({
			'strFields': component.get( "v.fields" ),
			'strFieldToFilterKeyWord' : component.get( "v.fieldAsLabel" ),
			'searchKeyWord': getInputkeyWord,
			'ObjectName' : component.get("v.objectAPIName"),
			'whereClause': getWhereClause
		});

		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var storeResponse = response.getReturnValue();
				if (storeResponse == undefined || storeResponse.length == 0 ) {
					component.set( "v.showMessage", true );
				} else {
					component.set("v.Message", '');
				}

				/* BEGIN - Manuel Medina - C1STAGILE-9601 - New logic to determine record label based on fieldAsLabel attribute - 06052019 */
				var fieldAsLabel				= component.get( "v.fieldAsLabel" ).split( "." );
				var relatedSObject				= fieldAsLabel.length > 1 ? fieldAsLabel[ 0 ] : "";
				var field						= fieldAsLabel.length > 1 ? fieldAsLabel[ 1 ] : fieldAsLabel[ 0 ];

				for( var i=0; i < storeResponse.length; i++ ){
					storeResponse[i][ "Name" ]	= relatedSObject != "" ? storeResponse[i][ relatedSObject ][ field ] : storeResponse[i][ field ];
				}
				/* END - Manuel Medina - 06052019 */

				if( component.get( "v.fromCMPMethod" ) ){
					event.getParam( "arguments" ).callback( response.getReturnValue() );
					
					component.set( "v.fromCMPMethod", false );
				}

				component.set("v.listOfSearchRecords", storeResponse);
			}
		});
	  // enqueue the Action  
		$A.enqueueAction(action);
	
	},
})
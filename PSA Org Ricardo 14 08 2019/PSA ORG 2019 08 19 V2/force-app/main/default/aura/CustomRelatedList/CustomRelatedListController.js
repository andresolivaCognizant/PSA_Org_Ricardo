({
	doInit : function(component, event, helper) {
		helper.manageButtonLabels( component );
		
		var action												= component.get( "c.getRecords" );
		
		var request												= {
																	strSObject		: component.get( "v.childSObject" ),
																	strParentField	: component.get( "v.parentField" ),
																	strRecordId		: component.get( "v.recordId" ),
																	strFieldSet		: component.get( "v.fieldSet" ),
																	strFields		: component.get( "v.fields" ),
																	strFilter		: component.get( "v.filter" )
																};

		action.setParams( {
			"strRequest": JSON.stringify( request )
		} );

		action.setCallback( this, function( response ){
			var state											= response.getState();
			
			if( state === "SUCCESS" ){
				if( response.getReturnValue().hasError ){
					console.log( response.getReturnValue() );
					
					helper.hideSpinner( component );

				}else{
					var records									= response.getReturnValue().records;
					var columns									= response.getReturnValue().columns;

					for( var j=0; j<records.length; j++ ){
						for( var i=0; i<columns.length; i++ ){
							var fieldName						= columns[i].fieldName.split( "." );
							var relatedSObject					= fieldName.length > 1 ? fieldName[ 0 ] : "";
							var field							= fieldName.length > 1 ? fieldName[ 1 ] : fieldName[ 0 ];

							records[j][ columns[i].fieldName ]	= relatedSObject != "" && !$A.util.isUndefinedOrNull( records[j][ relatedSObject ] ) && !$A.util.isUndefinedOrNull( records[j][ relatedSObject ][ field ] ) ? records[j][ relatedSObject ][ field ] : records[j][ field ];
						}
					}

					component.set( "v.records", records );
					component.set( "v.columns", columns );

					helper.hideSpinner( component );
				}
			
			}else if( state === "ERROR" ){
				var errors				= response.getError();
				
				if( errors && errors[0] && errors[0].message ){
					console.log( "Error message: " + errors[0].message );
				}else{
					console.log( "Unknown error" );
				}

				helper.hideSpinner( component );
			}
		} );

		$A.enqueueAction( action );
	}
})
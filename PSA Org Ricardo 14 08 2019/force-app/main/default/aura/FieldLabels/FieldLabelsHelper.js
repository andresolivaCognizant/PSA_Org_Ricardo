({
	getFieldLabels : function( component, fromInit, event ) {
		var strFieldNames					= component.get( "v.fieldNames" );
		var action							= component.get( "c.getFieldLabel" );
		
		console.log( JSON.stringify( strFieldNames ) );
		
		action.setParams( { 
			"strFieldNames" : JSON.stringify( strFieldNames )
		});
		
		action.setCallback( this, function( response ){
			var state						= response.getState();
			
			if( state === "SUCCESS" ){
				
				if( fromInit ){
					if( response.getReturnValue().ERROR != undefined && response.getReturnValue().ERROR.E != undefined ){
						console.log( response.getReturnValue().ERROR.E );
						
					}else{
						component.set( 'v.fieldLabels', response.getReturnValue() );
					}
				
				}else{
					event.getParam( "arguments" ).callback( response.getReturnValue() );
				}
			
			}else{
				component.set( 'v.hasError', true );
				component.set( 'v.fieldLabels', strFieldName );
			}
		});
		
		$A.enqueueAction( action );
	}
})
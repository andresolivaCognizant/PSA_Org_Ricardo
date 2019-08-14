({
	doInit : function( component, event, helper ) {
		var strFieldName					= component.get( "v.fieldName" );
		var strSObject						= component.get( "v.sObject" );
		var action							= component.get( "c.getFieldLabel" );
		action.setParams( { 
			"strfieldName" : strFieldName,
			"strSObject" : strSObject,
		});
		
		action.setCallback( this, function( response ){
			var state						= response.getState();
			
			if( state === "SUCCESS" ){
				component.set( 'v.fieldLabel', response.getReturnValue() );
			}else{
				component.set( 'v.hasError', true );
				component.set( 'v.fieldLabel', strFieldName );
			}
		});
		
		$A.enqueueAction( action );
	}
})
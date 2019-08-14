global class RESTInt97AMock implements HttpCalloutMock{

	global Integer intStatusCode;
	
	global RESTInt97AMock( Integer intStatusCode ){
		this.intStatusCode						= intStatusCode;
	}

	global HTTPResponse respond( HTTPRequest req ) {
		
		HTTPResponse res						= new HTTPResponse();
		res.setStatusCode( intStatusCode != null ? intStatusCode : 200 );
		res.setStatus( 'OK' ); 
		
		if( intStatusCode != null ){
			res.setBody( '{ "StatusCode": "200", "message": "msg", "description": "desc"} }' );
		
		}else{
			res.setBody( '{ "exception": "exception", "message": "msg", "description": "desc"}' );
		}
		
		return res;
	}
}
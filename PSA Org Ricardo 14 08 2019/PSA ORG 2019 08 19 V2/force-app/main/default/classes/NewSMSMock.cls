/******************************************************************************************
* Name: 			  NewSMSMock
* Author: 			  Borja Gay
* Description:		  Mock class for SMS integration
* 
* Changes (Version)
* -----------------------------------------------------------------------------------------
*			No.		Date			          Author		       Description
*			-----	----------		      ----------------	     ---------------
* @version	1.0		28/06/2019		        Borja Gay 	         Initial definition.
*******************************************************************************************/
global class NewSMSMock implements HttpCalloutMock{

  global Integer intStatusCode;
  
  global NewSMSMock( Integer intStatusCode ){
    this.intStatusCode = intStatusCode;
  }

  global HTTPResponse respond( HTTPRequest req ) {
    
    HTTPResponse res            = new HTTPResponse();
    res.setStatusCode( intStatusCode != null ? intStatusCode : 200 );
    res.setStatus( 'OK' ); 
    
    if( intStatusCode != null ){
      res.setBody( '{"tokenId" : "testToken"' );
    
    }else{
      res.setBody( '{ "exception": "exception", "message": "msg", "description": "desc"}' );
    }
    
    return res;
  }
}
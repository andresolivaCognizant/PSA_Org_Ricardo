global class RESTInt91Mock implements HttpCalloutMock{

  global Integer intStatusCode;
  
  global RESTInt91Mock( Integer intStatusCode ){
    this.intStatusCode            = intStatusCode;
  }

  global HTTPResponse respond( HTTPRequest req ) {
    
    HTTPResponse res            = new HTTPResponse();
    res.setStatusCode( intStatusCode != null ? intStatusCode : 200 );
    res.setStatus( 'OK' ); 
    
    if( intStatusCode != null ){
      res.setBody( '{"lcdv16": "1CB9AFG6S54A010","lcdv9": "1CB9AFG6S","familyDescription": "1CB9","genreDeProduitCode": "1","genreDeProduitLabel": "VP","marqueCommercialCode": "C","marqueCommercialLabel": "AC","ligneDeProduitCode": "B9","ligneDeProduitLabel": "BERLINGO VP (B9)","silhouetteCode": "AF","silhouetteLabel": "BERLINE FAMILIALE","finitionCode": "G","finitionLabel": "MOYENNE BASSE PLUS","moteurCode": "6S","moteurLabel": "INJECTION TU5JP4","boiteDeVitesseCode": "5","boiteDeVitesseLabel": "BVM5"}' );
    
    }else{
      res.setBody( '{ "exception": "exception", "message": "msg", "description": "desc"}' );
    }
    
    return res;
  }
}
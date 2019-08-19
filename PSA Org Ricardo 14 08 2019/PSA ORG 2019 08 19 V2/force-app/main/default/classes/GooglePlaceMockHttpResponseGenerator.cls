@isTest
global class GooglePlaceMockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('https://maps.googleapis.com/maps/api/place/', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
		String sResult = '{"predictions":[{'+
         '"description" : "France","id" : "a977cb95bbbf6d267fdbe3cc2f2c1abd582f5d8a",'+
         '"matched_substrings":[{"length" : 1,"offset" : 0}],'+
         '"place_id" : "ChIJMVd4MymgVA0R99lHx5Y__Ws",'+
         '"reference" : "CiQeAAAAtUNuFO2mEvSEC-wARAQ008AjzZnROKZ9I4xJE1q7Ak8SENWpwKCJZpoH5NdLDS8dc-saFEBHlM2x7hoyTadRjw86kYj0dp_k",'+
         '"structured_formatting":{"main_text" : "France","main_text_matched_substrings":[{"length" : 1,"offset" : 0}]},"terms":['+
         '{"offset" : 0,"value" : "France"}],"types" : [ "country", "political", "geocode"]}],"status" : "OK"}';
    	res.setBody(sResult);
		res.setStatusCode(200);
    	return res;
	}
}
@isTest
public class Int137Mock implements HttpCalloutMock{

    public HTTPResponse respond(HTTPRequest req) {
        Map<String, Object> map_req =
            (Map<String, Object>) JSON.deserializeUntyped(req.getBody());
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        res.setStatusCode((Integer) map_req.get('mock_status'));
        return res;
    }

}
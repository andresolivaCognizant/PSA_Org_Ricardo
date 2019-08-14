public with sharing class RESTInt91 {

	public class Int91Request {
		public string langue;
		public string pays;
		public string mode = 'MODE_XML';
		public string marque;
		public string vin;
	}

	public class Int91Response {
		public String lcdv16;
		public String lcdv9;
		public String familyDescription;
		public String genreDeProduitCode;
		public String genreDeProduitLabel;
		public String marqueCommercialCode;
		public String marqueCommercialLabel;
		public String ligneDeProduitCode;
		public String ligneDeProduitLabel;
		public String silhouetteCode;
		public String silhouetteLabel;
		public String finitionCode;
		public String finitionLabel;
		public String moteurCode;
		public String moteurLabel;
		public String boiteDeVitesseCode;
		public String boiteDeVitesseLabel;
		public integer result;
		public String message;
	}

	public static Int91Response sendRequest(string vin,string lang, string country, string brand, Integer timeOut){
		UtilSetting__mdt requestVIN        = new UtilSetting__mdt();
		List<string> userAndCert = new List<string>();
        requestVIN                         = [SELECT Id,DeveloperName,Value__c,Value2__c,Value3__c
                                                    FROM UtilSetting__mdt
                                                    WHERE DeveloperName =: 'Int91Endpoint'
                                                    LIMIT 1];
		//27/05/2019 [BGF]Fix since DS must not be send to Int91 at the moment, review C1STAGILE-9669
		if(brand == 'DS'){
			brand = 'AC';
		}
		userAndCert = requestVIN.Value3__c.split('#');
       	Int91Request wrp = new Int91Request();
       	wrp.langue = lang;
       	wrp.pays = country;
       	wrp.vin = vin;
       	wrp.marque = brand;
        Http http               = new Http();
        HTTPRequest request     = new HttpRequest();
        String requestEndpoint =  requestVIN.Value__c+'?vin='+vin+'&langue='+lang+'&pays='+country+'&mode='+wrp.mode+'&marque='+brand;
        System.debug(requestEndpoint);
		Int91Response sResult          = new Int91Response();
        HttpResponse response;
        request.setEndpoint(requestEndpoint);
        request.setMethod('GET');
        //request.setHeader('Accept-Encoding','gzip, deflate');
        request.setHeader('X-SourceSystem', 'SFDC' );
        request.setHeader('X-SourceUser', userAndCert[0]);
        request.setHeader('X-Timestamp', System.now().format( 'yyyy-MM-dd' ) + 'T' + System.now().format( 'hh:mm:ss' ) );
        request.setHeader('X-ClientSecret', requestVIN.Value2__c );
		if(userAndCert.size() > 1){
			request.setClientCertificateName(userAndCert[1]);
		}
		request.setTimeOut(timeOut);
        try{
            response = http.send(request);
            if(response != null){
				System.debug(response.getBody());
                if(response.getStatusCode() == 200 || response.getStatusCode() == 201  || response.getStatusCode() == 202 || 
                   response.getStatusCode() == 203){
                sResult = (Int91Response)JSON.deserialize(response.getBody(),Int91Response.class);

            }
            sResult.result = response.getStatusCode();
            }
         }catch(Exception e){
            System.debug('Callout error: '+ e);
        }
        return sResult;
	}
}
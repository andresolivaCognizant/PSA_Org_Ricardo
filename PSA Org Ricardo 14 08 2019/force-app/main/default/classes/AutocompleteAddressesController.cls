public with sharing class AutocompleteAddressesController {

	@AuraEnabled
	public static string getAddressAutoComplete(String input, String types, String language) {
		//String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=' + EncodingUtil.urlEncode(input, 'UTF-8') + '&types=' + types + '&language=' + language + '&key=' + getGoogleMapsAPIKey();
		system.debug('input 1: ' + input + ' types 2: ' + types + ' language 3: ' + language);
		if(String.isEmpty(GOOGLE_API_AUTOCOMPLETE)) {
			loadDefaultValues();
		}
		String url = GOOGLE_API_AUTOCOMPLETE;
		url = url.replace('{0}',  EncodingUtil.urlEncode(input, 'UTF-8'));
		url = url.replace('{1}',  types);
		url = url.replace('{2}',  language);
		url = url.replace('{3}',  GOOGLE_API_KEY);
		return getHttp(url);
	}

	@AuraEnabled
	public static string getAddressDetails(String PlaceId, String language) {
	//String url = 'https://maps.googleapis.com/maps/api/place/details/json?placeid=' + PlaceId + '&language=EN&key=' + getGoogleMapsAPIKey();
		system.debug('PlaceId 1: ' + PlaceId + ' language 2: ' + language);
		if(String.isEmpty(GOOGLE_API_DETAILS)) {
			loadDefaultValues();
		}
		String url =  GOOGLE_API_DETAILS;
		url = url.replace('{0}',  PlaceId);
		url = url.replace('{1}',  language);
		url = url.replace('{2}',  GOOGLE_API_KEY);
		return getHttp(url);
	}
	@AuraEnabled
	public static boolean setAddressDetails(Id RecordId, String[] lstAddress){
		Boolean bAction = false;
		system.debug('lstAddress ' + lstAddress);
		List<Account> lstAcc = new List<Account>([Select BillingStreet, BillingCity, BillingCountry,BillingState, BillingPostalCode From Account Where Id = : RecordId]);
		List<String> aux = String.valueof(lstAddress).split(',');
		system.debug('lstAddress ' + lstAddress);
		for (Account acc : lstAcc){
			acc.BillingStreet		= matchPattern(aux.get(0).split('=')[1]);
			acc.BillingCity			= matchPattern(aux.get(1).split('=')[1]);
			acc.BillingState		= matchPattern(aux.get(2).split('=')[1]);
			acc.BillingCountry		= matchPattern(aux.get(3).split('=')[1]);
			acc.BillingPostalCode	= matchPattern(aux.get(4).split('=')[1]);
		}
		if(!lstAcc.isEmpty()){
			Database.DMLOptions dml = new Database.DMLOptions(); 
			dml.DuplicateRuleHeader.allowSave 			= true;
			dml.DuplicateRuleHeader.runAsCurrentUser 	= true;
			
			List<Database.SaveResult> sr = Database.update(lstAcc, dml);
			//if (sr.isSuccess()) {
			//	System.debug('Duplicate account has been inserted in Salesforce!');
			//}
			bAction = true;
		}

		return bAction;
	}

	private static string matchPattern(String sAux){
		Pattern p = Pattern.compile('([^}]*)\\}\\)');
		Matcher m = p.matcher(sAux);
		system.debug('Value:  ' + sAux + ' matchPattern: ' + m );
		return (m.find())?m.group(1):sAux;
	}

	private static  string GOOGLE_API_ENDPOINT;
	private static  string GOOGLE_API_KEY;
	private static  string GOOGLE_API_AUTOCOMPLETE;
	private static  string GOOGLE_API_DETAILS;
	
	/*	Name 		: loadDefaultValues
		Description	: Load configuration values
		@PARAM 		: 
					: 
		@OUTPUT 	: 
	*/
	public static void loadDefaultValues(){
		for(UtilSetting__mdt larp : [SELECT MasterLabel, QualifiedApiName, Value__c,Value2__c FROM UtilSetting__mdt where QualifiedApiName LIKE 'AutocompleteAddress%']){
			String sValue 	= larp.QualifiedApiName;
			String sAuxVal 	= larp.Value__c;
			if(sValue.indexof('KEY')>0 ){
				GOOGLE_API_KEY	= sAuxVal;
			}else if(sValue.indexof('EPAC')>0){
				GOOGLE_API_AUTOCOMPLETE= sAuxVal;
			}else if(sValue.indexof('EPDT')>0){
				GOOGLE_API_DETAILS = sAuxVal;
			}else if(sValue.indexof('EP')>0){
				GOOGLE_API_ENDPOINT = sAuxVal;
			}
		}
		system.debug('Val 1: ' + GOOGLE_API_ENDPOINT + ' Val 2: ' + GOOGLE_API_AUTOCOMPLETE + ' Val 3: ' + GOOGLE_API_DETAILS + ' Val 4: ' +  GOOGLE_API_KEY);
	}
	public static string getHttp(String url) {
		try {
			Http http 				= new Http();
			HttpRequest request 	= new HttpRequest();
			request.setEndpoint(GOOGLE_API_ENDPOINT + url);
			request.setMethod('GET');
			HttpResponse response 	= http.send(request);
			system.debug('Response Body: ' + response.getBody() );
			String aux = response.getBody();
			System.debug(aux);
			return response.getBody();
		} catch (Exception e) {
			return 'Error';
		}
		
	}
	// //This is for first web service
	//@AuraEnabled
	//public static string processWebResp(String Res) {
	//	system.debug('Web service response to process;' + Res);
	//	return null; 
	//}
	 
	////This is for second web service 
	//@AuraEnabled
	//public static string processWebRes(String Res) {
	//	List<String> mylst = parse(Res);
	//	system.debug('Web service response to process' + Res);
	//	return null;
	//}

	//public static List<String> parse(String json) {
	//	system.debug('Web service response to process' + System.JSON.deserialize(json, List<String>.class));
	//	return (List<String>) System.JSON.deserialize(json, List<String>.class);
	//}

	////Wrapper class
	//public class AddressJsonInfo {
	//	public String long_name;
	//	public String short_name;
	//	public List<String> types;
	//}

	//--------------------------------------------------------------------------------------------------------------------//
/*
	@AuraEnabled
	public static string getAnalyticsReport() {
		//String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=' + EncodingUtil.urlEncode(input, 'UTF-8') + '&types=' + types + '&language=' + language + '&key=' + getGoogleMapsAPIKey();
		//system.debug('input 1: ' + input + ' types 2: ' + types + ' language 3: ' + language);
		String url = 'https://analyticsreporting.googleapis.com/v4/reports:batchGet';
		return executeCallout(url);
	}

	public static String getOauthToken(){

        //String body = 'grant_type=password&username=' +  confWS.CNP_Oauth_Username__c + '&password='+ confWS.CNP_Oauth_Password__c;
        //String body = 'grant_type=password&username=' +  confWSBPB.CNP_Oauth_Username__c + '&password='+ confWSBPB.CNP_Oauth_Password__c;

        String ret 		= '';
        HttpRequest req = new HttpRequest();

        //req.setHeader('Authorization', 'Basic ' +  confWS.CNP_Oauth_Token__c );
        
        req.setMethod('POST');
        //req.setEndpoint(confWS.CNP_OAuth_Endpoint__c);
        
        
        
		string params = 'https://accounts.google.com/o/oauth2/v2/auth?client_id=440520078118-uauf19jepfa196ulj58jnck8jrbt7ooq.apps.googleusercontent.com' +
                '&redirect_uri=https%3A%2F%2Fpsadev1-c1stdev1.cs84.force.com%2FPSADEV1TEST%2Fs%2Fanalyticsreport' +
                '&response_type=code' +
                '&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fanalytics.readonly+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fanalytics+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fanalytics.readonly' +
                '&include_granted_scopes=true' +
                '&state=pass-through value'+
                '&grant_type=authorization_code';
                // '&access_type=offline';


		string url='https://accounts.google.com/o/oauth2/v2/auth?redirect_uri=https%3A%2F%2Fpsadev1-c1stdev1.cs84.force.com%2FPSADEV1TEST%2Fs%2Fanalyticsreport&prompt=consent&response_type=code&client_id=407408718192.apps.googleusercontent.com&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fanalytics.readonly+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fanalytics+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fanalytics.readonly&access_type=offline';

		req.setEndpoint(params);

        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setHeader('Content-Length','800');
        //req.setBody(body);
        Http binding 		= new Http();
        HttpResponse res 	= new HttpResponse();
        //System.debug('Request headers ' + req.getHeader('Authorization'));
        //System.debug('Request body ' + req.getBody());

        try{
            res = binding.send(req);
            OAuth objAuthenticationInfo = (OAuth)JSON.deserialize(res.getbody(), OAuth.class);
        	if(objAuthenticationInfo.access_token != null)
            	ret = objAuthenticationInfo.access_token;
            System.debug('Response Body ' + res.getBody());
        }catch(Exception e){
            System.debug('Callout error: '+ e);
        }

        return ret;
    }

    public static String executeCallout(String url){

    	HTTPRequest req 		= new HttpRequest();
        String accessToken 		= '';
        
        String timestamp 		= '';
        String request_Endpoint =  url;
		System.debug('Request_Endpoint: '+ request_Endpoint);
        
        req.setEndpoint(request_Endpoint);//AUTH HARCODED ON REQUEST AS PARAM
        req.setMethod('POST');
        String bodyval = '{"reportRequests":[{"viewId":"-","dateRanges":[{"startDate":"7daysAgo","endDate":"today"}],"metrics":[{"expression","ga:sessions"}]]}}';
        accessToken = getOauthToken();
        System.debug('acessToken ' + accessToken);
        req.setHeader('Authorization', 'Bearer ' + '4%2FAAAINhPnJHvYpkxSOah5MuRprCOI9uKbg-5bXN-lUD92ebr-HSZAA1OMyHVj3FFxAT8j7QJbVsN-NdvS0zRwP3U');//accessToken
        req.setTimeOut(120000);

        req.setbody(bodyval);

        Http http = new Http();
        
        try{
            HttpResponse resp = http.send(req);
            if(resp != null){
            	System.debug('Response ' + resp.getBody());
            	if(!resp.getBody().contains('Fault')){
            		//ret = parseResponseBpb(resp);
            	}else{
            		//ret = parseResponseError(resp);	
            	}	
            }

         }catch(Exception e){
         	System.debug('Callout error: '+ e);
        }

        return timestamp;
   }



   	public static string postHttp(String url) {
		try {
			Http http 				= new Http();
			HttpRequest request 	= new HttpRequest();
			request.setEndpoint(url);
			request.setMethod('POST');

			String bodyval = '{"reportRequests":[{"viewId":"-","dateRanges":[{"startDate":"7daysAgo","endDate":"today"}],"metrics":[{"expression","ga:sessions"}]]}}';
			system.debug('bodyVal ' + bodyval);
			request.setbody(bodyval);

			HttpResponse response 	= http.send(request);
			system.debug('Response Body: ' + response.getBody() );
			return response.getBody();
		} catch (Exception e) {
			return 'Error';
		}
		
	}
	public class OAuth{
        public String id{get;set;}
        public String issued_at{get;set;}
        public String instance_url{get;set;}
        public String signature{get;set;}
        public String access_token{get;set;}    
    }
 
 */
}
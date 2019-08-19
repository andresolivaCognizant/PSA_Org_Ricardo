public without sharing class RESTInt97A {

    private static Set<String> QUOTE_FILTER_STATUS = new Set<string>();
    private static String QUOTE_FILTER_RECORDTYPE; 
    private static String OPPTY_NEW_STATUS_SUB; 
    private static String OPPTY_NEW_STATUS_OFF; 
    private static String OPPTY_SENDSUBSI_STATUS; 
    private static String OPPTY_SENDOFFER_STATUS; 

    @AuraEnabled 
    public static Map<String, Object> checkMandatoryFields(String req) {
        Map<String, Object> res = new Map<String, Object>();
        
        try {
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(req);
            
            Opportunity o = [
                SELECT
                    Id,
                    FleetCategory__c,
                    ProductionRequest__c,
                    RealQuantity__c,
                    FundingForm__c,
                    FundingCompany__c,
                	Account.Id,
                    Account.Name,
                    Account.NonUniqueFiscalId__c,
                    (
                    SELECT
                        Id,
                        LCDV16__c,
                        ColorCode__c,
                        InteriorTrimCode__c,
                        ProductionYear__c,
                        Quantity__c,
                        SuggestedDiscountTotalAmount__c 
                        FROM SBQQ__Quotes2__r
                    )
                FROM Opportunity
                WHERE Id = :(Id) m.get('record_id')
            ];
            
            res.put('hasError', false);
            res.put('error', null);
            res.put('payload', o);

        } catch (Exception e) {
            res.put('hasError', true);
        }

        return res;
    }
    
    /**
	* @Method: 		checkUserAccess
	* @param: 		N/A
	* @Description:	Validates if the current user can modify the Opportunity is match one of the following rules:
	*				- Is the owner.
	*				- Is a member of the Partner Account
	*				- Is a member of the Partner Account VN contract
	* @author 		Manuel Medina - 04012018
	*/
	public static Boolean checkUserAccess( Id idOpportunity ){
		Opportunity objOpportunity								= new Opportunity();
		objOpportunity											= [SELECT Id,
																		OwnerId,
																		Owner.ContactId,
																		Owner.Contact.AccountId,
																		Owner.Contact.Account.VNContractNumber__c
																	FROM Opportunity
																	WHERE Id =: idOpportunity
																	LIMIT 1
																];

		Map<Id, User> mapUserById								= new Map<Id, User>();
		if( objOpportunity.Owner.ContactId != null && objOpportunity.Owner.Contact.AccountId != null && objOpportunity.Owner.Contact.Account.VNContractNumber__c != null ){
			mapUserById											= new Map<Id, User>( [SELECT Id
																	FROM User
																	WHERE Contact.Account.VNContractNumber__c =: objOpportunity.Owner.Contact.Account.VNContractNumber__c
																] );
		}
																
		if( mapUserById.containsKey( System.UserInfo.getUserId() ) || System.UserInfo.getUserId().equals( objOpportunity.OwnerId ) ){
			return true;
		
		}else{
			return false;
		}
	}

    @AuraEnabled
	public static String SendRequest(Id idOpp){
		/* BEGIN - Manuel Medina - C1ST-11763 - New logic to validate if the user can modify the opportunity - 04012018 */
		Boolean blnHasAccess									= checkUserAccess( idOpp );
		if( !blnHasAccess ){
			return System.Label.OpportunityActionsNotAllowed;
		}
		/* END - Manuel Medina - 04012018 */
		
        loadDefaultValues();
        if(isValidStatus(idOpp,OPPTY_SENDSUBSI_STATUS)){
    		String sMessage   = getResources(idOpp,OPPTY_NEW_STATUS_SUB);
            string sEndResult = '';
            if(!String.isEmpty(sMessage)){
                // Sync
                sEndResult = executeCallout(sMessage,idOpp,true,OPPTY_NEW_STATUS_SUB);
                // Async
                /*
                CalloutInt97A execCOORS = new CalloutInt97A(sMessage,idOpp);
                Id jobID = System.enqueueJob(execCOORS);
                for ( AsyncApexJob jobInfo  : [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob Where Id = :jobID]) {
                   sEndResult = ' Id             : ' + jobInfo.Id  + '\n' +
                   ' Status             : Sent! ' + // + jobInfo.Status + '\n' + 
                   ' TotalJobItems      : ' + jobInfo.TotalJobItems + '\n' +
                   ' JobItemsProcessed  : ' + jobInfo.JobItemsProcessed + '\n' +
                   ' NumberOfErrors     : ' + jobInfo.NumberOfErrors + '\n' +
                   ' Opportunity Updated : Yes';
                }
                */
            }
            System.debug('CalloutInt97A sEndResult: ' + sEndResult);
            return (String.isEmpty(sEndResult))?sMessage:sEndResult;
        }else{
            return System.Label.FleetRequestValidStageMessage;
        }
    }
    @AuraEnabled
    public static String SendRequestOffer(Id idOpp){
    	/* BEGIN - Manuel Medina - C1ST-11763 - New logic to validate if the user can modify the opportunity - 04012018 */
		Boolean blnHasAccess									= checkUserAccess( idOpp );
		if( !blnHasAccess ){
			return System.Label.OpportunityActionsNotAllowed;
		}
		/* END - Manuel Medina - 04012018 */
    	
        loadDefaultValues();
        if(isValidStatus(idOpp,OPPTY_SENDOFFER_STATUS) || isValidStatus(idOpp,'FR1')){
            String sMessage     = getResources(idOpp,OPPTY_NEW_STATUS_OFF);
            string sEndResult   = '';
            if(!String.isEmpty(sMessage)){
                sEndResult      = executeCallout(sMessage,idOpp,true,OPPTY_NEW_STATUS_OFF);
            }
            System.debug('CalloutInt97A sEndResult: ' + sEndResult);
            return (String.isEmpty(sEndResult))?sMessage:sEndResult;
        }else{
            return System.Label.FleetRequestValidStageMessage;
        }
    }
    private static void updateRecords(Id idOpp, String sNewStatus){

        try {
            if (String.isEmpty(sNewStatus)) {
                loadDefaultValues();
            }
            List<Opportunity> lstOpportunities = new List<Opportunity>([
                SELECT Id, StageName, TECH_IsBHCallout__c
                FROM Opportunity
                WHERE Id =: idOpp
            ]);

            lstOpportunities.get(0).StageName           = sNewStatus;
            lstOpportunities.get(0).TECH_IsBHCallout__c = !lstOpportunities.get(0).TECH_IsBHCallout__c;

            update lstOpportunities;
        } catch (Exception e) {
             System.debug('updateRecords error: '+ e);
        }

    }
    private static boolean isValidStatus(Id idOpp, String sStatus){
        try{
            if(String.isEmpty(sStatus)){
                loadDefaultValues();
            }
            List<Opportunity> lstOpportunities = new List<Opportunity>([ SELECT Id, StageName FROM Opportunity WHERE Id =: idOpp]);
            System.debug('isValidStatus StageName: '+ lstOpportunities.get(0).StageName);
            System.debug('isValidStatus sStatus: ' + sStatus);
            return (lstOpportunities.get(0).StageName == sStatus)?true:false;
        }catch(Exception e){
             System.debug('isValidStatus error: '+ e);
             return false;
        }
    }
    private static void loadDefaultValues(){
        for(UtilSetting__mdt larp : [SELECT MasterLabel, QualifiedApiName, Value__c,Value2__c,Value3__c FROM UtilSetting__mdt where QualifiedApiName LIKE 'INT97A_Quote%']){
            if(larp.QualifiedApiName=='INT97A_QuoteStatus'){
                String sValue           = larp.Value__c;
                QUOTE_FILTER_STATUS.addAll(sValue.split(';'));
                QUOTE_FILTER_RECORDTYPE = PAD.getObjRecordType(larp.Value3__c,larp.Value2__c);
            }else if(larp.QualifiedApiName=='INT97A_QuoteOppStatus'){
                OPPTY_NEW_STATUS_SUB    = larp.Value__c;
                OPPTY_NEW_STATUS_OFF    = larp.Value2__c;
            }else if(larp.QualifiedApiName=='INT97A_QuoteOppSendStatus'){
                OPPTY_SENDSUBSI_STATUS  = larp.Value__c;
                OPPTY_SENDOFFER_STATUS  = larp.Value2__c;
            }
        }  
    }
    private static String getResources(Id idOpp, String sStatusToSend){
        BH_Offer auxOffer;
        List<Opportunity> lstOpportunities;
        List<SBQQ__Quote__c> lstQuotes;

        System.debug('getResources	: ' + idOpp);
        if(idOpp != null){
           	lstOpportunities    = new List<Opportunity>([
                                                    SELECT Id, LastModifiedBy.Alias, CreatedBy.LDAPID__c, FleetRequestDate__c, DestinationDealerId__r.VNContractNumber__c, Account.Name,
                                                        Account.NonUniqueFiscalId__c,DestinationDealerID__r.Id,FleetCategory__c,Segment__c, Account.CompanyActivityType__c,
                                                        Account.CreatedDate,Account.InitialCreationDate__c,StageName,ProductionRequest__c,RealQuantity__c,FundingForm__c,FundingCompany__c,Description 
                                                    FROM Opportunity 
                                                    WHERE Id =: idOpp]);
           	System.debug('getResources	OPP: ' + lstOpportunities.size());
            lstQuotes          = new List<SBQQ__Quote__c>([
                                                    SELECT Id,LCDV16__c,ColorCode__c,InteriorTrimCode__c,OptionCodes__c,ProductionYear__c,Quantity__c,
                                                        SuggestedDiscountTotalPercentage__c,SuggestedDiscountTotalAmount__c,CurrencyISOCode,SuggestedSubsidiaryPartPercentage__c,
                                                        SuggestedSubsidiaryPartAmount__c,SuggestedDealerPartPercentage__c,SuggestedDealerPartAmount__c,BasePrice__c,TotalOptions__c,DealerMargin__c 
                                                    FROM SBQQ__Quote__c 
                                                    WHERE SBQQ__Opportunity2__c =: idOpp AND RecordTypeId =: QUOTE_FILTER_RECORDTYPE AND SBQQ__Status__c IN : QUOTE_FILTER_STATUS]);
            List<AccountFleet__c> lstAccountFleets  = new List<AccountFleet__c>([SELECT Id,VolumeOfVehicles__c FROM AccountFleet__c WHERE Account__c =: lstOpportunities.get(0).AccountId]);       
            List<BH_Vehicles> lstVehicles           = new List<BH_Vehicles>();           
            for(SBQQ__Quote__c af : lstQuotes){
                lstVehicles.add(new BH_Vehicles(toString(af.Id),toString(af.LCDV16__c),toString(af.ColorCode__c),toString(af.InteriorTrimCode__c),
                    toString(af.OptionCodes__c),toInteger(String.valueOf(af.ProductionYear__c)),toInteger(String.valueOf(af.Quantity__c)),
                    toDecimal(af.SuggestedDiscountTotalPercentage__c),toDecimal(af.SuggestedDiscountTotalAmount__c),af.CurrencyISOCode,toDecimal(af.SuggestedSubsidiaryPartPercentage__c),
                    toInteger(String.valueOf(af.SuggestedSubsidiaryPartAmount__c)),toDecimal(af.SuggestedDealerPartPercentage__c),toInteger(String.valueOf(af.SuggestedDealerPartAmount__c)),(af.TotalOptions__c==null)?toDecimal(af.BasePrice__c):toDecimal(af.BasePrice__c)+toDecimal(af.TotalOptions__c),toDecimal(af.DealerMargin__c)));
            }

            for(Opportunity op : lstOpportunities){
                auxOffer                            = new BH_Offer(String.valueOf(op.Id), toString(op.CreatedBy.LDAPID__c), toString(String.valueOf(op.FleetRequestDate__c)), toString(op.DestinationDealerId__r.VNContractNumber__c), op.Account.Name,
                                                    toString(op.Account.NonUniqueFiscalId__c),toString(op.Account.Id),
                                                    (lstAccountFleets.isEmpty() || lstAccountFleets.size()==0)?0:Integer.valueOf(lstAccountFleets.get(0).VolumeOfVehicles__c),0,
                                                    toString(String.valueOf(op.FleetCategory__c)),toString(op.Segment__c),toString(op.Account.CompanyActivityType__c),toString(String.valueOf(op.Account.InitialCreationDate__c)),sStatusToSend, //String.valueOf(op.StageName),
                                                    (op.ProductionRequest__c=='1')?true:false,Integer.valueOf(op.RealQuantity__c),String.valueOf(op.FundingForm__c),String.valueOf(op.FundingCompany__c),toString(op.Description),
                                                    lstVehicles);
                
            }
        }
        System.debug('getResources	: ' + JSON.serialize(auxOffer));
        return JSON.serialize(auxOffer);
    }
    private static Integer toInteger(String sVal){
    	return (String.isEmpty(sVal))?0:Integer.valueOf(sVal);
    }
    private static String toString(String sVal){
    	return (String.isEmpty(sVal))?'':String.valueOf(sVal);
    }
    private static Decimal toDecimal(Decimal sVal){
    	return (sVal==null)?0.0:sVal;
    }
    private static Date toDate(String sDate){
    	return (String.isEmpty(sDate))?null:Date.parse(sDate);
    }
	private static DateTime toDateTime(String sDate){
    	return (String.isEmpty(sDate))?null:Datetime.parse(sDate);
    }
    public class BH_Offer{

        public String FleetOfferId;
        public String CreatedByUser;
        public String CreateDate;
        public String Dealer;
        public String ClientName;
        public String FiscalId;
        public String ClientID;
        public Integer CarParkBrand;
        public Integer CarParkOthers;
        public String FleetCategory;
        public String Segment;
        public String Quality;
        public String ClientAge;
        public String Status;
        public Boolean ProductionRequest;
        public Integer RealQuantity;
        public String FundingForm;
        public String FundingCompany;       // Optional
        public String Comments;             // Optional
        public List<BH_vehicles> Vehicles;

        public BH_Offer(String FleetOfferId, String CreatedByUser, String CreateDate, String Dealer,String ClientName, String FiscalId, String ClientID, Integer CarParkBrand,
            Integer CarParkOthers, String FleetCategory, String Segment , String Quality, String ClientAge, String Status, Boolean ProductionRequest, Integer RealQuantity, 
            String FundingForm, String FundingCompany, String Comments, List<BH_Vehicles> Vehicles){
            this.FleetOfferId       = FleetOfferId;
            this.CreatedByUser      = (CreatedByUser!=null)?CreatedByUser:'';
            this.CreateDate         = (CreateDate!=null)?CreateDate:'';
            this.Dealer             = (Dealer!=null)?Dealer:'';
            this.ClientName         = (ClientName!=null)?ClientName:'';
            this.FiscalId           = (FiscalId!=null)?FiscalId:'';
            this.ClientID           = (ClientID!=null)?ClientID:'';
            this.CarParkBrand       = CarParkBrand;
            this.CarParkOthers      = CarParkOthers;
            this.FleetCategory      = (FleetCategory!=null)?FleetCategory:'';
            this.Segment            = (Segment!=null)?Segment:'';
            this.Quality            = (Quality!=null)?Quality:'';
            this.ClientAge          = (ClientAge!=null)?ClientAge:'';
            this.Status             = (Status!=null)?Status:'';
            this.ProductionRequest  = ProductionRequest;
            this.RealQuantity       = RealQuantity;
            this.FundingForm        = (FundingForm!=null)?FundingForm:'';
            this.FundingCompany     = (FundingCompany!=null)?FundingCompany:'';
            this.Comments           = (Comments!=null)?Comments:'';
            this.Vehicles           = Vehicles; 
        }
    }

    public class BH_Vehicles{
        public String QuoteId;
        public String LCDV;
        public String Color;
        public String Trim;
        public String Options;
        public Integer ProductionYear;
        public Integer Quantity;
        public Decimal DiscountTotalPct;
        public Decimal DiscountTotalAmount;
        public String DiscountTotalCurrency;
        public Decimal DicountBrandPct;
        public Integer DicountBrandAmount;
        public Decimal DiscountDealerPct;
        public Integer DiscountDealerAmount;
        public Decimal Price;
        public Decimal Margin;
        
        public BH_Vehicles(String QuoteId, String LCDV, String Color, String Trim, String Options, Integer ProductionYear, Integer Quantity, Decimal DiscountTotalPct,
            Decimal DiscountTotalAmount, String DiscountTotalCurrency, Decimal DicountBrandPct, Integer DicountBrandAmount, Decimal DiscountDealerPct, Integer DiscountDealerAmount,
            Decimal Price, Decimal Margin ){            
            this.QuoteId                =   QuoteId;
            this.LCDV                   =   (LCDV!=null)?LCDV:'';
            this.Color                  =   (Color!=null)?Color:'';
            this.Trim                   =   (Trim!=null)?Trim:'';
            this.Options                =   (Options!=null)?Options:'';
            this.ProductionYear         =   ProductionYear;
            this.Quantity               =   Quantity;
            this.DiscountTotalPct       =   DiscountTotalPct;
            this.DiscountTotalAmount    =   DiscountTotalAmount;
            this.DiscountTotalCurrency  =   (DiscountTotalCurrency!=null)?DiscountTotalCurrency:'';
            this.DicountBrandPct        =   DicountBrandPct;
            this.DicountBrandAmount     =   DicountBrandAmount;
            this.DiscountDealerPct      =   DiscountDealerPct;
            this.DiscountDealerAmount   =   DiscountDealerAmount;
            this.Price                  =   Price;
            this.Margin                 =   Margin;
        }
    }
    
    //public RESTInt97A(JSONParser parser) {
    //    while (parser.nextToken() != System.JSONToken.END_OBJECT) {
    //        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
    //            String text = parser.getText();
    //            if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
    //                if (text == 'errors' || text == 'error') {
    //                    errors = arrayOfErrors(parser);
    //                } else {
    //                    System.debug(LoggingLevel.WARN, 'RESTInt97A consuming unrecognized property: '+text);
    //                    consumeObject(parser);
    //                }
    //            }
    //        }
    //    }
    //}
    //public static RESTInt97A parse(String json) {
    //    System.JSONParser parser = System.JSON.createParser(json);
    //    return new RESTInt97A(parser);
    //}
    //public class Error {
    //    public String application {get;set;} 
    //    public String environment {get;set;} 
    //    public String id {get;set;} 
    //    public String code {get;set;} 
    //    public String timestamp {get;set;} 
    //    public String message {get;set;} 
    //    public String description {get;set;} 
    //    public String system_Z {get;set;} // in json: system

    //    public Error(JSONParser parser) {
    //        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
    //            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
    //                String text = parser.getText();
    //                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
    //                    if (text == 'application') {
    //                        application = parser.getText();
    //                    } else if (text == 'environment') {
    //                        environment = parser.getText();
    //                    } else if (text == 'id') {
    //                        id = parser.getText();
    //                    } else if (text == 'code') {
    //                        code = parser.getText();
    //                    } else if (text == 'timestamp') {
    //                        timestamp = parser.getText();
    //                    } else if (text == 'message') {
    //                        message = parser.getText();
    //                    } else if (text == 'description') {
    //                        description = parser.getText();
    //                    } else if (text == 'system') {
    //                        system_Z = parser.getText();
    //                    } else {
    //                        System.debug(LoggingLevel.WARN, 'Errors consuming unrecognized property: '+text);
    //                        consumeObject(parser);
    //                    }
    //                }
    //            }
    //        }
    //    }
    //}    
    //public List<Error> errors {get;set;} 
    //public static void consumeObject(System.JSONParser parser) {
    //    Integer depth = 0;
    //    do {
    //        System.JSONToken curr = parser.getCurrentToken();
    //        if (curr == System.JSONToken.START_OBJECT || curr == System.JSONToken.START_ARRAY) {
    //            depth++;
    //        } else if (curr == System.JSONToken.END_OBJECT || curr == System.JSONToken.END_ARRAY) {
    //            depth--;
    //        }
    //    } while (depth > 0 && parser.nextToken() != null);
    //}
    //private static List<Error> arrayOfErrors(System.JSONParser p) {
    //    List<Error> res = new List<Error>();
    //    if (p.getCurrentToken() == null) p.nextToken();
    //    while (p.nextToken() != System.JSONToken.END_ARRAY) {
    //        res.add(new Error(p));
    //    }
    //    return res;
    //}


    private static String executeCallout(String sBody,Id idOpp, Boolean bUpdateRecord,String sNewStatus){

        UtilSetting__mdt mdtFleetRequets        = new UtilSetting__mdt();
        mdtFleetRequets                         = [SELECT Id,DeveloperName,Value__c,Value2__c,Value3__c FROM UtilSetting__mdt WHERE DeveloperName =: 'Int97AEndpoint' LIMIT 1];

        Http http               = new Http();
        HTTPRequest request     = new HttpRequest();
        String request_Endpoint =  mdtFleetRequets.Value__c;
        String sResult          = '';
        HttpResponse response;
        System.debug(sBody);
        request.setEndpoint(request_Endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type','application/json');
        request.setHeader('Content-Length', ''+sBody.length());
        request.setClientCertificateName(mdtFleetRequets.Value3__c);
        request.setHeader('X-Timestamp', System.now().format( 'yyyy-MM-dd' ) + 'T' + System.now().format( 'hh:mm:ss' ) );
        request.setHeader('X-ClientSecret', mdtFleetRequets.Value2__c );
        request.setTimeOut(120000);
        request.setbody(sBody);
        Map<String, Object> m = new Map<String, Object> ();
        String sRes;
        
        response = http.send(request);
        
        try{
            
            if(response != null){
                System.debug('Response ' + response.getBody());
                if(response.getStatusCode() == 200 ){
                    System.debug('Response OK' + response.getStatusCode() + ' ' + response.getStatus());
                    sResult = System.Label.RESTInt97A_Result_OK;
                    if(bUpdateRecord){
                        updateRecords(idOpp,sNewStatus);
                    }
                }else{
                    sRes = response.getBody();
                    sRes = sRes.right(sRes.length()-12);
                    sRes = sRes.left(sRes.length()-1);
                    System.debug('Response Updated: ' +sRes);
                    m = (Map<String, Object>) JSON.deserializeUntyped(sRes);
                    System.debug('Error Map: ' + m.get('description'));
                    System.debug('Error Map 2: ' + m.get('message'));
                    //sResult = System.Label.RESTInt97A_Result_KO + ' :' + EncodingUtil.urlDecode(String.valueOf(m.get('description')), 'UTF-8');
                    // BEGIN - US 5639
                    //sResult = System.Label.RESTInt97A_Result_KO + ' :' + ((response.getBody()).split('"message":')[1]).split('"description":' )[0];
       				sResult = System.Label.RESTInt97A_Result_KO + ' : ' + m.get('message');
       				// END - US 5639
                }
            }
         }catch(Exception e){
            //sResult = System.Label.RESTInt97A_Result_KO + ' Exception: ' + e; 
            // BEGIN - US 5639
            //sResult = System.Label.RESTInt97A_Result_KO + ' Exception: ' + ((response.getBody()).split('"message":')[1]).split('"description":' )[0];
            sRes = response.getBody();
            sRes = sRes.right(sRes.length()-12);
            sRes = sRes.left(sRes.length()-1);
            
            m = (Map<String, Object>) JSON.deserializeUntyped(sRes);
            sResult = System.Label.RESTInt97A_Result_KO + ' Exception: ' + m.get('message');
            // END - US 5639

            System.debug('Callout error: '+ e);
        }
        return sResult;
   }
   public class CalloutInt97A implements Queueable,Database.AllowsCallouts {
        
        private final String sMsgs;
        private final Id idOpp;
        private final Boolean bUpdateRecord;
        private final String sStatus;
        public CalloutInt97A(String sBody,Id idOpp,Boolean bUpdateRecord, String sStatus) {
            this();
            this.idOpp          = idOpp;
            this.sMsgs          = sBody;
            this.bUpdateRecord  = bUpdateRecord;
            this.sStatus        = sStatus;
        }
        public CalloutInt97A() {}
        public void execute(QueueableContext context) {
            executeCallout(sMsgs,idOpp,bUpdateRecord,sStatus);
        }
    }
    
    
}
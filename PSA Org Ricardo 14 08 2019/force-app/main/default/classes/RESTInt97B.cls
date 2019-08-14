@RestResource(urlMapping='/fleetRequest')
global with sharing class RESTInt97B  {


    //====================================================================================
    // *** REST POST *** : Require field should not be empty, method to post a FleetOffer
    //====================================================================================
    @HttpPost
    //global static String FleetOffer(String FleetOfferId, String CustomerId, Datetime OrderFrom,Datetime OrderTo,Date MaxDPG,
    //    String ProductionRequest,String RealQuantity,String Status,Boolean BonusCalculated,String Acceptedby,
    //    Datetime Acceptedon,String QuoteId,Decimal Discountbrand,String Discountbrandtype,Decimal Discountdealer,String Discountdealertype){
       global static String fleetRequest(bh_opportunity opportunity, bh_account account, List<bh_quote> quote){
        List<Opportunity> lstOpportunities ;
        List<SBQQ__Quote__c> lstQuotes;
        List<sObject> aux       =  new List<sObject>();
        //The fleet request ([GENERAL_RULE_FLEET_REQ_03]) concerned by the response is updated according to the response
        //if(isValidId(FleetOfferId) && isValidId(CustomerId) && isValidId(QuoteId )){
            lstOpportunities    = new List<Opportunity>([
                                SELECT 
                                    Id,DestinationDealerID__r.VNContractNumber__c,Account.NonUniqueFiscalId__c,Account.Id,StageName,
                                    ProductionRequest__c,ApprovedQuantity__c,CalculatedBonus__c,AcceptedBy__c, AcceptedOn__c, OrderStartDate__c,OrderEndDate__c,
                                    MaxDeliveryDate__c,FundingForm__c,FundingCompany__c,FleetCategory__c,Segment__c,Account.CompanyActivityType__c,
                                    Description 
                                FROM 
                                    Opportunity 
                                //]);
                                //WHERE 
                                    //Id =:FleetOfferId]);
                                WHERE 
                                    Id =:opportunity.id]);
            lstQuotes           = new List<SBQQ__Quote__c>([
                                SELECT 
                                    Id,SubsidiaryPartPercentage__c,CurrencyISOCode,DealerPartPercentage__c,SBQQ__Status__c
                                FROM 
                                    SBQQ__Quote__c 
                                WHERE 
                                    SBQQ__Opportunity2__c =: lstOpportunities.get(0).Id 
                                    //AND 
                                    //Id =: QuoteId 
                                    AND 
                                    Id =: quote.get(0).id 
                                    //AND  SBQQ__Status__c = '1'
                                    ]);
            for(Opportunity op : lstOpportunities){
                //op.Account.NonUniqueFiscalId__c = account.nonUniqueFiscalId;
                //op.OrderStartDate__c     = opportunity.orderStartDate;
                //op.OrderEndDate__c       = opportunity.orderEndDate;
                op.ProductionRequest__c  = opportunity.productionRequest;
                op.ApprovedQuantity__c   = Decimal.valueOf(opportunity.approvedQuantity);
                //op.FundingForm__c        = FundingForm;
                //op.FundingCompany__c     = FundingCompany;
                //op.FleetCategory__c      = FleetCategory;
                //op.Segment__c            = Sopportunity.egment;
                //op.Account.CompanyActivityType__c = CompanyActivityType,
                //op.Description           = Comments;
                //op.MaxDeliveryDate__c    = MaxDPG;
                op.StageName               =  opportunity.stage;
                op.CalculatedBonus__c      =  opportunity.bonusCalculated;
            }
            Integer iPos = 0;
            for(SBQQ__Quote__c af : lstQuotes){
                
                if(iPos<=quote.size()){
                    bh_quote auxQuote = quote.get(iPos);
                    if(auxQuote!=null){
                        af.SubsidiaryPartPercentage__c   = Decimal.valueOf(auxQuote.subsidiaryPartPct);
                        af.DealerPartPercentage__c       = Decimal.valueOf(auxQuote.dealerPartPct);
                        af.SBQQ__Status__c               = auxQuote.status;
                    }
                }
                iPos+=1;
            }
        //}
        try{
            //5   Quotes related to the fleet request ([GENERAL_RULE_QUOTE_02]) are updated in C1ST 
            aux.addAll(lstOpportunities);
            aux.addAll(lstQuotes);  
            update aux;
        } catch(DmlException e) {
            system.debug('DmlException' + e);
        } catch(Exception e) {
            system.debug('Exception' + e);
        }
        return  JSON.serialize(aux);  
    }
    private static boolean isValidId(String sParam){
        
        boolean bResponse   = false;
        if(!String.isEmpty(sParam)){
            if(sParam.length()==15 || sParam.length()==18 ){
                bResponse   = true;
            }
        }
        return bResponse;
    }


    global class bh_quote{
        global String id;
        global String subsidiaryPartPct;
        global String dealerPartPct;
        global String status;
        global bh_quote(String id, String subsidiaryPartPct, String dealerPartPct, String  status){
            this.id                     = id;
            this.subsidiaryPartPct      = subsidiaryPartPct;
            this.dealerPartPct          = dealerPartPct;
            this.status                 = status;
        }
    }
    global class bh_account{
        global String vnContractNumber;
        global String nonUniqueFiscalId;
        global bh_account(String vnContractNumber, String nonUniqueFiscalId ){
            this.vnContractNumber       = vnContractNumber;
            this.nonUniqueFiscalId      = nonUniqueFiscalId;
        }
    }
    global class bh_opportunity{
        global String id;
        global String accountId;
        global String stage;
        global String productionRequest;
        global String approvedQuantity;
        global Boolean bonusCalculated;
        global Integer orderStartDate;
        global Decimal orderEndDate;
        global Decimal fundingForm;
        global String fleetCategory;
        global Decimal segment;
        global Decimal companyActivityType;
        
        global bh_opportunity(String id, String accountId, String stage, String productionRequest, String approvedQuantity, Boolean bonusCalculated, Integer orderStartDate, Decimal orderEndDate,
            Decimal fundingForm, String fleetCategory, Decimal segment, Decimal companyActivityType ){
            this.id                      =   id;
            this.accountId               =   accountId;
            this.stage                   =   stage;
            this.productionRequest       =   productionRequest;
            this.approvedQuantity        =   approvedQuantity;
            this.bonusCalculated         =   bonusCalculated;
            this.orderStartDate          =   orderStartDate;
            this.orderEndDate            =   orderEndDate;
            this.fundingForm             =   fundingForm;
            this.fleetCategory           =   fleetCategory;
            this.segment                 =   segment;
            this.companyActivityType     =   companyActivityType;
 
        }

    }
}
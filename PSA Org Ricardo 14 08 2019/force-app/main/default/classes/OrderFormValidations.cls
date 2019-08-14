public class OrderFormValidations {


    public static void OrderFormValidation(List<Opportunity> lNewOpportunities){
        Map<id, Opportunity> MapOpp = new Map<id, Opportunity>();
        String country = '%' + PAD.sUserCountry + '%';


        System.debug('Test country ' +  country);

        List<UtilSetting__mdt> utilSettings = [select Value__c from UtilSetting__mdt where DeveloperName = 'OrderFormValidation' AND Value__c LIKE :country];
        if(!utilSettings.isEmpty()){
           // for(UtilSetting__mdt util : utilSettings){
            //System.debug('Test country ' +  country);
            for(Opportunity Opp : lNewOpportunities){
                if(Opp.StageName == '6'){
                   MapOpp.put(Opp.Id, Opp);
                }
            }


        //}


        list<SBQQ__Quote__c> quotes = [select id, SBQQ__Opportunity2__c from SBQQ__Quote__c where SBQQ__Opportunity2__c IN :MapOpp.keySet() AND recordType.developername LIKE '%Form%' AND SalesManagerValidationFlag__c = false AND SBQQ__Status__c = '2'];

        //for(UtilSetting__mdt util : utilSettings){
            for(SBQQ__Quote__c orderForm : quotes){
                System.debug('VALIDATION ERROR');
                MapOpp.get(orderForm.SBQQ__Opportunity2__c).addError('VALIDATION ERROR');
            }
        }
        //}

    }

}
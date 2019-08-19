public class OrderFormProductListDealer {
    
    private final static id RT_ORDERFORM = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get(Label.RT_CPQOrderForm).getRecordTypeId();
    
    public class ObjectRequestListProduct {

        @InvocableVariable(
            label           = 'Product Id'
            description     = 'The record to be processed'
            required        = true
        )
        public String idProduct;
        
        @InvocableVariable(
            label           = 'Quote Id'
            description     = 'The record to be cloned'
            required        = true
        )
        public String idQuote;

    }
    
    @InvocableMethod(
        label       = 'PB: Show all products related'
        description = 'Show all products related'
    )
    
    public static void handleRecords (List<ObjectRequestListProduct> requests){
        
        System.debug('START handleRecords');
        //List<String> lResult 						= new List<String>();
        List<Id> lstRecords  						= new List<Id>();
        List<SBQQ__QuoteLine__c> lQLines 			= new List<SBQQ__QuoteLine__c>();
        String newQteId;
        for(ObjectRequestListProduct r : requests){ 
     		lstRecords.add(r.idQuote);
            
     	}
     	
  
		
        if(!lstRecords.isEmpty()){
            if(Test.isRunningTest()){
                lQLines = [SELECT Id, SBQQ__Product__c, SBQQ__Product__r.Reserved__c, SBQQ__Quote__c, SBQQ__Quote__r.ReservedVehicle__c, SBQQ__Quote__r.RecordType.Name, SBQQ__Product__r.Stock__c, SBQQ__Product__r.ProductCode, SBQQ__Product__r.ColorCode__c, SBQQ__Product__r.InteriorTrimCode__c, SBQQ__Product__r.OptionsCode__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :lstRecords]; 			
            } else { 
                lQLines = [SELECT Id, SBQQ__Product__c, SBQQ__Product__r.Reserved__c, SBQQ__Quote__c, SBQQ__Quote__r.ReservedVehicle__c, SBQQ__Quote__r.RecordType.Name, SBQQ__Product__r.Stock__c, SBQQ__Product__r.ProductCode, SBQQ__Product__r.ColorCode__c, SBQQ__Product__r.InteriorTrimCode__c, SBQQ__Product__r.OptionsCode__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :lstRecords AND SBQQ__Product__r.Is_bundle__c = true]; 			
            }
        

            if(requests != null && !requests.isEmpty() && requests[0].idQuote != null && requests[0].idProduct != null){

                    newQteId = OrderFormCreate.cloneQuote(lQLines, requests[0].idProduct, lstRecords);
                    //lResult.add(newQteId);
                    OrderFormCreate.cloneExpenses(lQLines[0].SBQQ__Quote__c,newQteId);
                    
                
                    
            }
            
       }
        //return  lResult;

    
    }
    
    
    
    

}
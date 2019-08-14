public class OrderFormFreeSetProduct {
    
    private final static id RT_ORDERFORM = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('CPQ_Order_Form').getRecordTypeId();
    
    public class ObjectRequestListProduct {
   
        @InvocableVariable(
            label           = 'Quote Id'
            description     = 'The record to be cloned'
            required        = true
        )
        public String idQuote;
        
        @InvocableVariable(
            label           = 'Quantity'
            description     = 'Quantity of OrderForms to create'
            required        = true
        )
        public Integer Quantity;

    }
    
    @InvocableMethod(
        label       = 'PB: Select freeset products'
        description = 'Select freeset products'
    )
    
    public static List<String> handleRecords (List<ObjectRequestListProduct> requests){
        
        System.debug('START handleRecords FreeSet products');
        List<String> lResult 						= new List<String>();
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
        
			System.debug('##OFFSP## lQLines: '+lQLines);
            if(requests != null && !requests.isEmpty() && requests[0].idQuote != null && !lQLines.isEmpty()){
				
                List<String> result = OrderFormCreate.cloneFreeSetPrd(lQLines, lstRecords, requests[0].Quantity);
                // This if is needed because the flow expects, as much, one element
                if(!result.isEmpty()){
                    return new List<String>{result[0]};
                }else{
                    return new List<String>();
                }
            }
            
       }
       
        return (!lstRecords.isEmpty())?new List<String> {lstRecords[0]}:new List<String>{};

    
    }
    
    
    
    

}
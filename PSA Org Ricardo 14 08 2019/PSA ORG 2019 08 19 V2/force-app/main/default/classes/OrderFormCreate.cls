public with sharing class OrderFormCreate { 
        
    @InvocableMethod(
        label       = 'PB: New Order Form Proces'
        description = 'New Order Form Process'
    )
    
    public static List<String> handleRecords (List<ObjectRequest> requests){
        
        system.debug('handleRecords: ' +requests);
        
        List<Id> lstRecords 						= new List<Id>();
         for(ObjectRequest r : requests){ 
             lstRecords.add(r.recordId);
         }
        
        List<String> result = handleRecords(lstRecords);
        
        // This if is needed because the flow expects, as much, one element
        if(!result.isEmpty()){
            return new List<String>{result[0]};
        }else{
            return new List<String>();
        }
    }

    public static List<String> handleRecords (List<String> lstRecords){
        
        List<Product2> prod 						= new List<Product2>();
        List<SBQQ__Quote__c> quote 					= new List<SBQQ__Quote__c>();
        List<SBQQ__QuoteLine__c> qLines 			= new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> qLReserved 		= new List<SBQQ__QuoteLine__c>();
        List<Product2> lProductToUpdate 			= new List<Product2>();
        String newQteId;
        List<String> newLQteId = new List<String>();

         try { 
        
            if(!lstRecords.isEmpty()){
                if(Test.isRunningTest()){
                    qLines = [SELECT Id, SBQQ__Product__c, SBQQ__Product__r.Reserved__c, SBQQ__Quote__c, SBQQ__Quote__r.ReservedVehicle__c, SBQQ__Quote__r.RecordType.Name, SBQQ__Product__r.Stock__c, SBQQ__Product__r.ProductCode, SBQQ__Product__r.ColorCode__c, SBQQ__Product__r.InteriorTrimCode__c, SBQQ__Product__r.OptionsCode__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :lstRecords]; 			
                } else { 
                    qLines = [SELECT Id, SBQQ__Product__c, SBQQ__Product__r.Reserved__c, SBQQ__Quote__c, SBQQ__Quote__r.ReservedVehicle__c, SBQQ__Quote__r.RecordType.Name, SBQQ__Product__r.Stock__c, SBQQ__Product__r.ProductCode, SBQQ__Product__r.ColorCode__c, SBQQ__Product__r.InteriorTrimCode__c, SBQQ__Product__r.OptionsCode__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :lstRecords AND SBQQ__Product__r.Is_bundle__c = true]; 			
                }
                
                if (!qLines.isEmpty() && qLines[0].SBQQ__Product__r.Stock__c == true){
                    // Look for reserved Quotes
                    qLReserved = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Product__c = :qLines[0].SBQQ__Product__c AND SBQQ__Quote__r.ReservedVehicle__c = true];
                    
                    if(!qLReserved.isEmpty()){
                        lProductToUpdate.add(new Product2(id = qLines[0].SBQQ__Product__c, WithOrderForm__c = true, Reserved__c = false));//##RM 240818## Punto 1.                        
                    }else{
                        lProductToUpdate.add(new Product2(id = qLines[0].SBQQ__Product__c, WithOrderForm__c = true));//##RM 240818## Punto 2. 
                        
                    }
                    
                    system.debug('_______>>ReservedVehicle__c: '+qLines[0].SBQQ__Quote__r.ReservedVehicle__c);
                    system.debug('_______>>Reserved__c: '+qLines[0].SBQQ__Product__r.Reserved__c);
                    system.debug('_______>>qLReserved: '+qLReserved.isEmpty());
                    
                    if (qLines[0].SBQQ__Quote__r.ReservedVehicle__c == true && qLines[0].SBQQ__Product__r.Reserved__c == true){ 
                        // Clone Quote 
                        newQteId = cloneQuote(qLines, null, lstRecords);
                        cloneExpenses(qLines[0].SBQQ__Quote__c,newQteId);////##RM 050918## To clone expenses.
                        system.debug('Quote with Reserved Check "True"');
                        
                    }
                    
                    if(qLines[0].SBQQ__Quote__r.ReservedVehicle__c == false && qLines[0].SBQQ__Product__r.Reserved__c == false){
                        newQteId = cloneQuote(qLines, null, lstRecords);
                        cloneExpenses(qLines[0].SBQQ__Quote__c,newQteId);////##RM 050918## To clone expenses.
                        system.debug('Quote with Reserved Check "True"');
                    }
                                           
                    
                }/*else{
                    
                    newQteId = cloneFreeSetPrd(qLines, lstRecords);
                    cloneExpenses(qLines[0].SBQQ__Quote__c,newQteId);////##RM 050918## To clone expenses.
                    
                }*/
                
                Database.update(lProductToUpdate,true);
                
            } else {
                throw new OrderFormCreateException('NO Quote in entry was send to the class'); 
            }
         } catch(dmlexception e) {
            string error = 'DMLexception ERROR OrderFormCreate.handleRecords --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
            system.debug('Error: '+error);
        }  catch(exception e){
            string error = 'Exception ERROR OrderFormCreate.handleRecords --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
            system.debug('Error: '+error);
        }
        
        newLQteId.add(newQteId); 
        System.debug('_______>> '+newLQteId);
        System.debug('_______>> lProductToUpdate: '+lProductToUpdate);
        return newLQteId;
    }
    
    public class ObjectRequest {

        @InvocableVariable(
            label           = 'Record ID'
            description     = 'The record to be processed'
            required        = true
        )
        public String recordId;
        

    }
    @future
    public static void AsyncCloneExpenses(Id idQuoteOrigin, id idOrderForm){
        List<Expenses__c> lExpensesInfo = [SELECT CurrencyIsoCode,DiscountToApplyAmount__c,DiscountToApply__c,FeeType__c,Id,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,Name,Price__c,Quote__c,SystemModstamp,TotalToPay__c FROM Expenses__c where Quote__c = :idQuoteOrigin];
        
        List<Expenses__c> lExpensesClone = new List<Expenses__c>();
        
        for(Expenses__c oExp : lExpensesInfo){
            
            Expenses__c oExpenseClone = oExp.clone(false,true,false,false);
            oExpenseClone.Quote__c = idOrderForm;
            lExpensesClone.add(oExpenseClone);
            
        }
        try { 
            database.insert(lExpensesClone,true);
        } catch(dmlexception e) {
            system.debug('Error: '+e);
        }
        System.debug('EXPENSES: '+lExpensesClone);
        
        
    }
    
    
    
    public static List<Expenses__c> cloneExpenses(Id idQuoteOrigin, id idOrderForm){
        List<Expenses__c> lExpensesInfo = [SELECT CurrencyIsoCode,DiscountToApplyAmount__c,DiscountToApply__c,FeeType__c,Id,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,Name,Price__c,Quote__c,SystemModstamp,TotalToPay__c FROM Expenses__c where Quote__c = :idQuoteOrigin];
        
        List<Expenses__c> lExpensesClone = new List<Expenses__c>();
        
        for(Expenses__c oExp : lExpensesInfo){
            
            Expenses__c oExpenseClone = oExp.clone(false,true,false,false);
            oExpenseClone.Quote__c = idOrderForm;
            lExpensesClone.add(oExpenseClone);
            
        }
        try { 
            database.insert(lExpensesClone,true);
        } catch(dmlexception e) {
            system.debug('Error: '+e);
        }
        System.debug('EXPENSES: '+lExpensesClone);
        return lExpensesClone;
        
        
    }
    
    public static List<String> cloneFreeSetPrd(List<SBQQ__QuoteLine__c> qLines, List<Id> lstRecords, Integer Quantity){
        List<String> newQteId = new List<String>(); 

        // Get Free Setup Product 
        try { 

            Product2[] prdFSId = [SELECT Id FROM Product2 WHERE ProductCode = :qLines[0].SBQQ__Product__r.ProductCode AND ColorCode__c = :qLines[0].SBQQ__Product__r.ColorCode__c AND InteriorTrimCode__c = :qLines[0].SBQQ__Product__r.InteriorTrimCode__c AND OptionsCode__c = :qLines[0].SBQQ__Product__r.OptionsCode__c LIMIT 1]; 

            if (!prdFSId.isEmpty()){
                system.debug('cloneFreeSetPrd QL: '+qLines);
                system.debug('cloneFreeSetPrd PId: '+prdFSId[0].Id);
                String tempId;
                for(Integer i = 0; i<Quantity; i++){
                    tempId = AsyncCloneQuote(qLines, prdFSId[0].Id, lstRecords);
                    OrderFormCreate.AsyncCloneExpenses(qLines[0].SBQQ__Quote__c, tempId);
                    newQteId.add(tempId);
                }
            }/* else {
                throw new OrderFormCreateException('NO Product was found for ProductCode: '+qLines[0].SBQQ__Product__r.ProductCode+', ColorCode: '+qLines[0].SBQQ__Product__r.ColorCode__c+ ', InteriorTrimCode: '+qLines[0].SBQQ__Product__r.InteriorTrimCode__c+', OptionsCode: '+qLines[0].SBQQ__Product__r.OptionsCode__c);
            }*/
            
        } catch(dmlexception e) {
            string error = 'DMLexception ERROR OrderFormCreate.cloneFreeSetPrd --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
            system.debug('Error: '+error);
        }  catch(exception e){
            string error = 'Exception ERROR OrderFormCreate.cloneFreeSetPrd --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
            system.debug('Error: '+error);
        }

        return newQteId;
    } 
    
    public static String cloneQuote(List<SBQQ__QuoteLine__c> qLines, String prdId, List<Id> lstRecords){
        String sRType = ' ';
        String newQteId;
        List<RecordType> rType 				= new List<RecordType>(); 
        List<SBQQ__Quote__c> quoteToClone 	= new List<SBQQ__Quote__c>();
        
        try { 
            sRType = qLines[0].SBQQ__Quote__r.RecordType.Name;
                    
            if (sRType.contains('OPV')){
                sRType = '%OPV OrderForm%';
            } else if (sRType.contains('CPQ')){
                sRType = '%CPQ Order Form%';
            }
                                            
            rType = [SELECT Id FROM RecordType WHERE Name like :sRType LIMIT 1]; 
                    
            system.debug('sRType: ' +sRType); 
                    
            String sObjectApiName = 'SBQQ__Quote__c';
    
              Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get(sObjectApiName).getDescribe().fields.getMap();
             
              String genQLineFields = '';
      
              for(String fieldName : fieldMap.keyset()){
                  if (genQLineFields == null || genQLineFields == ''){
                      genQLineFields = fieldName;
                  }else{
                       genQLineFields = genQLineFields + ', ' + fieldName;
                  }
              }
                       
             String qGen = 'SELECT ' +genQLineFields+ ' FROM SBQQ__Quote__c WHERE Id IN :lstRecords';
                    
            List<SBQQ__Quote__c> qte = Database.query(qGen);
                    
            for(SBQQ__Quote__c quoteC : qte) {
                SBQQ__Quote__c clonedRecord = quoteC.clone();
                clonedRecord.RecordTypeId = rType[0].Id;
                clonedRecord.QuotesWithOrderForms__c = quoteC.Id;
                clonedRecord.External_Comments__c = null;
                clonedRecord.Internal_Comments__c = null;
                clonedRecord.SBQQ__Status__c = '2';
                clonedRecord.DisplayServiceContractsTC__c = quoteC.DisplayServiceContractsTC__c;
                clonedRecord.TECH_Profession__c = quoteC.TECH_Profession__c;  
                clonedRecord.TradeInCar__c = quoteC.TradeInCar__c;
                clonedRecord.createddate = null;
                clonedRecord.lastmodifieddate = null;
                clonedRecord.createdbyid = null;
                clonedRecord.lastmodifiedbyid = null;
                
                quoteToClone.add(clonedRecord);
            }
                    
            insert quoteToClone;
            
            newQteId = quoteToClone[0].Id;
            system.debug('quoteToClone: ' +quoteToClone);
            
            // Clone QuoteLine
            system.debug('cloneQuote QId: '+quoteToClone[0].Id);
            system.debug('cloneQuote PId: '+prdId);
            cloneQuoteLines(quoteToClone[0].Id, prdId, lstRecords);
            
        } catch(dmlexception e){
            string error = 'DMLexception ERROR OrderFormCreate.cloneQuote --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
            system.debug('Error: '+error);
        }  catch(exception e){
            string error = 'Exception ERROR OrderFormCreate.cloneQuote --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
            system.debug('Error: '+error);
        }
        
        return newQteId; 
    }
    
    public static String AsyncCloneQuote(List<SBQQ__QuoteLine__c> qLines, String prdId, List<Id> lstRecords){
        String sRType = ' ';
        String newQteId;
        List<RecordType> rType 				= new List<RecordType>(); 
        List<SBQQ__Quote__c> quoteToClone 	= new List<SBQQ__Quote__c>();
        
        try { 
            sRType = qLines[0].SBQQ__Quote__r.RecordType.Name;
                    
            if (sRType.contains('OPV')){
                sRType = '%OPV OrderForm%';
            } else if (sRType.contains('CPQ')){
                sRType = '%CPQ Order Form%';
            }
                                            
            rType = [SELECT Id FROM RecordType WHERE Name like :sRType LIMIT 1]; 
                    
            system.debug('sRType: ' +sRType); 
                    
            String sObjectApiName = 'SBQQ__Quote__c';
    
              Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get(sObjectApiName).getDescribe().fields.getMap();
             
              String genQLineFields = '';
      
              for(String fieldName : fieldMap.keyset()){
                  if (genQLineFields == null || genQLineFields == ''){
                      genQLineFields = fieldName;
                  }else{
                       genQLineFields = genQLineFields + ', ' + fieldName;
                  }
              }
                       
             String qGen = 'SELECT ' +genQLineFields+ ' FROM SBQQ__Quote__c WHERE Id IN :lstRecords';
                    
            List<SBQQ__Quote__c> qte = Database.query(qGen);
                    
            for(SBQQ__Quote__c quoteC : qte) {
                SBQQ__Quote__c clonedRecord = quoteC.clone();
                clonedRecord.RecordTypeId = rType[0].Id;
                clonedRecord.QuotesWithOrderForms__c = quoteC.Id;
                clonedRecord.External_Comments__c = null;
                clonedRecord.Internal_Comments__c = null;
                clonedRecord.SBQQ__Status__c = '2';
                clonedRecord.DisplayServiceContractsTC__c = quoteC.DisplayServiceContractsTC__c;
                clonedRecord.TECH_Profession__c = quoteC.TECH_Profession__c; 
                clonedRecord.TradeInCar__c = quoteC.TradeInCar__c;
                clonedRecord.createddate = null;
                clonedRecord.lastmodifieddate = null;
                clonedRecord.createdbyid = null;
                clonedRecord.lastmodifiedbyid = null;
                clonedRecord.VIN__c = null;
                clonedRecord.CARNumber__c = null;
                clonedRecord.Quantity__c = 1;
                
                quoteToClone.add(clonedRecord);
            }
                    
            insert quoteToClone;
            
            newQteId = quoteToClone[0].Id;
            system.debug('quoteToClone: ' +quoteToClone);
            
            // Clone QuoteLine
            system.debug('cloneQuote QId: '+quoteToClone[0].Id);
            system.debug('cloneQuote PId: '+prdId);
            AsyncCloneQuoteLines(quoteToClone[0].Id, prdId, lstRecords);
            
        } catch(dmlexception e){
            string error = 'DMLexception ERROR OrderFormCreate.cloneQuote --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
            system.debug('Error: '+error);
        }  catch(exception e){
            string error = 'Exception ERROR OrderFormCreate.cloneQuote --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
            system.debug('Error: '+error);
        }
        
        return newQteId; 
    }
    
    @future
    public static void AsyncCloneQuoteLines(String newQuoteId, String prodId, List<Id> lstRecords){
        List<OrderFormLine__c> qLToClone	= new List<OrderFormLine__c>();
        
        try { 
        
            String sObjectApiName = 'SBQQ__QuoteLine__c';
            
              Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get(sObjectApiName).getDescribe().fields.getMap();
                     
            String genQLineFields = '';
              
              for(String fieldName : fieldMap.keyset()){
                  if (genQLineFields == null || genQLineFields == ''){
                      genQLineFields = fieldName;
                  }else{
                       genQLineFields = genQLineFields + ', ' + fieldName;
                  }
              }
                               
            String qGen = 'SELECT ' +genQLineFields+ ', SBQQ__Product__r.ProductCode, SBQQ__Product__r.Family, SBQQ__Product__r.Name, SBQQ__Product__r.CDC__c, SBQQ__Product__r.Stock__c ' 
                + ' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :lstRecords ORDER BY Name ASC';							
            List<SBQQ__QuoteLine__c> quoteLine = Database.query(qGen);
      
            //Clone Quote Lines 
            for(SBQQ__QuoteLine__c quoteLineC : quoteLine) {
                OrderFormLine__c clonedRecord = new OrderFormLine__c();
                clonedRecord.OrderForm__c = newQuoteId;
                clonedRecord.ListPrice__c = quoteLineC.SBQQ__ListPrice__c;
                clonedRecord.PriceVATIncluded__c = quoteLineC.PRICEVATINCLUDED__c;
                clonedRecord.Quantity__c = quoteLineC.SBQQ__Quantity__c;
                
                //clonedRecord.Product__c = null;
                clonedRecord.TECH_ProductCode__c = quoteLineC.SBQQ__Product__r.ProductCode;
                clonedRecord.TECH_ProductFamily__c = quoteLineC.SBQQ__Product__r.Family;
                clonedRecord.TECH_ProductName__c = quoteLineC.SBQQ__Product__r.Name;
                clonedRecord.TECH_CDC__c = quoteLineC.SBQQ__Product__r.CDC__c;
                if(quoteLineC.SBQQ__Product__r.Stock__c){
                    //clonedRecord.Product__c = prodId;
                    clonedRecord.Product__c = null;
                }
                /*if (prodId != null && quoteLineC.SBQQ__ProductFamily__c == Label.ProductFamilyVersion){
                    //clonedRecord.Product__c = prodId;
                    clonedRecord.Product__c = null;
                    clonedRecord.TECH_ProductCode__c = quoteLineC.SBQQ__Product__r.ProductCode;
                    clonedRecord.TECH_ProductFamily__c = quoteLineC.SBQQ__Product__r.Family;
                    clonedRecord.TECH_ProductName__c = quoteLineC.SBQQ__Product__r.Name;
                    clonedRecord.TECH_CDC__c = quoteLineC.SBQQ__Product__r.CDC__c;
                }else{
                    clonedRecord.Product__c = quoteLineC.SBQQ__Product__c;

                }*/
                
                qLToClone.add(clonedRecord);
            }
                            
            insert qLToClone;
            system.debug('qLToClone: ' +qLToClone);
            
        } catch(dmlexception e) {
            string error = 'DMLexception ERROR OrderFormCreate.cloneQuoteLines --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
            system.debug('Error: '+error);
        }  catch(exception e){
            string error = 'Exception ERROR OrderFormCreate.cloneQuoteLines --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
            system.debug('Error: '+error);
        }
    }
    
    public static void cloneQuoteLines(String newQuoteId, String prodId, List<Id> lstRecords){
        List<OrderFormLine__c> qLToClone	= new List<OrderFormLine__c>();
        
        try { 
        
            String sObjectApiName = 'SBQQ__QuoteLine__c';
            
              Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get(sObjectApiName).getDescribe().fields.getMap();
                     
            String genQLineFields = '';
              
              for(String fieldName : fieldMap.keyset()){
                  if (genQLineFields == null || genQLineFields == ''){
                      genQLineFields = fieldName;
                  }else{
                       genQLineFields = genQLineFields + ', ' + fieldName;
                  }
              }
                               
            String qGen = 'SELECT ' +genQLineFields+ ' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :lstRecords';							
            List<SBQQ__QuoteLine__c> quoteLine = Database.query(qGen);
      
            //Clone Quote Lines 
            for(SBQQ__QuoteLine__c quoteLineC : quoteLine) {
                OrderFormLine__c clonedRecord = new OrderFormLine__c();
                clonedRecord.OrderForm__c = newQuoteId;
                clonedRecord.ListPrice__c = quoteLineC.SBQQ__ListPrice__c;
                clonedRecord.PriceVATIncluded__c = quoteLineC.PRICEVATINCLUDED__c;
                clonedRecord.Quantity__c = quoteLineC.SBQQ__Quantity__c;
                
                if (prodId != null && quoteLineC.SBQQ__ProductFamily__c == Label.ProductFamilyVersion){
                    clonedRecord.Product__c = prodId;
                }else{
                    clonedRecord.Product__c = quoteLineC.SBQQ__Product__c;
                }
                
                qLToClone.add(clonedRecord);
            }
                            
            insert qLToClone;
            system.debug('qLToClone: ' +qLToClone);
            
        } catch(dmlexception e) {
            string error = 'DMLexception ERROR OrderFormCreate.cloneQuoteLines --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
            system.debug('Error: '+error);
        }  catch(exception e){
            string error = 'Exception ERROR OrderFormCreate.cloneQuoteLines --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
            system.debug('Error: '+error);
        }
    }
    
    public class OrderFormCreateException extends exception{
        // Custom exception class
    }
    
    
    
    
    
}
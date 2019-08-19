public with sharing class CheckProductReservation {
    
    private final static string ORDERFORM_RECORDTYPEID 	= Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('CPQ_Order_Form').getRecordTypeId();
    private final static string CPQQUOTE_RECORDTYPEID 	= Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('CPQ_Quote').getRecordTypeId();
    private final static string MSG_ERROR				= Label.ErrorProduct;
    private final static string MSG_ERROREDITDEL		= Label.ErrorEditionDeletion;
    private final static string FAMILY_VERSION 			= Label.ProductFamilyVersion;
    private final static string FAMILY_COLOR 			= Label.ProductFamilyColor;
    private final static string FAMILY_OPTIONS 			= Label.ProductFamilyOptions;
    private final static string FAMILY_INTERIOR 		= Label.ProductFamilyInterior;
    
    public static void checkAvailability(List<SBQQ__QuoteLine__c> lNewLines){
        
        Set<Id> setIdProductToInsert = new Set<Id>();
        Set<Id> setIdProductInQuote = new Set<Id>();
        
        for(SBQQ__QuoteLine__c lines : lNewLines){
            System.debug('1: '+lines.SBQQ__Product__c);
            setIdProductToInsert.add(lines.SBQQ__Product__c);
            
        }
        
        for(SBQQ__QuoteLine__c lines : [Select id,SBQQ__Product__c From SBQQ__QuoteLine__c where SBQQ__Product__c IN :setIdProductToInsert AND SBQQ__Quote__r.RecordtypeId = :ORDERFORM_RECORDTYPEID]){
            System.debug('2: '+lines.SBQQ__Product__c);
            setIdProductInQuote.add(lines.SBQQ__Product__c);
            
            
        }
        
        System.debug('3: '+setIdProductInQuote);
        System.debug('4: '+setIdProductInQuote);
        for(SBQQ__QuoteLine__c lines : lNewLines){
            
            if(setIdProductInQuote.contains(lines.SBQQ__Product__c)){
                lines.addError(MSG_ERROR);
                
            }
            
        }
  
        
    }
    
    
    /*public static void blockEditionElimination(List<SBQQ__QuoteLine__c> lNewLines){ 
        System.debug('>>> Lines: '+lNewLines);
        set<id> setQuotes 			= new set<id>();
        set<id> setQuotesReserved 	= new set<id>();
        
        for(SBQQ__QuoteLine__c oLine : lNewLines){
                if(oLine.SBQQ__ProductFamily__c == FAMILY_VERSION || oLine.SBQQ__ProductFamily__c ==FAMILY_COLOR || oLine.SBQQ__ProductFamily__c == FAMILY_OPTIONS|| 
                   oLine.SBQQ__ProductFamily__c == FAMILY_INTERIOR ){
                       System.debug('>>>oLine.SBQQ__ProductFamily__c : '+oLine.SBQQ__ProductFamily__c);
                       setQuotes.add(oLine.SBQQ__Quote__c);
                       
                       
                }
        }
        
        for(SBQQ__Quote__c oQuote : [SELECT Id FROM SBQQ__Quote__c WHERE Id IN :setQuotes AND RecordTypeId = :CPQQUOTE_RECORDTYPEID AND ReservedVehicle__c = true]){
            System.debug('>>>Quote Reserved : '+oQuote);
            setQuotesReserved.add(oQuote.Id);
        }
        
        
        for(SBQQ__QuoteLine__c oLine : lNewLines){
            if(oLine.SBQQ__ProductFamily__c == FAMILY_VERSION || oLine.SBQQ__ProductFamily__c ==FAMILY_COLOR || oLine.SBQQ__ProductFamily__c == FAMILY_OPTIONS|| oLine.SBQQ__ProductFamily__c == FAMILY_INTERIOR ){
                   if(setQuotesReserved.contains(oLine.SBQQ__Quote__c)){
                       System.debug('>>>oLine : '+oLine);
                       oLine.addError(MSG_ERROREDITDEL);
                   }
                   
                   
            }
        }
        
        
        
        
    }*/

}
public with sharing class PopulateQuoteInformation {
    
    private final static string FAMILY_VERSION 		= Label.ProductFamilyVersion;
    private final static string FAMILY_SERVICES 	= Label.ProductFamilyServices;
    private final static string FAMILY_ACCESSORIES 	= Label.ProductFamilyAccessories;
    private final static string FAMILY_COLOR 		= Label.ProductFamilyColor;
    private final static string FAMILY_OPTIONS 		= Label.ProductFamilyOptions;
    private final static string FAMILY_INTERIOR 	= Label.ProductFamilyInterior;
    
    
    public static void mainProcess(List<SBQQ__QuoteLine__c> lNewQuoteLines){
        Set<id> setIdQuotesInitial 				= new Set<id>();
        Set<id> setIdQuotesToPopulate 			= new Set<id>();
        String sColorCode		= '';
        String sColorName		= '';
        String sInteriorCode	= '';
        String sInteriorName	= '';
        String sOptionsCode		= '';
        String sOptionsName		= '';
        String sAccessoriesCode	= '';
        String sAccessoriesName	= '';
        String sServicesCode	= '';
        String sServicesName	= '';
        Id idQuote;
        
        for(SBQQ__QuoteLine__c oQuoteLine : lNewQuoteLines){
            setIdQuotesInitial.add(oQuoteLine.SBQQ__Quote__c);   
        }
        
        for(SBQQ__QuoteLine__c oQuoteLine : [SELECT SBQQ__Quote__c,SBQQ__Product__r.Family FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN:setIdQuotesInitial AND SBQQ__Product__r.Family = :FAMILY_VERSION]){
            setIdQuotesToPopulate.add(oQuoteLine.SBQQ__Quote__c);
        }
                
        if(!setIdQuotesToPopulate.isEmpty()){
            
            for(SBQQ__QuoteLine__c oQuoteLine : [SELECT id, SBQQ__Quote__c,SBQQ__Product__c,SBQQ__Product__r.Family,SBQQ__Product__r.ProductCode,SBQQ__Product__r.Name FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :setIdQuotesToPopulate]){
                
                idQuote = oQuoteLine.SBQQ__Quote__c;
                
                if(oQuoteLine.SBQQ__Product__c!=null){                
                    if(oQuoteLine.SBQQ__Product__r.Family == FAMILY_SERVICES){
                        sServicesCode += oQuoteLine.SBQQ__Product__r.ProductCode + '\n';
                        sServicesName += oQuoteLine.SBQQ__Product__r.Name + '\n';
                        
                    }else if(oQuoteLine.SBQQ__Product__r.Family == FAMILY_ACCESSORIES){
                        sAccessoriesCode += oQuoteLine.SBQQ__Product__r.ProductCode + '\n';
                        sAccessoriesName += oQuoteLine.SBQQ__Product__r.Name + '\n';                    
                        
                    }else if(oQuoteLine.SBQQ__Product__r.Family == FAMILY_COLOR){
                        sColorCode = oQuoteLine.SBQQ__Product__r.ProductCode;
                        sColorName = oQuoteLine.SBQQ__Product__r.Name;                    
                        
                    }else if(oQuoteLine.SBQQ__Product__r.Family == FAMILY_OPTIONS){
                        sOptionsCode += oQuoteLine.SBQQ__Product__r.ProductCode + '\n';
                        sOptionsName += oQuoteLine.SBQQ__Product__r.Name + '\n';                    
                        
                    }else if(oQuoteLine.SBQQ__Product__r.Family == FAMILY_INTERIOR){
                        sInteriorCode = oQuoteLine.SBQQ__Product__r.ProductCode;
                        sInteriorName = oQuoteLine.SBQQ__Product__r.Name;       
                        
                    }
                    
                }
                
            }
            
            System.debug('sColorCode: '+sColorCode);
            System.debug('sColorName: '+sColorName);
            System.debug('sInteriorCode: '+sInteriorCode);
            System.debug('sInteriorName: '+sInteriorName);
            System.debug('sOptionsCode: '+sOptionsCode);
            System.debug('sOptionsName: '+sOptionsName);
            System.debug('sAccessoriesCode: '+sAccessoriesCode);
            System.debug('sAccessoriesName: '+sAccessoriesName);
            System.debug('sServicesCode: '+sServicesCode);
            System.debug('sServicesName: '+sServicesName);

            SBQQ__Quote__c oQuoteToUpdate = new SBQQ__Quote__c(Id = idQuote, ServiceCodes__c=sServicesCode, ServiceDescription__c=sServicesName, AccessoryCodes__c= sAccessoriesCode, AccessoryDescription__c=sAccessoriesName,
                                                               ColorCode__c=sColorCode, ColorDescription__c=sColorName, OptionCodes__c=sOptionsCode, OptionDescription__c=sOptionsName, InteriorTrimCode__c=sInteriorCode, 
                                                               InteriorTrimDescription__c=sInteriorName);
            
            Database.update(oQuoteToUpdate,true);
            System.debug('##RM## QUOTE UPDATED-> '+oQuoteToUpdate);

        }
        else{
            List<SBQQ__Quote__c> lstQuotesUpdate = new List<SBQQ__Quote__c>();
            for(Id quoteId : setIdQuotesInitial){
                SBQQ__Quote__c oQuoteToUpdate = new SBQQ__Quote__c(Id = quoteId, ServiceCodes__c=null, ServiceDescription__c=null, AccessoryCodes__c= null, AccessoryDescription__c=null,
                                                               ColorCode__c=null, ColorDescription__c=null, OptionCodes__c=null, OptionDescription__c=null, InteriorTrimCode__c=null, 
                                                               InteriorTrimDescription__c=null);
                lstQuotesUpdate.add(oQuoteToUpdate);
            }
            update lstQuotesUpdate;
        }
        
	}

}
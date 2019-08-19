public with sharing class FleetRequestValidations {


    private final static id RT_ACCOUNTB2B 					= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account_B2B').getRecordTypeId();
    private final static id RT_OPPORTUNITYFLEET 			= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Label.RTOppFleetRequest).getRecordTypeId();    
    private final static id RT_QUOTEFLEET 					= Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get(Label.RTQuoteFleetRequest).getRecordTypeId();

	private final static string OPPORTUNITY_OPEN_STAGENAME	= 'FR1';
    
    
    public static void quoteValidateEdition(List<SBQQ__Quote__c> lNewQuotes, map<id,SBQQ__Quote__c> oldMapQuotes){ //to call in before update
        
        map<String,String> stagenames = OpportunityUtils.getStages();
        
        Set<Id> setOpportunityIdQuote = new Set<Id>();
        
        for(SBQQ__Quote__c oQuote : lNewQuotes){
            
            if(oQuote.recordTypeId == RT_QUOTEFLEET &&  oQuote.SBQQ__Opportunity2__c!=null){
                setOpportunityIdQuote.add(oQuote.SBQQ__Opportunity2__c);                
            }                        
        }
        
        map<id,Opportunity> mapIdOpportunity = new map<id,Opportunity>([SELECT id,recordtypeid,SBQQ__PrimaryQuote__c,stagename 
                                                                        FROM Opportunity 
                                                                        WHERE id IN :setOpportunityIdQuote AND recordtypeid = :RT_OPPORTUNITYFLEET AND stagename != :OPPORTUNITY_OPEN_STAGENAME]);
        
        for(SBQQ__Quote__c oQuote : lNewQuotes){
            
            if(oQuote.SBQQ__Opportunity2__c != null && mapIdOpportunity.get(oQuote.SBQQ__Opportunity2__c)!=null){
                
            	oQuote.addError(Label.ErrorQuoteFleetEditon +' '+stagenames.get(mapIdOpportunity.get(oQuote.SBQQ__Opportunity2__c).Stagename));                 
                
            }
            
        }

        
    }
    
    
    public static void quoteValidateInsert(List<SBQQ__Quote__c> lNewQuotes){ //to call in before insert
        
        
        map<String,String> stagenames = OpportunityUtils.getStages();
        
        Set<Id> setOpportunityIdQuote = new Set<Id>();
        
        for(SBQQ__Quote__c oQuote : lNewQuotes){
            
            if(oQuote.recordTypeId == RT_QUOTEFLEET &&  oQuote.SBQQ__Opportunity2__c!=null){
                setOpportunityIdQuote.add(oQuote.SBQQ__Opportunity2__c);                
            }                        
        }
        
        map<id,Opportunity> mapIdOpportunity = new map<id,Opportunity>([SELECT id,recordtypeid,SBQQ__PrimaryQuote__c,stagename 
                                                                        FROM Opportunity 
                                                                        WHERE id IN :setOpportunityIdQuote AND recordtypeid = :RT_OPPORTUNITYFLEET AND stagename != :OPPORTUNITY_OPEN_STAGENAME]);
        
        for(SBQQ__Quote__c oQuote : lNewQuotes){
            
            if(oQuote.SBQQ__Opportunity2__c != null && mapIdOpportunity.get(oQuote.SBQQ__Opportunity2__c)!=null){
                
            	oQuote.addError(Label.ErrorCreateQuote +' '+stagenames.get(mapIdOpportunity.get(oQuote.SBQQ__Opportunity2__c).Stagename));                    
                
            }
            
        }

        
    }
    
    
    
    
    
    
    public static void minParkValidation(List<Opportunity> lNewOpportunities){
        
        Set<Id> setAccountId 				= new Set<Id>();
        Set<String> setSegments 			= new Set<String>();
        Map<Id,Decimal> mapIdAccountNFleets = new Map<Id,Decimal>();
        Map<String,Decimal> mapMinPark 		= new Map<String,Decimal>();
        
        for(Opportunity oOpportunity : lNewOpportunities){
            
            if(oOpportunity.recordTypeId == RT_OPPORTUNITYFLEET){
                setAccountId.add(oOpportunity.AccountId);
				setSegments.add(oOpportunity.Segment__c);                
            }                        
        }
        
        System.debug('##RM## MP __ setSegments: '+setSegments);
        System.debug('##RM## MP __ setAccountId: '+setAccountId);
        
        for(MinParkConfigurator__mdt oItem :[SELECT MinPark__c,Label FROM MinParkConfigurator__mdt WHERE Label IN :setSegments]){
            mapMinPark.put(oItem.Label, oItem.MinPark__c);
            
        }
        
        System.debug('##RM## MP __ mapMinPark: '+mapMinPark);

        for(AccountFleet__c oItem : [Select id, VolumeOfVehicles__c, Account__c FROM AccountFleet__c WHERE Account__c IN :setAccountId]){
            
            if(mapIdAccountNFleets.containsKey(oItem.Account__c)){
                
                Decimal iCount = mapIdAccountNFleets.get(oItem.Account__c) + oItem.VolumeOfVehicles__c;
                mapIdAccountNFleets.put(oItem.Account__c,iCount);
                
            }else{
                mapIdAccountNFleets.put(oItem.Account__c,oItem.VolumeOfVehicles__c);                
            }
            
        }

        System.debug('##RM## MP __ mapIdAccountNFleets: '+mapIdAccountNFleets);
        
        for(Opportunity oOpportunity : lNewOpportunities){
            
            if(mapIdAccountNFleets.get(oOpportunity.AccountId)!=null){
                
                //start the validations
                System.debug('##RM## MP __ mapMinPark.get(oOpportunity.Segment__c): '+mapMinPark.get(oOpportunity.Segment__c));
                System.debug('##RM## MP __ < MENOR O IGUAL > __');
                System.debug('##RM## MP __ mapIdAccountNFleets.get(oOpportunity.AccountId): '+mapIdAccountNFleets.get(oOpportunity.AccountId));
                if(mapMinPark.get(oOpportunity.Segment__c) != null){
                    
                    if(mapMinPark.get(oOpportunity.Segment__c) <= mapIdAccountNFleets.get(oOpportunity.AccountId)){
                        continue;    
                    }else{
                    	oOpportunity.addError(Label.ErrorMinPark);
                    }
             
                }

            }
            
        }

        
    }
    
    public static void minParkValidationEdition(List<Opportunity> lNewOpportunities,map<id,Opportunity> mapOldOpportunities){
        
        Set<Id> setAccountId 				= new Set<Id>();
        Set<String> setSegments 			= new Set<String>();
        Map<Id,Decimal> mapIdAccountNFleets = new Map<Id,Decimal>();
        Map<String,Decimal> mapMinPark 		= new Map<String,Decimal>();
        
        for(Opportunity oOpportunity : lNewOpportunities){
            
            if(oOpportunity.recordTypeId == RT_OPPORTUNITYFLEET && (mapOldOpportunities.get(oOpportunity.id).Segment__c != oOpportunity.Segment__c || mapOldOpportunities.get(oOpportunity.id).AccountId != oOpportunity.AccountId)){
                setAccountId.add(oOpportunity.AccountId);
				setSegments.add(oOpportunity.Segment__c);                
            }                        
        }
        
        System.debug('##RM## MP __ setSegments: '+setSegments);
        System.debug('##RM## MP __ setAccountId: '+setAccountId);
        
        for(MinParkConfigurator__mdt oItem :[SELECT MinPark__c,Label FROM MinParkConfigurator__mdt WHERE Label IN :setSegments]){
            mapMinPark.put(oItem.Label, oItem.MinPark__c);
            
        }
        
        System.debug('##RM## MP __ mapMinPark: '+mapMinPark);

        for(AccountFleet__c oItem : [Select id, VolumeOfVehicles__c, Account__c FROM AccountFleet__c WHERE Account__c IN :setAccountId]){
            
            if(mapIdAccountNFleets.containsKey(oItem.Account__c)){
                
                Decimal iCount = mapIdAccountNFleets.get(oItem.Account__c) + oItem.VolumeOfVehicles__c;
                mapIdAccountNFleets.put(oItem.Account__c,iCount);
                
            }else{
                mapIdAccountNFleets.put(oItem.Account__c,oItem.VolumeOfVehicles__c);                
            }
            
        }

        System.debug('##RM## MP __ mapIdAccountNFleets: '+mapIdAccountNFleets);
        
        for(Opportunity oOpportunity : lNewOpportunities){
            
            if(mapIdAccountNFleets.get(oOpportunity.AccountId)!=null){
                
                //start the validations
                System.debug('##RM## MP __ mapMinPark.get(oOpportunity.Segment__c): '+mapMinPark.get(oOpportunity.Segment__c));
                System.debug('##RM## MP __ < MENOR O IGUAL > __');
                System.debug('##RM## MP __ mapIdAccountNFleets.get(oOpportunity.AccountId): '+mapIdAccountNFleets.get(oOpportunity.AccountId));
                if(mapMinPark.get(oOpportunity.Segment__c) != null){
                    
                    if(mapMinPark.get(oOpportunity.Segment__c) <= mapIdAccountNFleets.get(oOpportunity.AccountId)){
                        continue;    
                    }else{
                    	oOpportunity.addError(Label.ErrorMinPark);
                    }
             
                }

            }
            
        }

        
    }

}
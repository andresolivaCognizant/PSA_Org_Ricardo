public with sharing class CheckStockReservation {
    
    private final static string FAMILIY_VERSION = Label.ProductFamilyVersion;
    private final static string CPQQUOTE_RECORDTYPEID 	= Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('CPQ_Quote').getRecordTypeId();
    
    
    public static void reservationProcess(List<SBQQ__Quote__c> lNewQuotes, map<id,SBQQ__Quote__c> mapOldQuotes){
        set<id> setIdQuotes	= new set<id>();
        
        for(SBQQ__Quote__c oQuote : lNewQuotes){
			System.debug('##RM CheckStockReservation## oQuote.ReservedVehicle__c: '+oQuote.ReservedVehicle__c); 
            System.debug('##RM CheckStockReservation## mapOldQuotes.get(oQuote.id).ReservedVehicle__c: '+mapOldQuotes.get(oQuote.id).ReservedVehicle__c); 
            if(oQuote.ReservedVehicle__c == true && mapOldQuotes.get(oQuote.id).ReservedVehicle__c == false)                        
                setIdQuotes.add(oQuote.id);            
        }
        
        
        
        if(!setIdQuotes.isEmpty()){
            
            set<id> setIdProduct 							= new set<id>();
            set<id> setIdQuotesNoStock 						= new set<id>();
            set<id> setIdQuotesNoReserve 					= new set<id>();
            List<Product2> listToReserve 					= new List<Product2>();
            map<Id,id> mapIdQuoteProduct			 		= new map<Id,id> ();
            map<Id,String> mapIdProductQuoteReserve		 	= new map<Id,String> ();
            map<Id,String> mapIdProductQuoteReserveOwner	= new map<Id,String> ();
            set<id> setQuoteReset							= new set<id> ();
            
            List<User> currentUser							= [SELECT contactid, contact.account.ownerid from user where id = :userinfo.getUserId()];
            
            for(SBQQ__QuoteLine__c oQline : [SELECT id, SBQQ__Quote__c, SBQQ__ProductFamily__c,Stock__c,SBQQ__Product__c,SBQQ__Product__r.Reserved__c,SBQQ__Product__r.Dealer_Code__c,toLabel(SBQQ__Product__r.Family),
                                             SBQQ__Product__r.Dealer_Code__r.OwnerId, SBQQ__Product__r.Stock__c,SBQQ__Product__r.Dealer_Code__r.Owner.TECH_GroupOfDealers__c,SBQQ__Product__r.Dealer_Code__r.Owner.TECH_GroupOfDealersStockSharing__c  
                                             FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :setIdQuotes]){
                
                                                 
                 
                System.debug('##RM CheckStockReservation## LINE FAMILY: '+oQline.SBQQ__Product__r.Family+ ' = '+FAMILIY_VERSION);                                  
                if(oQline.SBQQ__Product__r.Family == FAMILIY_VERSION){
                    System.debug('##RM CheckStockReservation## oQline: '+oQline); 
                    
                    mapIdQuoteProduct.put(oQline.SBQQ__Quote__c, oQline.SBQQ__Product__c);
                    
                    if(oQline.SBQQ__Product__r.Stock__c == false){
                        
                        setIdQuotesNoStock.add(oQline.SBQQ__Quote__c);
                        
                    }else if(oQline.SBQQ__Product__r.Reserved__c){
                        
                        setIdQuotesNoReserve.add(oQline.SBQQ__Quote__c);
                        setIdProduct.add(oQline.SBQQ__Product__c);
                        
                    }else{
                        System.debug('##RM CheckStockReservation## GROUP DEALER: '+oQline.SBQQ__Product__r.Dealer_Code__r.Owner.TECH_GroupOfDealers__c);
                        System.debug('##RM CheckStockReservation## GROUP STOCK: '+oQline.SBQQ__Product__r.Dealer_Code__r.Owner.TECH_GroupOfDealersStockSharing__c);
                        
                        if(currentUser!=null && !currentUser.isEmpty() && currentUser[0].contactid!=null && currentUser[0].contact.account != null && currentUser[0].contact.account.ownerid == oQline.SBQQ__Product__r.Dealer_Code__r.OwnerId 
                           && oQline.SBQQ__Product__r.Dealer_Code__r.Owner.TECH_GroupOfDealers__c == true && oQline.SBQQ__Product__r.Dealer_Code__r.Owner.TECH_GroupOfDealersStockSharing__c==true ){
                               
                               listToReserve.add(new Product2(id = oQline.SBQQ__Product__c, Reserved__c = true));
                            
                           }else{
                               
                               setQuoteReset.add(oQline.SBQQ__Quote__c);
                               
                           }

                    }
                    
                }
                
            }
            
            System.debug('##RM CheckStockReservation## setIdQuotesNoStock: '+setIdQuotesNoStock);
            System.debug('##RM CheckStockReservation## setIdQuotesNoReserve: '+setIdQuotesNoReserve);  
             
            
            
            if(!setIdQuotesNoReserve.isEmpty()){
                
                for(SBQQ__QuoteLine__c oQline : [SELECT id, SBQQ__Quote__c,SBQQ__Product__c,SBQQ__Quote__r.Owner.Name,SBQQ__Quote__r.Name FROM SBQQ__QuoteLine__c WHERE SBQQ__Product__c IN :setIdProduct AND SBQQ__Quote__r.ReservedVehicle__c = true]){
                    
                    mapIdProductQuoteReserve.put(oQline.SBQQ__Product__c, oQline.SBQQ__Quote__r.Name);
                    mapIdProductQuoteReserveOwner.put(oQline.SBQQ__Product__c, oQline.SBQQ__Quote__r.Owner.Name);
                }
                
            }
            
			System.debug('##RM CheckStockReservation## mapIdProductQuoteReserve: '+mapIdProductQuoteReserve);
            System.debug('##RM CheckStockReservation## mapIdProductQuoteReserveOwner: '+mapIdProductQuoteReserveOwner);
            System.debug('##RM CheckStockReservation## mapIdQuoteProduct: '+mapIdQuoteProduct);
            
            try{
                System.debug('##RM CheckStockReservation## listToReserve: '+listToReserve);  
                database.update(listToReserve);
                
            }catch(System.DmlException e){
                System.debug('DmlException ERROR CheckStockReservation.reservationProcess -->' + e.getMessage() + ' Line: '+e.getLineNumber());
            }catch(Exception e){
                System.debug('Exception ERROR CheckStockReservation.reservationProcess-->' + e.getMessage() + ' Line: '+e.getLineNumber());
            }

            
            for(SBQQ__Quote__c oQuote : lNewQuotes){
                
                if(setQuoteReset.contains(oQuote.id)) 
                	oQuote.addError(Label.ErrorQuoteOwner);
                
            	if(setIdQuotesNoStock.contains(oQuote.id)) 
                    oQuote.addError(Label.ErrorStock);

				if(setIdQuotesNoReserve.contains(oQuote.id))                    
					oQuote.addError(String.format(Label.ErrorReservation, new String[]{mapIdProductQuoteReserveOwner.get(mapIdQuoteProduct.get(oQuote.id)),mapIdProductQuoteReserve.get(mapIdQuoteProduct.get(oQuote.id))}));
                	            
        	}
            
            
        }
        
    }
    
    
    public static void cancelReservationProcess(List<SBQQ__Quote__c> lNewQuotes, map<id,SBQQ__Quote__c> mapOldQuotes){
        set<id> setIdQuotes	= new set<id>();
        
        for(SBQQ__Quote__c oQuote : lNewQuotes){

            if(oQuote.ReservedVehicle__c == false && mapOldQuotes.get(oQuote.id).ReservedVehicle__c == true)                        
                setIdQuotes.add(oQuote.id);            
        }
        
        if(!setIdQuotes.isEmpty()){
            
        	List<Product2> listToReserve 	= new List<Product2>();
            set<id> setQuoteReset 			= new set<id>();
        	List<User> currentUser			= [SELECT contactid, contact.account.ownerid from user where id = :userinfo.getUserId()];
            
            for(SBQQ__QuoteLine__c oQline : [SELECT id, SBQQ__Quote__c, SBQQ__ProductFamily__c,Stock__c,toLabel(SBQQ__Product__r.Family),SBQQ__Product__c,SBQQ__Product__r.Reserved__c,SBQQ__Product__r.Dealer_Code__c,
                                                 SBQQ__Product__r.Dealer_Code__r.OwnerId, SBQQ__Product__r.Stock__c,SBQQ__Product__r.Dealer_Code__r.Owner.TECH_GroupOfDealers__c,SBQQ__Product__r.Dealer_Code__r.Owner.TECH_GroupOfDealersStockSharing__c  
                                                 FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :setIdQuotes]){
                    
                                                     
                     
                System.debug('##RM CheckStockReservation## LINE FAMILY: '+oQline.SBQQ__Product__r.Family+ ' = '+FAMILIY_VERSION);                            
				if(oQline.SBQQ__Product__r.Family == FAMILIY_VERSION){
					
					if(currentUser!=null && !currentUser.isEmpty() && currentUser[0].contactid!=null && currentUser[0].contact.account != null && currentUser[0].contact.account.ownerid == oQline.SBQQ__Product__r.Dealer_Code__r.OwnerId 
						   && oQline.SBQQ__Product__r.Dealer_Code__r.Owner.TECH_GroupOfDealers__c == true && oQline.SBQQ__Product__r.Dealer_Code__r.Owner.TECH_GroupOfDealersStockSharing__c==true ){
							   
						listToReserve.add(new Product2(id = oQline.SBQQ__Product__c, Reserved__c = false));
							   
				    }else{
                        
                       setQuoteReset.add(oQline.SBQQ__Quote__c);
					   
				    }

				}
                                                     
        	}
            
            
            try{
                
                database.update(listToReserve);
                
            }catch(System.DmlException e){
                System.debug('DmlException ERROR CheckStockReservation.cancelreservationProcess -->' + e.getMessage() + ' Line: '+e.getLineNumber());
            }catch(Exception e){
                System.debug('Exception ERROR CheckStockReservation.cancelreservationProcess-->' + e.getMessage() + ' Line: '+e.getLineNumber());
            }

            
            for(SBQQ__Quote__c oQuote : lNewQuotes){
                
                if(setQuoteReset.contains(oQuote.id)) 
                	oQuote.addError(Label.ErrorQuoteOwner);
                            
        	}
            
            
        }
	   
	   
	}
    
    
    public static void editionProcess(List<SBQQ__Quote__c> lNewQuotes, map<id,SBQQ__Quote__c> mapOldQuotes){
        set<id> setIdQuotes	= new set<id>();
        set<id> setIdQuotesWithDocuments = new set<id>();
        
        for(SBQQ__Quote__c oQuote : lNewQuotes){

            if(oQuote.ReservedVehicle__c == true && mapOldQuotes.get(oQuote.id).ReservedVehicle__c == false && oQuote.RecordTypeId == CPQQUOTE_RECORDTYPEID)                        
                setIdQuotes.add(oQuote.id);            
        }
        
        if(!setIdQuotes.isEmpty()){
            
            for(SBQQ__QuoteDocument__c oDoc : [SELECT id,SBQQ__Quote__c from SBQQ__QuoteDocument__c where SBQQ__Quote__c IN :setIdQuotes]){
                setIdQuotesWithDocuments.add(oDoc.SBQQ__Quote__c);
            }
            
            for(SBQQ__Quote__c oQuote : lNewQuotes){

            	if(!setIdQuotesWithDocuments.contains(oQuote.id))                        
                	oQuote.addError(Label.ErrorQuoteDocument);
        	}
        
        }

    }
        
    
    

}
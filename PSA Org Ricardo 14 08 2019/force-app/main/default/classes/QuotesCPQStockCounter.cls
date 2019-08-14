global class QuotesCPQStockCounter implements SBQQ.ProductSearchPlugin{
	public String type1 {get; set;}
   
    global QuotesCPQStockCounter(){
        System.debug('METODO: customSearchFilter Constructor');
    }
    
    global Boolean isFilterHidden(SObject quote, String fieldName){
        System.debug('METODO: isFilterHidden');
 
		return false;
	}
    
    global String getFilterDefaultValue(SObject quote, String fieldName){
		System.debug('METODO: getFilterDefaultValue');
        
		return NULL;
	}
    
    global Boolean isSearchCustom(SObject so, Map<String,Object> ma){
        System.debug('METODO: isSearchCustom'); 
        System.debug('Map we have:' + ma);
        type1= 'Search';
        return true;
    }
    
    global String getAdditionalSearchFilters(SObject so, Map<String,Object> ma){
    	System.debug('METODO: getAdditionalSearchFilters'); 
        System.debug('Map Passed:');
        System.debug(ma);
        return null;
    }
    
    global List<PricebookEntry> search(SObject quote, Map<String,Object> fieldValuesMap){
		System.debug('METODO: search');
		System.debug('search quote: '+quote);
		System.debug('search fieldValuesMap: '+fieldValuesMap);
		
           
		//GET ALL POSSIBLE FILTER FIELDS FROM THE SEARCH FILTER FIELD SET
		List<Schema.FieldSetMember> searchFilterFieldSetFields = SObjectType.Product2.FieldSets.GSelling_Filters.getFields();
		
		//GET ALL POSSIBLE FIELDS FROM THE SEARCH RESULTS FIELD SET
		List<Schema.FieldSetMember> searchResultFieldSetFields = SObjectType.Product2.FieldSets.SBQQ__SearchResults.getFields();
		
		//BUILD THE SELECT STRING
		String selectClause = 'SELECT ';

		for(Schema.FieldSetMember field : searchResultFieldSetFields){
			selectClause += 'Product2.' + field.getFieldPath() + ', ';
		}
        selectClause += 'Id, UnitPrice, Pricebook2Id, Product2Id, Product2.Id';

        //BUILD THE WHERE CLAUSE
        String whereClause = '';
        String fieldNm = '';

		for(Schema.FieldSetMember field : searchFilterFieldSetFields){
			fieldNm = field.getFieldPath();
			fieldNm = fieldNm.replace('Code__c','');
			
			if(!fieldValuesMap.containsKey(fieldNm)){
				continue;
			}

			if(field.getType() == Schema.DisplayType.String || field.getType() == Schema.DisplayType.Picklist){
				whereClause += 'Product2.' + field.getFieldPath() + ' LIKE \'%' + fieldValuesMap.get(fieldNm) + '%\' AND ';
			}
		}

		whereClause += 'Pricebook2Id = \'' + quote.get('SBQQ__PricebookId__c') + '\' AND IsActive = true AND Product2.Dealer_Code__r.Owner.TECH_GroupOfDealers__c = TRUE AND Product2.Dealer_Code__r.Owner.TECH_GroupOfDealersStockSharing__c = TRUE AND Product2.IsActive = true AND Product2.SBQQ__Component__c = false AND CurrencyIsoCode =  \''+(String)quote.get('CurrencyIsoCode') + '\' AND Product2.Is_bundle__c = TRUE';
		whereClause += ' ORDER BY Product2.CDC__c, Product2.Stock__c ASC LIMIT 2000'; 

		String query;

        //BUILD THE QUERY
        query = selectClause + ' FROM PricebookEntry WHERE ' + whereClause;

		System.debug('search selectClause: '+selectClause);
		System.debug('search whereClause: '+whereClause);
		System.debug('search query: '+query);
		
        //DO THE QUERY
		List<PricebookEntry> pbes = new List<PricebookEntry>();
		pbes = Database.query(query);

		System.debug('search pbes: '+pbes);
		
		System.debug('Number of PBEs: ' + pbes.size());
           
        return pbes;
	}
    
    global Boolean isSuggestCustom(SObject so, Map<String,Object> ma){
        System.debug('METODO: isSuggestCustom');
        //System.debug('Sobject Passed: ' + so.getSObjectType().getDescribe().getName());
        System.debug(ma);
        type1='Guided Selling';
        return true;
    }
    
    global Boolean isInputHidden(SObject so, String st){
        System.debug('METODO: isInputHidden');
        System.debug('String Passed: ' + st);
        return false;
    }
    
    global String getInputDefaultValue(SObject so, String st){
        System.debug('METODO: getInputDefaultValue');
        System.debug('String Passed: ' + st);
        return null;
    }
    
    global String getAdditionalSuggestFilters(SObject so, Map<String,Object> ma){
        System.debug('METODO: getAdditionalSuggestFilters');
        System.debug('Map Passed:');
        System.debug(ma);
        return null;
    }
    
    global List<PricebookEntry> suggest(SObject so, Map<String,Object> ma){
        System.debug('METODO: suggest');
        System.debug('Object: '+so);
        System.debug('Quote: '+(Id)so.get('Id'));
        System.debug('Partner: '+(Id)so.get('SBQQ__Partner__c'));
        System.debug('Map: '+ma);
        
        //DO THE QUERY
		List<PricebookEntry> pbes = new List<PricebookEntry>();
		List<PricebookEntry> lStock = new List<PricebookEntry>();

		try {
		
			//GET ALL POSSIBLE FILTER FIELDS FROM THE SEARCH FILTER FIELD SET
			List<Schema.FieldSetMember> searchFilterFieldSetFields = SObjectType.Product2.FieldSets.GSelling_Filters.getFields();
			
			//GET ALL POSSIBLE FIELDS FROM THE SEARCH RESULTS FIELD SET
			List<Schema.FieldSetMember> searchResultFieldSetFields = SObjectType.Product2.FieldSets.SBQQ__SearchResults.getFields();
			
			//BUILD THE SELECT STRING
			String selectClause = 'SELECT ';

	        selectClause += 'Id ,UnitPrice ,Pricebook2Id ,Product2Id ,Product2.Id ,Product2.Dealer_Code__c ,Product2.Dealer_Group__c ,Product2.Stock__c ,Product2.CDC__c';
						
			for(Schema.FieldSetMember field : searchResultFieldSetFields){
				if (!selectClause.contains(field.getFieldPath())){
					selectClause += ' ,'+'Product2.' + field.getFieldPath();
				}
			}		
			
	        system.debug('Here selectClause: '+selectClause);
	
	        //BUILD THE WHERE CLAUSE
	        String whereClause = '';
	        String fieldNm = '';
	
			for(Schema.FieldSetMember field : searchFilterFieldSetFields){
				fieldNm = field.getFieldPath();
				fieldNm = fieldNm.replace('Code__c','');
	
	            if(!ma.containsKey(fieldNm)){
					continue;
				}
	
				if(field.getType() == Schema.DisplayType.String || field.getType() == Schema.DisplayType.Picklist){
					whereClause += 'Product2.' + field.getFieldPath() + ' LIKE \'%' + ma.get(fieldNm) + '%\' AND ';
				}
			}
	        
	        whereClause += 'Pricebook2Id = \'' + so.get('SBQQ__PricebookId__c') + '\' AND IsActive = true AND Product2.IsActive = true AND Product2.SBQQ__Component__c = false AND CurrencyIsoCode =  \''+(String)so.get('CurrencyIsoCode') + '\' AND Product2.Is_bundle__c = TRUE';
			whereClause += ' ORDER BY Product2.CDC__c, Product2.Stock__c ASC LIMIT 2000'; 
	
			String query;
	
	        //BUILD THE QUERY
	        query = selectClause + ' FROM PricebookEntry WHERE ' + whereClause;
	        
	        system.debug('Here Partner: '+(Id)so.get('SBQQ__Partner__c'));
	        
	        Id dealerCode = (Id)so.get('SBQQ__Partner__c');
	        
	        if (dealerCode == null){
	        	SBQQ__Quote__c[] partner = [SELECT SBQQ__Partner__c FROM SBQQ__Quote__c WHERE Id = :(Id)so.get('Id')];
	        	
	        	dealerCode = partner[0].SBQQ__Partner__c;
	        }
	        
	        system.debug('Quote dealerCode: '+dealerCode);
	        
	        Id contactId = [SELECT ContactId FROM User WHERE id =: Userinfo.getUserid()].ContactId;
	        
	        List<Contact> dealerGroup = [SELECT Account.OwnerId FROM Contact WHERE id =:contactId Limit 1];// AND ????
	        
	     	system.debug('Here dealerGroup: '+dealerGroup.size()); 
			system.debug('Here query: '+query);
			
			pbes = Database.query(query);
			
			string prodId = null;
	        Boolean setDealer = false;
	        Boolean setBourse = false;
	           
	        if (ma.get('Stock') == true){
	        	
	        	for (integer i=0;i<pbes.size();i++) {
	        		setDealer = false;
	        		setBourse = false;
	        	  
	        		if (pbes.get(i).Product2.Stock__c == true) {	        			
	        			// If Stock Dealer is flagged and owner in "Placa" is the same, Bourse is unflagged  
	        			system.debug('Product dealerCode: '+pbes.get(i).Product2.Dealer_Code__c);
	        			if(!dealerGroup.isEmpty()){ 
		        			if (pbes.get(i).Product2.StockDealer__c == 'X' && (dealerGroup[0].Account.OwnerId == pbes.get(i).Product2.Dealer_Group__c || dealerCode == pbes.get(i).Product2.Dealer_Code__c)){
		        				pbes.get(i).Product2.StockBourse__c = ' ';
		        				setDealer = true;
		        			}
	        			} else {
	        				if (pbes.get(i).Product2.StockDealer__c == 'X' && dealerCode == pbes.get(i).Product2.Dealer_Code__c){
		        				pbes.get(i).Product2.StockBourse__c = ' ';
		        				setDealer = true;
		        			}
	        			}
	        			
	        			// If Stock Dealer is flagged and owner in "Placa" is NOT the same, Dealer is unflagged  
	        			//if (pbes.get(i).Product2.StockDealer__c == 'X' && dealerGroup[0].Account.OwnerId != pbes.get(i).Product2.Dealer_Group__c && dealerCode != pbes.get(i).Product2.Dealer_Code__c){
	        			if (pbes.get(i).Product2.StockBourse__c == 'X' && setDealer == false){
	        				pbes.get(i).Product2.StockDealer__c = ' ';
	        				setBourse = true;
	        			}
	        		        			
	        		    if (pbes.get(i).Product2.StockCentral__c == 'X' || setDealer == true || setBourse == true){
	        		    	lStock.add(pbes[i]);
	        				system.debug('Here lStock: '+lStock);
	        		    }
	        		}
	        	}
	            
	        } else {      
	        	
	        	system.debug('pbes size: '+pbes.size());
	        	
	        	Integer cntStckPSA = 0;
	        	Integer cntStckBour = 0;
	        	Integer cntStckDlr = 0;
				Integer iStock = 0;
				Boolean unaddbourse = false;
	        		        	
	        	for (integer i=0;i<pbes.size();i++) {
	        		if (lStock.size() > 0 && prodId != pbes.get(i).Product2.CDC__c){
						system.debug('iStock: ' +iStock);
											
			            lStock.get(iStock).Product2.StockCentral__c = String.valueOf(cntStckPSA);
						lStock.get(iStock).Product2.StockBourse__c = String.valueOf(cntStckBour); 
						lStock.get(iStock).Product2.StockDealer__c = String.valueOf(cntStckDlr);
						
						system.debug('StockCentral__c for: ' +lStock.get(iStock).Product2.StockCentral__c);
						system.debug('StockBourse__c for: ' +lStock.get(iStock).Product2.StockBourse__c);
						system.debug('StockDealer__c for: ' +lStock.get(iStock).Product2.StockDealer__c);
						
						cntStckPSA = 0;
	        			cntStckBour = 0;
	        			cntStckDlr = 0;
	        			iStock = iStock + 1;
	        		}
	        	
	        		if (pbes.get(i).Product2.Stock__c == false) {
	        			system.debug('pbes: '+pbes[i]);
	        			lStock.add(pbes[i]); 
	        			
	        			lStock.get(iStock).Product2.StockCentral__c = String.valueOf(cntStckPSA);
						lStock.get(iStock).Product2.StockBourse__c = String.valueOf(cntStckBour);
						lStock.get(iStock).Product2.StockDealer__c = String.valueOf(cntStckDlr);
	        			
	        			prodId = pbes.get(i).Product2.CDC__c;
	        			system.debug('Here 2 prodId: '+prodId);
	        		}
	        		
	        		if (pbes.get(i).Product2.Stock__c == true && prodId == pbes.get(i).Product2.CDC__c) {
	        			if (pbes.get(i).Product2.StockCentral__c == 'X'){
		             		cntStckPSA = cntStckPSA + 1;
		            	}
	        			
	        			unaddbourse = false; 
	        			
	        			if(!dealerGroup.isEmpty()){ 
		        			if (pbes.get(i).Product2.StockDealer__c == 'X' && (dealerGroup[0].Account.OwnerId == pbes.get(i).Product2.Dealer_Group__c || dealerCode == pbes.get(i).Product2.Dealer_Code__c)){
			             		system.debug('User dealerGroup: '+dealerGroup[0].Account.OwnerId);
			             		system.debug('Product dealerGroup: '+pbes.get(i).Product2.Dealer_Group__c);
			             		system.debug('Product dealerCode: '+pbes.get(i).Product2.Dealer_Code__c);
			             		
			             		cntStckDlr = cntStckDlr + 1;
			             		system.debug('cntStckDlr 1: '+cntStckDlr);
			             		unaddbourse = true;
			            	}
			            } else {
		        			if (pbes.get(i).Product2.StockDealer__c == 'X' && dealerCode == pbes.get(i).Product2.Dealer_Code__c){
		        				system.debug('Product dealerCode: '+pbes.get(i).Product2.Dealer_Code__c);
		        				
			             		cntStckDlr = cntStckDlr + 1;
			             		system.debug('cntStckDlr 1: '+cntStckDlr);
			             		unaddbourse = true;
			            	}			            	
			            }	 
		            	
			            if (pbes.get(i).Product2.StockBourse__c == 'X' && unaddbourse == false){
			             	cntStckBour = cntStckBour + 1;
			            }  	        						
	        		}
	        	}
	        		        		        		
        		if (lStock.size() > 0){
		            lStock.get(iStock).Product2.StockCentral__c = String.valueOf(cntStckPSA);
		            lStock.get(iStock).Product2.StockBourse__c = String.valueOf(cntStckBour);
					lStock.get(iStock).Product2.StockDealer__c = String.valueOf(cntStckDlr);
					
					system.debug('StockCentral__c: ' +lStock.get(iStock).Product2.StockCentral__c);
					system.debug('StockBourse__c: ' +lStock.get(iStock).Product2.StockBourse__c);
					system.debug('StockDealer__c: ' +lStock.get(iStock).Product2.StockDealer__c);
        		}
	       
	        } 
		}  catch(dmlexception e) {
	    	string error = 'DMLexception ERROR QuotesCPQStockCounter.suggest --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
	    	system.debug('Error: '+error);
        } catch(exception e){
        	string error = 'exception ERROR QuotesCPQStockCounter.suggest --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
        	system.debug('Error: '+error);
        }
        
        system.debug('lStock: '+lStock);
        
		return lStock;
    }
    
    public class StockCounterException extends exception{
        // Custom exception class
    }
}
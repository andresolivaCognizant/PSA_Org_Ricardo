global class PSA_CPQ_Custom_Search implements SBQQ.ProductSearchPlugin{
    public String type1 {get; set;}
   
    global PSA_CPQ_Custom_Search(){
        System.debug('METODO: customSearchFilter Constructor');
    }
    
    global Boolean isFilterHidden(SObject quote, String fieldName){
        System.debug('METODO: isFilterHidden');
        /*
		// This would hide Product Code filter if Quote Status is Approved
		return fieldName == 'ProductCode' && quote.SBQQ__Status__c. == 'Approved';
		*/
		return false;
	}
    
    global String getFilterDefaultValue(SObject quote, String fieldName){
		System.debug('METODO: getFilterDefaultValue');
		/*
		// This would set Product Family filter to Service if Quote Type is Quote
		return (fieldName == 'Family' && quote.SBQQ__Type__c. == 'Quote') ? 'Service' : NULL;
		*/        
		return NULL;
	}
    
        global Boolean isSearchCustom(SObject so, Map<String,Object> ma){
        System.debug('METODO: isSearchCustom');
        //System.debug('Sobject Passed: ' + so.getSObjectType().getDescribe().getName());
        System.debug('Map we have:' + ma);
        type1= 'Search';
        return true;
    }
    
        global String getAdditionalSearchFilters(SObject so, Map<String,Object> ma){
        System.debug('METODO: getAdditionalSearchFilters');
        //System.debug('Sobject Passed: ' + so.getSObjectType().getDescribe().getName());
        System.debug('Map Passed:');
        System.debug(ma);
        return null;
    }
    
       global List<PricebookEntry> search(SObject quote, Map<String,Object> fieldValuesMap){
		System.debug('METODO: search');
           
		//GET ALL POSSIBLE FILTER FIELDS FROM THE SEARCH FILTER FIELD SET
		List<Schema.FieldSetMember> searchFilterFieldSetFields = SObjectType.Product2.FieldSets.SBQQ__SearchFilters.getFields();

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

		for(Schema.FieldSetMember field : searchFilterFieldSetFields){
			if(!fieldValuesMap.containsKey(field.getFieldPath())){
				continue;
			}

			if(field.getType() == Schema.DisplayType.String || field.getType() == Schema.DisplayType.Picklist){
				whereClause += 'Product2.' + field.getFieldPath() + ' LIKE \'%' + fieldValuesMap.get(field.getFieldPath()) + '%\' AND ';
			}
		}

//        System.debug('Quote Sobject Passed: ' + quote.getSObjectType().getDescribe().getName());
           
		whereClause += 'Pricebook2Id = \'' + quote.get('SBQQ__PricebookId__c') + '\' LIMIT 2000';

		String query;

        //BUILD THE QUERY
           query = selectClause + ' FROM PricebookEntry WHERE ' + whereClause;

        //DO THE QUERY
		List<PricebookEntry> pbes = new List<PricebookEntry>();
		pbes = Database.query(query);

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
        System.debug('We Do: ' + type1);
        System.debug('METODO: suggest');
        System.debug(ma);

		//GET ALL POSSIBLE FILTER FIELDS FROM THE SEARCH FILTER FIELD SET
		List<Schema.FieldSetMember> searchFilterFieldSetFields = SObjectType.Product2.FieldSets.SBQQ__SearchFilters.getFields();

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

		for(Schema.FieldSetMember field : searchFilterFieldSetFields){

            if(!ma.containsKey(field.getFieldPath())){
				continue;
			}

			if(field.getType() == Schema.DisplayType.String || field.getType() == Schema.DisplayType.Picklist){
				whereClause += 'Product2.' + field.getFieldPath() + ' LIKE \'%' + ma.get(field.getFieldPath()) + '%\' AND ';
			}
		}
            
		whereClause += /*'Product2.Familia_Version__c = \'' + ma.get('Familia') + '\' AND Product2.Grade__c = \'' + ma.get('Grade') + */' Product2.Stock__c = '+ ma.get('Stock') +' AND ';

            whereClause += 'Pricebook2Id = \'' + so.get('SBQQ__PricebookId__c') + '\' LIMIT 2000';

		String query;

        //BUILD THE QUERY
        query = selectClause + ' FROM PricebookEntry WHERE ' + whereClause;
           
        Id AccntId = [select contactid, contact.accountid from user where id =: Userinfo.getUserid()].contact.accountid;
            
        //Id SiteGeoId = [Select SiteGeoIdPK__c from Account where id =: Userinfo.getUserid()].SiteGeoIdPK__c;
            
        //DO THE QUERY
		List<PricebookEntry> pbes = new List<PricebookEntry>();
		pbes = Database.query(query);
            
            if (ma.get('Stock') == 'Non'){                
                    
                Integer cntStckPSA = [Select COUNT() FROM PricebookEntry WHERE IsActive = true AND Product2.IsActive = true AND Product2.SBQQ__Component__c = false AND Pricebook2Id = :pbes.get(0).Pricebook2Id AND CurrencyIsoCode ='EUR' AND Product2.Stock__c = True AND Product2.Name = :pbes.get(0).Product2.Name AND Product2.StockCentral__c = 'X'];
                
                Integer cntStckBour = [Select COUNT() FROM PricebookEntry WHERE IsActive = true AND Product2.IsActive = true AND Product2.SBQQ__Component__c = false AND Pricebook2Id = :pbes.get(0).Pricebook2Id AND CurrencyIsoCode ='EUR' AND Product2.Stock__c = True AND Product2.Name = :pbes.get(0).Product2.Name AND Product2.StockBourse__c = 'X'];
                
//                Integer cntStckDlr = [Select COUNT() FROM PricebookEntry WHERE IsActive = true AND Product2.IsActive = true AND Product2.SBQQ__Component__c = false AND Pricebook2Id = :pbes.get(0).Pricebook2Id AND CurrencyIsoCode ='EUR' AND Product2.Stock__c = True AND Product2.Name = :pbes.get(0).Product2.Name AND Product2.StockDealer__c = 'X' AND Product2.SiteGeoId__c = :SiteGeoId];

                pbes.get(0).Product2.StockCentral__c = String.valueOf(cntStckPSA);
				pbes.get(0).Product2.StockBourse__c = String.valueOf(cntStckBour);
//				pbes.get(0).Product2.StockDealer__c = String.valueOf(cntStckDlr);
            }
		return pbes;
    }
}
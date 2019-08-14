/*
-- - Name         : LeadDealerAllocation
-- - Author       : DXC. Ruben Fernandez
-- - Date         : 30/01/2018
-- - Description  : Manage Lead trigger methods
--
-- - History:
-- Date         Author  Version  Comments
-- -----------  -----   -------  ---------------------------------------
-- 30/01/2018   DXC     1.0      Initial version rfernandezlo
*/
public with sharing class LeadDealerAllocation {
/*
    ----------------------------------------------------------------------
    -- - Name 			: handleonAfterInsert
    -- - Author 		: DXC
    -- - Date 			: 30/01/2018
    -- - Input 			: List<Leads>
    -- - Output 		: void
    -- - Description 	:
    -- 
    -- Maintenance History: 
    -- Date Name Version Remarks 
    -- ----------- ------ ------- ---------------------------------------
    -- 30/01/2018	  DXC   1.0     Initial version
    --
    */ 

    private static string SOQL_WHERE_AND		= ' AND ';
    private static string SOQL_WHERE_OR			= ' OR ';
    private static string SOQL_WHERE_IN			= ' IN ';


    private static string SOQL_SELC_FIELDS		= ''; //'Id,Brand__c,Country__c,PRFlag__c,RAFlag__c,VOActivity__c,VNFlag__c,VNContractNumber__c,VNPrincipalSite__c,RAContractNumber__c,RAPrincipalSite__c,PRContractNumber__c,PRPrincipalSite__c,AgentContractNumber__c,AgentPrincipalSite__c,LicenseCode__c,SiteGeoIdPK__c';
    private static string SOQL_FROM_OBJECT		= ''; //'Account';
    private static string SOQL_FROM_OBJECTRT	= ''; //'Account';
    private static string DEALER_B2B_CRITERIA 	= 'J';
    private static string SOQL_GEO_FIELD		= ''; //'BillingAddress';
    private static String SOQL_GEO_UNITS		= ''; //'km';	// Move to Meta Data
    private static Integer SOQL_GEO_DIST		= 20;	// Move to Meta Data
    private static String SOQL_OPEN				= '(';	
    private static String SOQL_CLOSE			= ')';

    private static Map <String, String> ACTIVITY_MAPPING;
    private static Map <String, String> ACTIVITY_MAPPING_SOQL;

    private static final String ACTIVITY_GROUP_KEY1 = 'PR';	
    private static final String ACTIVITY_GROUP_KEY2 = 'RA';
    private static final String ACTIVITY_GROUP_KEY3 = 'VO';
    private static final String ACTIVITY_GROUP_KEY4 = 'VN';

    private static List<String> lstGeographicalDealers 	= new List<String>();
    private static Set<String> setFilters 				= new Set<String>();
    
    private static void loadDefaultValues(){
        String sObjectType = 'Default';
        List<LeadDealerAllocation__mdt> lValues = [SELECT Object__c,ObjectFields__c,ObjectRecordType__c,AddressField__c,AddressDistance__c,AddressDistanceUnit__c FROM LeadDealerAllocation__mdt where QualifiedApiName = :sObjectType limit 1];			
            if(!lValues.isEmpty()){
                SOQL_SELC_FIELDS	=	lValues.get(0).ObjectFields__c;
                SOQL_FROM_OBJECT	=	lValues.get(0).Object__c;
                SOQL_FROM_OBJECTRT	=	lValues.get(0).ObjectRecordType__c;
                SOQL_GEO_FIELD		=	lValues.get(0).AddressField__c;
                SOQL_GEO_UNITS		=	lValues.get(0).AddressDistanceUnit__c;
                SOQL_GEO_DIST		=	Integer.valueOf(lValues.get(0).AddressDistance__c);
            }
    }
    //@future
    public static void handleDealerAllocation(List<Id> lstIds){

        List<Lead> lstLeads 			= new List<Lead>([SELECT FirstName,LastName,Street,City,Country,PostalCode,Latitude,
            Longitude,Phone,NationalId__c,DestinationGeographicalCode__c,DestinationPOSCode__c,Company,BrandOwnedVehicle__c,
            Email,LeadCountry__c,Activity__c,CustomerType__c,LeadChannel__c,LeadRequestType__c,LeadSource,LeadType__c,CustomerContact__c,
            MarketingCode__c,BirthDate__c,TECH_DealerPdVInternal__c,FiscalId__c,VINOwnedVehicle__c,MobileProfessionalTelephone__c,
            LandlineProfessionalTelephone__c,RecordTypeId,LandlinePersonalTelephone__c,MobilePersonalTelephone__c,Customer__c,
            CalculatedPOS__c,LocalIdOfCustomer__c,CalculatedPOS__r.AgentFlag__c,CalculatedPOS__r.RAFlag__c,CalculatedPOS__r.TECH_AfterSalesManager__c,
            CalculatedPOS__r.TECH_SalesManager__c,CalculatedPOS__r.TECH_SalesManagerAgent__c,VehicleRegistrationNumber__c,
            CalculatedPOS__r.LeadFilters__c,PSABrand__c,TreatmentDueDate__c,OwnerId,CreatedDate,TECH_Web2Lead__c, TECH_Web2LeadAssignment__c FROM Lead Where Id IN: lstIds]);

        setDealerAllocation(lstLeads);
        LeadAssigmentProcess.handleAssigmentProcess(lstLeads, true, false);

    }

    public static void setDealerAllocation(List<Lead> lstLeads){

        //System.debug('##>> LeadDealerAllocation START <<');
        String sQuery 					= '';
        String sWhereQuery 				= '';
        String sWhereGeographicalCode 	= '';
        String sWherePOSCode			= '';			
        List<Account> lstSearchResult 	= new List<Account>();	// Results
        List<Lead> lstNotUpdatedLeads 	= new List<Lead>();  	// Dealer not found.
        List<Lead> lstUpdateLeads 		= new List<Lead>();		// List of Leads to be updated.
         List<Lead> lstLeadsToProcess 	= new List<Lead>();		// List of Leads to be updated.
        Map<String, Account> mapAccountsId 	= new Map<String, Account>();
        
        /*INIT MAPPING*/
        loadDefaultValues();
        setActivityMapping();
        setActivitySOQLMapping();

        System.debug('##>> setLeadDealerAllocation START STEP 1 <<');
        for(Lead l :lstLeads){
            system.debug('## LeadDealerAllocation.DestinationGeographicalCode : ' + l.DestinationGeographicalCode__c + ' DestinationPOSCod: ' + l.DestinationPOSCode__c);
            /*Execute only if value was not selected by users*/
            if(l.CalculatedPOS__c==null){
                if(!String.isEmpty(l.DestinationGeographicalCode__c) && !String.isEmpty(l.DestinationPOSCode__c)){
                    sWherePOSCode 			= whereConditionCode(l.DestinationPOSCode__c);
                    lstGeographicalDealers.add(l.DestinationGeographicalCode__c);
                    lstLeadsToProcess.add(l);
                }else if(!String.isEmpty(l.DestinationGeographicalCode__c)){ //&& l.DestinationGeographicalCode__c!=''){
                    lstGeographicalDealers.add(l.DestinationGeographicalCode__c);	
                    lstLeadsToProcess.add(l);
                }else if(!String.isEmpty(l.DestinationPOSCode__c)){
                       sWherePOSCode 			= whereConditionCode(l.DestinationPOSCode__c);
                    lstLeadsToProcess.add(l);
                }
            }
        }
        if(!lstLeadsToProcess.isEmpty()){
            sWhereQuery= ' RecordTypeId=\'' + String.escapeSingleQuotes(PAD.getObjRecordType(SOQL_FROM_OBJECT,'Dealer'))+'\'';
            Boolean bOption 			= false;
            if(!lstGeographicalDealers.isEmpty()){
                //Change Id by SiteGeoIdPK__c
                sWhereQuery				= sWhereQuery + SOQL_WHERE_AND + String.valueOf((sWherePOSCode !='')?'(':'') + 
                                        SOQL_OPEN + 'SiteGeoIdPK__c' + SOQL_WHERE_IN + ':lstGeographicalDealers' + SOQL_WHERE_AND +  whereConditionActiveDealer() +SOQL_CLOSE;
                bOption					= true;
            }
            if(sWherePOSCode !=''){
                sWhereQuery 			= sWhereQuery + String.valueOf((bOption)?SOQL_WHERE_OR:SOQL_WHERE_AND ) + sWherePOSCode + String.valueOf((bOption)?SOQL_CLOSE:'');
            }

            //sQuery = 'SELECT ' +SOQL_SELC_FIELDS + ' FROM ' +SOQL_FROM_OBJECT + ' WHERE ' + sWhereQuery;
            sQuery = buildQuery() + sWhereQuery;
            system.debug('## LeadDealerAllocation sQuery STEP 1  : ' + sQuery);

            lstSearchResult = SearchRecords(sQuery);

            if(!lstSearchResult.isEmpty()){
                for(Account acc : lstSearchResult){
                    mapAccountsId.put(acc.SiteGeoIdPK__c, acc);
                    if(acc.VNContractNumber__c!=null && acc.VNPrincipalSite__c){
                        mapAccountsId.put(String.valueOf(acc.VNContractNumber__c) + '' + acc.VNPrincipalSite__c, acc);
                    }
                    if(acc.RAContractNumber__c!=null && acc.RAPrincipalSite__c){
                        mapAccountsId.put(String.valueOf(acc.RAContractNumber__c) + '' + acc.RAPrincipalSite__c, acc);
                    }
                    if(acc.PRContractNumber__c!=null && acc.PRPrincipalSite__c){
                        mapAccountsId.put(String.valueOf(acc.PRContractNumber__c) + '' + acc.PRPrincipalSite__c, acc);
                    }
                    if(acc.AgentContractNumber__c!=null && acc.AgentPrincipalSite__c){
                        mapAccountsId.put(String.valueOf(acc.AgentContractNumber__c) + '' + String.valueOf(acc.AgentPrincipalSite__c).toLowerCase(), acc);
                    }
                }
                Boolean bFound	 				= false;			// To know when match the any criteria.
                // Processing only those leads with any of its search fields populated.
                for(Lead l :lstLeadsToProcess){
                     bFound = false;
                     if(l.DestinationGeographicalCode__c!=null){
                         System.debug('## LeadDealerAllocation STEP 1 --> First Match : ' + mapAccountsId.containsKey(l.DestinationGeographicalCode__c));
                         if(mapAccountsId.containsKey(l.DestinationGeographicalCode__c)){
                             l.CalculatedPOS__c = mapAccountsId.get(l.DestinationGeographicalCode__c).Id;
                             lstUpdateLeads.add(l);
                             bFound	= true;	
                         }
                     }
                     if(l.DestinationPOSCode__c!=null && l.DestinationPOSCode__c !='' && !bFound){
                         System.debug('## LeadDealerAllocation STEP 1 --> Second Match : ' + mapAccountsId.containsKey(l.DestinationPOSCode__c+'true'));
                         if(mapAccountsId.containsKey(l.DestinationPOSCode__c+'true')){
                             bFound	= true;
                             l.CalculatedPOS__c = mapAccountsId.get(l.DestinationPOSCode__c+'true').Id;
                             l.DestinationGeographicalCode__c = mapAccountsId.get(l.DestinationPOSCode__c+'true').SiteGeoIdPK__c;
                             lstUpdateLeads.add(l);
                         }else{
                             lstNotUpdatedLeads.add(l);
                         }
                     }else if(!bFound){  
                             lstNotUpdatedLeads.add(l);
                     }
                }
            }
        }
        System.debug('##>> setLeadDealerAllocation START STEP 2 << Cond 0 : ' + lstSearchResult.isEmpty() + ' | Cond 1:' + lstNotUpdatedLeads.isEmpty() );
        List<Lead> lstTotalNotUpdatedLeads	= new List<Lead>();
        
        // CASE 2: Dealers not found or Empty Fields//

        if(lstSearchResult.isEmpty() || !lstNotUpdatedLeads.isEmpty()){
            List<Lead> lstFinalLeads 		= new List<Lead>();
            List<Lead> lstFinalLeadsProcess	= new List<Lead>();
            lstFinalLeads 					= (lstSearchResult.isEmpty())?lstLeads:lstNotUpdatedLeads;
            Address s;
            Integer iCount					= 0;
            Integer iVal					= 0;
            sWhereQuery						= '';
            for(Lead l :lstFinalLeads){
                System.debug('##>> LeadDealerAllocation START STEP 2 << Latitude : ' + l.Latitude + ' Longitude: ' + l.Longitude);
                /*Execute only if CalculatedPOS__c was not selected by users*/
                if(l.CalculatedPOS__c==null && l.Latitude!=null && l.Longitude!=null){
                    lstFinalLeadsProcess.add(l);
                    if(setWhereCondition(l) !=''){
                        if(iCount>0){
                            sWhereQuery = sWhereQuery + SOQL_WHERE_OR + SOQL_OPEN;
                        }else{
                            sWhereQuery = '(';
                        }
                            sWhereQuery = sWhereQuery + setWhereCondition(l) ;
                            setFilters.add(setWhereCondition(l));
                    }
                    iCount +=1;
                }else{
                    // Not found so, should be cleaned?
                    // l.DestinationGeographicalCode__c = null;
                    lstTotalNotUpdatedLeads.add(l);
                }
            }
            if(sWhereQuery != ''){
                //sQuery = 'SELECT ' + SOQL_SELC_FIELDS + ' FROM ' + SOQL_FROM_OBJECT + ' WHERE ' + sWhereQuery +')';
                sQuery = buildQuery() + String.valueOf((iCount>1)?SOQL_OPEN + sWhereQuery +SOQL_CLOSE :sWhereQuery);// + String.ValueOf(sOrder!=''?' ORDER BY ' + sOrder:'');
                
                // add ORDER BY clause to query
                Pattern myPattern   = Pattern.compile('DISTANCE\\(.*?km.*?\\)'); 
                Matcher myMatcher   = myPattern.matcher(sQuery);
                if (myMatcher.find()) {
                    sQuery += ' ORDER BY ' + myMatcher.group(0) + ' DESC';
                }

                System.debug('## LeadDealerAllocation sQuery CASE 2 : ' + sQuery);
               
                lstSearchResult 	= SearchRecords(sQuery);
                mapAccountsId 	  	= new Map<String, Account>();
                if(!lstSearchResult.isEmpty()){
                    //Brand, Country + Activity
                    for(Account acc : lstSearchResult){	
                        String sAux = String.ValueOf((acc.PRFlag__c)?ACTIVITY_MAPPING.get(ACTIVITY_GROUP_KEY1):(acc.VOActivity__c)?ACTIVITY_MAPPING.get(ACTIVITY_GROUP_KEY3):(acc.VNFlag__c)?ACTIVITY_MAPPING.get(ACTIVITY_GROUP_KEY4):(acc.RAFlag__c)?ACTIVITY_MAPPING.get('APV'):'');
                        System.debug('## LeadDealerAllocation STEP 2 --> Aux: ' + sAux);						
                        mapAccountsId.put(String.valueOf(acc.Brand__c) + String.valueOf(acc.Country__c) +  sAux , acc);
                        
                        //if(acc.LicenseCode__c!=null && acc.LicenseCode__c==DEALER_B2B_CRITERIA){
                            //mapAccountsId.put(String.valueOf(acc.Brand__c) + String.valueOf(acc.Country__c) + sAux + acc.LicenseCode__c, acc);
                        //}
                    }
                    Boolean bFound	 = false;	// To know when match the any criteria.
                    for(Lead l :lstFinalLeads){
                         bFound = false;
                         /*Execute only if CalculatedPOS__c was not selected by users*/
                         if(l.CalculatedPOS__c==null && l.Activity__c!=null){
                             //if(l.Company!=null && l.Company!= '' ){
                             //	System.debug('## LeadDealerAllocation STEP 2 --> Match 1 : ' + mapAccountsId.containsKey(l.PSABrand__c+l.LeadCountry__c+ACTIVITY_MAPPING.get(l.Activity__c)+DEALER_B2B_CRITERIA));
                             //	if(mapAccountsId.containsKey(l.PSABrand__c+l.LeadCountry__c+ACTIVITY_MAPPING.get(l.Activity__c)+DEALER_B2B_CRITERIA)){
                            // 		bFound	= true;
                            // 		l.CalculatedPOS__c = mapAccountsId.get(l.PSABrand__c+l.LeadCountry__c+ACTIVITY_MAPPING.get(l.Activity__c)+DEALER_B2B_CRITERIA).Id;
                            // 		l.DestinationGeographicalCode__c =mapAccountsId.get(l.PSABrand__c+l.LeadCountry__c+ACTIVITY_MAPPING.get(l.Activity__c)+DEALER_B2B_CRITERIA).SiteGeoIdPK__c;
                            // 		lstUpdateLeads.add(l);
                            // 	}
                             //}
                             System.debug('## LeadDealerAllocation STEP 2 --> Match 2 bFound : ' + bFound);
                             System.debug('## LeadDealerAllocation STEP 2 --> Match 2 KEY : ' + l.PSABrand__c+l.LeadCountry__c+ACTIVITY_MAPPING.get(l.Activity__c));
                             System.debug('## LeadDealerAllocation STEP 2 --> Match 2 : ' +mapAccountsId.containsKey(l.PSABrand__c+l.LeadCountry__c+ACTIVITY_MAPPING.get(l.Activity__c)));
                             if(mapAccountsId.containsKey(l.PSABrand__c+l.LeadCountry__c+ACTIVITY_MAPPING.get(l.Activity__c)) && !bFound){
                                 bFound	= true;
                                 l.CalculatedPOS__c = mapAccountsId.get(l.PSABrand__c+l.LeadCountry__c+ACTIVITY_MAPPING.get(l.Activity__c)).Id;
                                 l.DestinationGeographicalCode__c = mapAccountsId.get(l.PSABrand__c+l.LeadCountry__c+ACTIVITY_MAPPING.get(l.Activity__c)).SiteGeoIdPK__c;
                                 lstUpdateLeads.add(l);
                             }
                        }
                    }
                }
            }
        }
        //System.debug('##>> LeadDealerAllocation START STEP 3 <<');
        
        //FINAL STEP: UPDATE LEADS //
        // Assigning the dealer //
        

        //if (UpdateRecords(lstUpdateLeads)){
        //	System.debug('##>> LeadDealerAllocation UpdateRecords With new Dealer OK');
        //}

        //if(UpdateRecords(lstTotalNotUpdatedLeads)){
        //	System.debug('##>> LeadDealerAllocation UpdateRecords Without Dealer OK');
        //}
        
        //List<Lead> lstAll = new List<Lead>();
        //lstAll.addAll(lstUpdateLeads);
        //lstAll.addAll(lstTotalNotUpdatedLeads);
        
        //System.debug('##>> setLeadDealerAllocation END <<');
    }

    /* SearchRecords */
    private static List<sObject> SearchRecords(String sQuery){
        System.debug('##>> LeadTriggerHandler START SearchRecords <<: ' + sQuery);
        List<sObject> lstSearchResult 	= new List<sObject>();
        if(sQuery!=''){
            try {
                lstSearchResult = database.query(sQuery);
                system.debug('## LeadTriggerHandler SearchRecords Result : ' + lstSearchResult.size() + ' isEmpty: ' + lstSearchResult.isEmpty());
            } catch(dmlexception e) {
                system.debug('## LeadTriggerHandler SearchRecords Error 1 : ' + e.getMessage());
            } catch (Exception e){
                System.debug('## LeadTriggerHandler SearchRecords Error 2: ' + e.getMessage());
            }
        }
        return lstSearchResult;
    }

    ///* UpdateRecords */
    //private static boolean UpdateRecords(List<Lead> lstUpdateLeads){
    //	System.debug('##>> LeadDealerAllocation START UpdateRecords <<: ' + lstUpdateLeads.size());
    //	if(!lstUpdateLeads.isEmpty()){

    //		try{
    //			Update lstUpdateLeads;
    //			return true;
    //		}catch(Exception e){
 //				system.debug('### LeadDealerAllocation.UpdateRecords SaveResult Error 0 : ' + e.getMessage());
 //				return false;
    //		}

    //		//List<Database.SaveResult> lstSR        = Database.update(lstUpdateLeads,false);
    //		//for( Database.SaveResult sr : lstSR){
    //		//    if(sr.isSuccess()){
    //		//    	system.debug('### UpdateRecords SaveResult : ' + sr);
    //		//    	return true;
    //		//    }
    //		//    else {
    //		//        // Get first save result error.
    //		//        Database.Error err = sr.getErrors()[0];
    //		//        // Check if the error is related to trival access level.
    //		//        if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION ){
    //		//           system.debug('### UpdateRecords SaveResult Error 1 : ' + err.getMessage());
    //		//        }
    //		//        else{
    //		//           system.debug('### UpdateRecords SaveResult Error 2 : ' + err.getMessage());
    //		//        }
    //		//        return false;
    //		//    }
    //	 //   }
    //	}
    //	return false;
    //}


    /* setWhereCondition */
    private static string setWhereCondition(Lead l){
        String sWhereQuery ='';
        System.debug('##>> LeadTriggerHandler START setWhereCondition >> Lead : ' + l +  ' >> Activity : ' + l.Activity__c);

        if(l.Activity__c!= null){
            sWhereQuery = 'Brand__c =\'' + l.PSABrand__c + '\''  + SOQL_WHERE_AND + 'Country__c =\'' + l.LeadCountry__c + '\'';
            //sWhereQuery = String.format('(Brand__c = \'\'{0}\'\' AND Country__c = \'\'{1}\'\')',new String[] {l.BrandOwnedVehicle__c, l.LeadCountry__c});
            if(ACTIVITY_MAPPING_SOQL.containsKey(ACTIVITY_MAPPING.get(l.Activity__c))){
                sWhereQuery = sWhereQuery + SOQL_WHERE_AND + ACTIVITY_MAPPING_SOQL.get(ACTIVITY_MAPPING.get(l.Activity__c)) + SOQL_WHERE_AND +  setWhereConditionOrder(l) + SOQL_CLOSE;
            }else{
                sWhereQuery = sWhereQuery + SOQL_CLOSE;
            }
        }
        return sWhereQuery;
    }
    /* setWhereConditionOrder */
    private static string setWhereConditionOrder(Lead l){
        return 'DISTANCE(' +SOQL_GEO_FIELD + ', GEOLOCATION( '+ l.Latitude + ',' + l.Longitude + '),\'' + SOQL_GEO_UNITS +'\') <' + SOQL_GEO_DIST;
    }

    private static void setActivityMapping(){
        ACTIVITY_MAPPING = new Map<String,String>();
        ACTIVITY_MAPPING.put('PR',ACTIVITY_GROUP_KEY1);
        ACTIVITY_MAPPING.put('APV',ACTIVITY_GROUP_KEY2);
        ACTIVITY_MAPPING.put('ACC',ACTIVITY_GROUP_KEY2);
        ACTIVITY_MAPPING.put('VO',ACTIVITY_GROUP_KEY3);
        ACTIVITY_MAPPING.put('VN',ACTIVITY_GROUP_KEY4);
        ACTIVITY_MAPPING.put('SE',ACTIVITY_GROUP_KEY4);
        ACTIVITY_MAPPING.put('FI',ACTIVITY_GROUP_KEY4);
    }

    
    //private static void setActivitySOQLMapping(){
    //	ACTIVITY_MAPPING_SOQL = new Map<String,String>();
    //	ACTIVITY_MAPPING_SOQL.put(ACTIVITY_GROUP_KEY1,'(PRFlag__c=true AND PRContractBeginDate__c<=TODAY AND PRContractEndDate__c>=TODAY)');
    //	ACTIVITY_MAPPING_SOQL.put(ACTIVITY_GROUP_KEY2,'(RAFlag__c=true AND RAContractBeginDate__c<=TODAY AND RAContractEndDate__c>=TODAY)');
    //	ACTIVITY_MAPPING_SOQL.put(ACTIVITY_GROUP_KEY3,'(VOActivity__c=true AND VNContractBeginDate<=TODAY AND VNContractEndDate>=TODAY)');
    //	ACTIVITY_MAPPING_SOQL.put(ACTIVITY_GROUP_KEY4,'(VNFlag__c=true AND VNContractBeginDate__c<=TODAY AND VNContractEndDate__c>=TODAY)');
    
    //}
    
    // NEW FIELD
    private static void setActivitySOQLMapping(){
        ACTIVITY_MAPPING_SOQL = new Map<String,String>();
        ACTIVITY_MAPPING_SOQL.put(ACTIVITY_GROUP_KEY1,'(PRFlag__c=true AND TECH_PRContractActive__c = true)');
        ACTIVITY_MAPPING_SOQL.put(ACTIVITY_GROUP_KEY2,'(RAFlag__c=true AND TECH_RAContractActive__c = true)');
        ACTIVITY_MAPPING_SOQL.put(ACTIVITY_GROUP_KEY3,'(VOActivity__c=true AND TECH_VNContractActive__c = true)');
        ACTIVITY_MAPPING_SOQL.put(ACTIVITY_GROUP_KEY4,'(VNFlag__c=true AND TECH_VNContractActive__c = true)');
    
    }

    private static string buildQuery(){
        return 'SELECT ' +SOQL_SELC_FIELDS + ' FROM ' +SOQL_FROM_OBJECT + ' WHERE ';
    }
    /* whereConditionCode */
    private static string whereConditionCode(String sValue){
        String sWherePOSCode = '';
        
        //sWherePOSCode='((VNContractNumber__c =' + sValue  + SOQL_WHERE_AND + 'VNPrincipalSite__c = true AND VNContractBeginDate__c<=TODAY AND VNContractEndDate__c>=TODAY)';
        //sWherePOSCode=sWherePOSCode + SOQL_WHERE_OR + '(RAContractNumber__c =' 		+ sValue  + SOQL_WHERE_AND + 'RAPrincipalSite__c = true AND RAContractBeginDate__c<=TODAY AND RAContractEndDate__c>=TODAY)';
        //sWherePOSCode=sWherePOSCode + SOQL_WHERE_OR + '(PRContractNumber__c =' 		+ sValue  + SOQL_WHERE_AND + 'PRPrincipalSite__c = true AND PRContractBeginDate__c<=TODAY AND PRContractEndDate__c>=TODAY)';	
        //sWherePOSCode=sWherePOSCode + SOQL_WHERE_OR + '(AgentContractNumber__c =' 	+ sValue  + SOQL_WHERE_AND + 'AgentPrincipalSite__c = true AND AgentContractBeginDate__c<=TODAY AND AgentContractEndDate__c>=TODAY))';

        // NEW FIELD
        sWherePOSCode='((VNContractNumber__c =\'' 	+ sValue  + '\'' + SOQL_WHERE_AND + 'VNPrincipalSite__c = true AND TECH_VNContractActive__c = true)';
        sWherePOSCode=sWherePOSCode + SOQL_WHERE_OR +  '(RAContractNumber__c =\'' 	+ sValue  + '\'' + SOQL_WHERE_AND + 'RAPrincipalSite__c = true AND TECH_RAContractActive__c = true)';			
        sWherePOSCode=sWherePOSCode + SOQL_WHERE_OR +  '(PRContractNumber__c =\'' 	+ sValue  + '\'' + SOQL_WHERE_AND + 'PRPrincipalSite__c = true AND TECH_PRContractActive__c = true)';	
        sWherePOSCode=sWherePOSCode + SOQL_WHERE_OR +  '(AgentContractNumber__c =\'' + sValue  + '\'' + SOQL_WHERE_AND + 'AgentPrincipalSite__c = true AND TECH_AgentContractActive__c = true))';
        return sWherePOSCode;
    }
    /* whereCondition */

    
    private static string whereConditionActiveDealer(){
            String sWhereGeographicalCode = 'TECH_ContractActive__c=true';
            
            //String sWhereGeographicalCode = '((VNContractBeginDate__c<=TODAY AND VNContractEndDate__c>=TODAY) OR '+ 
      //      '(RAContractBeginDate__c<= TODAY AND RAContractEndDate__c>= TODAY) OR '+
      //      '(PRContractBeginDate__c<= TODAY AND PRContractEndDate__c>=TODAY) OR '+
      //      '(AgentContractBeginDate__c<= TODAY AND AgentContractEndDate__c>=TODAY))';
            return sWhereGeographicalCode;
    }
}
/**
	*   @Class : AllocationMatchingProcess.cls
	*
	*   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
	*   @Created        :   24 Jan 2018
	*   @Description    :   Class thats find coincidences between Lead and Account.
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description
	*	   Rubén Moreno				24/1/2018				 Creation.
	*	   Rubén Moreno				4/4/2018				 Correction in B2C VIN rule.
	*	   C1STRUN-2321             05/06/2019               Added a Manual Sharing to match clients		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/


public without sharing class AllocationMatchingProcess {

  	private static string SOQL_WHERE_AND	=' AND ';
  	private static string SOQL_WHERE_OR		=' OR ';
    private static string B2B_RULES			='B2B Matching';
    private static string B2C_RULES			='B2C Matching';
    private static string B2BCONTACT_RULES	='B2BContact Matching';
    private static string ASSETFIELD_VIN	= Label.VinAPIName.toUpperCase();
    private static string REG_NUMBER		= Label.RegNumAPIName.toUpperCase();
        
	public static void matchLeadsAccounts(List<Lead> lAllLeads, String sNameProcess){
		
        String sSelectAsset = '';
        String sSelectAccount = '';
		boolean bRegNumber = false;
        boolean bVIN = false;
        map<Id,string> mapLeadsRulesAccountString = new  map<Id,string>();
        map<Id,string> mapLeadsRulesAssetString = new  map<Id,string>();
        String sFilterAccountString = '';
        String sFilterAssetString = '';
       
        String sValuesLeadAux = '';
        map<String,Id> mapValuesLeadAux = new map<String,Id>();
		map<string,integer> mapFieldNCaractersAccount = new map<string,integer>();
        
        //extract all the rules.
        List<MatchingProcess__mdt> lRules = [SELECT fieldtype__c,MatchType__c,SourceField__c,TargetField__c,label,TargetObject__c,order__c, NumberCaracters__c
                                                 FROM MatchingProcess__mdt
                                                 WHERE GroupRule__c = :sNameProcess   
                                                 order by Label   asc];

         
        //creation of the where clause depending to the values of all leads.
        if(lRules!=null && !lRules.isEmpty()){
            
            
            for(Lead l : lAllLeads){
				bRegNumber = false;
                bVIN = false;
                sFilterAccountString = '';
                sFilterAssetString = '';
                Decimal d = -1;
                //run all the rules.
                for(Integer i = 0 ; i < lRules.size() ; i++){ 
                    
                    if(!sSelectAccount.contains(lRules[i].TargetField__c) && lRules[i].TargetObject__c == 'Account'){
                       sSelectAccount += lRules[i].TargetField__c+' ,';
                    }
                        
                    if(!sSelectAsset.contains(lRules[i].TargetField__c) && lRules[i].TargetObject__c == 'Asset'){
                        sSelectAsset += lRules[i].TargetField__c+' ,';
                    }
                    
                    mapFieldNCaractersAccount.put(lRules[i].SourceField__c,(integer)lRules[i].NumberCaracters__c);
                    
                    
                    if(lRules[i].TargetObject__c == 'Asset' && l.get(lRules[i].SourceField__c)!=null){
                        
                        if(String.valueof(lRules[i].TargetField__c).toUpperCase().contains(ASSETFIELD_VIN)){
                            sFilterAssetString += '('+lRules[i].TargetField__c+ '= \'' +l.get(lRules[i].SourceField__c)+'\'';
                            bVIN = true;
                        }
                        
                        if(String.valueof(lRules[i].TargetField__c).toUpperCase().contains(REG_NUMBER)){
                            sFilterAssetString += (sFilterAssetString!='')? ') OR ('+lRules[i].TargetField__c+ '= \'' +l.get(lRules[i].SourceField__c)+'\')':'('+lRules[i].TargetField__c+ '= \'' +l.get(lRules[i].SourceField__c)+'\')';
                            bRegNumber = true;
                            
                        }
                            
                      
                    } 
	
                    
                    
                    
                    if(d!= lRules[i].order__C && l.get(lRules[i].SourceField__c)!=null){
                 
                        //first condition.
                        if(i==0){
							if(lRules[i].fieldType__c == 'PHO'){
                                
                                sValuesLeadAux += (l.get(lRules[i].SourceField__c)!=null && lRules[i].NumberCaracters__c!=null && String.valueof(l.get(lRules[i].SourceField__c)).length() > lRules[i].NumberCaracters__c)?String.valueof(l.get(lRules[i].SourceField__c)).substring(0,Integer.valueof(lRules[i].NumberCaracters__c)).replace('+',''):String.escapeSingleQuotes(String.valueOf(l.get(lRules[i].SourceField__c))).replace('+','');
                                
                                if(lRules[i].TargetObject__c == 'Account'){
                                                                        
                                    sFilterAccountString+=  (l.get(lRules[i].SourceField__c)!=null && lRules[i].NumberCaracters__c!=null && String.valueof(l.get(lRules[i].SourceField__c)).length() > lRules[i].NumberCaracters__c)?' \"'+String.valueof(l.get(lRules[i].SourceField__c)).substring(0,Integer.valueof(lRules[i].NumberCaracters__c)).replace('+','')+'*\"':'\"\"*'+String.escapeSingleQuotes(String.valueOf(l.get(lRules[i].SourceField__c))).replace('+','')+'*\"';
                                }
                                
                            }else if(lRules[i].fieldType__c == 'DAT'){
                                sValuesLeadAux+=String.valueof(l.get(lRules[i].SourceField__c)).replace(' 00:00:00','');
                                
                                if(lRules[i].TargetObject__c == 'Account'){
                                    
                                    sFilterAccountString+='  \"'+String.valueof(l.get(lRules[i].SourceField__c)).replace(' 00:00:00','')+'  \"';
                                    
                                }
                                
                                
                            }else{
                            	sValuesLeadAux += (l.get(lRules[i].SourceField__c)!=null && lRules[i].NumberCaracters__c!=null && String.valueof(l.get(lRules[i].SourceField__c)).length() > lRules[i].NumberCaracters__c)?String.escapeSingleQuotes(String.valueof(l.get(lRules[i].SourceField__c)).substring(0,Integer.valueof(lRules[i].NumberCaracters__c))):String.escapeSingleQuotes(String.valueOf(l.get(lRules[i].SourceField__c)));

                                if(lRules[i].TargetObject__c == 'Account'){
                                    sFilterAccountString+=  (l.get(lRules[i].SourceField__c)!=null && lRules[i].NumberCaracters__c!=null && String.valueof(l.get(lRules[i].SourceField__c)).length() > lRules[i].NumberCaracters__c)?'  \"'+String.escapeSingleQuotes(GeneralUtils.removeAccents(String.valueOf(l.get(lRules[i].SourceField__c))).substring(0,Integer.valueof(lRules[i].NumberCaracters__c)))+'*\"':'\"'+String.escapeSingleQuotes(GeneralUtils.removeAccents(String.valueOf(l.get(lRules[i].SourceField__c))))+'\"';
                                }

                            }

                            
                            
                         //conditions join to AND. All members have the same order.
                        }else if(lRules[i].order__C==lRules[i-1].order__C){
                            
                            
                            if(lRules[i].fieldType__c == 'PHO'){
                                sValuesLeadAux += (l.get(lRules[i].SourceField__c)!=null && lRules[i].NumberCaracters__c!=null && String.valueof(l.get(lRules[i].SourceField__c)).length() > lRules[i].NumberCaracters__c)?String.valueof(l.get(lRules[i].SourceField__c)).substring(0,Integer.valueof(lRules[i].NumberCaracters__c)).replace('+',''):String.escapeSingleQuotes(String.valueOf(l.get(lRules[i].SourceField__c))).replace('+','');

                                if(lRules[i].TargetObject__c == 'Account'){
                                    
                                    
                                    sFilterAccountString += (l.get(lRules[i].SourceField__c)!=null && l.get(lRules[i].SourceField__c)!=null && lRules[i].NumberCaracters__c!=null && String.valueof(l.get(lRules[i].SourceField__c)).length() > lRules[i].NumberCaracters__c)?SOQL_WHERE_AND+'  \"'+String.valueof(l.get(lRules[i].SourceField__c)).substring(0,Integer.valueof(lRules[i].NumberCaracters__c)).replace('+','')+'*\"':SOQL_WHERE_AND+'\"*'+String.escapeSingleQuotes(String.valueOf(l.get(lRules[i].SourceField__c))).replace('+','')+'*\"';
                                    
                                }
                                
                                
                                
                            }else if(lRules[i].fieldType__c == 'DAT'){
                                sValuesLeadAux+=String.valueof(l.get(lRules[i].SourceField__c)).replace(' 00:00:00','');
                                
                                if(lRules[i].TargetObject__c == 'Account'){
                                    
                                    sFilterAccountString+=SOQL_WHERE_AND+'  \"'+String.valueof(l.get(lRules[i].SourceField__c)).replace(' 00:00:00','')+'  \"';
                                    
                                }
                                
                                
                            }else{
                            	sValuesLeadAux += (l.get(lRules[i].SourceField__c)!=null && lRules[i].NumberCaracters__c!=null && String.valueof(l.get(lRules[i].SourceField__c)).length() > lRules[i].NumberCaracters__c)?String.escapeSingleQuotes(String.valueof(l.get(lRules[i].SourceField__c)).substring(0,Integer.valueof(lRules[i].NumberCaracters__c))):String.escapeSingleQuotes(String.valueOf(l.get(lRules[i].SourceField__c)));
                                
                                if(lRules[i].TargetObject__c == 'Account'){
                                    
                                    sFilterAccountString+=  (l.get(lRules[i].SourceField__c)!=null && lRules[i].NumberCaracters__c!=null && String.valueof(l.get(lRules[i].SourceField__c)).length() > lRules[i].NumberCaracters__c)?SOQL_WHERE_AND+'  \"'+String.escapeSingleQuotes(GeneralUtils.removeAccents(String.valueOf(l.get(lRules[i].SourceField__c))).substring(0,Integer.valueof(lRules[i].NumberCaracters__c)))+'*\"':SOQL_WHERE_AND+'\"'+String.escapeSingleQuotes(GeneralUtils.removeAccents(String.valueOf(l.get(lRules[i].SourceField__c))))+'\"';
                                    
                                }
                                
                            }
                            
     
                            
                          //the following condition are different order to the previous.
                        }else if(lRules[i].order__C!=lRules[i-1].order__C){
                            mapValuesLeadAux.put(GeneralUtils.removeAccents(sValuesLeadAux.toUpperCase()),l.id); //add rule with values of lead
                            sValuesLeadAux = '';//empty the string
                            
                            if(lRules[i].fieldType__c == 'PHO'){
                                sValuesLeadAux += (l.get(lRules[i].SourceField__c)!=null && l.get(lRules[i].SourceField__c)!=null && lRules[i].NumberCaracters__c!=null && String.valueof(l.get(lRules[i].SourceField__c)).length() > lRules[i].NumberCaracters__c)?String.valueof(l.get(lRules[i].SourceField__c)).substring(0,Integer.valueof(lRules[i].NumberCaracters__c)).replace('+',''):String.escapeSingleQuotes(String.valueOf(l.get(lRules[i].SourceField__c))).replace('+','');

                                if(lRules[i].TargetObject__c == 'Account'){
                                    
                                    
                                    sFilterAccountString+=  (l.get(lRules[i].SourceField__c)!=null && lRules[i].NumberCaracters__c!=null && String.valueof(l.get(lRules[i].SourceField__c)).length() > lRules[i].NumberCaracters__c)?SOQL_WHERE_OR+'  *\"'+String.valueof(l.get(lRules[i].SourceField__c)).substring(0,Integer.valueof(lRules[i].NumberCaracters__c)).replace('+','')+'*\"':SOQL_WHERE_OR+'\"*'+String.escapeSingleQuotes(String.valueOf(l.get(lRules[i].SourceField__c))).replace('+','')+'*\"';
                                    
                                }
                                
                                
                            }else if(lRules[i].fieldType__c == 'DAT'){
                                sValuesLeadAux+=String.valueof(l.get(lRules[i].SourceField__c)).replace(' 00:00:00','');
                                
                                if(lRules[i].TargetObject__c == 'Account'){
                                    
                                    sFilterAccountString+=SOQL_WHERE_OR+'  \"'+String.valueof(l.get(lRules[i].SourceField__c)).replace(' 00:00:00','')+'  \"';
                                    
                                }
                                
                                
                            }else{
                            	sValuesLeadAux += (l.get(lRules[i].SourceField__c)!=null && lRules[i].NumberCaracters__c!=null && String.valueof(l.get(lRules[i].SourceField__c)).length() > lRules[i].NumberCaracters__c)?String.escapeSingleQuotes(String.valueof(l.get(lRules[i].SourceField__c)).substring(0,Integer.valueof(lRules[i].NumberCaracters__c))):String.escapeSingleQuotes(String.valueOf(l.get(lRules[i].SourceField__c)));

                                if(lRules[i].TargetObject__c == 'Account'){
                                    sFilterAccountString+=  (l.get(lRules[i].SourceField__c)!=null && lRules[i].NumberCaracters__c!=null && String.valueof(l.get(lRules[i].SourceField__c)).length() > lRules[i].NumberCaracters__c)?SOQL_WHERE_OR+'  \"'+String.escapeSingleQuotes(GeneralUtils.removeAccents(String.valueOf(l.get(lRules[i].SourceField__c))).substring(0,Integer.valueof(lRules[i].NumberCaracters__c)))+'*\"':SOQL_WHERE_OR+'\"'+String.escapeSingleQuotes(GeneralUtils.removeAccents(String.valueOf(l.get(lRules[i].SourceField__c))))+'\"';
                                    
                                }

                            }
                            
                            
                            
                        }
                        

                        
                    //the variable 'd' store the order number that contains one element null.
                    }else{
                        
                        d = lRules[i].order__C;
                    }
                    
                    
                    
                    
                    
                    if(sFilterAccountString.startsWith(' OR ')){
                        sFilterAccountString = sFilterAccountString.removeStart(' OR ');
                    }
                    


                    
                }
                
                sFilterAccountString = sFilterAccountString.replace('-','\\-');
                
                if(bRegNumber && bVIN){
                    sFilterAssetString = '(' + sFilterAssetString + ')';
                }
                
                if(!bRegNumber && bVIN){
                    sFilterAssetString = sFilterAssetString + ')';
                }
                
                mapValuesLeadAux.put(GeneralUtils.removeAccents(sValuesLeadAux.toUpperCase()),l.id); //add rule with values of lead
                sValuesLeadAux = '';
                
                if(sFilterAccountString!= ''){
                    mapLeadsRulesAccountString.put(l.id,'( '+sFilterAccountString+' )');
                    
                } 
                
                
                System.debug('_______>>sFilterAssetString     '+sFilterAssetString);
                if(sFilterAssetString!= ''){
                    mapLeadsRulesAssetString.put(l.id,sFilterAssetString);
                    
                    
                }

                
            }
            
            
        }
		

		//creation of the final SOSL query with the values of the leads. 
        String sWhereAccount = string.join(mapLeadsRulesAccountString.values(), '  OR ' );  
        String sWhereAsset = string.join(mapLeadsRulesAssetString.values(), '  OR ' );
        String sQueryAccount1 = (sWhereAccount!='')?'FIND  {'+sWhereAccount+'}  IN ALL FIELDS Returning Account('+sSelectAccount+' isPersonAccount'+')':'block';       
        String sQueryAsset1 = (sWhereAsset!='')?'FIND  {"ACAR*"}  Returning AccountContactAssetRelation__c ('+sSelectAsset.removeEnd(',')+' WHERE '+sWhereAsset+')':'block';  //"ACAR*" because the name is autonumber "ACAR-"

        System.debug('##RM## SOSL ACCOUNT 1: '+sQueryAccount1);
        System.debug('##RM## SOSL ASSET 1: '+sQueryAsset1);
        System.debug('##RM## mapValuesLeadAux 1: '+mapValuesLeadAux);
        
      
        map<Id,Id> mapIdLeadContact = new map<Id,Id>();
        map<Id,Id> mapIdLeadAccount = new map<Id,Id>();
        List<List<Account>> lAccountSearch = new List<List<Account>>();
        List<List<AccountContactAssetRelation__c>> lAccountAssetSearch = new List<List<AccountContactAssetRelation__c>>();
        //run the query and extract related accounts.
        try{
            lAccountSearch = (sQueryAccount1!='block')?search.query(sQueryAccount1):null;
            lAccountAssetSearch= (sQueryAsset1!='block')?search.query(sQueryAsset1):null;
            
        } catch(DMLexception e) {
		    System.debug('AllocationMatchingProcess.matchLeadsAccounts ERROR -->' + e.getMessage() + ' Line: '+e.getLineNumber());
		} catch (Exception e){
		    System.debug('AllocationMatchingProcess.matchLeadsAccounts ERROR --> ' + e.getMessage() + ' Line: '+e.getLineNumber());
		}
            

        
        
        //B2C matching process rules
        if(sNameProcess == B2C_RULES){
                    
            if(lAccountSearch!=null && !lAccountSearch.isEmpty()){
                
                for(List<Account> la : lAccountSearch){
                    for(Account a : la){
                        
                    	if(a.IsPersonAccount){
                            String sFirstname = (a.firstname!=null && a.firstname.length()>mapFieldNCaractersAccount.get('FirstName'))?a.firstname.substring(0,mapFieldNCaractersAccount.get('FirstName')):a.firstname;
                            String sLandlinePersonalTelephone = (a.LandlinePersonalTelephone__pc!=null)?a.LandlinePersonalTelephone__pc.replace('+',''):null;
                            String LandlineProfessionalTelephone = (a.LandlineProfessionalTelephone__pc!=null)?a.LandlineProfessionalTelephone__pc.replace('+',''):null;
                            String MobilePersonalTelephone = (a.MobilePersonalTelephone__pc!=null)?a.MobilePersonalTelephone__pc.replace('+',''):null;
                            String MobileProfessionalTelephone = (a.MobileProfessionalTelephone__pc!=null)?a.MobileProfessionalTelephone__pc.replace('+',''):null;
                            String sBirthdate = (a.PersonBirthdate!=null)?String.valueof(a.PersonBirthdate).replace(' 00:00:00',''):null;
                            
                            System.debug('*** mapValuesLeadAux->'+mapValuesLeadAux);
                            System.debug('*** sBirthdate->'+sBirthdate+sFirstname+a.lastname);
                            if(a.LocalIdOfCustomer__c!=null && mapValuesLeadAux.containsKey(GeneralUtils.removeAccents((a.LocalIdOfCustomer__c).toUpperCase()))){ 
                                System.debug('LocalIdOfCustomer__c'+A.Id);
                                mapIdLeadAccount.put(mapValuesLeadAux.get(GeneralUtils.removeAccents((a.LocalIdOfCustomer__c).toUpperCase())),a.id);
                                
                            }else if(a.NationalId__pc!=null && mapValuesLeadAux.containsKey(GeneralUtils.removeAccents((a.NationalId__pc).toUpperCase()))){ 
                                System.debug('NationalId__pc'+A.Id);
                                mapIdLeadAccount.put(mapValuesLeadAux.get(GeneralUtils.removeAccents((a.NationalId__pc).toUpperCase())),a.id);
                                
                            }else if(mapValuesLeadAux.containsKey(GeneralUtils.removeAccents((sLandlinePersonalTelephone+sFirstname+a.lastname).toUpperCase()))){
                                System.debug('sLandlinePersonalTelephone'+A.Id);
                                mapIdLeadAccount.put(mapValuesLeadAux.get(GeneralUtils.removeAccents((sLandlinePersonalTelephone+sFirstname+a.lastname).toUpperCase())),a.id);
                                
                            }else if(mapValuesLeadAux.containsKey(GeneralUtils.removeAccents((LandlineProfessionalTelephone+sFirstname+a.lastname).toUpperCase()))){
                                mapIdLeadAccount.put(mapValuesLeadAux.get(GeneralUtils.removeAccents((LandlineProfessionalTelephone+sFirstname+a.lastname).toUpperCase())),a.id);
                                
                            }else if(mapValuesLeadAux.containsKey(GeneralUtils.removeAccents((MobilePersonalTelephone+sFirstname+a.lastname).toUpperCase()))){
                                System.debug('MobilePersonalTelephone'+A.Id);
                                mapIdLeadAccount.put(mapValuesLeadAux.get(GeneralUtils.removeAccents((MobilePersonalTelephone+sFirstname+a.lastname).toUpperCase())),a.id);
                                
                            }else if(mapValuesLeadAux.containsKey(GeneralUtils.removeAccents((MobileProfessionalTelephone+sFirstname+a.lastname).toUpperCase()))){
                                mapIdLeadAccount.put(mapValuesLeadAux.get(GeneralUtils.removeAccents((MobileProfessionalTelephone+sFirstname+a.lastname).toUpperCase())),a.id);
                                
                            }else if(mapValuesLeadAux.containsKey(GeneralUtils.removeAccents((a.PersonEmail+sFirstname+a.lastname).toUpperCase()))){
                                System.debug('PersonEmail'+A.Id);
                                mapIdLeadAccount.put(mapValuesLeadAux.get(GeneralUtils.removeAccents((a.PersonEmail+sFirstname+a.lastname).toUpperCase())),a.id);
                                
                            }else if(mapValuesLeadAux.containsKey(GeneralUtils.removeAccents((a.BillingStreet+a.BillingPostalCode+sFirstname+a.lastname).toUpperCase()))){
                                System.debug('BillingStreet'+A.Id);
                                mapIdLeadAccount.put(mapValuesLeadAux.get(GeneralUtils.removeAccents((a.BillingStreet+a.BillingPostalCode+sFirstname+a.lastname).toUpperCase())),a.id);
                                
                            }else if(mapValuesLeadAux.containsKey(GeneralUtils.removeAccents((sBirthdate+sFirstname+a.lastname).toUpperCase()))){
                                System.debug('PersonBirthdate'+A.Id);
                                mapIdLeadAccount.put(mapValuesLeadAux.get(GeneralUtils.removeAccents((sBirthdate+sFirstname+a.lastname).toUpperCase())),a.id);
                                
                            }
                        }
                    }
                }
            }
            
            if(lAccountAssetSearch!=null && !lAccountAssetSearch.isEmpty()){
                
                for(List<AccountContactAssetRelation__c> lAssetItem : lAccountAssetSearch){
                    for(AccountContactAssetRelation__c assetItem : lAssetItem){
                        String sFirstname = (assetItem.AccountId__r.firstname!=null && assetItem.AccountId__r.firstname.length()>mapFieldNCaractersAccount.get('FirstName'))?assetItem.AccountId__r.firstname.substring(0,4):assetItem.AccountId__r.firstname;
                        if(mapValuesLeadAux.containsKey(GeneralUtils.removeAccents((assetItem.AccountId__r.Lastname+sFirstname+assetItem.AssetId__r.VIN__c).toUpperCase()))){
                            System.debug('VIN__c 1'+assetItem.AccountId__r);
                            mapIdLeadAccount.put(mapValuesLeadAux.get(GeneralUtils.removeAccents((assetItem.AccountId__r.Lastname+sFirstname+assetItem.AssetId__r.VIN__c).toUpperCase())),assetItem.AccountId__c);
                            
                        }else if(mapValuesLeadAux.containsKey(GeneralUtils.removeAccents((assetItem.AccountId__r.Lastname+sFirstname+assetItem.RegistrationNumber__c).toUpperCase()))){
                            System.debug('RN 1'+assetItem.AccountId__r);
                            mapIdLeadAccount.put(mapValuesLeadAux.get(GeneralUtils.removeAccents((assetItem.AccountId__r.Lastname+sFirstname+assetItem.RegistrationNumber__c).toUpperCase())),assetItem.AccountId__c);
           
                        }
                
                    }
                    
                }
                
            }
        
        //B2B matching process rules
        }else if(sNameProcess == B2B_RULES){
                    
            if(lAccountSearch!=null && !lAccountSearch.isEmpty()){
                
                for(List<Account> la : lAccountSearch){
                    for(Account a : la){

                        if(a.LocalIdOfCustomer__c!=null && mapValuesLeadAux.containsKey(GeneralUtils.removeAccents((a.LocalIdOfCustomer__c).toUpperCase()))){ 
                            System.debug('LocalIdOfCustomer__c'+A.Id);
                            mapIdLeadAccount.put(mapValuesLeadAux.get(GeneralUtils.removeAccents((a.LocalIdOfCustomer__c).toUpperCase())),a.id);
                            
                        }else if(a.FiscalId__c!=null && mapValuesLeadAux.containsKey(GeneralUtils.removeAccents((a.FiscalId__c).toUpperCase()))){ 
                            System.debug('FiscalId__c'+A.Id);
                            mapIdLeadAccount.put(mapValuesLeadAux.get(GeneralUtils.removeAccents((a.FiscalId__c).toUpperCase())),a.id);
                            
                        }else if(mapValuesLeadAux.containsKey(GeneralUtils.removeAccents((a.BillingPostalCode+a.Name).toUpperCase()))){
                            System.debug('BillingPostalCode'+a.Id);
                            mapIdLeadAccount.put(mapValuesLeadAux.get(GeneralUtils.removeAccents((a.BillingPostalCode+a.Name).toUpperCase())),a.id);
                            
                        }    
                        
                    }
                                        
                }
            }
            
            if(lAccountAssetSearch!=null && !lAccountAssetSearch.isEmpty()){
                
                for(List<AccountContactAssetRelation__c> lAssetItem : lAccountAssetSearch){
                    for(AccountContactAssetRelation__c AssetItem : lAssetItem){
                    
                        if(mapValuesLeadAux.containsKey(GeneralUtils.removeAccents((assetItem.AssetId__r.VIN__c+assetItem.AccountId__r.Name).toUpperCase()))){
                            System.debug('VIN__c 2'+assetItem.AccountId__r);
                            mapIdLeadAccount.put(mapValuesLeadAux.get(GeneralUtils.removeAccents((assetItem.AssetId__r.VIN__c+assetItem.AccountId__r.Name).toUpperCase())),assetItem.AccountId__c);
                            
                        }else if(mapValuesLeadAux.containsKey(GeneralUtils.removeAccents((assetItem.RegistrationNumber__c+assetItem.AccountId__r.Name).toUpperCase()))){
                            System.debug('RNUMBER 2'+assetItem.AccountId__r);
                            mapIdLeadAccount.put(mapValuesLeadAux.get(GeneralUtils.removeAccents((assetItem.RegistrationNumber__c+assetItem.AccountId__r.Name).toUpperCase())),assetItem.AccountId__c);
                            
                        }
                    }
                }
                
            }
            
            
            
            //Process to search B2B Contacts

			String sSelectContact = '';
			String sFilterContactString = '';
			map<Id,string> mapLeadsRulesContactString = new  map<Id,string>();
			map<string,integer> mapFieldNCaracters = new map<string,integer>();	
            map<id,id> mapLeadContact = new map<id,id>();
			
			sValuesLeadAux = '';
			mapValuesLeadAux.clear();
			
			List<MatchingProcess__mdt> lRulesContact = [ SELECT fieldtype__c,MatchType__c,SourceField__c,TargetField__c,label,TargetObject__c,order__c, NumberCaracters__c
                                                         FROM MatchingProcess__mdt
                                                         WHERE GroupRule__c = :B2BCONTACT_RULES
                                                         order by Label   asc];

            
			
            if(lRulesContact!=null && !lRulesContact.isEmpty()){
            
				for(Lead l : lAllLeads){
					//##RM## 19/FEB if(mapIdLeadAccount.containsKey(l.id)){
						sFilterContactString = '';
						//##RM## 19/FEB sFilterAssetString = '';
						Decimal d = -1;
						for(Integer i = 0 ; i < lRulesContact.size() ; i++){ 
							if(!sSelectContact.contains(lRulesContact[i].TargetField__c) && lRulesContact[i].TargetObject__c == 'Contact'){
							   sSelectContact += lRulesContact[i].TargetField__c+' ,';
							}
							
                            mapFieldNCaracters.put(lRulesContact[i].SourceField__c,(integer) lRulesContact[i].NumberCaracters__c);
							/*if(!sSelectAsset.contains(lRulesContact[i].TargetField__c) && lRulesContact[i].TargetObject__c == 'Asset'){
								sSelectAsset += lRulesContact[i].TargetField__c+' ,';
							}*/
							
							if(d!= lRulesContact[i].order__C && l.get(lRulesContact[i].SourceField__c)!=null){
                 
                                //first condition.
                                if(i==0){
                                    if(lRulesContact[i].fieldType__c == 'PHO'){
                                        
                                        sValuesLeadAux += (l.get(lRulesContact[i].SourceField__c)!=null && lRulesContact[i].NumberCaracters__c!=null && String.valueof(l.get(lRulesContact[i].SourceField__c)).length() > lRulesContact[i].NumberCaracters__c)?String.valueof(l.get(lRulesContact[i].SourceField__c)).substring(0,Integer.valueof(lRulesContact[i].NumberCaracters__c)).replace('+',''):String.escapeSingleQuotes(String.valueOf(l.get(lRulesContact[i].SourceField__c))).replace('+','');
                                        
                                        if(lRulesContact[i].TargetObject__c == 'Contact'){
                                                                                
                                            sFilterContactString+=  (l.get(lRulesContact[i].SourceField__c)!=null && lRulesContact[i].NumberCaracters__c!=null && String.valueof(l.get(lRulesContact[i].SourceField__c)).length() > lRulesContact[i].NumberCaracters__c)?' \"'+String.valueof(l.get(lRulesContact[i].SourceField__c)).substring(0,Integer.valueof(lRulesContact[i].NumberCaracters__c)).replace('+','')+'*\"':'\"\"*'+String.escapeSingleQuotes(String.valueOf(l.get(lRulesContact[i].SourceField__c))).replace('+','')+'*\"';
                                        }

                                        
                                    }else if(lRulesContact[i].fieldType__c == 'DAT'){
                                        sValuesLeadAux+=String.valueof(l.get(lRulesContact[i].SourceField__c)).replace(' 00:00:00','');
                                        
                                        if(lRulesContact[i].TargetObject__c == 'Contact'){
                                            
                                            sFilterContactString+='  \"'+String.valueof(l.get(lRulesContact[i].SourceField__c)).replace(' 00:00:00','')+'  \"';
                                            
                                        }
                                        
                                
                            		}else{
                                        sValuesLeadAux += (l.get(lRulesContact[i].SourceField__c)!=null && lRulesContact[i].NumberCaracters__c!=null && String.valueof(l.get(lRulesContact[i].SourceField__c)).length() > lRulesContact[i].NumberCaracters__c)?String.escapeSingleQuotes(String.valueof(l.get(lRulesContact[i].SourceField__c)).substring(0,Integer.valueof(lRulesContact[i].NumberCaracters__c))):String.escapeSingleQuotes(String.valueOf(l.get(lRulesContact[i].SourceField__c)));
        
                                        if(lRulesContact[i].TargetObject__c == 'Contact'){
                                            sFilterContactString+=  (l.get(lRulesContact[i].SourceField__c)!=null && lRulesContact[i].NumberCaracters__c!=null && String.valueof(l.get(lRulesContact[i].SourceField__c)).length() > lRulesContact[i].NumberCaracters__c)?'  \"'+String.escapeSingleQuotes(GeneralUtils.removeAccents(String.valueOf(l.get(lRulesContact[i].SourceField__c))).substring(0,Integer.valueof(lRulesContact[i].NumberCaracters__c)))+'*\"':'\"'+String.escapeSingleQuotes(GeneralUtils.removeAccents(String.valueOf(l.get(lRulesContact[i].SourceField__c))))+'\"';
                                        }

                                    }
                                        
                                    
                                    
                                 //conditions join to AND. All members have the same order.
                                }else if(lRulesContact[i].order__C==lRulesContact[i-1].order__C){
                                    
                                    
                                    if(lRulesContact[i].fieldType__c == 'PHO'){
                                        sValuesLeadAux += (l.get(lRulesContact[i].SourceField__c)!=null && lRulesContact[i].NumberCaracters__c!=null && String.valueof(l.get(lRulesContact[i].SourceField__c)).length() > lRulesContact[i].NumberCaracters__c)?String.valueof(l.get(lRulesContact[i].SourceField__c)).substring(0,Integer.valueof(lRulesContact[i].NumberCaracters__c)).replace('+',''):String.escapeSingleQuotes(String.valueOf(l.get(lRulesContact[i].SourceField__c))).replace('+','');
        
                                        if(lRulesContact[i].TargetObject__c == 'Contact'){
                                            
                                            
                                            sFilterContactString += (l.get(lRulesContact[i].SourceField__c)!=null && l.get(lRulesContact[i].SourceField__c)!=null && lRulesContact[i].NumberCaracters__c!=null && String.valueof(l.get(lRulesContact[i].SourceField__c)).length() > lRulesContact[i].NumberCaracters__c)?SOQL_WHERE_AND+'  \"'+String.valueof(l.get(lRulesContact[i].SourceField__c)).substring(0,Integer.valueof(lRulesContact[i].NumberCaracters__c)).replace('+','')+'*\"':SOQL_WHERE_AND+'\"*'+String.escapeSingleQuotes(String.valueOf(l.get(lRulesContact[i].SourceField__c))).replace('+','')+'*\"';
                                            
                                        }
                                        
                                        
                                    }else if(lRulesContact[i].fieldType__c == 'DAT'){
                                        sValuesLeadAux+=String.valueof(l.get(lRulesContact[i].SourceField__c)).replace(' 00:00:00','');
                                        
                                        if(lRulesContact[i].TargetObject__c == 'Contact'){
                                            
                                            sFilterContactString+=SOQL_WHERE_AND+'  \"'+String.valueof(l.get(lRulesContact[i].SourceField__c)).replace(' 00:00:00','')+'  \"';
                                            
                                        }

                                        
                                    }else{
                                        sValuesLeadAux += (l.get(lRulesContact[i].SourceField__c)!=null && lRulesContact[i].NumberCaracters__c!=null && String.valueof(l.get(lRulesContact[i].SourceField__c)).length() > lRulesContact[i].NumberCaracters__c)?String.escapeSingleQuotes(String.valueof(l.get(lRulesContact[i].SourceField__c)).substring(0,Integer.valueof(lRulesContact[i].NumberCaracters__c))):String.escapeSingleQuotes(String.valueOf(l.get(lRulesContact[i].SourceField__c)));
                                        
                                        if(lRulesContact[i].TargetObject__c == 'Contact'){
                                            
                                            sFilterContactString+=  (l.get(lRulesContact[i].SourceField__c)!=null && lRulesContact[i].NumberCaracters__c!=null && String.valueof(l.get(lRulesContact[i].SourceField__c)).length() > lRulesContact[i].NumberCaracters__c)?SOQL_WHERE_AND+'  \"'+String.escapeSingleQuotes(GeneralUtils.removeAccents(String.valueOf(l.get(lRulesContact[i].SourceField__c))).substring(0,Integer.valueof(lRulesContact[i].NumberCaracters__c)))+'*\"':SOQL_WHERE_AND+'\"'+String.escapeSingleQuotes(GeneralUtils.removeAccents(String.valueOf(l.get(lRulesContact[i].SourceField__c))))+'\"';
                                            
                                        }
                                        
                                        
                                    }
                                    
                                  //the following condition are different order to the previous.
                                }else if(lRulesContact[i].order__C!=lRulesContact[i-1].order__C){
                                    
                                    mapValuesLeadAux.put(GeneralUtils.removeAccents(sValuesLeadAux.toUpperCase()),l.id); //add rule with values of lead
                                    sValuesLeadAux = '';//empty the string
                                    
                                    if(lRulesContact[i].fieldType__c == 'PHO'){
                                        sValuesLeadAux += (l.get(lRulesContact[i].SourceField__c)!=null && l.get(lRulesContact[i].SourceField__c)!=null && lRulesContact[i].NumberCaracters__c!=null && String.valueof(l.get(lRulesContact[i].SourceField__c)).length() > lRulesContact[i].NumberCaracters__c)?String.valueof(l.get(lRulesContact[i].SourceField__c)).substring(0,Integer.valueof(lRulesContact[i].NumberCaracters__c)).replace('+',''):String.escapeSingleQuotes(String.valueOf(l.get(lRulesContact[i].SourceField__c))).replace('+','');
        
                                        if(lRulesContact[i].TargetObject__c == 'Contact'){
                                            
                                            
                                            sFilterContactString+=  (l.get(lRulesContact[i].SourceField__c)!=null && lRulesContact[i].NumberCaracters__c!=null && String.valueof(l.get(lRulesContact[i].SourceField__c)).length() > lRulesContact[i].NumberCaracters__c)?SOQL_WHERE_OR+'  *\"'+String.valueof(l.get(lRulesContact[i].SourceField__c)).substring(0,Integer.valueof(lRulesContact[i].NumberCaracters__c)).replace('+','')+'*\"':SOQL_WHERE_OR+'\"*'+String.escapeSingleQuotes(String.valueOf(l.get(lRulesContact[i].SourceField__c))).replace('+','')+'*\"';
                                            
                                        }
                                        
                                                                                
                                    }else if(lRulesContact[i].fieldType__c == 'DAT'){
                                        sValuesLeadAux+=String.valueof(l.get(lRulesContact[i].SourceField__c)).replace(' 00:00:00','');
                                        
                                        if(lRulesContact[i].TargetObject__c == 'Contact'){
                                            
                                            sFilterContactString+=SOQL_WHERE_OR+'  \"'+String.valueof(l.get(lRulesContact[i].SourceField__c)).replace(' 00:00:00','')+'  \"';
                                            
                                        }
                                        

                                        
                                    }else{
                                        sValuesLeadAux += (l.get(lRulesContact[i].SourceField__c)!=null && lRulesContact[i].NumberCaracters__c!=null && String.valueof(l.get(lRulesContact[i].SourceField__c)).length() > lRulesContact[i].NumberCaracters__c)?String.escapeSingleQuotes(String.valueof(l.get(lRulesContact[i].SourceField__c)).substring(0,Integer.valueof(lRulesContact[i].NumberCaracters__c))):String.escapeSingleQuotes(String.valueOf(l.get(lRulesContact[i].SourceField__c)));
        
                                        if(lRulesContact[i].TargetObject__c == 'Contact'){
                                            sFilterContactString+=  (l.get(lRulesContact[i].SourceField__c)!=null && lRulesContact[i].NumberCaracters__c!=null && String.valueof(l.get(lRulesContact[i].SourceField__c)).length() > lRulesContact[i].NumberCaracters__c)?SOQL_WHERE_OR+'  \"'+String.escapeSingleQuotes(GeneralUtils.removeAccents(String.valueOf(l.get(lRulesContact[i].SourceField__c))).substring(0,Integer.valueof(lRulesContact[i].NumberCaracters__c)))+'*\"':SOQL_WHERE_OR+'\"'+String.escapeSingleQuotes(GeneralUtils.removeAccents(String.valueOf(l.get(lRulesContact[i].SourceField__c))))+'\"';
                                            
                                        }
                                        
                                        
                                    }			
                                    
                                }
        
                                
                            //the variable 'd' store the order number that contains one element null.
                            }else{
                                
                                d = lRulesContact[i].order__C;
                            }
                            
                            
							
							/*if(sFilterAssetString.startsWith(') OR')){
								sFilterAssetString = sFilterAssetString.removeStart(') OR ');
							}*/
            	
							if(sFilterContactString.startsWith(' OR ')){
								sFilterContactString = sFilterContactString.removeStart(' OR ');
							}
							
							
						}
                    
                    	sFilterContactString = sFilterContactString.replace('-','\\-');
                    	
                        mapValuesLeadAux.put(GeneralUtils.removeAccents(sValuesLeadAux.toUpperCase()),l.id); //add rule with values of lead
                        sValuesLeadAux = '';
						
						if(sFilterContactString!= ''){
                            mapLeadsRulesContactString.put(l.id,'( '+sFilterContactString+' )');
							
						} 
						
						/*if(sFilterAssetString!= ''){
							mapLeadsRulesAssetString.put(l.id,'( '+sFilterAssetString+' )');						
							
						}*/
                    //##RM## 19/FEB}
                    
				}
					
				//creation of the final sosl query with the values of the leads. 					
				String sWhereContact = string.join(mapLeadsRulesContactString.values(), ' OR ' );					
				//##RM## 19/FEB String sWhereAssetContact = string.join(mapLeadsRulesAssetString.values(), ' OR ' );
				//##RM## 19/FEB sWhereAssetContact = ''+sWhereAssetContact+')';  //rule finished.
				
				String sQueryContact1 = 'FIND  {'+sWhereContact+'}  IN ALL FIELDS Returning Contact('+sSelectContact.removeEnd(',')+')';
				//##RM## 19/FEB String sQueryContactAsset1 = 'FIND  {"ACAR*"}  Returning AccountContactAssetRelation__c ('+sSelectAsset.removeEnd(',')+' WHERE '+sWhereAssetContact+')';
				
				System.debug('####### sQueryContact1 6: '+sQueryContact1); 
				//##RM## 19/FEB System.debug('####### sQueryContactAsset1 6: '+sQueryContactAsset1);  
				List<List<Contact>> lContactSearch = new List<List<Contact>>();
				//##RM## 19/FEB List<List<AccountContactAssetRelation__c>> lContactAssetSearch = new List<List<AccountContactAssetRelation__c>>();
				//run the query and extract related contacts.
				
				try{
					lContactSearch = search.query(sQueryContact1);
					//##RM## 19/FEB lContactAssetSearch= search.query(sQueryContactAsset1);
					
				} catch(DMLexception e) {
					System.debug('AllocationMatchingProcess.matchLeadsAccount ERROR -->' + e.getMessage() + ' Line: '+e.getLineNumber());
				} catch (Exception e){
					System.debug('AllocationMatchingProcess.matchLeadsAccount ERROR --> ' + e.getMessage() + ' Line: '+e.getLineNumber());
				}
					

				
				System.debug('mapValuesLeadAux ----->'+mapValuesLeadAux);
				System.debug('lContactSearch ----->'+lContactSearch);
				System.debug('mapFieldNCaracters ----->'+mapFieldNCaracters);
							
				if(lContactSearch!=null && !lContactSearch.isEmpty()){
					
					for(List<Contact> la : lContactSearch){
						for(Contact a : la){
							
							String sFirstname = (a.firstname!=null && a.firstname.length()>mapFieldNCaracters.get('FirstName'))?a.firstname.substring(0,mapFieldNCaracters.get('Firstname')):a.firstname;
							String sLandlinePersonalTelephone = (a.LandlinePersonalTelephone__c!=null)?a.LandlinePersonalTelephone__c.replace('+',''):null;
							String LandlineProfessionalTelephone = (a.LandlineProfessionalTelephone__c!=null)?a.LandlineProfessionalTelephone__c.replace('+',''):null;
							String MobilePersonalTelephone = (a.MobilePersonalTelephone__c!=null)?a.MobilePersonalTelephone__c.replace('+',''):null;
							String MobileProfessionalTelephone = (a.MobileProfessionalTelephone__c!=null)?a.MobileProfessionalTelephone__c.replace('+',''):null;
							String sBirthdate = (a.Birthdate!=null)?String.valueof(a.Birthdate).replace(' 00:00:00',''):null;
							
                            //*** Local id of customer belonging to account or contact(have to create)
							if(a.Account.LocalIdOfCustomer__c!=null && mapValuesLeadAux.containsKey(GeneralUtils.removeAccents((a.Account.LocalIdOfCustomer__c).toUpperCase()))){ 
								System.debug('LocalIdOfCustomer__c'+A.Id);
								mapIdLeadAccount.put(mapValuesLeadAux.get(GeneralUtils.removeAccents((a.Account.LocalIdOfCustomer__c).toUpperCase())),a.id);
						
							}else if(a.NationalId__c!=null && mapValuesLeadAux.containsKey(GeneralUtils.removeAccents((a.NationalId__c).toUpperCase()))){ 
								System.debug('NationalId__pc'+A.Id);
								mapIdLeadContact.put(mapValuesLeadAux.get(GeneralUtils.removeAccents((a.NationalId__c).toUpperCase())),a.id);
								
							}else if(mapValuesLeadAux.containsKey(GeneralUtils.removeAccents((sLandlinePersonalTelephone+sFirstname+a.lastname).toUpperCase()))){
								System.debug('sLandlinePersonalTelephone'+A.Id);
								mapIdLeadContact.put(mapValuesLeadAux.get(GeneralUtils.removeAccents((sLandlinePersonalTelephone+sFirstname+a.lastname).toUpperCase())),a.id);
								
							}else if(mapValuesLeadAux.containsKey(GeneralUtils.removeAccents((LandlineProfessionalTelephone+sFirstname+a.lastname).toUpperCase()))){
								mapIdLeadContact.put(mapValuesLeadAux.get(GeneralUtils.removeAccents((LandlineProfessionalTelephone+sFirstname+a.lastname).toUpperCase())),a.id);
								
							}else if(mapValuesLeadAux.containsKey(GeneralUtils.removeAccents((MobilePersonalTelephone+sFirstname+a.lastname).toUpperCase()))){
								System.debug('MobilePersonalTelephone'+A.Id);
								mapIdLeadContact.put(mapValuesLeadAux.get(GeneralUtils.removeAccents((MobilePersonalTelephone+sFirstname+a.lastname).toUpperCase())),a.id);
								
							}else if(mapValuesLeadAux.containsKey(GeneralUtils.removeAccents((MobileProfessionalTelephone+sFirstname+a.lastname).toUpperCase()))){
								mapIdLeadContact.put(mapValuesLeadAux.get(GeneralUtils.removeAccents((MobileProfessionalTelephone+sFirstname+a.lastname).toUpperCase())),a.id);
								
							}else if(mapValuesLeadAux.containsKey(GeneralUtils.removeAccents((a.ProfessionalEmail__c+sFirstname+a.lastname).toUpperCase()))){
								System.debug('ProfessionalEmail__c'+A.Id);
								mapIdLeadContact.put(mapValuesLeadAux.get(GeneralUtils.removeAccents((a.ProfessionalEmail__c+sFirstname+a.lastname).toUpperCase())),a.id);
								
							}else if(mapValuesLeadAux.containsKey(GeneralUtils.removeAccents((a.MailingStreet+a.MailingPostalCode+sFirstname+a.lastname).toUpperCase()))){
								System.debug('MailingStreet'+A.Id);
								mapIdLeadContact.put(mapValuesLeadAux.get(GeneralUtils.removeAccents((a.MailingStreet+a.MailingPostalCode+sFirstname+a.lastname).toUpperCase())),a.id);
								
							}else if(mapValuesLeadAux.containsKey(GeneralUtils.removeAccents((sBirthdate+sFirstname+a.lastname).toUpperCase()))){
								System.debug('PersonBirthdate'+A.Id);
								mapIdLeadContact.put(mapValuesLeadAux.get(GeneralUtils.removeAccents((sBirthdate+sFirstname+a.lastname).toUpperCase())),a.id);
								
							}
						}
					}
				}	
            
            }
            
        }


        /** EDITED BY C1STRUN-2321 IN ORDER TO DO CREATE A MANUAL SHARING, NEEDED FOR USERS WITHOUT VISIBILITY **/
        Map<Id, List<Id>> mapRecordToShsare = new Map<Id, List<Id>>();
        List<Id> usersToShare = new List<Id>();
        Id idUser = (Id) UserInfo.getUserId();
        usersToShare.add(idUser);
        
        
        for(Lead l : lAllLeads){
            
            
            if( mapIdLeadAccount.get(l.id) != null && l.Customer__c == null){  
                mapRecordToShsare.put(mapIdLeadAccount.get(l.id),usersToShare); 
            }
            
            l.Customer__c           =(l.Customer__c==null)?mapIdLeadAccount.get(l.id):l.Customer__c;
            l.customerContact__c    =(l.customerContact__c==null)?mapIdLeadContact.get(l.id):l.customerContact__c;
            
        }
        
        if (!mapIdLeadAccount.isEmpty()){
            ManualSharingProcess.ManualSharing(mapRecordToShsare);
        }
        
    }
    /** END OF MODIFICATIONS **/

	


	/*
     * @Method          :   matchingProcess
     * @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   24 Jan 2018
     * @Description     :   Start the matching process.
     * @Params          :   lLeads(List<Lead>): List of Leads.
     * @Returns         :   List<Lead>.
     */	

    
     public static void matchingProcess(List<Lead> lLeads){
     	
		List<Lead> lLeadsB2C = new List<Lead>();
     	List<Lead> lLeadsB2B = new List<Lead>();

         
		for(Lead l : lLeads){
     		if(l.Company!=null){
     			lLeadsB2B.add(l);
     		}else{
     			lLeadsB2C.add(l);
     		}
     	}
      	
        if(!lLeadsB2C.isEmpty()){
        	AllocationMatchingProcess.matchLeadsAccounts(lLeadsB2C,B2C_RULES);

        }
        
        if(!lLeadsB2B.isEmpty()){
        	AllocationMatchingProcess.matchLeadsAccounts(lLeadsB2B,B2B_RULES);
        }
     }
}
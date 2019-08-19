/**
	*   @Class : LeadDiscardProcess.cls
	*
	*   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
	*   @Created        :   01 Mar 2018
	*   @Description    :   Match leads with a blacklist in order to discard leads.
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description
	*	   Rubén Moreno				01/03/2018				 Creation.		
	*	   Rubén Moreno				10/04/2018				 Added all phone fields.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/


public with sharing class LeadDiscardProcess {
	
    
    
    
    public static string matchFunction(String matchType, String sLeadValue, String sBlacklistValue){
        
        if(matchType == null){//None
            return null;
        }else{
            
            if(matchType == '0'){//equals
				return matchExact(sLeadValue,sBlacklistValue);
			}else if(matchType == '1'){//starts with
				return matchStartWith(sLeadValue,sBlacklistValue);
			}else if(matchType == '2'){//ends with
				return matchEndWith(sLeadValue,sBlacklistValue);
			}else if(matchType == '3'){//contains
				return matchContains(sLeadValue,sBlacklistValue);
            }else{
                return null;
            }
            
        }
    }
    

	public static string matchExact(String sLeadValue, String sBlacklistValue){
		//System.debug(sLeadValue+' == '+sBlacklistValue);
		return (sLeadValue.toUpperCase()==sBlacklistValue.toUpperCase())?'1':'0';
	}

	public static string matchStartWith(String sLeadValue, String sBlacklistValue){
		//System.debug(sLeadValue+' START '+sBlacklistValue);
		return (sLeadValue.toUpperCase().startsWith(sBlacklistValue.toUpperCase()))?'1':'0';
	}
    
    public static string matchEndWith(String sLeadValue, String sBlacklistValue){
		//System.debug(sLeadValue+' END '+sBlacklistValue);
		return (sLeadValue.toUpperCase().endsWith(sBlacklistValue.toUpperCase()))?'1':'0';
	}
    
    public static string matchContains(String sLeadValue, String sBlacklistValue){
		//System.debug(sLeadValue+' CONTAINS '+sBlacklistValue);
		return (sLeadValue.toUpperCase().contains(sBlacklistValue.toUpperCase()))?'1':'0';
	}



	public static void mainProcess(List<Lead> lLeads) {
		
		Set<String> setLeadBrands 			= new Set<String>();
		Set<String> setLeadCountries 		= new Set<String>();
		String sResultLeadMobilePers		= '';
        String sResultLeadMobileProf		= '';
        String sResultLeadLandlinePers		= '';
        String sResultLeadLandlineProf		= '';
        String sResultLeadPhone				= '';
        String sResultCriterias				= '';
        Integer iIndex						= 0;
        
		for(Lead oLead : lLeads){
			setLeadBrands.add(oLead.PSABrand__c);
			setLeadCountries.add(oLead.LeadCountry__c);
		}
		
        System.debug('_________ setLeadBrands'+setLeadBrands);
        System.debug('_________ setLeadCountries'+setLeadCountries);
        
        List<BlackList__c> loBlackList =[SELECT Id, Name, PhoneMatchType__c , Brand__c, Country__c, Phone__c, EmailMatchType__c, Email__c, FirstNameMatchType__c, Firstname__c, LastNameMatchType__c,LastName__c
									     FROM BlackList__c
									     WHERE (Country__c IN :setLeadCountries OR Country__c = null) AND (Brand__c IN :setLeadBrands OR Brand__c = 'All')
                                         ORDER BY Name desc
                                         LIMIT 50000];
        
        
        for(Lead oLead : lLeads){
            
            for(BlackList__c oBlackList : loBlackList){
            
                sResultCriterias = '';                               
                sResultCriterias += (oBlackList.PhoneMatchType__c 		!=null)?'1':null;
                sResultCriterias += (oBlackList.EmailMatchType__c		!=null)?'1':null;
                sResultCriterias += (oBlackList.FirstNameMatchType__c	!=null)?'1':null;
                sResultCriterias += (oBlackList.LastNameMatchType__c	!=null)?'1':null;
                
                sResultLeadPhone = '';
                sResultLeadPhone += (oLead.Phone		!=null && oBlackList.PhoneMatchType__c 		!=null && (oLead.PSABrand__c == oBlackList.Brand__c || oBlackList.Brand__c == 'All') && (oLead.leadcountry__c == oBlackList.country__c || oBlackList.country__c == null))?matchFunction(oBlackList.PhoneMatchType__c,oLead.Phone,oBlackList.Phone__C)				:null;
                sResultLeadPhone += (oLead.Email		!=null && oBlackList.EmailMatchType__c		!=null && (oLead.PSABrand__c == oBlackList.Brand__c || oBlackList.Brand__c == 'All') && (oLead.leadcountry__c == oBlackList.country__c || oBlackList.country__c == null))?matchFunction(oBlackList.EmailMatchType__c,oLead.Email,oBlackList.Email__C)				:null;
                sResultLeadPhone += (oLead.FirstName	!=null && oBlackList.FirstNameMatchType__c	!=null && (oLead.PSABrand__c == oBlackList.Brand__c || oBlackList.Brand__c == 'All') && (oLead.leadcountry__c == oBlackList.country__c || oBlackList.country__c == null))?matchFunction(oBlackList.FirstNameMatchType__c,oLead.Firstname,oBlackList.Firstname__C)	:null;
                sResultLeadPhone += (oLead.LastName		!=null && oBlackList.LastNameMatchType__c	!=null && (oLead.PSABrand__c == oBlackList.Brand__c || oBlackList.Brand__c == 'All') && (oLead.leadcountry__c == oBlackList.country__c || oBlackList.country__c == null))?matchFunction(oBlackList.LastNameMatchType__c,oLead.LastName,oBlackList.LastName__C)		:null;
                
                sResultLeadMobilePers = '';
                sResultLeadMobilePers += (oLead.MobilePersonalTelephone__c		!=null && oBlackList.PhoneMatchType__c 		!=null && (oLead.PSABrand__c == oBlackList.Brand__c || oBlackList.Brand__c == 'All') && (oLead.leadcountry__c == oBlackList.country__c || oBlackList.country__c == null))?matchFunction(oBlackList.PhoneMatchType__c,oLead.MobilePersonalTelephone__c,oBlackList.Phone__C)				:null;
                sResultLeadMobilePers += (oLead.Email							!=null && oBlackList.EmailMatchType__c		!=null && (oLead.PSABrand__c == oBlackList.Brand__c || oBlackList.Brand__c == 'All') && (oLead.leadcountry__c == oBlackList.country__c || oBlackList.country__c == null))?matchFunction(oBlackList.EmailMatchType__c,oLead.Email,oBlackList.Email__C)				:null;
                sResultLeadMobilePers += (oLead.FirstName						!=null && oBlackList.FirstNameMatchType__c	!=null && (oLead.PSABrand__c == oBlackList.Brand__c || oBlackList.Brand__c == 'All') && (oLead.leadcountry__c == oBlackList.country__c || oBlackList.country__c == null))?matchFunction(oBlackList.FirstNameMatchType__c,oLead.Firstname,oBlackList.Firstname__C)	:null;
                sResultLeadMobilePers += (oLead.LastName						!=null && oBlackList.LastNameMatchType__c	!=null && (oLead.PSABrand__c == oBlackList.Brand__c || oBlackList.Brand__c == 'All') && (oLead.leadcountry__c == oBlackList.country__c || oBlackList.country__c == null))?matchFunction(oBlackList.LastNameMatchType__c,oLead.LastName,oBlackList.LastName__C)		:null;
                
                sResultLeadMobileProf = '';
                sResultLeadMobileProf += (oLead.MobileProfessionalTelephone__c	!=null && oBlackList.PhoneMatchType__c 		!=null && (oLead.PSABrand__c == oBlackList.Brand__c || oBlackList.Brand__c == 'All') && (oLead.leadcountry__c == oBlackList.country__c || oBlackList.country__c == null))?matchFunction(oBlackList.PhoneMatchType__c,oLead.MobileProfessionalTelephone__c,oBlackList.Phone__C)				:null;
                sResultLeadMobileProf += (oLead.Email							!=null && oBlackList.EmailMatchType__c		!=null && (oLead.PSABrand__c == oBlackList.Brand__c || oBlackList.Brand__c == 'All') && (oLead.leadcountry__c == oBlackList.country__c || oBlackList.country__c == null))?matchFunction(oBlackList.EmailMatchType__c,oLead.Email,oBlackList.Email__C)				:null;
                sResultLeadMobileProf += (oLead.FirstName						!=null && oBlackList.FirstNameMatchType__c	!=null && (oLead.PSABrand__c == oBlackList.Brand__c || oBlackList.Brand__c == 'All') && (oLead.leadcountry__c == oBlackList.country__c || oBlackList.country__c == null))?matchFunction(oBlackList.FirstNameMatchType__c,oLead.Firstname,oBlackList.Firstname__C)	:null;
                sResultLeadMobileProf += (oLead.LastName						!=null && oBlackList.LastNameMatchType__c	!=null && (oLead.PSABrand__c == oBlackList.Brand__c || oBlackList.Brand__c == 'All') && (oLead.leadcountry__c == oBlackList.country__c || oBlackList.country__c == null))?matchFunction(oBlackList.LastNameMatchType__c,oLead.LastName,oBlackList.LastName__C)		:null;
                
                sResultLeadLandlinePers = '';
                sResultLeadLandlinePers += (oLead.LandlinePersonalTelephone__c	!=null && oBlackList.PhoneMatchType__c 		!=null && (oLead.PSABrand__c == oBlackList.Brand__c || oBlackList.Brand__c == 'All') && (oLead.leadcountry__c == oBlackList.country__c || oBlackList.country__c == null))?matchFunction(oBlackList.PhoneMatchType__c,oLead.LandlinePersonalTelephone__c,oBlackList.Phone__C)				:null;
                sResultLeadLandlinePers += (oLead.Email							!=null && oBlackList.EmailMatchType__c		!=null && (oLead.PSABrand__c == oBlackList.Brand__c || oBlackList.Brand__c == 'All') && (oLead.leadcountry__c == oBlackList.country__c || oBlackList.country__c == null))?matchFunction(oBlackList.EmailMatchType__c,oLead.Email,oBlackList.Email__C)				:null;
                sResultLeadLandlinePers += (oLead.FirstName						!=null && oBlackList.FirstNameMatchType__c	!=null && (oLead.PSABrand__c == oBlackList.Brand__c || oBlackList.Brand__c == 'All') && (oLead.leadcountry__c == oBlackList.country__c || oBlackList.country__c == null))?matchFunction(oBlackList.FirstNameMatchType__c,oLead.Firstname,oBlackList.Firstname__C)	:null;
                sResultLeadLandlinePers += (oLead.LastName						!=null && oBlackList.LastNameMatchType__c	!=null && (oLead.PSABrand__c == oBlackList.Brand__c || oBlackList.Brand__c == 'All') && (oLead.leadcountry__c == oBlackList.country__c || oBlackList.country__c == null))?matchFunction(oBlackList.LastNameMatchType__c,oLead.LastName,oBlackList.LastName__C)		:null;
                
                sResultLeadLandlineProf = '';
                sResultLeadLandlineProf += (oLead.LandlineProfessionalTelephone__c!=null && oBlackList.PhoneMatchType__c 		!=null && (oLead.PSABrand__c == oBlackList.Brand__c || oBlackList.Brand__c == 'All') && (oLead.leadcountry__c == oBlackList.country__c || oBlackList.country__c == null))?matchFunction(oBlackList.PhoneMatchType__c,oLead.LandlineProfessionalTelephone__c,oBlackList.Phone__C)				:null;
                sResultLeadLandlineProf += (oLead.Email							!=null && oBlackList.EmailMatchType__c		!=null && (oLead.PSABrand__c == oBlackList.Brand__c || oBlackList.Brand__c == 'All') && (oLead.leadcountry__c == oBlackList.country__c || oBlackList.country__c == null))?matchFunction(oBlackList.EmailMatchType__c,oLead.Email,oBlackList.Email__C)				:null;
                sResultLeadLandlineProf += (oLead.FirstName						!=null && oBlackList.FirstNameMatchType__c	!=null && (oLead.PSABrand__c == oBlackList.Brand__c || oBlackList.Brand__c == 'All') && (oLead.leadcountry__c == oBlackList.country__c || oBlackList.country__c == null))?matchFunction(oBlackList.FirstNameMatchType__c,oLead.Firstname,oBlackList.Firstname__C)	:null;
                sResultLeadLandlineProf += (oLead.LastName						!=null && oBlackList.LastNameMatchType__c	!=null && (oLead.PSABrand__c == oBlackList.Brand__c || oBlackList.Brand__c == 'All') && (oLead.leadcountry__c == oBlackList.country__c || oBlackList.country__c == null))?matchFunction(oBlackList.LastNameMatchType__c,oLead.LastName,oBlackList.LastName__C)		:null;
                
                
                
                System.debug('LEAD IN LOOP: '+oLead);
                System.debug('BLACKLIST IN LOOP: '+oBlackList);
                
                System.debug('#RM# Comparison:'+oBlackList.name+' Rule->'+sResultCriterias+' -- '+sResultLeadMobilePers+'<-Lead');
                System.debug('#RM# Comparison:'+oBlackList.name+' Rule->'+sResultCriterias+' -- '+sResultLeadMobileProf+'<-Lead');
                System.debug('#RM# Comparison:'+oBlackList.name+' Rule->'+sResultCriterias+' -- '+sResultLeadLandlinePers+'<-Lead');
                System.debug('#RM# Comparison:'+oBlackList.name+' Rule->'+sResultCriterias+' -- '+sResultLeadLandlineProf+'<-Lead');
                
                if(sResultLeadMobileProf==sResultCriterias || sResultLeadMobilePers==sResultCriterias || sResultLeadPhone==sResultCriterias || sResultLeadLandlinePers==sResultCriterias || sResultLeadLandlineProf==sResultCriterias){//the lead has matched all criterias.
                    oLead.Status 						= 'Discarded';
                    oLead.LeadQualificationResult__c 	= 'Contact methods failed';
                    
                    System.debug('*********#RM#*********** Lead Discard: '+oLead);
                    System.debug('#RM# Rule Discard: '+oBlackList.name);
                    
                    break;//to pass to the next lead.
                    
                }else{//the lead has not matched at least one criteria.
                    continue;
                    
                }
            
            }

         }    

	}
}
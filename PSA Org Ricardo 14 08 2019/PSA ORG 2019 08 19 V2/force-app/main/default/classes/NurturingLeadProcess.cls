/**
	*   @Class : NurturingLeadProcess.cls
	*
	*   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
	*   @Created        :   01 Mar 2018
	*   @Description    :   Match leads with a configurator in order to update leads to nurturing status.
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description
	*	   Rubén Moreno				15/06/2018				 Creation.		
	*	   		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/


public with sharing class NurturingLeadProcess {
    
    private final static string NURTURING_STATUS = 'Nurturing';
    
    public static void mainProcess(List<Lead> lLeads){
        
        Set<String> setLeadBrands		= new Set<String>();
		Set<String> setLeadCountries	= new Set<String>();
        
		for(Lead oLead : lLeads){
			setLeadBrands.add(oLead.PSABrand__c);
			setLeadCountries.add(oLead.LeadCountry__c);
		}
		
        System.debug('## RM NLP## setLeadBrands: '+setLeadBrands);
        System.debug('## RM NLP## setLeadCountries: '+setLeadCountries);
        
        
        List<NurturingLeadConfigurator__mdt> lConfigurator = [SELECT Brand__c, Country__c, PurchaseIntentionPeriod__c, RequestType__c 
                                                              FROM NurturingLeadConfigurator__mdt 
                                                              WHERE (Country__c IN :setLeadCountries OR Country__c = 'All') AND (Brand__c IN :setLeadBrands OR Brand__c = 'All')
                                                              LIMIT 50000];        
        
        for(Lead oLead : lLeads){
            
            for(NurturingLeadConfigurator__mdt oConf : lConfigurator){
                
                if((olead.LeadCountry__c == oConf.Country__c || oConf.Country__c == 'All') && (olead.PSABrand__c == oConf.Brand__c || oConf.Brand__c == 'All') && 
                   (olead.PurchaseIntentionPeriod__c == oConf.PurchaseIntentionPeriod__c) && (olead.LeadRequestType__c == oConf.RequestType__c)){
                    
                    oLead.Status 					= NURTURING_STATUS;
                    oLead.TECH_NurturingLead__c		= true;
                    oLead.OwnerId					= Label.API_User;
                       
                    System.debug('## RM NLP## Lead Nurturing: '+oLead);
                    break; // it is not necessary check other rule.
                    
                }
                
            }
            
        }
        
    }

}
/**
    *   @Class          :  EmailMessageUtils   
    *
    *   @Author         :  Pedro Párraga <parragabornez.pedrojesus@ext.mpsa.com>
    *   @Created        :  17/04/2019 
    *   @Description    :  Class to Controller EmailMessages events
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer             Date						Description    
    *      Pedro Párraga         17/04/2019                 Creation.    
	* 	   Ruben Fernandez		 25/04/2019					Added new methods to make sure emails are sent from the right OWA 
	*														- getCECProfiles. List of all CEC profiles used to validate the "FROM"
	*														used for outbound emails
	*														- getCEOOWA. Map of OWAs for each tupla of Country & Brand
	*														- validateEmailOWA. For each outbound email sent by a CEC user checks
	*														if the address selecte as "FROM" is the right one. In case of error, it
	*														return an specific error.
	*														Updated existing methods:
	*														- changeCaseStatus. Replaced hardcode values by constants: CareConstants
	*														                    New validation (only for Inbound emails)
	*																			Error Handling. Try / Catch added.
    *   ----------------------------------------------------------------------------------------------------------------------------
**/
public with sharing class EmailMessageUtils {

 	private static map<String,OrgWideEmailAddress> mapOWA 		= new  map<String,OrgWideEmailAddress> ();
	private static Set <String> validCECProfiles 				= new Set<String>();
	/*
      * @Method          :   getCECProfiles
      * @Description     :   Get all CEC profiles used for validation
      * @Param           :   -
      * @Return          :   -
    */ 
	private static void getCECProfiles(){
		for(ProfilesCECUsers__mdt profileCECUser : [SELECT Label FROM ProfilesCECUsers__mdt WHERE IsActive__c = true]){
            validCECProfiles.add(profileCECUser.Label);
        }
	}
	/*
      * @Method          :   getCECOWA
      * @Description     :   Get all OWAs by each Brand & Country tupla
      * @Param           :   -
      * @Return          :   -
    */ 
	private static void getCECOWA(){
		for (OrgWideEmailAddress owea : [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress Where Address Like : EmailMessageConstants.OWA_EMAIL_DOMAIN_FILTER]){
    		String Country;
    		String Address  = owea.Address;
    		Integer iPos 	= Address.indexof(EmailMessageConstants.OWA_EMAIL_DOMAIN);
			if(iPos>0){
				Country 	= Address.left(iPos).right(5).left(2);  
				if(Address.indexof(EmailMessageConstants.ADDRESS_CITROEN)>=0){
					mapOWA.put(Country.toUpperCase() + EmailMessageConstants.CASE_BRAND_CITROEN, owea);
				}else if(Address.indexof(EmailMessageConstants.ADDRESS_DSAUTOMOBILES)>=0){
					mapOWA.put(Country.toUpperCase() + EmailMessageConstants.CASE_BRAND_DSAUTOMOBILES, owea);
				}else if(Address.indexof(EmailMessageConstants.ADDRESS_PEUGEOT)>=0){
					mapOWA.put(Country.toUpperCase() + EmailMessageConstants.CASE_BRAND_PEUGEOT, owea);
				}
			}
        }
	}
    /*
      * @Method          :   validateEmailOWA
      * @Description     :   All emails sent from cases by CEC agents will be sent with the
	  *					 :   right OWA (Brand & Country)
      * @Param           :   List<EmailMessage> lstNewEmailMess
      * @Return          :   -
    */ 
	public static void validateEmailOWA (List<EmailMessage> lstNewEmailMess){
		getCECOWA();
		getCECProfiles();
		set<Id> caseIds 				= new set<Id>();
		List<EmailMessage> lstEmailsEnd = new List<EmailMessage>();
    	map<Id,String> case2Map 		= new map<Id,String>();
		if(validCECProfiles.contains(PAD.uCurrentUserName.Profile.Name)){
			for(EmailMessage message : lstNewEmailMess){
				if(message.Incoming == false){
					String sParentId 	= message.parentId;
					if(String.isNotBlank(sParentId) && sParentId.startsWith(case.sObjectType.getDescribe().getKeyPrefix())){
						caseIds.add(message.ParentId);
						lstEmailsEnd.add(message);
					}
				}
			}
		}
    	List<Case> casesToUpdate = [Select Id, Status, Country__c, Brand__c From Case Where Id IN: caseIds];
    	for(Case c : casesToUpdate){
			case2Map.put(c.Id,c.Country__c + c.Brand__c);
    	}
		for(EmailMessage message : lstEmailsEnd){
        	if(case2Map.containsKey(message.ParentId) && mapOWA.containsKey(case2Map.get(message.ParentId))){
                OrgWideEmailAddress owa = mapOWA.get(case2Map.get(message.ParentId));
                //if(message.FromAddress != owa.Address){
                    //message.addError(Label.EmailMessage_Wrong_FromAddress + ' ' + owa.DisplayName );	
                    message.FromAddress = owa.Address;
                    message.FromName	= owa.DisplayName;
                //}
            }
    	}
	}
	/*
      * @Method          :   changeCaseStatus
      * @Description     :   Case status is managed based on receiving an emailert
      * @Param           :   List<EmailMessage> lstNewEmailMess
      * @Return          :   Void
    */ 
	public static void changeCaseStatus(List<EmailMessage> lstNewEmailMess){
		set<Id> idsCaseEm 				= new set<Id>();
		for(EmailMessage em : lstNewEmailMess){
			String parentId 			= em.ParentId;
			if(em.Incoming){
				if(String.isNotBlank(parentId) && parentId.startsWith(case.sObjectType.getDescribe().getKeyPrefix())){
					idsCaseEm.add(parentId);
				}
			}
		}
		if(!idsCaseEm.isEmpty()){
			List<Case> lstCases 		= [SELECT Id, Status  FROM Case WHERE Id IN : idsCaseEm];
			for(Case cas : lstCases){
				if(cas.Status == CareConstants.CASE_STATUS_CLOSED){
					cas.Status 			= CareConstants.CASE_STATUS_REOPENED;
				}else if(cas.Status != CareConstants.CASE_STATUS_LOCKED){
					cas.Status 			= CareConstants.CASE_STATUS_UPDATED_BY;
				}
			}
			if(!lstCases.isEmpty()){
				try{
					update lstCases;
				}catch(Exception e){
					System.debug(' Email Message. Case Update exception: ' + e.getMessage());
				}
			}
		}
	}
}
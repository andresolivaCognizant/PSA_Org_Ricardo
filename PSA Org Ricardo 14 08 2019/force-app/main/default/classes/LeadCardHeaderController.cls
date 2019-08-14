public with sharing class LeadCardHeaderController {
	
	@AuraEnabled
    public static Lead getLeadRecord (Id leadId) {
	    System.debug('Start of LeadCardHeaderController.getLeadRecord...'); 
	    return [SELECT Name,
	                   LeadRequestType__c, 
	                   LeadSource, 
	                   ProductCustomerInterest__c,
	                   //Contact,
	                   Status,
	                   TreatmentPriority__c,
	                   TECH_TreatmentPriorityLabel__c
	              FROM Lead
	             WHERE Id = :leadId LIMIT 1];
    }
    
    @AuraEnabled
    public static Integer getLeadActivityCount (Id leadId) {
	    System.debug('Start of LeadCardHeaderController.getLeadActivityCount...'); 
	    
	    Integer activityCount = [SELECT COUNT() FROM Task WHERE Who.Id = :leadId];
	    
	    return activityCount;
    }
}
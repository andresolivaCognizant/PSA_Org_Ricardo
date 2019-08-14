public with sharing class LookupUserResultController {
       
    @AuraEnabled
	public static List<leadCounts> getUserLeadCounts(Id userId) {
		System.debug('Start of LookupUserResultController.getUserLeadCounts...');
		List<leadCounts> userLeadCounts = new List<leadCounts>();
		List<Lead> Leads = [SELECT Id, 
									Name,
				                    OwnerId, 
				                    TECH_TreatmentPriorityLabel__c 
		                    FROM Lead
		                    WHERE Id = :userId];

		Integer countOnTime = 0;
		Integer countUrgent = 0;
		Integer countOverdue = 0;
		
		Id currentUserId;
		
		for (Lead ld : Leads)         
		{
		    leadCounts lc = new leadCounts();
		    integer onTimeCount = 0;
		    integer urgentCount = 0;
		    integer overdueCount = 0;
		    
		    if (ld.OwnerId == currentUserId) 
		    {
		        if (ld.TECH_TreatmentPriorityLabel__c == LEAD_PRIORITY_ONTIME) onTimeCount ++;
		        else if (ld.TECH_TreatmentPriorityLabel__c == LEAD_PRIORITY_URGENT) urgentCount ++;
		        else overdueCount ++;
		    } 
		    else
		    {
		        lc.id = ld.Id;
		        lc.userName = ld.Name;
		        lc.countOnTime = onTimeCount;
		        lc.countUrgent = urgentCount;
		        lc.countOverdue = overdueCount;
		        userLeadCounts.add(lc);
		        
		        currentUserId = ld.OwnerId;
		    }
		}
		System.debug(':::userLeadCounts: ' + userLeadCounts);
		return userLeadCounts;
	}   
	
	static final String LEAD_PRIORITY_ONTIME = 'On Time';
	static final String LEAD_PRIORITY_URGENT = 'Urgent';
	static final String LEAD_PRIORITY_OVERDUE = 'Overdue';
	static final String LEAD_PRIORITY_ALL = 'All';
	
	public class leadCounts {
		
		    @AuraEnabled
		    public Id id;
		
		    @AuraEnabled
		    public String userName;
		    
		    @AuraEnabled
		    public Integer countOnTime = 0;
		    
		    @AuraEnabled
		    public Integer countUrgent = 0;
		    
		    @AuraEnabled
		    public Integer countOverdue = 0;
		}
	
}
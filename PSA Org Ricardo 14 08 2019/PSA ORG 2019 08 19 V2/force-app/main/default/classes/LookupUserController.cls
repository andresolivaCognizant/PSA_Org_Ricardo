/**
 * This method is used to return a list of records from the specified object
 * @param ObjectName - The API name of object
 * @param searchKeyWord - The text to search
 * @param whereClause - Allow add any where clause to the query
 */ 

public with sharing class LookupUserController {

    @AuraEnabled
    public static List <sObject> fetchLookUpValues(String searchKeyWord, String ObjectName, String whereClause) {
        System.debug('Start of LookupUserController.fetchLookupValues...');

        String searchKey = searchKeyWord + '%';
        String sQuery =  '';

        if (whereClause == null) {
            sQuery =  'select id, Name from ' + ObjectName + ' where Name LIKE: searchKey order by createdDate DESC';
        } else {
            sQuery = 'SELECT Id, Name, Contact.GeographicalSite__r.Name FROM ' +
                ObjectName +
                ' WHERE (Name LIKE :searchKey OR Contact.GeographicalSite__r.Name LIKE :searchKey) ' +
                whereClause +
                ' ORDER BY Contact.GeographicalSite__r.Name ASC NULLS LAST, Name ASC NULLS LAST';
        }

        return Database.query(sQuery);
    }
    
    @AuraEnabled
    public static List<leadCounts> getUserLeadCounts(Boolean filterByCurrentUser) {
        List<leadCounts> userLeadCounts = new List<leadCounts>();
        List<Lead> Leads = [SELECT Id, 
                                    Name,
                                    OwnerId, 
                                    TECH_TreatmentPriorityLabel__c 
                            FROM Lead
                            ORDER BY OwnerId];
        
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
        System.debug('userLeadCounts: ' + userLeadCounts);
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
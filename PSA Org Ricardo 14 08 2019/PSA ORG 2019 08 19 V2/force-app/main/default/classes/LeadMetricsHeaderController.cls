public with sharing class LeadMetricsHeaderController {
    
    static final String LEAD_PRIORITY_ONTIME    = 'On Time';
    static final String LEAD_PRIORITY_URGENT    = 'Urgent';
    static final String LEAD_PRIORITY_OVERDUE   = 'Overdue';
    static final String LEAD_PRIORITY_ALL       = 'All';
    static final String LEAD_SOQL_QUERY         = 'SELECT Activity__c, SUM(TECH_TreatmentPriorityOnTime__c),SUM(TECH_TreatmentPriorityOverdue__c),SUM(TECH_TreatmentPriorityUrgent__c) FROM Lead';
    static final String LEAD_SOQL_GROUP         = ' GROUP BY Activity__c';

    
    public class LeadMetricsDataWrapper {
        
        @AuraEnabled
        public String priority;
        
        @AuraEnabled
        public String priorityName;

        @AuraEnabled
        public String className;
        
        @AuraEnabled
        public Integer vnCount;
        
        @AuraEnabled
        public Integer voCount;
        
        @AuraEnabled
        public Integer apvCount;
        
        @AuraEnabled
        public Integer otherCount;
        
        @AuraEnabled
        public Integer subTotalCount;
        
        @AuraEnabled
        public Integer totalCount;
        
    }
    
    public class LeadTotalsWrapper {
        
        @AuraEnabled
        public Integer totalOnTime;
        
        @AuraEnabled
        public Integer totalUrgent;
        
        @AuraEnabled
        public Integer totalOverdue;
        
        @AuraEnabled
        public Integer totalOther;
        
        @AuraEnabled
        public Integer totalNewLeads;
        
    }
    
    @AuraEnabled
    public static LeadTotalsWrapper getLeadTotals (Boolean filterByCurrentUser,
                                                   String filterByStatus,
                                                   String whereClause) {
       LeadTotalsWrapper leadTotalsData = new LeadTotalsWrapper();  
       System.debug('Start of LeadMetricsController.getLeadTotals...'); 
       System.debug(':::filterByStatus: ' + filterByStatus);
       if (filterByCurrentUser ) System.debug(':::filterByCurrentUser: true');
       else System.debug(':::filterByCurrentUser: false');
       System.debug(':::whereClause: ' + whereClause);
       
       String queryString = 'SELECT Id ' +
                                    ',TECH_TreatmentPriorityLabel__c ' +
                                    ',Activity__c ' +
                              ' FROM Lead ';

        if (String.isBlank(whereClause)) {
            whereClause = ' WHERE Id != null ';
        }
        
        if (String.isNotBlank(filterByStatus)) {
            if (filterByStatus.indexOf(',')>1) {
        		whereClause     = whereClause + ' AND Status IN ' + filterByStatus +' ';
        	} else {
        		whereClause     = whereClause + ' AND Status = \'' + filterByStatus + '\' ';
        	}
            //whereClause = whereClause + ' AND Status = \'' + filterByStatus + '\' ';
        }
        
        System.debug(':::filterByCurrentUser' + filterByCurrentUser);
        if (filterByCurrentUser) {
            String currentUserId = UserInfo.getUserID();
            whereClause = whereClause + ' AND OwnerId =  \'' + currentUserId + '\' ';    
        }
        
        queryString = queryString + whereClause;
              
        List<Lead> Leads = new List<Lead>();
        try {
            Leads = database.query(queryString);
            system.debug('## RESULTS : ' + leads);
        } catch(dmlexception e) {
            system.debug('## DML Exception : ' + e.getMessage());
        } catch (Exception e){
            System.debug('### Other Exception--> ' + e.getMessage());
        }
        
        Integer countOnTime = 0;
        Integer countUrgent = 0;
        Integer countOverdue = 0;
        Integer countOther = 0;
        Integer countTotal = 0;
        
        for (Lead ld : Leads)
        {
            if (ld.TECH_TreatmentPriorityLabel__c == LEAD_PRIORITY_ONTIME) 
            { 
                countOnTime++; 
            }
            else if (ld.TECH_TreatmentPriorityLabel__c == LEAD_PRIORITY_URGENT) 
            { 
                countUrgent++; 
            }
            else if (ld.TECH_TreatmentPriorityLabel__c == LEAD_PRIORITY_OVERDUE) 
            { 
                countOverdue++; 
            }
            else 
            {
                countOther++;
            }
            
            countTotal++;
        }
        
        leadTotalsData.totalOnTime = countOnTime;
        leadTotalsData.totalUrgent = countUrgent;
        leadTotalsData.totalOverdue = countOverdue;
        leadTotalsData.totalOther = countOther;
        leadTotalsData.totalNewLeads = countTotal;
        
        System.debug('leadTotalsData: ' + leadTotalsData);
        return leadTotalsData;
        
    }
    
    /*
    @AuraEnabled
    public static List<LeadMetricsDataWrapper> getLeadMetrics (Boolean filterByCurrentUser,
                                                               String filterByStatus,
                                                               String whereClause) {
        System.debug('Start of LeadMetricsController.getLeadMetrics...');
        System.debug(':::filterByStatus: ' + filterByStatus);
        if (filterByCurrentUser ) System.debug(':::filterByCurrentUser: true');
        else System.debug(':::filterByCurrentUser: false');
        System.debug(':::whereClause: ' + whereClause);
        
        String[] priorityLevels = new String[]{LEAD_PRIORITY_OVERDUE, LEAD_PRIORITY_URGENT,LEAD_PRIORITY_ONTIME};   
        List<LeadMetricsDataWrapper> leadMetricsData = new List<LeadMetricsDataWrapper>();  
        
        Integer countTotal = 0;
        for (String priority : priorityLevels) 
        {
            LeadMetricsDataWrapper lmd = new LeadMetricsDataWrapper();
            Integer countVN = 0;
            Integer countVO = 0;
            Integer countAPV = 0;
            Integer countOther = 0;
            Integer countSubTotal = 0;
            
            String queryString = 'SELECT Id ' +
                                        ',TECH_TreatmentPriorityLabel__c ' +
                                        ',Activity__c ' +
                                  ' FROM Lead ';
    
            if (String.isBlank(whereClause)) {
                whereClause = ' WHERE Id != null ';
            }
            
            whereClause = whereClause + 'AND TECH_TreatmentPriorityLabel__c = :priority';
            
            if (String.isNotBlank(filterByStatus)) {
                whereClause = whereClause + ' AND Status = \'' + filterByStatus + '\' ';
            }
            
            System.debug(':::filterByCurrentUser' + filterByCurrentUser);
            if (filterByCurrentUser) {
                String currentUserId = UserInfo.getUserID();
                whereClause = whereClause + ' AND OwnerId =  \'' + currentUserId + '\' ';    
            }
                    
            queryString = queryString + whereClause;
          
            List<Lead> Leads = new List<Lead>();
            try {
                Leads = database.query(queryString);
                system.debug('## RESULTS : ' + leads);
            } catch(dmlexception e) {
                system.debug('## DML Exception : ' + e.getMessage());
            } catch (Exception e){
                System.debug('### Other Exception--> ' + e.getMessage());
            }

            for (Lead ld : Leads)
            {
                if (ld.Activity__c == 'VN') 
                { 
                    countVN++; 
                }
                else if (ld.Activity__c == 'VO') 
                { 
                    countVO++; 
                }
                else if (ld.Activity__c == 'APV') 
                { 
                    countAPV++; 
                }
                
                //else if (ld.Activity__c == 'PR' || 
                //         ld.Activity__c == 'SE' || 
                //         ld.Activity__c == 'FI' || 
                //         ld.Activity__c == 'ACC')
                //
                else
                {
                    countOther++;
                }
                
                countSubTotal++;
            }
            
            countTotal = countTotal + countSubTotal;
            
            lmd.subTotalCount = countSubTotal;
            lmd.vnCount = countVN;
            lmd.voCount = countVO;
            lmd.apvCount = countAPV;
            lmd.otherCount = countOther;
            //lmd.priority = priority;
            if (priority == LEAD_PRIORITY_OVERDUE) {
                lmd.className = 'traffic-light red-light';
                lmd.priority = System.Label.LeadAssignmentOverdue;
            } else if (priority == LEAD_PRIORITY_URGENT) {
                lmd.className = 'traffic-light amber-light';
                lmd.priority = System.Label.LeadAssignmentUrgent;
            } else {
                lmd.className = 'traffic-light green-light';
                lmd.priority = System.Label.LeadAssignmentOnTime;
            }
            
            leadMetricsData.add(lmd);
        }
        
        System.debug('leadMetricsData: ' + leadMetricsData);
        return leadMetricsData;
    } 

    */
    @AuraEnabled
    public static String getUserPortalRole() {
        System.debug('Start of DealerPortalThemeController.getUserPortalRole...');
        
        //User uri              = new User();
        //UserRole upr          = new UserRole();
        /*Updated. Preventing error if no rows*/
        List<UserRole> lstUPR = new List<UserRole>([SELECT PortalRole FROM UserRole WHERE Id IN (SELECT UserRoleId FROM User WHERE Id= :UserInfo.getUserID())]);
        System.debug('return: ' + lstUPR.get(0));
        /*End update*/
        String portalRole     = 'Worker';
        //String currentUserId  = UserInfo.getUserID();
        //uri = [SELECT UserRoleId FROM User WHERE Id = :currentUserId LIMIT 1];

        //System.debug('userRoleId: ' + uri.userRoleId);
        
        if(!lstUPR.isEmpty()){
            if (lstUPR.get(0).PortalRole != null ) {
                portalRole = lstUPR.get(0).PortalRole;
            }
        }
        
        return portalRole;
        //return 'Manager';
    }
    @AuraEnabled
    public static List<LeadMetricsDataWrapper> getLeadMetrics (Boolean filterByCurrentUser,
                                                               String filterByStatus,
                                                               String whereClause) {
        System.debug('Start of LeadMetricsController.getLeadMetrics...');
        System.debug(':::filterByStatus: ' + filterByStatus);
        if (filterByCurrentUser ) System.debug(':::filterByCurrentUser: true');
        else System.debug(':::filterByCurrentUser: false');
        System.debug(':::whereClause: ' + whereClause);
        
        String[] priorityLevels = new String[]{LEAD_PRIORITY_OVERDUE, LEAD_PRIORITY_URGENT,LEAD_PRIORITY_ONTIME};   
        List<LeadMetricsDataWrapper> leadMetricsData = new List<LeadMetricsDataWrapper>(); 
        List<AggregateResult> lstLeads = new List<AggregateResult>();
           
        Integer countVN_Urg         = 0;
        Integer countVO_Urg         = 0;
        Integer countAPV_Urg        = 0;
        Integer countOther_Urg      = 0;
        Integer countSubTotal       = 0;
        
        Integer countVN_OT          = 0;
        Integer countVO_OT          = 0;
        Integer countAPV_OT         = 0;
        Integer countOther_OT       = 0;
        
        Integer countVN_OV          = 0;
        Integer countVO_OV          = 0;
        Integer countAPV_OV         = 0;
        Integer countOther_OV       = 0;
        String  sCurrentRole        = getUserPortalRole();        
        if (filterByCurrentUser) {
            String currentUserId    = UserInfo.getUserID();
            if(String.isEmpty(whereClause)){
                whereClause             = ' WHERE OwnerId =  \'' + currentUserId + '\' ';    
            }
        }else{
            if(sCurrentRole.equals('Manager')){
                String currentUserId    = UserInfo.getUserID();
                if(String.isEmpty(whereClause)){
                    whereClause             = ' WHERE OwnerId !=  \'' + currentUserId + '\' ';    
                }
            }
        }
        if (!String.isEmpty(filterByStatus)) {
            if(String.isEmpty(whereClause)){
                /* Start: RFL - C1STAGILE-9109 Added support to multiple status */
                if (filterByStatus.indexOf(',')>1) {
                    whereClause     = ' WHERE Status IN ' + filterByStatus + ' ';
                } else {
                    whereClause     = ' WHERE Status = \'' + filterByStatus + '\' ';
                }
                /* End Change - C1STAGILE-9109 */  
            }else{
                /* Start: RFL - C1STAGILE-9109 Added support to multiple status */
                if (filterByStatus.indexOf(',')>1) {
                    whereClause     = whereClause + ' AND Status IN ' + filterByStatus + ' ';
                } else {
                    whereClause     = whereClause + ' AND Status = \'' + filterByStatus + '\' ';
                }
                /* End Change - C1STAGILE-9109 */
            }
        }
        String queryString          = LEAD_SOQL_QUERY + whereClause + LEAD_SOQL_GROUP;
        System.debug('## queryString : ' + queryString);
        try {
            lstLeads = database.query(queryString);
            System.debug('## RESULTS : ' + lstLeads);
        } catch(dmlexception e) {
            System.debug('## DML Exception : ' + e.getMessage());
        } catch (Exception e){
            System.debug('### Other Exception--> ' + e.getMessage());
        }

        for (AggregateResult ar : lstLeads){
            System.debug('Activity__c :' + ar.get('Activity__c'));
            System.debug('On Time: ' + ar.get('expr0'));
            System.debug('Overdue: ' + ar.get('expr1'));
            System.debug('Urgent: '  + ar.get('expr2'));

            if (ar.get('Activity__c') == 'VN'){
                countVN_Urg = countVN_Urg + Integer.valueOf(ar.get('expr2'));
                countVN_OT  = countVN_OT  + Integer.valueOf(ar.get('expr0'));
                countVN_OV  = countVN_OV  + Integer.valueOf(ar.get('expr1')); 
            }
            else if (ar.get('Activity__c') == 'VO'){ 
                countVO_Urg = countVO_Urg + Integer.valueOf(ar.get('expr2'));
                countVO_OT  = countVO_OT  + Integer.valueOf(ar.get('expr0'));
                countVO_OV  = countVO_OV  + Integer.valueOf(ar.get('expr1'));  
            }
            else if (ar.get('Activity__c') == 'APV') { 
                countAPV_Urg = countAPV_Urg + Integer.valueOf(ar.get('expr2'));
                countAPV_OT  = countAPV_OT  + Integer.valueOf(ar.get('expr0'));
                countAPV_OV  = countAPV_OV  + Integer.valueOf(ar.get('expr1')); 
            }
            else{
                countOther_Urg = countOther_Urg + Integer.valueOf(ar.get('expr2'));
                countOther_OT  = countOther_OT  + Integer.valueOf(ar.get('expr0'));
                countOther_OV  = countOther_OV  + Integer.valueOf(ar.get('expr1'));
            }
            countSubTotal++;
        }
            
        for (String priority : priorityLevels){
            LeadMetricsDataWrapper lmd = new LeadMetricsDataWrapper();
           
            if (priority == LEAD_PRIORITY_OVERDUE) {
                lmd.className   = 'traffic-light red-light';
                lmd.priority    = System.Label.LeadAssignmentOverdue;
                lmd.priorityName= priority;
                lmd.vnCount     = countVN_OV;
                lmd.voCount     = countVO_OV;
                lmd.apvCount    = countAPV_OV;
                lmd.otherCount  = countOther_OV;
                lmd.subTotalCount   = countVN_OV + countVO_OV + countAPV_OV + countOther_OV;
            } else if (priority == LEAD_PRIORITY_URGENT) {
                lmd.className = 'traffic-light amber-light';
                lmd.priority    = System.Label.LeadAssignmentUrgent;
                lmd.priorityName= priority;
                lmd.vnCount     = countVN_Urg;
                lmd.voCount     = countVO_Urg;
                lmd.apvCount    = countAPV_Urg;
                lmd.otherCount  = countOther_Urg;
                lmd.subTotalCount   = countVN_Urg + countVO_Urg + countAPV_Urg + countOther_Urg;
            } else {
                lmd.className   = 'traffic-light green-light';
                lmd.priority    = System.Label.LeadAssignmentOnTime;
                lmd.priorityName= priority;
                lmd.vnCount     = countVN_OT;
                lmd.voCount     = countVO_OT;
                lmd.apvCount    = countAPV_OT;
                lmd.otherCount  = countOther_OT;
                lmd.subTotalCount   = countVN_OT + countVO_OT + countAPV_OT + countOther_OT;
            }
            leadMetricsData.add(lmd);
        }    
        
        
        System.debug('leadMetricsData: ' + leadMetricsData);
        return leadMetricsData;
    } 
    

}
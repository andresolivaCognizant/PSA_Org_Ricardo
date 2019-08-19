public without sharing class LMAContainerController {
	
	static final String LEAD_PRIORITY_ONTIME = 'On Time';
	static final String LEAD_PRIORITY_URGENT = 'Urgent';
	static final String LEAD_PRIORITY_OVERDUE = 'Overdue';
	static final String LEAD_PRIORITY_ALL = 'All';
	
	class leadCounts {
		
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
	
	@AuraEnabled
	public static List<leadCounts> getUserLeadCounts() {
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
     
     
     
     /*
     * @Method          :   setTransferRecords
     * @Author          :   Rubén Fernandez Lopez
     * @Created         :   26/01/2018
     * @Description     :   Transfer selected records to new Owner.
     * @Params          :   sObjectType(String): Type of Object.
     * @Returns         :   string: list of fields to get from the object.
     */	
	
	@AuraEnabled
	public static boolean setTransferRecords(String lstRecordsId, String sOwnerID){
        System.debug('Start of LMAContainerController.setTransferRecords...');
		boolean bResult = false;
		system.debug('setTransferRecords ' + lstRecordsId + ' | ' + sOwnerID);
		List<String> selectedIdsList = new List<String>();
		if(lstRecordsId!=null && sOwnerID != null){
			//Object[] listToSave = (Object[])JSON.deserializeUntyped(lstRecordsId);
			List<LeadIds> c = (List<LeadIds>)JSON.deserializeStrict(lstRecordsId,List<LeadIds>.class);
			system.debug('setTransferRecords.values : ' + c);
			if(c.size()>0){         
			    for (LeadIds sId : c) {
			    	system.debug('setTransferRecords.values : ' + string.valueof(sId.value));
			        selectedIdsList.add(string.valueof(sId.value) );
			    }
			}
			
			List<Lead> lRecords = new List<Lead>([SELECT Id, OwnerId FROM Lead where Id IN :selectedIdsList]);
			
			for(Lead obj : lRecords){
				system.debug('setTransferRecords.obj.OwnerId : ' + sOwnerID);
				obj.OwnerId = sOwnerID;
			}
			System.debug('lRecords: ' + lRecords);
			if(!lRecords.isEmpty()){
				try{
					update lRecords;
					bResult = true;
				}catch(Exception e){
					system.debug('setTransferRecords.Update Error: ' + e.getMessage());
				}
			}

		}else{
            System.debug('setTransferRecords.Param null or empty.');
		}
		System.debug('setTransferRecords.bResult' + bResult);
		return bResult;
	}
	public class LeadIds {
    	public String value;
	}
    
	@AuraEnabled
	public static String getUserPortalRole() {
		System.debug('Start of DealerPortalThemeController.getUserPortalRole...');
		
        User uri = new User();
        List<UserRole> upr = new List<UserRole>();
        String portalRole;
        String currentUserId = UserInfo.getUserID();
        uri = [SELECT UserRoleId, Profile.Name FROM User WHERE Id = :currentUserId LIMIT 1];
        System.debug('userRoleId: ' + uri.userRoleId);
        
        // profiles for full salesforce license users that should be considered managers
        Set<String> setP = new Set<String>{
            'CEC_Dealer_Int',
            'RMCD'
        };

        if (setP.contains(uri.Profile.Name)) {
            return 'Manager';
        }
        
        upr = [SELECT PortalRole FROM UserRole WHERE Id = :uri.userRoleId LIMIT 1];

        if (upr.isEmpty()) {
            return 'Worker';
        }

        portalRole = upr.get(0).PortalRole;

        System.debug('portalRole: ' + upr.get(0).PortalRole);
        if (upr.get(0).portalRole == null ) {
            portalRole='Worker';
        } else {
            if (portalRole.indexOf('Placa')>=0){
                portalRole='RMCD';
            }
        }
        
        System.debug('return: ' + portalRole);
		return portalRole;
		//return 'Manager';
	}
}
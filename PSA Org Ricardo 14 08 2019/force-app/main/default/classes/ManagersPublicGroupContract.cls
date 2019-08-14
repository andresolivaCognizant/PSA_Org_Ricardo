/*
*   @Class : ManagersPublicGroupContract
*
*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
*   @Created        :   07 Jun 2018
*   @Description    :   To manage public groups contract

*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Developer            Date                     Description
*	   Raul Barba			07 Jun 2018				 Creation.	
*   ----------------------------------------------------------------------------------------------------------------------------
*/
public class ManagersPublicGroupContract {
    
    
    /*
     * @Method          :   createPublicGroup
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   07 Jun 2018
     * @Description     :   Call the actions that handle the creation of public groups before update.
     * @Params          :   List<Account> records.
     * @Returns         :   List<Account> records updated
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
    public static List<Account> createPublicGroup(List<Account> lAccounts){
        List<Group> groups = new List<Group>();
        Group tempGroup;
        Id dealerType = Schema.SObjectType.ACCOUNT.getRecordTypeInfosByDeveloperName().get('Account_DealerPartner').getRecordTypeId();
        Map<String, List<account>> accGroupContract = new Map<String, List<account>>();
        String tempNumber = '';
        
        for(Account account : lAccounts){
        	tempNumber = '';
            if(shouldCreatePublicGroup(account, dealerType)){
                if((account.VNContractNumber__c != null) &&  account.TECH_VNContractActive__c){
                	tempNumber = 'CONTRACT_' + account.VNContractNumber__c + '_APEX';
                }else if((account.RAContractNumber__c != null) &&  account.TECH_RAContractActive__c){
                    tempNumber = 'CONTRACT_' + account.RAContractNumber__c + '_APEX';
                }else if((account.AgentContractNumber__c != null) &&  account.TECH_AgentContractActive__c){
                	tempNumber = 'CONTRACT_' + account.AgentContractNumber__c + '_APEX';
                }
                if(tempNumber != ''){
                	if(accGroupContract.containsKey(tempNumber)){
                		accGroupContract.get(tempNumber).add(account);
                	}else{
                		accGroupContract.put(tempNumber, new List<Account>());
                		accGroupContract.get(tempNumber).add(account);
                	}
                }
            }
        }
        
        
        Map<String, Group> mapGroupNames = new Map<String, Group>();
		for (Group t : [select id, name from Group where name in :accGroupContract.keySet()]) {
		    mapGroupNames.put(t.name,t);
		}
		
		List<Account> accUpdated = new List<Account>();
		List<Group> groupsFinal = new List<Group>();
        
        for(String groupName : accGroupContract.keySet()){
        	system.debug(accGroupContract.get(groupName));
        	if(mapGroupNames.containsKey(groupName)){
        		groupsFinal.add(mapGroupNames.get(groupName));
        	}else{
        		tempGroup = new Group(Name = (groupName));
	        	groups.add(tempGroup);
	        	groupsFinal.add(tempGroup);
        		system.debug(groupsFinal);
        		
        	}
        }
        Insert groups;  
        system.debug(accGroupContract);
        system.debug(groupsFinal);
        for(Group groupFinal : groupsFinal){
    		for(account acc : accGroupContract.get(groupFinal.Name)){
    			if(acc.TECH_PublicGroupsContract__c == null){
    				acc.TECH_PublicGroupsContract__c = groupFinal.id;
    				accUpdated.add(acc);
    			}else if(!acc.TECH_PublicGroupsContract__c.Contains(groupFinal.id) && (acc.TECH_PublicGroupsContract__c.length() < 200)){
    				acc.TECH_PublicGroupsContract__c = acc.TECH_PublicGroupsContract__c + ';' + groupFinal.id;
    				accUpdated.add(acc);
    			}
    		
    		}
        }     
        
        return accUpdated; 
    }
    
    /*
     * @Method          :   shouldCreatePublicGroup
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   07 Jun 2018
     * @Description     :   Detect if the account have to create a new public group.
     * @Params          :   Account and dealer record type id.
     * @Returns         :   Boolean
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
    public static Boolean shouldCreatePublicGroup(Account account, id dealerType){
        if(account.IsPartner && (account.RecordTypeId == dealerType)
           && (((account.VNContractNumber__c != null) &&  account.TECH_VNContractActive__c) 
           || ((account.RAContractNumber__c != null) &&  account.TECH_RAContractActive__c)
           || ((account.AgentContractNumber__c != null) &&  account.TECH_AgentContractActive__c))
           ){
            return true;
        }else{
            return false;
        }
    }
   
    /*
     * @Method          :   PopulatedPublicGroup
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   07 Jun 2018
     * @Description     :   Populated Public Group before insert the partner users.
     * @Params          :   List<User> records.
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
    public static void PopulatedPublicGroup(List<User> lUsers){
        Id dealerType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account_DealerPartner').getRecordTypeId();
        List<GroupMember>lGroupMember =new List<GroupMember>();
        String[] groups;
        for(User us: lUsers){
            if(shouldAddToPublicGroup(us, dealerType)){
                groups = us.Contact.Account.TECH_PublicGroupsContract__c.split(';');
                for(String gid : groups){
                    GroupMember gm= new GroupMember(); 
                    gm.GroupId=gid;
                    gm.UserOrGroupId = us.id;
                    lGroupMember.add(gm);
                }
            }
        }
        
        insert lGroupMember;      
    }

    
    /*
     * @Method          :   shouldAddToPublicGroup
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   07 Jun 2018
     * @Description     :   Detect if the sales Manager user have to bee add to a public group.
     * @Params          :   User.
     * @Returns         :   Boolean
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
    public static Boolean shouldAddToPublicGroup(User user, id dealerType){
       // if((user.ContactID != null) && shouldCreatePublicGroup(user.Contact.Account, dealerType)
       //   && (user.profile.Name == 'Sales_Manager') && (user.Contact.Account.TECH_PublicGroupsContract__c != null)){
       if((user.ContactID != null) && (user.Contact.Account.RecordTypeId == dealerType)
          && user.Contact.Account.IsPartner && (user.Contact.Account.TECH_PublicGroupsContract__c != null)
          && (user.profile.UserLicense.name == 'Partner Community') && user.IsActive){
            return true;
        }else{
            return false;
        }
    }
}
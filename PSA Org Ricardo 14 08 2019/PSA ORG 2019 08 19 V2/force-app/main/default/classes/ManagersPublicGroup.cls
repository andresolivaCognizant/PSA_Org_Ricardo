/*
*   @Class : ManagersPublicGroup
*
*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
*   @Created        :   22 feb 2018
*   @Description    :   To manage public groups

*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Developer            Date                     Description
*	   Raul Barba			22 feb 2018				 Creation.	
*   ----------------------------------------------------------------------------------------------------------------------------
*/
public class ManagersPublicGroup {
    
    
    /*
     * @Method          :   createPublicGroup
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   20 feb 2018
     * @Description     :   Call the actions that handle the creation of public groups before update.
     * @Params          :   List<Account> records.
     * @Returns         :   List<Account> records vn principal site updated
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
    public static List<Account> createPublicGroup(List<Account> lAccounts){
        List<Group> groups = new List<Group>();
        Group tempGroup;
        Id dealerType = Schema.SObjectType.ACCOUNT.getRecordTypeInfosByDeveloperName().get('Account_DealerPartner').getRecordTypeId();
        Map<String, account> accGroup = new Map<String, account>();
        Map<Id, Account> mapLAccounts = new Map<Id, Account>();
        
        for(Account account : lAccounts){
            mapLAccounts.put(account.Id, account);
            if(shouldCreatePublicGroup(account, dealerType)){
                if(account.TECH_PublicGroups__c == null){
                    if(account.Country__c != null){
                    	tempGroup = new Group(Name = ('DEALER_' + account.Country__c + '_' + account.SiteGeoIdPK__c + '_APEX'));
                    	groups.add(tempGroup);
                    	accGroup.put(tempGroup.Name, account);
                    }else if(account.BillingCountry != null){
                        tempGroup = new Group(Name = ('DEALER_' + account.BillingCountry + '_' + account.SiteGeoIdPK__c + '_APEX'));
                    	groups.add(tempGroup);
                    	accGroup.put(tempGroup.Name, account);
                    }
                }
            }
        }
        Insert groups;
        Account tempAcc;
        List<Account> accUpdated = new List<Account>();
        for(Group gro : groups){
            tempAcc = accGroup.get(gro.Name);
            if(tempAcc.TECH_PublicGroups__c == null){
                tempAcc.TECH_PublicGroups__c = gro.id;
                accUpdated.add(tempAcc);
            }
        }
        
        
        List<Account> relatedAccounts = new List<Account>();
        
        for(Account acc: addLink(lAccounts, dealerType,addVNContract(lAccounts, dealerType))){
            if(!mapLAccounts.containsKey(acc.Id)){
                relatedAccounts.add(acc);
            }else{
                mapLAccounts.get(acc.Id).TECH_PublicGroups__c = acc.TECH_PublicGroups__c;
            }
        }
        update relatedAccounts;
        
        return accUpdated; 
    }
    
    /*
     * @Method          :   shouldCreatePublicGroup
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   20 feb 2018
     * @Description     :   Detect if the account have to create a new public group.
     * @Params          :   Account and dealer record type id.
     * @Returns         :   Boolean
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
    public static Boolean shouldCreatePublicGroup(Account account, id dealerType){
        if(account.IsPartner && account.TECH_VNContractActive__c && account.VNPrincipalSite__c 
           && (account.VNContractNumber__c != null) && (account.SiteGeoIdPK__c != null) 
           && (account.RecordTypeId == dealerType)){
            return true;
        }else{
            return false;
        }
    }
    
    /*
     * @Method          :   shouldNotCreatePublicGroup
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   28 May 2018
     * @Description     :   Detect if the account could be a subscriber.
     * @Params          :   Account and dealer record type id.
     * @Returns         :   Boolean
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
    public static Boolean shouldNotCreatePublicGroup(Account account, id dealerType){
        if(account.IsPartner && account.TECH_VNContractActive__c && !account.VNPrincipalSite__c 
           && (account.VNContractNumber__c != null)
           && (account.RecordTypeId == dealerType)){
            return true;
        }else{
            return false;
        }
    }
    
    /*
     * @Method          :   addVNContract
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   21 feb 2018
     * @Description     :   Update the account with the same VNContract number.
     * @Params          :   List<Account> records and dealer record type id.
     * @Returns         :   Map<Id,Account> records
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
    public static Map<Id, Account> addVNContract(List<Account> lAccounts, id dealerType){
        List<Account> vnAccounts = new List<Account>();
        Account notgruop;
        Map<Id, Account> vnAccountsUpdate = new Map<Id, Account>();
        Map<String,String> mapVN = new Map<String,String>();
        Map<String,Account> mapVNNotPrincipal = new Map<String,Account>();
        for(Account account : lAccounts){
            if(shouldCreatePublicGroup(account, dealerType)){
                mapVN.put(account.VNContractNumber__c, account.TECH_PublicGroups__c);
            }else if(shouldNotCreatePublicGroup(account, dealerType)){
                mapVNNotPrincipal.put(account.VNContractNumber__c, account);
            }
        }
        vnAccounts = [select id, TECH_PublicGroups__c, RecordType.DeveloperName, isPartner, 
                      VNPrincipalSite__c, TECH_VNContractActive__c, VNContractNumber__c
                      from Account where isPartner = true 
                      and RecordType.DeveloperName = 'Account_DealerPartner' and VNPrincipalSite__c = false  
                      and TECH_VNContractActive__c = true and VNContractNumber__c in :mapVN.keySet()];
        for(Account account : vnAccounts){
            if(account.TECH_PublicGroups__c == null){
                account.TECH_PublicGroups__c = mapVN.get(account.VNContractNumber__c);
                vnAccountsUpdate.put(account.id, account);
            }else if(!account.TECH_PublicGroups__c.Contains(mapVN.get(account.VNContractNumber__c)) && (account.TECH_PublicGroups__c.length() < 200)){
                account.TECH_PublicGroups__c = account.TECH_PublicGroups__c + ';' + mapVN.get(account.VNContractNumber__c);
                vnAccountsUpdate.put(account.id, account);
            }
        }
        
        //Not to create Public Group
        vnAccounts = [select id, TECH_PublicGroups__c, RecordType.DeveloperName, isPartner, 
                      VNPrincipalSite__c, TECH_VNContractActive__c, VNContractNumber__c
                      from Account where isPartner = true 
                      and RecordType.DeveloperName = 'Account_DealerPartner' and VNPrincipalSite__c = true  
                      and TECH_VNContractActive__c = true and VNContractNumber__c in :mapVNNotPrincipal.keySet()];
        for(Account account : vnAccounts){
        	notgruop = mapVNNotPrincipal.get(account.VNContractNumber__c);
            if(notgruop.TECH_PublicGroups__c == null){
                notgruop.TECH_PublicGroups__c = account.TECH_PublicGroups__c;
                vnAccountsUpdate.put(notgruop.id, notgruop);
            }else if(account.TECH_PublicGroups__c != null && !notgruop.TECH_PublicGroups__c.Contains(account.TECH_PublicGroups__c) && (notgruop.TECH_PublicGroups__c.length() < 200)){
                notgruop.TECH_PublicGroups__c = notgruop.TECH_PublicGroups__c + ';' + account.TECH_PublicGroups__c;
                vnAccountsUpdate.put(notgruop.id, notgruop);
            }
        }
        return vnAccountsUpdate;
    }
    
    /*
     * @Method          :   addLink
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   21 feb 2018
     * @Description     :   Update the account related with the PartnerAccountLink__c.
     * @Params          :   List<Account> records and dealer record type id.
     * @Returns         :   List<Account> records
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
    public static List<Account> addLink(List<Account> lAccounts, id dealerType, Map<Id, Account> mapVNAccounts){
        List<PartnerAccountLink__c> links = new List<PartnerAccountLink__c>();
        Map<id,String> mapLink = new Map<id,String>();
        Map<id,String> mapLinkNotPrincipal = new Map<id,String>();
        for(Account account : lAccounts){
            if(shouldCreatePublicGroup(account, dealerType)){
                mapLink.put(account.id, account.TECH_PublicGroups__c);
            }else{
                mapLinkNotPrincipal.put(account.id, account.TECH_PublicGroups__c);
            }
        }
        Account accTemp;
        List<Account> linkAccounts = new List<Account>();
        links = [select SubscriberId__r.TECH_PublicGroups__c, ProviderId__r.Id, SubscriberId__r.isPartner, SubscriberId__r.RecordType.DeveloperName
                        from PartnerAccountLink__c 
                        where ProviderId__r.Id in :mapLink.keySet() and SubscriberId__r.isPartner = true 
                      and SubscriberId__r.RecordType.DeveloperName = 'Account_DealerPartner'];
          for(PartnerAccountLink__c part : links){
              if(mapVNAccounts.containsKey(part.SubscriberId__r.Id)){
                  accTemp = mapVNAccounts.remove(part.SubscriberId__r.Id);
              }else{
                 accTemp = part.SubscriberId__r;
              }
              if(accTemp.TECH_PublicGroups__c  == null){
                    accTemp.TECH_PublicGroups__c  = mapLink.get(part.ProviderId__r.Id);
              }else if(!accTemp.TECH_PublicGroups__c.Contains(mapLink.get(part.ProviderId__r.Id)) && (accTemp.TECH_PublicGroups__c.length() < 200)){
                    accTemp.TECH_PublicGroups__c  = accTemp.TECH_PublicGroups__c  + ';' + mapLink.get(part.ProviderId__r.Id);
              }
              linkAccounts.add(accTemp);
         }
         
         //Not to create Public Group
         links = [select SubscriberId__r.TECH_PublicGroups__c, ProviderId__r.Id, SubscriberId__r.isPartner, SubscriberId__r.RecordType.DeveloperName,
         ProviderId__r.TECH_PublicGroups__c, SubscriberId__r.Id, ProviderId__r.isPartner, ProviderId__r.RecordType.DeveloperName,
         ProviderId__r.VNContractNumber__c ,ProviderId__r.VNPrincipalSite__c ,ProviderId__r.TECH_VNContractActive__c, ProviderId__r.SiteGeoIdPK__c
                        from PartnerAccountLink__c 
                        where SubscriberId__r.Id in :mapLinkNotPrincipal.keySet() and SubscriberId__r.isPartner = true 
                      and SubscriberId__r.RecordType.DeveloperName = 'Account_DealerPartner' and ProviderId__r.isPartner = true 
                      and ProviderId__r.RecordType.DeveloperName = 'Account_DealerPartner' and  ProviderId__r.TECH_VNContractActive__c = true
                      and ProviderId__r.VNPrincipalSite__c = true and ProviderId__r.SiteGeoIdPK__c != null and ProviderId__r.VNContractNumber__c != null];        
          for(PartnerAccountLink__c part : links){
              if(mapVNAccounts.containsKey(part.SubscriberId__r.Id)){
                  accTemp = mapVNAccounts.remove(part.SubscriberId__r.Id);
              }else{
                 accTemp = part.SubscriberId__r;
              }
              if(accTemp.TECH_PublicGroups__c  == null){
                    accTemp.TECH_PublicGroups__c  = part.ProviderId__r.TECH_PublicGroups__c;
              }else if(!accTemp.TECH_PublicGroups__c.Contains(part.ProviderId__r.TECH_PublicGroups__c) && (accTemp.TECH_PublicGroups__c.length() < 200)){
                    accTemp.TECH_PublicGroups__c  = accTemp.TECH_PublicGroups__c  + ';' + part.ProviderId__r.TECH_PublicGroups__c;
              }
              linkAccounts.add(accTemp);
         }
         
        linkAccounts.addAll(mapVNAccounts.values());
        return linkAccounts;
    }
    
    
    /*
     * @Method          :   PopulatedPublicGroup
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   22 feb 2018
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
                groups = us.Contact.Account.TECH_PublicGroups__c.split(';');
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
	 * @Created         :   22 feb 2018
     * @Description     :   Detect if the sales Manager user have to bee add to a public group.
     * @Params          :   User.
     * @Returns         :   Boolean
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
    public static Boolean shouldAddToPublicGroup(User user, id dealerType){
        if((user.ContactID != null) && shouldCreatePublicGroup(user.Contact.Account, dealerType)
          && (user.profile.Name == 'Sales_Manager') && (user.Contact.Account.TECH_PublicGroups__c != null)){
       //if((user.ContactID != null) && (user.Contact.Account.RecordTypeId == dealerType)
       //   && user.Contact.Account.IsPartner && (user.Contact.Account.TECH_PublicGroups__c != null)
       //   && (user.profile.UserLicense.name == 'Partner Community') && user.IsActive){
            return true;
        }else{
            return false;
        }
    }
}
public class ManualSharingProcess {
	
	private final static Id RT_CONTACT_PARTNER              = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('PartnerUser').getRecordTypeId();

	/*
	 * @Method          :   ManualSharing
	 * @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
	 * @Created         :   23 feb 2018
	 * @Description     :   In order to give access via Manual Sharing.
	 * @Params          :   Map of accounts by user/group to share.
	 * @Returns         :   Boolean. True if needs to be shared. False by default.
	 */	
	public static Boolean ManualSharing(map<Id,List<id>> mapGrantAccess) {
		Boolean isSharing                           = false;
		List<sObject> lSObjectToShare               = new List<sObject>();
		
		for(Id i : mapGrantAccess.keySet()){
			if(i.getSObjectType() == Schema.Account.getSObjectType()){ 
				for(Id idUserOrGroup : mapGrantAccess.get(i)){ 
					AccountShare accShr             = new AccountShare();
					accShr.AccountId                = i;
					accShr.UserOrGroupId            = idUserOrGroup;
					accShr.AccountAccessLevel       = 'Edit';
					accShr.RowCause                 = Schema.AccountShare.RowCause.Manual;
					// US 1800 BEGIN
					//accShr.OpportunityAccessLevel = 'Read';
					accShr.OpportunityAccessLevel   = 'None';
					// US 1800 END          
					lSObjectToShare.add(accShr);
					isSharing                       = true;
				}

			}else if(i.getSObjectType() == Schema.Opportunity.getSObjectType()){ 
				for(Id idUserOrGroup : mapGrantAccess.get(i)){
					OpportunityShare oppShr         = new OpportunityShare();
					oppShr.OpportunityId            = i;
					oppShr.UserOrGroupId            = idUserOrGroup;

					/* BEGIN - Manuel Medina - C1STAGILE-9664 - 14052019 */
					//oppShr.OpportunityAccessLevel   = 'Read';
					oppShr.OpportunityAccessLevel   = 'Edit';
					/* END - Manuel Medina - 14052019 */

					oppShr.RowCause                 = Schema.OpportunityShare.RowCause.Manual;
					lSObjectToShare.add(oppShr);
					isSharing                       = true;
				}
				
			}else if(i.getSObjectType() == Schema.Lead.getSObjectType()){ 
				for(Id idUserOrGroup : mapGrantAccess.get(i)){
					LeadShare leadShr               = new LeadShare();
					leadShr.LeadId                  = i;
					leadShr.UserOrGroupId           = idUserOrGroup;
					leadShr.LeadAccessLevel         = 'Edit';
					leadShr.RowCause                = Schema.LeadShare.RowCause.Manual;
					lSObjectToShare.add(leadShr);
					isSharing                       = true;
				}
			}
		}
		
		try{
			Database.insert(lSObjectToShare,true);
			
		}catch(DMLexception e) {
			System.debug('ManualSharingProcess.ManualSharing ERROR -->' + e.getMessage() + ' Line: '+e.getLineNumber());
		} catch (Exception e){
			System.debug('ManualSharingProcess.ManualSharing ERROR --> ' + e.getMessage() + ' Line: '+e.getLineNumber());
		}
		
		return isSharing;
	}
	
	
	/*
	 * @Method          :   ManualSharingAsync
	 * @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
	 * @Created         :   23 feb 2018
	 * @Description     :   In order to give access via Manual Sharing asynchronous.
	 * @Params          :   -
	 * @Returns         :   -
	 */	
	public static void ManualSharingAsync(map<Id,List<id>> mapGrantAccess,List<sObject> sObjectsDelete) {
		List<sObject> lSObjectToShare               = new List<sObject>();
		
		for(Id i : mapGrantAccess.keySet()){
	
			if(i.getSObjectType() == Schema.Account.getSObjectType()){
				for(Id idUserOrGroup : mapGrantAccess.get(i)){
					AccountShare accShr             = new AccountShare();
					accShr.AccountId                = i;
					accShr.UserOrGroupId            = idUserOrGroup;
					accShr.AccountAccessLevel       = 'Edit';
					accShr.RowCause                 = Schema.AccountShare.RowCause.Manual;
					// US 1800 BEGIN
					//accShr.OpportunityAccessLevel = 'Read';
					accShr.OpportunityAccessLevel   = 'None';
					// US 1800 END          
					lSObjectToShare.add(accShr);
				}
				
			}else if(i.getSObjectType() == Schema.Opportunity.getSObjectType()){
				for(Id idUserOrGroup : mapGrantAccess.get(i)){
					OpportunityShare oppShr         = new OpportunityShare();
					oppShr.OpportunityId            = i;
					oppShr.UserOrGroupId            = idUserOrGroup;
					oppShr.OpportunityAccessLevel   = 'Read';
					oppShr.RowCause                 = Schema.OpportunityShare.RowCause.Manual;
					lSObjectToShare.add(oppShr);
				}
				
			}else if(i.getSObjectType() == Schema.Lead.getSObjectType()){
				for(Id idUserOrGroup : mapGrantAccess.get(i)){
					LeadShare leadShr               = new LeadShare();
					leadShr.LeadId                  = i;
					leadShr.UserOrGroupId           = idUserOrGroup;
					leadShr.LeadAccessLevel         = 'Edit';
					leadShr.RowCause                = Schema.LeadShare.RowCause.Manual;
					lSObjectToShare.add(leadShr);
				}
			}
		}
		
		if(!Test.isRunningTest()){
			InsertAsyncQueueable job = new InsertAsyncQueueable(lSObjectToShare,sObjectsDelete);
			ID jobID = System.enqueueJob(job);
		}
	}
	
	/*
	 * @Method          :   setRecordToShare
	 * @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
	 * @Created         :   23 feb 2018
	 * @Description     :   In order to give access via Manual Sharing with corresponding Public Groups.
	 *   ----------------------------------------------------------------------------------------------------------------------------
	 *      Modification Log :
	 *   ----------------------------------------------------------------------------------------------------------------------------
	 *     Developer            Date                     Description
	 *	   Sergio Lopez			27 nov 2018				 Modifying Sharing Model. Lead records will be shared with PublicGroup and 
	 * 													 Account, Opportunity, Quotes, Order, Users... records will be shared with PublicGroupContract 	
	 *     Ruben Fernandez      29 mar 2019              Merged with DEV1. Removed extra vars.
	 *   ----------------------------------------------------------------------------------------------------------------------------     */	    
	public static Map<Id, List<Id>> setRecordToShare(List<sObject> lSObjects){
		//id idRTpartnerUser = RT_CONTACT_PARTNER;
		Map<Id, List<Id>> mapRecordToShsare = new Map<Id, List<Id>>();
		List<Contact> lContacts             = new List<Contact>();
		List<Opportunity> lOpportunities    = new List<Opportunity>();
		List<Lead> lLeads                   = new List<Lead>();
		// US 1348 - BEGIN
		List<Account> lAccount              = new List<Account>();
		// US 1348 - END
	   
		for(sObject sObj : lSObjects){
			
			if(sObj.getSObjectType() == Schema.Contact.getSObjectType()){
				Contact cnt                 = (Contact) sObj;
				if(cnt.recordTypeId == RT_CONTACT_PARTNER){
					lContacts.add(cnt);
				}
			}else if(sObj.getSObjectType() == Schema.Lead.getSObjectType()){
				lLeads.add((Lead) sObj);
			}else if(sObj.getSObjectType() == Schema.Opportunity.getSObjectType()){
				lOpportunities.add((Opportunity) sObj);
			} 
			// US 1348 - BEGIN
			else if(sObj.getSObjectType() == Schema.Account.getSObjectType()){
				lAccount.add((Account) sObj);
			}
			// US 1348 - END
			
		}
		
		// US 1266 - INI
		/*if(!lContacts.isEmpty()){
			for(Contact c : [SELECT Id, AccountId, Account.TECH_PublicGroupsContract__c FROM Contact WHERE id IN :lContacts]){
				if(c.AccountId != null && c.Account.TECH_PublicGroupsContract__c!=null){
					mapRecordToShsare.put(c.AccountId, c.Account.TECH_PublicGroupsContract__c.split(';'));
				}
			}
		}*/
		// US 1266 - END
		// US 1348 - BEGIN
		if(!lAccount.isEmpty()){
			for(Account l : [SELECT Id, Owner.Contact.Account.TECH_PublicGroups__c, Owner.Contact.Account.TECH_PublicGroupsContract__c FROM Account WHERE id IN :lAccount AND Owner.Contact.Account.RecordType.Name = 'Dealer']){
						   	
				if(l.Owner.Contact.Account.TECH_PublicGroupsContract__c!=null){ 
					mapRecordToShsare.put(l.Id, l.Owner.Contact.Account.TECH_PublicGroupsContract__c.split(';'));
				}
				
				/*if(l.Owner.Contact.Account.TECH_PublicGroups__c!=null){
					mapRecordToShsare.put(l.Id, l.Owner.Contact.Account.TECH_PublicGroups__c.split(';'));
				}*/
				
			}
		}
		// US 1348 - END
		
		if(!lLeads.isEmpty()){
			for(Lead l : [SELECT Id, CalculatedPOS__c, CalculatedPOS__r.TECH_PublicGroups__c, CalculatedPOS__r.TECH_PublicGroupsContract__c, Customer__c, Owner.Type FROM Lead WHERE id IN :lLeads and Owner.Type != 'Queue']){
				if(l.CalculatedPOS__c != null && l.CalculatedPOS__r.TECH_PublicGroups__c!=null){
					// US 742 - INI
					if(l.CalculatedPOS__r.TECH_PublicGroupsContract__c!=null){ 
						mapRecordToShsare.put(l.CalculatedPOS__c, l.CalculatedPOS__r.TECH_PublicGroupsContract__c.split(';'));
					}
					// US 742 - END
					if(l.CalculatedPOS__r.TECH_PublicGroups__c!=null){
						mapRecordToShsare.put(l.Id, l.CalculatedPOS__r.TECH_PublicGroups__c.split(';'));
					}
					
					if(l.Customer__c != null && l.CalculatedPOS__r.TECH_PublicGroupsContract__c!=null){
						system.debug('## Customer: '+l.Customer__c);
						mapRecordToShsare.put(l.Customer__c, l.CalculatedPOS__r.TECH_PublicGroupsContract__c.split(';'));
					}
				}
			}
		}
		
		if(!lOpportunities.isEmpty()){
			for(Opportunity o : [SELECT Id, AccountId, CalculatedPOS__c, PartnerAccount.TECH_PublicGroups__c,PartnerAccountId, PartnerAccount.TECH_PublicGroupsContract__c, CalculatedPOS__r.TECH_PublicGroups__c, CalculatedPOS__r.TECH_PublicGroupsContract__c FROM Opportunity WHERE id IN :lOpportunities]){
				// US 1266 - INI
				if(o.CalculatedPOS__r.TECH_PublicGroupsContract__c!=null){ //|| o.PartnerAccount.TECH_PublicGroupsContract__c!=null){ 
					mapRecordToShsare.put(o.CalculatedPOS__c, o.CalculatedPOS__r.TECH_PublicGroupsContract__c.split(';'));
				}
				// Start change C1STRUN-1886
				if(o.PartnerAccountId!=null && o.PartnerAccount.TECH_PublicGroupsContract__c!=null){
					mapRecordToShsare.put(o.PartnerAccountId, o.PartnerAccount.TECH_PublicGroupsContract__c.split(';'));
				}
				// End change C1STRUN-1886
				if(o.CalculatedPOS__r.TECH_PublicGroups__c!=null){ // || o.PartnerAccount.TECH_PublicGroups__c!=null){ 
					mapRecordToShsare.put(o.Id, o.CalculatedPOS__r.TECH_PublicGroups__c.split(';')); 
				}
				// Start change C1STRUN-1886
					if(o.PartnerAccountId != null && o.PartnerAccount.TECH_PublicGroups__c!=null){
				  		mapRecordToShsare.put(o.Id, o.PartnerAccount.TECH_PublicGroups__c.split(';')); 
					}
				 // End change C1STRUN-1886
				 
				// US 1266 - END            
					if(o.AccountId!=null && o.CalculatedPOS__c != null && o.CalculatedPOS__r.TECH_PublicGroupsContract__c!=null){
					mapRecordToShsare.put(o.AccountId, o.CalculatedPOS__r.TECH_PublicGroupsContract__c.split(';'));
					mapRecordToShsare.put(o.Id, o.CalculatedPOS__r.TECH_PublicGroupsContract__c.split(';'));
					
				}
				// Start change C1STRUN-1886
				else if(o.AccountId!=null && o.PartnerAccountId != null && o.PartnerAccount.TECH_PublicGroupsContract__c!=null){
					mapRecordToShsare.put(o.AccountId, o.PartnerAccount.TECH_PublicGroupsContract__c.split(';'));
					mapRecordToShsare.put(o.Id, o.PartnerAccount.TECH_PublicGroupsContract__c.split(';'));
				}
				// End change C1STRUN-1886
			}
		}
		
		system.debug('## mapRecordToShsare: '+mapRecordToShsare);
		return mapRecordToShsare;
	   }
	
	
	/*
	 * @Method          :   setRecordToShare
	 * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   26 feb 2018
	 * @Description     :   In order to give access via Manual Sharing a sObject to a user.
	 * @Params          :   Id of the object to share and Id of the user.  
	 */	
	public static Map<Id, List<Id>> setRecordToShare(Id sObjectId, Id user){
		
		Map<Id, List<Id>> mapRecordToShsare = new Map<Id, List<Id>>();
		List<Id> groupsIds;
			
		for(User u : [SELECT Id, Contact.Account.TECH_PublicGroups__c, Contact.Account.TECH_PublicGroupsContract__c FROM User WHERE id = :user and ContactID != null and Contact.AccountId != null and (Contact.Account.TECH_PublicGroups__c != null or Contact.Account.TECH_PublicGroupsContract__c != null)]){
			groupsIds = new List<Id>();
			if(u.Contact.Account.TECH_PublicGroups__c != null){
				groupsIds.addAll(u.Contact.Account.TECH_PublicGroups__c.split(';'));
			}
			if(u.Contact.Account.TECH_PublicGroupsContract__c != null){
				groupsIds.addAll(u.Contact.Account.TECH_PublicGroupsContract__c.split(';'));
			}
			mapRecordToShsare.put(sObjectId, groupsIds);
		}
		
		
		return mapRecordToShsare;
		
	}
	

}
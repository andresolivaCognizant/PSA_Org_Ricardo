public with sharing class AccountSharing {
	
    private final static id RT_B2B_CONTACT 		= Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Label.RTContactB2B).getRecordTypeId();
    private final static id RT_ACCOUNTB2C 		= Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2C_PA').getRecordTypeId();
	private final static id RT_ACCOUNTB2B 		= Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
    

	/*
     * @Method          :   ManualSharingLeadConversion
     * @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   16 feb 2018
     * @Description     :   To get access to the related account of opportunities and leads I owned. It is used in Lead Conversion Process.
     * @Params          :   -
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */	
	
    public static void ManualSharingLeadConversion(List<sObject>  lSObjects) {
		
        List<AccountShare> lAccountShare = new List<AccountShare>();
        
		for(sObject oObject : lSObjects){
			
            AccountShare accShr  = new AccountShare();// Create new sharing object	
			
            if(oObject.getSObjectType() == Schema.Lead.getSObjectType()){
                
                Lead oLead = (Lead) oObject;	
				accShr.AccountId = oLead.Customer__c;//Set the ID of record being shared.
				accShr.UserOrGroupId = oLead.OwnerId;// Set the ID of user being granted access				
				accShr.AccountAccessLevel = 'Edit';// Set the access level.
				accShr.RowCause = Schema.AccountShare.RowCause.Manual;// Set rowCause to 'manual' for manual sharing.
				
                
				
		    }else if(oObject.getSObjectType() == Schema.Opportunity.getSObjectType()){
                
                Opportunity oOpportunity = (Opportunity) oObject;
						
				accShr.AccountId = oOpportunity.AccountId;//Set the ID of record being shared.
				accShr.UserOrGroupId = oOpportunity.OwnerId;// Set the ID of user being granted access				
				accShr.AccountAccessLevel = 'Edit';// Set the access level.
				accShr.RowCause = Schema.AccountShare.RowCause.Manual;// Set rowCause to 'manual' for manual sharing.

				
		    }
            lAccountShare.add(accShr);
		}
        
        try{
            System.debug('ACCOUNSHARE: '+lAccountShare);
            // The false parameter allows for partial processing if multiple records passed 
            Database.insert(lAccountShare,false);// Insert the sharing record. 

            
        }catch(DMLexception e) {
            System.debug('AccountSharing.ManualSharingLeadConversion ERROR -->' + e.getMessage() + ' Line: '+e.getLineNumber());
        } catch (Exception e){
            System.debug('AccountSharing.ManualSharingLeadConversion ERROR --> ' + e.getMessage() + ' Line: '+e.getLineNumber());
        }
	}
    /*
   * @Method          :   PGroupAccountSharingLeadConversion
   * @Author          :   Rubén Fernandez (DXC)
   * @Created         :   11 07 2018
   * @Description     :   Fix PRO issue. C1STRUN-425
   * @Params          :   Map <Id,Id> --> AccountId, LeadOwnerId
   * @Returns         :   -
   * @MaxSoqls        :   0
   * @MaxDmls         :   -
   */ 
  public static void PGroupAccountSharingLeadConversion(Map<Id, Id>  mapObjects){
    Map<Id, Id>  mapAuxObjects = new Map<Id, Id>();

    for(Id oId : mapObjects.keySet()){
      if(!ManualSharingProcess.ManualSharing(ManualSharingProcess.setRecordToShare(oId, mapObjects.get(oId)))){
        mapAuxObjects.put(oId, mapObjects.get(oId));
      }
    }
    if(!mapAuxObjects.isEmpty()){
      ManualAccountSharingLeadConversion(mapAuxObjects);
    }

  }


  /*
   * @Method          :   ManualAccountSharingLeadConversion
   * @Author          :   Rubén Fernandez (DXC)
   * @Created         :   11/07/2018
   * @Description     :   Fix PRO issue. C1STRUN-425
   * @Params          :   Map <Id,Id> --> AccountId, LeadOwnerId
   * @Returns         :   -
   * @MaxSoqls        :   0
   * @MaxDmls         :   1
   */ 
    
  @TestVisible
  private static void ManualAccountSharingLeadConversion(Map<Id, Id>  mapObjects) {
    System.debug('ManualAccountSharingLeadConversion');
    List<AccountShare> lSharing   = new List<AccountShare>();
    
    for(Id oId : mapObjects.keySet()){
      AccountShare accShare       = new AccountShare();                 // Create new sharing object  
      accShare.AccountId          = oId;                                // Set the ID of record being shared.
      accShare.UserOrGroupId      = mapObjects.get(oId);                // Set the ID of user being granted access       
      accShare.AccountAccessLevel = 'Edit';                             // Set the access level.
      accShare.RowCause           = Schema.AccountShare.RowCause.Manual;// Set rowCause to 'manual' for manual sharing.
      lSharing.add(accShare);
    }
    try{
        if(!lSharing.isEmpty())
          Database.insert(lSharing,false);
    }catch(DMLexception e) {
        System.debug('ManualAccountSharingLeadConversion DML Exception -->' + e.getMessage() + ' Line: '+e.getLineNumber());
    } catch (Exception e){
        System.debug('ManualAccountSharingLeadConversion Exception --> ' + e.getMessage() + ' Line: '+e.getLineNumber());
    }
  }      
    
    
    
    
    /*
     * @Method          :   revokeAccessByBrand
     * @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   13 Mar 2018
     * @Description     :   To revoke access on the account to all users linked to the brand.
     * @Params          :   map<Id,sObject> mapIdSobject
     * @Returns         :   void
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */	
    

    public static void revokeAccessByBrand(map<Id,sObject> mapUpdateSobject){
                
        List<AccountShare> lAShareToRemove			= new List<AccountShare>();
        Map<id,AccountShare> mapCopyAccountShare	= new Map<id,AccountShare>();
        Set<Id> setAccountToChangeOwner				= new Set<Id>();
        Set<Id> setAllUsers 						= new Set<Id>();
        Map<id,AccountShare> mapIdDSBrand 			= new Map<id,AccountShare>();
        Map<Id,AccountShare> mapIdAPBrand 			= new Map<id,AccountShare>();
        Map<Id,AccountShare> mapIdACBrand 			= new Map<id,AccountShare>();
		Set<Id> setIdsObject						= new Set<Id>();
        map<Id,Contact> mapIdB2BContact				= new map<Id,Contact>();
        Id idB2BAccount;
        List<Account> lB2Baccounts					= new List<Account>();
        List<Account> lAccountToUpdateOwner 		= new List<Account>();
        
        for(Id idKey : mapUpdateSobject.keySet()){
            if(idKey.getSObjectType() == Schema.Account.getSObjectType() && mapUpdateSobject.get(idKey).get('RecordTypeId') == RT_ACCOUNTB2C){
                setIdsObject.add(idKey);
            
            }/*else if(idKey.getSObjectType() == Schema.Contact.getSObjectType() && mapUpdateSobject.get(idKey).get('RecordTypeId') == RT_B2B_CONTACT){
                System.debug('##RM## 1');
 				if(mapUpdateSobject.get(idKey).get('AccountId')!=null)
                    System.debug('##RM## 2');
                    idB2BAccount = (Id) mapUpdateSobject.get(idKey).get('AccountId');
                	setIdsObject.add(idB2BAccount);
                	mapIdB2BContact.put(idB2BAccount,(Contact) mapUpdateSobject.get(idKey));
            }*/
        }
        System.debug('##RM## mapIdB2BContact'+mapIdB2BContact);
        System.debug('setIdsObject: '+setIdsObject);
        for(AccountShare a : [SELECT Account.RecordTypeId,AccountAccessLevel,CaseAccessLevel,ContactAccessLevel,OpportunityAccessLevel,Account.OwnerId,Account.DSAnonymization__pc,Account.APAnonymization__pc,Account.ACAnonymization__pc, AccountId, Id, UserOrGroupId 
                              FROM AccountShare 
                              WHERE AccountId IN : setIdsObject /*AND (Account.DSAnonymization__pc = TRUE OR Account.APAnonymization__pc = TRUE OR Account.ACAnonymization__pc =  TRUE)*/]){
            
                                  if(a.Account.recordtypeid == RT_ACCOUNTB2C && mapUpdateSobject.get(a.AccountId).get('DSAnonymization__pc') == true){
                                      mapIdDSBrand.put(a.id,a);//contains accountshare records that belong to DS brand and its should be removed.
                                      System.debug('##RM## 3');
                                  }/*else if(a.Account.recordtypeid == RT_ACCOUNTB2B && mapIdB2BContact.get(a.AccountId).DSAnonymization__c == true){
                                      mapIdDSBrand.put(a.id,a);//contains accountshare records that belong to DS brand and its should be removed.
                                  }*/
                                  
                                  if(a.Account.recordtypeid == RT_ACCOUNTB2C && mapUpdateSobject.get(a.AccountId).get('APAnonymization__pc') == true){
                                      System.debug('##RM## 4');
                                      mapIdAPBrand.put(a.id,a);//contains accountshare records that belong to AP brand and its should be removed.
                                  }/*else if(a.Account.recordtypeid == RT_ACCOUNTB2B && mapIdB2BContact.get(a.AccountId).APAnonymization__c == true){
                                      mapIdAPBrand.put(a.id,a);//contains accountshare records that belong to AP brand and its should be removed.
                                  }*/
                                  
                                  if(a.Account.recordtypeid == RT_ACCOUNTB2C && mapUpdateSobject.get(a.AccountId).get('ACAnonymization__pc') == true){
                                     System.debug('##RM## 5');
                                     mapIdACBrand.put(a.id,a);//contains accountshare records that belong to AC brand and its should be removed.
                                  }/*else if(a.Account.recordtypeid == RT_ACCOUNTB2B && mapIdB2BContact.get(a.AccountId).ACAnonymization__c == true){
                                     mapIdACBrand.put(a.id,a);//contains accountshare records that belong to AC brand and its should be removed.
                                  }*/
                                  
                                  setAllUsers.add(a.UserOrGroupId);
                                  if(a.Account.OwnerId != a.UserOrGroupId)
                                  	mapCopyAccountShare.put(a.id,a);// this is a copy of original accountshare before to change their owners.
                                  
        }
        
		map<Id,User> mapIdUser = new map<Id,User>([SELECT Id, brand__c FROM User WHERE id IN : setAllUsers]);
        System.debug('##RM## mapCopyAccountShare BEF: '+mapCopyAccountShare);
        for(Id idKeyDS : mapIdDSBrand.keySet()){
            
            if(mapIdUser.get(mapIdDSBrand.get(idKeyDS).UserOrGroupId)!=null && mapIdUser.get(mapIdDSBrand.get(idKeyDS).UserOrGroupId).brand__c == 'DS'){
                
                System.debug('DS: '+mapIdUser.get(mapIdDSBrand.get(idKeyDS).UserOrGroupId).brand__c);
                System.debug('DS key: '+idKeyDS);
                
                mapCopyAccountShare.remove(idKeyDS);//remove key in order to no create the accountshare record.
                
                if(mapIdDSBrand.get(idKeyDS).Account.OwnerId == mapIdDSBrand.get(idKeyDS).UserOrGroupId){
                    setAccountToChangeOwner.add(mapIdDSBrand.get(idKeyDS).AccountId);
                }else{
                    lAShareToRemove.add(mapIdDSBrand.get(idKeyDS));
                }
                    
            }
            
        }
        
        for(Id idKeyAC : mapIdACBrand.keySet()){
            if(mapIdUser.get(mapIdACBrand.get(idKeyAC).UserOrGroupId)!=null && mapIdUser.get(mapIdACBrand.get(idKeyAC).UserOrGroupId).brand__c == 'AC'){
               	
                System.debug('AC: '+mapIdUser.get(mapIdACBrand.get(idKeyAC).UserOrGroupId).brand__c);
                System.debug('AC key: '+idKeyAC);
                
                mapCopyAccountShare.remove(idKeyAC);//remove key in order to no create the accountshare record.
                
                if(mapIdACBrand.get(idKeyAC).Account.OwnerId == mapIdACBrand.get(idKeyAC).UserOrGroupId){
                    setAccountToChangeOwner.add(mapIdACBrand.get(idKeyAC).AccountId);
                }else{
                    lAShareToRemove.add(mapIdACBrand.get(idKeyAC));
                }
                    
            }
        }
        
        for(Id idKeyAP : mapIdAPBrand.keySet()){
            
            if(mapIdUser.get(mapIdAPBrand.get(idKeyAP).UserOrGroupId)!=null && mapIdUser.get(mapIdAPBrand.get(idKeyAP).UserOrGroupId).brand__c == 'AP'){
                
                System.debug('AP: '+mapIdUser.get(mapIdAPBrand.get(idKeyAP).UserOrGroupId).brand__c);
                System.debug('AP key: '+idKeyAP);
                
                mapCopyAccountShare.remove(idKeyAP);//remove key in order to no create the accountshare record.
                
                if(mapIdAPBrand.get(idKeyAP).Account.OwnerId == mapIdAPBrand.get(idKeyAP).UserOrGroupId){
                    setAccountToChangeOwner.add(mapIdAPBrand.get(idKeyAP).AccountId);
                }else{
                    lAShareToRemove.add(mapIdAPBrand.get(idKeyAP));
                }
                    
            }
            
        }
        
        try{
            
            
            System.debug('##RM## revokeAccessByBrand --- UPDATE OWNER:'+setAccountToChangeOwner);
            System.debug('##RM## mapCopyAccountShare AFT: '+mapCopyAccountShare);
            
            for(Id idKey : mapUpdateSobject.keySet()){
                if(idKey.getSObjectType() == Schema.Account.getSObjectType()){
                    if(setAccountToChangeOwner.contains(idKey)){
                        System.debug('##RM## CHANGE OWNER');
                        
                        Account oAccount = new Account(id=idKey,OwnerId = Label.API_User);
                        lAccountToUpdateOwner.add(oAccount);
                    }
                        
                    
                }/*else if(idKey.getSObjectType() == Schema.Contact.getSObjectType() && mapUpdateSobject.get(idKey).get('RecordTypeId') == RT_B2B_CONTACT){
                    System.debug('##RM## 6');
                    if(mapUpdateSobject.get(idKey).get('AccountId')!=null){
                        System.debug('##RM## 7');
                        Id idAccount = (Id) mapUpdateSobject.get(idKey).get('AccountId');
                        if(setAccountToChangeOwner.contains(idAccount)){
                            System.debug('##RM## 8');
                        	Account oAccount = new Account(id=idAccount,OwnerId = Label.API_User);
                            lB2Baccounts.add(oAccount);
                            Contact oContact = (Contact) mapUpdateSobject.get(idKey);
                            oContact.OwnerId = Label.API_User;
                    	}
                    }
                }*/
        	}
			
        	Database.update(lB2Baccounts,true);        
            Database.delete(lAShareToRemove,true);
        	Database.update(lAccountToUpdateOwner,true);
        
            for(AccountShare oASh : mapCopyAccountShare.values()){
                oASh.id = null;
            }
            
        	Database.insert(mapCopyAccountShare.values(),true);

        	
            
        }catch(DmlException e){
			System.debug('DmlException ERROR AccountSharing.revokeAccessByBrand -->' + e.getMessage() + ' Line: '+e.getLineNumber());
        }catch(Exception e){
            System.debug('Exception ERROR AccountSharing.revokeAccessByBrand-->' + e.getMessage() + ' Line: '+e.getLineNumber());
        }
      
                
    }
    

    
    
   
    
}
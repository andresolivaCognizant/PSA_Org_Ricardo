/*
*   @Class : SendEmailOwnerChanged.cls
*
*   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
*   @Created        :   
*   @Description    :   To send emails when the lead owner change.

*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Developer            Date                     Description
*      Ruben Moreno         4 jun 2018               ##RM 4/6/2018## delete lead manual sharing.
*      Ruben Moreno         19 jul 2018              to sent emails in several languages.
*      Sergio Lopez         16 aug 2018              Check EmailOptOut, the user can refuse to receive email  
*      C1STRUN-2356 		28 may 2019				 Insert lead Link...
*   ----------------------------------------------------------------------------------------------------------------------------
*/


global without sharing class SendEmailOwnerChanged {
    
    private static final String SALESMANAGER_PROFILE    = 'Sales_Manager';
    private static final String NAME_TEMPLATE           = 'ChangeOwner_';
    private static final string LEAD_COMPANY            = '{!Lead.Company}';
    private static final string LEAD_NAME               = '{!Lead.Name}';
    /** C1STRUN-2356 MODIFICATION **/
    private static final string LEAD_LINK               = '{!Lead.Link}';
    
    /** END RUN MODIFICATION **/

    private static final string QUOTE_PREFIX            = '00G';
    
    global static void sendEmail(List<Lead> lLeads, map<id,Lead> mapOldLeads){
        
        System.debug('************ START SEND EMAIL ****************');
        
        Integer iCont               = 0;
        List<String> lEmails        = new List<String>();
        List<Id> lIdOwners          = new List<Id>();
        List<Id> lIdOldOwner        = new List<Id>();
        List<Lead> lLeadsChanged    = new List<Lead>();
        Set<Id> setIdAccount        = new Set<Id>();
        Set<Id> setIdUser           = new Set<Id>();
        String sLanguage            = '';
        Id userOwner                    ;
        boolean isQueue             = false;
        for(Lead l : lLeads){
            System.debug('************ is QUEUE??: '+String.valueOf(l.ownerId).substring(0,3)+' = '+QUOTE_PREFIX);  
            if(l.ownerId != mapOldLeads.get(l.id).ownerid && mapOldLeads.get(l.id).ownerid != Label.TECH_WebToLead && QUOTE_PREFIX == String.valueOf(l.ownerId).substring(0,3)){
                if(!lIdOwners.contains(l.ownerId))
                    lIdOwners.add(l.ownerId);
                /*if(!lIdOldOwner.contains(mapOldLeads.get(l.id).ownerid))
lIdOldOwner.add(mapOldLeads.get(l.id).ownerid);*/
                lLeadsChanged.add(l);
                iCont += 1;
                isQueue = true;
            }else if(l.ownerId != mapOldLeads.get(l.id).ownerid && mapOldLeads.get(l.id).ownerid != Label.TECH_WebToLead && QUOTE_PREFIX != String.valueOf(l.ownerId).substring(0,3)){
                if(!lIdOwners.contains(l.ownerId))
                    lIdOwners.add(l.ownerId);
                if(!lIdOldOwner.contains(mapOldLeads.get(l.id).ownerid))
                    lIdOldOwner.add(mapOldLeads.get(l.id).ownerid);
                lLeadsChanged.add(l);
                iCont += 1;
            }
        }
        if(!isQueue){            
            for(User oUser :  [SELECT Id, EmailOptOut__c,ContactId,LanguageLocaleKey ,Contact.AccountId,Email,Profile.name,ManagerId,Manager.Email  FROM User WHERE id IN :lIdOwners]){
                System.debug('************oUser: '+oUser);
                //lEmails.add(oUser.Email);
                sLanguage = oUser.LanguageLocaleKey ;
                userOwner = oUser.id;
                
                if(oUser.EmailOptOut__c==false){
                    System.debug('************ EmailOptOut__c FALSE: ');
                    lEmails.add(oUser.Email);
                }
                
                if(oUser.ContactId != null/* && oUser.Profile.name != SALESMANAGER_PROFILE*/){
                    System.debug('************ COMMUNITIES USER: '+oUser);
                    setIdAccount.add(oUser.Contact.AccountId);
                }else if(oUser.ContactId == null && oUser.Profile.name != SALESMANAGER_PROFILE && oUser.ManagerId != null && oUser.Manager.Email!=null ){
                    System.debug('************ INTERNAL USER: '+oUser);
                    lEmails.add(oUser.Manager.Email);
                }
            }
            
            for(User oUser :  [SELECT Id, Contact.AccountId,Email,Profile.name FROM User WHERE Contact.AccountId IN :setIdAccount AND EmailOptOut__c = false AND isActive = true]){
                if(oUser.Profile.name == SALESMANAGER_PROFILE && !lEmails.contains(oUser.Email))
                    lEmails.add(oUser.Email);
            }
            
        }else{
            System.debug('************ QUEUE OWNER: '+lIdOwners);
            for(GroupMember grm : [SELECT Group.type,Groupid,Id,UserOrGroupId FROM GroupMember where Group.type = 'Queue' AND groupid IN :lIdOwners AND Group.DoesSendEmailToMembers = true]){
                if(grm.UserOrGroupId.getSobjectType() == Schema.User.getSObjectType())
                    System.debug('************ user contains in queue: '+grm.UserOrGroupId);
                setIdUser.add(grm.UserOrGroupId); 
            }
            
            for(User oUser :  [SELECT id,Email,LanguageLocaleKey FROM User WHERE id IN :setIdUser AND EmailOptOut__c = false AND isActive = true]){
                lEmails.add(oUser.Email);
                sLanguage = oUser.LanguageLocaleKey ;
                userOwner = oUser.id;
                
            }
            
        }
        System.debug('************ lEmails: '+lEmails);
        if(lEmails!=null && !lEmails.isEmpty() && !lLeadsChanged.isEmpty()){
            //building email message
            
            try{ 
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where DisplayName = :Label.DisplayNameOwea];
                
                if (owea!=null && !owea.isEmpty()) {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                
                //##RM 4/6/2018## ManualSharingProcess.ManualSharing(new map<Id,List<id>>{lLeadsChanged[0].id =>lIdOldOwner});
                System.debug('************ language: '+sLanguage);
                System.debug('************ lLeadsChanged: '+lLeadsChanged);
                System.debug('************lEmails: '+lEmails);
                
                
                //lLeadsChanged[0].email = lEmails[0];
                
                if(iCont == 1){
                    
                    List<EmailTemplate> lEmailTemplate = [SELECT ID,Body FROM EMAILTEMPLATE WHERE NAME = : 'ChangeOwner_'+sLanguage];
                    System.debug('************ lEmailTemplate: '+lEmailTemplate);
                    
                    String leadURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + lLeadsChanged[0].Id;
                    
                     /** C1STRUN- 2356 MODIFICATION **/

                    mail.setHtmlBody(lEmailTemplate[0].body.replace(LEAD_COMPANY,
					(lLeadsChanged[0].Company!=null)?lLeadsChanged[0].Company+', ':''+', ').replace(LEAD_NAME,
                    (lLeadsChanged[0].Firstname!=null)?lLeadsChanged[0].Firstname + lLeadsChanged[0].Lastname:'' + lLeadsChanged[0].Lastname).replace(LEAD_LINK,
							('<a href="' + leadURL + '">Open here</a>'))); 
                    
                    /** END RUN MODIFICATION **/
                    
                    /** Enforcing the Subject to fix C1STAGILE-10900 **/
                    mail.setSubject(lEmailTemplate[0].Subject);
                    /** ------------------------------------------- **/
                    
                    mail.setSaveAsActivity(false);
                    mail.setToAddresses(lEmails);
                    
                }else{
                    List<EmailTemplate> lEmailTemplate = [SELECT ID FROM EMAILTEMPLATE WHERE NAME = : 'ChangeOwnerMassive_'+sLanguage];
                    System.debug('************ lEmailTemplate: '+lEmailTemplate);
                    // mail.setTargetObjectId(userOwner);
                    mail.setTemplateId(lEmailTemplate[0].id);
                    mail.setSaveAsActivity(false);
                    mail.setToAddresses(lEmails);
                    
                }
                
                
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                String leadURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + lLeadsChanged[0].Id;
                
                System.debug('URL' + leadURL);
                System.debug('######## Sent to: '+lEmails);
                System.debug('######## Email Content: '+mail);
                System.debug('************ END SEND EMAIL ****************');
                
                
            }catch (Exception e){
                System.debug('SendEmailOwnerChanged.sendEmail ERROR --> ' + e.getMessage() + ' Line: '+e.getLineNumber());
            }
            
        }
        
    }
    
}
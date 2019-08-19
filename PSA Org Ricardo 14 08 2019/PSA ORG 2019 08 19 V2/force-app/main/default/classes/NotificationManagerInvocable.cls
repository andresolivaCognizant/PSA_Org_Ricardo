/*
-- - Name         : NotificationManagerInvocable
-- - Author       : Ruben Moreno Leyva
-- - Date         : 8/6/2018
-- - Description  : to manage notification delivery
--
-- - History:
-- - Date       Author  Version  Comments
-- -----------  -----   -------  ---------------------------------------
--   8/6/2018   RML     1.0      Creation
*/

global with sharing class NotificationManagerInvocable {
    
   
    // -----------------------------------------------------------------
    // INVOCABLE CLASS: PARAMS
    // -----------------------------------------------------------------
    
    
    global class PostRequest {

        @InvocableVariable(
            label           = 'Notification Name'
            description     = 'What notification is going to be sent'
            required        = true
        )
        global String notificationName;

        @InvocableVariable(
            label           = 'ObjectId'
            required        = true
        )
        global Id sObjId;
          
        @InvocableVariable(
            label           = 'OwnerCountry'
            required        = false
        )
        global string ownerCountry;
        
        @InvocableVariable(
            label           = 'OwnerId'
            required        = true
        )
        global string ownerId;
        
        @InvocableVariable(
            label           = 'OwnerEmail'
            required        = false
        )
        global string ownerEmail;


    }
    
    
    @InvocableMethod(
        label       = 'PB: Notification Manager'
        description = 'Send email notifications'
    )
    public static void checkNotificacionManager(List<PostRequest> requests){
        
        System.debug('##RM NM ##requests: '+requests);
        
        String notificationName 				= '';
        map<Id,id> mapAllIdOwner				= new map<Id,id>();
        map<Id,List<String>> mapIdOwnerToSent	= new map<Id,List<String>>();
        List<String> lCountriesNotAvailables 	= new List<String>();
        map<Id,String> mIdobjectCountry 		= new map<Id,String>();
        map<Id,String> mIdobjectEmail	 		= new map<Id,String>();
        
        
        for(PostRequest req : requests){
            
            notificationName = req.notificationName;
            if(req.ownerCountry!=null)                
            	mIdobjectCountry.put(req.sObjId,req.ownerCountry);
            	mapAllIdOwner.put(req.sObjId,req.OwnerId);
            	mIdobjectEmail.put(req.sObjId,req.OwnerEmail);

        }
        
        System.debug('##RM NM ##notificationName: '+notificationName);
        System.debug('##RM NM ##mIdobjectCountry: '+mIdobjectCountry);
        

        for(NotificationManager__mdt oItem : [Select Country__c, OpOutNotification__c,Label FROM NotificationManager__mdt WHERE NotificationName__c = : notificationName]){
            
            if(!oItem.Label.startsWith('TECH_') && oItem.OpOutNotification__c == true){
                lCountriesNotAvailables.add(oItem.Country__c);
            }
            
        }
        
                
        for(Id oKey : mIdobjectCountry.keyset()){
            
            if(lCountriesNotAvailables.isEmpty() || !lCountriesNotAvailables.contains(mIdobjectCountry.get(oKey)))
                mapIdOwnerToSent.put(oKey,new List<String>{mapAllIdOwner.get(oKey),mIdobjectEmail.get(oKey)});
                
        }
        
        System.debug('##RM NM ##lCountriesNotAvailables: '+lCountriesNotAvailables);
        System.debug('##RM NM ##mapIdOwnerToSent: '+mapIdOwnerToSent);
        
		if(!mapIdOwnerToSent.values().isEmpty())
            sendNotification(mapIdOwnerToSent,notificationName);

        
    }
    
    public static void sendNotification(map<Id,List<String>> mapIdsOwner, string notificationName){
        
        OrgWideEmailAddress[] owea 					= [select Id from OrgWideEmailAddress where DisplayName = :Label.DisplayNameOwea];
        EmailTemplate templateId 					= [Select id from EmailTemplate /*where name = :notificationName*/ LIMIT 1];
        List<Messaging.SingleEmailMessage> allmsg 	= new List<Messaging.SingleEmailMessage>();
        System.debug('##RM NM ## OWEA: '+owea);
        System.debug('##RM NM ## mapIdsOwner: '+mapIdsOwner);
        

        for(Id idItem : mapIdsOwner.keySet()){
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			if (owea!=null && !owea.isEmpty()) {
            	mail.setOrgWideEmailAddressId(owea.get(0).Id);
        	}
            
            mail.setTargetObjectId(mapIdsOwner.get(idItem)[0]);
            mail.setToAddresses(new List<String> {mapIdsOwner.get(idItem)[1]});
			//mail.setWhatId(idItem); --> NOT AVAILABLE FOR USERS
            //mail.setTemplateID(templateId.Id);
            mail.setTemplateId('00X0O000002ji35');
			mail.setSaveAsActivity(false); //--> NOT AVAILABLE FOR USERS           
            allmsg.add(mail);
            
            System.debug('##RM NM ## MAIL: '+mail);
            
        }
    
        
        try{
            
            Messaging.sendEmail(allmsg,TRUE);
            
        }catch(Exception e){
            System.debug('Exception ERROR NotificationManagerInvocable.sendNotification-->' + e.getMessage() + ' Line: '+e.getLineNumber());
        }
        	
        
        
        
    }

}
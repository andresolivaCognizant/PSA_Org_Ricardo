/*
-- - Name         : FlowSendEmailInvokable
-- - Author       : Sergio Lopez Calvo
-- - Date         : 05/03/2019
-- - Description  : to manage notification delivery
--
-- - History:
-- - Date        Author  Version  Comments
-- ------------  ------  -------  ---------------------------------------
--   05/03/2019  SLC     1.0      Creation
*/

global with sharing class FlowSendEmailInvokable {
    
   
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
            label           = 'OwnerBrand'
            required        = true
        )
        global string ownerBrand;
        
        @InvocableVariable(
            label           = 'OwnerId'
            required        = true
        )
        global string ownerId;

        @InvocableVariable(
            label           = 'ServiceAppointment'
            required        = true
        )
        global string serviceApp;

    }
        
    @InvocableMethod(
        label       = 'PB: Notification Invokable'
        description = 'Send email notifications'
    )

    public static void flowSendEmail(List<PostRequest> requests){
        
        System.debug('##requests: '+requests);
        
        String notificationName 				= '';
        String ownerBrand        				= '';
        String ownerId           				= '';
        String serviceApp        				= '';
                
        for(PostRequest req : requests){
            notificationName    = req.notificationName;
            ownerBrand          = req.ownerBrand;
            ownerId             = req.ownerId;
            serviceApp          = req.serviceApp;
        }
        
        System.debug('##notificationName: '+notificationName);
        System.debug('##ownerBrand: '+ownerBrand);
        System.debug('##ownerId: '+ownerId);
        System.debug('##serviceApp: '+serviceApp);
                
        sendNotification(notificationName,ownerBrand,ownerId,serviceApp);

    }

    public static void sendNotification(string notificationName, string ownerBrand, string ownerId, string serviceApp){

        String templName = notificationName + ' ' + ownerBrand;
        
        EmailTemplate templateId 					= [Select id from EmailTemplate where name = :templName LIMIT 1];

        User userInfo 					= [Select Id, Email, FirstName from User where id = :ownerId LIMIT 1];
        
        serviceApp = serviceApp.replace(';', ',');
        serviceApp = serviceApp.trim();

        if (serviceApp.substring(serviceApp.length() - 1,serviceApp.length()) == ','){
            serviceApp = serviceApp.substring(0,serviceApp.length() - 1);
        }

        System.debug('##serviceApp: '+serviceApp);

        set<Id> setIds = new set<Id>();
        
        String[] splitServiceApp = serviceApp.split(',');

        System.debug('##splitServiceApp: '+splitServiceApp);
                    
        for (Integer iteration=0;iteration < splitServiceApp.size();iteration++){
            setIds.add(splitServiceApp[iteration]);
        }        

        System.debug('##setIds: '+setIds);

        List<ServiceAppointment> lSApp = [SELECT Id, AppointmentNumber FROM ServiceAppointment WHERE Id IN :setIds ORDER BY AppointmentNumber];

        System.debug('##lSApp: '+lSApp);

        // Step 0: Create a master list to hold the emails we'll send
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    
        // Step 1: Create a new Email
        Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
    
        // Step 2: Set list of people who should get the email
        List<String> sendTo = new List<String>();
        //sendTo.add(myContact.Email);
        //sendTo.add('patil.rajan@gmail.com');
        sendTo.add(userInfo.Email);
        mail.setToAddresses(sendTo);
    
        // Step 3: Set who the email is sent from
        //mail.setReplyTo(UserInfo.getUserEmail());
        //mail.setSenderDisplayName(UserInfo.getFirstName());
         
        // (Optional) Set list of people who should be CC'ed
        //List<String> ccTo = new List<String>();
        //ccTo.add('business@example.com');
        //mail.setCcAddresses(ccTo);

        // Step 4. Set email contents - you can use variables!
        mail.setSubject(Label.SResInactiveSubjectNot);

        String fullFileURL = System.URL.getSalesforceBaseUrl().toExternalForm();

        System.debug('##fullFileURL: '+fullFileURL);

        String body = Label.EmailSalutation + ' ' + userInfo.FirstName+ ', ';
        body += '<br/>';
        body += '<br/>' + Label.SResInactiveBodyNot;
    
        for (ServiceAppointment sa : lSApp) { 
            body += '<br><a href='+fullFileURL+'/'+sa.Id+'><p>'+sa.AppointmentNumber+'</p></a>';
        }
        
        body += '<br/>-------------------------------------';
        body += '<br/>';
        body += '<br/>' + Label.GoodbyeMsg;

        mail.setHtmlBody(body);
    
        // Step 5. Add your email to the master list
        mails.add(mail);         
    
        try{
            // Step 6: Send all emails in the master list
            Messaging.sendEmail(mails); 
            
        } catch(Exception e){
            System.debug('Exception ERROR NotificationManagerInvocable.sendNotification-->' + e.getMessage() + ' Line: '+e.getLineNumber());
        }
        	        
    }    
    
}
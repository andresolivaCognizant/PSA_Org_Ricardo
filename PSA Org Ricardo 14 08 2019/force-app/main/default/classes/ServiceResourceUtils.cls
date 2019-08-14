/**
 * Name:            ServiceResourceUtils
 * @author:         Diego Rincón (DR) href=<diego.rincon@ext.mpsa.com>
 * Project:         PSA
 * Description:     Helper class to handle bussiness logic related to the ServiceResource sObject.
 *
 * Changes (version)
 * -------------------------------------------------------------------------------------------------
 *              No.     Date            Author                  Description
 *              ----    ------------    --------------------    ------------------------------------
 * @version     1.0     2018-09-20      Diego Rincón (DR)       Class creation.
 *              2.0     2019-03-28      Sergio Lopez            Non future UpdateUsers method creation, trigger will be launched from bacth,
 *                                                              Service Appointment canceled after inactive Service Resource, 
 *                                                              notify to Service Appointment Owners
 *                                          
 *                                                              
 */

public class ServiceResourceUtils {

    /**
     * @author          Diego Rincón (DR)
     * @date            2018-09-20
     * @description     Method to find and update users who should become
     *                  inactive after ServiceResource records are deactivated.
     * @param           Maps from trigger context.
     * @return          none
     */
    public static void isDeactivated(
        Map<Id, ServiceResource> mapOldRows,
        Map<Id, ServiceResource> mapNewRows
    ) {
        System.debug('@@ ServiceResourceUtils.isDeactivated');
        Set<Id> setUserIds = new Set<Id>();
        Set<Id> setSRIds = new Set<Id>();
        String brand;

        for (Id key : mapNewRows.keySet()) {
            if (
                !mapNewRows.get(key).IsActive &&
                mapNewRows.get(key).IsActive != mapOldRows.get(key).IsActive &&
                null != mapNewRows.get(key).RelatedRecordId
            ) {
                setSRIds.add(key);
                setUserIds.add(mapNewRows.get(key).RelatedRecordId);
            }
        }

        // US 1018 - I
        if (!setSRIds.isEmpty()) {
            endServiceApp(setSRIds);
        }
        // US 1018 - F

        if (!setUserIds.isEmpty()) {
            updateUsers(setUserIds);
        }

    }

    @future
    public static void updateUsers(Set<Id> setU) {
        System.debug('@@ ServiceResourceUtils.updateUsers');
        // US 1018 Begin
        updUsers(setU);
        // US 1018 End
    }

    // US 1018 Begin
    public static void updUsers(Set<Id> setU) {
        System.debug('@@ ServiceResourceUtils.updUsers');
        List<User> lstUpd = new List<User>();

        for (User u : [
            SELECT Id, IsActive
            FROM User
            WHERE
                Id IN :setU AND
                IsActive = true
        ]) {
            u.IsActive = false;
            lstUpd.add(u);
        }

        update lstUpd;
    }   
 
    public static void endServiceApp(Set<Id> setSRIds) {
        System.debug('@@ ServiceResourceUtils.endServiceApp');

        try {
            String keepOwner = '';
            String email = '';
            String fName = '';
            
            Set<String> setSA   = new Set<String>();

            List<ServiceAppointment> lSApp       = new List<ServiceAppointment>();
            List<ServiceAppointment> lSAToUpd    = new List<ServiceAppointment>();

            if (!setSRIds.isEmpty()){
                for (AssignedResource ar : [SELECT Id, ServiceAppointmentId
                                                FROM AssignedResource
                                                WHERE ServiceResourceId IN :setSRIds]){
                    setSA.add(ar.ServiceAppointmentId);
                }
            }
        
            // Collect Service Appointment from ending territories. Service Apps will be canceled.
            if (!setSA.isEmpty()){
                for (ServiceAppointment sa : [SELECT Id, OwnerId, Owner.Email, Owner.FirstName, Status, AppointmentNumber
                                                FROM ServiceAppointment
                                                WHERE Id IN :setSA
                                                AND (Status = 'Open' 
                                                OR  Status = 'ReScheduled')
                                                AND SchedStartTime > TODAY 
                                            ORDER BY OwnerId]){
                    sa.Status = 'Canceled';

                    if (!keepOwner.equals(sa.OwnerId)){
                        if (keepOwner != null && !lSApp.isEmpty()){ 
                            sendNotifcation(email, fName, lSApp);
                        }

                        keepOwner = sa.OwnerId;
                        email = sa.Owner.Email;
                        fName = sa.Owner.FirstName;
                        lSApp.clear();    
                    } else {
                        lSApp.add(sa);
                    }

                    lSAToUpd.add(sa);
                }
            }

            if (!lSApp.isEmpty()){
                sendNotifcation(email, fName, lSApp);
            }

            if (!lSAToUpd.isEmpty()){
                update lSAToUpd;
            }
        }  catch(dmlexception e) {
            string error = 'DMLexception ERROR ServiceResourceUtils.endServiceApp --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
            system.debug('Error: '+error);
        } catch(exception e){
            string error = 'Exception ERROR ServiceResourceUtils.endServiceApp --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
            system.debug('Error: '+error);
        } 

    }
    
    /*********************************************************************************************************
    * @Method          : sendNotifcation
    * @Author          : Sergio Lopez
    * @Created         : 18/03/2019
    * @Description     : When a Service Appointment are canceled, a notification is send to the owners.
    * @params          : String, email. 
    *                    String, first name.
    *                    List, of Service App. Numbers.
    **********************************************************************************************************/
    public static void sendNotifcation(String email, String firstName, List<ServiceAppointment> lSApp) {
        System.debug('@@ ServiceResourceUtils.sendNotifcation');

        // Step 0: Create a master list to hold the emails we'll send
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    
        // Step 1: Create a new Email
        Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
    
        // Step 2: Set list of people who should get the email
        List<String> sendTo = new List<String>();
        //sendTo.add(myContact.Email);
        //sendTo.add('patil.rajan@gmail.com');
        sendTo.add(email);
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

        String body = Label.EmailSalutation + ' ' + firstName+ ', ';
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
    }
    // US 1018 End 
}
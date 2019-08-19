/**
    *   @Class          :   EmailUtils   
    *
    *   @Author         :   Pedro Párraga <parragabornez.pedrojesus@ext.mpsa.com>
    *   @Created        :   
    *   @Description    :  Generic class for sending emails
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description    
    *      Pedro Párraga         12/03/2019                   Creation.      
    *   ----------------------------------------------------------------------------------------------------------------------------
**/
public class EmailUtils{

   /**
      * @Method          :   sendEmail
      * @Description     :   Sending emails
      * @Param           :   Integer reserveSingleEmailCapacity
                             String[] toAddresses
                             String senderDisplayName
                             String subject
                             Boolean useSignature
                             String plainTextBody
                             String HtmlBody
      * @Return          :   Void
   **/ 
   public static void sendEmail(Integer reserveSingleEmailCapacity, String[] toAddresses, String senderDisplayName, String subject, Boolean useSignature, String plainTextBody, String HtmlBody){
      System.debug('sendEmail');
      
      try{
        Messaging.reserveSingleEmailCapacity(reserveSingleEmailCapacity);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName(senderDisplayName);
        mail.setSubject(subject);
        mail.setUseSignature(useSignature);
        mail.setPlainTextBody(plainTextBody);
        mail.setHtmlBody(HtmlBody);
    
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
      }catch(Exception e){
          System.debug('The following error has occurred: '+e.getCause());
      }
   } 
}
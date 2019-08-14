/**
*   @Class          :  EmailMessageTrigger   
*
*   @Author         :  Pedro Párraga <parragabornez.pedrojesus@ext.mpsa.com>
*   @Created        :  17/04/2019 
*   @Description    :  Trigger for the object EmailMessage
*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Developer                Date                     Description    
*      Pedro Párraga            17/04/2019               Creation.
*      Ruben Fernadnez          25/04/2019               Addedd before insert method.
*   ----------------------------------------------------------------------------------------------------------------------------
**/
trigger EmailMessageTrigger on EmailMessage (before insert, after insert) {
    
    if(EmailMessageHandler.shouldRunTrigger()) {
        if(Trigger.isBefore){
            if(Trigger.isInsert){
                if (PAD.canTrigger('EmailMessage_BeforeInsert')) {
                    EmailMessageHandler.beforeInsert(Trigger.new);
                }
            }
        }
        if(Trigger.isAfter){
            if(Trigger.isInsert){
                if (PAD.canTrigger('EmailMessage_AfterInsert')) {
                    EmailMessageHandler.afterInsert(Trigger.new);
                }
            }
        }
    }

}
/**
    *   @Class          :   BusinessHourCustomTrigger   
    *
    *   @Author         :   Pedro Párraga <parragabornez.pedrojesus@ext.mpsa.com>
    *   @Created        :   
    *   @Description    :  Trigger for the object LiveChatTranscript
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description    
    *      Pedro Párraga         28/03/2019                   Creation.      
    *   ----------------------------------------------------------------------------------------------------------------------------
**/
trigger LiveChatTranscriptTrigger on LiveChatTranscript (before insert, after insert, before update, after update) {

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            if (PAD.canTrigger('LiveChatTranscriptT_BeforeInsert')) {
                LiveChatTranscriptHandler.beforeInsert(Trigger.new);
            }
        }
        
        if(Trigger.isUpdate){
            if (PAD.canTrigger('LiveChatTranscriptT_BeforeUpdate')) {
                LiveChatTranscriptHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
            }
        }
    }

    //if(Trigger.isAfter){
    //    if(Trigger.isInsert){
    //        if (PAD.canTrigger('LiveChatTranscriptT_AfterInsert')) {

    //        }
    //    }

    //    if(Trigger.isUpdate){
    //        if (PAD.canTrigger('LiveChatTranscriptT_AfterUpdate')) {

    //        }
    //    }
    //}
}
/**
    *   @Class          :   BusinessHourCustomTrigger   
    *
    *   @Author         :   Pedro Párraga <parragabornez.pedrojesus@ext.mpsa.com>
    *   @Created        :   
    *   @Description    :  Trigger for the object BusinessHour__c
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description    
    *      Pedro Párraga         12/03/2019                   Creation.      
    *   ----------------------------------------------------------------------------------------------------------------------------
**/
trigger BusinessHourCustomTrigger on BusinessHour__c (before insert, after insert, before update, after update) {

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            if (PAD.canTrigger('CustomBH_BeforeInsert')) {
               BusinessHoursHandler.beforeInsert(Trigger.new);
            }
        }
        if(Trigger.isUpdate){
            if (PAD.canTrigger('CustomBH_BeforeUpdate')) {
                BusinessHoursHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
            }
        }
    }

    if(Trigger.isAfter){
        if(Trigger.isInsert){
            if (PAD.canTrigger('CustomBH_AfterInsert')) {
                BusinessHoursHandler.afterInsert(Trigger.new);
            }
        }

        if(Trigger.isUpdate){
            if (PAD.canTrigger('CustomBH_AfterUpdate')) {
                BusinessHoursHandler.afterUpdate(Trigger.new, Trigger.oldMap);
            }
        }
    }
}
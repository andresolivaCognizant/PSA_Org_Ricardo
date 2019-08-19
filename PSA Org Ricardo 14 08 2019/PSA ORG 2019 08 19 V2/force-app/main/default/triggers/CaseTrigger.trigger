/*-----------------------------------------------------------------------------------------------------------//
  * Class Name    : CaseTrigger
  * Project       : PSA - C1ST - Care
  * Author        : Borja Gay Flores    <gayflores.borja@ext.mpsa.com>
  * Date          : 10/18/2018
  * Description   : Case Trigger
  *
  *-----------------------------------------------------------------------------------------------------------
  *      Modification Log :
  *-----------------------------------------------------------------------------------------------------------
  *      Developer                Date                     Description    
  *      Borja Gay Flores         10/18/2019               Creation.      
  *      Carmen Hernandez         03/20/2019               Refactor & Add bypass
  *      Carmen Hernandez		  07/12/2019			   Add condition .shouldRunTrigger
  *-----------------------------------------------------------------------------------------------------------*/
trigger CaseTrigger on Case (before insert, after insert, before update, after update) {
    
    if(CaseTriggerHandler.shouldRunTrigger()){
            
        /***************************************************
                            * BEFORE *
        ****************************************************/
        if(trigger.isBefore){
            /* INSERT */
            if(trigger.isInsert){
                /* Execute the process only if user is allowed to do it*/
                if(PAD.canTrigger('Case_BeforeInsert')){
                    CaseTriggerHandler.beforeInsert(trigger.new);
                }
            }
            /* UPDATE */
            if(trigger.isUpdate){
                /* Execute the process only if user is allowed to do it*/
                if(PAD.canTrigger('Case_BeforeUpdate')){
                    CaseTriggerHandler.beforeUpdate(trigger.new, trigger.oldMap);
                }
            }
        }
    
        /***************************************************
                            * AFTER *
        ****************************************************/
        if(trigger.isAfter){
            /* INSERT */
            if(trigger.isInsert){
                /* Execute the process only if user is allowed to do it*/
                if(PAD.canTrigger('Case_AfterInsert')){
                    CaseTriggerHandler.afterInsert(trigger.new);
                }
            }
            /* UPDATE */
            if(trigger.isUpdate){
                /* Execute the process only if user is allowed to do it*/
                if(PAD.canTrigger('Case_AfterUpdate')){
                    CaseTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
                }
            }
        }
    }
}
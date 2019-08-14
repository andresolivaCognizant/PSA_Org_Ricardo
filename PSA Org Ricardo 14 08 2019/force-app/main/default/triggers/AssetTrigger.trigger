/*-----------------------------------------------------------------------------------------------------------//
  * Class Name    : AssetTrigger
  * Project       : PSA - C1ST
  * Author        : Ruben Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
  * Date          : 04/11/2018  
  * Description   : Asset Trigger
  *
  *-----------------------------------------------------------------------------------------------------------
  *      Modification Log :
  *-----------------------------------------------------------------------------------------------------------
  *      Developer              Date                    Description    
  *	 Ruben Moreno		11 Apr 2018		Creation.
  *	 Nerea Leguinazabal	11 Jul 2019		Method changeVINAndLastKnownRegistrationNumber moved to AssetUtils		  
  *-----------------------------------------------------------------------------------------------------------*/
trigger AssetTrigger on Asset (after delete, after insert, after update, before delete, before insert, before update) {

    if(AssetTriggerHandler.shouldRunTrigger()) {        

        /***************************************************
                            * BEFORE *
        ****************************************************/
        if (Trigger.isBefore){
            /* INSERT */
            if (Trigger.isInsert) {
                 /* Execute the process only if user is allowed to do it */
                if(PAD.canTrigger('Asset_BeforeInsert')){
                    AssetTriggerHandler.beforeInsert(Trigger.New);
                }
            }
            /* UPDATE */
            if(Trigger.isUpdate){
                 /* Execute the process only if user is allowed to do it */
                if(PAD.canTrigger('Asset_BeforeUpdate')){
                    AssetTriggerHandler.beforeUpdate( Trigger.New, Trigger.oldMap );
                }
            }
            /* DELETE 
            if(Trigger.isDelete){
            }
			*/
        /***************************************************
                            * AFTER *
        ****************************************************/
        } else {
            /* INSERT */
            if(Trigger.isInsert){
                /* Execute the process only if user is allowed to do it */
                if(PAD.canTrigger('Asset_AfterInsert')){
                    AssetTriggerHandler.afterInsert(Trigger.newMap);
                }
            }
            /* UPDATE */
            if(Trigger.isUpdate){
                /* Execute the process only if user is allowed to do it */
                if(PAD.canTrigger('Asset_AfterUpdate')){
                    AssetTriggerHandler.afterUpdate(Trigger.oldMap, Trigger.newMap);
                }
            }
            /* DELETE 
            if(Trigger.isDelete){
            }
			*/
            /* UNDELETE 
            if(Trigger.isUndelete){
            }
			*/
        }
    }
}
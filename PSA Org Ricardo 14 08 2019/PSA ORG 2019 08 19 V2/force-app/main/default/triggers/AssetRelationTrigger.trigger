/*-----------------------------------------------------------------------------------------------------------//
  * Class Name    : AssetRelationTrigger
  * Project       : PSA - C1ST
  * Author        : Diego Rincón    <diego.rincon@ext.mpsa.com>
  * Date          : 07/05/2018
  * Description   : Asset Relation Trigger
  *
  *-----------------------------------------------------------------------------------------------------------
  *      Modification Log :
  *-----------------------------------------------------------------------------------------------------------
  *      Developer                Date                     Description    
  *      Diego Rincón             07/05/2018               Creation
  *-----------------------------------------------------------------------------------------------------------*/
trigger AssetRelationTrigger on AccountContactAssetRelation__c (before insert, after insert, before update, after update) {

    switch on Trigger.operationType {
        when BEFORE_INSERT {
            if(PAD.canTrigger('AccountContactAssetRelation_BeforeInsert' )){
                AssetRelationTriggerHandler.beforeInsert(Trigger.new);
            }
        }
        when AFTER_INSERT {
            if(PAD.canTrigger( 'AccountContactAssetRelation_AfterInsert' )){
            	AssetRelationTriggerHandler.afterInsert(Trigger.newMap);  
            }
        }
        when BEFORE_UPDATE {
            if(PAD.canTrigger('AccountContactAssetRelation_BeforeUpdate')){
                AssetRelationTriggerHandler.beforeUpdate(Trigger.oldMap, Trigger.newMap);
            }
        }
        when AFTER_UPDATE {
            if(PAD.canTrigger('AccountContactAssetRelation_AfterUpdate')){
                AssetRelationTriggerHandler.afterUpdate(Trigger.oldMap, Trigger.newMap);
            }
        }
    }
}
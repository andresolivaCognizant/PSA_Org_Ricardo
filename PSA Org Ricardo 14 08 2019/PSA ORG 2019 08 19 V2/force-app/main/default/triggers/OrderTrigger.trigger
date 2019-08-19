trigger OrderTrigger on Order (before insert,before update,before delete,after delete, after insert, after update) {
  
    
   /***************************************************
              * BEFORE *
    ****************************************************/
  
    if (Trigger.isBefore){
      
      /* INSERT */
      if (Trigger.isInsert) {     
          /* Execute the process only if user is allowed to do it */
          if(PAD.canTrigger('Order_BeforeInsert')){
              OrderTriggerHandler.beforeInsert(trigger.new);
          }          
      }
  
      /* UPDATE */
      if(Trigger.isUpdate){
        /* Execute the process only if user is allowed to do it */
        if(PAD.canTrigger('Order_BeforeUpdate')){
			      OrderTriggerHandler.beforeUpdate(trigger.new, trigger.oldMap);
        }
      }
  
      /* DELETE */
      if(Trigger.isDelete){
      }
  
  
    /***************************************************
              * AFTER *
    ****************************************************/
  
    }else{
    
      /* INSERT */
      if(Trigger.isInsert){
          /* Execute the process only if user is allowed to do it */
          if(PAD.canTrigger('Order_AfterInsert')){
            OrderTriggerHandler.afterInsert(trigger.new,trigger.newMap);
          }
      }
  
      /* UPDATE */
      if(Trigger.isUpdate){
        /* Execute the process only if user is allowed to do it */
        if(PAD.canTrigger('Order_AfterUpdate')){
          OrderTriggerHandler.afterUpdate(trigger.new, Trigger.oldmap,trigger.newMap);
        }
      }
  
      /* DELETE */
      if(Trigger.isDelete){
      }
  
      /* UNDELETE */
      if(Trigger.isUndelete){
      }
    }    

}
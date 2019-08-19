public with sharing class OrderTriggerHandler {
	
/*
*   @Class : OrderTrigger.cls
*
*   @Author         :   Ruben Fernandez
*   @Created        :   26 Jul 2018
*   @Description    :   To manage order trigger methods

*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Developer            Date                     Description
*      Ruben Fernandez      26 Jul 2018              Creation.
*      Andrés Oiva          18 Aug 2019              C1STDEPLOY-231 ==> Call method OrderUtils.updateOrderFormToActiveStatus() in order to update quote status if fullfill requirements
*   ----------------------------------------------------------------------------------------------------------------------------
*/
    private static boolean runtrigger = true;

    /*
     * @Method          :   shouldRunTrigger
     * @Description     :   To get the flag that indicate if the trigger should run or not
     * @Returns         :   Boolean
     */
    public  static  boolean shouldRunTrigger() {
        return runtrigger;
    }

    /*
     * @Method          :   dontRunTrigger
     * @Description     :   To indicate that the trigger should not run
     * @Returns         :   false
     */
    public  static  void    dontRunTrigger() {
        runtrigger = false;
    }

    /*
     * @Method          :   beforeInsert
     * @Description     :   Call the actions that handle the before insert trigger.
     * @Params          :   List<Order> records before the changes.
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */     
    public static void beforeInsert(List<Order> lNewOrders) {
        if(lNewOrders.size() == 1){
            // Call single methods only
            OrderUtils.callBUSingleOrderMethods(lNewOrders[0], null);
        }
    }

    /*
     * @Method          :   beforeUpdate
     * @Description     :   Call the actions that handle the before update trigger.
     * @Params          :   List< Order> records after the changes, Map<Id, Order> record before the changes
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */
    public static void beforeUpdate(List<Order> lNewOrders, Map<Id, Order> mapOldOrders) {
        if(lNewOrders.size() == 1){
            // Call single methods only
            OrderUtils.callBUSingleOrderMethods(lNewOrders[0], mapOldOrders.get(lNewOrders[0].Id));
        }
        OrderUtils.updateOrderFormToActiveStatus(  lNewOrders,  mapOldOrders );//Andrés Oliva JIRA C1STDEPLOY-231  18/08/2019

    }

    /*
     * @Method          :   afterInsert
     * @Description     :   Call the actions that handle the after insert trigger
     * @Params          :   List<Order> records after the changes
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */
    public static void afterInsert(List<Order> lNewOrders,Map<id,Order> mapNewOrders) {
        if (!PAD.canTrigger('Order_AfterInsert')) {
            return;
        }

        System.debug('Order After Insert' + lNewOrders.size());
        List<Order> lstOrderDMS   = new List<Order>();
        for(Order l : lNewOrders){
            if( PAD.sUserTypeCode == '0' && PAD.sUserDMS){
                //28/01/2019 RFL: C1STAGILE-6493. Replace CreatedById by OwnerId
//                if(l.OwnerId == PAD.uCurrentUserName.Id){
                    lstOrderDMS.add(l);
//                }
                // END Change
            //28/01/2019 RFL: C1STAGILE-6493. Replace CreatedById by OwnerId
            }
        }

        if(!lstOrderDMS.isEmpty()){
            System.debug('Order After Insert SAPIWebhook');
            SAPIWebhook.ProcessRecords(lstOrderDMS,0);
        }

        AccountLeaserRelationUtils.createAccounLeaserRelation(lNewOrders);

        //Change the XXAccountStatus__c field in Account
        ChangeAccountStatus.mainFunction(trigger.new);
        OrderUtils.createAutomaticContactTask(mapNewOrders.keySet());
    }

    /*
     * @Method          :   afterUpdate
     * @Description     :   Call the actions that handle the after update trigger.
     * @Params          :   List<Order> records after the changes, Map<Id, Order> record before the changes
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */     
    public static void afterUpdate(List<Order> lNewOrders, Map<Id, Order> mapOldOrders,Map<id,Order> mapNewOrders) {
    
        List<Order> lOrdersToChangeAccountStatus = new List<Order>();  
        Set<Id> setOrdersToCreateTask = new Set<Id>();   
        for(Order ord : lNewOrders){
            if(ord.Status != mapOldOrders.get(ord.id).Status){
                lOrdersToChangeAccountStatus.add(ord);
            }
            if(mapOldOrders.get(ord.id).RealDeliveryDate__c == null && mapNewOrders.get(ord.id).RealDeliveryDate__c != null){
                setOrdersToCreateTask.add(ord.id);
            }
        }

        //Change the XXAccountStatus__c field in Account
        if(lOrdersToChangeAccountStatus != null && lOrdersToChangeAccountStatus.size()>0){
            ChangeAccountStatus.mainFunction(lOrdersToChangeAccountStatus);
        }
        if(!setOrdersToCreateTask.isEmpty()){
            OrderUtils.createAutomaticContactTask(setOrdersToCreateTask);
        }
    }
}
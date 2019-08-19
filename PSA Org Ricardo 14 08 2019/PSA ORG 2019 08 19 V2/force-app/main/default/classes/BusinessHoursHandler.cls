/**
    *   @Class          :   BusinessHoursHandler   
    *
    *   @Author         :   Pedro Párraga <parragabornez.pedrojesus@ext.mpsa.com>
    *   @Created        :   
    *   @Description    :  Class to handle the trigger events of the BusinessHour object _c
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description    
    *      Pedro Párraga         12/03/2019                   Creation.      
    *   ----------------------------------------------------------------------------------------------------------------------------
**/
public with sharing class BusinessHoursHandler {

   /**
      * @Method          :   beforeInsert
      * @Description     :   Event handler for before insert
      * @Param           :   List<BusinessHour__c> lstNew
      * @Return          :   Void
   **/  
   public static void beforeInsert(List<BusinessHour__c> lstNew){
      BusinessHoursUtils.completeBusinessHourCustom(lstNew);
   }    

    /**
      * @Method          :   afterInsert
      * @Description     :   Event handler for after insert
      * @Param           :   List<BusinessHour__c> lstNew
      * @Return          :   Void
   **/    
   public static void afterInsert(List<BusinessHour__c> lstNew){       
      BusinessHoursUtils.InsertBusinessHour bh = new BusinessHoursUtils.InsertBusinessHour(lstNew);
      System.enqueueJob(bh);
   }

   /**
      * @Method          :   beforeUpdate
      * @Description     :   Event handler for before update
      * @Param           :   List<BusinessHour__c> lstNew
                             Map<Id, BusinessHour__c> oldMap
      * @Return          :   Void
   **/  
   public static void beforeUpdate(List<BusinessHour__c> lstNew, Map<Id, BusinessHour__c> oldMap){
      BusinessHoursUtils.completeBusinessHourCustom(lstNew);
   }  

   /**
      * @Method          :   afterUpdate
      * @Description     :   Event handler for after update
      * @Param           :   List<BusinessHour__c> lstNew
                             Map<Id, BusinessHour__c> oldMap
      * @Return          :   Void
   **/  
   public static void afterUpdate(List<BusinessHour__c> lstNew, Map<Id, BusinessHour__c> oldMap){
      BusinessHoursUtils.UpdateBusinessHour bh = new BusinessHoursUtils.UpdateBusinessHour(lstNew);
      System.enqueueJob(bh);
   }    
}
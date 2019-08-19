/**
    *   @Class          :   AccountContactRelationTriggerHandler   
    *
    *   @Author         :   Pedro Párraga <parragabornez.pedrojesus@ext.mpsa.com>
    *   @Created        :   
    *   @Description    :  Class to handle the trigger events of the AccountContactRelation object _c
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description    
    *      Pedro Párraga         21/05/2019                   Creation.      
    *   ----------------------------------------------------------------------------------------------------------------------------
**/
public with sharing class AccountContactRelationTriggerHandler {

    private static boolean runtrigger = true;
    
    public static boolean shouldRunTrigger() {
        return runtrigger;
    }
    
    public static void dontRunTrigger() {
        runtrigger = false;
    }
    

    /**
      * @Method          :   beforeInsert
      * @Description     :   Event handler for before insert
      * @Param           :   List<AccountContactRelation> lstNew
      * @Return          :   Void
    **/  
    public static void beforeInsert(List<AccountContactRelation> lstNew){
        //dontRunTrigger ();
        AccountContactRelationUtils.fillTechC1stKey(lstNew);
    }  
}
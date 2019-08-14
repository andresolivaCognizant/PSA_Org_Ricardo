/**
*   @Class          :   BusinessHoursHandler   
*
*   @Author         :  Pedro Párraga <parragabornez.pedrojesus@ext.mpsa.com>
*   @Created        :  17/04/2019 
*   @Description    :  Class to handle the trigger events of the EmailMessageHandler object
*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Developer              Date                       Description    
*      Pedro Párraga          17/04/2019                 Creation. 
*      Ruben Fernadnez          25/04/2019               Addedd before insert method.     
*   ----------------------------------------------------------------------------------------------------------------------------
**/
public with sharing class EmailMessageHandler {
   private static boolean runtrigger = true;

    /*
     * @Method          :   shouldRunTrigger
     * @Created         :   20 feb 2018
     * @Description     :   To get the flag that indicate if the trigger should run or not
     */
    public static boolean shouldRunTrigger() {
        return runtrigger;
    }

    /*
     * @Method          :   dontRunTrigger
     * @Created         :   20 feb 2018
     * @Description     :   To indicate that the trigger should not run
     */
    public static void dontRunTrigger() {
        runtrigger = false;
    }
   /**
      * @Method          :   afterInsert
      * @Description     :   Event handler for before insert
      * @Param           :   List<EmailMessage> lstNew
      * @Return          :   Void
   **/  
   public static void afterInsert(List<EmailMessage> lstNew){
     EmailMessageUtils.changeCaseStatus(lstNew);
   }    
   /**
   * @Method          :   beforeInsert
   * @Description     :   Event handler for before insert
   * @Param           :   List<EmailMessage> lstNew
   * @Return          :   Void
   **/  
   public static void beforeInsert(List<EmailMessage> lstNew){
     EmailMessageUtils.validateEmailOWA(lstNew);
   }   

}
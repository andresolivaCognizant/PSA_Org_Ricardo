/**
    *   @Class          :   BusinessHoursHandler   
    *
    *   @Author         :   Pedro Párraga <parragabornez.pedrojesus@ext.mpsa.com>
    *   @Created        :   
    *   @Description    :  Class to handle the trigger events of the LiveChatTranscript object
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description    
    *      Pedro Párraga         28/03/2019                   Creation.      
    *   ----------------------------------------------------------------------------------------------------------------------------
**/
public with sharing class LiveChatTranscriptHandler {

   /**
      * @Method          :   beforeInsert
      * @Description     :   Event handler for before insert
      * @Param           :   List<LiveChatTranscript> lstNew
      * @Return          :   Void
   **/  
   public static void beforeInsert(List<LiveChatTranscript> lstNew){
      LiveChatTranscriptUtils.asignContactToLiveChat(lstNew);
   }  

    /**
      * @Method          :   afterInsert
      * @Description     :   Event handler for after insert
      * @Param           :   List<LiveChatTranscript> lstNew
      * @Return          :   Void
   **/    
/*   public static void afterInsert(List<LiveChatTranscript> lstNew){       

   }*/

   /**
      * @Method          :   beforeUpdate
      * @Description     :   Event handler for before update
      * @Param           :   List<LiveChatTranscript> lstNew//
                             Map<Id, LiveChatTranscript> oldMap
      * @Return          :   Void
   **/  
   public static void beforeUpdate(List<LiveChatTranscript> lstNew, Map<Id, LiveChatTranscript> oldMap){
   		LiveChatTranscriptUtils.asignContactToCase(lstNew);
   }  

   /**
      * @Method          :   afterUpdate
      * @Description     :   Event handler for after update
      * @Param           :   List<LiveChatTranscript> lstNew
                             Map<Id, LiveChatTranscript> oldMap
      * @Return          :   Void
   **/  
/*   public static void afterUpdate(List<LiveChatTranscript> lstNew, Map<Id, LiveChatTranscript> oldMap){

   }  */ 
}
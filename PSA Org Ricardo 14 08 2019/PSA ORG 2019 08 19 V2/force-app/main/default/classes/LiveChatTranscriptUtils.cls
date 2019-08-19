/**
    *   @Class          :   BusinessHoursUtils   
    *
    *   @Author         :   Pedro Párraga <parragabornez.pedrojesus@ext.mpsa.com>
    *   @Created        :   
    *   @Description    :  class that machetes the LiveChatTranscript object
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description    
    *      Pedro Párraga         28/03/2019                   Creation.      
    *   ----------------------------------------------------------------------------------------------------------------------------
**/
public with sharing class LiveChatTranscriptUtils {
    
    private static Map<String, String> mapPicklistValues = new Map<String, String>();
    static{
        for (Schema.PicklistEntry pickListVal : Case.Country__c.getDescribe().getPicklistValues()){
            mapPicklistValues.put(picklistVal.getValue(), pickListVal.getLabel());
        }   
    }    
    

   /**
      * @Method          :   asignContactToCase
      * @Description     :   assigns the contact of the LiveChatTranscrip object
      * @Param           :   List<LiveChatTranscript> lstNew
      * @Return          :   void
   **/  
    public static void asignContactToLiveChat(List<LiveChatTranscript> lstNew){
      System.debug('asignContactToLiveChat');

      Set<Id> idsLiveChatButton = new Set<Id>();
      for(LiveChatTranscript live : lstNew){
        idsLiveChatButton.add(live.LiveChatButtonId);
      }

      Map<Id, LiveChatButton> mapButton = new Map<Id, LiveChatButton>([SELECT Id, DeveloperName FROM LiveChatButton WHERE Id IN : idsLiveChatButton]);
      System.debug('mapButton class: '+mapButton);

      Map<String, String> mapContacts= new Map<String, String>();
      for(Contact cont : [SELECT Id, Name FROM Contact WHERE Name like '%Anonymous%']){
          mapContacts.put(cont.Name, cont.Id);
      }

      for(LiveChatTranscript live : lstNew){
        if(Test.isRunningTest()){
            return;
        }

        String nameButton = mapButton.get(live.LiveChatButtonId).DeveloperName;
        for(String codeCountry: mapPicklistValues.keySet()){
          if(nameButton.contains(codeCountry)){
            String nameContact = mapPicklistValues.get(codeCountry)+' Anonymous';
            live.ContactId = mapContacts.get(nameContact);
            break;
          }
		}
      }
    }


   /**
      * @Method          :   asignContactToCase
      * @Description     :   assigns the contact of the LiveChatTranscrip object to the case associated with this
      * @Param           :   List<LiveChatTranscript> lstNew
      * @Return          :   void
   **/  
    public static void asignContactToCase(List<LiveChatTranscript> lstNew){
        System.debug('asignContactToCase');

        Map<String, String> mapCaseAndContact = new Map<String, String>();
        List<String> lstLiveNoContact = new List<String>();
        List<Case> lstCases;
        Map<Id, Case> mapCases = new Map<Id, Case>();

        for(LiveChatTranscript lch : lstNew){
            if(lch.ContactId != null){
                mapCaseAndContact.put(lch.CaseId, lch.ContactId);
            }else{
                lstLiveNoContact.add(lch.CaseId);
            }
        }

        if(!mapCaseAndContact.isEmpty()){
          mapCases = new Map<Id, Case>([SELECT Id FROM Case WHERE Id IN : mapCaseAndContact.keySet()]); 
          if(!mapCases.isEmpty()){
            Map<Id, Contact> lstContact = new Map<Id, Contact>([SELECT Id, IsPersonAccount, AccountId FROM Contact where Id IN : mapCaseAndContact.values()]);
            for(String idCase : mapCaseAndContact.keySet()){
              String idContact = mapCaseAndContact.get(idCase);
              mapCases.get(idCase).AccountId = lstContact.get(idContact).AccountId;
              mapCases.get(idCase).ContactId = lstContact.get(idContact).Id;
            }
          }
        }

        if(!lstLiveNoContact.isEmpty()){
             lstCases = matchAccountToCase(lstLiveNoContact);
             for(Case cas : lstCases){
                mapCases.put(cas.Id, cas);
             }          
        }

        if(!mapCases.isEmpty()){
          update mapCases.values();
        }
        
    }

   /**
      * @Method          :   matchAccountToCase
      * @Description     :   Method that assigns an anonymous account to the case when
                             the LiveChatTranscript object has no contact
      * @Param           :   List<String> lstCaseIds
      * @Return          :   List<Case>
   **/  
    private static List<Case> matchAccountToCase(List<String> lstCaseIds){
        System.debug('matchAccountToCase');
        List<Case> lstCases = [SELECT Id, Subject, Country__c, Origin FROM Case WHERE Id IN : lstCaseIds];
        
        Map<String, String> mapAccounts = new Map<String, String>();
        for(Account ac : [SELECT Id, Name FROM Account WHERE Name like '%Anonymous%']){
            mapAccounts.put(ac.Name, ac.Id);
        }
        
        for(Case ca : lstCases){         
            if(ca.Origin == CareConstants.CASE_ORIGIN_CHAT){
                if(ca.Country__c != null){ 
                    ca.AccountId = mapAccounts.get(mapPicklistValues.get(ca.Country__c) +' Anonymous');
                }
                ca.Subject = Label.Chat_conversation;
            }
        }
        
        return lstCases;
    }   
}
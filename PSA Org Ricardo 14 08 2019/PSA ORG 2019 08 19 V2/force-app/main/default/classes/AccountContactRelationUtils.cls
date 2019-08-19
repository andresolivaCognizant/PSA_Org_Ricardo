/**
    *   @Class          :   AccountContactRelationTriggerHandler   
    *
    *   @Author         :   Pedro Párraga <parragabornez.pedrojesus@ext.mpsa.com>
    *   @Created        :   
    *   @Description    :  Class responsible for carrying out processes related to the AccountContactRelation object
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description    
    *      Pedro Párraga         21/05/2019                   Creation.      
    *   ----------------------------------------------------------------------------------------------------------------------------
**/
public with sharing class AccountContactRelationUtils {

    /**
      * @Method          :   afterInsert
      * @Description     :   fill the TechC1stKey__c field
      * @Param           :   List<AccountContactRelation> lstNew
      * @Return          :   Void
   **/  
	public static void fillTechC1stKey(List<AccountContactRelation> lstNew) {
        for (AccountContactRelation acr : lstNew) {
            acr.TechC1stKey__c = acr.AccountId + '_' + acr.ContactId;
        }		
	}
}
/*-----------------------------------------------------------------------------------------------------------//
  * Class Name    : CaseTriggerHandler
  * Project       : PSA - C1ST
  * Author        : Borja Gay Flores    <gayflores.borja@ext.mpsa.com>
  * Date          : XX/XX/2018
  * Description   : Description .....
  *
  *-----------------------------------------------------------------------------------------------------------
  *      Modification Log :
  *-----------------------------------------------------------------------------------------------------------
  *      Developer                Date                     Description    
  *      Borja Gay Flores         XX/XX/2019               Creation.      
  *      Carmen Hernandez         20/03/2019               Add methods - shouldRunTrigger / dontRunTrigger
  *-----------------------------------------------------------------------------------------------------------*/
public with sharing class CTITaskCaseRelation {

    private static final String TYPE_CALL       = 'Call';
    private static final String ID_INIT_CASE    = '500';
    private static final String BRAND_FIELD     = 'Brand__c';
    private static final String COUNTRY_FIELD   = 'Country__c';
    private static final String LANGUAGE_FIELD  = 'Language__c';
    private static final String HYPEN_STR       = '-';
    private static final String EMPTY_STR       = '';
    private static final String SPACE_STR       = ' ';

    /*********************************************************************************************************
    * @Method          :   populateCaseInfo
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   03/27/2019
    * @Description     :   This method is used to update the {Brand, Country, Language}fields in the related case
    * @params	       :   List<Task> : Trigger.new
    * @Returns         :   void
    **********************************************************************************************************/ 
	public static void populateCaseInfo(List<Task> lstTsk){
        
        List<Case> casesToUpdate = new List<Case>();
        for(Task tsk : lstTsk){
            String what = tsk.WhatId;
            if(what != null && tsk.Type == TYPE_CALL && tsk.Skill__c != EMPTY_STR && what.startsWith(ID_INIT_CASE)){
                Map <String, String> mapSkill = getValuesFromSkill(tsk.Skill__c);
                if(mapSkill != null){
                    Case tmpCase = new Case(Id = what);
                    for(String field : mapSkill.keySet()){
                        tmpCase.put(field, mapSkill.get(field));
                    }
                    casesToUpdate.add(tmpCase);
                }
            }
        }
        if(casesToUpdate != null && casesToUpdate.size()>0){
            update casesToUpdate;
        }
	}

    /*********************************************************************************************************
    * @Method          :   getValuesFromSkill
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   03/27/2019
    * @Description     :   This method is used to get {Country,Brand,Language} from a string with a specific 
    *                  :   format: ex:'PSA CC Peugeot pt-PT'
    * @params	       :   String: Skill
    * @Returns         :   Map<String, String> : Keys: map[Country__c], map[Brand__c], map[Language__c]
    **********************************************************************************************************/   
    public static Map<String, String> getValuesFromSkill(String skill){

        Map<String, String> mapBrandValues = new Map<String, String>();
        for (Schema.PicklistEntry pickListVal : Case.Brand__c.getDescribe().getPicklistValues()){
            mapBrandValues.put(picklistVal.getLabel(), pickListVal.getValue());
        }
        
        Map<String, String> mapValues = new Map<String, String>();
        List<String> strList = skill.split(SPACE_STR);
        if(strList != null && strList.size() == 4){
            List<String> strList2 = strList.get(3).split(HYPEN_STR);
            if(strList2 != null && strList2.size() == 2){
                mapValues.put(LANGUAGE_FIELD, strList2.get(0).toUpperCase());
                mapValues.put(COUNTRY_FIELD, strList2.get(1).toUpperCase());
                mapValues.put(BRAND_FIELD, mapBrandValues.get(strList.get(2)));
            }
        }
        return mapValues;
    }
}
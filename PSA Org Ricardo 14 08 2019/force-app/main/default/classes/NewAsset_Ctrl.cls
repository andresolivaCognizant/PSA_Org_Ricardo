/*
	 * @Name            :   NewAsset_Ctrl
	 * @Author          :   Ricardo Pereira Ramirez
	 * @Created         :   27/12/2018
	 * @Methods (aura)    
						-  getRecordDetails. Retrieves info of a given Id dynamically
	 * @Methods (private)   
						-
*/ 
public with sharing class NewAsset_Ctrl {

    @AuraEnabled
    public static Boolean getCountryType() {
        return GenericButtonController.getCountryType();
    }

}
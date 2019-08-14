/*
	 * @Name            :   ConfigurationHelper
	 * @Author          :   Ricardo Pereira Ramirez
	 * @Created         :   13/12/2018
	 * @Methods (aura)    
						-
*/ 
public class ConfigurationHelper {

    /*
	 * @Method          :   getEnhancedHeaderConfig
	 * @Description     :   Retrieves a record of EnhancedHeaderConfig by its name
	 * @Params          :   configName
	 * @Returns         :   EnhancedHeaderConfig
	 */ 
	public static List<EnhancedHeaderConfig__mdt> getEnhancedHeaderConfig(String configName) {
        List<EnhancedHeaderConfig__mdt> lstConfig = [SELECT Id, ConfigJSON__c FROM EnhancedHeaderConfig__mdt WHERE DeveloperName =: configName];		
		
        return lstConfig;
    }
}
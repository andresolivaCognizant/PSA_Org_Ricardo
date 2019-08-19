public with sharing class DealerPortalThemeController {
	
	@AuraEnabled
	public static User getUserDetails() {
		System.debug('Start of DealerPortalThemeController.getUserDetails...');
		String currentUserId = UserInfo.getUserID();
		return [SELECT Id, ProfileId, Profile.Name, Brand__c FROM User WHERE Id = :currentUserId];
	} 

	@AuraEnabled        
    public static Map<String,String> DMSWakeUpbyCORS(){
        Map<String,String>  sCORS = new Map<String,String>();
        if(PAD.sUserDMSType=='1'){
           sCORS.put('body',SAPIWebhook.getRequestParams());
           sCORS.put('endpoint',SAPIWebhook.getFinalURL(PAD.sURLDMS,null));
        }
        return sCORS;
    }    

}
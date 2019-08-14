public class CustomerPortalThemeController {
@AuraEnabled
	public static String getUserCountryAndLang() {
		id currentUserId = UserInfo.getUserId();
		List<User> lstUsr = new List<User>();
		String result = '';
		lstUsr = [SELECT id, Name, Country__c, LanguageLocaleKey,  Profile.Name, Profile.UserLicense.Name from User where id = :currentUserId];
		if (lstUsr[0].Profile.UserLicense.Name == 'Guest User License') {
			result = 'guest';
		} else {
			String valueLanguage = lstUsr[0].LanguageLocaleKey.split('_')[0].toUpperCase();
			result = lstUsr[0].Country__c + ';' + valueLanguage;
		}
		return result;
	}
}
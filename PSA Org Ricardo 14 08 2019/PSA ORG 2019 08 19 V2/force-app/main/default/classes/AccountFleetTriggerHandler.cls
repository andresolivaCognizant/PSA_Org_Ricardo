public class AccountFleetTriggerHandler {
    public static void setAccountFleetCountryandCurrency(List<AccountFleet__c> lstAccF){
        String usrId = userInfo.getUserId();
		List<User> lstUser = new List<User>();
		lstUser = [SELECT id,DefaultCurrencyIsoCode,Country__c from User where id=:usrId];
        
        for(AccountFleet__c acc : lstAccF){
            if(lstUser[0].Country__c != null){
                acc.Country__c = lstUser[0].Country__c;
            }
            if(lstUser[0].DefaultCurrencyIsoCode != null){
                acc.CurrencyIsoCode = lstUser[0].DefaultCurrencyIsoCode;
            }
        }
    }
}
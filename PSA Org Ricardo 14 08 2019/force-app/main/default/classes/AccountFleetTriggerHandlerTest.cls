@isTest
public class AccountFleetTriggerHandlerTest {
	@isTest
    static void setAccountFleetCountryandCurrencyTest(){
        String usrId = userInfo.getUserId();
		List<User> lstUser = new List<User>();
		lstUser = [SELECT id,DefaultCurrencyIsoCode,Country__c from User where id=:usrId];
        List<Account> lstAccts = TestDataFactoryUtil.createAccount(1,'B2B');
        AccountFleet__c acc = new AccountFleet__c();
        acc.Account__c = lstAccts[0].id;
        test.startTest();
        insert acc;
        test.stopTest();
        
    }
}
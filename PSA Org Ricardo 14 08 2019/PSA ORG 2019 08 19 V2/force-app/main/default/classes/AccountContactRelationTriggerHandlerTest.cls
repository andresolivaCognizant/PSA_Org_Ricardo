@isTest
private class AccountContactRelationTriggerHandlerTest {

	@TestSetup
	static void TestSetup(){
        List<Account> lstNewAcc = new List<Account>{
		 new Account(
			Name = 'Test'
		),
         new Account(
			Name = 'Test2'
         )}; 
    	Insert lstNewAcc;

   		Contact cnt             =   new Contact (
        		FirstName           =   'TEST ' ,
        		LastName            =   'matching',
        		Salutation          =   '1',
        		Birthdate           =   Date.today() - 23,
        		AccountId           =   lstNewAcc.get(1).Id,
        		Phone               =   '+56585458548'
    	);
    	Insert cnt;
	}

    @isTest static void matchTechC1stKey() {
		Test.startTest();
			List<AccountContactRelation> lstAcc = [SELECT Id, TechC1stKey__c, Account.Name, Contact.Name FROM AccountContactRelation];
			System.assertEquals(lstAcc[0].AccountId + '_' + lstAcc[0].ContactId, lstAcc[0].TechC1stKey__c);
		Test.stopTest();		
	}
    
    @isTest static void TriggerStaticMethodsTest() {
		Test.startTest();
			Boolean bOKResult = AccountContactRelationTriggerHandler.shouldRunTrigger();
        	AccountContactRelationTriggerHandler.dontRunTrigger();
        	Boolean bKOResult = AccountContactRelationTriggerHandler.shouldRunTrigger();
			System.assertEquals(true,bOKResult);
        	System.assertEquals(false,bKOResult);
		Test.stopTest();
	}
}
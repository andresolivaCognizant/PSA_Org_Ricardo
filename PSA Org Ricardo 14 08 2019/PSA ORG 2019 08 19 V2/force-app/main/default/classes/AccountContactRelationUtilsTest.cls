@isTest
private class AccountContactRelationUtilsTest {

	@TestSetup
	static void TestSetup(){
		Account acc = new Account(
			Name = 'Test'
		); 

   		insert acc;

		Account acc2 = new Account(
		Name = 'Test2'
		); 

    	insert acc2;

   		Contact cnt             =   new Contact (
        		FirstName           =   'TEST ' ,
        		LastName            =   'matching',
        		Salutation          =   '1',
        		Birthdate           =   Date.today() - 23,          
        		AccountId           =   acc2.Id,
        		Phone               =   '+56585458548'
        
    	);

    	insert cnt;
	}
	
    @isTest static void matchTechC1stKey() {
		Test.startTest();
			List<AccountContactRelation> lstAcc = [SELECT Id, TechC1stKey__c, Account.Name, Contact.Name FROM AccountContactRelation];
			System.assertEquals(lstAcc[0].AccountId + '_' + lstAcc[0].ContactId, lstAcc[0].TechC1stKey__c);
		Test.stopTest();		
	}
}
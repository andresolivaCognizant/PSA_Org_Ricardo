/**
	*   @Class : APB014_AccountMergeTest
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   30 08 2018
	*   @Description    :   Test for APB014_AccountMerge batch
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer			Date			Description	
	*	   Raul Barba			30/08/2018		Creation.
	*	   Ricardo Pereira		25/06/2019		Refactored. Created testSetup method.
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
public class APB014_AccountMergeTest {

	@TestSetup
	static void setup(){
		// Test data setup
		/* List<Account> lstAccts = new List<Account>();
		for(integer i=0;i<3;i++){
			Account acc             =   new Account (
				Name           =   'Prueba' + i
			);
			lstAccts.add(acc);
		}
		insert lstAccts; */
		

		/////////////////ACCOUNT CREATION\\\\\\\\\\\\\\\\\\\\\\
		List<Account> lstDealers = TestDataFactoryUtil.createAccount( 1, 'Dealer');
		List<Account> lstAccounts = TestDataFactoryUtil.createPersonAccount( 3 );
		
		// Retrieve calculated fields
		lstAccounts = [SELECT Id, PersonContactId FROM Account WHERE Id IN :lstAccounts];

		
		////////////////////ACC EXTERNAL REFERENCES\\\\\\\\\\\\\\\
		List<AccountExtRef__c> lstAcctsExt = new List<AccountExtRef__c>();
		for(account acc : lstAccounts){
			
			AccountExtRef__c accExtRef = new AccountExtRef__c (
				Account__c = acc.id,
				System__c = 'MDM',
				ExternalId__c = 'Ext' + acc.id
			);
			
			lstAcctsExt.add(accExtRef);
		}

		insert lstAcctsExt;


		/////////////////CONSENT CREATION\\\\\\\\\\\\\\\\\\\\
		List<Consent__c> lstConsents = new List<Consent__c>();
		
		lstConsents.add(new Consent__c (
			Contact__c = lstAccounts[1].PersonContactId, 
            DocumentBrand__c = 'AC', 
            CollectedEntityId__c = lstDealers[0].Id, 
            CollectedCountry__c = 'AF', 
            Purpose__c = 'Cookies', 
            CheckBox2Meaning__c = 'MkgGroup', 
            CheckBox2Value__c = true,
			CheckBox3Meaning__c = 'MkgPOSPhoneSMS', 
            CheckBox3Value__c = true, 
            CheckBox4Meaning__c = 'MkgBrandPhoneSMS', 
            CheckBox4Value__c = true, 
            CheckBox5Meaning__c = 'MkgGroupPhoneSMS', 
            CheckBox5Value__c = true, 
            CheckBox6Meaning__c = 'MkgPOSMail', 
            CheckBox6Value__c = true));

		lstConsents.add(new Consent__c (
			Contact__c = lstAccounts[2].PersonContactId, 
            DocumentBrand__c = 'AC', 
            CollectedEntityId__c = lstDealers[0].Id, 
            CollectedCountry__c = 'AF', 
            Purpose__c = 'Cookies', 
            CheckBox2Meaning__c = 'MkgGroup', 
            CheckBox2Value__c = true,
			CheckBox3Meaning__c = 'MkgPOSPhoneSMS', 
            CheckBox3Value__c = true, 
            CheckBox4Meaning__c = 'MkgBrandPhoneSMS', 
            CheckBox4Value__c = true, 
            CheckBox5Meaning__c = 'MkgGroupPhoneSMS', 
            CheckBox5Value__c = true, 
            CheckBox6Meaning__c = 'MkgPOSMail', 
            CheckBox6Value__c = true));
		
		insert lstConsents;
	}

	@isTest static void AccountMergeTest() {
		
		List<Account> lstAccounts = [SELECT Id, PersonContactId 
									FROM Account 
									WHERE Name LIKE 'Account_%' 
									AND IsPersonAccount = true];
		
		

		List<CustomerMergeEntry__c> lstCme = new List<CustomerMergeEntry__c>();

		lstCme.add(new CustomerMergeEntry__c (
			Status__c = '0',
			RequestDate__c = Date.today(),
			MasterCustomer__c = lstAccounts[0].id,
			SlaveCustomer__c = lstAccounts[1].id
		));
		
		lstCme.add(new CustomerMergeEntry__c (
			Status__c = '0',
			RequestDate__c = Date.today(),
			MasterCustomer__c = lstAccounts[0].id,
			SlaveCustomer__c = lstAccounts[2].id
		));
		
		insert lstCme;


		// Perform test
		Test.startTest();
		System.assertEquals(2, [select Id from CustomerMergeEntry__c where Status__c = '0'].size());
		APB014_AccountMerge b = new APB014_AccountMerge();
		Database.executeBatch(b,60); 
		Test.stopTest();
		
		System.assertEquals(0, [select Id from CustomerMergeEntry__c where Status__c = '0'].size());
		System.assertEquals(2, [select Id from CustomerMergeEntry__c where Status__c = '2'].size());
		System.assertEquals(0, [select Id from CustomerMergeEntry__c where Status__c = '3'].size());

	}
	
	@isTest static void AccountMergeTestForceException() {
		
		List<Account> lstAccounts = [SELECT Id, PersonContactId 
									FROM Account 
									WHERE Name LIKE 'Account_%' 
									AND IsPersonAccount = true];
		
		

		List<CustomerMergeEntry__c> lstCme = new List<CustomerMergeEntry__c>();

		lstCme.add(new CustomerMergeEntry__c (
			Status__c = '0',
			RequestDate__c = Date.today(),
			MasterCustomer__c = lstAccounts[0].id,
			SlaveCustomer__c = lstAccounts[0].id
		));
		
		
		insert lstCme;


		// Perform test
		Test.startTest();
		APB014_AccountMerge b = new APB014_AccountMerge();
		Database.executeBatch(b,60); 
		Test.stopTest();
		
	}

}
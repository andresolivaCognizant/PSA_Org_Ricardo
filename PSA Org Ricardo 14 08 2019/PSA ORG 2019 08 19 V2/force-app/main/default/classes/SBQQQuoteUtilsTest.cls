/**
 * Salesforce
 * @author              Antoine Audollent
 * Project:             PSA - Customer First
 * Description:         Unit tests to cover class SBQQQuoteUtils
 * Changes (version)
 * -------------------------------------------------------------------------------------------------
 *              No.     Date            Author                  Description
 *              ----    ------------    --------------------    ------------------------------------
 * @version     1.0     2019-05-10      Antoine Audollent       Class creation.
 *                                                              Code coverage: % (minimum)
 * 				1.1		2019-06-26		Ruben Fernandez			Added Setup and executed the test as
 * 																a Sales Manager.
 * 				1.2		2019-07-11		Nerea Leguinazabal		#C1STAGILE-16994: Use TestDataFactoryUtil for Data creation
 */
@isTest
private class SBQQQuoteUtilsTest {

	 @testSetup static void setup() {

        List<String> lstActivities              =   new List<String>{'VN'};
        List<Contact> lstContsA                 =   TestDataFactoryUtil.createPartnerUser(1, 1, 'Dealer', '133225511','1247770', 'EXTKEY0069','AP','PT', 'J',lstActivities,true);
        List<User> lstUsers1                    =   TestDataFactoryUtil.createUser(lstContsA,'Sales_Manager','Partner','Manager');
		Insert lstUsers1;
        
        // --> Needed to test CPQ otherwise not possible to reach 100% of coverage
        List<PermissionSet> lstPS               = new List<PermissionSet>([SELECT Id FROM PermissionSet WHERE Name = 'ExtraPermissionSetsforCPQUsersinPartnerCommunity']);
        List<PermissionSetAssignment> lstPSA    = new List<PermissionSetAssignment>();
        System.runAs(new User(Id = Userinfo.getUserId())) {
            for(User u : lstUsers1){
                PermissionSetAssignment psa     = new PermissionSetAssignment();
                psa.AssigneeId                  = u.Id;
                psa.PermissionSetId             = lstPS.get(0).Id;
                lstPSA.add(psa);
            }
            Insert lstPSA;
        }
    }

	@isTest static void test_method_one() {
		List<Account> MyDealer = new List<Account>([Select Id, OrderFormValidation__c From Account Where RecordTypeId =:AccountConstants.ACCOUNT_RT_DEALER AND Name Like 'DEALER_Account_%' AND CreatedDate >= TODAY AND OwnerId =: UserInfo.getUserId() ]);
		MyDealer.get(0).OrderFormValidation__c 	= true;
		update MyDealer;
		List<SBQQ__Quote__c> lNewQuotes 		= new List<SBQQ__Quote__c>();
		Map<Id, SBQQ__Quote__c> mapOldQuotes 	= new Map<Id, SBQQ__Quote__c>();
		User usr                            	= [SELECT Id, Contact.AccountId,Contact.Account.CommunicationMode__c 
													FROM User 
													WHERE Profile.Name = 'Sales_Manager' AND IsActive=true AND CreatedDate >= TODAY LIMIT 1];        
        //System.runAs(usr) {   
			Account b2c = new Account(
				FirstName 	= 'Account FirstName',
				LastName 	= 'Account LastName',
				Salutation 	= '1',
				Country__c 	= 'ES',
				PersonalEmail__pc = 'b2c@test.com',
				RecordTypeId = AccountConstants.ACCOUNT_RT_B2C,
				CompanyActivityType__c = '0'
			);

			insert b2c;
			
			Id rtOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('FleetRequestOpportunity').getRecordTypeId();

			Opportunity opp1 	= new Opportunity(
				CloseDate 		= system.today()+180, 
				Name 			= 'Test', 
				StageName 		= '2',
				RecordTypeId 	= rtOpp,  
				Country__c 		= 'ES',
				AccountId 		= b2c.Id
			);

			insert opp1;
			
			Opportunity opp = new Opportunity(
				CloseDate = system.today()+180, 
				Name = 'Test', 
				StageName = '2',
				Country__c = 'ES',
				RecordTypeId = rtOpp,
				ParentOpportunity__c = opp1.Id,
				AccountId = b2c.Id
			);

			insert opp;	   	
			
			Id rtQuote = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('OPV_OrderForm_VO').getRecordTypeId();

			
			SBQQ__Quote__C quote = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
				'SalesManagerValidationFlag__c'		=> false,
				'SBQQ__ExpirationDate__c' 			=> system.today()-1,
				'SBQQ__Status__c'    				=> '1',
				'SBQQ__Opportunity2__c'  			=> opp.Id,
				'RecordTypeId'						=> rtQuote,
				'SBQQ__Account__c'					=> b2c.Id
			} ,false); 	   	

			Test.startTest();
				insert quote;
				lNewQuotes.add(quote);
				quote.SBQQ__Status__c = '2';
				update quote;
				mapOldQuotes.put(quote.Id, quote);
				SBQQQuoteUtils.checkProcess(lNewQuotes, mapOldQuotes);
			Test.stopTest();
		//}		
	}
	@isTest static void createQuoteWithOutOpportunityTest() {
		List<Account> MyDealer = new List<Account>([Select Id, OrderFormValidation__c From Account Where RecordTypeId =:AccountConstants.ACCOUNT_RT_DEALER AND Name Like 'DEALER_Account_%' AND CreatedDate >= TODAY AND OwnerId =: UserInfo.getUserId() ]);
		MyDealer.get(0).OrderFormValidation__c 	= true;
		update MyDealer;
		List<SBQQ__Quote__c> lNewQuotes 		= new List<SBQQ__Quote__c>();
		Map<Id, SBQQ__Quote__c> mapOldQuotes 	= new Map<Id, SBQQ__Quote__c>();
		User usr                            	= [SELECT Id, Contact.AccountId,Contact.Account.CommunicationMode__c 
													FROM User 
													WHERE Profile.Name = 'Sales_Manager' AND IsActive=true AND CreatedDate >= TODAY LIMIT 1];        
        //System.runAs(usr) {   
			Account b2c = new Account(
				FirstName 	= 'Account FirstName',
				LastName 	= 'Account LastName',
				Salutation 	= '1',
				Country__c 	= 'ES',
				PersonalEmail__pc = 'b2c@test.com',
				RecordTypeId = AccountConstants.ACCOUNT_RT_B2C,
				CompanyActivityType__c = '0'
			);

			insert b2c;
			
			Id rtQuote = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('OPV_OrderForm_VO').getRecordTypeId();

			
			SBQQ__Quote__C quote = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
				'SalesManagerValidationFlag__c'		=> false,
				'SBQQ__ExpirationDate__c' 			=> system.today()-1,
				'SBQQ__Status__c'    				=> '2',
				'RecordTypeId'						=> rtQuote,
				'SBQQ__Account__c'					=> b2c.Id
			} ,false); 	   	

			Test.startTest();
				insert quote;
			Test.stopTest();
			System.assertNotEquals(null, quote.id,'QUOTE NOT CREATED');
		//}		
	}
	@isTest static void createAutomaticContactTask() {
		List<Account> MyDealer = new List<Account>([Select Id, OrderFormValidation__c From Account Where RecordTypeId =:AccountConstants.ACCOUNT_RT_DEALER AND Name Like 'DEALER_Account_%' AND CreatedDate >= TODAY AND OwnerId =: UserInfo.getUserId() ]);
		MyDealer.get(0).OrderFormValidation__c 	= true;
		update MyDealer;
		List<SBQQ__Quote__c> lNewQuotes 		= new List<SBQQ__Quote__c>();
		Map<Id, SBQQ__Quote__c> mapOldQuotes 	= new Map<Id, SBQQ__Quote__c>();
		User usr                            	= [SELECT Id, Contact.AccountId,Contact.Account.CommunicationMode__c 
													FROM User 
													WHERE Profile.Name = 'Sales_Manager' AND IsActive=true AND CreatedDate >= TODAY LIMIT 1];        
        //System.runAs(usr) {   
			Account b2c = new Account(
				FirstName 	= 'Account FirstName',
				LastName 	= 'Account LastName',
				Salutation 	= '1',
				Country__c 	= 'ES',
				PersonalEmail__pc = 'b2c@test.com',
				RecordTypeId = AccountConstants.ACCOUNT_RT_B2C,
				CompanyActivityType__c = '0'
			);

			insert b2c;

			
			SBQQ__Quote__C quote = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
				'SalesManagerValidationFlag__c'		=> false,
				'SBQQ__ExpirationDate__c' 			=> system.today()-1,
				'SBQQ__Status__c'    				=> '2',
				'RecordTypeId'						=> PAD.getRecordTypeIdByDeveloperName(Constants.SOT_SBQQ_QUOTE,'OPV_Quote'),
				'SBQQ__Account__c'					=> b2c.Id
			} ,false); 	   	

			Test.startTest();
				insert quote;
			Test.stopTest();
			System.assertNotEquals(null, quote.id,'QUOTE NOT CREATED');
		//}		
	}
}
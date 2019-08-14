/*-----------------------------------------------------------------------------------------------------------//
* Class Name	: FlowOppTypeInputControllerTest
* Project		: PSA - C1ST
* Author		: Ricardo Pereira
* Date			: 05/07/2019
* Description	: Test class for FlowOppTypeInputController
*
* @Private
*               1.
*-----------------------------------------------------------------------------------------------------------*/
@isTest
public class FlowOppTypeInputControllerTest {

	@TestSetup
	static void setup(){

		/////////////////PARTNER USER\\\\\\\\\\\\\\\\\\\\\\\\\
		List<String> lstActivities = new List<String>{'VN','VD'};
        List<Contact> lstContacts = TestDataFactoryUtil.createPartnerUser(1, 1, 'Dealer', '133225511','1237770', 'EXTKEY0002','AP','PT', 'J',lstActivities,true);
        List<User> lstUsers1 = TestDataFactoryUtil.createUser(lstContacts,'Sales_Manager','Partner','Manager');
        insert lstUsers1;

		////////////////////CUSTOMER\\\\\\\\\\\\\\\\\\\\\\\\\\
		List<Account> lstAccounts = TestDataFactoryUtil.createPersonAccount( 1 );
		lstAccounts[0].OwnerId = lstUsers1[0].Id;
		update lstAccounts;

	}

	@isTest
	private static void getTypeOptions_TEST(){

		User partnerUser = [SELECT Id, Name FROM User WHERE LastName = 'Testing' AND email  LIKE '%@example%.org'];

		System.runAs(partnerUser){
			Test.startTest();
			FlowOppTypeInputController.getTypeOptions('ES');
			Test.stopTest();
		}
		// NOTE This method can not be asserted, as the result depends on the configured UtilSetting__mdt

	}
	
	@isTest
	private static void getOpportunityOptions_TEST(){

		User partnerUser = [SELECT Id, Name FROM User WHERE LastName = 'Testing' AND email  LIKE '%@example%.org' AND IsActive = true];
		Account customer = [SELECT Id, Name FROM Account WHERE Name LIKE 'Account_%' AND IsPersonAccount = true AND PersonalEmail__pc LIKE 'test%@example.com'];

		System.runAs(partnerUser){

			// Opp needs to be created by partner user
			List<Opportunity> lstOpps = TestDataFactoryUtil.createOpportunities(3, 'VN', customer, 50000, '2', 35);
			System.debug('##RP## lstOpps: ' + lstOpps);

			lstOpps[0].Activity__c = 'VD';
			update lstOpps[0];
			//List<Opportunity> lstVDOpps = TestDataFactoryUtil.createOpportunities(1, 'VD', customer, 50000, '2', 35);
			//System.debug('##RP## lstVDOpps: ' + lstVDOpps);

			Test.startTest();
			FlowOppTypeInputController.ComboboxOption[] lstVNOptions 
				= FlowOppTypeInputController.getOpportunityOptions(customer.Id, 'VN');

			FlowOppTypeInputController.ComboboxOption[] lstVDOptions 
				= FlowOppTypeInputController.getOpportunityOptions(customer.Id, 'VD');

			Test.stopTest();

			System.assertEquals(3, lstVNOptions.size()); // Expects 3 because there is a third 'NoOne' Option 
			System.assertEquals(2, lstVDOptions.size());

			Boolean assertContent = false;
			for(FlowOppTypeInputController.ComboboxOption opt:lstVDOptions){
				if(String.isNotEmpty(opt.value) && opt.value == lstOpps[0].Id){
					assertContent = true;
					break;
				}
			}

			System.assert(assertContent); // This assert ensures the options list contains the correct Opp
		}
	}

}
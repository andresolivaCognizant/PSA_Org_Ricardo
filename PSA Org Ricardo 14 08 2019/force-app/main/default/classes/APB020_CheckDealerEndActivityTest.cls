/**
	*   @Class 			: APB020_CheckDealerEndActivityTest
	*   @Author         : Pedro Párraga
	*   @Created        : 10 Juli 2019
	*   @Description    : Test for APB020_CheckDealerEndActivity
	*
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Pedro Párraga			11/06/2019				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
private class APB020_CheckDealerEndActivityTest {
	
	@testSetup static void setup() {
        Account accDealer = new Account(
                Name                =   'TEST MATCH',
                Phone               =   '+843434',
                BillingPostalCode   =   '23456',
                FiscalId__c         =   '30.686.957-4',
                RecordTypeiD        =   PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_DEALER),
                TECH_PublicGroups__c=   userInfo.getUserId(),
                VNContractEndDate__c = System.today()-1
        );
        
        insert accDealer;
	}
	
	@isTest static void APB020_CheckDealerEndActivity() {
        Test.startTest();
        	APB020_CheckDealerEndActivity b = new APB020_CheckDealerEndActivity(); 
            Database.executeBatch(b,60); 
            Account acc = [SELECT Id, VNContractEndDate__c FROM Account LIMIT 1];
            System.assertEquals(acc.VNContractEndDate__c, System.today()-1);
        Test.stopTest();
	}
	
}
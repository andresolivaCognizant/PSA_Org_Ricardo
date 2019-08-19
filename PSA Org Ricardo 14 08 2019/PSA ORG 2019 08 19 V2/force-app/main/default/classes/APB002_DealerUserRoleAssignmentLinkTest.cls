/**
	*   @Class 			: APB002_DealerUserRoleAssignmentLinkTest
	*   @Author         : Pedro Párraga
	*   @Created        : 10 Juli 2019
	*   @Description    : Test for APB002_DealerUserRoleAssignmentLink
	*
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Pedro Párraga			11/06/2019				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
private class APB002_DealerUserRoleAssignmentLinkTest {

	@testSetup static void setup(){
        Account accDealer = new Account(
                Name                =   'TEST MATCH',
                Phone               =   '+843434',
                BillingPostalCode   =   '23456',
                FiscalId__c         =   '30.686.957-4',
                RecordTypeiD        =   PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_DEALER),
                TECH_PublicGroups__c=   userInfo.getUserId(),
                VNPrincipalSite__c  = true,
                TECH_SalesManager__c =  userInfo.getUserId()
        );
        
        insert accDealer;

        PartnerAccountLink__c part = new PartnerAccountLink__c(
                ProviderId__c = accDealer.Id, 
                SubscriberId__c = accDealer.Id,
                EndDate__c = System.today().addDays(30));
		insert part;		
	}
	
	@isTest static void APB002_DealerUserRoleAssignmentLink() {
		List<Account> lstAcc = [SELECT Id, TECH_SalesManagerAgent__c FROM Account LIMIT 1];

        Test.startTest();
        	APB002_DealerUserRoleAssignmentLink b = new APB002_DealerUserRoleAssignmentLink(lstAcc); 
            Database.executeBatch(b,60); 
            System.assertEquals(null, lstAcc[0].TECH_SalesManagerAgent__c);     	
        Test.stopTest();
	}
}
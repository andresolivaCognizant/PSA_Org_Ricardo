/**
	*   @Class 			: APB020_ServiceResourceUserInactiveTest
	*   @Author         : Pedro Párraga
	*   @Created        : 10 Juli 2019
	*   @Description    : Test for APB020_ServiceResourceUserInactive
	*
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Pedro Párraga			11/06/2019				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
private class APB020_ServiceResourceUserInactiveTest {
	
	@testSetup static void setup() {
        List<User> lstUsers 	= new List<User>();
    	lstUsers.add(TestDataFactoryUtil.createOneUser('PSA_Admin', 'PSA', 'AP', 'FR', '9876543'));
    	insert lstUsers;		
	}
	
	@isTest static void APB020_ServiceResourceUserInactive() {
		List<User> lstUser = [SELECT Id FROM User WHERE Profile.Name = 'PSA_Admin' AND IsActive = true LIMIT 1];
        Account accDealer = new Account(
                Name                =   'TEST MATCH',
                Phone               =   '+843434',
                BillingPostalCode   =   '23456',
                FiscalId__c         =   '30.686.957-4',
                RecordTypeiD        =   PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_DEALER),
                TECH_PublicGroups__c=   userInfo.getUserId()
        );
        
        insert accDealer;

		ServiceResource sr1 		= new ServiceResource(
			RelatedRecordId 		= lstUser[0].Id, 
			Name 					= 'Name245', 
			IsActive 				= false, 
			IsCapacityBased 		= false, 
			IsOptimizationCapable 	= false, 
			EnergyCode__c	 		= '581', 
			EnergyDescription__c 	= 'Energ334', 
			FamilyCode__c 			= '969', 
			FamilyDescription__c 	= 'Famil127', 
			GearboxCode__c 			= '1', 
			GearboxDescription__c 	= 'Gearb930', 
			ShapeCode__c 			= '19', 
			ShapeDescription__c 	= 'Shape726', 
			IsAvailable__c 			= true, 
			Country__c 				= 'FR',
            Account__c				= accDealer.Id
		);

		insert sr1;

        Test.startTest();     	
    		APB020_ServiceResourceUserInactive b = new APB020_ServiceResourceUserInactive(); 
            Database.executeBatch(b,60); 
        Test.stopTest();

        List<User> lstUserResult = [SELECT Id, IsActive FROM User WHERE Profile.Name = 'PSA_Admin' LIMIT 1];
        System.assertEquals(false, lstUserResult[0].IsActive);
	}
	
}
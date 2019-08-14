/*********************************************************************************************************
* Project:          C1ST: CORE - DMS
* Description:      Test class FOR ServiceResourceTriggerHandler apex class.
*
* COVERAGE:         ServiceResourceTriggerHandler --> 00%
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description
*           -----   ----------      --------------------    ---------------
* @version 	1.0     2019-03-01      Ruben Fernandez (RF)    Initial definition.
*                                                           + sSERVERAfterSalesAccountTest
*                                                           + sSERVERAfterSalesAssetTest
*                                                           + sSERVERAfterSalesAccountAssetTest
*                                                           + sSERVERSalesOrderTest
*                                                           + sSERVERSalesQuoteTest
*                                                           + sCORSSalesQuoteTest
*********************************************************************************************************/
@isTest 
public class ServiceResourceTriggerHandlerTest {

    @testSetup static void setup() {

        List<User> lstUsers 	= new List<User>();
    	lstUsers.add(TestDataFactoryUtil.createOneUser('PSA_Admin', 'PSA', 'AP', 'FR', '9876543'));
        lstUsers.add(TestDataFactoryUtil.createOneUser('PSA_Admin', 'PSA', 'AC', 'FR', '6876544'));
		Insert lstUsers;
        
        // --> Needed to test CPQ otherwise not possible to reach 100% of coverage
        List<PermissionSet> lstPS               = new List<PermissionSet>([SELECT Id FROM PermissionSet WHERE Name = 'ExtraPermissionSetsforCPQUsersinPartnerCommunity']);
        List<PermissionSetAssignment> lstPSA    = new List<PermissionSetAssignment>();
        System.runAs(new User(Id = Userinfo.getUserId())) {
            for(User u : lstUsers){
                PermissionSetAssignment psa     = new PermissionSetAssignment();
                psa.AssigneeId                  = u.Id;
                psa.PermissionSetId             = lstPS.get(0).Id;
                lstPSA.add(psa);
            }
            //Insert lstPSA;
        }
    }
    
    /* Testing ServiceResource Update */
    @isTest static void sServiceResourceOKTest(){
        List<User> lstUsers 	= [Select Id From User Where Profile.Name = 'PSA_Admin' AND IsActive = true Limit 2];
        List<Account> lstAcc	= new List<Account>{new Account(
		  Name            = 'Test Dealer 1',
		  RecordTypeId    = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account_DealerPartner').getRecordTypeId()
        )};
		Insert lstAcc;
        
		List<ServiceResource> lstSerRes = new List<ServiceResource>();
		ServiceResource sr1 		= new ServiceResource(
			RelatedRecordId 		= lstUsers[0].Id, 
			Name 					= 'Name245', 
			IsActive 				= true, 
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
            Account__c				= lstAcc.get(0).Id
		);
        ServiceResource sr2 		= new ServiceResource(
          	RelatedRecordId 		= lstUsers[1].Id, 
          	Name 					= 'Name246', 
          	IsActive 				= true, 
          	IsCapacityBased 		= false, 
          	IsOptimizationCapable 	= false, 
          	EnergyCode__c 			= '582', 
          	EnergyDescription__c 	= 'Energ335', 
          	FamilyCode__c 			= '966',
          	FamilyDescription__c 	= 'Famil128', 
          	GearboxCode__c 			= '1', 
          	GearboxDescription__c 	= 'Gearb930', 
          	ShapeCode__c 			= '19', 
          	ShapeDescription__c 	= 'Shape726', 
          	IsAvailable__c 			= true, 
          	Country__c 				= 'FR',
            Account__c				= lstAcc.get(0).Id
        );
        lstSerRes.add(sr1); 
        lstSerRes.add(sr2);
        Insert lstSerRes; 
        
        Test.startTest();
            Boolean bRun = ServiceResourceTriggerHandler.shouldRunTrigger();
            ServiceResourceTriggerHandler.dontRunTrigger();
            Boolean bDontRun =ServiceResourceTriggerHandler.shouldRunTrigger();
            Boolean bRunbU = ServiceResourceTriggerHandler.testAuxMethod(false);
           	Boolean bRunaU = ServiceResourceTriggerHandler.testAuxMethod(true);
        	lstSerRes.get(0).Country__c = 'PT';
        	Update lstSerRes;
        Test.stopTest();
        
        System.assertEquals(true,bRun);
        System.assertEquals(false,bDontRun);
    }
	/* Testing ServiceResource Update KO*/
  /*  @isTest static void sServiceResourceKOTest(){
        
        Test.startTest();
            Boolean bRunbU 	= ServiceResourceTriggerHandler.testAuxMethod(false);
        	bRunbU 			= ServiceResourceTriggerHandler.testAuxMethod(false);
           	Boolean bRunaU 	= ServiceResourceTriggerHandler.testAuxMethod(true);
        	bRunaU 			= ServiceResourceTriggerHandler.testAuxMethod(true);
        Test.stopTest();
        
        System.assertEquals(true,bRunbU);
        System.assertEquals(false,bRunaU);
    } */
}
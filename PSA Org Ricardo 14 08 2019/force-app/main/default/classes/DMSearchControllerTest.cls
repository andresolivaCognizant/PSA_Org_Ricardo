/**
*   @Class : DMSearchControllerTest
*
*   @Author         :   DXC
*   @Created        :   10 May 2018
*   @Description    :   Test for DMSearchController class
*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*		Developer           	Date                    Description	
*		DXC						10/05/2018				Creation
* 		Ruben Fernandez			08/05/2019				New test method
*       Ruben Fernandez         26/06/2019              New methods:
*                                                       - SearchWithCriterisasAllTest
*                                                       - SearchWithCriterisasAccountTest
*                                                       - SearchWithCriterisasAssetTest
*                                                       - SearchWithCriterisasOppTest
*                                                       Changes:
*                                                       - Test Data moved to Setup
*                                                       - Assertions added
*   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
public with sharing class DMSearchControllerTest {
    
	@testSetup
    static void setup() {
        List<String> lstActivities	= new List<String>{'VN'};
        List<Account> lstAcc		= TestDataFactoryUtil.createPersonAccount(1);
        List<Asset> lstAst			= TestDataFactoryUtil.createAsset(1,lstAcc);
        List<Order> lstOrd			= TestDataFactoryUtil.createOrder(1,'VNOrders','Draft',lstAcc);
        Account a 					= [Select PersonContactId From Account Where Id = :lstAcc.get(0).Id];
        List<Account> lstFullAcc	= TestDataFactoryUtil.createAccount(1,'Dealer');
        // Create Consents and Contactability
        Consent__c consent 	 		= new Consent__c(Contact__c = a.PersonContactId, 
                                            DocumentBrand__c 	= PAD.sUserBrand, 
                                            CollectedEntityId__c= lstFullAcc[0].id, 
                                            CollectedCountry__c = PAD.sUserCountry, 
                                            Purpose__c 			= 'Cookies',
                                            CheckBox1Meaning__c = 'MkgPOSBrand', 
                                            CheckBox1Value__c = false,
                                            CheckBox2Meaning__c = 'MkgPOSBrandEmailSMS', 
                                            CheckBox2Value__c = true,
                                            CheckBox3Meaning__c = 'MkgGroupEmailSMS', 
                                            CheckBox3Value__c = true, 
                                            CheckBox4Meaning__c = 'MkgPartnersEmailSMS', 
                                            CheckBox4Value__c = true);
        Insert consent;
        // Create Campaign and campaignmenber
        map<String, Object> mapApiNameToFieldValueCmp = new map<String, Object>{
            'Name'	  		=>	'New Campaign 2020',
            'Type'			=>	'Email',
            'CustomerType__c'=>	'1',
			'RecordTypeId'	=>	PAD.recordTypesMapByDeveloperName.get(Constants.RT_CAMPAIGN_DMCAMPAIGN)
        };
        Campaign oCmp 		= TestDataFactoryUtil.createCampaign(mapApiNameToFieldValueCmp, true);
        // Create Opportunity
        map<String, Object> mapApiNameToFieldValueOpp = new map<String, Object>{
            'Name'	  		=> 'Test Campaign Opportunity 2020', 
            'Probability'   => 30,
            'Amount'        => 2,
            'AccountId'     => lstACC.get(0).id,
            'CloseDate'     => System.today(),
            'Activity__c'   => 'VN',
            'Country__c'    => PAD.sUserCountry,
            'StageName'     => '1'
        };
        Opportunity Opp = TestDataFactoryUtil.createOpportunities(mapApiNameToFieldValueOpp, true);
    }
    static testMethod void InitMethodsTest(){
        List<Account> lstFullAcc	= new List<Account>([Select Id From Account Where Name Like 'Account_Dealer_%' AND RecordTypeId =:AccountConstants.ACCOUNT_RT_DEALER]); //TestDataFactoryUtil.createAccount(1,'Dealer');
        map<String, Object> mapApiNameToFieldValueCnt = new map<String, Object>{
            'FirstName'	  		=> 'John 01',
            'LastName'			=> 'McFly',
            'Salutation'		=> '1',
            'Email' 			=> 'johnmcflynomail@example.com',
            'Phone' 			=> '981000111',
            'NationalId__c' 	=> '12455678C',
            'AccountId' 		=> lstFullAcc.get(0).Id,
			'AvailableLeadTreatment__c'	=> true
        };
        Contact oCnt				= TestDataFactoryUtil.createContact(mapApiNameToFieldValueCnt,true);
        map<String, Object> mapApiNameToFieldValueCmp = new map<String, Object>{
            'Name'	  		=>	'New Campaign',
            'Type'			=>	'Phone',
            'CustomerType__c'=>	'1',
			'RecordTypeId'	=>	PAD.recordTypesMapByDeveloperName.get(Constants.RT_CAMPAIGN_DMCAMPAIGN)
        };
        Campaign oCmp 		= TestDataFactoryUtil.createCampaign(mapApiNameToFieldValueCmp, true);
    	Test.startTest();  
        	DMSearchController.FieldResponse field = DMSearchController.getselectOptions();
        	String str = '[' + JSON.serializePretty(oCnt.Id) +']';
        	Boolean bAddUser		= DMSearchController.createNewRecords(str,oCmp.Id);
    	Test.stopTest();
   	}
    
    /**
    * This test method is used to test Opportunities
    * Conditions: Run as logged user
    */
    static testMethod void SearchWithCriterisasOppTest(){
		List<Account> lstAcc = new List <Account>([SELECT Id,PersonContactId FROM Account Where OwnerId = :UserInfo.getUserId() AND Country__c =: PAD.sUserCountry]);
        Campaign oCmp 		 = [Select Id From Campaign Where OwnerId = :UserInfo.getUserId() AND CreatedDate >= TODAY];
       	Opportunity oOpp	 = [Select Id From Opportunity Where Name = 'Test Campaign Opportunity 2020'];
        Test.startTest();
           	Id [] fixedSearchResults	= new Id[1];
            fixedSearchResults[0] 		= oOpp.Id;
            Test.setFixedSearchResults(fixedSearchResults);
	      	DMSearchController.findRecords('' , '' ,'Test Campaign Opportunity', '', '{3:1}.CreatedDate' , '>= THIS_MONTH' , null , oCmp.Id, false);
        Test.stopTest();
        System.assertEquals(12, [select id from Contactability__c where Contact__c = : lstAcc.get(0).PersonContactId].size());
        List<Contactability__c> auxResponse = new List<Contactability__c>([select id, Channel__c, ContactabilityStatus__c from Contactability__c where Contact__c = :lstAcc.get(0).PersonContactId AND Channel__c ='eMail' AND ContactabilityStatus__c = true]);
        System.assertEquals(false,auxResponse.isEmpty());
    }
    /**
    * This test method is used to test Vehicles
    * Conditions: Run as logged user
    */
    static testMethod void SearchWithCriterisasAssetTest(){
		List<Account> lstAcc = new List <Account>([SELECT Id,PersonContactId FROM Account Where OwnerId = :UserInfo.getUserId() AND Country__c =: PAD.sUserCountry]);
        Campaign oCmp 		 = [Select Id From Campaign Where OwnerId = :UserInfo.getUserId() AND CreatedDate >= TODAY];
       	Asset oAsset	 	 = [Select Id From Asset Where Name = 'TestAsset0'];
        Test.startTest();
           	Id [] fixedSearchResults	= new Id[1];
            fixedSearchResults[0] 		= oAsset.Id;
            Test.setFixedSearchResults(fixedSearchResults);
        	DMSearchController.findRecords('' , 'TestAsset' , '', '', '{2:1}.CreatedDate', '>= THIS_MONTH', null , oCmp.Id, false);
        Test.stopTest();
        System.assertEquals(12, [select id from Contactability__c where Contact__c = : lstAcc.get(0).PersonContactId].size());
        List<Contactability__c> auxResponse = new List<Contactability__c>([select id, Channel__c, ContactabilityStatus__c from Contactability__c where Contact__c = :lstAcc.get(0).PersonContactId AND Channel__c ='eMail' AND ContactabilityStatus__c = true]);
        System.assertEquals(false,auxResponse.isEmpty());
    }
    /**
    * This test method is used to test Customers
    * Conditions: Run as logged user
    */
    static testMethod void SearchWithCriterisasAccountTest(){
		List<Account> lstAcc = new List <Account>([SELECT Id,PersonContactId FROM Account Where OwnerId = :UserInfo.getUserId() AND Country__c =: PAD.sUserCountry]);
        Campaign oCmp 		 = [Select Id From Campaign Where OwnerId = :UserInfo.getUserId() AND CreatedDate >= TODAY];
       	Account oAcc	 	 = [Select Id From Account Where OwnerId = :UserInfo.getUserId() AND Name Like 'Account%' AND CreatedDate >= TODAY AND RecordTypeId =: AccountConstants.ACCOUNT_RT_B2C AND Country__c =: PAD.sUserCountry ];
        Test.startTest();
           	Id [] fixedSearchResults	= new Id[1];
            fixedSearchResults[0] 		= oAcc.Id;
            Test.setFixedSearchResults(fixedSearchResults);
            DMSearchController.findRecords('Account', '', '', '', '{1:1}.CreatedDate', '>= THIS_MONTH', null, oCmp.Id, false);
        Test.stopTest();
        System.assertEquals(12, [select id from Contactability__c where Contact__c = : lstAcc.get(0).PersonContactId].size());
        List<Contactability__c> auxResponse = new List<Contactability__c>([select id, Channel__c, ContactabilityStatus__c from Contactability__c where Contact__c = :lstAcc.get(0).PersonContactId AND Channel__c ='eMail' AND ContactabilityStatus__c = true]);
        System.assertEquals(false,auxResponse.isEmpty());
    }
    /**
    * This test method is used to test Extended Option
    * Conditions: Run as current user
    */
    static testMethod void SearchWithCriterisasAllTest(){
		List<Account> lstAcc = new List <Account>([SELECT Id,PersonContactId FROM Account Where OwnerId = :UserInfo.getUserId() AND Country__c =: PAD.sUserCountry]);
        Campaign oCmp 		 = [Select Id From Campaign Where OwnerId = :UserInfo.getUserId() AND CreatedDate >= TODAY];
       	Opportunity oOpp	 = [Select Id From Opportunity Where Name = 'Test Campaign Opportunity 2020'];
        Asset oAst	 	 	 = [Select Id From Asset Where Name = 'TestAsset0' AND CreatedDate >= TODAY];
        Account oAcc	 	 = [Select Id From Account Where OwnerId = :UserInfo.getUserId() AND Name Like 'Account%' AND CreatedDate >= TODAY AND RecordTypeId =: AccountConstants.ACCOUNT_RT_B2C AND Country__c =: PAD.sUserCountry ];
        Test.startTest();
           	Id [] fixedSearchResults	= new Id[3];
            fixedSearchResults[0] 		= oOpp.Id;
        	fixedSearchResults[1]		= oAst.Id;
        	fixedSearchResults[2]		= oAcc.Id;
        	DMSearchController.DataTableResponse ltngTableWrapper      = new DMSearchController.DataTableResponse(); 
            Test.setFixedSearchResults(fixedSearchResults);
            ltngTableWrapper = DMSearchController.findRecords('Account' , 'TestAsset' , 'Test Campaign Opportunity' , ' ' , '{1:1}.CreatedDate', 'THIS_MONTH', null, oCmp.Id, true);
        Test.stopTest();
        System.assertEquals(0,ltngTableWrapper.iCampaignMembers);
    }
}
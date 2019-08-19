/******************************************************************************************
* Name: 			OpportunityUtilsTest
* Author: 			Marcos Garcia Garcia
* Description:		Test class for OpportunityUtils class
* 
* Changes (Version)
* -----------------------------------------------------------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2019-05-14		Marcos Garcia Garcia (MGG)	Initial definition.
*******************************************************************************************/
@isTest 
public class OpportunityUtilsTest {

	private static final String CODE_PORTUGAL = 'PT';
	private static final String CODE_PEUGEOUT = 'AP';
	private static final String ROLE_PSA = 'PSA';
	private static final String USER_LDAPID = '9876543';
	private static final String PROFILE_SYSADMIN = 'System Administrator';
	private static final String RT_CAMPAIGN_DMCAMPAIGNID = PAD.recordTypesMapByDeveloperName.get( Constants.RT_CAMPAIGN_DMCAMPAIGN );

	/******************************************************************************************************
	 * @Method          : setup
	 * @Author          : Marcos Garcia Garcia
	 * @Created         : 14/05/2019
	 * @Description     : Setup Method
	 ******************************************************************************************************/
	@testSetup 
	static void setup() {
		User userFromPortugal = TestDataFactoryUtil.createOneUser(PROFILE_SYSADMIN, ROLE_PSA, CODE_PEUGEOUT, CODE_PORTUGAL, USER_LDAPID);
		insert userFromPortugal;

		System.runAs(userFromPortugal){
			Map<String, Object> mapApiNameToFieldValueAccount = new Map<String, Object>();
			mapApiNameToFieldValueAccount.put('Name', 'AccountTest');
			Account account = TestDataFactoryUtil.createAccount(mapApiNameToFieldValueAccount, true);

		   	List<Opportunity> lOpp = TestDataFactoryUtil.createOpportunities(10, '', account, 2, 'New', 30);

		   	Id recordTypeOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('QuickOpportunity').getRecordTypeId();
			Map<String, Object> mapApiNameToFieldValueOpp = new Map<String, Object>{
			'Name'	  		=> 'TestRT_OPP_QUICK', 
			'Probability'   => 30,
			'Amount'        => 2,
			'AccountId'     => account.id,
			'CloseDate'     => System.today(),
			'Activity__c'   => 'VN',
			'Country__c'    => PAD.sUserCountry,
			'StageName'     => '1',
			'RecordTypeId'     => recordTypeOpp
			};
 
			TestDataFactoryUtil.createOpportunities(mapApiNameToFieldValueOpp, true);
		}

		/* BEGIN - Manuel Medina - C1STAGILE-7889 - Test data required for OpportunityUtils.campaignInfluenceProcess method - 22052019 */
		System.runAs( [SELECT Id FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1][0] ){
			List<et4ae5__SendDefinition__c> lstSendDefinitios	= Test.loadData( et4ae5__SendDefinition__c.sObjectType, 'DM_SendDefinitios' );
			List<Campaign> lstCampaigns							= Test.loadData( Campaign.sObjectType, 'DM_Campaigns' );
			List<et4ae5__IndividualEmailResult__c> lstIERs		= Test.loadData( et4ae5__IndividualEmailResult__c.sObjectType, 'DM_IndividualEmailResults' );
			List<Account> lstAccounts							= TestDataFactoryUtil.createPersonAccount( 5 );
			List<Contact> lstCotnacts							= [SELECT Id
																	FROM Contact
																	WHERE AccountId IN: lstAccounts
																];

			Integer i											= 0;
			for( Account objAccount : lstAccounts ){
				objAccount.FirstName							= 'CI_Account ' + i;
				i++;
			}
			
			update lstAccounts;

			for( et4ae5__IndividualEmailResult__c objIER : lstIERs ){
				Integer intIdex									= ( Math.random() * 5 ).intValue();

				objIER.et4ae5__Contact__c						= lstCotnacts.get( intIdex ).Id;
				objIER.et4ae5__DateSent__c						= System.now().addDays( intIdex - 10 );
			}

			update lstIERs;
		}
		/* END - Manuel Medina - 22052019 */
	}

	/******************************************************************************************************
	 * @Method          : getStagesTest
	 * @Author          : Marcos Garcia Garcia
	 * @Created         : 14/05/2019
	 * @Description     : Test Get Stages
	 ******************************************************************************************************/
	@isTest
	public static void getStagesTest(){
	 	List<User> users = new List<User>([Select id, Country__c from User LIMIT 1]);
	 	User u = users.get(0);

		System.runAs(u){
			Map<String,String> stages = OpportunityUtils.getStages();

			System.assertEquals(14, stages.size());
		}
	}

	/******************************************************************************************************
	 * @Method          : getDestinationDealerTest
	 * @Author          : Marcos Garcia Garcia
	 * @Created         : 14/05/2019
	 * @Description     : Test getDestinationDealer
	 ******************************************************************************************************/
	@isTest
	public static void getDestinationDealerTest(){
		List<User> users = new List<User>([Select id, Country__c from User LIMIT 1]);
	 	User u = users.get(0);
		List<Opportunity> opps = new List<Opportunity>([Select Id, OwnerId, DestinationDealerId__c From Opportunity]);

		System.runAs(u){
			OpportunityUtils.getDestinationDealer(opps);
		}
	}

	/******************************************************************************************************
	 * @Method          : shareOAccWthUserTest
	 * @Author          : Marcos Garcia Garcia
	 * @Created         : 14/05/2019
	 * @Description     : Test shareOAccWthUserTest
	 ******************************************************************************************************/
	@isTest
	public static void shareOAccWthUserTest(){
		List<User> users = new List<User>([Select id, Country__c from User LIMIT 1]);
	 	User u = users.get(0);

		List<Opportunity> opps = new List<Opportunity>([Select Id, OwnerId, AccountId From Opportunity]);
		System.runAs(u){
			OpportunityUtils.shareOAccWthUser(opps);
		}
	}

	/******************************************************************************************************
	 * @Method          : changeRecordTypeToStandardOppTest
	 * @Author          : Marcos Garcia Garcia
	 * @Created         : 14/05/2019
	 * @Description     : Test changeRecordTypeToStandardOppTest
	 ******************************************************************************************************/
	@isTest
	public static void changeRecordTypeToStandardOppTest(){
		List<User> users = new List<User>([Select id, Country__c from User LIMIT 1]);
	 	User u = users.get(0);

		List<Opportunity> opps = new List<Opportunity>([Select Id, OwnerId, RecordTypeId From Opportunity where Name like 'TestRT_OPP_QUICK']);
		System.runAs(u){
			OpportunityUtils.changeRecordTypeToStandardOpp(opps);
		}
	}
	
	/******************************************************************************************************
	 * @Method          : processBUIndividualOpp
	 * @Author          : Ruben Fernandez
	 * @Created         : 14/05/2019
	 * @Description     : Test for processBUIndividualOpp method. This method also covers:
	 * 						- getOrderFormFromOpp
	 * 						- createOrderFromOrderForm
	 ******************************************************************************************************/
	@isTest
	public static void processBUIndividualOppTest(){
		List<String> lstActivities  				= new List<String>(); 
		lstActivities.add('VD');
		List<Contact> lstConts      					= TestDataFactoryUtil.createPartnerUser(1, 1, 'Dealer', '133225515','1237775', 'EXTKEY0010','AP','ES', 'J',lstActivities,true);
		List<User> lstUsers         					= TestDataFactoryUtil.createUser(lstConts,'Salesman','Partner','Manager');

		lstUsers.get( 0 ).ByPassApexTriggers__c			= 'Opportunity_AfterInsert;Opportunity_BeforeInsert';
		insert lstUsers;
		
		List<Account> lstAcc;
		List<Opportunity> lstNewOpp;

		System.runAs( lstUsers.get( 0 ) ){
			OpportunityTriggerHandler.dontRunTrigger();
			AccountTriggerHandler.dontRunTrigger();

			lstAcc                   					= TestDataFactoryUtil.createPersonAccount(1);
			lstNewOpp					            	= TestDataFactoryUtil.createOpportunities(1, 'Opportunity_Record_Type',lstAcc.get(0),1000,'6', 25);
		}

		Test.startTest();
		
			List <Opportunity> lstOldOpp            	= TestDataFactoryUtil.createOpportunities(1, 'Opportunity_Record_Type',lstAcc.get(0),1000,'2', 25);
			
			OpportunityTriggerHandler.dontRunTrigger();
			AccountTriggerHandler.dontRunTrigger();

			//System.runAs( lstUsers.get( 0 ) ){
				SBQQ__Quote__c oQuoteCPQ                = new SBQQ__Quote__c(
					ReservedVehicle__c                  = false,  
					SBQQ__Opportunity2__c               = lstNewOpp.get(0).Id,
					SBQQ__Account__c                    = lstAcc.get(0).Id,
					Country__c							= 'PT',
					Brand__c							= 'AP',
					LCDV16__c							= '1CW8AFHLHKB0A020',
					VIN__c								= 'VF72RHNZBJ4330145',
					ProductionYear__c					= System.Today().year(),
					RecordTypeId                        = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('OPVOrderFormVD').getRecordTypeId(), 
					SBQQ__Status__c                     = '2');
				insert oQuoteCPQ;

				OpportunityTriggerHandler.dontRunTrigger();
				AccountTriggerHandler.dontRunTrigger();

				SBQQ__Quote__c oQuote                   = new SBQQ__Quote__c(
					QuotesWithOrderForms__c             = oQuoteCPQ.id,
					ReservedVehicle__c                  = false, 
					RecordTypeId                        = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('CPQ_Order_Form').getRecordTypeId(), 
					SBQQ__Opportunity2__c               = lstOldOpp.get(0).Id, 
					SBQQ__Account__c                    = lstAcc.get(0).Id,
					ProductionYear__c					= System.Today().year(),
					SBQQ__Status__c                     = '1' );
				insert oQuote;
			//}
		
			OpportunityUtils.processBUIndividualOpp(lstNewOpp.get(0),lstOldOpp.get(0));
		Test.stopTest();
		// A new standar Order should be created with same values
		List<Order> lstOrder = new List<Order>([SELECT Id,Country__c,Brand__c,LCDV16__c From Order]);
		System.assertEquals(1, lstOrder.size());
		System.assertEquals('PT', lstOrder.get(0).Country__c);
		System.assertEquals('AP', lstOrder.get(0).Brand__c);
		System.assertEquals('1CW8AFHLHKB0A020', lstOrder.get(0).LCDV16__c);
	}

	/******************************************************************************************************
	 * @Method          : campaignInfluenceProcessTest
	 * @Author          : Manuel Medina
	 * @Created         : 22/05/2019
	 * @Description     : Test for campaignInfluenceProcess method. This method also covers:
	 *						- getAdditionalInfo
	 *						- createContactRole
	 *						- setCampaignFromIER
	 *						- createCampaignInfluence
	 ******************************************************************************************************/
	@isTest
	public static void campaignInfluenceProcessTest(){
		List<Account> lstAccounts								= [SELECT Id
																	FROM Account
																	WHERE FirstName LIKE 'CI_Account%'
																];

		List<Campaign> lstCampaings								= [SELECT Id,
																		PSAVehiculeModelSearch__c
																	FROM Campaign
																];

		PSARangeDescription__c objPSARange						= new PSARangeDescription__c();
		objPSARange.Code__c										= 'TSC1';
		objPSARange.Description__c								= 'Peugeot';
		objPSARange.Type__c										= 'LCDV4';
		objPSARange.Country__c									= 'PT';
		objPSARange.Brand__c									= 'AP';
		insert objPSARange;

		for( Integer i=0; i<lstCampaings.size(); i++ ){
			lstCampaings[i].PSAVehiculeModelSearch__c			= i == 1 ? objPSARange.Id : null;
		}

		update lstCampaings;

		Test.startTest();
			List<Opportunity> lstOpportunities					= new List<Opportunity>();

			for( Integer i=0; i<10; i++ ){
				Integer intIdex									= ( Math.random() * 5 ).intValue();

				Opportunity objOpportunity						= new Opportunity();
				objOpportunity.Name								= 'CI_Opportunity ' + i;
				objOpportunity.AccountId						= lstAccounts.get( intIdex ).Id;
				objOpportunity.StageName						= '1';
				objOpportunity.CloseDate						= System.today().addDays( 30 );
				objOpportunity.Country__c						= 'PT';
				objOpportunity.Brand__c							= 'AP';
				objOpportunity.Activity__c						= 'APV';
				objOpportunity.LCDVInterest__c					= 'TSC1';

				lstOpportunities.add( objOpportunity );
			}

			insert lstOpportunities;

			System.assertEquals( true, ![SELECT Id FROM CampaignInfluence].isEmpty() );
			System.assertEquals( true, ![SELECT Id FROM Opportunity WHERE CampaignId != null].isEmpty() );
			System.assertEquals( true, ![SELECT Id FROM Opportunity WHERE Campaign.PSAVehiculeModelSearch__r.Code__c = 'TSC1'].isEmpty() );
		Test.stopTest();
	}
}
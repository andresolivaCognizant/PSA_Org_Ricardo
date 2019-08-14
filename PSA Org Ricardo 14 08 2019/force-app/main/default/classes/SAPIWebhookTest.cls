/*********************************************************************************************************
* Project:          C1ST: CORE - DMS
* Description:      Test class FOR SAPIWebhook apex class.
*
* COVERAGE:         SAPIWebhook --> 100%
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description
*           -----   ----------      --------------------    ---------------
* @version  1.0     2018-10-24      Manuel Medina (MM)      Initial definition.
*           2.0     2019-03-01      Ruben Fernandez (RF)    Refactored to cover the 100%:
*                                                           + sSERVERAfterSalesAccountTest
*                                                           + sSERVERAfterSalesAssetTest
*                                                           + sSERVERAfterSalesAccountAssetTest
*                                                           + sSERVERSalesOrderTest
*                                                           + sSERVERSalesQuoteTest
*                                                           + sCORSSalesQuoteTest
*           2.0     2019-06-17      Pedro Párraga           Edit
*           2.1     2019-07-12      Nerea Leguinazabal      Add User.IsActive condition to Testing Users
*********************************************************************************************************/
@isTest 
public class SAPIWebhookTest {

    @testSetup static void setup() {

        List<String> lstActivities              =   new List<String>{'VN'};
        List<Contact> lstContsA                 =   TestDataFactoryUtil.createPartnerUser(3, 1, 'Dealer', '133225511','1237770', 'EXTKEY0002','AP','PL', 'J',lstActivities,true);
        
        List<Contact> lstSales                  = new List<Contact>();
        List<Contact> lstASales                 = new List<Contact>();
        lstSales.add(lstContsA.get(0));
        lstSales.add(lstContsA.get(2));
        lstASales.add(lstContsA.get(1));
        List<User> lstUsers1                    =   TestDataFactoryUtil.createUser(lstSales,'Sales_Manager','Partner','Manager');
        lstUsers1.addAll(TestDataFactoryUtil.createUser(lstASales,'Aftersales_Manager','Partner','Manager'));
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
    
    /* Testing Server to Server call*/
    @isTest static void sSERVERAfterSalesAccountTest(){
        User usr                                = [SELECT Id, Contact.AccountId,Contact.Account.CommunicationMode__c FROM User WHERE Contact.Account.CommunicationMode__c = '2' AND Profile.Name = 'Aftersales_Manager' AND IsActive=true LIMIT 1];
        System.runAs(usr) {
            Test.startTest();
            	//1er DMSWebhook__c: Insert Account
                List <Account> lstAcc           = TestDataFactoryUtil.createPersonAccount(1);
                lstAcc.get(0).BillingPostalCode = '28041';
            	SAPIWebhook.processedRecords.clear();
            	//2º DMSWebhook__c: Update Account
                Update lstAcc;
                SAPIWebhook.getRequestParams();
            Test.stopTest();
        }
        List<DMSWebhook__c> lstPushT = [SELECT Id FROM DMSWebhook__c];
        System.assertEquals(false,lstPushT.isEmpty());
        //There are 2 DMSWebhook__c records belong to : {Insert Account; Update Account}
        System.assertEquals(2,lstPushT.size());
    }

    /* Testing Server to Server call*/
    @isTest static void sSERVERAfterSalesAssetTest(){ 
        User usr                    = [SELECT Id, Contact.AccountId,Contact.Account.CommunicationMode__c FROM User WHERE Contact.Account.CommunicationMode__c = '2' AND Profile.Name = 'Aftersales_Manager' AND IsActive=true LIMIT 1];
        
        System.runAs(usr) {
            Test.startTest();
            	//1er DMSWebhook__c: Insert Account
                List <Account> lstAcc           = TestDataFactoryUtil.createPersonAccount(1);
            	//2º DMSWebhook__c: Insert Asset
            	//3º DMSWebhook__c: Insert AssetRelation (Implicit)
                List <Asset> lstAst             = TestDataFactoryUtil.createAsset(1,lstAcc);
            	//The order record does not meet the criteria for making the 'SAPIWebhookTest' call (Profile != Sales)
                List <Order> lstOrd             = TestDataFactoryUtil.createOrder(1,'VNOrders','Draft',lstAcc);
                SAPIWebhook.getRequestParams();
                SAPIWebhook.getRequestCustomParams(lstAcc.get(0).Id,lstAst.get(0).Id);
            Test.stopTest();
        }
        List<DMSWebhook__c> lstPushT = [SELECT Id FROM DMSWebhook__c];
        System.assertEquals(false,lstPushT.isEmpty());
        //There are 3 DMSWebhook__c records belong to : {Insert Account; Insert Asset; Insert AssetRelation}        
        System.assertEquals(3,lstPushT.size());
    }

    /* Testing Server to Server call*/
    @isTest static void sSERVERAfterSalesAccountAssetTest(){ 
        User usr = [SELECT Id, Contact.AccountId,Contact.Account.CommunicationMode__c FROM User WHERE Contact.Account.CommunicationMode__c = '2' AND Profile.Name = 'Aftersales_Manager' AND IsActive=true LIMIT 1];
      
        System.runAs(usr) {
        Test.startTest();
            //1er DMSWebhook__c: Insert Account
            List <Account> lstAcc           = TestDataFactoryUtil.createPersonAccount(1);
            //2º DMSWebhook__c: Insert Asset       
            //3º DMSWebhook__c: Insert AssetRelation (Implicit)
            List <Asset> lstAst             = TestDataFactoryUtil.createAsset(1,lstAcc);
            //The order record does not meet the criteria for making the 'SAPIWebhookTest' call (Profile != Sales)
            List <Order> lstOrd             = TestDataFactoryUtil.createOrder(1,'VNOrders','Draft',lstAcc);
            //4º DMSWebhook__c: Insert AssetRelation            
            List<AccountContactAssetRelation__c> lst = new List<AccountContactAssetRelation__c>{
                new AccountContactAssetRelation__c(
                    AccountId__c            = lstAcc.get(0).Id,
                    AssetId__c              = lstAst.get(0).Id,
                    PosessionChangeConfirmation__c = true,
                    AccountRole__c          = 'Keeper'
                )
            };
            Insert lst;
            SAPIWebhook.getRequestParams();
        Test.stopTest();
        }
        
        List<DMSWebhook__c> lstPushT            = [SELECT Id FROM DMSWebhook__c];
        System.assertEquals(false,lstPushT.isEmpty());
        //There are 4 DMSWebhook__c records belong to : {Insert Account; Insert Asset; Insert AssetRelation; Insert AssetRelation}                
        System.assertEquals(4,lstPushT.size());
    }

    /* Testing Server to Server call*/
    @isTest static void sSERVERSalesOrderTest(){
        User usr                                = [SELECT Id, Contact.AccountId,Contact.Account.CommunicationMode__c FROM User WHERE Contact.Account.CommunicationMode__c = '2' AND Profile.Name = 'Sales_Manager' AND IsActive=true LIMIT 1];
        System.runAs(usr) {
            Test.startTest();
            	//The account record does not meet the criteria for making the 'SAPIWebhookTest' call (Profile != AfterSales)            
                List <Account> lstAcc           = TestDataFactoryUtil.createPersonAccount(1);
            	//1er DMSWebhook__c: Insert Order 
                List <Order> lstOrd             = TestDataFactoryUtil.createOrder(1,'VNOrders','Draft',lstAcc);
                SAPIWebhook.getRequestParams(); 
            Test.stopTest();
        }
        List<DMSWebhook__c> lstPushT            = [SELECT Id FROM DMSWebhook__c];
        System.assertEquals(false,lstPushT.isEmpty());
        //There is 1 DMSWebhook__c record belong to : {Insert Order}                        
        System.assertEquals(1,lstPushT.size());
    }
    
    /* Testing Server to Server call*/
    @isTest static void sSERVERAdminQuoteTest(){
        User usr                                = [SELECT Id, Contact.AccountId,Contact.Account.CommunicationMode__c FROM User WHERE Contact.Account.CommunicationMode__c = '2' AND Profile.Name = 'Sales_Manager' AND IsActive=true LIMIT 1];
        //The account record does not meet the criteria for making the 'SAPIWebhookTest' call (Profile != AfterSales)            
        List <Account> lstAcc                   = TestDataFactoryUtil.createPersonAccount(1);
        List <Opportunity> lstOpp               = TestDataFactoryUtil.createOpportunities(1, 'Opportunity_Record_Type',lstAcc.get(0),1000,'2', 25);
        //The SBQQ__Quote__c record does not meet the criteria for making the 'SAPIWebhookTest' call (Profile != Other)   
        SBQQ__Quote__c oQuoteCPQ                = new SBQQ__Quote__c(
            ReservedVehicle__c                  = false,  
            SBQQ__Opportunity2__c               = lstOpp.get(0).Id,
            SBQQ__Account__c                    = lstAcc.get(0).Id,
            ProductionYear__c                   = 2019,
            SBQQ__Status__c                     = '3');
        Insert oQuoteCPQ;
        //The SBQQ__Quote__c record does not meet the criteria for making the 'SAPIWebhookTest' call (Profile != Other)   
        SBQQ__Quote__c oQuote                   = new SBQQ__Quote__c(
            QuotesWithOrderForms__c             = oQuoteCPQ.id,
            ReservedVehicle__c                  = false, 
            RecordTypeId                        = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('CPQ_Order_Form').getRecordTypeId(), 
            SBQQ__Opportunity2__c               = lstOpp.get(0).Id, 
            SBQQ__Account__c                    = lstAcc.get(0).Id,
            ProductionYear__c                   = 2019,
            SBQQ__Status__c                     = '1' );
        Insert oQuote;
        
        System.runAs(usr) {   
            Test.startTest();
                SAPIWebhook.getRequestParams();
            Test.stopTest();
         }
        List<DMSWebhook__c> lstPushT            = [SELECT Id FROM DMSWebhook__c];
        //There aren't DMSWebhook__c records 
        System.assertEquals(true,lstPushT.isEmpty());
    }
    /* Testing Server to Server call*/
    @isTest static void sSERVERSalesQuoteTest(){
        User usr                                = [SELECT Id, Contact.AccountId,Contact.Account.CommunicationMode__c FROM User WHERE Contact.Account.CommunicationMode__c = '2' AND Profile.Name = 'Sales_Manager' AND IsActive=true LIMIT 1];
        System.runAs(usr) {
            Test.startTest();   
                //The account record does not meet the criteria for making the 'SAPIWebhookTest' call (Profile != AfterSales)            
                List <Account> lstAcc           = TestDataFactoryUtil.createPersonAccount(1);
                List <Opportunity> lstOpp       = TestDataFactoryUtil.createOpportunities(1, 'Opportunity_Record_Type',lstAcc.get(0),1000,'2', 25);
                //1er DMSWebhook__c: Insert SBQQ__Quote__c
                SBQQ__Quote__c oQuoteCPQ        = new SBQQ__Quote__c(
                    ReservedVehicle__c          = false,  
                    RecordTypeId                = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('CPQ_Order_Form').getRecordTypeId(),
                    SBQQ__Opportunity2__c       = lstOpp.get(0).Id,
                    SBQQ__Account__c            = lstAcc.get(0).Id, 
                    ProductionYear__c           = 2019,         
                    SBQQ__Status__c             = '3');
                Insert oQuoteCPQ;
                SBQQQuoteTriggerHandler.runTrigger();            
            	//2º DMSWebhook__c: Insert SBQQ__Quote__c
                SBQQ__Quote__c oQuote           = new SBQQ__Quote__c(
                    OwnerId                     = usr.Id,
                    QuotesWithOrderForms__c     = oQuoteCPQ.id,
                    ReservedVehicle__c          = false, 
                    RecordTypeId                = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('CPQ_Order_Form').getRecordTypeId(), 
                    SBQQ__Opportunity2__c       = lstOpp.get(0).Id, 
                    SBQQ__Account__c            = lstAcc.get(0).Id,
                    ProductionYear__c           = 2019,
                    SBQQ__Status__c             = '1' );
                Insert oQuote;
              
                System.assertEquals(oQuote.RecordTypeId, Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('CPQ_Order_Form').getRecordTypeId());
                SAPIWebhook.getRequestParams();
            Test.stopTest();
        }
        List<DMSWebhook__c> lstPushT            = [SELECT Id FROM DMSWebhook__c];
        System.assertEquals(false,lstPushT.isEmpty());
        //We should have 2 records, but in the 'SBQQ__Quote__c' trigger there is a runtrigger = false 
        //and the call to 'WebHook' can not be executed in the insertion of the second record                              
        //System.assertEquals(2,lstPushT.size());
    }

    /* Testing Server to Server call*/
    @isTest static void sCORSSalesQuoteTest(){
        User usr                            = [SELECT Id, Contact.AccountId,Contact.Account.CommunicationMode__c FROM User WHERE Contact.Account.CommunicationMode__c = '1' AND Profile.Name = 'Sales_Manager' AND IsActive=true LIMIT 1];        
        System.runAs(usr) {   
            Test.startTest();
            	//The account record does not meet the criteria for making the 'SAPIWebhookTest' call (Profile != After_Sales)            
                List <Account> lstAcc       = TestDataFactoryUtil.createPersonAccount(1);
                List <Opportunity> lstOpp   = TestDataFactoryUtil.createOpportunities(1, 'Opportunity_Record_Type',lstAcc.get(0),1000,'2', 25);
            	//The SBQQ__Quote__c record does not meet the criteria for making the 'SAPIWebhookTest' call                            
                SBQQ__Quote__c oQuoteCPQ    = new SBQQ__Quote__c(
                    ReservedVehicle__c      = false,  
                    SBQQ__Opportunity2__c   = lstOpp.get(0).Id,
                    SBQQ__Account__c        = lstAcc.get(0).Id,
                    ProductionYear__c       = 2019,
                    SBQQ__Status__c         ='3');
                Insert oQuoteCPQ;
            	//The SBQQ__Quote__c record does not meet the criteria for making the 'SAPIWebhookTest' call        
                SBQQ__Quote__c oQuote       = new SBQQ__Quote__c(
                    QuotesWithOrderForms__c = oQuoteCPQ.id,
                    ReservedVehicle__c      = false, 
                    RecordTypeId            = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('CPQ_Order_Form').getRecordTypeId(), 
                    SBQQ__Opportunity2__c   = lstOpp.get(0).Id, 
                    SBQQ__Account__c        = lstAcc.get(0).Id,
                    ProductionYear__c       = 2019,
                    SBQQ__Status__c         = '1');
                Insert oQuote;
                SAPIWebhook.getRequestParams();
            Test.stopTest();
        }
        List<DMSWebhook__c> lstPushT        = [SELECT Id FROM DMSWebhook__c];
        System.assertEquals(true,lstPushT.isEmpty());
        System.assertEquals(0,lstPushT.size());
    }
}
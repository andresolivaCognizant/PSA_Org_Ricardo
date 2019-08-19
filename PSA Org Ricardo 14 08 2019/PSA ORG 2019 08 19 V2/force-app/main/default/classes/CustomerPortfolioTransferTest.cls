/**
 * Salesforce
 * @author              Diego Rincón (DR) href=<diego.rincon@ext.mpsa.com>
 * Project:             PSA - Customer First
 * Description:         Unit tests to validate the behavior of CustomerPortfolioTransfer,
 *                      APB019_CustomerPortfolioTransfer and APS019_CustomerPortfolioTransfer
 *                      classes.
 * Changes (version)
 * -------------------------------------------------------------------------------------------------
 *              No.     Date            Author                  Description
 *              ----    ------------    --------------------    ------------------------------------
 * @version     1.0     2018-11-29      Diego Rincón (DR)       Class creation.
 *                                                              Code coverage: 78% (minimum)
 *                                                              Review
 */

@isTest
private class CustomerPortfolioTransferTest {

    @testSetup static void setup() {
        List<Account> lstA = Test.loadData(Account.sObjectType, 'LeadsTestData_PersonAccount');
        List<Contact> lstC = Test.loadData(Contact.sObjectType, 'LeadsTestData_PersonAccountContact');
        // merge to person account - begin
        List<Account> lstB2C = new List<Account>();

/*        for(Account a : lstA) {
            Account p = new Account(
                Id              = a.Id,
                RecordTypeId    = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId() 
                //Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C_PA').getRecordTypeId()
            );
            lstB2C.add(p);
        }

        update lstB2C;*/
        // merge to person account - end
        
        List<Account> lstD              = Test.loadData(Account.sObjectType, 'LeadsTestData_DealerAccount');
        List<Opportunity> lstO          = Test.loadData(Opportunity.sObjectType, 'LeadsTestData_Opportunity');
        List<SBQQ__Quote__c> lstQ       = Test.loadData(SBQQ__Quote__c.sObjectType, 'LeadsTestData_SbqqQuote');
        List<ServiceContract__c> lstS   = Test.loadData(ServiceContract__c.sObjectType, 'LeadsTestData_ServiceContract');

        List<Profile> lstP              = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        if (!lstP.isEmpty()) {
            insert new User(
                ProfileId           = lstP.get(0).Id,
                LastName            = 'LastName',
                Email               = 'user@test.com',
                UserName            = 'customer.portfolio.transfer@test.com',
                Alias               = 'cpt',
                TimeZoneSidKey      = 'America/Los_Angeles',
                EmailEncodingKey    = 'UTF-8',
                LanguageLocaleKey   = 'en_US',
                LocaleSidKey        = 'en_US',
                VNRRDICode__c       = 'VNRRDI1',
                IsActive            = true
            );
        }
        
        TestDataFactoryUtil.createSobject(Constants.SOT_LEAD, new map<String, Object>{
                'FirstName'                 => 'First Name 044',
                'Salutation'                =>  '1',
                'LastName'                  => 'LastName 044',
                'Street'                    => 'Calle Test 472',
                'City'                      => 'Madrid',
                'PostalCode'                => '28012',
                'Latitude'                  =>  39.9691,
                'Longitude'                 => -4.8237,
                'Phone'                     => '915001000',
                'DestinationPOSCode__c'     => '1237771',
                'PSABrand__c'               => 'AP',
                'Email'                     => 'test4@leadexample.com',
                'LeadRequestType__c'        => '1',
                'IdReservationVD__c'        => '12345323X',
                'status'                    => 'Qualified',
                'OwnerId'                   => UserInfo.getUserId(),
                'CustomerType__c'           => '1',
                'RecordTypeId'              => PAD.recordTypesMapByDeveloperName.get(Constants.RT_LEAD_B2C)
        }, true);
        
        
    }

    @isTest static void testMethod1(){
        Test.startTest();
            CustomerPortfolioTransfer.getVnContractList(null);
        Test.stopTest();
    }

    @isTest static void testMethod2(){
        // create a JSONGenerator object
        // pass true to the constructor for pretty print formatting
        JSONGenerator g = JSON.createGenerator(true);

        g.writeStartObject();
            g.writeStringField('vn_contract', 'VNC001');
        g.writeEndObject();

        Test.startTest();
            CustomerPortfolioTransfer.getAgentContractList(g.getAsString());
        Test.stopTest();
    }

    @isTest static void testMethod3(){
        // create a JSONGenerator object
        // pass true to the constructor for pretty print formatting
        JSONGenerator g = JSON.createGenerator(true);

        g.writeStartObject();
            g.writeStringField('vn_contract', 'VNC001');
        g.writeEndObject();

        Test.startTest();
            CustomerPortfolioTransfer.getUserList(g.getAsString());
        Test.stopTest();
    }

    @isTest static void testMethod4(){
        Map<Id, AggregateResult> mapO = new Map<Id, AggregateResult>([
            SELECT COUNT(Id), AccountId Id
            FROM Opportunity
            GROUP BY AccountId
        ]);

        Map<Id, AggregateResult> mapQ = new Map<Id, AggregateResult>([
            SELECT COUNT(Id), SBQQ__Account__c Id
            FROM SBQQ__Quote__c
            GROUP BY SBQQ__Account__c
        ]);

        Map<Id, AggregateResult> mapS = new Map<Id, AggregateResult>([
            SELECT COUNT(Id), Account__c Id
            FROM ServiceContract__c
            GROUP BY Account__c
        ]);

        List<Account> lstB2B = [
            SELECT Id
            FROM Account
            WHERE
                (Id IN :mapO.keySet()) OR
                (Id IN :mapQ.keySet()) OR
                (Id IN :mapS.keySet())
        ];

        List<User> lstU = [SELECT Id FROM User WHERE UserName = 'customer.portfolio.transfer@test.com'];

        for(Account a : lstB2B) {
            a.OwnerId = lstU.get(0).Id;
        }

        update lstB2B;

        // create a JSONGenerator object
        // pass true to the constructor for pretty print formatting
        JSONGenerator g = JSON.createGenerator(true);

        g.writeStartObject();
            g.writeStringField('vn_contract', 'VNC001');
            g.writeFieldName('user_id');
            g.writeStartArray();
                for (User u : [
                        SELECT Id
                        FROM User
                        WHERE Id = :System.UserInfo.getUserId()
                ]) {
                    g.writeString(u.Id);
                }
            g.writeEndArray();
        g.writeEndObject();

        Test.startTest();
            CustomerPortfolioTransfer.getAvailableActivity(g.getAsString());
        Test.stopTest();
    }

    @isTest static void testMethod5(){
        // create a JSONGenerator object
        // pass true to the constructor for pretty print formatting
        JSONGenerator g = JSON.createGenerator(true);

        g.writeStartObject();
            g.writeStringField('vn_contract', 'VNC001');
            g.writeFieldName('source');
                g.writeStartObject();
                g.writeEndObject();
            g.writeFieldName('destination');
                g.writeStartObject();
                    g.writeStringField(
                        'user_id',
                        [SELECT Id FROM User WHERE UserName = 'customer.portfolio.transfer@test.com'].Id
                    );
                g.writeEndObject();
                g.writeFieldName('rows');
                    g.writeStartArray();
                        for (Account a : [
                            SELECT Id
                            FROM Account
                            WHERE IsPersonAccount = true
                        ]) {
                            g.writeString(a.Id);
                        }
                    g.writeEndArray();
        g.writeEndObject();

    // dummy CRON expression: midnight on March 15
    // because this is a test, job executes immediately after Test.stopTest()
    String CRON_EXP = '0 0 0 15 3 ? 2099';

        Test.startTest();
            CustomerPortfolioTransfer.insertTransferRequest(g.getAsString());
            System.schedule(
                'ScheduledApexTest',
                CRON_EXP,
                new APS019_CustomerPortfolioTransfer()
            );
        Test.stopTest();
    }
    
    @isTest
    private static void getCustomerType_LeadB2C_01(){
        
        Lead leadB2C = [Select id,CustomerType__c from Lead where CustomerType__c = '1' Limit 1];
        
        Test.startTest();
        String retStr = CustomerPortfolioTransfer.getCustomerType(leadB2C);
        Test.stopTest();
        
        System.assertEquals('B2C', retStr);
    }
    
    @isTest
    private static void getCustomerType_LeadB2B_01(){

         
        Lead leadB2C = [Select id,CustomerType__c from Lead where CustomerType__c = '1' Limit 1];
        leadB2C.CustomerType__c = '2';
        update leadB2C;
        
        Test.startTest();
        String retStr = CustomerPortfolioTransfer.getCustomerType(leadB2C);
        Test.stopTest();
        
        System.assertEquals('B2B', retStr);
    }
    
    @isTest
    private static void getCustomerType_getBrandStatus_01(){

        String retOKStr;
        String retKOStr;
        String sType;
        
        Test.startTest();
            retOKStr = CustomerPortfolioTransfer.getBrandStatus('Customer');
            retKOStr = CustomerPortfolioTransfer.getBrandStatus('Client');

        Test.stopTest();
            
        System.assertEquals('Customer', retOKStr);
        System.assertEquals(null, retKOStr);
                
    }
    
}
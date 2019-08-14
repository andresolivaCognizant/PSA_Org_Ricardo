/**
    *   @Class          : APS010_ScheduleAssetNextMaintenanceTest
    *   @Author         : Pedro Párraga
    *   @Created        : 28/10/2018
    *   @Description    : Test for APS010_ScheduleAssetNextMaintenance
    *
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description    
    *      Pedro Párraga            18/06/2019               Edit.       
    *   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
private class APS010_ScheduleAssetNextMaintenanceTest {

    // dummy CRON expression: midnight on March 15
    // because this is a test, job executes immediately after Test.stopTest()
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    
    @testSetup static void setup() {
        Account b2c = new Account(
            FirstName           = 'Account FirstName',
            LastName            = 'Account LastName',
            Salutation          = '1',
            PersonalEmail__pc   = 'b2c@test.com',
            RecordTypeId        = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId()
        );

        insert b2c;

        Asset a = new Asset(
            Name                        = 'Asset Test 1',
            AssetType__c                = 'VN',
            CurrencyIsoCode             = 'EUR',
            AccountId                   = b2c.Id,
            FirstRegistrationDate__c    = Date.today().addYears(-1),
            InitialStepKm__c            = 2000,
            InitialStepYear__c          = 1,
            CyclicStepKm__c             = 2000,
            CyclicStepYear__c           = 1
        );

        insert a;

        }

    @isTest static void testMethod1(){

        Asset a = [SELECT Id FROM Asset];

        a.NextMaintenanceDate__c = Date.today().addDays(-1);
        update a;
        
        test.startTest();
            // schedule the test job
             String jobId = System.schedule(
                'ScheduledApexTest',
                CRON_EXP,
                new APS010_ScheduleAssetNextMaintenance()
            );
        test.stopTest();
    }
    
    @isTest static void testMethod2(){

        Asset a = [SELECT Id FROM Asset];

        a.NextMaintenanceDate__c = Date.today().addDays(-1);
        a.Brand__c = 'AP';
        update a;

        test.startTest();
            // schedule the test job
             String jobId = System.schedule(
                'ScheduledApexTest',
                CRON_EXP,
                new APS010_ScheduleAssetNextMaintenance()
            );
        test.stopTest();
    }

    @isTest static void testMethod3(){

        Asset a = [SELECT Id FROM Asset];

        a.NextMaintenanceDate__c = Date.today().addDays(-1);
        a.Country__c = 'ES';
        update a;

        test.startTest();
            // schedule the test job
             String jobId = System.schedule(
                'ScheduledApexTest',
                CRON_EXP,
                new APS010_ScheduleAssetNextMaintenance()
            );
        test.stopTest();
    }

    @isTest static void testMethod4(){

        Asset a = [SELECT Id FROM Asset];

        a.NextMaintenanceDate__c = Date.today().addDays(-1);
        a.Brand__c = 'AP';
        a.Country__c = 'ES';
        update a;

        test.startTest();
            // schedule the test job
             String jobId = System.schedule(
                'ScheduledApexTest',
                CRON_EXP,
                new APS010_ScheduleAssetNextMaintenance()
            );
        test.stopTest();
    }

}
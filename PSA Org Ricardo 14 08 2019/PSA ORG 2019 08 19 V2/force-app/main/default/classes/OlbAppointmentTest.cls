/**
 * Salesforce
 * @author              Diego Rincón (DR) href=<diego.rincon@ext.mpsa.com>
 * Project:             PSA - Customer First
 * Description:         Unit tests to validate the behavior of OlbAppointment class.
 *
 * Changes (version)
 * -------------------------------------------------------------------------------------------------
 *              No.     Date            Author                  Description
 *              ----    ------------    --------------------    ------------------------------------
 * @version     1.0     2019-04-112      Diego Rincón (DR)       Class creation. Code coverage: 90%
 *
 */

@isTest
private class OlbAppointmentTest {

    @isTest static void testMethod1(){
        Lead lea  = new Lead(
                FirstName                   = 'Test 001', 
                LastName                    = 'Version1',
                Phone                       = '956789876',
                PSABrand__c                 = 'AP',
                Email                       = 'psaLead@leadexample.com',
                LeadCountry__c              = 'AZ',
                NationalId__c               = '0909843X'
        );

        insert lea;

        Account acc             =   new Account (
            FirstName               =   'Account FirstName',
            LastName                =   'Account LastName',
            Salutation              =   '1',
            PersonalEmail__pc       =   'testaccB2C@test.com',
            RecordTypeId            =   Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2C_PA').getRecordTypeId(),
            TECH_CreatedFromLead__c =   true,
            TECH_Salutation__pc     =   '1',
            PersonEmail             = 'a@test.com',
            LandlinePersonalTelephone__pc = '658458458',
            NonResidentCustomer__pc = true,
            Brand__c                = 'AP',
            RRDICode__c             = '1234567',
            SiteGeoIdPK__c          = '0123456789'
        );

        insert acc;

        Account dealer             =   new Account (
            Name                    = 'Dealer',
            RecordTypeId            =   Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('Dealer').getRecordTypeId(),
            TECH_CreatedFromLead__c =   true,
            Country__c              = 'PT', 
            Brand__c                = 'AP',
            RRDICode__c             = '1234568',
            SiteGeoIdPK__c          = '0123456780',
            AgentContractNumber__c  = '1237771'
        );

        insert dealer;

        Asset asse = new Asset(
            Name                = 'Test Vehicle',
            AssetType__c        = 'VN',
            CurrencyIsoCode     = 'EUR',
            AccountId           = acc.Id,
            LastKnownRegistrationNumber__c = '1',
            VIN__c                         = 'sd320000000000789',
            Brand__c            = 'AP'
        );

        insert asse;

        List<AccountContactAssetRelation__c> lstR = new List<AccountContactAssetRelation__c>([SELECT Id FROM AccountContactAssetRelation__c]);

        WorkshopAppointment__c workSh = new WorkshopAppointment__c(
            Driver__c = acc.Id,
            Asset__c = asse.Id,
            TECH_AccountAssetRelation__c = lstR.get(0).Id
        );
        
        insert workSh;

        TeleAlert__c teleAlert = new TeleAlert__c(
            Country__c = 'PT', 
            Brand__c = 'AP', 
            Priority__c = '1', 
            Asset__c = asse.Id, 
            WorkshopAppointmentID__c = workSh.Id, 
            Account__c = acc.Id,
            APVDealer__c= dealer.Id);
        insert teleAlert;

        JSONGenerator g = JSON.createGenerator(true);
        g.writeStartObject();
            g.writeStringField('id', [SELECT Id FROM TeleAlert__c LIMIT 1].Id);
            g.writeNumberField('mock_status', 500);
        g.writeEndObject();

        Test.setMock(HttpCalloutMock.class, new Int137Mock());

        OlbAppointment.getAppointmentId(g.getAsString());
    }

    @isTest static void testMethod2(){
        Lead lea  = new Lead(
                FirstName                   = 'Test 001', 
                LastName                    = 'Version1',
                Phone                       = '956789876',
                PSABrand__c                 = 'AP',
                Email                       = 'psaLead@leadexample.com',
                LeadCountry__c              = 'AZ',
                NationalId__c               = '0909843X'
        );

        insert lea;

        Account acc             =   new Account (
            FirstName               =   'Account FirstName',
            LastName                =   'Account LastName',
            Salutation              =   '1',
            PersonalEmail__pc       =   'testaccB2C@test.com',
            RecordTypeId            =   Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2C_PA').getRecordTypeId(),
            TECH_CreatedFromLead__c =   true,
            TECH_Salutation__pc     =   '1',
            PersonEmail             = 'a@test.com',
            LandlineProfessionalTelephone__pc = '658458457',
            NonResidentCustomer__pc = true,
            Brand__c                = 'AP',
            RRDICode__c             = '1234567',
            SiteGeoIdPK__c          = '0123456789'
        );

        insert acc;

        Account dealer             =   new Account (
            Name                    = 'Dealer',
            RecordTypeId            =   Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('Dealer').getRecordTypeId(),
            TECH_CreatedFromLead__c =   true,
            Country__c              = 'PT', 
            Brand__c                = 'AP',
            RRDICode__c             = '1234568',
            SiteGeoIdPK__c          = '0123456780',
            AgentContractNumber__c  = '1237771'
        );

        insert dealer;

        Asset asse = new Asset(
            Name                = 'Test Vehicle',
            AssetType__c        = 'VN',
            CurrencyIsoCode     = 'EUR',
            AccountId           = acc.Id,
            LastKnownRegistrationNumber__c = '1',
            VIN__c                         = 'sd320000000000789',
            Brand__c            = 'AP'
        );

        insert asse;

        List<AccountContactAssetRelation__c> lstR = new List<AccountContactAssetRelation__c>([SELECT Id FROM AccountContactAssetRelation__c]);

        WorkshopAppointment__c workSh = new WorkshopAppointment__c(
            Driver__c = acc.Id,
            Asset__c = asse.Id,
            TECH_AccountAssetRelation__c = lstR.get(0).Id
        );
        
        insert workSh;

        TeleAlert__c teleAlert = new TeleAlert__c(
            Country__c = 'PT', 
            Brand__c = 'AP', 
            Priority__c = '1', 
            Asset__c = asse.Id, 
            WorkshopAppointmentID__c = workSh.Id, 
            Account__c = acc.Id,
            APVDealer__c= dealer.Id);
        insert teleAlert;

        JSONGenerator g = JSON.createGenerator(true);
        g.writeStartObject();
            g.writeStringField('id', [SELECT Id FROM TeleAlert__c LIMIT 1].Id);
            g.writeNumberField('mock_status', 500);
        g.writeEndObject();

        Test.setMock(HttpCalloutMock.class, new Int137Mock());

        OlbAppointment.getAppointmentId(g.getAsString());
    }

    @isTest static void testMethod3(){
        Lead lea  = new Lead(
                FirstName                   = 'Test 001', 
                LastName                    = 'Version1',
                Phone                       = '956789876',
                PSABrand__c                 = 'AP',
                Email                       = 'psaLead@leadexample.com',
                LeadCountry__c              = 'AZ',
                NationalId__c               = '0909843X'
        );

        insert lea;

        Account acc             =   new Account (
            FirstName               =   'Account FirstName',
            LastName                =   'Account LastName',
            Salutation              =   '1',
            PersonalEmail__pc       =   'testaccB2C@test.com',
            RecordTypeId            =   Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2C_PA').getRecordTypeId(),
            TECH_CreatedFromLead__c =   true,
            TECH_Salutation__pc     =   '1',
            PersonEmail             = 'a@test.com',
            MobilePersonalTelephone__pc = '658458458',
            NonResidentCustomer__pc = true,
            Brand__c                = 'AP',
            RRDICode__c             = '1234567',
            SiteGeoIdPK__c          = '0123456789'
        );

        insert acc;

        Account dealer             =   new Account (
            Name                    = 'Dealer',
            RecordTypeId            =   Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('Dealer').getRecordTypeId(),
            TECH_CreatedFromLead__c =   true,
            Country__c              = 'PT', 
            Brand__c                = 'AP',
            RRDICode__c             = '1234568',
            SiteGeoIdPK__c          = '0123456780',
            AgentContractNumber__c  = '1237771'
        );

        insert dealer;

        Asset asse = new Asset(
            Name                = 'Test Vehicle',
            AssetType__c        = 'VN',
            CurrencyIsoCode     = 'EUR',
            AccountId           = acc.Id,
            LastKnownRegistrationNumber__c = '1',
            VIN__c                         = 'sd320000000000789',
            Brand__c            = 'AP'
        );

        insert asse;

        List<AccountContactAssetRelation__c> lstR = new List<AccountContactAssetRelation__c>([SELECT Id FROM AccountContactAssetRelation__c]);

        WorkshopAppointment__c workSh = new WorkshopAppointment__c(
            Driver__c = acc.Id,
            Asset__c = asse.Id,
            TECH_AccountAssetRelation__c = lstR.get(0).Id
        );
        
        insert workSh;

        TeleAlert__c teleAlert = new TeleAlert__c(
            Country__c = 'PT', 
            Brand__c = 'AP', 
            Priority__c = '1', 
            Asset__c = asse.Id, 
            WorkshopAppointmentID__c = workSh.Id, 
            Account__c = acc.Id,
            APVDealer__c= dealer.Id);
        insert teleAlert;

        JSONGenerator g = JSON.createGenerator(true);
        g.writeStartObject();
            g.writeStringField('id', [SELECT Id FROM TeleAlert__c LIMIT 1].Id);
            g.writeNumberField('mock_status', 500);
        g.writeEndObject();

        Test.setMock(HttpCalloutMock.class, new Int137Mock());

        OlbAppointment.getAppointmentId(g.getAsString());
    }

}
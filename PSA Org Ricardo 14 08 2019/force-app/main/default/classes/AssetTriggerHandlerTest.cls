@isTest
private class AssetTriggerHandlerTest {
    
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
            Name                = 'Asset Test 1',
            AssetType__c        = 'VN',
            CurrencyIsoCode     = 'EUR',
            AccountId           = b2c.Id,
            InitialStepKm__c    = 2000,
            InitialStepYear__c  = 1,
            CyclicStepKm__c     = 2000,
            CyclicStepYear__c   = 1
        );

        insert a;

        Opportunity opp         = new Opportunity (
            Name                = 'Test',
            StageName           = 'FR1',
            AccountId           = b2c.Id,
            CloseDate           = System.today(),
            Activity__c         = 'VN',
            Country__c          = 'ES',
            Segment__c			= '27',
            FundingForm__c      = '1'
        );

        insert opp;

        Order o                 = new Order(
            AccountId           = b2c.Id,
            EffectiveDate       = Date.today().addYears(-2),
            Status              = 'Draft',
            OrderId__c          = 'oId',
            RealDeliveryDate__c = Date.today().addYears(-1),
			      OpportunityId       = opp.Id
        );

        insert o;
    }
    
    static testMethod void assetTriggerHandler01Test() {

        List<Asset> lNewAsset = new List<Asset>();
        
        Account oAccount = new Account(
                Name                =   'TEST MATCH B2B',
                phone               =   '+843434',
                BillingPostalCode   =   '234563',
                FiscalId__c         =   '30.686.957-4',
                RecordTypeId        =   Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2B').getRecordTypeId()
        );
        
        insert oAccount;

        for(Integer i = 0; i<10; i++){
            lNewAsset.add(new Asset(Name = 'Asset_Test'+i, AssetType__c='VN', CurrencyIsoCode = 'EUR', accountid = oAccount.id));
        }

        Database.insert(lNewAsset);
        
        Map<Id, Asset> mapNewAsset = new Map<Id, Asset>();
        
        for (Asset a : lNewAsset) {
            mapNewAsset.put(a.Id, a);
        }
        
        test.startTest();
            AssetTriggerHandler.afterInsert(mapNewAsset);
            AssetTriggerHandler.shouldRunTrigger();
            AssetTriggerHandler.dontRunTrigger();
        test.stopTest();

    }

    @isTest static void assetTriggerHandler02Test(){

        Asset a = [SELECT Id FROM Asset];

        a.Brand__c                  = 'AP';
        a.WarrantyBeginDate__c      = Date.today().addYears(-1);
        a.LastAPVVisitDate__c       = Date.today();
        a.LastAPVVisitMileage__c    = 1000;
        
        update a;
    }

    @isTest static void assetTriggerHandler03Test(){

        Asset a = [SELECT Id FROM Asset];

        a.Brand__c                  = 'AP';
        a.WarrantyBeginDate__c      = Date.today().addYears(-1);
        a.RealMileageDate__c        = Date.today();
        a.RealMileage__c            = 2000;

        update a;
    }

    @isTest static void assetTriggerHandler04Test(){

        Asset a = [SELECT Id FROM Asset];

        a.Brand__c                  = 'AP';
        a.WarrantyBeginDate__c      = Date.today().addYears(-1);
        a.LastAPVVisitDate__c       = Date.today();
        a.LastAPVVisitMileage__c    = 1000;
        a.RealMileageDate__c        = Date.today();
        a.RealMileage__c            = 2000;

        update a;
    }
    
    @isTest static void assetTriggerHandler05Test(){

        Asset a = [SELECT Id FROM Asset];

        a.Brand__c                  = 'AP';
        a.FirstRegistrationDate__c  = Date.today().addYears(-1);
        a.LastAPVVisitDate__c       = Date.today();
        a.LastAPVVisitMileage__c    = 1000;
        a.RealMileageDate__c        = Date.today();
        a.RealMileage__c            = 2000;

        update a;
    }

    @isTest static void assetTriggerHandler06Test(){

        Asset a = [SELECT Id FROM Asset];

        a.Brand__c                  = 'AP';
        a.EnergyCode__c             = '01';
        a.FirstRegistrationDate__c  = Date.today().addDays(-17);
        a.LastAPVVisitDate__c       = Date.today().addDays(-16);
        a.LastAPVVisitMileage__c    = 1000;
        a.RealMileageDate__c        = Date.today().addDays(-15);
        a.RealMileage__c            = 2000;

        update a;
    }

    @isTest static void assetTriggerHandler07Test(){

        Asset a = [SELECT Id FROM Asset];

        a.Brand__c                  = 'AP';
        a.FirstRegistrationDate__c  = Date.today().addDays(-17);
        a.LastAPVVisitDate__c       = Date.today().addDays(-16);
        a.LastAPVVisitMileage__c    = 1000;
        a.RealMileageDate__c        = Date.today().addDays(-15);
        a.RealMileage__c            = 2000;

        update a;
    }

    @isTest static void assetTriggerHandler08Test(){

        Order o = [SELECT Id FROM Order];
        Asset a = [SELECT Id FROM Asset];

        a.Brand__c                  = 'AP';
        a.OrderId__c                = o.Id;
        a.LastAPVVisitDate__c       = Date.today().addDays(-16);
        a.LastAPVVisitMileage__c    = 1000;
        a.RealMileageDate__c        = Date.today().addDays(-15);
        a.RealMileage__c            = 2000;

        update a;
    }
    
    // manteinance test methods
    @isTest static void assetTriggerHandler09Test(){

        Asset a = [SELECT Id FROM Asset];

        a.Brand__c                  = 'AP';
        a.EnergyCode__c             = '01';
        a.FirstRegistrationDate__c  = Date.today().addYears(-5);
        a.LastAPVVisitDate__c       = Date.today();
        a.LastAPVVisitMileage__c    = 100000;

        update a;

        // reissue update operation to get updated formulas.
        update a;
    }

    @isTest static void assetTriggerHandler10Test(){

        Asset a = [SELECT Id FROM Asset];

        a.Brand__c                  = 'AP';
        a.EnergyCode__c             = '01';
        a.CyclicStepYear__c         = null;
        a.LastAPVVisitDate__c       = Date.today();
        a.LastAPVVisitMileage__c    = 100000;
        a.LastMaintenanceDate__c    = Date.today();
        a.LastMaintenanceMileage__c = 100000;

        update a;
        
        // reissue update operation to get updated formulas.
        update a;
    }
    
    @isTest static void assetTriggerHandler11Test(){

        Asset a = [SELECT Id FROM Asset];

        a.Brand__c                  = 'AP';
        a.EnergyCode__c             = '01';
        a.LastAPVVisitDate__c       = Date.today();
        a.LastAPVVisitMileage__c    = 100000;
        a.LastMaintenanceDate__c    = Date.today();
        a.LastMaintenanceMileage__c = 100000;

        update a;
        
        // reissue update operation to get updated formulas.
        update a;
    }

    @isTest static void assetTriggerHandler12Test(){

        Asset a = [SELECT Id FROM Asset];

        a.Brand__c                  = 'AP';
        a.EnergyCode__c             = '01';
        a.FirstRegistrationDate__c  = Date.today().addMonths(-6);
        a.LastAPVVisitDate__c       = Date.today().addMonths(-3);
        a.LastAPVVisitMileage__c    = 100;

        update a;

    }
    
    @isTest static void assetTriggerHandler13Test(){

        Asset a = [SELECT Id FROM Asset];

        a.Brand__c                  = 'AP';
        a.Country__c                = 'ES';
        a.EnergyCode__c             = '01';
        a.FirstRegistrationDate__c  = Date.today().addMonths(-6);
        a.LastAPVVisitDate__c       = Date.today().addMonths(-3);
        a.LastAPVVisitMileage__c    = 100;

        update a;

    }
    
    @isTest static void assetTriggerHandler14Test(){

        Asset a = [SELECT Id FROM Asset];

        a.Country__c                = 'ES';
        a.EnergyCode__c             = '01';
        a.FirstRegistrationDate__c  = Date.today().addMonths(-6);
        a.LastAPVVisitDate__c       = Date.today().addMonths(-3);
        a.LastAPVVisitMileage__c    = 100;

        update a;

    }

}
@istest
private class EnqueueAssetsToUpdateTest {
    @TestSetup
    static void makeData(){
            Account b2c = new Account(
            FirstName           = 'Account FirstName',
            LastName            = 'Account LastName',
            Salutation          = '1',
            PersonalEmail__pc   = 'b2c@test.com',
            Phone				= '987654321',
            RecordTypeId        = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId(),
			NonResidentCustomer__pc = true
        );

        insert b2c;
    
        List<Asset> lstA = new List<Asset>{
            new Asset(
                Name                        = 'Asset Test 1',
                AssetType__c                = 'VN',
                CurrencyIsoCode             = 'EUR',
                AccountId                   = b2c.Id,
                InitialStepKm__c            = 25000,
                InitialStepYear__c          = 1,
                CyclicStepKm__c             = 25000,
                CyclicStepYear__c           = 1,
                Country__c                  = 'ES',
                EnergyCode__c               = '01',
                FirstRegistrationDate__c    = Date.today().addMonths(-6),
                LastAPVVisitDate__c         = Date.today().addMonths(-3),
                LastAPVVisitMileage__c      = 100,
                VIN__c						= 'ASKFAKJSUFHSAKSJ1',
                language__c					= 'ES'
            ),
            new Asset(
                Name                        = 'Asset Test 2',
                AssetType__c                = 'VN',
                CurrencyIsoCode             = 'EUR',
                AccountId                   = b2c.Id,
                InitialStepKm__c            = 25000,
                InitialStepYear__c          = 1,
                CyclicStepKm__c             = 25000,
                CyclicStepYear__c           = 1,
                Country__c                  = 'ES',
                EnergyCode__c               = '01',
                FirstRegistrationDate__c    = Date.today().addMonths(-6),
                LastAPVVisitDate__c         = Date.today().addMonths(-3),
                LastAPVVisitMileage__c      = 100,
                VIN__c						= 'ASKFAKJSUFHSAKSJ2',
                language__c					= 'ES'
            ),
            new Asset(
                Name                        = 'Asset Test 3',
                AssetType__c                = 'VN',
                CurrencyIsoCode             = 'EUR',
                AccountId                   = b2c.Id,
                InitialStepKm__c            = 25000,
                InitialStepYear__c          = 1,
                CyclicStepKm__c             = 25000,
                CyclicStepYear__c           = 1,
                Brand__c                    = 'AP',
                EnergyCode__c               = '01',
                FirstRegistrationDate__c    = Date.today().addMonths(-6),
                LastAPVVisitDate__c         = Date.today().addMonths(-3),
                LastAPVVisitMileage__c      = 100,
                VIN__c						= 'ASKFAKJSUFHSAKSJ3',
                language__c					= 'ES'
            ),
            new Asset(
                Name                        = 'Asset Test 3',
                AssetType__c                = 'VN',
                CurrencyIsoCode             = 'EUR',
                AccountId                   = b2c.Id,
                InitialStepKm__c            = 25000,
                InitialStepYear__c          = 1,
                CyclicStepKm__c             = 25000,
                CyclicStepYear__c           = 1,
                Brand__c                    = 'AP',
                Country__c                  = 'ES',
                EnergyCode__c               = '01',
                FirstRegistrationDate__c    = Date.today().addMonths(-6),
                LastAPVVisitDate__c         = Date.today().addMonths(-3),
                LastAPVVisitMileage__c      = 100,
                VIN__c						= 'ASKFAKJSUFHSAKSJ4',
                language__c					= 'ES'
            )
        };

        insert lstA;
    }

    @isTest
    private static void EnqueueAssetsToUpdate_test_01(){
        List<Asset> assets = [Select id, VIN__c, Language__c, Country__c, Brand__c, LCDV16__c,LCDV9__c,FamilyDescription__c,AssetDestinationUsage__c,Model__c,ShapeCode__c ,ShapeDescription__c ,FinishingCode__c,FinishingDescription__c,EngineCode__c,EngineDescription__c,GearboxCode__c, GearboxDescription__c from Asset];
        
        Test.startTest();
		EnqueueAssetsToUpdate.makeCallout = false;
        System.enqueueJob(new EnqueueAssetsToUpdate(assets));
        Test.stopTest();
    }
    
    @isTest
    private static void EnqueueAssetsToUpdate_test_02(){
        Asset asset = [Select id, VIN__c, Language__c, Country__c, Brand__c, LCDV16__c,LCDV9__c,FamilyDescription__c,AssetDestinationUsage__c,Model__c,ShapeCode__c ,ShapeDescription__c ,FinishingCode__c,FinishingDescription__c,EngineCode__c,EngineDescription__c,GearboxCode__c, GearboxDescription__c from Asset Limit 1 ];        
        
        Test.startTest();
		Test.setMock( HttpCalloutMock.class, new RestInt91Mock( 200 ));
        EnqueueAssetsToUpdate.performCallout(asset);
        Test.stopTest();
    }
    
}
/*   @Class : AssetUtilsTest.cls
*
*   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
*   @Created        :   12 April 2018
*   @Description    :   Apex Unit test class for AssetUtilsTest.cls

*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Developer                Date                     Description
*      Rubén Moreno             12 April 2018            Creation.  
*      Rubén Fernandez          16 June  2019            Added assingRealMileageSourceTest test method 
*   ----------------------------------------------------------------------------------------------------------------------------
*/

@isTest
private class AssetUtilsTest {
    
    @testSetup static void setup() {
        Account b2c = new Account(
            FirstName           = 'Account FirstName',
            LastName            = 'Account LastName',
            Salutation          = '1',
            PersonalEmail__pc   = 'b2c@test.com',
            Phone				= '987654321',
            RecordTypeId        = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId()
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
                LastAPVVisitMileage__c      = 100
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
                LastAPVVisitMileage__c      = 100
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
                LastAPVVisitMileage__c      = 100
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
                LastAPVVisitMileage__c      = 100
            )
        };

        insert lstA;
    }

    public static testMethod void doTest() {

        List<Asset> lNewAsset = new List<Asset>();

        Account oAccount = new Account(
            Name                = 'TEST MATCH B2B',
            Phone               = '+56643434434',
            BillingPostalCode   = '234563',
            FiscalId__c         = '18624067-7',
            RecordTypeId        = Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2B').getRecordTypeId()
        );

        insert oAccount;

        for (Integer i = 0; i<10; i++){
            lNewAsset.add(new Asset(
                Name                = 'Asset_Test'+i,
                AssetType__c        = 'VN',
                CurrencyIsoCode     = 'EUR',
                accountid           = oAccount.id
            ));
        }

        Database.insert(lNewAsset);

        Test.startTest();
            AssetUtils.createAssetAccountRelation(lNewAsset);
        Test.stopTest();
    }

    @isTest static void testMethod1(){

        Map<Id, Asset> m = new Map<Id, Asset>([SELECT Id FROM Asset]);
        AssetUtils.AssetMaintenance testJob = new AssetUtils.AssetMaintenance(m.keySet());
        Id jobID = System.enqueueJob(testJob);
        System.debug('After update job Id: ' + jobId);
    }

    @isTest static void testMethod2(){

        Map<Id, Asset> m = new Map<Id, Asset>([SELECT Id FROM Asset]);
        
        Asset a = m.values().get(0);
        a.FirstRegistrationDate__c = Date.today().addYears(-2);
        update a;
        
        AssetUtils.AssetMaintenance testJob = new AssetUtils.AssetMaintenance(m.keySet());
        Id jobID = System.enqueueJob(testJob);
        System.debug('After update job Id: ' + jobId);
    }
    
    @isTest static void assetQualifying01Test(){
        Set<Id> idAssets = new set<Id>();
        
        for(Asset a :[Select id from Asset]){
            idAssets.add(a.id);
        }
        
        Test.startTest();
        System.enqueueJob(new AssetUtils.AssetQualifying(idAssets));
        Test.stopTest();
    }

    @isTest static void assingRealMileageSourceTest(){
        List<Asset> lstAssetsA          = new List<Asset>([SELECT Id,RealMileage__c,RealMileageDate__c,RealMileageSource__c FROM Asset LIMIT 1]);
        List<Asset> lstAssetsB          = new List<Asset>([SELECT Id,RealMileage__c,RealMileageDate__c,RealMileageSource__c FROM Asset LIMIT 1]);
        Asset newAsset                  = lstAssetsA.get(0);
        newAsset.RealMileage__c         = 105000;
        newAsset.RealMileageDate__c     = System.today();
        newAsset.RealMileageSource__c   = 'APV';

        Map<Id, Asset> mapOldAssetById  = new Map<Id, Asset>{
            lstAssetsB.get(0).Id => new Asset(
                RealMileage__c          = 125000,
                RealMileageDate__c      = System.today(),
                RealMileageSource__c    = 'APV'
            )
        };
        
            Test.startTest();
                AssetUtils.assingRealMileageSource(lstAssetsA,mapOldAssetById);
            Test.stopTest();
        
        System.assertEquals('APV', newAsset.RealMileageSource__c);
    }
}
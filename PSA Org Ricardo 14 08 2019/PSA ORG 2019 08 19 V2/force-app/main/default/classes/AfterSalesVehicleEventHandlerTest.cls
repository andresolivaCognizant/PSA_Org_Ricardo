@isTest
public class AfterSalesVehicleEventHandlerTest {

    @testSetup static void setup() {

        List<Account> lstA = Test.loadData(Account.sObjectType, 'AfterSalesTestData_PersonAccount');
        List<Contact> lstC = Test.loadData(Contact.sObjectType, 'AfterSalesTestData_PersonAccountContact');

        // merge to person account - begin
        List<Account> lstB2C = new List<Account>();
            
        for(Account a : lstA) {
            Account p = new Account(
                Id              = a.Id,
                RecordTypeId    = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C_PA').getRecordTypeId()
            );
            lstB2C.add(p);
        }

        update lstB2C;
        // merge to person account - end

        Test.loadData(Asset.sObjectType, 'AfterSalesTestData_Asset');

        Asset a = [SELECT Id FROM Asset];
    }
    
    @isTest static void testMethod1(){

        Asset a = [SELECT Id FROM Asset];
            a.RealMileage__c        = 125000;
            a.RealMileageDate__c    = System.today();
            a.RealMileageSource__c  = 'APV';
        update a;

        Map<String, VehicleEvent__x> m = new Map<String, VehicleEvent__x>{
            'xxxxxxx' => new VehicleEvent__x(
                assetid__c          = a.Id,
                realmileage__c      = 125000,
                realmileagedate__c  = System.today(),
                realmileagesource__c = 'APV'
            )
        };

        Test.startTest();
            AfterSalesVehicleEventHandler.validateVehicleEventRules(m);
        Test.stopTest();
    }

    @isTest static void testMethod2(){

        Asset a = [SELECT Id FROM Asset];
            a.RealMileage__c        = 125000;
            a.RealMileageDate__c    = System.today().addDays(-1);
            a.RealMileageSource__c  = 'APV';
        update a;

        Map<String, VehicleEvent__x> m = new Map<String, VehicleEvent__x>{
            'xxxxxxx' => new VehicleEvent__x(
                assetid__c          = a.Id,
                realmileage__c      = 126000,
                realmileagedate__c  = System.today(),
                realmileagesource__c = 'APV'
            )
        };

        Test.startTest();
            AfterSalesVehicleEventHandler.validateVehicleEventRules(m);
        Test.stopTest();
    }

    @isTest static void testMethod3(){

        Asset a = [SELECT Id FROM Asset];
            a.RealMileage__c        = 126000;
            a.RealMileageDate__c    = System.today();
            a.RealMileageSource__c  = 'APV';
        update a;

        Map<String, VehicleEvent__x> m = new Map<String, VehicleEvent__x>{
            'xxxxxxx' => new VehicleEvent__x(
                assetid__c          = a.Id,
                realmileage__c      = 125000,
                realmileagedate__c  = System.today().addDays(-1),
                realmileagesource__c = 'APV'
            )
        };

        Test.startTest();
            AfterSalesVehicleEventHandler.validateVehicleEventRules(m);
        Test.stopTest();
    }

}
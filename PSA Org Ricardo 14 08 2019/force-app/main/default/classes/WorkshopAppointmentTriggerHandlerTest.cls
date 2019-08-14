@isTest
private class WorkshopAppointmentTriggerHandlerTest {

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

    }
    
     /* Testing Insert / Update WorkshopAppointment */
    @isTest static void WorkshopAppointmentTest(){

        List<Account> lstA = new List<Account>([SELECT Id, IsPersonAccount FROM Account]); 
        List<Asset> lstV = new List<Asset>([SELECT Id, AccountId FROM Asset]);
        List<AccountContactAssetRelation__c> lstR = new List<AccountContactAssetRelation__c>([SELECT Id FROM AccountContactAssetRelation__c]);

        Test.startTest();

        	WorkshopAppointment__c w = new WorkshopAppointment__c(
                Driver__c = lstA.get(0).Id,
                Asset__c = lstV.get(0).Id,
                TECH_AccountAssetRelation__c = lstR.get(0).Id
            );
            
            insert w;
        
        	w.ReceptionDatetime__c = System.now().addDays(-1);
        	update w;

        Test.stopTest();
        
    }
    /* Testing Undelete WorkshopAppointment */
    @isTest static void WorkshopAppintmentUndeleteTest(){

        List<Account> lstA = new List<Account>([SELECT Id, IsPersonAccount FROM Account]); 
        List<Asset> lstV = new List<Asset>([SELECT Id, AccountId FROM Asset]);
        List<AccountContactAssetRelation__c> lstR = new List<AccountContactAssetRelation__c>([SELECT Id FROM AccountContactAssetRelation__c]);

        Test.startTest();

            WorkshopAppointment__c w = new WorkshopAppointment__c(
                Driver__c = lstA.get(0).Id,
                Asset__c = lstV.get(0).Id,
                TECH_AccountAssetRelation__c = lstR.get(0).Id
            );
            
            insert w;
            delete w;
            WorkshopAppointment__c[] savedAppoitments = [SELECT Id, Asset__c, Driver__c FROM WorkshopAppointment__c WHERE Asset__c = :lstV.get(0).Id AND Driver__c =: lstA.get(0).Id ALL ROWS];
            
            System.assertEquals(lstV.get(0).Id, savedAppoitments.get(0).Asset__c);
            
            undelete savedAppoitments;

        Test.stopTest();
        
    }

}
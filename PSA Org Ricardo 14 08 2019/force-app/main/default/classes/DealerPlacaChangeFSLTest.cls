@isTest
private class DealerPlacaChangeFSLTest {
    
  @testSetup static void setup() {
    List<User> lstUsers   = new List<User>();
    lstUsers.add(TestDataFactoryUtil.createOneUser('PSA_Admin', 'PSA', 'AP', 'FR', '9876543'));
    lstUsers.add(TestDataFactoryUtil.createOneUser('PSA_Admin', 'PSA', 'AC', 'FR', '6876544'));
    Insert lstUsers;
  }
  
  @isTest static void test_method_one() {
  
    List<User> lstUsers       = [Select Id From User Where Profile.Name = 'PSA_Admin' AND IsActive = true Limit 2]; 
    List<Account> lstAcc      = new List<Account>();
    Account a1                = new Account(
      Name                    = 'Test Dealer 1',
      RecordTypeId            = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account_DealerPartner').getRecordTypeId()
    );
    lstAcc.add(a1);
    insert lstAcc;
    OperatingHours oph        = new OperatingHours(Name = 'test 1'); 
    insert oph;
        
    List<ServiceResource> lstSerRes = new List<ServiceResource>{
      new ServiceResource(
      RelatedRecordId         = lstUsers[0].Id, 
      Name                    = 'Name245',
      ResourceType            = 'T',
      IsActive                = true, 
      IsCapacityBased         = false, 
      IsOptimizationCapable   = false, 
      EnergyCode__c           = '581', 
      EnergyDescription__c    = 'Energ334', 
      FamilyCode__c           = '969', 
      FamilyDescription__c    = 'Famil127', 
      GearboxCode__c          = '1', 
      GearboxDescription__c   = 'Gearb930', 
      ShapeCode__c            = '19', 
      ShapeDescription__c     = 'Shape726', 
      IsAvailable__c          = true, 
      Country__c              = 'FR',
      Account__c              = lstAcc.get(0).Id,
      Type__c                 = 'VD'
    ),
      new ServiceResource(
      RelatedRecordId         = lstUsers[1].Id, 
      Name                    = 'Name246', 
      IsActive                = true, 
      IsCapacityBased         = false, 
      IsOptimizationCapable   = false, 
      EnergyCode__c           = '582', 
      EnergyDescription__c    = 'Energ335', 
      FamilyCode__c           = '966',
      FamilyDescription__c    = 'Famil128', 
      GearboxCode__c          = '1', 
      GearboxDescription__c   = 'Gearb930', 
      ShapeCode__c            = '19', 
      ShapeDescription__c     = 'Shape726', 
      IsAvailable__c          = true, 
      Country__c              = 'FR',
      Account__c              = lstAcc.get(0).Id
    )};
    Insert lstSerRes; 

    ServiceTerritory st       = new ServiceTerritory (
      Account__c              = lstAcc.get(0).Id,
      IsActive                = true,
      Description             = 'Test ST 1',
      Name                    = 'ST 1',
      OperatingHoursId        = oph.Id
    );
    Insert st;

    List<ServiceTerritoryMember> lstServTerr = new List<ServiceTerritoryMember>();
    ServiceTerritoryMember stm  = new ServiceTerritoryMember(
      ServiceResourceId       = lstSerRes.get(0).Id,
      ServiceTerritoryId      = st.Id,
      EffectiveStartDate      = System.Today()-2,
      ExternalId__c           = 'STM1',
      TerritoryType           = 'P'
    );

    lstServTerr.add(stm);

    ServiceTerritoryMember stm2 = new ServiceTerritoryMember(
      ServiceResourceId       = lstSerRes.get(1).Id,
      ServiceTerritoryId      = st.Id,
      EffectiveStartDate      = System.Today()-2,
      ExternalId__c           = 'STM2',
      TerritoryType           = 'S'
    );
    lstServTerr.add(stm2);
    Insert lstServTerr;
    
    // New test data //
    List<String> lstActivities=   new List<String>{'VN'};
    List<Contact> lstContsA   =   TestDataFactoryUtil.createPartnerUser(1, 1, 'Dealer', '133225511','1237770', 'EXTKEY0002','AP','PL', 'J',lstActivities,true);
    
    WorkOrder wo              = new WorkOrder();
    wo.subject                = 'New Work Order Subject' + datetime.now();
    wo.description            = 'New Work Order Description' + datetime.now();
    wo.accountId              = lstContsA.get(0).AccountId;
    wo.contactId              = lstContsA.get(0).Id;
    Insert wo;

    List<ServiceAppointment>lSSA= new List<ServiceAppointment>{ new ServiceAppointment(
        Status                = 'Scheduled',
        parentRecordId        = wo.id,
        EarliestStartTime     = System.now(),
        DueDate               = DateTime.Now().AddHours(+1),
        SchedStartTime        = System.Today()+1,
        SchedEndTime          = System.Today()+5,
        ServiceTerritoryId    = st.Id
    )};
    Insert lSSA;
    AssignedResource fls_AR   = new AssignedResource (
        ServiceResourceId     = lstSerRes.get(0).Id,
        ServiceAppointmentId  = lSSA.get(0).Id 
    );
    Insert fls_AR;
    Test.startTest();
      DealerPlacaChangeFSL.startSecTerrRelation(lstAcc);  
      DealerPlacaChangeFSL.endSecTerrRelation(lstAcc, true);
      DealerPlacaChangeFSL.endSecTerrRelation(lstAcc, false);
      DealerPlacaChangeFSL.sendNotifcation('testuser@example.com', 'first name test', lSSA);
    Test.stopTest();  
  } 
}
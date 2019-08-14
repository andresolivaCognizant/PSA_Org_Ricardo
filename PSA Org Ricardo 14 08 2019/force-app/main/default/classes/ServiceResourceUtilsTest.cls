@isTest
private class ServiceResourceUtilsTest {
  @testSetup
  static void setupTestData(){
    List<User> lstUsers = new List<User>{
      TestDataFactoryUtil.createOneUser('PSA_Admin', 'PSA', 'AP', 'ES', '2872541'),
      TestDataFactoryUtil.createOneUser('PSA_Admin', 'PSA', 'AP', 'ES', '1873545')
    };
    insert lstUsers;

    System.runAs(lstUsers[0]){
      Test.startTest();

         DateTime newDate = DateTime.Now().AddHours(+1);

          Account a1 = new Account(
              Name            = 'Test Dealer 1',
              RecordTypeId    = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account_DealerPartner').getRecordTypeId()
          );

          insert a1;

          OperatingHours oph = new OperatingHours(
            Name = 'test 1'
          ); 
          insert oph;

          List<ServiceResource> lstSerRes = new List<ServiceResource>();

          ServiceResource sr1 = new ServiceResource(RelatedRecordId=UserInfo.getUserId(), Name = 'Name245', IsActive = true, IsCapacityBased = false, IsOptimizationCapable = false, EnergyCode__c = '581', EnergyDescription__c = 'Energ334', FamilyCode__c = '969', FamilyDescription__c = 'Famil127', GearboxCode__c = '1', GearboxDescription__c = 'Gearb930', ShapeCode__c = '19', ShapeDescription__c = 'Shape726', isAvailable__c = false, Country__c = 'FR');
          lstSerRes.add(sr1); 

          ServiceResource sr2 = new ServiceResource(RelatedRecordId=lstUsers[1].Id, Name = 'Name246', IsActive = true, IsCapacityBased = false, IsOptimizationCapable = false, EnergyCode__c = '581', EnergyDescription__c = 'Energ334', FamilyCode__c = '969', FamilyDescription__c = 'Famil127', GearboxCode__c = '1', GearboxDescription__c = 'Gearb930', ShapeCode__c = '19', ShapeDescription__c = 'Shape726', isAvailable__c = false, Country__c = 'FR');
          lstSerRes.add(sr2);

          Insert lstSerRes; 

          ServiceTerritory st = new ServiceTerritory (
              Account__c = a1.Id,
              IsActive = true,
              Description = 'Test ST 1',
              Name = 'ST 1',
              OperatingHoursId = oph.Id
          );

          insert st;

          List<ServiceTerritoryMember> lstServTerr = new List<ServiceTerritoryMember>();

          ServiceTerritoryMember stm = new ServiceTerritoryMember(
            ServiceResourceId = sr1.Id,
            ServiceTerritoryId = st.Id,
            EffectiveStartDate = System.now(),
            ExternalId__c = 'STM1'

          );

          lstServTerr.add(stm);

          ServiceTerritoryMember stm2 = new ServiceTerritoryMember(
            ServiceResourceId = sr2.Id,
            ServiceTerritoryId = st.Id,
            EffectiveStartDate = System.now(),
            ExternalId__c = 'STM2'

          );

          lstServTerr.add(stm2);

          insert lstServTerr;

          WorkOrder wo = new WorkOrder (
            CurrencyIsoCode = 'EUR',
            Status = 'Nouveau',
            Priority = 'Faible',
            Duration = 30,
            DurationType = 'Minutes', 
            ServiceTerritoryId = st.Id,
            StartDate = System.today(),
            EndDate = System.today()
          );

          insert wo;

          List<ServiceAppointment> lstSerApp = new List<ServiceAppointment>();

          ServiceAppointment sa = new ServiceAppointment (
            Status = 'Open',
            ParentRecordId = wo.Id,
            EarliestStartTime = System.now(),
            DueDate = newDate,
            SchedStartTime = System.Today()+1,
            SchedEndTime = System.Today()+5,
            ServiceTerritoryId = st.Id
          );

          lstSerApp.add(sa);

          ServiceAppointment sa2 = new ServiceAppointment (
            Status = 'Open',
            ParentRecordId = wo.Id,
            EarliestStartTime = System.now(),
            DueDate = newDate,
            SchedStartTime = System.Today()+1,
            SchedEndTime = System.Today()+5,
            ServiceTerritoryId = st.Id
          );

          lstSerApp.add(sa2);

          insert lstSerApp;

          List<AssignedResource> lstAssRes = new List<AssignedResource>();

          AssignedResource ar = new AssignedResource (
              ServiceResourceId = sr1.Id,
              ServiceAppointmentId = sa.Id 
          );

          lstAssRes.add(ar);

          AssignedResource ar2 = new AssignedResource (
              ServiceResourceId = sr2.Id,
              ServiceAppointmentId = sa2.Id 
          );

          lstAssRes.add(ar2);

          insert lstAssRes;
      Test.stopTest();
    }


  }

  static testMethod void test_getFamilyData_UseCase1(){
    List<ServiceResource> serviceresource_Obj  =  [SELECT Name, IsActive, IsCapacityBased, IsOptimizationCapable, EnergyCode__c, 
                                                          EnergyDescription__c, FamilyCode__c, FamilyDescription__c,GearboxCode__c, 
                                                          GearboxDescription__c, ShapeCode__c, ShapeDescription__c, IsAvailable__c 
                                                          FROM ServiceResource];

    System.debug('serviceresource_Obj: '+serviceresource_Obj.size());

    Test.startTest();
        serviceresource_Obj[0].IsActive = false;
        serviceresource_Obj[1].IsActive = false;
        update serviceresource_Obj;
    Test.stopTest();
  }
}
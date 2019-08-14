@isTest
private class AfterSalesBoardControllerTest{
  @testSetup
  static void setupTestData(){
    test.startTest();
    Account account_Obj = new Account(FirstName = 'Account FirstName', LastName = 'Account LastName', Salutation = '1', PersonalEmail__pc = 'b2c@test.com', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId(), PSAWorker__pc = false, TECH_CreatedFromLead__pc = false,TECH_OptOut__pc = false, NonResidentCustomer__pc = false, MobileProfessionalTelephoneStatus__pc = false, TECH_DummyContact__pc = false, SBQQ__AssetQuantitiesCombined__c = false, SBQQ__CoTermedContractsCombined__c = false, SBQQ__IgnoreParentContractedPrices__c = false, SBQQ__PreserveBundle__c = false, TECH_CreatedFromLead__c = false, FlagAP__c = false, FlagAC__c = false, FlagDS__c = false, OwnerOfAVehicle__c = false, VNPrincipalSite__c = false, PRPrincipalSite__c = false, RAPrincipalSite__c = false, AgentPrincipalSite__c = false, VNFlag__c = false, PRFlag__c = false, RAFlag__c = false, VOActivity__c = false, ShippingNPAI__c = false, BillingNPAI__c = false, OngoingClaim__c = false, AgentFlag__c = false, PMPrincipalSite__c = false, PdVInterne__c = false, AfterSalesDiscountAgreement__c = false, DMSConnectedToC1st__c = false, IsActive__c = false, PSASupplier__c = false, InternalCustomer__c = false, et4ae5__HasOptedOutOfMobile__pc = false, MailingNPAI__pc = false, NewsletterSubscriberAP__pc = false, NewsletterSubscriberAC__pc = false, NewsletterSubscriberDS__pc = false, TECH_OptOutRequest__pc = false, Deceased__pc = false, CondominiumPurchase__pc = false, ACAnonymization__pc = false, DSAnonymization__pc = false, AccountPrincipalContact__pc = false, AvailableLeadTreatment__pc = false, TECH_MostActive__pc = false, Professional__pc = false);
    Insert account_Obj; 
    Asset asset_Obj = new Asset(AssetType__c = 'VN', AccountId = account_Obj.id, IsCompetitorProduct = false, Name = 'Name444', SBQQ__Bundle__c = false, SBQQ__Bundled__c = false, SBQQ__ComponentDiscountedByPackage__c = false, SBQQ__FromServiceCloud__c = false, /*BTA__c = false,*/ BrokenDownVehicle__c = false, Eurorepar__c = false);
    Insert asset_Obj; 
    test.stopTest(); 
  }
  static testMethod void test_getRecordDetails_UseCase1(){
    List<Account> account_Obj  =  [SELECT id,SBQQ__AssetQuantitiesCombined__c,SBQQ__CoTermedContractsCombined__c,SBQQ__IgnoreParentContractedPrices__c,SBQQ__PreserveBundle__c,TECH_CreatedFromLead__c,FlagAP__c,FlagAC__c,FlagDS__c,OwnerOfAVehicle__c,VNPrincipalSite__c,PRPrincipalSite__c,RAPrincipalSite__c,AgentPrincipalSite__c,VNFlag__c,PRFlag__c,RAFlag__c,VOActivity__c,ShippingNPAI__c,BillingNPAI__c,OngoingClaim__c,AgentFlag__c,PMPrincipalSite__c,PdVInterne__c,AfterSalesDiscountAgreement__c,DMSConnectedToC1st__c,IsActive__c,PSASupplier__c,InternalCustomer__c,et4ae5__HasOptedOutOfMobile__pc,MailingNPAI__pc,NewsletterSubscriberAP__pc,NewsletterSubscriberAC__pc,NewsletterSubscriberDS__pc,TECH_OptOutRequest__pc,Deceased__pc,NonResidentCustomer__pc,PSAWorker__pc,CondominiumPurchase__pc,TECH_OptOut__pc,APAnonymization__pc,ACAnonymization__pc,DSAnonymization__pc,TECH_CreatedFromLead__pc,MobileProfessionalTelephoneStatus__pc,MobilePersonalTelephoneStatus__pc,AccountPrincipalContact__pc,AvailableLeadTreatment__pc,TECH_MostActive__pc,TECH_DummyContact__pc,Professional__pc from Account];
    System.assertEquals(true,account_Obj.size()>0);
    List<Asset> asset_Obj  =  [SELECT AccountId,IsCompetitorProduct,Name,SBQQ__Bundle__c,SBQQ__Bundled__c,SBQQ__ComponentDiscountedByPackage__c,SBQQ__FromServiceCloud__c/*,BTA__c*/,BrokenDownVehicle__c,Eurorepar__c from Asset];
    System.assertEquals(true,asset_Obj.size()>0);
    AccountContactAssetRelation__c a = [
         SELECT Id, AssetId__c, AccountId__c
         FROM AccountContactAssetRelation__c
    ];
    AfterSalesBoardController obj01 = new AfterSalesBoardController();
    AfterSalesBoardController.getRecordDetails(a.Id);
  }
  static testMethod void test_getRelatedRecords_UseCase1(){
    List<Account> account_Obj  =  [SELECT Id,SBQQ__AssetQuantitiesCombined__c,SBQQ__CoTermedContractsCombined__c,SBQQ__IgnoreParentContractedPrices__c,SBQQ__PreserveBundle__c,TECH_CreatedFromLead__c,FlagAP__c,FlagAC__c,FlagDS__c,OwnerOfAVehicle__c,VNPrincipalSite__c,PRPrincipalSite__c,RAPrincipalSite__c,AgentPrincipalSite__c,VNFlag__c,PRFlag__c,RAFlag__c,VOActivity__c,ShippingNPAI__c,BillingNPAI__c,OngoingClaim__c,AgentFlag__c,PMPrincipalSite__c,PdVInterne__c,AfterSalesDiscountAgreement__c,DMSConnectedToC1st__c,IsActive__c,PSASupplier__c,InternalCustomer__c,et4ae5__HasOptedOutOfMobile__pc,MailingNPAI__pc,NewsletterSubscriberAP__pc,NewsletterSubscriberAC__pc,NewsletterSubscriberDS__pc,TECH_OptOutRequest__pc,Deceased__pc,NonResidentCustomer__pc,PSAWorker__pc,CondominiumPurchase__pc,TECH_OptOut__pc,APAnonymization__pc,ACAnonymization__pc,DSAnonymization__pc,TECH_CreatedFromLead__pc,MobileProfessionalTelephoneStatus__pc,MobilePersonalTelephoneStatus__pc,AccountPrincipalContact__pc,AvailableLeadTreatment__pc,TECH_MostActive__pc,TECH_DummyContact__pc,Professional__pc from Account];
    System.assertEquals(true,account_Obj.size()>0);
    List<Asset> asset_Obj  =  [SELECT AccountId,IsCompetitorProduct,Name,SBQQ__Bundle__c,SBQQ__Bundled__c,SBQQ__ComponentDiscountedByPackage__c,SBQQ__FromServiceCloud__c,/*BTA__c,*/BrokenDownVehicle__c,Eurorepar__c from Asset];
    System.assertEquals(true,asset_Obj.size()>0);
    AfterSalesBoardController obj01 = new AfterSalesBoardController();
    AfterSalesBoardController.getRelatedRecords(account_Obj[0].Id,'Campaign');
  }
  static testMethod void test_getRelatedRecords_UseCase2(){
    List<Account> account_Obj  =  [SELECT Id,SBQQ__AssetQuantitiesCombined__c,SBQQ__CoTermedContractsCombined__c,SBQQ__IgnoreParentContractedPrices__c,SBQQ__PreserveBundle__c,TECH_CreatedFromLead__c,FlagAP__c,FlagAC__c,FlagDS__c,OwnerOfAVehicle__c,VNPrincipalSite__c,PRPrincipalSite__c,RAPrincipalSite__c,AgentPrincipalSite__c,VNFlag__c,PRFlag__c,RAFlag__c,VOActivity__c,ShippingNPAI__c,BillingNPAI__c,OngoingClaim__c,AgentFlag__c,PMPrincipalSite__c,PdVInterne__c,AfterSalesDiscountAgreement__c,DMSConnectedToC1st__c,IsActive__c,PSASupplier__c,InternalCustomer__c,et4ae5__HasOptedOutOfMobile__pc,MailingNPAI__pc,NewsletterSubscriberAP__pc,NewsletterSubscriberAC__pc,NewsletterSubscriberDS__pc,TECH_OptOutRequest__pc,Deceased__pc,NonResidentCustomer__pc,PSAWorker__pc,CondominiumPurchase__pc,TECH_OptOut__pc,APAnonymization__pc,ACAnonymization__pc,DSAnonymization__pc,TECH_CreatedFromLead__pc,MobileProfessionalTelephoneStatus__pc,MobilePersonalTelephoneStatus__pc,AccountPrincipalContact__pc,AvailableLeadTreatment__pc,TECH_MostActive__pc,TECH_DummyContact__pc,Professional__pc from Account];
    System.assertEquals(true,account_Obj.size()>0);
    List<Asset> asset_Obj  =  [SELECT AccountId,IsCompetitorProduct,Name,SBQQ__Bundle__c,SBQQ__Bundled__c,SBQQ__ComponentDiscountedByPackage__c,SBQQ__FromServiceCloud__c,/*BTA__c,*/BrokenDownVehicle__c,Eurorepar__c from Asset];
    System.assertEquals(true,asset_Obj.size()>0);
    AccountContactAssetRelation__c a = [
            SELECT Id, AssetId__c, AccountId__c, AccountRole__c
            FROM AccountContactAssetRelation__c
    ];
    
    a.AccountRole__c = 'Owner';
    
    update a;
        
    AfterSalesBoardController obj01 = new AfterSalesBoardController();
    AfterSalesBoardController.getRelatedRecords(a.Id,'Opportunity');
  }
  static testMethod void test_getRelatedRecords_UseCase3(){
        AccountContactAssetRelation__c a = [
            SELECT Id, AssetId__c, AccountId__c
            FROM AccountContactAssetRelation__c
        ];
        
        /*Id wId = AfterSalesSearchController.insertWorkshopAppointment(
            a.Id,
            true,
            null
        );

        WorkshopAppointment__c w = new WorkshopAppointment__c(
            Id                      = wId,
            ReceptionDatetime__c    = System.now().addDays(-1)
        );

        update w;
    AfterSalesBoardController.getRelatedRecords(wId,'Consents');*/
  }
  /*static testMethod void test_getCalloutResponseContents_UseCase1(){
    List<Account> account_Obj  =  [SELECT SBQQ__AssetQuantitiesCombined__c,SBQQ__CoTermedContractsCombined__c,SBQQ__IgnoreParentContractedPrices__c,SBQQ__PreserveBundle__c,TECH_CreatedFromLead__c,FlagAP__c,FlagAC__c,FlagDS__c,OwnerOfAVehicle__c,VNPrincipalSite__c,PRPrincipalSite__c,RAPrincipalSite__c,AgentPrincipalSite__c,VNFlag__c,PRFlag__c,RAFlag__c,VOActivity__c,ShippingNPAI__c,BillingNPAI__c,OngoingClaim__c,AgentFlag__c,PMPrincipalSite__c,PdVInterne__c,AfterSalesDiscountAgreement__c,DMSConnectedToC1st__c,IsActive__c,PSASupplier__c,InternalCustomer__c,et4ae5__HasOptedOutOfMobile__pc,MailingNPAI__pc,NewsletterSubscriberAP__pc,NewsletterSubscriberAC__pc,NewsletterSubscriberDS__pc,TECH_OptOutRequest__pc,Deceased__pc,NonResidentCustomer__pc,PSAWorker__pc,CondominiumPurchase__pc,TECH_OptOut__pc,APAnonymization__pc,ACAnonymization__pc,DSAnonymization__pc,TECH_CreatedFromLead__pc,MobileProfessionalTelephoneStatus__pc,MobilePersonalTelephoneStatus__pc,AccountPrincipalContact__pc,AvailableLeadTreatment__pc,TECH_MostActive__pc,TECH_DummyContact__pc,Professional__pc from Account];
    System.assertEquals(true,account_Obj.size()>0);
    List<Asset> asset_Obj  =  [SELECT AccountId,IsCompetitorProduct,Name,SBQQ__Bundle__c,SBQQ__Bundled__c,SBQQ__ComponentDiscountedByPackage__c,SBQQ__FromServiceCloud__c,BTA__c,BrokenDownVehicle__c,Eurorepar__c from Asset];
    System.assertEquals(true,asset_Obj.size()>0);
    AfterSalesBoardController obj01 = new AfterSalesBoardController();
    AfterSalesBoardController.DataTableResponse obj31 = new AfterSalesBoardController.DataTableResponse();
    obj31.lstDataTableData = new List<AfterSalesBoardController.DataTableObject>();

    AfterSalesBoardController.getCalloutResponseContents('test@test.com');
  }*/
  /*static testMethod void test_myBrandElegibility_UseCase1(){
    List<Account> account_Obj  =  [SELECT SBQQ__AssetQuantitiesCombined__c,SBQQ__CoTermedContractsCombined__c,SBQQ__IgnoreParentContractedPrices__c,SBQQ__PreserveBundle__c,TECH_CreatedFromLead__c,FlagAP__c,FlagAC__c,FlagDS__c,OwnerOfAVehicle__c,VNPrincipalSite__c,PRPrincipalSite__c,RAPrincipalSite__c,AgentPrincipalSite__c,VNFlag__c,PRFlag__c,RAFlag__c,VOActivity__c,ShippingNPAI__c,BillingNPAI__c,OngoingClaim__c,AgentFlag__c,PMPrincipalSite__c,PdVInterne__c,AfterSalesDiscountAgreement__c,DMSConnectedToC1st__c,IsActive__c,PSASupplier__c,InternalCustomer__c,et4ae5__HasOptedOutOfMobile__pc,MailingNPAI__pc,NewsletterSubscriberAP__pc,NewsletterSubscriberAC__pc,NewsletterSubscriberDS__pc,TECH_OptOutRequest__pc,Deceased__pc,NonResidentCustomer__pc,PSAWorker__pc,CondominiumPurchase__pc,TECH_OptOut__pc,APAnonymization__pc,ACAnonymization__pc,DSAnonymization__pc,TECH_CreatedFromLead__pc,MobileProfessionalTelephoneStatus__pc,MobilePersonalTelephoneStatus__pc,AccountPrincipalContact__pc,AvailableLeadTreatment__pc,TECH_MostActive__pc,TECH_DummyContact__pc,Professional__pc from Account];
    System.assertEquals(true,account_Obj.size()>0);
    List<Asset> asset_Obj  =  [SELECT AccountId,IsCompetitorProduct,Name,SBQQ__Bundle__c,SBQQ__Bundled__c,SBQQ__ComponentDiscountedByPackage__c,SBQQ__FromServiceCloud__c,BTA__c,BrokenDownVehicle__c,Eurorepar__c from Asset];
    System.assertEquals(true,asset_Obj.size()>0);
    AfterSalesBoardController obj01 = new AfterSalesBoardController();
    AfterSalesBoardController.DataTableResponse obj31 = new AfterSalesBoardController.DataTableResponse();
    obj31.lstDataTableData = new List<AfterSalesBoardController.DataTableObject>();
    AfterSalesBoardController.DataTableObject obj51 = new AfterSalesBoardController.DataTableObject(obj51.sObjectVal = new sObject());
    obj51.campaigns = 10;
    obj51.opportunities = 10;
    AfterSalesBoardController.myBrandElegibility();
  }*/
   
   static testMethod void test_myBrandElegibility_UseCase1() { 
        AccountContactAssetRelation__c a = [
            SELECT Id, AssetId__c, AccountId__c
            FROM AccountContactAssetRelation__c
        ];
        
       Id wId = (Id) AfterSalesSearchController.insertWorkshopAppointment(
            a.Id,
            true,
            null
        ).get('Id');

        AfterSalesBoardController.myBrandElegibility(wId);
    }

    static testMethod void test_myBrandElegibility_UseCase2() {
        AccountContactAssetRelation__c a = [
            SELECT Id, AssetId__c, AccountId__c
            FROM AccountContactAssetRelation__c
        ];

        Asset v = new Asset(
            Id = a.AssetId__c,
            Brand__c = 'AC'
        );

        update v;

        Account d = new Account(
            Id = a.AccountId__c,
            CustomerSpaceACStatus__c = '1'
        );

        update d;

       Id wId = (Id) AfterSalesSearchController.insertWorkshopAppointment(
            a.Id,
            true,
            null
        ).get('Id');

        AfterSalesBoardController.myBrandElegibility(wId);
    }

    static testMethod void test_myBrandElegibility_UseCase3() {
        AccountContactAssetRelation__c a = [
            SELECT Id, AssetId__c, AccountId__c
            FROM AccountContactAssetRelation__c
        ];

        Asset v = new Asset(
            Id = a.AssetId__c,
            Brand__c = 'AP'
        );

        update v;

        Account d = new Account(
            Id = a.AccountId__c,
            CustomerSpaceAPStatus__c = '1'
        );

        update d;

       Id wId = (Id) AfterSalesSearchController.insertWorkshopAppointment(
            a.Id,
            true,
            null
        ).get('Id');

        AfterSalesBoardController.myBrandElegibility(wId);
    }

    static testMethod void test_myBrandElegibility_UseCase4() {
        AccountContactAssetRelation__c a = [
            SELECT Id, AssetId__c, AccountId__c
            FROM AccountContactAssetRelation__c
        ];

        Asset v = new Asset(
            Id = a.AssetId__c,
            Brand__c = 'DS'
        );

        update v;

        Account d = new Account(
            Id = a.AccountId__c,
            CustomerSpaceDSStatus__c = '1'
        );

        update d;

       Id wId = (Id) AfterSalesSearchController.insertWorkshopAppointment(
            a.Id,
            true,
            null
        ).get('Id');

        AfterSalesBoardController.myBrandElegibility(wId);
    }

    static testMethod void test_myBrandElegibility_UseCase5() {
        AccountContactAssetRelation__c a = [
            SELECT Id, AssetId__c, AccountId__c
            FROM AccountContactAssetRelation__c
        ];
        
       Id wId = (Id) AfterSalesSearchController.insertWorkshopAppointment(
            a.Id,
            true,
            null
        ).get('Id');

        AfterSalesBoardController.myBrandElegibility(wId);
    }

    static testMethod void test_myBrandElegibility_UseCase6() {
        AccountContactAssetRelation__c a = [
            SELECT Id, AssetId__c, AccountId__c
            FROM AccountContactAssetRelation__c
        ];
        
       Id wId = (Id) AfterSalesSearchController.insertWorkshopAppointment(
            a.Id,
            true,
            null
        ).get('Id');

        Account d = new Account(
            Id                  = a.AccountId__c,
            PersonMobilePhone   = '777777777'
        );

        update d;

        AfterSalesBoardController.myBrandElegibility(wId);
    }

    @isTest static void testMethod1(){
        AccountContactAssetRelation__c a = [
            SELECT Id, AssetId__c, AccountId__c
            FROM AccountContactAssetRelation__c
        ];
        
       Id wId = (Id) AfterSalesSearchController.insertWorkshopAppointment(
            a.Id,
            true,
            null
        ).get('Id');
        
        JSONGenerator g = JSON.createGenerator(true);
        g.writeStartObject();
        g.writeObjectField('ids', new List<Id>{wId});
        g.writeEndObject();

        Test.startTest();
            AfterSalesBoardController.getAppointmentInfo(g.getAsString());
        Test.stopTest();
    }

    @isTest static void testMethod2(){
        AccountContactAssetRelation__c a = [
            SELECT Id, AssetId__c, AccountId__c
            FROM AccountContactAssetRelation__c
        ];

       Id wId = (Id) AfterSalesSearchController.insertWorkshopAppointment(
            a.Id,
            true,
            null
        ).get('Id');
        
        Test.startTest();
            AfterSalesBoardController.getRelatedRecords(wId, 'Consents');
        Test.stopTest();
    }
    static testmethod void DMSCORSTest(){
        AccountContactAssetRelation__c a = [
            SELECT Id, AssetId__c, AccountId__c
            FROM AccountContactAssetRelation__c
        ];
        Test.startTest();
            Map<String,String> mapResults   = AfterSalesBoardController.DMSWakeUp(a.AccountId__c,a.AssetId__c);
            Boolean bResult                  = AfterSalesBoardController.DMSWakeUpbyServer(a.AccountId__c);
        Test.stopTest();
    }
}
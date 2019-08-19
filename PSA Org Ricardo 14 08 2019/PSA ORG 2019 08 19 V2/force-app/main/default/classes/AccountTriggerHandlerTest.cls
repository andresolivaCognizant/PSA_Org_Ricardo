@isTest
private class AccountTriggerHandlerTest {
    
    @testSetup static void setup() {
        List<String> lstActivities              = new List<String>{'VN'};
        List<Contact> lstContsA               = TestDataFactoryUtil.createPartnerUser(2, 1, 'Dealer', '133225511','1237770', 'EXTKEY0002','AP','PT', 'J',lstActivities,true);
        List<Contact> lstSales                  = new List<Contact>{lstContsA.get(0)};
        List<Contact> lstASales                 = new List<Contact>{lstContsA.get(1)};
        List<User> lstUsers1                    = TestDataFactoryUtil.createUser(lstSales,'Sales_Manager','Partner','Manager');
        lstUsers1.addAll(TestDataFactoryUtil.createUser(lstASales,'Aftersales_Manager','Partner','Manager'));
        Insert lstUsers1;
    }
    static testMethod void myUnitTest() {
        
        Lead l = new Lead(
                FirstName                   = 'First Name 003',
                Salutation                  =  '1',
                LastName                    = 'LastName 003',
                Street                      = 'Calle Test 372',
                City                        = 'Madrid',
                Country                     = 'España', 
                PostalCode                  = '28012',
                Latitude                    =  39.9691,
                Longitude                   = -4.8237,
                Phone                       = '915001000',
                //DestinationGeographicalCode__c= acct.Id,
                DestinationPOSCode__c       = '1237771',
                Company                     = 'DEALER TEST COMPANY_0031',
                PSABrand__c                 = 'AP',
                Email                       = 'test@leadexample.com',
                LeadCountry__c              = 'PL',
                LeadRequestType__c          = '5',
                IdReservationVD__c          = '12345323X',
                status                      = 'Qualified',
                OwnerId                     = UserInfo.getUserId(),
                RecordTypeId                = PAD.getObjRecordType('Lead','B2B'));
        
        //insert l;
        
        Lead oLead = new Lead(
                FirstName                   = 'First Name 044',
                Salutation                  =  '1',
                LastName                    = 'LastName 044',
                Street                      = 'Calle Test 472',
                City                        = 'Madrid',
                Country                     = 'España', 
                PostalCode                  = '28012',
                Latitude                    =  39.9691,
                Longitude                   = -4.8237,
                Phone                       = '915001000',
                DestinationPOSCode__c       = '1237771',
                Company                     = 'DEALER TEST COMPANY_0031',
                PSABrand__c                 = 'AP',
                Email                       = 'test4@leadexample.com',
                LeadCountry__c              = 'PL',
                LeadRequestType__c          = '5',
                IdReservationVD__c          = '12345323X',
                status                      = 'Qualified',
                OwnerId                     = UserInfo.getUserId(),
                RecordTypeId                = PAD.getObjRecordType('Lead','B2C'));
        
        List<Lead> listlead = new List<Lead>();
        listlead.add(l);
        listlead.add(oLead);
        insert listlead;
        //insert oLead;
        
        Account accB2C              =   new Account (
            FirstName               =   'Account FirstName',
            LastName                =   'Account LastName',
            Salutation              =   '1',
            PersonalEmail__pc       =   'testaccB2C@test.com',
            RecordTypeId            =   Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2C_PA').getRecordTypeId(),
            TECH_CreatedFromLead__c =   true,
            TECH_Idlead__c          =   oLead.id
        );
   
        Account accB2B              =   new Account (
            Name                    =   'Account FirstName',
            RecordTypeId            =   Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2B').getRecordTypeId(),
            TECH_CreatedFromLead__c =   true,
            TECH_Idlead__c          =   l.id
        );
        
        insert new List<Account>{accB2C,accB2B} ;
        
        map<id,Account> mapIdAccount = new Map<Id,Account>();
        mapIdAccount.put(accB2C.id, accB2C);
        mapIdAccount.put(accB2B.id, accB2B);
        
        accB2B.FiscalId__c = '30686957-4';
        accB2C.NationalId__pc = '30686957-4';
        update new List<Account>{accB2C,accB2B} ;
        
        test.startTest();
            AccountTriggerHandler.shouldRunTrigger();
            AccountTriggerHandler.dontRunTrigger();
            AccountUtils.WrapperMappingAccount wma = new AccountUtils.WrapperMappingAccount(l.phone,l.Email,l.Address2__c,l.Birthdate__c,l.FirstName,
                              l.LastName,l.LandlinePersonalTelephone__c,l.LandlineProfessionalTelephone__c,l.PSABrand__c,l.MobilePersonalTelephone__c,l.MobileProfessionalTelephone__c,
                              l.Salutation,l.NationalId__c,l.tITLE,l.Language__c,l.State,l.Street,l.Country,l.PostalCode,l.City,l.LeadSource);

        test.stopTest();
        
    }

    static testMethod void validateNIF() {
      Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
      User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com',
         EmailEncodingKey='UTF-8', LastName='TestNIF', LanguageLocaleKey='en_US',
         LocaleSidKey='en_US', ProfileId = p.Id,
         TimeZoneSidKey='America/Los_Angeles', UserName='TestNIF@testorg.com',
         Country__c = 'PT');

      System.runAs(u2) {
        List<Account> lst_acc = new List<Account>();

            Account accB2C              =   new Account (
                FirstName               =   'acc1',
                LastName                =   'acc1',
                PersonalEmail__pc       =   'acc1C@test.com',
                RecordTypeId            =   Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2C_PA').getRecordTypeId(),
                TECH_CreatedFromLead__c =   true,
                Country__c              =   'PT',
                NonResidentCustomer__pc =   false,
                NationalId__pc          =   '500206007',
                NationalId2__pc         =   '500206007',
                TECH_ContactCountry__pc =    'PT',
                NationalIdType__pc      =   'NIF'
            );

            Account accB2COne              =   new Account (
                FirstName               =   'acc1',
                LastName                =   'acc1',
                PersonalEmail__pc       =   'acc1C@test.com',
                RecordTypeId            =   Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2C_PA').getRecordTypeId(),
                TECH_CreatedFromLead__c =   true,
                Country__c              =   'PT',
                NonResidentCustomer__pc =   false,
                NationalId__pc          =   '500206007',
                NationalId2__pc         =   '500206007',
                TECH_ContactCountry__pc =    'PT',
                NationalId2Type__pc     =   'NIF'
            );

            lst_acc.add(accB2C);
            lst_acc.add(accB2COne);

            Test.startTest();
                insert lst_acc;

                try{
                    accB2C.NationalId__pc = '500234007';
                    update accB2C;
                }catch(DmlException e){ 

                }

                try{
                    accB2COne.NationalId2__pc = '500234007';
                    update accB2COne;
                }catch(DmlException e){ 

                }

                try{
                    accB2C.NationalId__pc = '50023400734';
                    update accB2C;
                }catch(DmlException e){ 

                }

                try{
                    accB2COne.NationalId2__pc = '50023400743';
                    update accB2COne;
                }catch(DmlException e){ 

                }
            Test.stopTest();
        }
        
    }

    static testMethod void changeStatusBrandAccount() {
        User usr                                = [SELECT Id, Contact.AccountId,Contact.Account.CommunicationMode__c FROM User WHERE Contact.Account.CommunicationMode__c = '2' AND Profile.Name = 'Aftersales_Manager' LIMIT 1];
        
        System.runAs(usr) {
            Test.startTest();
                List<Account> lst_acc = new List<Account>();

                Account accOne = new Account(
                        Name              =   'TEST MATCH 26',
                        Phone             =   '+34900100100',
                        BillingPostalCode =   '23451',
                        FiscalId__c       =   '1233111',
                        RecordTypeId      =   PAD.getRecordTypeIdByDeveloperName('Account','Account_B2B'),
                        Brand__c          =   'All',
                        Country__c        =   'PT',
                        Type              =   'Prospect',
                        AccountSource     =   'Visit Showroom'
                );
                Account accTwo = new Account(
                        Name              =   'TEST MATCH 26',
                        Phone             =   '+34900100100',
                        BillingPostalCode =   '23451',
                        FiscalId__c       =   '1233112',
                        RecordTypeId      =   PAD.getRecordTypeIdByDeveloperName('Account','Account_B2B'),
                        Brand__c          =   'AC',
                        Country__c        =   'PT'
                );
                Account accThree = new Account(
                        Name              =   'TEST MATCH 26',
                        Phone             =   '+34900100100',
                        BillingPostalCode =   '23451',
                        FiscalId__c       =   '1233113',
                        RecordTypeId      =   PAD.getRecordTypeIdByDeveloperName('Account','Account_B2B'),
                        Brand__c          =   'AP',
                        Country__c        =   'PT'
                );
                Account accFour = new Account(
                        Name              =   'TEST MATCH 26',
                        Phone             =   '+34900100100',
                        BillingPostalCode =   '23451',
                        FiscalId__c       =   '1233114',
                        RecordTypeId      =   PAD.getRecordTypeIdByDeveloperName('Account','Account_B2B'),
                        Brand__c          =   'DS',
                        Country__c        =   'PT'
                );

                lst_acc.add(accOne);
                lst_acc.add(accTwo);
                lst_acc.add(accThree);
                lst_acc.add(accFour);
                Insert lst_acc;

                /* Set<Id> set_ids = new Set<Id>();
                lst_acc = [SELECT Id FROM Account];
                for(Account acc : lst_acc){
                    set_ids.add(acc.Id);
                }*/
            Test.stopTest();
        }
    }

    static testMethod void afterInsert() {
        List<Account> lst_acc = new List<Account>();

            Account accOne = new Account(
                    Name              =   'TEST MATCH 26',
                    Phone             =   '+8434334',
                    BillingPostalCode =   '23451',
                    FiscalId__c       =   '1233111',
                    RecordTypeId      =   Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2B').getRecordTypeId(),
                    Brand__c          =   'All'
            );

            lst_acc.add(accOne);

            
            insert lst_acc;

            Test.startTest();
                AccountTriggerHandler.afterInsert(lst_acc);
            Test.stopTest();        
    }

    /******************************************************************************************************
     * @Method          : afterBeforeUpdate
     * @Author          : Marcos Garcia Garcia
     * @Created         : 13/05/2019
     * @Description     : Positive case afterBeforeUpdate
     ******************************************************************************************************/
    static testMethod void afterBeforeUpdate() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        UserRole r = [select id, Name from UserRole where UserRole.Name like 'PSA'];
        User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='TestNIF', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = r.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='TestNIF@testorg.com',
                            Country__c = 'PT');

        System.runAs(u2) {
            List<Account> lst_acc = new List<Account>();

            Account accOne = new Account(
                    FirstName         =   'TestAccount',
                    LastName          =   'TestLastName',
                    Phone             =   '+8434334',
                    BillingPostalCode =   '23451',
                    FiscalId__c       =   '1233111',
                    RecordTypeId      =   Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId(),
                    ACAnonymization__pc = false,
                    AP_Forgotten_Request_Status__pc = '1',
                    APForgottenRequestDate__pc = System.today(),
                    ACAccountStatus__c = 'Customer',
                    APAccountStatus__c = 'Prospect',
                    DSAccountStatus__c = 'Prospect',
                    CopyToBillingAddress__c = true,
                    BillingState       = 'Asturias',
                    BillingStreet      = 'Torrecerredo',
                    BillingCountry     = 'Spain',
                    BillingCity        = 'Oviedo'
            );

            lst_acc.add(accOne);

            Test.startTest();

                insert lst_acc;

                List<Account> listAccounts = new List<Account>([Select id, ACAnonymization__pc From Account Where FirstName = 'TestAccount']);
                Account acc = listAccounts.get(0);

                Map<String, Object> mapApiNameToFieldValueCase = new Map<String, Object>();
                mapApiNameToFieldValueCase.put('Subject', 'AccountTriggerHandlerTest');
                mapApiNameToFieldValueCase.put('Brand__c', 'AC');
                mapApiNameToFieldValueCase.put('Country__c', 'ES');
                mapApiNameToFieldValueCase.put('Language__c', 'ES');
                mapApiNameToFieldValueCase.put('Priority', '1');
                mapApiNameToFieldValueCase.put('Reason', '2');
                mapApiNameToFieldValueCase.put('AccountId', acc.Id);
                
                TestDataFactoryUtil.createSobject('Case', mapApiNameToFieldValueCase, true);

                acc.ACAnonymization__pc = true;

                update acc;

            Test.stopTest();
        }
    }

    /******************************************************************************************************
     * @Method          : copyFromBillingAddress
     * @Author          : Marcos Garcia Garcia
     * @Created         : 13/05/2019
     * @Description     : Positive case copyFromBillingAddress
     ******************************************************************************************************/
    static testMethod void copyFromBillingAddressPersonAccount() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        UserRole r = [select id, Name from UserRole where UserRole.Name like 'PSA'];
        User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='TestNIF', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = r.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='TestNIF@testorg.com',
                            Country__c = 'PT');

        System.runAs(u2) {
            List<Account> lst_acc = new List<Account>();

            Account accOne = new Account(
                    FirstName         =   'TestAccount',
                    LastName          =   'TestLastName',
                    Phone             =   '+8434334',
                    BillingState      =   'Asturias',
                    BillingStreet     =    'Uria',
                    BillingCity       =    'Oviedo',
                    BillingCountry    =    'Spain',
                    BillingPostalCode =   '23451',
                    FiscalId__c       =   '1233111',
                    RecordTypeId      =   Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId(),
                    ACAnonymization__pc = false,
                    ACAccountStatus__c = 'Customer',
                    APAccountStatus__c = 'Prospect',
                    DSAccountStatus__c = 'Prospect',
                    AC_Forgotten_Request_Status__pc = '1',
                    ACForgottenRequestDate__pc = System.today(),
                    CopyFromBillingAddress__c = true
            );

            lst_acc.add(accOne);

            Test.startTest();

                insert lst_acc;

                List<Account> listAccounts = new List<Account>([Select id, 
                                        ACAnonymization__pc,
                                        BillingState,
                                        BillingStreet,
                                        BillingCity,
                                        BillingCountry,
                                        BillingPostalCode,
                                        PersonMailingState,
                                        PersonMailingStreet,
                                        PersonMailingCountry,
                                        PersonMailingPostalCode,
                                        PersonMailingCity 
                                        From Account 
                                        Where FirstName = 'TestAccount']);
                Account acc = listAccounts.get(0);

                acc.ACAnonymization__pc = true;

                update acc;

                System.assertEquals(acc.BillingState, acc.PersonMailingState);
                System.assertEquals(acc.BillingStreet, acc.PersonMailingStreet);
                System.assertEquals(acc.BillingCity, acc.PersonMailingCity);
                System.assertEquals(acc.BillingCountry, acc.PersonMailingCountry);
                System.assertEquals(acc.BillingPostalCode, acc.PersonMailingPostalCode);

            Test.stopTest();

        }

    }

    /******************************************************************************************************
     * @Method          : copyToBillingAddress
     * @Author          : Marcos Garcia Garcia
     * @Created         : 13/05/2019
     * @Description     : Positive case copyToBillingAddress
     ******************************************************************************************************/
    static testMethod void copyToBillingAddress() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        UserRole r = [select id, Name from UserRole where UserRole.Name like 'PSA'];
        User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='TestNIF', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = r.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='TestNIF@testorg.com',
                            Country__c = 'PT');

        System.runAs(u2) {
            List<Account> lst_acc = new List<Account>();

            Account accOne = new Account(
                    Name              =   'AccountName',
                    Phone             =   '+8434334',
                    ShippingState      =   'Asturias',
                    ShippingStreet     =    'Uria',
                    ShippingCity       =    'Oviedo',
                    ShippingCountry    =    'Spain',
                    ShippingPostalCode =   '23451',
                    FiscalId__c       =   '1233111',
                    RecordTypeId      =   Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2B').getRecordTypeId(),
                    ACAccountStatus__c = 'Prospect',
                    APAccountStatus__c = 'Prospect',
                    DSAccountStatus__c = 'Prospect',
                    CopyToBillingAddress__c = true
            );

            lst_acc.add(accOne);

            Test.startTest();

                insert lst_acc;

                List<Account> listAccounts = new List<Account>([Select id, 
                                    Phone,
                                    BillingState,
                                    BillingStreet,
                                    BillingCity,
                                    BillingCountry,
                                    BillingPostalCode,
                                    ShippingState,
                                    ShippingStreet,
                                    ShippingCountry,
                                    ShippingPostalCode,
                                    ShippingCity 
                                    From Account 
                                    Where Name = 'AccountName']);
                Account acc = listAccounts.get(0);

                acc.Phone = '111111';

                update acc;

                System.assertEquals(acc.ShippingState, acc.BillingState);
                System.assertEquals(acc.ShippingStreet, acc.BillingStreet);
                System.assertEquals(acc.ShippingCity, acc.BillingCity);
                System.assertEquals(acc.ShippingCountry, acc.BillingCountry);
                System.assertEquals(acc.ShippingPostalCode, acc.BillingPostalCode);

            Test.stopTest();
        }
    }

    /******************************************************************************************************
     * @Method          : copyFromBillingAddress
     * @Author          : Marcos Garcia Garcia
     * @Created         : 13/05/2019
     * @Description     : Positive case copyFromBillingAddress
     ******************************************************************************************************/
    static testMethod void copyFromBillingAddress() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        UserRole r = [select id, Name from UserRole where UserRole.Name like 'PSA'];
        User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='TestNIF', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = r.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='TestNIF@testorg.com',
                            Country__c = 'PT');

        System.runAs(u2) {
            List<Account> lst_acc = new List<Account>();

            Account accOne = new Account(
                    Name              =   'AccountName',
                    Phone             =   '+8434334',
                    BillingPostalCode =   '23451',
                    FiscalId__c       =   '1233111',
                    RecordTypeId      =   Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2B').getRecordTypeId(),
                    ACAccountStatus__c = 'Prospect',
                    APAccountStatus__c = 'Prospect',
                    DSAccountStatus__c = 'Prospect',
                    CopyFromBillingAddress__c = true
            );

            lst_acc.add(accOne);

            Test.startTest();

                insert lst_acc;

                List<Account> listAccounts = new List<Account>([Select id, 
                                                        Phone,
                                                        BillingState,
                                                        BillingStreet,
                                                        BillingCity,
                                                        BillingCountry,
                                                        BillingPostalCode,
                                                        ShippingState,
                                                        ShippingStreet,
                                                        ShippingCountry,
                                                        ShippingPostalCode,
                                                        ShippingCity 
                                                        From Account 
                                                        Where Name = 'AccountName']);
                Account acc = listAccounts.get(0);

                acc.Phone = '111111';

                update acc;

                System.assertEquals(acc.BillingState, acc.ShippingState);
                System.assertEquals(acc.BillingStreet, acc.ShippingStreet);
                System.assertEquals(acc.BillingCity, acc.ShippingCity);
                System.assertEquals(acc.BillingCountry, acc.ShippingCountry);
                System.assertEquals(acc.BillingPostalCode, acc.ShippingPostalCode);

            Test.stopTest();
        }
    }

    /******************************************************************************************************
     * @Method          : anonymizeRecordsProspectTest
     * @Author          : Marcos Garcia Garcia
     * @Created         : 13/05/2019
     * @Description     : Positive case anonymizeRecordsProspectTest
     ******************************************************************************************************/
    static testMethod void anonymizeRecordsProspectTest() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        UserRole r = [select id, Name from UserRole where UserRole.Name like 'PSA'];
        User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='TestNIF', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = r.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='TestNIF@testorg.com',
                            Country__c = 'PT');

        System.runAs(u2) {
            List<Account> lst_acc = new List<Account>();

            Account accOne = new Account(
                    FirstName         =   'TestAccount',
                    LastName          =   'TestLastName',
                    Phone             =   '+8434334',
                    BillingPostalCode =   '23451',
                    FiscalId__c       =   '1233111',
                    RecordTypeId      =   Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId(),
                    ACAnonymization__pc = false,
                    APAnonymization__pc = false,
                    DSAnonymization__pc = false,
                    ACAccountStatus__c = 'Prospect',
                    APAccountStatus__c = 'Prospect',
                    DSAccountStatus__c = 'Prospect'
            );

            lst_acc.add(accOne);

            Test.startTest();

                insert lst_acc;

                List<Account> listAccounts = new List<Account>([Select id, ACAnonymization__pc From Account Where FirstName = 'TestAccount']);
                Account acc = listAccounts.get(0);

                //Insertar lead
                Map<String, Object> mapApiNameToFieldValueLead = new Map<String, Object>();
                mapApiNameToFieldValueLead.put('FirstName', 'FirstNameLead');
                mapApiNameToFieldValueLead.put('LastName', 'LastNameLead');
                mapApiNameToFieldValueLead.put('PSABrand__c', 'AP');
                mapApiNameToFieldValueLead.put('Status', 'Discarded');
                mapApiNameToFieldValueLead.put('Phone', '999999');
                mapApiNameToFieldValueLead.put('Customer__c', acc.Id);
                TestDataFactoryUtil.createLead(mapApiNameToFieldValueLead, true);
               
                acc.ACAnonymization__pc = true;
                acc.APAnonymization__pc = true;
                acc.DSAnonymization__pc = true;

                update acc;

            Test.stopTest();
        }
    }

    /******************************************************************************************************
     * @Method          : anonymizeRecordsCustomerTest
     * @Author          : Marcos Garcia Garcia
     * @Created         : 13/05/2019
     * @Description     : Positive case anonymizeRecordsCustomerTest
     ******************************************************************************************************/
    static testMethod void anonymizeRecordsCustomerTest() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        UserRole r = [select id, Name from UserRole where UserRole.Name like 'PSA'];
        User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='TestNIF', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = r.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='TestNIF@testorg.com',
                            Country__c = 'PT');
        
        System.runAs(u2) {
            List<Account> lst_acc = new List<Account>();

            Account accOne = new Account(
                    FirstName         =   'TestAccount',
                    LastName          =   'TestLastName',
                    Phone             =   '+8434334',
                    BillingPostalCode =   '23451',
                    FiscalId__c       =   '1233111',
                    RecordTypeId      =   Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId(),
                    ACAnonymization__pc = false,
                    APAnonymization__pc = false,
                    DSAnonymization__pc = false,
                    ACAccountStatus__c = 'Customer',
                    APAccountStatus__c = 'Customer',
                    DSAccountStatus__c = 'Customer'
            );

            lst_acc.add(accOne);

            Test.startTest();

                insert lst_acc;

                List<Account> listAccounts = new List<Account>([Select id, ACAnonymization__pc From Account Where FirstName = 'TestAccount']);
                Account acc = listAccounts.get(0);

                //Insertar lead
                Map<String, Object> mapApiNameToFieldValueLead = new Map<String, Object>();
                mapApiNameToFieldValueLead.put('FirstName', 'FirstNameLead');
                mapApiNameToFieldValueLead.put('LastName', 'LastNameLead');
                mapApiNameToFieldValueLead.put('PSABrand__c', 'AP');
                mapApiNameToFieldValueLead.put('Status', 'Discarded');
                mapApiNameToFieldValueLead.put('Phone', '999999');
                mapApiNameToFieldValueLead.put('Customer__c', acc.Id);
                TestDataFactoryUtil.createLead(mapApiNameToFieldValueLead, true);
               
                acc.ACAnonymization__pc = true;
                acc.APAnonymization__pc = true;
                acc.DSAnonymization__pc = true;

                update acc;

            Test.stopTest();
        }
    }

    /******************************************************************************************************
     * @Method          : consentsInit
     * @Author          : Pedro Parraga
     * @Created         : 28/05/2019
     * @Description     : create consent
     ******************************************************************************************************/
    static testMethod void consentsInit() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        UserRole r = [select id, Name from UserRole where UserRole.Name like 'PSA'];
        User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='TestNIF', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = r.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='TestNIF@testorg.com',
                            Country__c = 'CL', SiteGeoId__c = '0000046069');
        
        System.runAs(u2) {
            List<Account> lst_acc = new List<Account>();

            Account accOne = new Account(
                    FirstName         =   'TestAccount',
                    LastName          =   'TestLastName',
                    Phone             =   '+8434334',
                    BillingPostalCode =   '23451',
                    FiscalId__c       =   '1233111',
                    RecordTypeId      =   Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId(),
                    ACAnonymization__pc = false,
                    APAnonymization__pc = false,
                    DSAnonymization__pc = false,
                    ACAccountStatus__c = 'Customer',
                    APAccountStatus__c = 'Customer',
                    DSAccountStatus__c = 'Customer',
                    SiteGeoIdPK__c = '0000046069'
            );

            lst_acc.add(accOne);

            Test.startTest();

                insert lst_acc;

                Account acc = [Select id, ACAnonymization__pc From Account Where FirstName = 'TestAccount' LIMIT 1];

                //Insertar lead
                Map<String, Object> mapApiNameToFieldValueLead = new Map<String, Object>();
                mapApiNameToFieldValueLead.put('FirstName', 'FirstNameLead');
                mapApiNameToFieldValueLead.put('LastName', 'LastNameLead');
                mapApiNameToFieldValueLead.put('PSABrand__c', 'AP');
                mapApiNameToFieldValueLead.put('Status', 'Discarded');
                mapApiNameToFieldValueLead.put('Phone', '999999');
                mapApiNameToFieldValueLead.put('Customer__c', acc.Id);
                TestDataFactoryUtil.createLead(mapApiNameToFieldValueLead, true);
               
                acc.ACAnonymization__pc = true;
                acc.APAnonymization__pc = true;
                acc.DSAnonymization__pc = true;

                update acc;

            Test.stopTest();
        }
    }
    /******************************************************************************************************
    * @Method          : Bulk Account Insert / Update
    * @Author          : Ruben Fernandez
    * @Created         : 01/06/2019
    * @Description     : create / update B2B and B2C accounts
    ******************************************************************************************************/
    static testMethod void BulkAccountInsertTest() {
        List<Account> lst_B2B   = new List<Account>();
        List<Account> lst_B2C   = new List<Account>();
        String sKey             = '000';
        Integer iCode           = 23150;
        Integer iCodeC          = 64130;
        for (Integer i = 0;i<199;i++){
            sKey += String.valueOf(i);
            lst_B2B.add(new Account(
                    Name                =   String.Valueof(i*5) + ' TEST ACCOUNT B2B ' + sKey.right(3),
                    Phone               =   '+84300' + sKey.right(3),
                    BillingPostalCode   =   String.valueof(iCode + i),
                    FiscalId__c         =   String.valueof(iCode + i) + sKey.right(3),
                    RecordTypeId        =   Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account_B2B').getRecordTypeId(),
                    Brand__c            =   'AP'
            ));
            lst_B2C.add( new Account(
                    FirstName           = String.Valueof(i*9) + 'TestAccount',
                    LastName            = 'TestLastName acé ño ¨' + String.Valueof(i*7),
                    Phone               = '+34600'+sKey.right(3),
                    Salutation          = '1',
                    PersonalEmail__pc   = 'XXX@XXX.XX',
                    RecordTypeId        = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId(),
                    APAnonymization__pc = false,
                    APAccountStatus__c  = 'Customer'
            ));
         }
         Test.startTest();
            insert lst_B2B;
            insert lst_B2C;
         Test.stopTest();
    }
}
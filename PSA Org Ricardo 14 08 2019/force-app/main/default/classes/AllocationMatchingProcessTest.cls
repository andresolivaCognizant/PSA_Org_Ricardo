/**
    *   @Class : AllocationMatchingProcessTest.cls
    *
    *   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
    *   @Created        :   1 Feb 2018
    *   @Description    :   Apex Unit test class for AllocationMatchingProcess.csl
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description
    *      Rubén Moreno             1/2/2018                 Creation.  
    *      Capgemini                06/06/2018               C1STRUN-2321: Modification 
    *   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
private class AllocationMatchingProcessTest {

    static testMethod void myUnitTest() {
        
        List<id> fixedSearchResults= new List<Id>();
        
        List<Lead> lLeadsB2B = new List<Lead>();        
        List<Lead> lLeadsB2C = new List<Lead>();
     
        List<Account> lAccountsB2C 	= new List<Account>();
        List<Account> lAccountsB2B 	= new List<Account>();
        List<Account> lAccountsB2BSpf = new List<Account>();
        
        List<Asset> lAssetB2B 		= new List<Asset>();        
        List<Asset> lAssetB2C 		= new List<Asset>();
        List<Contact> lContact 		= new List<Contact>();
        // Testing B2B 

         Account accB3 = new Account(
                Name                =   'TEST MATCH 26',
                phone               =   '+8434334',
                BillingPostalCode   =   '23456',
                FiscalId__c         =   '1233111',
                RecordTypeId        =   AccountConstants.ACCOUNT_RT_B2B
        );
        insert accB3;
        
        Asset obAsset = new Asset(
                    Name            = 'Name ASSET',
                    VIN__c          = 'VF36E4HTH20603732',
                    accountid       = accB3.id,
            		AssetType__c    = 'VN'
                );
        insert obAsset;
        fixedSearchResults.add(obAsset.id);

        for(Integer i=11;i<20;i++) {
                        
            Account acct = new Account(
                LocalIdOfCustomer__c                          =   ''+i,
                Name                                          =   'TEST matching'+i,
                BillingPostalCode                             =   '23456',
                BillingStreet                                 =   'Calle de Sebastián Elcano ',
                FiscalId__c                                   =   ''+i,
                RecordTypeId                                  =   AccountConstants.ACCOUNT_RT_B2B
             );
            
            lAccountsB2B.add(acct);
            
        }
        
        if(!lAccountsB2B.isEmpty()){
            insert lAccountsB2B;
            
            Integer iCont = 10;
            for(Account a : lAccountsB2B){
                iCont += 1;
                Asset oAsset = new Asset(
                    Name            = 'Name ASSET',
                    VIN__c          = 'VF36E4HTH206037' +  String.valueof('0' + iCont).right(2),
                    accountid       = a.id,
            		AssetType__c    = 'VN'
                );
                
                lAssetB2B.add(oAsset);
                
                if(iCont < 12){
                    
                    Contact cnt     =   new Contact (
                        FirstName   =   'TEST ' ,
                        LastName    =   'matching'+iCont,
                        Salutation  =   '1',
                        Birthdate   =   Date.today() - 23,          
                        AccountId   =   a.Id,
                        phone       =   '+8745943'
                    );
                    
                   lContact.add(cnt);           
                }
            
            }
            lContact.addAll(new List<Contact>{
            new contact(
                AccountId                       =   accB3.Id,
                Firstname                       =   'TEST ',
                LastName                        =   ' MATCH',
                MailingStreet                   =   'Calle de Sebastián Elcano ',
                MailingPostalCode               =   '23456',
                Salutation                      =   '1',
                personalEmail__c                =   'a@a.com',
                Phone                           =   '334543'
                
            ),
            new contact(
                AccountId                       =   accB3.Id,
                Firstname                       =   'TEST ',
                MailingStreet                   =   'Calle TEST',
                MailingPostalCode               =   '23456',
                Lastname                        =   'MATCH',
                Salutation                      =   '1',
                personalEmail__c                =   'a@a.com',
                Phone                           =   '334543'
                
            ),
            new contact(
                AccountId                       =   accB3.Id,
                Firstname                       =   'TEST ',
                MailingStreet                   =   'Calle TEST',
                MailingPostalCode               =   '23456',
                Lastname                        =   'MATCH',
                Salutation                      =   '1',
                personalEmail__c                =   'a@a.com',
                Phone                           =   '334543'    
            ),
            new contact(
                AccountId                       =   accB3.Id,
                Firstname                       =   'TEST ',
                MailingStreet                   =   'Calle TEST',
                MailingPostalCode               =   '23456',
                Lastname                        =   'MATCH',
                NationalId__c                   =   '30.686.957-4',
                Salutation                      =   '1',
                personalEmail__c                =   'a@a.com',
                Phone                           =   '334543'
            ),
            new contact(
                AccountId                       =   accB3.Id,
                Firstname                       =   'TEST ',
                MailingStreet                   =   'Calle TEST',
                MailingPostalCode               =   '23456',
                Lastname                        =   'MATCH',                
                MobileProfessionalTelephone__c =   '+843434',
                Salutation                      =   '1',
                personalEmail__c                =   'a@a.com',
                Phone                           =   '334543'
            ),
            new contact(
                AccountId                       =  accB3.Id,
                Firstname                       =   'TEST ',
                MailingStreet                   =   'Calle TEST',
                MailingPostalCode               =   '23456',
                Lastname                        =   'MATCH',                
                LandlineProfessionalTelephone__c =   '+843434',
                Salutation                      =   '1',
                personalEmail__c                =   'a@a.com',
                Phone                           =   '334543'
            ),
            new contact(
                AccountId                       =   accB3.Id,
                Firstname                       =   'TEST ',
                MailingStreet                   =   'Calle TEST',
                MailingPostalCode               =   '23456',
                Lastname                        =   'MATCH',
                LandlinePersonalTelephone__c    =   '95632423',
                Salutation                      =   '1',
                personalEmail__c                =   'a@a.com',
                Phone                           =   '334543'
            ),
            new Contact (
                FirstName                       =   'TEST ' ,
                LastName                        =   'MATCH',
                Salutation                      =   '1',
                Birthdate                       =   Date.today() - 23,          
                AccountId                       =    accB3.Id,
                phone                           =   '+8745943'
            )});            
            
            if(!lAssetB2B.isEmpty()){    
                insert lAssetB2B;
            }
            
            if(!lContact.isEmpty()){
                insert lContact;
            }
        }
        
        Lead obLead = new Lead(
                FirstName                   = 'TEST ',
                Company                     = 'Test',           
                Email                       = 'a@a.com',
                LastName                    = 'MATCH',
                Street                      = 'Calle de Sebastián Elcano ',
                PostalCode                  = '23456',
                City                        = 'Madrid',
                Country                     = 'España', 
                Birthdate__C                = Date.today() - 23,
                MobileProfessionalTelephone__c =   '+843434',
                LandlinePersonalTelephone__c    =   '95632423',
            	LandlineProfessionalTelephone__c =   '+843434',
                LocalIdOfCustomer__c         =    '1234',
                RecordType                  =  new Recordtype (id = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('B2B').getRecordTypeId()),
                VINOwnedVehicle__c          = '5346',
                NationalId__c               = '123111',
                FiscalId__c                 = '123111'
                
        );
        
        for(Integer i=11;i<20;i++) {
            
            Lead oLead = new Lead(
                FirstName                   = 'TEST ',
                Company                     = 'Test',           
                LocalIdOfCustomer__c        = ''+i,
                Email                       = 'a@a.com',
                LastName                    = 'matching'+i,
                Street                      = 'Calle de Sebastián Elcano ',
                City                        = 'Madrid',
                Country                     = 'España', 
                PostalCode                  = '23456',
                Birthdate__C                = Date.today() - 23,
                MobileProfessionalTelephone__c =   '+843434',
                LandlinePersonalTelephone__c    =   '95632423',
                NationalId__c               = '1234'+i,
                FiscalId__c                 = '1234'+i,
                RecordType                  =  new Recordtype (id = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('B2B').getRecordTypeId()),
                VINOwnedVehicle__c          = '5346'
                );
            
            lLeadsB2B.add(oLead);
        }
        if(!lLeadsB2B.isEmpty()){
            lLeadsB2B.add(obLead);
            insert lLeadsB2B;           
            
        }
        
        // Testing B2C 
        
        Account acct1 = new Account(
                Firstname                       =   'TEST ',
                BillingStreet                   =   'Calle TEST',
                BillingPostalCode               =   '12345',
                Lastname                        =   'MATCH',
                Salutation                      =   '1',
                personEmail                     =   'a@a2.com',
            	LandlineProfessionalTelephone__pc =   '+843434',
                RecordTypeID                    =   AccountConstants.ACCOUNT_RT_B2C
        );
        Account acct2 = new Account(
                Firstname                       =   'TEST ',
                BillingStreet                   =   'Calle TEST',
                BillingPostalCode               =   '12345',
                Lastname                        =   'MATCH',
                Salutation                      =   '1',
            	LandlineProfessionalTelephone__pc =   '+843434',
                personEmail                     =   'test@test.com',
                RecordTypeID                    =   AccountConstants.ACCOUNT_RT_B2C
        );
        
        Account acct3 = new Account(
                Firstname                       =   'TEST ',
                BillingStreet                   =   'Calle TEST',
                BillingPostalCode               =   '12345',
                Lastname                        =   'MATCH',
                MobileProfessionalTelephone__pc =   '+843434',
                Salutation                      =   '1',
                personEmail                     =   'test@test.com',
                RecordTypeID                    =   AccountConstants.ACCOUNT_RT_B2C
        );
        
        Account acct4 = new Account(
                Firstname                       =   'TEST ',
                BillingStreet                   =   'Calle TEST',
                BillingPostalCode               =   '12345',
                Lastname                        =   'MATCH',
                NationalId__pc                  =   '30.686.957-4',
                MobileProfessionalTelephone__pc =   '+843434',
                Salutation                      =   '1',
                personEmail                     =   'test@test.com',
                RecordTypeID                    =   AccountConstants.ACCOUNT_RT_B2C
        );
        
         Account acct5 = new Account(
                Firstname                       =   'TEST ',
                BillingStreet                   =   'Calle TEST',
                BillingPostalCode               =   '12345',
                Lastname                        =   'MATCH',                
                MobileProfessionalTelephone__pc =   '+843434',
                LocalIdOfCustomer__c         =    '1234',
                Salutation                      =   '1',
                personEmail                     =   'test@test.com',
                RecordTypeID                    =   AccountConstants.ACCOUNT_RT_B2C
        );
        
        Account acct6 = new Account(
                Firstname                       =   'TEST ',
                BillingStreet                   =   'Calle TEST',
                BillingPostalCode               =   '12345',
                Lastname                        =   'MATCH',                
                LandlineProfessionalTelephone__pc =   '+843434',
                Salutation                      =   '1',
                personEmail                     =   'test@test.com',
                RecordTypeID                    =   AccountConstants.ACCOUNT_RT_B2C
        );
        
        Account acct7 = new Account(
                Firstname                       =   'TEST ',
                BillingStreet                   =   'Calle TEST',
                BillingPostalCode               =   '12345',
                Lastname                        =   'MATCH',                
                LandlinePersonalTelephone__pc   =   '95632423',
                Salutation                      =   '1',
                personEmail                     =   'test@test.com',
                RecordTypeID                    =   AccountConstants.ACCOUNT_RT_B2C
        );
    
        Account acct8 = new Account(
                Firstname                       =   'TEST ',
                BillingStreet                   =   'Calle TEST',
                BillingPostalCode               =   '12345',
                Lastname                        =   'MATCH',
                MobilePersonalTelephone__pc     =   '+843434',
                Salutation                      =   '1',
                personEmail                     =   'test@test.com',                
                RecordTypeID                    =   AccountConstants.ACCOUNT_RT_B2C
        );
             
        //Testing B2C GENERAL    
        if(lAccountsB2C.isEmpty()){
            lAccountsB2C.add(acct1);
            lAccountsB2C.add(acct2);
            lAccountsB2C.add(acct3);
            lAccountsB2C.add(acct4);
            lAccountsB2C.add(acct5);
            lAccountsB2C.add(acct6);
            lAccountsB2C.add(acct7);
            lAccountsB2C.add(acct8);
            insert lAccountsB2C;
            Integer iCont = 0;
        }
        Lead oLeadSpf = new Lead(
                FirstName                   = 'TEST ',
                LastName                    = 'MATCH',
                Street                      = 'CALLE TEST',
                City                        = 'Madrid',
                Country                     = 'España',
                LandlineProfessionalTelephone__c =   '+843434',
                PostalCode                  = '12345',
                MobileProfessionalTelephone__c =   '+843434',
                LandlinePersonalTelephone__c    =   '95632423',
                LocalIdOfCustomer__c         =    '1234',
                NationalId__c               = '1234',
                FiscalId__c                 = '1234',
                VehicleRegistrationNumber__c= '123',
                Birthdate__C                = Date.today()-23,
                Email                       = 'test@test.com',
                RecordType                = new Recordtype (id = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('B2C').getRecordTypeId()),
                VINOwnedVehicle__c          = '1234'
         );
        
        for(Integer i=1;i<10;i++) {
            
            Lead oLead = new Lead(
                FirstName                   = 'TEST ',
                LastName                    = 'matching'+i,
                Street                      = 'Calle de Sebastián Elcano',
                City                        = 'Madrid',
                Country                     = 'España', 
                PostalCode                  = '654546',
                MobileProfessionalTelephone__c =   '+843434',
                LandlinePersonalTelephone__c    =   '95632423',
                Birthdate__C                = Date.today()-23,
                Email                       = 'a@a.com',
                RecordType                = new Recordtype (id = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('B2C').getRecordTypeId()),
                VINOwnedVehicle__c          = ''+i
                );
            
            lLeadsB2C.add(oLead);
        }
        if(!lLeadsB2C.isEmpty()){
            lLeadsB2C.add(oLeadSpf);
            insert lLeadsB2C;
        }
        
       	fixedSearchResults.add(accB3.Id);
        fixedSearchResults.add(obAsset.Id);
        
        for(Account a :lAccountsB2C){
            fixedSearchResults.add(a.Id);
        }
        
        for(Account a :lAccountsB2B){
            fixedSearchResults.add(a.Id);
        }
        
        for(Contact c :lContact){
             fixedSearchResults.add(c.Id);
        }
        
        for(Account a :lAccountsB2BSpf){
            fixedSearchResults.add(a.Id);
        }
       	Test.setFixedSearchResults(fixedSearchResults);
        
        Test.startTest();
            AllocationMatchingProcess.matchLeadsAccounts(lLeadsB2C, 'B2C Matching');
            AllocationMatchingProcess.matchLeadsAccounts(lLeadsB2B, 'B2B Matching');

        Test.stopTest();       
    }
}
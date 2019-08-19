/*
-- - Name         : LeadUtilsTest
-- - Author       : DXC. Ruben Fernandez
-- - Date         : 06/02/2018
-- - Description  : Test class for LeadUtils.
--                  1. Lead_SLACalculationTest.

-- - History:
-- Date         Author  Version  Comments
-- -----------  -----   -------  --------------------------------------------------------
-- 06/02/2018   DXC     1.0      Initial version Ruben Fernandez
-- 14/05/2019   DR      1.1      Existing methods updated
--                               - Added Validation Rules bypass for current user
-- 15/05/2019   RF      1.2      Added new test methods:
--                               - Added Setup Methods (CEC Agent and Sales Manager user)
--                               - CECAgentLeadTest
--                               - CECAgentLeadTestEvent
--                               - CECAgentLeadTreatmentTest
-- 12/06/2019   Pedro Parraga    Edit
*/

@isTest
private class LeadUtilsTest {

    @testSetup static void setup() {

        List<String> lstActivities          = new List<String>{'VN'};
        List<Contact> lstContsA             = TestDataFactoryUtil.createPartnerUser(3, 1, 'Dealer', '133225511','1237770', 'EXTKEY0002','AP','PL', 'J',lstActivities,true);
        List<Contact> lstSales              = new List<Contact>();

        lstSales.add(lstContsA.get(0));
        lstSales.add(lstContsA.get(2));

        List<User> lstUsers1                = TestDataFactoryUtil.createUser(lstSales,'Sales_Manager','Partner','Manager');
        lstUsers1.get(0).Activity__c        = 'B2C-VN;B2C-VO;B2B-VN;B2B-VO';
        User CEC_User                       = TestDataFactoryUtil.createOneUser('CEC_Agent', 'Iberia',PAD.sUserBrand, PAD.sUserCountry,'E462425');
        CEC_User.IsActive                   = true;
        CEC_User.Activity__c                = 'B2C-VN;B2C-VO;B2B-VN;B2B-VO';
        lstUsers1.add(CEC_User);

        System.runAs(new User(Id = Userinfo.getUserId())) {
            Insert lstUsers1;
        }

        Insert new UserByPass__c(
            SetupOwnerId                    = UserInfo.getUserId(),
            ValidationRules__c              = true
        );

        Lead lea = new Lead(
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
                DestinationPOSCode__c       = '1237771',
                Company                     = 'DEALER TEST COMPANY_0031',
                PSABrand__c                 = 'AP',
                Email                       = 'test@leadexample.com',
                LeadCountry__c              = 'PL',
                LeadRequestType__c          = '1',
                IdReservationVD__c          = '12345323X',
                Status                      = 'Qualified',
                OwnerId                     = UserInfo.getUserId(),
                RecordTypeId                = PAD.getObjRecordType('Lead','B2B')
        );

        insert lea;
    }
    // TODO Add Asserts
    /**
     * Unit test for LeadUtils.LeadSLACalculation method.
     *
     * @author
     * @date
     * @param       none
     * @return      none
     */
    @isTest static void leadSLACalculationTest() {

        List<Lead> lstLeads = TestDataFactoryUtil.createLead(1, 'B2B', 'EXTKEY1001',null, 'AC','ES','VN', '22334413');
        Test.startTest();
            Insert lstLeads;
            Id idOwnerId;

            System.assertEquals(1,lstLeads.size(),'list should contain just one Lead');

            for(LeadAssignmentRuleProcess__mdt larp : [SELECT MasterLabel,
                                                              QualifiedApiName,
                                                              Active__c,
                                                              Activity__c,
                                                              Brand__c,
                                                              Country__c,
                                                              CustomerType__c,
                                                              DealerGrouping__c,
                                                              LeadChannel__c,
                                                              LeadRequestType__c,
                                                              LeadSource__c,
                                                              LeadType__c,
                                                              MarketingCode__c,
                                                              Sort__c,
                                                              SiteGeoIdPK__c,
                                                              PdVInternal__c,
                                                              TargetType__c,
                                                              TargetValue__c
                                                              FROM LeadAssignmentRuleProcess__mdt
                                                              WHERE Active__c = true
                                                              ORDER BY Sort__c ASC]){

                if (larp.TargetType__c == 'QUEUE') {
                    idOwnerId = (ID)larp.TargetValue__c;
                }
            }

            Datetime dtAux = LeadUtils.dtAdjustTimeZone(System.now(),'GMT');

            List<Lead> lstLeadsResult  = new List<Lead>([
                SELECT Id, OwnerId,TreatmentDueDate__c
                FROM Lead
                WHERE Id =:lstLeads.get(0).Id
            ]);

        Test.stopTest();
    }

    // TODO Add asserts
    /**
     * Unit test for LeadUtils.setActualTreatmentDate method.
     *
     * @author
     * @date
     * @param       none
     * @return      none
     */
    @isTest static void testSetActualTreatmentDate(){
        List<Account> lstAccounts = Test.loadData(Account.sObjectType, 'LeadsTestData_PersonAccount');

        System.assert(!lstAccounts.isEmpty(),'List should have Accounts');

        List<Lead> lstLeads = [SELECT Id,
                                      OwnerId,
                                      Status
                               FROM Lead];

        System.assert(!lstLeads.isEmpty(),'List should have Leads');

        LeadUtils.setActualTreatmentDate(
            new Map<Id, Lead> {lstLeads[0].Id => lstLeads[0]},
            new List<Lead> {new Lead(
                Id      = lstLeads[0].Id,
                Status  = 'Qualified',
                OwnerId = lstLeads[0].OwnerId
            )},
            'UPDATE_LEAD'
        );
    }


    // TODO Add asserts
    /**
     * Unit test for LeadUtils.changedOnwnerNotifications method.
     *
     * @author
     * @date
     * @param       none
     * @return      none
     */
    @isTest static void testChangedOnwnerNotifications(){

        List<Account> lstAccounts = Test.loadData(Account.sObjectType, 'LeadsTestData_PersonAccount');

        System.assert(!lstAccounts.isEmpty(),'List should have Accounts');

        List<Lead> lstLeads = [SELECT Id,
                                      OwnerId,
                                      LeadRequestType__c
                                FROM Lead];

        System.assert(!lstLeads.isEmpty(),'List should have Leads');

        LeadUtils.changedOnwnerNotifications(
            new Map<Id, Lead> {lstLeads[0].Id => new Lead(
                Id      = lstLeads[0].Id,
                OwnerId = null
            )},

            new List<Lead> {lstLeads[0]}
        );
    }

    // TODO Add asserts
    /**
     * Unit test for inserting Tasks.
     *
     * @author
     * @date
     * @param       none
     * @return      none
     */
    @isTest static void testInsertTasks(){

        List<Account> lstAccounts = Test.loadData(Account.sObjectType, 'LeadsTestData_PersonAccount');
        List<Lead> lstLeads = [SELECT Id FROM Lead];
        List<Task> lstTasks = new List<Task>();

        System.assert(!lstAccounts.isEmpty(),'List should have Accounts');
        System.assert(!lstLeads.isEmpty(),'List should have Leads');

        for (Lead currentLead : lstLeads) {
            lstTasks.add(new Task(
                WhoId = currentLead.Id
            ));
        }

        insert lstTasks;
    }

    // TODO Add asserts
    /**
     * Unit test for LeadUtils.calcFields method.
     *
     * @author      Diego Rincón
     * @date        2019-05-14
     * @param       none
     * @return      none
     */
    @isTest static void testCalcFields(){
        List<Account> lstAccounts = Test.loadData(Account.sObjectType, 'LeadsTestData_PersonAccount');
        List<Lead> lstLeads = [SELECT Id FROM Lead];

        System.assert(!lstAccounts.isEmpty(),'List should have Accounts');
        System.assert(!lstLeads.isEmpty(),'List should have Leads');

        List<Contact> lstContacts = new List<Contact>{

            new Contact(
                Salutation = '1',
                FirstName = 'Partner',
                LastName = 'UserAA',
                AccountId = lstAccounts.get(0).Id,
                Email = 'partner.user.aa@psa.invalid'
            )
        };

        insert lstContacts;

        System.assert(!lstContacts.isEmpty(),'List should have Contacts');

        List<Profile> lstProfiles = New List<Profile>([
            SELECT Id
            FROM Profile
            WHERE Name = 'Salesman'
        ]);

        List<UserRole> lstUserRoles = new List<UserRole>([
            SELECT Id, PortalType, PortalAccountId
            FROM UserRole WHERE PortalType = 'Partner'
        ]);

        List<User> lstUsers = new List<User>{new User(
            LastName            = 'Test',
            Email               = 'calcFields@testclass.com',
            Alias               = 'test',
            TimeZoneSidKey      = 'GMT',
            LocaleSidKey        = 'en_GB',
            EmailEncodingKey    = 'ISO-8859-1',
            ProfileId           = lstProfiles.get(0).Id,
            LanguageLocaleKey   = 'en_US',
            UserName            = 'calcFields@testclass.com',
            Country__c          = 'PL',
            Brand__c            = 'AC',
            VNRRDICode__c       = '12345',
            ContactId           = lstContacts.get(0).Id
        )};

        insert lstUsers;

        Group g = new Group(
            Name = 'Lead Calc Fields Test Queue'
        );

        insert g;

        for (Lead currentLead : lstLeads) {
           currentLead.OwnerId = g.Id;
        }

        LeadUtils.calcFields(lstLeads);

        for (Lead currentLead : lstLeads) {
            currentLead.OwnerId = lstUsers.get(0).Id;
            currentLead.TECH_Web2Lead__c = true;
            currentLead.et4ae5__Mobile_Country_Code__c = null;
            currentLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('B2C').getRecordTypeId();
        }

        LeadUtils.calcFields(lstLeads);

        for (Lead currentLead : lstLeads) {
            currentLead.OwnerId = lstUsers.get(0).Id;
            currentLead.TECH_Web2Lead__c = false;
            currentLead.et4ae5__Mobile_Country_Code__c = null;
            currentLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('B2C').getRecordTypeId();
        }

        LeadUtils.calcFields(lstLeads);
    }

    /**
     * Unit test for LeadUtils.activityQualifyingOwners method.
     *
     * @author      Ruben Fernandez
     * @date        2019-05-15
     * @param       none
     * @return      none
     */

    // TODO Add asserts
    @isTest static void cecAgentLeadTest(){
        User usrCecagent   = [SELECT Id,
                                      Username,
                                      IsActive
                                FROM User
                                WHERE Profile.Name = 'CEC_Agent'
                                AND IsActive=true
                                LIMIT 1];

        User usrSalesman = [SELECT Id,
                                    ContactId,
                                    Contact.AccountId,
                                    Contact.Account.CommunicationMode__c
                            FROM User
                            WHERE Activity__c != null
                            AND Profile.Name = 'Sales_Manager'
                            LIMIT 1];

        List<Lead> lstLeads    = [SELECT Id FROM Lead];

        System.runAs(usrCecagent) {
            Test.startTest();
                List<Account> lstAccounts = Test.loadData(Account.sObjectType, 'LeadsTestData_PersonAccount');

                System.assert(!lstAccounts.isEmpty(),'List should have Accounts');

                for (Lead currentLead : lstLeads) {
                    currentLead.OwnerId                           = usrSalesman.Id;
                    currentLead.TECH_Web2Lead__c                  = true;
                    currentLead.Longitude                         = -5.92483;
                    currentLead.Latitude                          = 43.55473;
                }

                LeadUtils.calcFields(lstLeads);

                for (Lead currentLead : lstLeads) {
                    currentLead.OwnerId                           = usrSalesman.Id;
                    currentLead.TECH_Web2Lead__c                  = true;
                    currentLead.et4ae5__Mobile_Country_Code__c    = null;
                    currentLead.CustomerType__c                   = '1';
                    currentLead.Activity__c                       = 'VN';
                    currentLead.CalculatedPOS__c                  = usrSalesman.Contact.AccountId;
                    currentLead.RecordTypeId                      = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('B2C').getRecordTypeId();
                }

                LeadUtils.calcFields(lstLeads);
                LeadUtils.setActualTreatmentDate(
                    new Map<Id, Lead> {
                        lstLeads[0].Id => lstLeads[0]
                    },
                    new List<Lead> {
                        new Lead(
                            Id      = lstLeads[0].Id,
                            Status  = 'Qualified',
                            OwnerId = usrSalesman.Id
                            )
                        },
                        'UPDATE_LEAD'
                    );
                
                LeadUtils.activityQualifyingOwners(lstLeads,new Map<Id, List<Id>> {usrSalesman.Contact.AccountId => new List<Id> { usrSalesman.ContactId }});
            Test.stopTest();
        }
    }


    /**
     * Unit test for LeadUtils.eventsQualifyingOwners method.
     *
     * @author      Ruben Fernandez
     * @date        2019-05-15
     * @param       none
     * @return      none
     */

    // TODO Add asserts
    @isTest static void cecAgentLeadTestEvent(){

        User usrCecagent   = [SELECT Id,
                                     Username,
                                     IsActive
                              FROM User
                              WHERE Profile.Name = 'CEC_Agent'
                              AND IsActive=true
                              LIMIT 1];

        User usrSalesman   = [SELECT Id,
                                     ContactId,
                                     Contact.AccountId,
                                     Contact.Account.CommunicationMode__c
                              FROM User
                              WHERE Contact.Account.CommunicationMode__c = '1'
                              AND Profile.Name = 'Sales_Manager'
                              LIMIT 1];

        List<Lead> lstLeads        = [SELECT Id FROM Lead];

        System.runAs(usrCecagent) {

            Test.startTest();
                List<Account> lstAccounts     = Test.loadData(Account.sObjectType, 'LeadsTestData_PersonAccount');
                List<Event> lstEvents       = new List<Event>();
                Map<Id, Set<Id>> mapSetIdsById  = new Map<Id, Set<Id>>();

                System.assert(!lstAccounts.isEmpty(),'List should have Accounts');

                for (Lead currentLead : lstLeads) {
                    currentLead.OwnerId                           = usrSalesman.Id;
                    currentLead.TECH_Web2Lead__c                  = true;
                    currentLead.et4ae5__Mobile_Country_Code__c    = null;
                    currentLead.CustomerType__c                   = '1';
                    currentLead.TECH_Web2Lead__c                  = true;
                    currentLead.Activity__c                       = 'VN';
                    currentLead.LeadCountry__c                    = 'PT';
                    currentLead.PSABrand__c                       = 'AC';
                    currentLead.CalculatedPOS__c                  = usrSalesman.Contact.AccountId;
                    currentLead.RecordTypeId                      = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('B2C').getRecordTypeId();

                    Event newEvent = new Event(
                        IsAllDayEvent           = false,
                        StartDateTime           = DateTime.now(),
                        EndDateTime             = DateTime.now()+10,
                        OwnerId                 = usrSalesman.Id,
                        Description             = 'Event Lead',
                        IsPrivate               = false,
                        IsRecurrence            = false,
                        IsReminderSet           = false,
                        HotOpportunity__c       = false,
                        AutomatedCreation__c    = false,
                        IsAllDayEvent__c        = false,
                        Type                    = 'Call'
                    );

                    lstEvents.add(newEvent);
                    mapSetIdsById.put(currentLead.Id,new Set<Id> { usrSalesman.Id });
                }

                Insert lstEvents;


                LeadUtils.dtDueDate(lstLeads,'function');
                LeadUtils.eventsQualifyingOwners(lstLeads,mapSetIdsById);
                LeadUtils.setActualTreatmentDate(
                    new Map<Id, Lead> {
                        lstLeads[0].Id => lstLeads[0]
                    },
                    new List<Lead> {
                        new Lead(
                            Id      = lstLeads[0].Id,
                            Status  = 'Qualified',
                            OwnerId = usrSalesman.Id
                        )
                    },
                    'UPDATE_LEAD'
                );
            Test.stopTest();
        }
    }

    /**
     * Unit test for LeadUtils.Treatment method.
     *
     * @author      Ruben Fernandez
     * @date        2019-05-15
     * @param       none
     * @return      none
     */

    @isTest static void cecAgentLeadTreatmentTest(){

        User usrCecagent = [
            SELECT Id, Username,IsActive
            FROM User
            WHERE Profile.Name = 'CEC_Agent' AND IsActive=true
            LIMIT 1
        ];

        User usrSalesman = [
            SELECT Id, ContactId, Contact.AccountId,Contact.Account.CommunicationMode__c
            FROM User
            WHERE Contact.Account.CommunicationMode__c = '2' AND Profile.Name = 'Sales_Manager' 
            LIMIT 1
        ];

        List<Lead> lstLeads = [SELECT Id FROM Lead];

        System.runAs(usrCecagent) {

            Test.startTest();

                List<Account> lstAccounts     = Test.loadData(Account.sObjectType, 'LeadsTestData_PersonAccount');
                List<Event> lstEvents       = new List<Event>();
                Map<Id, Set<Id>> mapSetIdsById  = new Map<Id, Set<Id>>();

                System.assert(!lstAccounts.isEmpty(),'List should have Accounts');

                for (Lead currentLead : lstLeads) {
                    currentLead.OwnerId                           = usrCecagent.Id;
                    currentLead.TECH_Web2Lead__c                  = true;
                    currentLead.et4ae5__Mobile_Country_Code__c    = null;
                    currentLead.CustomerType__c                   = '1';
                    currentLead.TECH_Web2Lead__c                  = true;
                    currentLead.Activity__c                       = 'VN';
                    currentLead.LeadCountry__c                    = 'PT';
                    currentLead.PSABrand__c                       = 'AC';
                    currentLead.CalculatedPOS__c                  = usrSalesman.Contact.AccountId;
                    currentLead.RecordTypeId                      = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('B2C').getRecordTypeId();
                }

                LeadUtils.setActualTreatmentDate(
                    new Map<Id, Lead> {
                        lstLeads[0].Id => lstLeads[0]},
                    new List<Lead> {new Lead(
                        Id          = lstLeads[0].Id,
                        Status      = 'Qualified',
                        OwnerId     = usrSalesman.Id,
                        Longitude   = -5.92483,
                        Latitude    = 43.55473
                    )},
                    'UPDATE_LEAD'
                );

                lstLeads[0].CalculatedPOS__c = null;

                LeadUtils.fireAllocation(
                    new Map<Id, Lead> {
                        lstLeads[0].Id => lstLeads[0]
                    },

                    new List<Lead> {
                        new Lead(
                            Id          = lstLeads[0].Id,
                            Status      = 'Qualified',
                            OwnerId     = usrSalesman.Id,
                            Longitude   = -5.92483,
                            Latitude    = 43.55473
                    )}
                );

                lstLeads[0].OwnerId = usrSalesman.Id;

                LeadUtils.allocateWebToLeadRecords(lstLeads);
                LeadUtils.setTreatmentDueDate(lstLeads);

            Test.stopTest();
        }
    }


    // TODO Add Asserts
    /**
     * Unit test for TaskUtils.getSubsidiaryConfig method.
     *
     * @author          Diego Rincón
     * @date            2019-05-27
     */
    @isTest static void testGetSubsidiaryConfig(){

        Test.loadData(Account.sObjectType, 'LeadsTestData_PersonAccount');

        List<Lead> lstLeads = [SELECT Id FROM Lead];

        System.assert(!lstLeads.isEmpty(),'List should have Accounts');

        lstLeads[0].PSABrand__c        = 'AC';
        lstLeads[0].LeadCountry__c     = 'PT';
        lstLeads[0].Activity__c        = 'VN';

        LeadUtils.getSubsidiaryConfig(lstLeads[0]);

        lstLeads[0].PSABrand__c        = 'AC';
        lstLeads[0].LeadCountry__c     = 'PT';
        lstLeads[0].Activity__c        = null;

        LeadUtils.getSubsidiaryConfig(lstLeads[0]);

        lstLeads[0].PSABrand__c        = 'AC';
        lstLeads[0].LeadCountry__c     = null;
        lstLeads[0].Activity__c        = null;

        LeadUtils.getSubsidiaryConfig(lstLeads[0]);

        lstLeads[0].PSABrand__c        = null;
        lstLeads[0].LeadCountry__c     = 'PT';
        lstLeads[0].Activity__c        = null;

        LeadUtils.getSubsidiaryConfig(lstLeads[0]);

        lstLeads[0].PSABrand__c        = null;
        lstLeads[0].LeadCountry__c     = null;
        lstLeads[0].Activity__c        = null;

        LeadUtils.getSubsidiaryConfig(lstLeads[0]);
    }

    /**
     * Unit test for TaskUtils.setTreatmentDueDate method.
     *
     * @author          Diego Rincón
     * @date            2019-05-28
     */

    // TODO Add Asserts
    @isTest static void testSetTreatmentDueDate(){

        List<Account> lstAccounts = Test.loadData(Account.sObjectType, 'LeadsTestData_PersonAccount');
        List<Lead> lstLeads = [SELECT Id FROM Lead];

        System.assert(!lstAccounts.isEmpty(),'List should have Accounts');

        List<Contact> lstContacts = new List<Contact>{
            new Contact(
                Salutation                      = '1',
                FirstName                       = 'Partner',
                LastName                        = 'UserAA',
                AccountId                       = lstAccounts.get(0).Id,
                Email                           = 'partner.user.aa@psa.invalid'
            )
        };

        insert lstContacts;

        List<Profile> lstProfiles = New List<Profile>([
            SELECT Id
            FROM Profile
            WHERE Name = 'Salesman'
        ]);

        List<UserRole> lstUserRoles = new List<UserRole>([
            SELECT Id, PortalType, PortalAccountId
            FROM UserRole WHERE PortalType = 'Partner'
        ]);

        List<User> lstUsers = new List<User>{new User(
            LastName            = 'Test',
            Email               = 'calcFields@testclass.com',
            Alias               = 'test',
            TimeZoneSidKey      = 'GMT',
            LocaleSidKey        = 'en_GB',
            EmailEncodingKey    = 'ISO-8859-1',
            ProfileId           = lstProfiles.get(0).Id,
            LanguageLocaleKey   = 'en_US',
            UserName            = 'calcFields@testclass.com',
            Country__c          = 'PL',
            Brand__c            = 'AC',
            VNRRDICode__c       = '12345',
            ContactId           = lstContacts.get(0).Id
        )};

        insert lstUsers;

        for (Lead currentLead : lstLeads) {
            currentLead.OwnerId           = lstUsers.get(0).Id;
            currentLead.LeadCountry__c    = 'PT';
            currentLead.PSABrand__c       = 'AC';
            currentLead.Activity__c       = 'VN';
            currentLead.LeadType__c       = 'PT';
        }

        LeadUtils.setTreatmentDueDate(lstLeads);
    }

    /**
     * Unit test for LeadUtils.eventsQualifyingOwners method.
     *
     * @author          Diego Rincón
     * @date            2019-07-02
     */

    // TODO Add Asserts
    @isTest static void testeventsQualifyingOwners(){
        List<Account> lstAccounts = Test.loadData(Account.sObjectType, 'LeadsTestData_PersonAccount');

        System.assert(!lstAccounts.isEmpty(),'List should have Accounts');

        List<Lead> lstLeads = new List<Lead>([
            SELECT
                Id,
                LeadCountry__c,
                PSABrand__c
            FROM Lead
        ]);

        List<Contact> lstContacts = new List<Contact>{
            new Contact(
                Salutation = '1',
                FirstName = 'Partner',
                LastName = 'UserAA',
                AccountId = lstAccounts.get(0).Id,
                Email = 'partner.user.aa@psa.invalid'
            )
        };

        insert lstContacts;

        List<Profile> lstProfiles = New List<Profile>([
            SELECT Id
            FROM Profile
            WHERE Name = 'Salesman'
        ]);

        List<User> lstUsers = new List<User>{new User(
            LastName            = 'Test',
            Email               = 'eqo@testclass.com',
            Alias               = 'test',
            TimeZoneSidKey      = 'GMT',
            LocaleSidKey        = 'en_GB',
            EmailEncodingKey    = 'ISO-8859-1',
            ProfileId           = lstProfiles.get(0).Id,
            LanguageLocaleKey   = 'en_US',
            UserName            = 'eqo@testclass.com',
            Country__c          = 'PL',
            Brand__c            = 'AC',
            VNRRDICode__c       = '12345',
            ContactId           = lstContacts.get(0).Id
        )};

        insert lstUsers;

        insert new List<Event>{
            new Event(
                OwnerId = lstUsers.get(0).Id,
                StartDateTime = System.now().addHours(1),
                EndDateTime = System.now().addHours(1).addMinutes(10),
                Type = 'Physical visit in PoS'
            )
        };

        Test.startTest();
            for (Lead currentLead : lstLeads) {
                currentLead.LeadCountry__c = 'PT';
                currentLead.PSABrand__c = 'AP';
                currentLead.TreatmentDueDate__c = System.now().addMinutes(65);
            }

            LeadUtils.eventsQualifyingOwners(
                lstLeads,
                new Map<Id, Set<Id>>{
                    lstLeads.get(0).Id => new Set<Id>{
                        lstUsers.get(0).Id
                    }
                }
            );
        Test.stopTest();
    }

    /**
     * Unit test for LeadUtils.flatAssignment method.
     *
     * @author          Diego Rincón
     * @date            2019-07-02
     */

    // TODO Add Asserts
    @isTest static void tesflatAssignment(){
        List<Account> lstAccounts = Test.loadData(Account.sObjectType, 'LeadsTestData_PersonAccount');

        System.assert(!lstAccounts.isEmpty(),'List should have Accounts');

        List<Lead> lstLeads = new List<Lead>([
            SELECT
                Id,
                LeadCountry__c,
                PSABrand__c
            FROM Lead
        ]);

        List<Contact> lstContacts = new List<Contact>{
            new Contact(
                Salutation = '1',
                FirstName = 'Partner',
                LastName = 'UserAA',
                AccountId = lstAccounts.get(0).Id,
                Email = 'partner.user.aa@psa.invalid'
            )
        };

        insert lstContacts;

        List<Profile> lstProfiles = New List<Profile>([
            SELECT Id
            FROM Profile
            WHERE Name = 'Salesman'
        ]);

        List<User> lstUsers = new List<User>{new User(
            LastName            = 'Test',
            Email               = 'flat@testclass.com',
            Alias               = 'test',
            TimeZoneSidKey      = 'GMT',
            LocaleSidKey        = 'en_GB',
            EmailEncodingKey    = 'ISO-8859-1',
            ProfileId           = lstProfiles.get(0).Id,
            LanguageLocaleKey   = 'en_US',
            UserName            = 'flat@testclass.com',
            Country__c          = 'PL',
            Brand__c            = 'AC',
            VNRRDICode__c       = '12345',
            ContactId           = lstContacts.get(0).Id
        )};

        insert lstUsers;

        Test.startTest();
            for (Lead currentLead : lstLeads) {
                currentLead.LeadCountry__c = 'PT';
                currentLead.PSABrand__c = 'AP';
                currentLead.TreatmentDueDate__c = System.now().addMinutes(65);
            }

            LeadUtils.flatAssignment(
                lstLeads,
                new Map<Id, Set<Id>>{
                    lstLeads.get(0).Id => new Set<Id>{
                        lstUsers.get(0).Id
                    }
                }
            );
        Test.stopTest();
    }
}
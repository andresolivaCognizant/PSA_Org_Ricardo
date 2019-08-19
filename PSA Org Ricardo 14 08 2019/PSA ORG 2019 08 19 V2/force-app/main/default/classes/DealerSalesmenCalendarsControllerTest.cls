/**
 * Salesforce
 * @author              Diego Rincón (DR) href=<diego.rincon@ext.mpsa.com>
 * Project:             PSA - Customer First
 * Description:         Unit tests to validate the behavior of
 *                      DealerSalesmenCalendarsController class.
 *
 * Changes (version)
 * -------------------------------------------------------------------------------------------------
 *              No.     Date            Author                  Description
 *              ----    ------------    --------------------    ------------------------------------
 * @version     1.0     2019-01-09      Diego Rincón (DR)       Class creation. Code coverage: 100%
 */

@isTest
private class DealerSalesmenCalendarsControllerTest {

    @testSetup static void setup() {
        Account a = new Account(
            Name            = 'Test Dealer',
            RecordTypeId    = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account_DealerPartner').getRecordTypeId()
        );

        insert a;

        Contact c = new Contact(
            FirstName = 'Test Dealer',
            LastName = 'Contact',
            AccountId = a.Id,
            Email = 'contact@test.dealer.com'
        );

        insert c;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Partner Community User'];

        User u = new User(
            ContactId           = c.Id,
            ProfileId           = p.Id,
            LastName            = 'LastName',
            Email               = 'contact@test.dealer.com',
            UserName            = 'dealer.salesmen.calendar@test.com',
            Alias               = 'dsc',
            TimeZoneSidKey      = 'America/Los_Angeles',
            EmailEncodingKey    = 'UTF-8',
            LanguageLocaleKey   = 'en_US',
            LocaleSidKey        = 'en_US',
            IsActive            = true
        );

        insert u;

        Event e = new Event(
            Subject = 'Call',
            OwnerId = u.Id,
            DurationInMinutes=10,
            ActivityDateTime=Date.today()
        );
        insert e;
    }

    @isTest static void testMethod1(){
        // create a JSONGenerator object
        // pass true to the constructor for pretty print formatting
        JSONGenerator g = JSON.createGenerator(true);

        g.writeStartObject();
            g.writeStringField(
                'record_id',
                [SELECT Id FROM Account].Id
            );
        g.writeEndObject();

        Test.startTest();
            DealerSalesmenCalendarsController.getEvents(g.getAsString());
        Test.stopTest();
    }

    @isTest static void testMethod2(){
        // create a JSONGenerator object
        // pass true to the constructor for pretty print formatting
        JSONGenerator g = JSON.createGenerator(true);

        g.writeStartObject();
            g.writeStringField(
                'record_id',
                '1234567'
            );
        g.writeEndObject();

        Test.startTest();
            DealerSalesmenCalendarsController.getEvents(g.getAsString());
        Test.stopTest();
    }

}
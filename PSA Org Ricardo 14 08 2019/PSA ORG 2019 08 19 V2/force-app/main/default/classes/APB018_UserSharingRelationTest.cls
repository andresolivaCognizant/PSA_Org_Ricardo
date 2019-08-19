/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class APB018_UserSharingRelationTest {

    @testSetup static void setup() {
        RecordType	rType = [SELECT Id FROM RecordType WHERE Name like '%Dealer%' LIMIT 1];

        Group g = new Group();
            g.Name = 'Test Group';
            g.DeveloperName = 'TestGroup';
            g.Type = 'Regular';
            g.DoesSendEmailToMembers = false;
            g.DoesIncludeBosses = true;
        insert g;

        Account account_Obj = new Account(
            Name            = 'Dealer',
            RecordTypeId    = rType.Id
        );

        insert account_Obj;

 
         Contact contact_Obj = new Contact(
            FirstName   = 'Contact',
            LastName    = 'Dealer',
            Email       = 'test@test.es',
            AccountId   = account_Obj.Id 
        );

        insert contact_Obj;
        
        User user_Obj = new User( 
            ContactId = contact_Obj.Id,
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Salesman'].Id,
            LastName = 'last1',
            Email = 'user1@test.com',
            Username = 'tstuser1@test.com',
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            brand__c = 'AP',
            IsActive = true
        );

        insert user_Obj;
        
        


    }

    static testMethod void testBatch(){

        Group[] lstG = [SELECT Id FROM Group WHERE Name = 'Test Group' Limit 1];
        User[] user_Obj = [SELECT Id FROM User WHERE Username = 'tstuser1@test.com' Limit 1];
        //setupData2(lstG[0].Id, user_Obj[0].Id);
        
        Test.startTest();
        
        APB018_UserSharingRelation obj01 = new APB018_UserSharingRelation();
        Database.executeBatch(obj01);
        Test.stopTest();
    }

    
    static void setupData2(id groupId, id userId) { 
        GroupMember gMember = new GroupMember (
            GroupId  		= groupId,
            UserOrGroupId   = userId
        );
        insert gMember;
    }

}
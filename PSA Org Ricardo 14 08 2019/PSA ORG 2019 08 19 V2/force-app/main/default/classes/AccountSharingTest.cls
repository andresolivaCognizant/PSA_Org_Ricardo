/**
	*   @Class : AccountSharingTest.cls
	*
	*   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
	*   @Created        :   07 Feb 2018
	*   @Description    :   Apex Unit test class for AccountSharingTest.cls
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description
	*	   Rubén Moreno				16 Feb 2018				 Creation.	
    *      Pedro Párraga            18/06/2019               Edit.
	*	   
	*   ----------------------------------------------------------------------------------------------------------------------------
**/


@isTest
public class AccountSharingTest {

    @isTest static void UnitTestManualSharing() {        
        Account acc = new Account(
                Name                                          =   'TEST MATCH',
                BillingPostalCode                             =   '23456',
            	RecordType                                    =   new RecordType(id=Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2B').getRecordTypeId())
        );
        
        insert acc;
        
        List<Opportunity> lOpp = TestDataFactoryUtil.createOpportunities(1, '', acc, 2, 'New', 30);
        
        List<Lead> lLead = TestDataFactoryUtil.createLead(1, 'B2B', 'acc', '', 'DS', 'FR', '', '');
        lLead[0].customer__c = acc.id;
        insert lLead;    
        
        
        test.startTest();
        AccountSharing.ManualSharingLeadConversion(lOpp);
        AccountSharing.ManualSharingLeadConversion(lLead);
        test.stopTest();
        
        
    }
    
    
    @isTest static void UnitTestRevokeAccessByBrand() {     
        User oUser1 = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = :Label.SystemAdministratorProfile].Id,
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
             Brand__c = 'AP'
        );
        
        User oUser2 = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = :Label.SystemAdministratorProfile].Id,
             LastName = 'last2',
             Email = 'tstuser2@test.com',
             Username = 'tstuser2@test.com',
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US',
             Brand__c = 'DS'
        );
        
        User oUser3 = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = :Label.SystemAdministratorProfile].Id,
             LastName = 'last3',
             Email = 'user3@test.com',
             Username = 'tstuser3@test.com',
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US',
             Brand__c = 'AC'
        );
        
        List<User> lUser = new List<User>{ouser1,ouser2,ouser3};
        insert lUser;
        
        Account acc1 = new Account(
                Name                                          =   'TEST MATCH 2',
            	Ownerid										  =    oUser1.Id,
                BillingPostalCode                             =   '23457',
            	RecordTypeId                                  =   Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2B').getRecordTypeId()
        );
        
        insert acc1;
        
        Account acc = new Account(
            Salutation			= 	'1',
            Ownerid				= 	oUser2.Id,
            FirstName			=	'TEST',
            LastName			=	'Account test',
            PersonalEmail__pc	=	'Accounttest@gmail.com',
            BillingPostalCode	=	'23456',
            NationalId__pc		=	'30.686.957-4',
            APAnonymization__pc	=	true,
            ACAnonymization__pc	=	true,
            DSAnonymization__pc	=	true,
            RecordTypeId		=	Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2C_PA').getRecordTypeId()
        );
        
        insert acc;     
        
        Test.startTest();
            AccountSharing.revokeAccessByBrand(new map<Id,Account> {acc.id => acc, acc1.id =>acc1});
            AccountSharing.PGroupAccountSharingLeadConversion(new map<Id,id> {acc.id => acc1.id });
            AccountSharing.ManualAccountSharingLeadConversion(new map<Id,id> {acc.id => acc1.id});
        Test.stopTest();
        
        
    }
    
}
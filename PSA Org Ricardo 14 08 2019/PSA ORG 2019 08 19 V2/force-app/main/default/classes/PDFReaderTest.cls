/*
-- - Name         : PDFReaderTest
-- - Author       : Ruben Fernandez
-- - Date         : 20/11/2018
-- - Description  : Test class for PDFReader
--                  1. PDFReaderMethodsTest
--                  2. PDFReaderMockTest
-- - History:
-- Date         Author  Version  Comments
-- -----------  -----   -------  ---------------------------------------
-- 22/01/2018   RFL     1.0      Initial version Ruben Fernandez
-- 18/06/2019   PP      1.1      Pedro Párraga 
*/

@isTest
private class PDFReaderTest {
	
	@testSetup 
	static void setup() {
        Account objAccount                  = new Account();
        objAccount.Country__c               = 'PL';
        objAccount.FirstName                = 'Account FirstName';
        objAccount.LastName                 = 'Account LastName';
        objAccount.Salutation               = '1';
        objAccount.PersonalEmail__pc        = 'b2c@test.com';
        objAccount.CompanyActivityType__c   = '0';
        objAccount.AccountType__c           = '0';
        objAccount.RecordTypeId             = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId();
        insert objAccount;
        
        Account objDealer		            = new Account();
        objDealer.Country__c	            = 'PL';
        objDealer.Name			            = 'Dealer';
        objDealer.RecordTypeId	            = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get( 'Account_DealerPartner' ).getRecordTypeId();

        insert objDealer;
        
        Opportunity objFleetRequest									= new Opportunity();
        objFleetRequest.OpportunityExtId__c							= 'FLEETTST0001';
        objFleetRequest.Name										= 'Fleet TST 10082018-1';
        objFleetRequest.StageName									= 'FR1';
        objFleetRequest.FleetRequestDate__c							= System.now();
        objFleetRequest.AccountId									= objAccount.Id;
        objFleetRequest.FleetCategory__c							= '17';
        objFleetRequest.CloseDate									= System.today().addDays( 15 );
        objFleetRequest.OrderStartDate__c							= System.today().addDays( 15 );
        objFleetRequest.OrderEndDate__c								= System.today().addDays( 20 );
        objFleetRequest.RecordTypeId								= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get( 'FleetRequestOpportunity' ).getRecordTypeId();
        objFleetRequest.Country__c									= 'PL';
        
        insert objFleetRequest;
        
        Opportunity objChildOpp										= new Opportunity();
        objChildOpp.OpportunityExtId__c								= 'CHILDOPPTST001';
        objChildOpp.Name											= 'Opp Stan';
        objChildOpp.StageName										= '4';
        objChildOpp.AccountId										= objAccount.Id;
        objChildOpp.CloseDate										= System.today().addDays( 15 );
        objChildOpp.ParentOpportunity__c							= objFleetRequest.Id;
        objChildOpp.OrderStartDate__c								= System.today().addDays( 15 );
        objChildOpp.OrderEndDate__c									= System.today().addDays( 20 );
        objChildOpp.RecordTypeId									= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get( 'Opportunity_Record_Type' ).getRecordTypeId();
        objChildOpp.Country__c										= 'PL';
        
        insert objChildOpp;
        
        SBQQ__Quote__c objFleetQuote								= new SBQQ__Quote__c();
        objFleetQuote.SBQQ__Key__c									= 'FLEETQUOTETST001';
        objFleetQuote.RecordTypeId									= Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get( 'FleetRequestQuote' ).getRecordTypeId();
        objFleetQuote.SBQQ__Account__c								= objAccount.Id;
        objFleetQuote.SBQQ__Status__c								= 'FR1';
        objFleetQuote.SBQQ__Partner__c								= objDealer.Id;
        objFleetQuote.Agent__c										= objDealer.Id;
        objFleetQuote.SBQQ__PrimaryContact__c						= [SELECT Id FROM Contact WHERE AccountId =: objAccount.Id LIMIT 1].Id;
        objFleetQuote.Driver__c										= objAccount.Id;
        objFleetQuote.SBQQ__Opportunity2__c							= objFleetRequest.Id;
        objFleetQuote.LCDV16__c										= 'LCDV001';
        objFleetQuote.ColorCode__c									= 'CC001';
        objFleetQuote.InteriorTrimCode__c							= 'ITC001';
        objFleetQuote.VersionDescription__c							= 'test';
        objFleetQuote.InteriorTrimDescription__c					= 'test';
        objFleetQuote.OptionCodes__c								= 'Opt 1';
        objFleetQuote.BasePrice__c									= 45;
        objFleetQuote.TotalOptions__c								= 87;
        objFleetQuote.ProductionYear__c								= 2017;
        //objFleetQuote.SubsidiaryPartAmount__c						= '545';
        objFleetQuote.SubsidiaryPartPercentage__c					= 2;
        //objFleetQuote.DealerPartAmount__c							= '654';
        objFleetQuote.DealerPartPercentage__c						= 6;
        objFleetQuote.OPV_LinkToOPVOffer__c							= 'https://psacallout.com/test';
        
        insert objFleetQuote;
        
        SBQQ__Quote__c objOrderQuote								= new SBQQ__Quote__c();
        objOrderQuote.SBQQ__Key__c									= 'QUOTETST003';
        objOrderQuote.RecordTypeId									= Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get( 'CPQ_Order_Form' ).getRecordTypeId();
        objOrderQuote.SBQQ__Account__c								= objAccount.Id;
        objOrderQuote.SBQQ__Status__c								= 'FR1';
        objOrderQuote.SBQQ__Partner__c								= objDealer.Id;
        objOrderQuote.Agent__c										= objDealer.Id;
        objOrderQuote.SBQQ__PrimaryContact__c						= [SELECT Id FROM Contact WHERE AccountId =: objAccount.Id LIMIT 1].Id;
        objOrderQuote.Driver__c										= objAccount.Id;
        objOrderQuote.SBQQ__Opportunity2__c							= objChildOpp.Id;
        objOrderQuote.LCDV16__c										= 'LCDV001';
        objOrderQuote.ColorCode__c									= 'CC001';
        objOrderQuote.InteriorTrimCode__c							= 'ITC001';
        objOrderQuote.VersionDescription__c							= 'test';
        objOrderQuote.InteriorTrimDescription__c					= 'test';
        objOrderQuote.OptionCodes__c								= 'Opt 13';
        objOrderQuote.BasePrice__c									= 45;
        objOrderQuote.TotalOptions__c								= 87;
        objOrderQuote.ProductionYear__c								= 2017;
        //objOrderQuote.SubsidiaryPartAmount__c						= '545';
        objOrderQuote.SubsidiaryPartPercentage__c					= 2;
        //objOrderQuote.DealerPartAmount__c							= '654';
        objOrderQuote.DealerPartPercentage__c						= 6;
        objOrderQuote.SBQQ__Primary__c								= true;
        objOrderQuote.OPV_LinkToOPVOffer__c							= 'https://psacallout.com/test';
        
        insert objOrderQuote;
        
        objChildOpp.SBQQ__PrimaryQuote__c							= objOrderQuote.Id;
        update objChildOpp;
       
    }
	private static testMethod void PDFReaderMockTest() {

        Test.startTest();
        	List<SBQQ__Quote__c> aux = new List<SBQQ__Quote__c>([SELECT Id FROM SBQQ__Quote__c Limit 1]);
        	Map<String, String> responseHeaders = new Map<String, String>();
        	Test.setMock( HttpCalloutMock.class, new PDFReaderMockTest( 200,'SUCCESS','VGhpcyBpcyBhIFBERiB0ZXN0IGRvY3VtZW50IHRvIGJlIGxvYWRlZA==',responseHeaders) ); 
			PDFReader.getCalloutResponseContents((STRING)aux.get(0).Id);
        Test.stopTest();
    }
}
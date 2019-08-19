/*
-- - Name         : LeadHandleDiscardTimeTest
-- - Author       : DXC. Ruben Fernandez
-- - Date         : 09/03/2018
-- - Description  : Test class for LeadHandleDiscardTimeTest class. Discard Time for Leads
--                  1. DiscardTimeTest.
--                  2. BulkDiscardTimeTest
-- - History:
-- Date         Author  Version  Comments
-- -----------  -----   -------  ---------------------------------------
-- 09/03/2018   DXC     1.0      Initial version Ruben Fernandez
*/
@isTest
private with sharing class LeadHandleDiscardTimeTest {
	
	private static final String DISCARDTIME_SETTING	= 'DiscardTime%';
	
	/* 1. DiscardTimeTest */
    @isTest static void DiscardTimeTest() {

        // Preparing test conditions.
        List<String> lstActivities  =   new List<String>(); 
        lstActivities.add('VN');
        List<Lead> lstLeads         =   TestDataFactoryUtil.createLead(1, 'B2B', 'EXTKEY0001',null, 'AP','ES','VN', '22334455');

		// Perform test
        Test.startTest();
        	Insert lstLeads;
        	
			Map<String,Integer> mapDiscardTimes = new Map<String,Integer>();
        	for (LeadDiscardTimeSetting__mdt lVal : [SELECT Days__c,Brand__c,Country__c FROM LeadDiscardTimeSetting__mdt where QualifiedApiName Like :DISCARDTIME_SETTING]){
				mapDiscardTimes.put(lVal.Brand__c + lVal.Country__c, Integer.valueOf(lVal.Days__c));
			}
        	List<Lead> lstLeadsResult 	= new List<Lead>([Select Id, Status, CreatedDate, TECH_DiscardTime__c,LeadCountry__c,PSABrand__c From Lead Where Id =:lstLeads.get(0).Id]);
        	// TECH_
        	Date dToday 				= lstLeadsResult.get(0).CreatedDate.date();
			Integer iDays				= mapDiscardTimes.get(lstLeadsResult.get(0).PSABrand__c + lstLeadsResult.get(0).LeadCountry__c);

        	System.assertEquals(lstLeadsResult.get(0).TECH_DiscardTime__c, dToday.addDays(iDays));
            // Record Status must be equal to Discarded.
        	//System.assertEquals(lstLeadsResult.get(0).Status, 'Discarded');

        Test.stopTest();

	}
	/* 2. BulkDiscardTimeTest */
    @isTest static void BulkDiscardTimeTest() {

        // Preparing test conditions.
        List<String> lstActivities  =   new List<String>(); 
        lstActivities.add('VN');
        List<Lead> lstLeads         =   TestDataFactoryUtil.createLead(10, 'B2B', 'EXTKEY0002',null, 'AP','ES','VN', '11334452');

		// Perform test
        Test.startTest();
        	Insert lstLeads;
        	
			Map<String,Integer> mapDiscardTimes = new Map<String,Integer>();
        	for (LeadDiscardTimeSetting__mdt lVal : [SELECT Days__c,Brand__c,Country__c FROM LeadDiscardTimeSetting__mdt where QualifiedApiName Like :DISCARDTIME_SETTING]){
				mapDiscardTimes.put(lVal.Brand__c + lVal.Country__c, Integer.valueOf(lVal.Days__c));
			}
        	List<Lead> lstLeadsResult 	= new List<Lead>([Select Id, Status, CreatedDate, TECH_DiscardTime__c,LeadCountry__c,PSABrand__c From Lead Where Id =:lstLeads.get(0).Id]);
        	// TECH_
        	Date dToday 				= lstLeadsResult.get(0).CreatedDate.date();
			Integer iDays				= mapDiscardTimes.get(lstLeadsResult.get(0).PSABrand__c + lstLeadsResult.get(0).LeadCountry__c);

        	System.assertEquals(lstLeadsResult.get(0).TECH_DiscardTime__c, dToday.addDays(iDays));
            // Record Status must be equal to Discarded.
        	//System.assertEquals(lstLeadsResult.get(0).Status, 'Discarded');

        Test.stopTest();

	}
}
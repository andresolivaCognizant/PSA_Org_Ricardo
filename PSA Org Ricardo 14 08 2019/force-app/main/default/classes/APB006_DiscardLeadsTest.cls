/*
-- - Name         : APB006_DiscardLeadsTest
-- - Author       : DXC. Ruben Fernandez
-- - Date         : 09/03/2018
-- - Description  : Test class for APB006_DiscardLeads batch. Discarding Leads
--                  1. DiscardLeadsNoCustomerTest.
--                  2. DiscardLeadsWithCustomerTest
--                  3. BulkDiscardLeadsTest
-- - History:
-- Date         Author  Version  Comments
-- -----------  -----   -------  ---------------------------------------
-- 09/03/2018   DXC     1.0      Initial version Ruben Fernandez
*/
@isTest
private with sharing class APB006_DiscardLeadsTest {
	
	private static final String DISCARDTIME_SETTING	= 'DiscardTime%';
	
	/* 1. DiscardLeadsNoCustomerTest */
    @isTest static void DiscardLeadsNoCustomerTest() {

        // Preparing test conditions.
        List<String> lstActivities  =   new List<String>(); 
        lstActivities.add('VN');
        List<Lead> lstLeads         =   TestDataFactoryUtil.createLead(1, 'B2B', 'EXTKEY0003',null, 'AP','ES','VN', '22334355');
        Insert lstLeads;
        for(Lead l : lstLeads){
        	l.TECH_DiscardTime__c 	= date.Today(); 
        }
		// Perform test
        Test.startTest();
        	Update lstLeads;
        	APB006_DiscardLeads b = new APB006_DiscardLeads();
            Database.executeBatch(b);
        Test.stopTest();
        // Record Status must be equal to Discarded.
		List<Lead> lstLeadsResult 	= new List<Lead>([Select Id, Status, CreatedDate, TECH_DiscardTime__c,LeadCountry__c,PSABrand__c From Lead Where Id =:lstLeads.get(0).Id]);
        System.assertEquals('Discarded',lstLeadsResult.get(0).Status);

	}


	/* 2. DiscardLeadsWithCustomerTest */
    @isTest static void DiscardLeadsWithCustomerTest() {

        // Preparing test conditions.
        List<String> lstActivities  =   new List<String>(); 
        lstActivities.add('VN');
        List<Lead> lstLeads         =   TestDataFactoryUtil.createLead(1, 'B2B', 'EXTKEY0004',null, 'AP','ES','VN', '22334354');
		List<Account> lstB2BAcc     =   TestDataFactoryUtil.createAccount(1,'B2B');
        Insert lstLeads;

        for(Lead l : lstLeads){
        	l.TECH_DiscardTime__c 	= date.Today();
        	l.Customer__c 			= lstB2BAcc.get(0).Id;
        }

		// Perform test
        Test.startTest();
        	Update lstLeads;
        	APB006_DiscardLeads b = new APB006_DiscardLeads();
            Database.executeBatch(b);
        Test.stopTest();
        // Record Status must be equal to Discarded.
		List<Lead> lstLeadsResult 	= new List<Lead>([Select Id, Status, CreatedDate, TECH_DiscardTime__c,LeadCountry__c,PSABrand__c From Lead Where Id =:lstLeads.get(0).Id]);
        //System.assertEquals('Discarded',lstLeadsResult.get(0).Status);

	}


	/* 3. BulkDiscardLeadsTest */
    @isTest static void BulkDiscardLeadsTest() {

        // Preparing test conditions.
  //      List<String> lstActivities  =   new List<String>(); 
  //      lstActivities.add('VN');
  //      List<Lead> lstLeadsA        =   TestDataFactoryUtil.createLead(201, 'B2B', 'EXTKEY0011',null, 'AP','ES','VN', '02334351');
  //      List<Lead> lstLeadsB        =   TestDataFactoryUtil.createLead(201, 'B2B', 'EXTKEY0012',null, 'AP','ES','VN', '02334352');
  //      List<Account> lstB2BAcc     =   TestDataFactoryUtil.createAccount(1,'B2B');
  //      Insert lstLeadsA;
  //      Insert lstLeadsB;
  //      for(Lead l : lstLeadsA){
  //      	l.TECH_DiscardTime__c 	= date.Today(); 
  //      }
  //      Integer iCount 				= 0;
  //      for(Lead l : lstLeadsB){
  //      	l.TECH_DiscardTime__c 	= date.Today();
  //      	l.Customer__c 			= lstB2BAcc.get(iCount).Id;
  //      	//iCount+=1;
  //      }
		//// Perform test
  //      Test.startTest();
  //      	Update lstLeadsA;
  //      	Update lstLeadsB;
  //      	APB006_DiscardLeads b = new APB006_DiscardLeads();
  //          Database.executeBatch(b);
  //      Test.stopTest();
  //      // Record Status must be equal to Discarded.
		//List<Lead> lstLeadsResult 	= new List<Lead>([Select Id, Status, CreatedDate, TECH_DiscardTime__c,LeadCountry__c,PSABrand__c From Lead Where Id =:lstLeadsA.get(0).Id]);
  //      System.assertEquals('Discarded',lstLeadsResult.get(0).Status);

	}
}
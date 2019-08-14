@IsTest
public with sharing class CustomListViewControllerTest {
	

	//@isTest
 //   static void CustomListViewController_GetViewsTest() {
 //   	// Perform test
 //       Test.startTest();

 //       Test.stopTest();
 //   }
      

    @isTest
    static void CustomListViewController_ListViewTest() {
    	List<ListView> lstRestul 	= new List<ListView>();
    	String sFinalQuery			= '';
    	String sQuery 				= 'SELECT Name, Account.Name, convertCurrency(Amount), CloseDate, toLabel(StageName), Owner.Alias, Id, RecordTypeId, CurrencyIsoCode,'+
    								' CreatedDate, LastModifiedDate, SystemModstamp, Account.Id, AccountId, Account.RecordTypeId, Owner.Id, OwnerId FROM Opportunity'+
    								' WHERE IsWon = true AND IsClosed = true ORDER BY Name ASC NULLS FIRST, Id ASC NULLS FIRST';
		String sFinalQueryN			= '';
    	String sQueryN 				= 'SELECT Name, Account.Name, convertCurrency(Amount), CloseDate, toLabel(StageName), Owner.Alias, Id, RecordTypeId, CurrencyIsoCode,'+
    								' CreatedDate, LastModifiedDate, SystemModstamp, Account.Id, AccountId, Account.RecordTypeId, Owner.Id, OwnerId FROM Opportunity'+
    								' ORDER BY Name ASC NULLS FIRST, Id ASC NULLS FIRST';    	

		List<ListView> listviews = new List<ListView>();
        for(ListView lstObj : [SELECT Id, Name, DeveloperName FROM ListView WHERE SobjectType ='Opportunity' order by name ASC]){
        	listviews.add(lstObj);
        }
        // Pro

    	// Perform test
    	//System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
	    Test.setMock(HttpCalloutMock.class, new CustomListViewMockGeneratorTest());
        CustomListViewController.getFilteredRecords(listviews.get(0).Id, 'Opportunity');
        

        Test.startTest();
			
			sFinalQuery				= CustomListViewController.AddQueryFilter(sQuery);
			sFinalQueryN			= CustomListViewController.AddQueryFilter(sQueryN);
			try{
				//CustomListViewController.readListView('All');
				lstRestul 			= CustomListViewController.getListViews('Opportunity');
			}catch(Exception e){
				//
			}
        Test.stopTest();
    }

    @isTest
    static void CustomListViewController_HierarchyTest() {
    	String sFinalQuery			= '';
    	String sQuery 				= 'SELECT Name, Account.Name, convertCurrency(Amount), CloseDate, toLabel(StageName), Owner.Alias, Id, RecordTypeId, CurrencyIsoCode,'+
    								' CreatedDate, LastModifiedDate, SystemModstamp, Account.Id, AccountId, Account.RecordTypeId, Owner.Id, OwnerId FROM Opportunity'+
    								' WHERE IsWon = true AND IsClosed = true ORDER BY Name ASC NULLS FIRST, Id ASC NULLS FIRST';
		String sFinalQueryN			= '';
    	String sQueryN 				= 'SELECT Name, Account.Name, convertCurrency(Amount), CloseDate, toLabel(StageName), Owner.Alias, Id, RecordTypeId, CurrencyIsoCode,'+
    								' CreatedDate, LastModifiedDate, SystemModstamp, Account.Id, AccountId, Account.RecordTypeId, Owner.Id, OwnerId FROM Opportunity'+
    								' ORDER BY Name ASC NULLS FIRST, Id ASC NULLS FIRST';  

    	Set<ID> lstRestul 			= new Set<ID>();
    	List<String> lstActivities  =   new List<String>(); 
        lstActivities.add('VN');
		List<Contact> lstConts       =   TestDataFactoryUtil.createPartnerUser(1, 2, 'Dealer', '133225511','1237770', 'EXTKEY0002','AP','CL', 'J',lstActivities,true);
		
		List<Contact> lstConts1      =  new List<Contact>();
		lstConts1.add(lstConts.get(0));
		List<Contact> lstConts2      =  new List<Contact>();
		lstConts2.add(lstConts.get(1));
        List<User> lstUsers1         =   TestDataFactoryUtil.createUser(lstConts1,'Sales_Manager','Partner','Manager');
        List<User> lstUsers2         =   TestDataFactoryUtil.createUser(lstConts2,'Sales_Manager_Agent','Partner','Worker');
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
        	lstUsers1.addAll(lstUsers2);
            Insert lstUsers1;
        }

    	// Perform test
    	//System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        Test.startTest();
        	System.runAs ( lstUsers1.get(0) ) {
        		lstRestul  			= CustomListViewController.getRoleSubordinateUsers();
        	 	sFinalQuery			= CustomListViewController.AddQueryFilter(sQuery);
				sFinalQueryN		= CustomListViewController.AddQueryFilter(sQueryN);
        	}
			 
        Test.stopTest();
    }

    @isTest
    static void CustomListViewController_TransferTest() {
    	// Preparing the test conditions.
        List<String> lstActivities  =   new List<String>(); 
        lstActivities.add('VN');
		List<Contact> lstConts      =   TestDataFactoryUtil.createPartnerUser(1, 1, 'Dealer', '133225511','1237770', 'EXTKEY0002','AP','CL', 'J',lstActivities,true);
        List<Account> lstB2BAcc     =   TestDataFactoryUtil.createAccount(1,'B2B');
        List<Opportunity> lstOpps   =   TestDataFactoryUtil.createOpportunities(1, null ,lstB2BAcc.get(0), 1000.0 ,'Proposal', 75);
        List<User> lstUsers         =   TestDataFactoryUtil.createUser(lstConts,'Salesman','Partner','Manager');
        
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            Insert lstUsers;
        }

		lstOpps.get(0).OwnerId 		= lstUsers.get(0).Id;
        update lstOpps;
        Boolean bResult 			= false;
        // Perform test
        Test.startTest();
       		LeadManualAssigmentController.setSelect('B2B');
       		String sRecordId 		='[{"value":"'+lstOpps.get(0).Id + '"}]';
       		bResult 				= CustomListViewController.setTransferRecords(sRecordId, lstUsers.get(0).Id);
        Test.stopTest();
    }

}
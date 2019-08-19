/**
	*   @Class : CustomerSearchAControllerTest.cls
	*
	*   @Author         :   Ruben Fernandez Lopez
	*   @Created        :   26 Mar 2018
	*   @Description    :   Apex Unit test class for CustomerSearchAController.csl
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description
	*	   Ruben Fernandez			26/03/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/


@isTest
private class CustomerSearchAControllerTest {

   static testMethod void CustomerSearchAControllerPositiveTest() {

    	List<String> whereSOSL = new List<String>();
    	whereSOSL.add('"Account_"');
    	

        List<String> lstActivities  =   new List<String>(); 
        lstActivities.add('VN');
        List<Contact> lstConts      =   TestDataFactoryUtil.createPartnerUser(1, 1, 'Dealer', '133225511','1237770', 'EXTKEY0002','AP','CL', 'J',lstActivities,true);
        List<Account> lstAccts      =   new List<Account>([Select Id,Name From Account Where Id =:lstConts.get(0).AccountId]);
        List<Account> lstB2BAcc     =   TestDataFactoryUtil.createAccount(3,'B2B');
        
        
        Account b2c = new Account(
			FirstName					= 'TEST',
			LastName					= 'TEST',
			Salutation					= '1',
			PersonalEmail__pc			= 'test@test.com',
			RecordTypeId				= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId()
		);
		
		insert b2c;
		
		Asset a = new Asset(
			Name						= 'Asset Test 1',
			AssetType__c				= 'VN',
			CurrencyIsoCode				= 'EUR',
			AccountId					= b2c.Id,
			InitialStepKm__c			= 25000,
			InitialStepYear__c			= 1,
			CyclicStepKm__c				= 25000,
			CyclicStepYear__c			= 1,
			Country__c					= 'ES',
			Brand__c					= 'AP',
			EnergyCode__c				= '01',
			FirstRegistrationDate__c	= Date.today().addMonths(-6),
			LastAPVVisitDate__c			= Date.today().addMonths(-3),
			LastAPVVisitMileage__c		= 3500
		);
		
		insert a;
		
		Test.setFixedSearchResults( new List<Id>{ b2c.Id, a.Id } );

    	Test.startTest();
    	    // Preparing the test conditions.
			CustomerSearchAController.getLabels('Lead');
			

			//SetSelect Method
			CustomerSearchAController.setSelect('B2B');
			CustomerSearchAController.setSelect(null);
			CustomerSearchAController.setSelect('CCC');

			List<String> fields = new List<String>();
			fields.add('Id');
			fields.add('FirstName');
			fields.add('LastName');
			fields.add('Account.Name');
			CustomerSearchAController.getLabelsAux('Contact','Account', fields);
			String sName = 'Account_%';
			CustomerSearchAController.getfetchRecords('Account','B2B','Account.Name like '  + String.escapeSingleQuotes(sName),whereSOSL,false);

    	Test.stopTest();

    }
    static testMethod void SecretQuestionTest() {
      
        // List<Account> lstAccts         =   TestDataFactoryUtil.createAccountContact(1,'B2B');
         
         Account b2c = new Account(
			FirstName					= 'TEST',
			LastName					= 'TEST',
			Salutation					= '1',
			PersonalEmail__pc			= 'test@test.com',
			RecordTypeId				= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId()
		);
		
		insert b2c;
		
		Asset a = new Asset(
			Name						= 'Asset Test 1',
			AssetType__c				= 'VN',
			CurrencyIsoCode				= 'EUR',
			AccountId					= b2c.Id,
			InitialStepKm__c			= 25000,
			InitialStepYear__c			= 1,
			CyclicStepKm__c				= 25000,
			CyclicStepYear__c			= 1,
			Country__c					= 'ES',
			Brand__c					= 'AP',
			EnergyCode__c				= '01',
			FirstRegistrationDate__c	= Date.today().addMonths(-6),
			LastAPVVisitDate__c			= Date.today().addMonths(-3),
			LastAPVVisitMileage__c		= 3500
		);
		
		insert a;
		
		Test.setFixedSearchResults( new List<Id>{ b2c.Id, a.Id } );
        
        // Perform test
        Test.startTest();
        	CustomerSearchAController.getLabels('Lead');
        
            //List<Contact> lstContact    =   new List<Contact>([SELECT Id, AccountId From Contact Where AccountId =:lstAccts.get(0).Id]);
            String  sQuestion           =   CustomerSearchAController.getSecretQuestion(b2c.Id, 'SecretQuestionFieldsB2C','Account');
            Boolean bResponse           =   CustomerSearchAController.getQuestionResponse('Y3Zuk+0K/+J1s6rJeH9bAe3o4WDx4Ki0CIUWaG2NyP4=','response',null,null);

        Test.stopTest();

    }
    static testMethod void FechRecordsTest() {
      
        // Preparing the test conditions.
        List<String> lstActivities  =   new List<String>(); 
        lstActivities.add('VN');
        List<Contact> lstConts      =   TestDataFactoryUtil.createPartnerUser(1, 1, 'Dealer', '133225511','1237770', 'EXTKEY0002','AP','CL', 'J',lstActivities,true);
        List<Account> lstAccts      =   new List<Account>([Select Id,Name From Account Where Id =:lstConts.get(0).AccountId]);
        List<Account> lstB2BAcc     =   TestDataFactoryUtil.createAccount(1,'B2B');
        List<User> lstUsers         =   TestDataFactoryUtil.createUser(lstConts,'Salesman','Partner','Manager');
        List<Lead> lstLeads         =   TestDataFactoryUtil.createLead(1, 'B2B', 'EXTKEY0002',null, 'AP','PL','VN', '22334455');

        System.debug('Results-->Lead:  OwnerId: ' + lstLeads.get(0).OwnerId + ' CalculatedPOS__c: ' + lstLeads.get(0).CalculatedPOS__c + ' Customer__c: ' + lstLeads.get(0).Customer__c );
        
        lstLeads.get(0).Customer__c = lstB2BAcc.get(0).Id;
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            Insert lstUsers;
        }
        
        
        Account b2c = new Account(
			FirstName					= 'TEST',
			LastName					= 'TEST',
			Salutation					= '1',
			PersonalEmail__pc			= 'test@test.com',
			RecordTypeId				= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId()
		);
		
		insert b2c;
		
		Asset a = new Asset(
			Name						= 'Asset Test 1',
			AssetType__c				= 'VN',
			CurrencyIsoCode				= 'EUR',
			AccountId					= b2c.Id,
			InitialStepKm__c			= 25000,
			InitialStepYear__c			= 1,
			CyclicStepKm__c				= 25000,
			CyclicStepYear__c			= 1,
			Country__c					= 'ES',
			Brand__c					= 'AP',
			EnergyCode__c				= '01',
			FirstRegistrationDate__c	= Date.today().addMonths(-6),
			LastAPVVisitDate__c			= Date.today().addMonths(-3),
			LastAPVVisitMileage__c		= 3500
		);
		
		insert a;
		
		Test.setFixedSearchResults( new List<Id>{ b2c.Id, a.Id } );

        // Perform test
        Test.startTest();
            Insert lstLeads;

            Boolean bResult = CustomerSearchAController.manualShareRecord(lstAccts.get(0).Id, lstUsers.get(0).Id, 'Read');
            List<CustomerSearchAController.DataTableColumns> lstTableColumn = new List<CustomerSearchAController.DataTableColumns>();
			List<CustomerSearchAController.DataTableObject> lstValues = new List<CustomerSearchAController.DataTableObject>();
            lstTableColumn.add(new CustomerSearchAController.DataTableColumns('Name','Name','Text',true,false));
     		lstValues.add(new CustomerSearchAController.DataTableObject(lstAccts.get(0),true));
            CustomerSearchAController.DataTableResponse ltngTableWrapper       = new CustomerSearchAController.DataTableResponse();
        	ltngTableWrapper.lstDataTableData                   = lstValues; //lstAux;
        	ltngTableWrapper.lstDataTableColumns                = lstTableColumn;

        Test.stopTest();
    }
    
	static testMethod void getfetchRecords1() {
		Account b2c = new Account(
			FirstName					= 'TEST',
			LastName					= 'TEST',
			Salutation					= '1',
			PersonalEmail__pc			= 'test@test.com',
			RecordTypeId				= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId()
		);
		
		insert b2c;
		
		Asset a = new Asset(
			Name						= 'Asset Test 1',
			AssetType__c				= 'VN',
			CurrencyIsoCode				= 'EUR',
			AccountId					= b2c.Id,
			InitialStepKm__c			= 25000,
			InitialStepYear__c			= 1,
			CyclicStepKm__c				= 25000,
			CyclicStepYear__c			= 1,
			Country__c					= 'ES',
			Brand__c					= 'AP',
			EnergyCode__c				= '01',
			FirstRegistrationDate__c	= Date.today().addMonths(-6),
			LastAPVVisitDate__c			= Date.today().addMonths(-3),
			LastAPVVisitMileage__c		= 3500
		);
		
		insert a;
		
		Test.setFixedSearchResults( new List<Id>{ b2c.Id, a.Id } );
		
		Test.startTest();
			String strOwnerId			= [SELECT OwnerId FROM Account WHERE Id =: b2c.Id LIMIT 1].OwnerId;
		
			CustomerSearchAController.getfetchRecords( 'Account', 'B2C', 'FirstName LIKE \'TEST%\' AND isPersonAccount=True', new List<String>{ 'TEST*' }, false );
		Test.stopTest();
	}
	
	static testMethod void getfetchRecords11() {
		Account b2c = new Account(
			FirstName					= 'TEST',
			LastName					= 'TEST',
			Salutation					= '1',
			PersonalEmail__pc			= 'test@test.com',
			RecordTypeId				= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId()
		);
		
		insert b2c;
		
		Asset a = new Asset(
			Name						= 'Asset Test 1',
			AssetType__c				= 'VN',
			CurrencyIsoCode				= 'EUR',
			AccountId					= b2c.Id,
			InitialStepKm__c			= 25000,
			InitialStepYear__c			= 1,
			CyclicStepKm__c				= 25000,
			CyclicStepYear__c			= 1,
			Country__c					= 'ES',
			Brand__c					= 'AP',
			EnergyCode__c				= '01',
			FirstRegistrationDate__c	= Date.today().addMonths(-6),
			LastAPVVisitDate__c			= Date.today().addMonths(-3),
			LastAPVVisitMileage__c		= 3500
		);
		
		insert a;
		
		Test.setFixedSearchResults( new List<Id>{ b2c.Id, a.Id } );
		
		Test.startTest();
			String strOwnerId			= [SELECT OwnerId FROM Account WHERE Id =: b2c.Id LIMIT 1].OwnerId;
		
			CustomerSearchAController.getfetchRecords( 'Account', 'B2C', 'FirstName LIKE \'TEST%\' AND isPersonAccount=True AND Owner.id=\'' + strOwnerId + '\'', new List<String>{ 'TEST*' }, false );
		Test.stopTest();
	}
	
	static testMethod void getfetchRecords2() {
		Account b2c = new Account(
			FirstName					= 'TEST',
			LastName					= 'TEST',
			Salutation					= '1',
			PersonalEmail__pc			= 'test@test.com',
			RecordTypeId				= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId()
		);
		
		insert b2c;
		
		Asset a = new Asset(
			Name						= 'Asset Test 1',
			AssetType__c				= 'VN',
			CurrencyIsoCode				= 'EUR',
			AccountId					= b2c.Id,
			InitialStepKm__c			= 25000,
			InitialStepYear__c			= 1,
			CyclicStepKm__c				= 25000,
			CyclicStepYear__c			= 1,
			Country__c					= 'ES',
			Brand__c					= 'AP',
			EnergyCode__c				= '01',
			FirstRegistrationDate__c	= Date.today().addMonths(-6),
			LastAPVVisitDate__c			= Date.today().addMonths(-3),
			LastAPVVisitMileage__c		= 3500
		);
		
		insert a;
		
		Test.setFixedSearchResults( new List<Id>{ b2c.Id, a.Id } );
		
		Test.startTest();
			CustomerSearchAController.getfetchRecords( 'Asset', 'Asset', 'AssetType__c = \'VN\'', new List<String>(), false );
		Test.stopTest();
	}
	
	static testMethod void getfetchRecords3() {
		Account b2c = new Account(
			FirstName					= 'EMPTY',
			LastName					= 'TEST',
			Salutation					= '1',
			PersonalEmail__pc			= 'test@test.com',
			RecordTypeId				= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId()
		);
		
		insert b2c;
		
		Test.setFixedSearchResults( new List<Id>{ b2c.Id } );
		
		Test.startTest();
			String strOwnerId			= [SELECT OwnerId FROM Account WHERE Id =: b2c.Id LIMIT 1].OwnerId;
		
			CustomerSearchAController.getfetchRecords( 'Account', 'B2C', 'FirstName LIKE \'EMPTY%\' AND isPersonAccount=True', new List<String>{ 'TEST*' }, false );
		Test.stopTest();
	}
	
	static testMethod void getfetchRecords31() {
		Account b2c = new Account(
			FirstName					= 'EMPTY',
			LastName					= 'TEST',
			Salutation					= '1',
			PersonalEmail__pc			= 'test@test.com',
			RecordTypeId				= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId()
		);
		
		insert b2c;
		
		Test.setFixedSearchResults( new List<Id>{ b2c.Id } );
		
		Test.startTest();
			String strOwnerId			= [SELECT OwnerId FROM Account WHERE Id =: b2c.Id LIMIT 1].OwnerId;
		
			CustomerSearchAController.getfetchRecords( 'Account', 'B2C', 'FirstName LIKE \'EMPTY%\' AND isPersonAccount=True AND Owner.id=\'' + strOwnerId + '\'', new List<String>{ 'TEST*' }, false );
		Test.stopTest();
	}
	
	static testMethod void getfetchRecords4() {
		Test.startTest();
			CustomerSearchAController.DataTableColumnsLink link		= new CustomerSearchAController.DataTableColumnsLink(
																		new CustomerSearchAController.DataTableEntity( 'Name' )
																	);
			
			CustomerSearchAController.DataTableCell cell			= new CustomerSearchAController.DataTableCell( 'Name', 'Name', 'top' );
		Test.stopTest();
	}
}
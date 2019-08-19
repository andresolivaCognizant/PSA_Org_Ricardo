/*-----------------------------------------------------------------------------------------------------------//
  * Class Name    : ChangeAccountStatusTest
  * Project       : PSA - C1ST - Sales
  * Author        : Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
  * Date          : 03/03/2019
  * Description   : Test Class of ChangeAccountStatus           
  *-----------------------------------------------------------------------------------------------------------
  *      Modification Log :
  *-----------------------------------------------------------------------------------------------------------
  *      Developer                Date                     Description    
  *     Carmen Hernandez        03/09/2019                Creation.
  *		Nerea Leguinazabal	    07/11/2019				  #C1STAGILE-16994: Use TestDataFactoryUtil for Data creation 
  *     Carmen Hernandez        07/18/2019                Refactor: Add Asserts; Coverage: 96%
  *-----------------------------------------------------------------------------------------------------------*/
@isTest 
public class ChangeAccountStatusTest { 

    /*********************************************************************************************************
    * @Method          :   setupCommonData
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/18/2019
    * @Description     :   This method is used to create test records once and then access them in every test 
    *                  :   method in the test class
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/    
    @testSetup static void setupCommonData(){

        //Insert Partner User
		List<Contact> lstContacts = TestDataFactoryUtil.createPartnerUser(1, 1, 'Dealer', '133225511','1237770', 'EXTKEY0002','AP','PT', 'J',new List<String>{'VN','VD'},true);
        List<User> lstUsers = TestDataFactoryUtil.createUser(lstContacts,'Sales_Manager','Partner','Manager');
        insert lstUsers;   

		//Insert 200 accounts
		System.runAs(lstUsers.get(0)){
			TestDataFactoryUtil.createPersonAccount(200);
		}
	}


    /*********************************************************************************************************
    * @Method          :   testInsertUpdateOrdersDifferentAccounts
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/18/2019
    * @Description     :   This method checks that the account status fields are updated correctly when 
	*					   Orders are updated / inserted
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/  
	@isTest static void testInsertUpdateOrdersDifferentAccounts(){

		List<Account> lstAccounts = [SELECT Id, ACAccountStatus__c, APAccountStatus__c, DSAccountStatus__c 
										FROM Account ORDER BY FirstName LIMIT 3];
	    User partnerUser = [SELECT Id, Name, Contact.AccountId FROM User WHERE LastName = 'Testing' AND 
										IsActive = true LIMIT 1];

		//Active order (Status != Cancelled) - Peugeot
		Order orderPeugeot = new Order(AccountId = lstAccounts.get(0).Id, EffectiveDate = System.today(), Status = SalesConstants.ORDER_STATUS_VD_COMPLETE,
			Brand__c = Constants.BRAND_PEUGEOT, OrderId__c = '123456780');
		//Inactive order (Status == Cancelled) - Citroen
		Order orderCitroen = new Order(AccountId = lstAccounts.get(1).Id, EffectiveDate = System.today(), Status = SalesConstants.ORDER_STATUS_CANCELLED,
			Brand__c = Constants.BRAND_CITROEN, OrderId__c = '123456781');
		//Active order (Status != Cancelled) - DS
		Order orderDS = new Order(AccountId = lstAccounts.get(2).Id, EffectiveDate = System.today(), Status = SalesConstants.ORDER_STATUS_CUSTOMER_WITHOUT_CAR,
			Brand__c = Constants.BRAND_DSAUTOMOBILES, OrderId__c = '123456782');

		//CASE 1: Insert Orders
        List<Order> lstOrders = new List<Order>{orderPeugeot, orderCitroen, orderDS}; 
		Test.startTest();
		System.runAs(partnerUser){
        	insert lstOrders;       
		}
        //Get updated data
		lstAccounts = [SELECT Id, ACAccountStatus__c, APAccountStatus__c, DSAccountStatus__c FROM Account WHERE Id IN: lstAccounts ORDER BY FirstName LIMIT 3];
		
		//Check XXAccountStatus__c fields
		//Check that the inactive elements have status = 'Prospect' and the active elements have status = 'Customer'
		System.assertEquals(lstAccounts.get(0).APAccountStatus__c, AccountConstants.ACCOUNT_TYPE_CUSTOMER);
		System.assertEquals(lstAccounts.get(1).ACAccountStatus__c, AccountConstants.ACCOUNT_TYPE_PROSPECT);
		System.assertEquals(lstAccounts.get(2).DSAccountStatus__c, AccountConstants.ACCOUNT_TYPE_CUSTOMER);

		//CASE 2: Update Orders
		lstOrders.get(0).Status = SalesConstants.ORDER_STATUS_CANCELLED;
		lstOrders.get(1).Status = SalesConstants.ORDER_STATUS_CUSTOMER_WITHOUT_CAR;
		lstOrders.get(2).Status = SalesConstants.ORDER_STATUS_CANCELLED;

		System.runAs(partnerUser){
        	update lstOrders;       
		}
		Test.stopTest();
		
        //Get updated data
		lstAccounts = [SELECT Id, ACAccountStatus__c, APAccountStatus__c, DSAccountStatus__c FROM Account WHERE Id IN: lstAccounts ORDER BY FirstName LIMIT 3];
		
		//Check XXAccountStatus__c fields
		//Check that the inactive elements have status = 'Prospect' and the active elements have status = 'Customer'
		System.assertEquals(lstAccounts.get(0).APAccountStatus__c, AccountConstants.ACCOUNT_TYPE_PROSPECT);
		System.assertEquals(lstAccounts.get(1).ACAccountStatus__c, AccountConstants.ACCOUNT_TYPE_CUSTOMER);
		System.assertEquals(lstAccounts.get(2).DSAccountStatus__c, AccountConstants.ACCOUNT_TYPE_PROSPECT);
	}

    /*********************************************************************************************************
    * @Method          :   testInsertUpdateOrderFormsSameAccount
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/18/2019
    * @Description     :   This method checks that the account status fields are updated correctly when 
	*					   OrderForms are updated / inserted
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/  
	@isTest static void testInsertUpdateOrderFormsSameAccount(){

		Account accountTest = [SELECT Id, ACAccountStatus__c, APAccountStatus__c, DSAccountStatus__c 
										FROM Account ORDER BY FirstName LIMIT 1];
	    User partnerUser = [SELECT Id, Name, Contact.AccountId FROM User WHERE LastName = 'Testing' AND 
										IsActive = true LIMIT 1];

		//Active orderForm (Status != Cancelled) - Peugeot
		SBQQ__Quote__C quotePeugeot = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
			'SBQQ__Account__c'  => accountTest.Id, 'SBQQ__Status__c' => SalesConstants.SBQQ_QUOTE_STATUS_DRAFT,
			'RecordTypeId'  => PAD.recordTypesMapByDeveloperName.get(Constants.RT_SBQQ_QUOTE_OPV_VD),
			'Brand__c'=> Constants.BRAND_PEUGEOT}, false);
		//Inactive orderForm (Status == Cancelled) - Citroen
		SBQQ__Quote__C quoteCitroen = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
			'SBQQ__Account__c'  => accountTest.Id, 'SBQQ__Status__c' => SalesConstants.SBQQ_QUOTE_STATUS_CANCELED,
			'RecordTypeId'  => PAD.recordTypesMapByDeveloperName.get(Constants.RT_SBQQ_QUOTE_OPV_VN),
			'Brand__c'=> Constants.BRAND_CITROEN} ,false);
		//Inactive orderForm (RecordType != OPV-VN/VD/VO) - DS
		SBQQ__Quote__C quoteDS = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
			'SBQQ__Account__c'  => accountTest.Id, 'SBQQ__Status__c' => SalesConstants.SBQQ_QUOTE_STATUS_DRAFT,
			'RecordTypeId'  => PAD.recordTypesMapByDeveloperName.get(Constants.RT_SBQQ_QUOTE_CPQ_ORDER_FORM),
			'Brand__c'=> Constants.BRAND_DSAUTOMOBILES} ,false);

		//CASE 1: Insert OrderForms
        List<SBQQ__Quote__C> lstOrderForms = new List<SBQQ__Quote__C>{quotePeugeot, quoteCitroen, quoteDS}; 
		Test.startTest();
		System.runAs(partnerUser){
        	insert lstOrderForms;       
		}

        //Get updated data
		accountTest = [SELECT Id, ACAccountStatus__c, APAccountStatus__c, DSAccountStatus__c FROM Account WHERE Id =: accountTest.Id ORDER BY FirstName LIMIT 1];		
		//Check XXAccountStatus__c fields
		//Check that the inactive elements have status = 'Prospect' and the active elements have status = 'Customer'		
		System.assertEquals(accountTest.APAccountStatus__c, AccountConstants.ACCOUNT_TYPE_CUSTOMER);
		System.assertEquals(accountTest.ACAccountStatus__c, AccountConstants.ACCOUNT_TYPE_PROSPECT);
		System.assertEquals(accountTest.DSAccountStatus__c, AccountConstants.ACCOUNT_TYPE_PROSPECT);
	
		//CASE 2: Update OrderForms
		lstOrderForms.get(0).SBQQ__Status__c = SalesConstants.SBQQ_QUOTE_STATUS_CANCELED;
		lstOrderForms.get(1).SBQQ__Status__c = SalesConstants.SBQQ_QUOTE_STATUS_DRAFT;
		lstOrderForms.get(2).SBQQ__Status__c = SalesConstants.SBQQ_QUOTE_STATUS_CANCELED;
		SBQQQuoteTriggerHandler.runTrigger(); 

		System.runAs(partnerUser){
        	update lstOrderForms;       
		}
		Test.stopTest();
		
        //Get updated data
		accountTest = [SELECT Id, ACAccountStatus__c, APAccountStatus__c, DSAccountStatus__c FROM Account WHERE Id =: accountTest.Id ORDER BY FirstName LIMIT 1];		
		
		//Check XXAccountStatus__c fields
		//Check that the inactive elements have status = 'Prospect' and the active elements have status = 'Customer'
		System.assertEquals(accountTest.APAccountStatus__c, AccountConstants.ACCOUNT_TYPE_PROSPECT);
		System.assertEquals(accountTest.ACAccountStatus__c, AccountConstants.ACCOUNT_TYPE_CUSTOMER);
		System.assertEquals(accountTest.DSAccountStatus__c, AccountConstants.ACCOUNT_TYPE_PROSPECT);
	}

    /*********************************************************************************************************
    * @Method          :   testInsertUpdateAssetRelation
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/18/2019
    * @Description     :   This method checks that the account status fields are updated correctly when 
	*					   AssetRelations are updated / inserted
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/  
	@isTest static void testInsertUpdateAssetRelation(){


		Account accountTest = [SELECT Id, ACAccountStatus__c, APAccountStatus__c, DSAccountStatus__c 
										FROM Account ORDER BY FirstName LIMIT 1];
	    User partnerUser = [SELECT Id, Name, Contact.AccountId FROM User WHERE LastName = 'Testing' AND 
										IsActive = true LIMIT 1];

		//Active assetRelation - Peugeot (Implicit: Insert AssetRelation, EndDate == null) 
		Asset assetPeugeot = new Asset(Name = 'A1', Brand__c = Constants.BRAND_PEUGEOT, AssetType__c = 'VN', CurrencyIsoCode = 'EUR', AccountId = accountTest.Id);
		//Active assetRelation - Citroen (Implicit: Insert AssetRelation, EndDate == null) 
		Asset assetCitroen = new Asset(Name = 'A2', Brand__c = Constants.BRAND_CITROEN, AssetType__c = 'VN', CurrencyIsoCode = 'EUR', AccountId = accountTest.Id);
		//Active assetRelation - DS (Implicit: Insert AssetRelation, EndDate == null))
		Asset assetDS = new Asset(Name = 'A3', Brand__c = Constants.BRAND_DSAUTOMOBILES, AssetType__c = 'VN', CurrencyIsoCode = 'EUR', AccountId = accountTest.Id);

		//CASE 1: Insert Assets (Implicit: Insert AssetRelations)
        List<Asset> lstAssets = new List<Asset>{assetPeugeot, assetCitroen, assetDS}; 
		Test.startTest();
		System.runAs(partnerUser){
        	insert lstAssets;       
		}

        //Get updated data
		accountTest = [SELECT Id, ACAccountStatus__c, APAccountStatus__c, DSAccountStatus__c FROM Account WHERE Id =: accountTest.Id ORDER BY FirstName LIMIT 1];		
		//Check XXAccountStatus__c fields
		//Check that the inactive elements have status = 'Prospect' and the active elements have status = 'Customer'
		System.assertEquals(accountTest.APAccountStatus__c, AccountConstants.ACCOUNT_TYPE_CUSTOMER);
		System.assertEquals(accountTest.ACAccountStatus__c, AccountConstants.ACCOUNT_TYPE_CUSTOMER);
		System.assertEquals(accountTest.DSAccountStatus__c, AccountConstants.ACCOUNT_TYPE_CUSTOMER);

		List<AccountContactAssetRelation__c> lstAssetRelation = [SELECT Id FROM AccountContactAssetRelation__c WHERE AssetId__c IN: lstAssets LIMIT 3];
		//CASE 2: Update AssetRelation
		lstAssetRelation.get(0).RelationEndDate__c = System.today();
		lstAssetRelation.get(1).RelationEndDate__c = System.today();
		lstAssetRelation.get(2).RelationEndDate__c = System.today();


		AssetRelationTriggerHandler.processedRecords.clear();
		AssetTriggerHandler.processedRecords.clear();
		System.runAs(partnerUser){
        	update lstAssetRelation;       
		}
		Test.stopTest();
		
        //Get updated data
		accountTest = [SELECT Id, ACAccountStatus__c, APAccountStatus__c, DSAccountStatus__c FROM Account WHERE Id =: accountTest.Id ORDER BY FirstName LIMIT 1];		
		
		//Check XXAccountStatus__c fields
		//Check that when the assetRelations update the RelationEndDate__c field have status = 'Old Customer'		
		System.assertEquals(accountTest.APAccountStatus__c, AccountConstants.ACCOUNT_TYPE_OLDCUSTOMER);
		System.assertEquals(accountTest.ACAccountStatus__c, AccountConstants.ACCOUNT_TYPE_OLDCUSTOMER);
		System.assertEquals(accountTest.DSAccountStatus__c, AccountConstants.ACCOUNT_TYPE_OLDCUSTOMER);
	}
}
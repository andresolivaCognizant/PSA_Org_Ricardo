/*-----------------------------------------------------------------------------------------------------------//
  * Class Name    : EnhancedRecordHeader_Test
  * Project       :
  * Author        :
  * Date          :
  * Description   : Test Class of EnhancedRecordHeader
  *
  *-----------------------------------------------------------------------------------------------------------
  *      Modification Log :
  *-----------------------------------------------------------------------------------------------------------
  *      Developer                Date                     Description
  *      Martin De Leon         07/18/2019               Added headers, Added more tests,
                                                         added asserts on existing
                                                         tests Coverage: 90%
  *-----------------------------------------------------------------------------------------------------------*/
@isTest
public class EnhancedRecordHeader_Test {

  /*********************************************************************************************************
    * @Method          :   setupCommonData
    * @Author          :
    * @Created         :
    * @Description     :   This method is used to create test records once and then access them in every test
    *                  :   method in the test class
    * @params	         :   void
    * @Returns         :   void
    **********************************************************************************************************/
	  @testSetup static void setup() {

        Account acc = new Account(
                Name = 'TEST',
                BillingPostalCode = '23456',
                RecordTypeId = Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2B').getRecordTypeId()
        );

        insert acc;

        Opportunity oppty = TestDataFactoryUtil.createOpportunities(new map<String, Object>{
                'Name'	  		=>	'opportunity with quote',
                'Probability'   => 30,
                'Amount'        => 2,
                'AccountId'     => acc.id,
                'CloseDate'     => System.today(),
                'Activity__c'   => 'VN',
                'Country__c'    => 'PL',
                'StageName'     => '1'
            } ,true);


            SBQQ__Quote__C quote = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
                'SBQQ__ExpirationDate__c'	=> System.today(),
                'SBQQ__Status__c'           => '1',
                'SBQQ__Opportunity2__c'     => oppty.id,
                'recordTypeId'              => PAD.recordTypesMapByDeveloperName.get(Constants.RT_SBQQ_QUOTE_CPQ_QUOTE)
            }, true);

            List<Account> accounts = new List<Account>();

            accounts.add(acc);

            TestDataFactoryUtil.createOrder(1,'VNOrders','Draft',accounts);
    }

    /*********************************************************************************************************
    * @Method          :   getRecordDetailsTEST
    * @Author          :
    * @Created         :
    * @Description     :   Tests the method getRecordDetails in class EnhancedRecordHeader_Ctrl
    * @params	         :   void
    * @Returns         :   void
    **********************************************************************************************************/
    @isTest static void getRecordDetailsTEST() {

  		  EnhancedRecordHeader_Ctrl.getRecordDetails([SELECT Id FROM Account LIMIT 1].Id);

    		try {
    		    EnhancedRecordHeader_Ctrl.getRecordDetails('');
    		} catch(AuraHandledException e) {
            System.assertEquals('System.AuraHandledException',e.getTypeName(),'Exception type should be "System.AuraHandledException"');
    		}
    }

    /*********************************************************************************************************
    * @Method          :   getRecordDetailsOrderTEST
    * @Author          :   Martin De Leon<martin.deleon@ext.mpsa.com>
    * @Created         :   07/05/2019
    * @Description     :   Tests the method getRecordDetails in class EnhancedRecordHeader_Ctrl using the Order object
    * @params	         :   void
    * @Returns         :   void
    **********************************************************************************************************/
    @isTest static void getRecordDetailsOrderTEST() {

      List<Order> orders = [SELECT Id FROM Order];

        System.assertEquals(1,orders.size(),'There should be only one Order');

  		  Map<String, Object> recordDetails = EnhancedRecordHeader_Ctrl.getRecordDetails(orders[0].Id);

        System.assert(!recordDetails.isEmpty(),'There should be only one key/value pair.');
    }

    /*********************************************************************************************************
    * @Method          :   getEnhancedHeaderConfigTEST
    * @Author          :
    * @Created         :
    * @Description     :   Tests the method getEnhancedHeaderConfig in class EnhancedRecordHeader_Ctrl
    * @params	         :   void
    * @Returns         :   void
    **********************************************************************************************************/
  	@isTest static void getEnhancedHeaderConfigTEST() {
  	  	String resultWithValue = EnhancedRecordHeader_Ctrl.getEnhancedHeaderConfig('Account');

    		String resultWithoutValue = EnhancedRecordHeader_Ctrl.getEnhancedHeaderConfig('');

        System.assertEquals('{"error":"No config found"}',resultWithoutValue, 'Unexpected result for having empty String parameter');
    }

    /*********************************************************************************************************
    * @Method          :   getAccountDetailsTEST
    * @Author          :   Martin De Leon<martin.deleon@ext.mpsa.com>
    * @Created         :   07/05/2019
    * @Description     :   Tests the method getAccountDetails in class EnhancedRecordHeader_Ctrl
    * @params	         :   void
    * @Returns         :   void
    **********************************************************************************************************/
  	@isTest static void getAccountDetailsTEST() {

        List<SBQQ__Quote__c> quotes = [SELECT Id FROM SBQQ__Quote__c];

        System.assertEquals(1,quotes.size(),'There should be only one Quote');

  	  	Map<String, Object> accountDetails = EnhancedRecordHeader_Ctrl.getAccountDetails(quotes[0].Id);

        System.assert(!accountDetails.isEmpty(),'There should be only one key/value pair.');
    }

    /*********************************************************************************************************
    * @Method          :   getAccountDetailsOrdersTEST
    * @Author          :   Martin De Leon<martin.deleon@ext.mpsa.com>
    * @Created         :   07/05/2019
    * @Description     :   Tests the method getAccountDetailsOrders in class EnhancedRecordHeader_Ctrl using the Order object
    * @params	         :   void
    * @Returns         :   void
    **********************************************************************************************************/
    @isTest static void getAccountDetailsOrdersTEST() {

        List<Order> orders = [SELECT Id FROM Order];

        System.assertEquals(1,orders.size(),'There should be only one Order');

  	  	Map<String, Object> accountDetails = EnhancedRecordHeader_Ctrl.getAccountDetails(orders[0].Id);

        System.assert(!accountDetails.isEmpty(),'There should be only one key/value pair.');
    }

}
/*-----------------------------------------------------------------------------------------------------------//
  * Class Name    : CareStaticVariablesTest
  * Project       : PSA - C1ST - Care
  * Author        : Martin De Leon    <martin.deleon@ext.mpsa.com>
  * Date          : 07/02/2019
  * Description   : Test Class of CaseStaticMehods
  *
 *-----------------------------------------------------------------------------------------------------------
  *      Modification Log :
  *-----------------------------------------------------------------------------------------------------------
  *      Developer                Date                     Description    
  *      Martin De Leon           07/02/2019               Creation.      
  *      Carmen Hernandez         07/15/2019               Add new method: checkGetCaseAssignmentRules - 97%
  *-----------------------------------------------------------------------------------------------------------*/
@isTest
private class CareStaticVariablesTest {

/*********************************************************************************************************
    * @Method          :   setupCommonData
    * @Author          :   Martin De Leon    <martin.deleon@ext.mpsa.com>
    * @Created         :   07/02/2019
    * @Description     :   This method is used to create test records once and then access them in every test
    *                  :   method in the test class
    * @params          :   void
    * @Returns         :   void
    **********************************************************************************************************/
 @testSetup static void setupCommonData() {

        //Create anonymous Account - Portugal
        Account anonymousAccountPT = TestDataFactoryUtil.createAccount(new map<String, Object>{
            'FirstName'=>'Portugal', 'LastName'=>'Anonymous', 'Phone'=>'+34630120456', 'Email__c'=> 'testEmailPT@emai.es',
            'TECH_IntegrationExtId__c'=> CareConstants.ANONYMOUS + 'PT', 'Country__c'=> 'PT',
            'RecordTypeId'=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA)}, false);

        //Create anonymous Account - Chile
        Account anonymousAccountCL = TestDataFactoryUtil.createAccount(new map<String, Object>{
            'FirstName'=>'Chile', 'LastName'=>'Anonymous', 'Phone'=>'+34630120456', 'Email__c'=> 'testEmailCL@emai.es',
            'TECH_IntegrationExtId__c'=> CareConstants.ANONYMOUS + 'CL', 'Country__c'=> 'CL',
            'RecordTypeId'=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA)}, false);

        //Insert 4 test accounts
        List<Account> accountsToInsert = new List<Account>{anonymousAccountPT,
                                                           anonymousAccountCL};
        insert accountsToInsert;

    }

    /*********************************************************************************************************
    * @Method          :   checkFlagWorkingForAccountsByCountry
    * @Author          :   Martin De Leon    <martin.deleon@ext.mpsa.com>
    * @Created         :   07/02/2019
    * @Description     :   This method is used to check that when invoking method getAnonymousAccsByCountry
                            the queries are only issued when the flag is true or if there are no records found.
    * @params          :   void
    * @Returns         :   void
    **********************************************************************************************************/
    @isTest static void checkFlagWorkingForAccountsByCountry() {

        List<Account> accountExternalIds = [SELECT TECH_IntegrationExtId__c FROM Account LIMIT 1];

        Set<String> accountTECHIntegrationExtIds = new Set<String>();

        for (Account currentAccount : accountExternalIds) {
            accountTECHIntegrationExtIds.add(currentAccount.TECH_IntegrationExtId__c);
        }

        Test.startTest();

        CareStaticVariables instance = CareStaticVariables.getInstance();

        Integer numberOfQueriesIssued = Limits.getQueries();

        System.assertEquals(0, numberOfQueriesIssued, 'DML STATEMENTS ARE DIFFERENT THAN EXPECTED.');

        instance.getAnonymousAccsByCountry(accountTECHIntegrationExtIds, true);

        numberOfQueriesIssued = Limits.getQueries();

        System.assertEquals(1, numberOfQueriesIssued, 'DML STATEMENTS ARE DIFFERENT THAN EXPECTED.');

        instance.getAnonymousAccsByCountry(accountTECHIntegrationExtIds, false);

        numberOfQueriesIssued = Limits.getQueries();

        System.assertEquals(1, numberOfQueriesIssued, 'DML STATEMENTS ARE DIFFERENT THAN EXPECTED.');

        instance.getAnonymousAccsByCountry(accountTECHIntegrationExtIds, true);

        numberOfQueriesIssued = Limits.getQueries();

        System.assertEquals(2, numberOfQueriesIssued, 'DML STATEMENTS ARE DIFFERENT THAN EXPECTED.');

        Test.stopTest();

    }
    

    /*********************************************************************************************************
    * @Method          :   checkFlagWorkingForAssetsByVINs
    * @Author          :   Martin De Leon    <martin.deleon@ext.mpsa.com>
    * @Created         :   07/02/2019
    * @Description     :   This method is used to check that when invoking method getAssetsByVINs
                           the queries are only issued when the flag is true or if there are no records found.
    * @params          :   void
    * @Returns         :   void
    **********************************************************************************************************/
    @isTest static void checkFlagWorkingForAssetsByVINs() {

        Set<String> vins = new Set<String>();

        for(Integer i=0;i < 200 ;i++) {
            vins.add('VF36E4HTH20160'+i);
        }

        Test.startTest();

        CareStaticVariables instance = CareStaticVariables.getInstance();

        Integer numberOfQueriesIssued = Limits.getQueries();

        System.assertEquals(0, numberOfQueriesIssued, 'DML STATEMENTS ARE DIFFERENT THAN EXPECTED.');

        instance.getAssetsByVINs(vins, true);

        numberOfQueriesIssued = Limits.getQueries();

        System.assertEquals(1, numberOfQueriesIssued, 'DML STATEMENTS ARE DIFFERENT THAN EXPECTED.');

        instance.getAssetsByVINs(vins, false);

        numberOfQueriesIssued = Limits.getQueries();

        System.assertEquals(1, numberOfQueriesIssued, 'DML STATEMENTS ARE DIFFERENT THAN EXPECTED.');

        instance.getAssetsByVINs(vins, true);

        numberOfQueriesIssued = Limits.getQueries();

        System.assertEquals(2, numberOfQueriesIssued, 'DML STATEMENTS ARE DIFFERENT THAN EXPECTED.');

        Test.stopTest();

    }
    
    
    /*********************************************************************************************************
    * @Method          :   checkFlagWorkingForgettingPicklistValues
    * @Author          :   Martin De Leon    <martin.deleon@ext.mpsa.com>
    * @Created         :   07/02/2019
    * @Description     :   This method is used to check that when invoking method getPicklistValues
                           the queries are only issued when the flag is true or if there are no records found.
    * @params          :   void
    * @Returns         :   void
    **********************************************************************************************************/
    @isTest static void checkFlagWorkingForgettingPicklistValues() {

        String picklistName = 'Brand__c';
        
        String keyPicklist = 'BRAND';

        Test.startTest();
        
        Map<String, String> brandsMap = new Map<String, String>();

        CareStaticVariables instance = CareStaticVariables.getInstance();

        brandsMap = instance.getPicklistValues(picklistName,keyPicklist, true);
        
        // The map should be filled.
        System.assert(!brandsMap.isEmpty());

        Map<String, String> anotherBrandsMap = instance.getPicklistValues(picklistName, keyPicklist, false);
        
        // code should return the existing Map and not run any describe.
        // So te wo maps should be equal.
        System.assert(brandsMap == anotherBrandsMap);

        Test.stopTest();

    }


    /*********************************************************************************************************
    * @Method          :   checkGetCaseAssignmentRules
    * @Author          :   Carmen Hernandez    <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/16/2019
    * @Description     :   This method is used to check that when invoking method GetCaseAssignmentRules
                           the queries are only issued when the flag is true or if there are no records found.
    * @params          :   void
    * @Returns         :   void
    **********************************************************************************************************/
    @isTest static void checkGetCaseAssignmentRules() {

        Test.startTest();
        CareStaticVariables instance = CareStaticVariables.getInstance();

        //At the beginning there are no queries 
        Integer numberOfQueriesIssued = Limits.getQueries();
        System.assertEquals(0, numberOfQueriesIssued, 'DML STATEMENTS ARE DIFFERENT THAN EXPECTED.');
        //The first time the method is called a query is executed
        instance.getCaseAssignmentRules(CareConstants.CASE_ASSIGNMENT_RULE_FO, false);
        numberOfQueriesIssued = Limits.getQueries();
        System.assertEquals(1, numberOfQueriesIssued, 'DML STATEMENTS ARE DIFFERENT THAN EXPECTED.');
        //The second time the method is called, it does not execute any query because it has the value 
        //stored in a static variable
        instance.getCaseAssignmentRules(CareConstants.CASE_ASSIGNMENT_RULE_FO, false);
        numberOfQueriesIssued = Limits.getQueries();
        System.assertEquals(1, numberOfQueriesIssued, 'DML STATEMENTS ARE DIFFERENT THAN EXPECTED.');
        //The query is executed again if the clearCache flag is true
        instance.getCaseAssignmentRules(CareConstants.CASE_ASSIGNMENT_RULE_FO, true);
        numberOfQueriesIssued = Limits.getQueries();
        System.assertEquals(2, numberOfQueriesIssued, 'DML STATEMENTS ARE DIFFERENT THAN EXPECTED.');

        Test.stopTest();
    }

}
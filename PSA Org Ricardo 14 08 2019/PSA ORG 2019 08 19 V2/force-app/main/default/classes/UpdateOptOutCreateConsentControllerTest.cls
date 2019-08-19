@isTest
private class UpdateOptOutCreateConsentControllerTest {
    
    private final static String GET_AVAILABLE_OPT_OUT           = 'AVAILABLE_OPT_OUT';

    @TestSetup
    static void makeData(){
        User DataSetCreatorUser = TestDataFactoryUtil.createUserCreatorDataSet();
        

        System.runAs(DataSetCreatorUser){
    		Account account = TestDataFactoryUtil.createAccount(new map<string,object>{
                'FirstName'               =>   'acc2',
                'LastName'                =>   'acc2',
                'PersonalEmail__pc'       =>   'acc2C@test.com',
                'RecordTypeId'            =>   PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA),
                'TECH_CreatedFromLead__c' =>   true,
                'Country__c'              =>   'PT',
                'NonResidentCustomer__pc' =>   false,
                'NationalId__pc'          =>   '500206007',
                'NationalId2__pc'         =>   '500206007',
                'TECH_ContactCountry__pc' =>    'PT',
                'NationalId2Type__pc'     =>   'NIF'
                }, true);

        Case caso = new Case(Status = '1', Origin = '1', Reason = '2', AccountId = account.Id, SuppliedName = 'Name', Country__c = 'ES', Brand__c = 'AC');
      	insert caso;

        }
    }

	@isTest static void updateOptOut_PersonnAccount_test() {
        Account pa = [Select Id, TECH_OptOut__pc, PersonContactId, Country__c, Brand__c from account where name like 'acc2%' limit 1];

        Test.startTest();
        System.assertEquals(Label.Do_not_contact_success, UpdateOptOutCreateConsentController.updateOptOut(pa.Id,'personAccount'));
        Test.StopTest();
	}

    @isTest static void updateOptOut_Case_test(){
        Case myCase = [SELECT Id, AccountId FROM Case limit 1];

        Test.startTest();
        System.assertEquals(Label.Opt_Out_succes, UpdateOptOutCreateConsentController.updateOptOut(myCase.Id,'case'));
        Test.StopTest();
    }
    
    @isTest
    static void check_methods_personnAccount_test(){
            Account pa = [Select Id, TECH_OptOut__pc, PersonContactId, Country__c, Brand__c from account where name like 'acc2%' limit 1];

            Test.startTest();
            System.assertEquals(Label.Do_not_contact_success, UpdateOptOutCreateConsentController.check(pa.id, 'personAccount'));
            Test.StopTest();
    }

    @isTest
    static void check_methods_Case_test(){
            Case myCase = [SELECT Id, AccountId FROM Case limit 1];

            Test.startTest();
            System.assertEquals(GET_AVAILABLE_OPT_OUT, UpdateOptOutCreateConsentController.check(myCase.id, 'case'));
            Test.stopTest();
    }
}
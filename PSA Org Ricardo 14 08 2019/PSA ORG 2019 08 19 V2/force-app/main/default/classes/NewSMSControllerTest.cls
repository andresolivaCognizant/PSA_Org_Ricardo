/******************************************************************************************
* Name: 			  NewSMSControllerTest
* Author: 			  Borja Gay
* Description:		  Test class for NewSMSController class
* 
* Changes (Version)
* -----------------------------------------------------------------------------------------
*			No.		Date			          Author		       Description
*			-----	----------		      ----------------	     ---------------
* @version	1.0		2019-07-01		        Borja Gay 	         Initial definition.
*******************************************************************************************/
@isTest
private class NewSMSControllerTest {

	@isTest static void test_method_one() {
		Test.setMock( HttpCalloutMock.class, new NewSMSMock(200));
       	Account acc = (Account)TestDataFactoryUtil.createSobject(Constants.SOT_ACCOUNT, new map<String, Object>{
                'FirstName'             => 'Account FirstName testMethod sobject',
                'LastName'              => 'Account LastNametest sobject',
                'Salutation'            => '1',
                'PersonalEmail__pc'     => 'b2ctestMethod2@test.com',
                'RecordTypeId'		    => PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA)
    	}, true);
		Case caso = (Case)TestDataFactoryUtil.createSobject(Constants.SOT_CASE, new map<String, Object>{
            'Status'                    => CareConstants.CASE_STATUS_OPEN,
            'Origin'                    => CareConstants.CASE_ORIGIN_PHONE,
            'Reason'                    => CareConstants.CASE_REASON_COMPLAINT,
            'AccountId'                 => acc.Id,
            'ContactId'                 => acc.PersonContactId,
            'SuppliedName'              => 'Name',
            'VIN__c'                    => 'CCCCCCCCCCCCCCCCC',
            'Country__c'                => 'DZ',
            'Language__c'               => 'FR',
            'Brand__c'                  => 'AP'
        },true);
        Test.startTest();
        	List<EmailTemplate> lst_em = [SELECT Id FROM EmailTemplate];
        	String idCase = caso.id;
        	String idEt = lst_em[0].Id;
        	List<String> getCaseInfon = NewSMSController.getCaseInfo(idCase);
        	List<String> getPhones = NewSMSController.getPhones(idCase);
        	String getTemplates = NewSMSController.getTemplates('AR_AP_Send_Chat','Details');
        	String loadBody = NewSMSController.loadBody(idEt);
        	String login = NewSMSController.login();
        	NewSMSController.sendSMS('111111111', 'Hola', 'AP',caso.id);
        	String createTask = NewSMSController.createTask(idCase, 'Hola');
        	List<String> phones = new List<String>();
        	phones.add('632273362');
        	NewSMSController.SMSResponse sms = NewSMSController.sendRequest(phones, 'Hola', 'AP', '324234324', caso.id,1);
			System.assertNotEquals(createTask,null);
        Test.stopTest();

		
	}
}
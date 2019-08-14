/*********************************************************************************************************
* Project:          C1ST: CORE - EmailMessageUtils
* Description:      Test class FOR EmailMessageUtil apex class.
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description
*           -----   ----------      --------------------    ---------------
* @version  1.0     2019-03-01      * ()      				Initial definition.
*           2.0     2019-05-14      Ruben Fernandez (RF)    Refactored to cover the 100%:
*                                                           + EmailIncomingNoCECAgentTest
*                                                           + EmailIncomingCECAgentTest
*********************************************************************************************************/
@isTest
private class EmailMessageUtilsTest {

	@testSetup static void setup() {

        User CEC_User           =   TestDataFactoryUtil.createOneUser('CEC_Agent', 'Iberia','AP', 'PT' ,'E462425');
        CEC_User.IsActive		=	true;
		Insert CEC_User;
    }
	
	 /* Testing Incoming Emails related to Cases */
    @isTest static void EmailIncomingNoCECAgentTest(){

            Test.startTest();
                List <Account> lstAcc           = TestDataFactoryUtil.createPersonAccount(1);
				// Create case
				map<String, Object> mapApiNameToFieldValueCmp = new map<String, Object>{
					'Subject'  		=>	'New Test Case 1',
					'Priority'		=>	'Phone',
					'Origin'		=>	CareConstants.CASE_ORIGIN_PHONE,
					'AccountId'		=>	lstAcc.get(0).Id,
					'Brand__c'		=>	PAD.sUserBrand,
					'Country__c'	=>	PAD.sUserCountry
				};
				sObject oCase 		=  TestDataFactoryUtil.createSobject('Case',mapApiNameToFieldValueCmp, true);
				List<EmailMessage> lstEmails = new List<EmailMessage>();

				EmailMessage e1 	= new EmailMessage(
					FromAddress 	= 'testcase1@example.org',
					Incoming 		= true,
					ToAddress		= 'testcase1@example.org',
					Subject 		= 'Email Subject Test 01',
					HtmlBody 		= 'Email Body Test 01',
					ParentId 		= oCase.Id
				);
				List<EmailMessage> lstNewEmailMess = new List<EmailMessage> ();
				lstNewEmailMess.add(e1);
				Insert lstNewEmailMess;
				EmailMessageUtils.changeCaseStatus(lstNewEmailMess);
				EmailMessageUtils.validateEmailOWA(lstNewEmailMess);

            Test.stopTest();
    }

	/* Testing Incoming Emails related to Cases by CEC User */
    @isTest static void EmailIncomingCECAgentCaseOpenTest(){
		User usr                    = [SELECT Id, Username,IsActive, Contact.AccountId FROM User WHERE Profile.Name = 'CEC_Agent' AND IsActive=true LIMIT 1];
        Id caseId;
        List <Account> lstAcc       = TestDataFactoryUtil.createPersonAccount(1);
        lstAcc.get(0).OwnerId		= usr.Id;
        update lstAcc;
		System.runAs(usr) {
		    Test.startTest();
				// Create case
				map<String, Object> mapApiNameToFieldValueCmp = new map<String, Object>{
					'Subject'  		=>	'New Test Case 2 Open',
					'Priority'		=>	'Phone',
					'Origin'		=>	CareConstants.CASE_ORIGIN_PHONE,
					'AccountId'		=>	lstAcc.get(0).Id,
					'Brand__c'		=>	PAD.sUserBrand,
					'Country__c'	=>	PAD.sUserCountry
				};
				sObject oCase 		=  TestDataFactoryUtil.createSobject('Case',mapApiNameToFieldValueCmp, true);
				caseId				=  oCase.Id;

				List<EmailMessage> lstEmails = new List<EmailMessage>();
				EmailMessage oEM 	= new EmailMessage();
				oEM.FromAddress 	= 'testcase2@example.org';
				oEM.Incoming 		= false;
				oEM.ToAddress		= 'testcase2@example.org';
				oEM.Subject 		= 'Email Subject Test 02';
				oEM.HtmlBody 		= 'Email Body Test 02';
				oEM.parentId 		= oCase.Id ;

				Insert oEM;
				List<EmailMessage> lstNewEmailMess = new List<EmailMessage> ();
				lstNewEmailMess.add(oEM);
				EmailMessageUtils.changeCaseStatus(lstNewEmailMess);
				EmailMessageUtils.validateEmailOWA(lstNewEmailMess);
            Test.stopTest();
		}
		List<Case> lstCases = [SELECT Id, Status FROM Case WHERE Id =: caseId LIMIT 1];
		//System.assertEquals(lstCases.get(0).Status, CareConstants.CASE_STATUS_UPDATED_BY);
		System.assertEquals(CareConstants.CASE_STATUS_TAKEN_INTO_ACCOUNT,lstCases.get(0).Status);
    }

	@isTest static void EmailIncomingCECAgentCaseClosedTest(){
		User usr                    = [SELECT Id, Username,IsActive, ContactId, Contact.AccountId FROM User WHERE Profile.Name = 'CEC_Agent' AND IsActive=true LIMIT 1];
       	List <Account> lstAcc       = TestDataFactoryUtil.createPersonAccount(1);
       	lstAcc.get(0).OwnerId		= usr.Id;
        update lstAcc;
        Id caseCloseId;
        System.debug('usr: ' + usr);
		System.runAs(usr) {
		    Test.startTest();
				// Create case
				map<String, Object> mapApiNameToFieldValueCase = new map<String, Object>{
					'Subject'  		=>	'New Test Case 3 Close',
					'Priority'		=>	'Phone',
					'Origin'		=>	CareConstants.CASE_ORIGIN_PHONE,
					'Status'		=>  CareConstants.CASE_STATUS_OPEN,
					'AccountId'		=>	lstAcc.get(0).Id,
					'Brand__c'		=>	PAD.sUserBrand,
					'Country__c'	=>	PAD.sUserCountry
				};
				sObject oCaseClose	=  TestDataFactoryUtil.createSobject('Case',mapApiNameToFieldValueCase, true);
                // Now we can move forward to the next status
            	oCaseClose.put('Status', CareConstants.CASE_STATUS_CLOSED);
				oCaseClose.put('CloseReasonL1__c','105');
				oCaseClose.put('CaseSurveyAcceptance__c','Yes');
				update oCaseClose;
				// Create EmailMessage asociated with the case created.
				List<EmailMessage> lstEmails = new List<EmailMessage>();
				EmailMessage oEM 	= new EmailMessage();
				oEM.FromAddress 	= 'testcase3@example.org';
				oEM.Incoming 		= true;
				oEM.ToAddress		= 'testcase3@example.org';
				oEM.Subject 		= 'Email Subject Test 03';
				oEM.HtmlBody 		= 'Email Body Test 03';
				oEM.parentId 		= oCaseClose.Id ;
				Insert oEM;
				List<EmailMessage> lstNewEmailMess = new List<EmailMessage> ();
				lstNewEmailMess.add(oEM);
				EmailMessageUtils.changeCaseStatus(lstNewEmailMess);
				EmailMessageUtils.validateEmailOWA(lstNewEmailMess);
            Test.stopTest();
		}
		List<Case> lstCases = [SELECT Id, Status FROM Case WHERE Subject = 'New Test Case 3 Close' LIMIT 1];
		//System.assertEquals(lstCases.get(0).Status, CareConstants.CASE_STATUS_REOPENED);
		//System.assertEquals(CareConstants.CASE_STATUS_TAKEN_INTO_ACCOUNT,lstCases.get(0).Status);
    }
}
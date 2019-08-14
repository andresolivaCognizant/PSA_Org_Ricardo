/*********************************************************************************************************
* Project:          C1ST: CORE - EmailMessageHandlerTest
* Description:      Test class FOR EmailMessageHandler apex class.
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description
*           -----   ----------      --------------------    ---------------
* @version  1.0     2019-05-14      Ruben Fernandez (RF)    Initial Version
*                                                           + EmailIncomingTest
*********************************************************************************************************/
@isTest
public class EmailMessageHandlerTest {
    
     /* Testing Incoming Emails related to Cases */
    @isTest static void EmailIncomingTest(){
            Boolean bResult;
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

				EmailMessage em1 	= new EmailMessage(
					FromAddress 	= 'testcase1@example.org',
					Incoming 		= true,
					ToAddress		= 'testcase1@example.org',
					Subject 		= 'Email Subject Test 01',
					HtmlBody 		= 'Email Body Test 01',
					ParentId 		= oCase.Id 
				);
                EmailMessage em2 	= new EmailMessage(
					FromAddress 	= 'testcase2@example.org',
					Incoming 		= false,
					ToAddress		= 'testcase2@example.org',
					Subject 		= 'Email Subject Test 02',
					HtmlBody 		= 'Email Body Test 02',
					ParentId 		= oCase.Id 
				);
				List<EmailMessage> lstNewEmailMess = new List<EmailMessage> ();
				lstNewEmailMess.add(em1);
                lstNewEmailMess.add(em2);
				Insert lstNewEmailMess;
                
                bResult = EmailMessageHandler.shouldRunTrigger();

            Test.stopTest();
            System.assertEquals(true,bResult);
    }
}
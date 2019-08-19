/*********************************************************************************************************
* Project:          C1ST: CORE - Quote Flows
* Description:      Test class FOR NewQuoteController apex class.
*
* COVERAGE:         NewQuoteController --> 100%
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description
*           -----   ----------      --------------------    ---------------
* @version  1.0     2019-06-10      Ruben Fernandez (RF)    Initial definition.
*                                                           + QuoteFlowTest
*		             07/11/2019	   	Nerea Leguinazabal	    #C1STAGILE-16994: Use TestDataFactoryUtil for Data creation 
*********************************************************************************************************/
@isTest 
public with sharing class NewQuoteControllerTest {
    @isTest static void QuoteFlowTest() {
       
        Account acc = new Account(
            Name            = 'Test Dealer 1',
            RecordTypeId    = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account_DealerPartner').getRecordTypeId()
        );

        insert acc;

    SBQQ__Quote__C quote = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
                    'SBQQ__ExpirationDate__c'  => System.Today()-1,
                    'SBQQ__Status__c' => '2',
                    'SBQQ__Account__c'  => acc.id
                } ,true);    

	  

        Test.startTest();

            ApexPages.StandardController sc         = new ApexPages.StandardController(quote);
            NewQuoteController testQuoteController  = new NewQuoteController(sc);
            PageReference pageRef                   = Page.QuoteExpenses;		
	        Test.setCurrentPage(pageRef);			

            PageReference pageResult                = testQuoteController.getFinishPageRef();
            System.assertEquals('/home/home.jsp', pageResult.getUrl());
        Test.stopTest();
    }
}
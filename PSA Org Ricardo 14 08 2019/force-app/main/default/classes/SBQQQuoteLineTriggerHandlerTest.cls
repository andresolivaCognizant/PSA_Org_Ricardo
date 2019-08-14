/*
*   @Class : SBQQQuoteLineTriggerHandlerTest.cls
*
*   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
*   @Created        :   02 08 2018
*   @Description    :   Test class for SBQQQuoteLineTriggerHandler

*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*       Developer               Date                     Description
*       Ruben Moreno		    03 08 2018				 Creation.
*       Nerea Leguinazabal      11 07 2019               #C1STAGILE-16994: Use TestDataFactoryUtil for Data creation  
*   ----------------------------------------------------------------------------------------------------------------------------
*/

@isTest
public class SBQQQuoteLineTriggerHandlerTest {

    @isTest static void quoteLineTrigger() {
        // Test data setup
        List<Account> lstAccts = TestDataFactoryUtil.createAccount(2,'B2B');

        for (Account a : lstAccts) {
            a.Country__c                = 'ES';
            a.CompanyActivityType__c    = '1';
            a.AccountType__c            = '0';
        }

        update lstAccts;

        Opportunity opp = new Opportunity (
            Name            = 'Test',
            StageName       = 'FR1',
            AccountId       = lstAccts[0].Id,
            CloseDate       = System.today(),
            Activity__c     = 'VN',
            RecordTypeId    = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Fleet Request Opportunity').getRecordTypeId(),
            Segment__c      = '25',
            Country__c      = 'IT'
        );
        insert opp;
        

		SBQQ__Quote__C oQuote = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
			'SBQQ__Opportunity2__c'		=> opp.id
		} ,true); 
  
        Product2 oProd = new Product2(Name = 'Peugeot 208', Family='Version', Stock__c = false);
        insert oProd;
        
        SBQQ__QuoteLine__c oQuoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.id , SBQQ__Product__c=oProd.id);
        insert oQuoteLine;

        
        // Perform test
        Test.startTest();
        SBQQQuoteLineTriggerHandler.afterDelete(new List<SBQQ__QuoteLine__c>{oQuoteLine});
        SBQQQuoteLineTriggerHandler.afterInsert(new List<SBQQ__QuoteLine__c>{oQuoteLine});
        SBQQQuoteLineTriggerHandler.beforeInsert(new List<SBQQ__QuoteLine__c>{oQuoteLine});
        SBQQQuoteLineTriggerHandler.afterUpdate(new List<SBQQ__QuoteLine__c>{oQuoteLine}, new map<id,SBQQ__QuoteLine__c>{oQuoteLine.id=>oQuoteLine});
        SBQQQuoteLineTriggerHandler.beforeUpdate(new List<SBQQ__QuoteLine__c>{oQuoteLine}, new map<id,SBQQ__QuoteLine__c>{oQuoteLine.id=>oQuoteLine});
        SBQQQuoteLineTriggerHandler.dontRunTrigger();
        Test.stopTest();

    }

}
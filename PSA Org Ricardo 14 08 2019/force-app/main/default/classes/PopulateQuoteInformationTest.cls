/*
*   @Class : PopulateQuoteInformationTest.cls
*
*   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
*   @Created        :   03 08 2018
*   @Description    :   Test class for PopulateQuoteInformation

*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*       Developer               Date                    Description
*	    Ruben Moreno			03 08 2018			    Creation.
*       Nerea Leguinazabal		11 07 2019              #C1STAGILE-16994: Use TestDataFactoryUtil for Data creation  
*   ----------------------------------------------------------------------------------------------------------------------------
*/

@isTest
public class PopulateQuoteInformationTest {
    
    @isTest static void mainProcessTest() {
        // Test data setup
        List<Account> lstAccts 		= TestDataFactoryUtil.createAccount(1,'B2B');
        lstAccts[0].CompanyActivityType__c    = '1';
        update lstAccts;
        
        Opportunity opp         	=   new Opportunity (
                Name                =   'Test',
                StageName           =   'New',
                AccountId           =   lstAccts[0].Id,
                CloseDate           =   System.today(),
                Activity__c         =   'VN',
                RecordTypeId        =   Schema.SObjectType.OPPORTUNITY.getRecordTypeInfosByName().get('Fleet Request Opportunity').getRecordTypeId(),
            	Segment__c			=	'25',
                Country__c          =   'IT'
        );
        insert opp;
        
        SBQQ__Quote__C oQuote = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
			'SBQQ__Opportunity2__c'	=> opp.Id
			} ,true); 
        
        Product2 oProd1 = new Product2(Name = 'Peugeot 208', Family=Label.ProductFamilyVersion, Stock__c = false);
        insert oProd1;
        
        SBQQ__QuoteLine__c oQuoteLine1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.id , SBQQ__Product__c=oProd1.id);
        
        Product2 oProd2 = new Product2(Name = 'Peugeot 208', Family=Label.ProductFamilyColor, Stock__c = false);
        insert oProd2;
        
        SBQQ__QuoteLine__c oQuoteLine2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.id , SBQQ__Product__c=oProd2.id);

        Product2 oProd3 = new Product2(Name = 'Peugeot 208', Family=Label.ProductFamilyInterior, Stock__c = false);
        insert oProd3;
        
        SBQQ__QuoteLine__c oQuoteLine3 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.id , SBQQ__Product__c=oProd3.id);

		Product2 oProd4 = new Product2(Name = 'Peugeot 208', Family=Label.ProductFamilyOptions, Stock__c = false);
        insert oProd4;
        
        SBQQ__QuoteLine__c oQuoteLine4 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.id , SBQQ__Product__c=oProd4.id);
        
        Product2 oProd5 = new Product2(Name = 'Peugeot 208', Family=Label.ProductFamilyServices, Stock__c = false);
        insert oProd5;
        
        SBQQ__QuoteLine__c oQuoteLine5 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.id , SBQQ__Product__c=oProd5.id);
        
        Product2 oProd6 = new Product2(Name = 'Peugeot 208', Family=Label.ProductFamilyAccessories, Stock__c = false);
        insert oProd6;
        
        SBQQ__QuoteLine__c oQuoteLine6 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.id , SBQQ__Product__c=oProd6.id);
        
        
		
        database.insert(new List<SBQQ__QuoteLine__c>{oQuoteLine1,oQuoteLine2,oQuoteLine3,oQuoteLine4,oQuoteLine5,oQuoteLine6});
        
        // Perform test
        Test.startTest();
		PopulateQuoteInformation.mainProcess(new List<SBQQ__QuoteLine__c>{oQuoteLine1,oQuoteLine2,oQuoteLine3,oQuoteLine4});
        Test.stopTest();

    }

}
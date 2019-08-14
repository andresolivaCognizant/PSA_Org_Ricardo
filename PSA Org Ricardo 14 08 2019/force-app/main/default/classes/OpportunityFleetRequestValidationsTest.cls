/**
    *   @Class          : OpportunityFleetRequestValidationsTest
    *   @Author         : Pedro Párraga
    *   @Created        : 19/06/2019
    *   @Description    : Test for OpportunityFleetRequestValidations
    *
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description    
    *      Pedro Párraga            19/06/2019               Creation.
    *      Nerea Leguinazabal	    07/11/2019				 #C1STAGILE-16994: Use TestDataFactoryUtil for Data creation          
    *   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
private class OpportunityFleetRequestValidationsTest {

    static testMethod void myUnitTest() {      
       	List<Account> lstAccts = TestDataFactoryUtil.createAccount(1,'B2B');
        lstAccts[0].CompanyActivityType__c = '0';
        update lstAccts;

        Opportunity opp         	=   new Opportunity (
                Name                =   'Test',
                StageName           =   'New',
                AccountId           =   lstAccts[0].Id,
                CloseDate           =   System.today(),
                Activity__c         =   'VN',
                RecordTypeId        =   Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Label.RTOppFleetRequest).getRecordTypeId(),
            	Country__c			=	'PL'
        );
        insert opp;

        SBQQ__Quote__C quotes = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
                    'SBQQ__Opportunity2__c'  => opp.Id
                } ,true);
        
        Test.startTest();	
    		OpportunityFleetRequestValidations.blockEdition(new List<Opportunity> {opp}, new map<id,Opportunity>{opp.Id => opp});
            OpportunityFleetRequestValidations.validateClone(new List<Opportunity> {opp});
        Test.stopTest();        
    }
}
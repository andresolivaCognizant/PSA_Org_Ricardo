/**
	*   @Class : OpportunityTriggerHandlerTest
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   27 March 2018
	*   @Description    :   Test for OpportunityTriggerHandler Apex class
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Raul Barba				27/3/2018				 Creation.	
    *      Pedro Parraga            17 Jun 2019              Edit.	
	*   ----------------------------------------------------------------------------------------------------------------------------
**/

@isTest
public class OpportunityTriggerHandlerTest {
    
    @isTest static void opportunityTrigger() {
        // Test data setup
        List<Account> lstAccts = TestDataFactoryUtil.createAccount(2,'Dealer');
        
        Contact cnt             =   new Contact (
            FirstName           =   'First Name ',
            LastName            =   'LastName_',
            Salutation          =   '1',
            Email               =   'psaContactFirstName@contactexample.com',
            ProfessionalEmail__c=   'psaContactFirstName@contactexample.com',
            NationalId__c       =   '1C',
            AccountId           =   lstAccts[0].Id,
            AvailableLeadTreatment__c = true
            );
 
        insert cnt;
        
        List<Contact> lCnt = [SELECT Id FROM Contact WHERE LastName = 'LastName_' LIMIT 1];
        List<User> lstUser = TestDataFactoryUtil.createUser(lCnt,'Sales_Manager','Partner','Manager');
        insert lstUser;
        
        // Perform test
        Test.startTest();
    		List<Opportunity> lstOpps   =   TestDataFactoryUtil.createOpportunities(1, null ,lstAccts[0], 1000.0 ,'Proposal', 75); 
    		lstOpps[0].OwnerId = lstUser[0].id;
    		update lstOpps[0]; 
            OpportunityTriggerHandler.dontRunTrigger();
        Test.stopTest();

    }

}
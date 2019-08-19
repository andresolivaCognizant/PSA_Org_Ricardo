/**
	*   @Class : APB015_AccountMergeDeleteTest
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   30 08 2018
	*   @Description    :   Test for APB015_AccountMergeDelete batch
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Raul Barba				30/08/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/

@isTest
public class APB015_AccountMergeDeleteTest {
    
    @isTest static void AccountMergeDeleteTest() {
        // Test data setup
        List<CustomerMergeEntry__c> lstCme = new List<CustomerMergeEntry__c>();        
        for(Integer i=-1;i<2;i++) {
            CustomerMergeEntry__c cme             =   new CustomerMergeEntry__c (
                Status__c           =   '2',
                RequestDate__c      =   Date.today().addyears(i)
            );
            lstCme.add(cme);
        }
        insert lstCme;
        
        
        System.assertEquals(3, [select Id from CustomerMergeEntry__c].size());
        
        // Perform test
        Test.startTest();
        	APB015_AccountMergeDelete b = new APB015_AccountMergeDelete();
            Database.executeBatch(b,60); 
        Test.stopTest();
        
        System.assertEquals(2, [select Id from CustomerMergeEntry__c].size());

    }

}
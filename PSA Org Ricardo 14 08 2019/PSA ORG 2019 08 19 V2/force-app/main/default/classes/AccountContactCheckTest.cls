/**
	*   @Class : AccountContactCheckTest
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   21 March 2018
	*   @Description    :   Test for AccountContactCheck Apex class
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Raul Barba				21/3/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/

@isTest
public class AccountContactCheckTest {
    
    @isTest static void relationTest(){
        // Test data setup
       	List<Account> lstAccts = TestDataFactoryUtil.createAccount(2,'Dealer');
        List<Contact> lstConts  =  TestDataFactoryUtil.createPartnerUser(1,1, 'Dealer', '133225511','1237770', 'EXTKEY0002','AP','CL', 'J',new List<String>(), true);
        
        AccountContactRelation acr = AccountContactCheck.getRelation(lstAccts[0].id, lstConts[0].id); 
        
        List<Lead> lstLeads         =   TestDataFactoryUtil.createLead(3, 'B2B', 'EXTKEY0001',null, 'AP','ES','VN', '22334455');
        lstLeads[0].CustomerContact__c = lstConts[0].id;
        lstLeads[0].Customer__c = lstAccts[0].id; 
        lstLeads[1].CustomerContact__c = lstConts[0].id;
        lstLeads[1].Customer__c = lstAccts[1].id;
        // Perform test
        Test.startTest(); 
        System.assertEquals(1, [select id from AccountContactRelation].size());
        insert acr;
        System.assertEquals(2, [select id from AccountContactRelation].size());
        AccountContactCheck.generateRelations(lstLeads);
        System.assertEquals(3, [select id from AccountContactRelation].size());
        Test.stopTest();
        
    }

}
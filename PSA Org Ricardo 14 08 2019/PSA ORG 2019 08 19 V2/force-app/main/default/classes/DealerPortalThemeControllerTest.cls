/**
	*   @Class : DealerPortalThemeControllerTest
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   11 April 2018
	*   @Description    :   Test for DealerPortalThemeController
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Raul Barba				11/04/2018				 Creation. --> DealerPortalThemeControllerTest
	* 	   Ruben Fernandez			07/05/2019				Added next test methods:
	*														- setup
	*														- DMSWakeUpbyCORSKOTest
	*														- DMSWakeUpbyCORSOKTest
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
public class DealerPortalThemeControllerTest {
    @testSetup 
	static void setup() {
		List<String> lstActivities              = new List<String>{'VN'};
        List<Contact> lstContsA                 = TestDataFactoryUtil.createPartnerUser(3, 1, 'Dealer', '133225511','1237770', 'EXTKEY0002','AP','PL', 'J',lstActivities,true);
        
        List<Contact> lstSales                  = new List<Contact>();
        List<Contact> lstASales                 = new List<Contact>();
        lstSales.add(lstContsA.get(0));
        lstSales.add(lstContsA.get(2));
        lstASales.add(lstContsA.get(1));
        List<User> lstUsers1                    =   TestDataFactoryUtil.createUser(lstSales,'Sales_Manager','Partner','Manager');
        lstUsers1.addAll(TestDataFactoryUtil.createUser(lstASales,'Aftersales_Manager','Partner','Manager'));
        Insert lstUsers1;
	}
    
    @isTest 
    static void DealerPortalThemeControllerTest(){
        User usr1;
        Test.startTest();
        	usr1 = DealerPortalThemeController.getUserDetails();
        Test.stopTest();
    }
    
    /**
    * This test method is used to test positive DMS call
    * Conditions: Run as Sales User
    */
	static testmethod void DMSWakeUpbyCORSOKTest(){

		User usr                            	= [SELECT Id, Contact.AccountId,Contact.Account.CommunicationMode__c FROM User WHERE Contact.Account.CommunicationMode__c = '1' AND Profile.Name = 'Sales_Manager' LIMIT 1];        
		Map<String,String> mapResults;
        System.runAs(usr) {   
            Test.startTest();
            	List <Account> lstAcc       	= TestDataFactoryUtil.createPersonAccount(1);
				mapResults 						= DealerPortalThemeController.DMSWakeUpbyCORS();
			Test.stopTest();
        }
        List<DMSWebhook__c> lstPushT        	= [SELECT Id FROM DMSWebhook__c];
        System.assertEquals(true, mapResults.containsKey('body') );
        System.assertEquals(0,lstPushT.size());
	}
	
    /**
    * This test method is used to test DMS is NOT called
    * Conditions: Run as System Administrator
    */	
	static testmethod void DMSWakeUpbyCORSNOTOKTest(){
		Map<String,String> mapResults;
		Test.startTest();
			List <Account> lstAcc       	= TestDataFactoryUtil.createPersonAccount(1);
			mapResults 						= DealerPortalThemeController.DMSWakeUpbyCORS();
		Test.stopTest();
        System.assertEquals(false, mapResults.containsKey('body') );
	}

}
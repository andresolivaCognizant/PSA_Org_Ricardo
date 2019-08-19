/**
    *   @Class          : SetAsPrincipalManagerProfileCheckTest
    *   @Author         : Pedro Párraga
    *   @Created        : 11/06/2019
    *   @Description    : Test for SetAsPrincipalManagerProfileCheck
    *
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description    
    *      Pedro Párraga            11/06/2019               Creation.      
    *   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
private class SetAsPrincipalManagerProfileCheckTest {

    @isTest static void DealerUserRoleAssignmentTest() {
        // Test data setup
        List<Account> lstAccts = TestDataFactoryUtil.createDealers(1, 'Dealer', '133225511', '1237770', 'EXTKEY0002', 'AP', 'CL', 'J',new List<String>(), true);
        lstAccts.addAll(TestDataFactoryUtil.createAccountContact(3,'Dealer'));
        
        List<Contact> lstCnts = new List<Contact>();        
        
        for(Integer j=0;j<1;j++) {
            for(Integer i=0;i<3;i++) {
                Contact cnt             =   new Contact (
                    FirstName           =   'First Name ' +'133225511'.right(3),
                    LastName            =   'LastName_',
                    Salutation          =   '1',
                    Email               =   'psaContactFirstName' + '133225511'.right(5) +  '@contactexample.com',
                    NationalId__c       =   '133225511'.right(8) + 'C',
                    Phone               =   '133225511'.right(9),
                    AccountId           =   lstAccts.get(j).Id,
                    SetAsPrincipalManager__c = true
                    );
                lstCnts.add(cnt);
            }
        }
        
        Insert lstCnts;
        
        List<Contact> lstConts1 = new List<Contact>();
        List<Contact> lstConts2 = new List<Contact>();
        List<Contact> lstConts3 = new List<Contact>();
        
        lstConts1.add(lstCnts.get(0));
        lstConts2.add(lstCnts.get(1));
        lstConts3.add(lstCnts.get(2));
        
        List<User> lstUsers1 	=   TestDataFactoryUtil.createUser(lstConts1,'Sales_Manager','Partner','Manager');
        lstUsers1.addAll(TestDataFactoryUtil.createUser(lstConts2,'Aftersales_Manager','Partner','Manager'));
        lstUsers1.addAll(TestDataFactoryUtil.createUser(lstConts3,'Sales_Manager_Agent','Partner','Manager'));
        
        Insert lstUsers1;
        
        // Perform test
        Test.startTest();
            List<SetAsPrincipalManagerProfileCheck.flowInputs> lWrActivity 	= new List<SetAsPrincipalManagerProfileCheck.flowInputs>();
        	SetAsPrincipalManagerProfileCheck.flowInputs 		wrp 		= new SetAsPrincipalManagerProfileCheck.flowInputs();
	        wrp.recordId 													= lstConts1[0].Id;
        	lWrActivity.add(wrp);		
        	SetAsPrincipalManagerProfileCheck.checkProfile(lWrActivity); 
        Test.stopTest();
    }
}
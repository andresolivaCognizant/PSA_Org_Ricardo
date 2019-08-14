/**
	*   @Class : APB001_DealerUserRoleAssignmentTest
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   07 Feb 2018
	*   @Description    :   Test for APB001_DealerUserRoleAssignment, APB002_DealerUserRoleAssignmentLink and APB005_DealerUserRoleAssignmentNumber batches
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Raul Barba				07/2/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/

@isTest
public class APB001_DealerUserRoleAssignmentTest {
    
    @isTest static void DealerUserRoleAssignmentTest() {
        // Test data setup
        List<Account> lstAccts = TestDataFactoryUtil.createDealers(1, 'Dealer', '133225511', '1237770', 'EXTKEY0002', 'AP', 'CL', 'J',new List<String>(), true);
        lstAccts.addAll(TestDataFactoryUtil.createAccountContact(7,'Dealer'));
        List<Contact> lstCnts = new List<Contact>();     
        boolean ppal = true;   
        for(Integer j=0;j<7;j++) {
            //for(Integer i=0;i<7;i++) {
        	    /*if (j==3){
                	ppal = false;
                }*/
                if(math.mod(j, 2) == 0){
                    ppal = true;
                }else{
                    ppal = false;
                }
                Contact cnt             =   new Contact (
                    FirstName           =   'First Name ' +'133225511'.right(3),
                    LastName            =   'LastName_',
                    Email               =   'psaContactFirstName' + '133225511'.right(5) +  '@contactexample.com',
                    NationalId__c       =   '133225511'.right(8) + 'C',
                    Phone               =   '133225511'.right(9),
                    AccountId           =   lstAccts.get(j).Id,
                    SetAsPrincipalManager__c = ppal
                    );
                lstCnts.add(cnt);
            //}
        }
        insert lstCnts;
        List<Contact> lstConts1 = new List<Contact>();
        List<Contact> lstConts2 = new List<Contact>();
        List<Contact> lstConts3 = new List<Contact>();
        List<Contact> lstConts4 = new List<Contact>();
        List<Contact> lstConts5 = new List<Contact>();
        List<Contact> lstConts6 = new List<Contact>();
        List<Contact> lstConts7 = new List<Contact>();
        lstConts1.add(lstCnts.get(0));
        lstConts2.add(lstCnts.get(1));
        lstConts3.add(lstCnts.get(2));
        lstConts4.add(lstCnts.get(3));
        lstConts5.add(lstCnts.get(4));
        lstConts6.add(lstCnts.get(5));
        lstConts7.add(lstCnts.get(6));
        List<User> lstUsers1 =   TestDataFactoryUtil.createUser(lstConts1,'Sales_Manager','Partner','Manager');
        List<User> lstUsers2 =   TestDataFactoryUtil.createUser(lstConts2,'Aftersales_Manager','Partner','Manager');
        List<User> lstUsers3 =   TestDataFactoryUtil.createUser(lstConts3,'Sales_Manager_Agent','Partner','Manager');
        List<User> lstUsers4 =   TestDataFactoryUtil.createUser(lstConts4,'Sales_Manager','Partner','Manager');
        List<User> lstUsers5 =   TestDataFactoryUtil.createUser(lstConts5,'Aftersales_Manager','Partner','Manager');
        List<User> lstUsers6 =   TestDataFactoryUtil.createUser(lstConts6,'Sales_Manager','Partner','Manager');
        List<User> lstUsers7 =   TestDataFactoryUtil.createUser(lstConts7,'Sales_Manager_Agent','Partner','Manager');
        
        Insert lstUsers1;
        Insert lstUsers2;
        Insert lstUsers3;
        Insert lstUsers4;
        Insert lstUsers5;
        Insert lstUsers6;
        Insert lstUsers7;
        
        lstAccts.get(0).IsPartner = true;
        lstAccts.get(0).VNFlag__c = true;
        lstAccts.get(0).VNPrincipalSite__c = true;
        lstAccts.get(0).VNContractNumber__c = '12345';        
        lstAccts.get(1).IsPartner = true;
        lstAccts.get(1).VNFlag__c = true;
        lstAccts.get(1).PRFlag__c = true;
        lstAccts.get(1).RAFlag__c = true; 
        lstAccts.get(1).AgentFlag__c = true;
        lstAccts.get(2).IsPartner = true;
        lstAccts.get(2).VNFlag__c = true;
        lstAccts.get(3).IsPartner = true;
        lstAccts.get(3).VNFlag__c = true;
        lstAccts.get(3).VNContractNumber__c = '12345';
        lstAccts.get(3).VNPrincipalSite__c = false;
        lstAccts.get(4).IsPartner = true;
        lstAccts.get(4).VNFlag__c = true;
        lstAccts.get(4).VNPrincipalSite__c = false;
        lstAccts.get(4).VNContractNumber__c = '12345';
        lstAccts.get(5).IsPartner = true;
        lstAccts.get(5).VNFlag__c = true;
        lstAccts.get(5).VNPrincipalSite__c = true;
        lstAccts.get(5).VNContractNumber__c = '12345';
        lstAccts.get(5).TECH_SalesManager__c = lstUsers1.get(0).Id;
        update lstAccts;
        PartnerAccountLink__c part = new PartnerAccountLink__c(
                ProviderId__c = lstAccts.get(5).Id, 
                SubscriberId__c = lstAccts.get(1).Id,
                EndDate__c = System.today().addDays(30));
		insert part;
        
        System.assertEquals(7, [select Id from Account where TECH_SalesManager__c = null and TECH_AfterSalesManager__c = null and TECH_SalesManagerAgent__c = null ].size());
        
        // Perform test
        Test.startTest();
        	APB001_DealerUserRoleAssignment b = new APB001_DealerUserRoleAssignment();
            Database.executeBatch(b,60); 
        Test.stopTest();
        
        //System.assertEquals(1, [select Id from Account where TECH_SalesManager__c = null and TECH_AfterSalesManager__c = null and TECH_SalesManagerAgent__c = null ].size());

    } 

}
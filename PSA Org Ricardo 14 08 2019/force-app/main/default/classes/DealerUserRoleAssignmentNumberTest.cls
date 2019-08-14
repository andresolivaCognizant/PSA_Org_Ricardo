/**
    *   @Class          : DealerUserRoleAssignmentNumberTest
    *   @Author         : Pedro Párraga
    *   @Created        : 19/06/2019
    *   @Description    : Test for APB005_DealerUserRoleAssignmentNumber
    *
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description    
    *      Pedro Párraga            19/06/2019               Creation.      
    *   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
private class DealerUserRoleAssignmentNumberTest {
	
	@isTest static void APB005_DealerUserRoleAssignmentNumber(){
        List<Account> lstAccts = TestDataFactoryUtil.createDealers(1, 'Dealer', '133225511', '1237770', 'EXTKEY0002', 'AP', 'CL', 'J',new List<String>(), true);
        lstAccts.addAll(TestDataFactoryUtil.createAccountContact(7,'Dealer'));     
       
       Contact cnt             =   new Contact (
            FirstName           =   'First Name ',
            LastName            =   'LastName_',
            Email               =   '133225511@contactexample.com',
            NationalId__c       =   '133225511C',
            Phone               =   '133225511',
            AccountId           =   lstAccts.get(0).Id
        );

        insert cnt;

        List<Contact> lstConts1 = new List<Contact>();

        lstConts1.add(cnt);

        List<User> lstUsers1 =   TestDataFactoryUtil.createUser(lstConts1,'Sales_Manager','Partner','Manager');

        
        Insert lstUsers1;
        
        lstAccts.get(0).IsPartner = true;
        lstAccts.get(0).VNFlag__c = true;
        lstAccts.get(0).VNPrincipalSite__c = false;
        lstAccts.get(0).VNContractNumber__c = '12345';
        lstAccts.get(0).TECH_SalesManager__c = null;
        update lstAccts;

        List<String> lstStringAcc = new List<String>();
        Map<String, Id> vNAfter = new Map<String, Id>();
        Map<String, Id> vNSales = new Map<String, Id>();

        for(Account acc : lstAccts){
        	lstStringAcc.add(acc.Id);
        	vNAfter.put(acc.VNContractNumber__c, acc.OwnerId);
        	vNSales.put(acc.VNContractNumber__c, acc.OwnerId);
        }

        Map<String, List<String>> up = new Map<String, List<String>>();
        up.put('Sales_Manager', lstStringAcc);
        up.put('Aftersales_Manager', lstStringAcc);

        Test.startTest();
        	APB005_DealerUserRoleAssignmentNumber b = new APB005_DealerUserRoleAssignmentNumber(up, vNAfter, vNSales);
            Database.executeBatch(b); 
        Test.stopTest();

        System.assertEquals(null, lstAccts[0].TECH_SalesManager__c);
        System.assertEquals(null, lstAccts[0].TECH_SalesManager__c);
	}
}
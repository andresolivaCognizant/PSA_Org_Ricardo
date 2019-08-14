/**
    *   @Class : LeadCardHeaderControllerTest
    *
    *   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
    *   @Created        :   11 April 2018
    *   @Description    :   Test for LeadCardHeaderController
    
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description    
    *      Raul Barba               11/04/2018               Creation.      
    *   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
public class LeadCardHeaderControllerTest {
    
    @isTest static void LeadCardHeaderControllerTest(){
        // Test data setup
        List<Lead> lstLeads         =   TestDataFactoryUtil.createLead(1, 'B2B', 'EXTKEY0001',null, 'AP','ES','VN', '22334455');
        insert lstLeads;
        // Perform test
        Test.startTest();
            Integer cont = LeadCardHeaderController.getLeadActivityCount(lstLeads[0].id);
            Lead lead1 = LeadCardHeaderController.getLeadRecord(lstLeads[0].id);
        Test.stopTest();
        
        System.assertEquals(0, cont);
        System.assertEquals('5', lead1.LeadRequestType__c);
    }

}
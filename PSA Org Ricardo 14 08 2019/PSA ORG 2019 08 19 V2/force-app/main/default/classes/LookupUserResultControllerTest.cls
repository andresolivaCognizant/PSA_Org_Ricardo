/**
    *   @Class          : LookupUserResultControllerTest
    *   @Author         : Pedro Párraga
    *   @Created        : 19/06/2019
    *   @Description    : Test for LookupUserResultController
    *
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description    
    *      Pedro Párraga            19/06/2019               Creation.      
    *   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
public with sharing class LookupUserResultControllerTest {
       
    @isTest
    public static void getUserLeadCountsTest() {
        
        Test.startTest();  
            List<Lead> lstLeads = TestDataFactoryUtil.createLead(1, 'B2B', 'EXTKEY0007',null, 'AP','ES','VN', '22334466');
            insert lstLeads;
            Id leadId = lstLeads[0].Id;
            List<LookupUserResultController.leadCounts> aux  = LookupUserResultController.getUserLeadCounts(leadId);
            System.assertEquals(0, aux[0].countOnTime);
            System.assertEquals(0, aux[0].countOverdue);
            System.assertEquals(0, aux[0].countUrgent);
        Test.stopTest();
        
    }
}
/*********************************************************************************************************
* Project:          C1ST: CORE - DMS
* Description:      Test class FOR PB001_DoNothingInvocable apex class.
*
* COVERAGE:         PB001_DoNothingInvocable --> 100%
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description
*           -----   ----------      --------------------    ---------------
* @version  1.0     2019-06-11      Ruben Fernandez (RF)    Initial definition
*********************************************************************************************************/
@isTest 
public with sharing class PB001_DoNothingInvocableTest {
    @isTest public static void doNothingInvocableTest() {

        Test.startTest();
            List<Lead> lstLeads         =   TestDataFactoryUtil.createLead(1, 'B2B', 'EXTKEY0007',null, 'AP','ES','VN', '22334455');
            List<PB001_DoNothingInvocable.UpdateRequest> lWrActivity 	= new List<PB001_DoNothingInvocable.UpdateRequest>();
            PB001_DoNothingInvocable.UpdateRequest  wrp = new PB001_DoNothingInvocable.UpdateRequest();
            Insert lstLeads;
            wrp.sfRecordId = lstLeads.get(0).Id;
            lWrActivity.add(wrp);
            PB001_DoNothingInvocable.requestMessage(lWrActivity);
        Test.stopTest();
        List<Lead> auxResults = new List<Lead>([SELECT Id, LeadCountry__c FROM Lead WHERE Id =: wrp.sfRecordId]);
        System.assertEquals('ES', auxResults.get(0).LeadCountry__c);
    }
}
@isTest
private class LeadTriggerHandlerTest {
	
    static testMethod void myUnitTest() {
        
        
        List<Lead> lNewLeads = TestDataFactoryUtil.createLead(3, 'B2B', 'accB2B', '', 'DS', 'DO', '', '123');
        insert lNewLeads;
        
        lNewLeads[0].nationalid__c = '124124452-5';
        update lNewLeads[0];
        
        map<Id,Lead> mapOldLeads = new map<Id,Lead>();
        
        for(Lead l : lNewLeads){
            mapOldLeads.put(l.id,l);
        }
        
        test.startTest();
        LeadTriggerHandler.afterInsert(lNewLeads);
        LeadTriggerHandler.beforeInsert(lNewLeads);
        LeadTriggerHandler.beforeUpdate(lNewLeads, mapOldLeads);
        LeadTriggerHandler.shouldRunTrigger();
        LeadTriggerHandler.dontRunTrigger();
        test.stopTest();
        
    }
	
}
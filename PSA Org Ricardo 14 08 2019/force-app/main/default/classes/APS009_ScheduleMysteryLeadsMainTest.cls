/**
    *   @Class          : APS009_ScheduleMysteryLeadsMainTest
    *   @Author         : Ruben Moreno Leyva
    *   @Created        : 22/5/2018
    *   @Description    : Test for APS009_ScheduleMysteryLeadsMain
    *
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description    
    *      Ruben Moreno Leyva       22/5/2018                Creation.      
    *   ----------------------------------------------------------------------------------------------------------------------------
**/

@isTest
public class APS009_ScheduleMysteryLeadsMainTest {
    
    @isTest static void testProcess(){
        Lead oLead1  = new Lead(
                FirstName                   = 'Test 001', 
                LastName                    = 'Version1',
                Phone                       = '956789876',
                PSABrand__c                 = 'AP',
                Email                       = 'psaLead@leadexample.com',
                LeadCountry__c              = 'AZ',
                NationalId__c               = '0909843X',
                DestinationGeographicalCode__c='0000045000',
                TECH_TemplateLead__c        = TRUE
        );
        
        Lead oLead2  = new Lead(
                FirstName                   = 'Test 002', 
                LastName                    = 'Version2',
                Phone                       = '956789826',
                PSABrand__c                 = 'AP',
                Email                       = 'psaLead2@leadexample.com',
                LeadCountry__c              = 'AZ',
                NationalId__c               = '09098432X',
                DestinationGeographicalCode__c='0000045000',
                TECH_TemplateLead__c        = TRUE
        );
        
        insert new list<Lead> {olead1,olead2};
        
        List<String> lstActivities  =   new List<String>(); 
        lstActivities.add('VN');
        List<Contact> lstConts      =   TestDataFactoryUtil.createPartnerUser(1, 1, 'Dealer', '133225511','1237770', '0000045000','AP','CL', 'J',lstActivities,true);
        List<Account> lstAccts      =   new List<Account>([Select Id,Name From Account Where Id =:lstConts.get(0).AccountId]);
        List<User> lstUsers         =   TestDataFactoryUtil.createUser(lstConts,'Salesman','Partner','Manager');        
        insert lstUsers;
        
        Test.startTest();
        APS009_ScheduleMysteryLeadsMain batch = new APS009_ScheduleMysteryLeadsMain('Phone','AZ',1); 
        APS009_ScheduleMysteryLeadsMain batch1 = new APS009_ScheduleMysteryLeadsMain('Email','AZ',1);
        String sSch = '0 0 * * * ? 2100';
        System.schedule('Executing: APS009_ScheduleMysteryLeadsMain - date: '+system.now(), sSch, batch);
        System.schedule('Executing: APS009_ScheduleMysteryLeadsMain - date: '+system.now()+2, sSch, batch1);    
        Test.stopTest();
        
    } 

}
/**
        *   @Class                      : BusinessHoursHandlerTest
        *   @Author         : Pedro Párraga
        *   @Created        : 22 january 2019
        *   @Description    : Test for BusinessHoursHandler
        *
        *   ----------------------------------------------------------------------------------------------------------------------------
        *      Modification Log :
        *   ----------------------------------------------------------------------------------------------------------------------------
        *      Developer                        Date                     Description    
        *          Pedro Párraga                        22/01/2019                               Creation.              
        *   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
private class NewLeadOverrideControllerTest {

        @testSetup static void setup(){
                Account acc = new Account(
                        FirstName = 'FirstName', 
                        LastName = 'LastName', 
                        Phone = '647362736', 
                        PersonMobilePhone  = '647362736', 
                    	Email__c = 'email@email.es',
                    	RecordTypeId = PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA),
                        NonResidentCustomer__pc = true
                );
                
                Insert acc;

                List<case> lstCases = new List<Case>();

                Case caso = new Case(
                        Status = '1', 
                        Origin = '1', Reason = '2', 
                        AccountId = acc.Id, 
                        SuppliedName = 'Name'
                );

                lstCases.add(caso);  

                Case caso2 = new Case(
                        Status = '1', 
                        Origin = '2', 
                        Reason = '2', 
                        AccountId = acc.Id, 
                        SuppliedName = 'Name'
                );

                lstCases.add(caso2); 

                Case caso3 = new Case(
                    Origin = '3',
                    SuppliedName = 'Juan Perez',
                    SuppliedPhone = '+351640234781',
                    SuppliedEmail = 'test@email.es',
                    Description = 'testCase',
                    CaseSurveyAcceptance__c = 'Yes',
                    Country__c = 'PT',
                    Brand__c = 'AP',
                    Language__c = 'PT',                    
                    Reason = '2'
                );

                lstCases.add(caso3); 

                Case caso4 = new Case(
                        Status = '1', 
                        Origin = '4', 
                        Reason = '2', 
                        AccountId = acc.Id, 
                        SuppliedName = 'Name'
                );

                lstCases.add(caso4); 
 
                Case caso5 = new Case(
                        Status = '1', 
                        Origin = '5',
                         Reason = '2', 
                         AccountId = acc.Id, 
                         SuppliedName = 'Name'
                );

                lstCases.add(caso5); 

                Case caso6 = new Case(
                        Status = '1', 
                        Origin = '6', 
                        Reason = '2', 
                        AccountId = acc.Id, 
                        SuppliedName = 'Name'
                );

                lstCases.add(caso6); 

                insert lstCases;                  
        }
	
	@isTest static void NewLeadOverrideMainTest() {
                List<Case> lst_case     = [SELECT Id FROM Case];

                Test.startTest();          
                        List<Lead> only = NewLeadOverrideController.isOnlyLead(lst_case[0].Id);

                        for(Case cas : lst_case){
                            Lead lea = NewLeadOverrideController.createLead(cas.Id, 'VN', '1', 'ProductCustomerInterest', 'ProductOwned');    
                        }
                        
                        only = NewLeadOverrideController.isOnlyLead(lst_case[0].Id);
                        Boolean isPerson = NewLeadOverrideController.isCorrectAccount(lst_case[0].Id);
                        List<Lead> aux = NewLeadOverrideController.getIdLead(lst_case[0].Id);
                Test.stopTest();
	}

        /* Method to test validation rules. It should generate an error */
        @isTest static void NewLeadErrorTest() {
                List<Case> lst_case    = [SELECT Id FROM Case];
        
                Test.startTest();
                       
                        List<Lead> only = NewLeadOverrideController.isOnlyLead(lst_case[0].Id);
                        try{
                                Lead lea = NewLeadOverrideController.createLead(lst_case[0].Id, 'VN', '1', 'ProductCustomerInterest', 'ProductOwned');
                        }catch(Exception e){
                                System.assertEquals('System.AuraHandledException', e.getTypeName());
                        }
                Test.stopTest();
	}
        
}
/**
    *   @Class : PT00_NIFValidationTest
    *
    *   @Author         :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    *   @Created        :   8 Mar 2019
    *   @Description    :   Test Class of PT00_NIFValidation         
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description    
    *      Carmen Hernandez         3/08/2019                Creation.      
    *   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest(SeeAllData=false)
public class PT00_NIFValidationTest {
     
    private static final String CODE_PORTUGAL = 'PT';
    private static final String CODE_PEUGEOUT = 'AP';
    private static final String CODE_NIF = 'NIF';
    private static final String VALID_NIF = '123456789';
    private static final String VALID_NIF2 = '510057926';
    private static final String INVALID_NIF = '774433200';  
    private static final String INVALID_NIF2 = 'PQK';
    private static final String TYPE_B2B = 'B2B';
    private static final String TYPE_B2C = 'B2C';    
    private static final String ACTIVITY_VN = 'VN';
    private static final String KEYWORD_LEAD = '02334351';
    private static final String KEYWORD_LEAD2 = '02334350';    
    private static final String ROLE_PSA = 'PSA';
    private static final String USER_LDAPID = '9876543';
    private static final String PROFILE_SYSADMIN = 'System Administrator';
    
    @testSetup static void setupCommonData(){
        
        User userFromPortugal = TestDataFactoryUtil.createOneUser(PROFILE_SYSADMIN, ROLE_PSA, CODE_PEUGEOUT, CODE_PORTUGAL, USER_LDAPID);
        insert userFromPortugal;
        
        System.runAs(userFromPortugal){
            //Create Lead B2C (Lead Country = Portugal)
            List<Lead> leadList = TestDataFactoryUtil.createLead(1, TYPE_B2C, null, null, CODE_PEUGEOUT, CODE_PORTUGAL, ACTIVITY_VN, KEYWORD_LEAD);
            insert leadList;
            //Create Account and Contact B2B (Country = Portugal)
            TestDataFactoryUtil.createAccountContact(1, TYPE_B2B);
            //Create Person Account
            Account personAccount = new Account(FirstName = 'TEST 2', Salutation = '1', LastName = 'TEST MATCH B2C 2', LandlinePersonalTelephone__pc = '+63323434', 
               BillingCountry = CODE_PORTUGAL, RecordTypeId = PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA));
            insert personAccount;
        }
    }

    /*  Name        : testValidCasesUpdateEvent
        Description : This method is to verify that no errors appear when updating {Leads/Accounts/Contacs} with a valid NIF
        @PARAM      : void
        @OUTPUT     : void
    */
    @isTest static void testValidCasesUpdateEvent(){
        
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Account account = [SELECT Id FROM Account  WHERE RecordTypeId =:PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA) LIMIT 1];
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        User user = [SELECT Id FROM User LIMIT 1];
        Boolean isOKLeadB2C, isOKContactB2B, isOKPersonAccount = false;
         
        System.runAs(user){
            //Update a Lead with a Valid NIF & check that there aren't errors
            lead.NationalId__c = VALID_NIF;
            lead.LeadCountry__c = CODE_PORTUGAL;
            update lead;
            isOKLeadB2C = Database.update(lead, false).isSuccess();
            
            //Update a contact with a Valid NIF & check that there aren't errors
        	contact.TECH_ContactCountry__c = CODE_PORTUGAL;              
            //Update National Id 1
        	contact.NationalId__c = VALID_NIF;
            contact.NationalIdType__c = CODE_NIF; 
        	//Update National Id 2
        	contact.NationalId2Type__c = CODE_NIF; 
        	contact.NationalId2__c = VALID_NIF2;      
        	update contact;
            isOKContactB2B = Database.update(contact, false).isSuccess();                     
 			
            //Update an account with a Valid NIF & check that there aren't errors
            account.Country__c = CODE_PORTUGAL;    
            //Update National Id 1        
            account.NationalId__pc = VALID_NIF;
            account.NationalIdType__pc = CODE_NIF; 
            //Update National Id 2        
            account.NationalId2__pc = VALID_NIF;
            account.NationalId2Type__pc = CODE_NIF;         
            isOKPersonAccount = Database.update(account, false).isSuccess();      
        } //End Run As User
        
        //Check that there aren't errors in the updates
        System.assert(isOKLeadB2C); 
        System.assert(isOKContactB2B); 
        System.assert(isOKPersonAccount); 
    }

    /*  Name        : testInvalidCasesUpdateEvent
        Description : This method is to verify that errors appear when updating {Leads/Accounts/Contacs} with a invalid NIF
        @PARAM      : void
        @OUTPUT     : void
    */
    @isTest static void testInvalidCasesUpdateEvent(){
        
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Account account = [SELECT Id FROM Account  WHERE RecordTypeId =:PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA) LIMIT 1];
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        User user = [SELECT Id FROM User LIMIT 1];
        
        //System.runAs(user){
            //Update a Lead with a Valid NIF & check that there are errors
            lead.NationalId__c = INVALID_NIF;
            lead.LeadCountry__c = CODE_PORTUGAL;
            List<Database.Error> errorsList = Database.update(lead, false).getErrors();                     
            
            //Update a contact with a Valid NIF & check that there are errors
        	contact.TECH_ContactCountry__c = CODE_PORTUGAL;              
            //Update National Id 1
        	contact.NationalId__c = INVALID_NIF;
            contact.NationalIdType__c = CODE_NIF;   
        	//Update National Id 2
        	contact.NationalId2__c = INVALID_NIF2;  
        	contact.NationalId2Type__c = CODE_NIF;         
        	errorsList.addAll(Database.update(contact, false).getErrors());
 			
            //Update an account with a Valid NIF & check that there are errors 
            account.Country__c = CODE_PORTUGAL;    
            //Update National Id 1        
            account.NationalId__pc = INVALID_NIF2;
            account.NationalIdType__pc = CODE_NIF; 
            //Update National Id 2        
            account.NationalId2__pc = INVALID_NIF;
            account.NationalId2Type__pc = CODE_NIF;     
        	errorsList.addAll(Database.update(account, false).getErrors());
        //} //End Run As User 
        
        //Check that there are errors in the updates 
        System.assert(errorsList!= null && errorsList.size()>0);   
        //Check that appears the error message : Label.NIFValidation
        for(Database.Error error :  errorsList){
            System.assert(error.getMessage().contains(Label.NIFValidation));
        }     
    }

    /*  Name        : testValidCasesUpdateEvent
        Description : This method is to verify that no errors appear when inserting {Leads/Accounts/Contacs} with a valid NIF
        @PARAM      : void
        @OUTPUT     : void
    */    
    @isTest static void testValidCasesInsertEvent(){
        
        User user = [SELECT Id FROM User LIMIT 1];
        Boolean isOKLeadB2C, isOKContactB2B, isOKPersonAccount = false;
         
        //System.runAs(user){

            //Insert a Lead with a Valid NIF & check that there aren't errors
        	List<Lead> leadList = TestDataFactoryUtil.createLead(1, TYPE_B2C, null, null, CODE_PEUGEOUT, CODE_PORTUGAL, ACTIVITY_VN, KEYWORD_LEAD);
            leadList.get(0).NationalId__c = INVALID_NIF;
            leadList.get(0).LeadCountry__c = CODE_PORTUGAL;
            //isOKLeadB2C = Database.insert(leadList.get(0), false).isSuccess();
        
        
        //}        
        
        
        
        
        
        
    }
    
    /*  Name        : testInvalidCasesUpdateEvent
        Description : This method is to verify that errors appear when inserting {Leads/Accounts/Contacs} with a invalid NIF
        @PARAM      : void
        @OUTPUT     : void
    */
    @isTest static void testInvalidCasesInsertEvent(){
        
    }
    

}
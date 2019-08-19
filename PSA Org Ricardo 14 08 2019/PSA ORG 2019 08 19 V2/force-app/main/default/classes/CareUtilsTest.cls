/*-----------------------------------------------------------------------------------------------------------//
  * Class Name    : CareUtils
  * Project       : PSA - C1ST - Care
  * Author        : Carmen Hernandez  <carmen.diazhernandez@ext.mpsa.com>
  * Date          : 07/04/2019
  * Description   : Test Class of CareUtils
  *
  *-----------------------------------------------------------------------------------------------------------
  *      Modification Log :
  *-----------------------------------------------------------------------------------------------------------
  *      Developer                Date                     Description              Coverage
  *      Carmen Hernandez         07/04/2019               Creation.                98%
  *-----------------------------------------------------------------------------------------------------------*/
@isTest
public class CareUtilsTest {
    
    /*********************************************************************************************************
    * @Method          :   setupCommonData
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/04/2019
    * @Description     :   This method is used to create test records once and then access them in every test 
    *                  :   method in the test class
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/      
    @testSetup static void setupCommonData(){
        
        //Create Person Account
        Account personAccount = TestDataFactoryUtil.createAccount(new map<String, Object>{
            'FirstName'=>'Juan', 'LastName'=>'Perez', 'Phone'=>'+351640234781', 'Brand__c'=>'AP',
            'Country__c'=>'PT', 'BillingPostalCode'=>'23456',
            'RecordTypeId'=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA)}, false);   
        //Create B2B Account
        Account b2bAccount = TestDataFactoryUtil.createAccount(new map<String, Object>{
            'Name'=>'Company', 'Phone'=>'+351640234781', 'Brand__c'=>'AP',
            'Country__c'=>'PT', 'BillingPostalCode'=>'23456',
            'RecordTypeId'=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2B)}, false);          
        //Insert Accounts
        List<Account> lstTestAccounts = new List<Account>{personAccount, b2bAccount}; 
        insert lstTestAccounts;        
        
        //Create B2C Case
        Case caseTypeB2C = (Case)TestDataFactoryUtil.createSobject('Case', new map<String, Object>{
            'Country__c'=>'PT', 'Brand__c'=>'AP', 'SuppliedName'=>'Raul Garcia Perez', 'SuppliedEmail'=>'testB2C@email.es', 
            'SuppliedPhone'=>'+351801213122','SuppliedNationalID__c'=>'123456789', 'AccountId'=> personAccount.Id, 
            'SuppliedCity__c'=>'Lisboa', 'SuppliedZipCode__c'=>'123'}, false);    
        //Create B2B Case                                                      
        Case caseTypeB2B = (Case)TestDataFactoryUtil.createSobject('Case', new map<String, Object>{
            'Country__c'=>'PT', 'Brand__c'=>'AP', 'SuppliedName'=>'Marta Ruiz Fernandez', 'SuppliedEmail'=>'testB2B@email.es', 
            'SuppliedCompany'=>'Super Company', 'SuppliedPhone'=>'+351801213123', 'SuppliedNationalID__c'=>'123456789', 
            'AccountId'=> b2bAccount.Id, 'SuppliedCity__c'=>'Lisboa','SuppliedZipCode__c'=>'123'}, false);    
        //Insert Cases
        List<Case> lstTestCases = new List<Case>{caseTypeB2C, caseTypeB2B}; 
        insert lstTestCases;
    }
    
    /*********************************************************************************************************
    * @Method          :   checkMappingPersonAccount
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/04/2019
    * @Description     :   This method is used to verify that all fields are mapped correctly when a person 
    *                  :   account is created from a case
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/        
    @isTest static void checkMappingPersonAccount(){
        
        Case caseB2C = [SELECT Country__c, Brand__c, SuppliedName, SuppliedEmail, SuppliedCompany, SuppliedPhone, 
                       SuppliedNationalID__c, SuppliedCity__c, SuppliedZipCode__c, FiscalID__c FROM Case
                       WHERE SuppliedEmail = 'testB2C@email.es' LIMIT 1];
        
        Account personAccount = CareUtils.createPersonAccountFromCase(caseB2C);
        //Check that all fields in the person account are mapped correctly
        System.assertEquals(PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA), personAccount.RecordTypeId);
 		System.assertEquals(caseB2C.Country__c, personAccount.Country__c);
 		System.assertEquals(caseB2C.Brand__c, personAccount.Brand__c);
 		System.assertEquals(caseB2C.SuppliedName.substringBefore(' '), personAccount.FirstName);
 		System.assertEquals(caseB2C.SuppliedName.substringAfter(' '), personAccount.LastName);
        System.assertEquals(caseB2C.SuppliedEmail, personAccount.Email__c);
        System.assertEquals(caseB2C.SuppliedEmail, personAccount.PersonalEmail__pc);
 		System.assertEquals(caseB2C.SuppliedPhone, personAccount.Phone);
 		System.assertEquals(caseB2C.SuppliedPhone, personAccount.PersonMobilePhone);
 		System.assertEquals(caseB2C.SuppliedPhone, personAccount.MobilePersonalTelephone__pc);
 		System.assertEquals(caseB2C.SuppliedNationalID__c, personAccount.NationalId__pc);
 		System.assertEquals(caseB2C.SuppliedCity__c, personAccount.PersonMailingCity);
 		System.assertEquals(caseB2C.SuppliedZipCode__c, personAccount.BillingPostalCode);
 		System.assertEquals(caseB2C.FiscalID__c, personAccount.FiscalID__c);
            
        //Check that the only difference between the two methods are the firstname and lastname fields
        Account personAccount2 = CareUtils.createPersonAccountFromCase(caseB2C, 'firstName', 'lastName');
        personAccount.FirstName = 'firstName';
        personAccount.LastName = 'lastName';
        //Check that after changing the fields 'FirstName' and 'LastName', the two accounts are the same ..       
        System.assert(personAccount2 == personAccount);
    }    
    
    /*********************************************************************************************************
    * @Method          :   checkCaseFromWebFormMatching
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/04/2019
    * @Description     :   This method is used to verify that all fields are mapped correctly when an account B2B 
    *                  :   is created from a case
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/            
    @isTest static void checkMappingAccountB2B(){
        Case caseB2B = [SELECT Country__c, Brand__c, SuppliedName, SuppliedEmail, SuppliedCompany, SuppliedPhone, 
                       SuppliedNationalID__c, SuppliedCity__c, SuppliedZipCode__c, FiscalID__c, AccountId FROM Case 
                       WHERE SuppliedEmail = 'testB2B@email.es' LIMIT 1];        

        Account accountB2B = CareUtils.createAccountB2BFromCase(caseB2B);
        //Check that all fields in the B2B account are mapped correctly
        System.assertEquals(PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2B), accountB2B.RecordTypeId);
 		System.assertEquals(caseB2B.Country__c, accountB2B.Country__c);
 		System.assertEquals(caseB2B.Brand__c, accountB2B.Brand__c);
 		System.assertEquals(caseB2B.SuppliedCompany, accountB2B.Name);
        System.assertEquals(caseB2B.SuppliedEmail, accountB2B.Email__c);
 		System.assertEquals(caseB2B.SuppliedPhone, accountB2B.Phone);
 		System.assertEquals(caseB2B.SuppliedCity__c, accountB2B.ShippingCity);
 		System.assertEquals(caseB2B.SuppliedZipCode__c, accountB2B.ShippingPostalCode);
 		System.assertEquals(caseB2B.FiscalID__c, accountB2B.FiscalID__c);   
        
        Contact contactB2B = CareUtils.createContactB2BFromCase(caseB2B);
        //Check that all fields in the B2B contact are mapped correctly
        System.assertEquals(caseB2B.SuppliedName.substringBefore(' '), contactB2B.FirstName);
        System.assertEquals(caseB2B.SuppliedName.substringAfter(' '), contactB2B.LastName);
        System.assertEquals(caseB2B.SuppliedEmail, contactB2B.ProfessionalEmail__c);
        System.assertEquals(caseB2B.SuppliedNationalID__c, contactB2B.NationalId__c);
        System.assertEquals(caseB2B.SuppliedPhone, contactB2B.MobileProfessionalTelephone__c);
        System.assertEquals(caseB2B.SuppliedPhone, contactB2B.MobilePersonalTelephone__c);
        System.assertEquals(caseB2B.AccountId, contactB2B.AccountId);
       
        //Check that the only difference between the two methods are the firstname and lastname fields
        Contact contactB2B2 = CareUtils.createContactB2BFromCase(caseB2B, 'firstname', 'lastname');    
        contactB2B.FirstName = 'firstname';
        contactB2B.LastName = 'lastname';
        //Check that after changing the fields 'FirstName' and 'LastName', the two contacts are the same ..  
        System.assert(contactB2B == contactB2B2);
    }    

    /*********************************************************************************************************
    * @Method          :   checkCaseFromWebFormMatching
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/04/2019
    * @Description     :   This method is used to verify that all fields are mapped correctly when a consent 
    *                  :   is created from a case
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/            
    @isTest static void checkMappingConsent(){
        Case caseB2C = [SELECT Country__c, Brand__c, AccountId, ContactId, SuppliedEmail, SuppliedPhone FROM Case
                       WHERE SuppliedEmail = 'testB2C@email.es' LIMIT 1];
        
		Consent__c consent = CareUtils.createConsentFromCase(caseB2C);  
        //Check that all fields in the consent are mapped correctly        
        System.assertEquals(CareConstants.CONSENT_TYPE_WEBFORM, consent.DocumentType__c);
        System.assertEquals(CareConstants.CONSENT_PURPOSE_SURVEY, consent.Purpose__c);
        System.assertEquals(caseB2C.Brand__c, consent.DocumentBrand__c);
        System.assertEquals(caseB2C.Country__c, consent.CollectedCountry__c);
        System.assertEquals(caseB2C.AccountId, consent.TECH_AccountId__c);	
        System.assertEquals(caseB2C.ContactId, consent.Contact__c);
        System.assertEquals(CareConstants.CONSENT_BRAND_EMAIL, consent.CheckBox1Meaning__c);
        System.assertEquals(true, consent.CheckBox1Value__c);
        System.assertEquals(CareConstants.CONSENT_BRAND_PHONE, consent.CheckBox2Meaning__c);
        System.assertEquals(true, consent.CheckBox2Value__c);        
    }    
    
    /*********************************************************************************************************
    * @Method          :   checkCaseFromWebFormMatching
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/04/2019
    * @Description     :   This method is used to verify that all fields are mapped correctly when a case 
    *                  :   is created from the webform
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/            
    @isTest static void checkMappingWebform(){
        
        Case caseWebForm = CareUtils.createCaseFromWebForm(false, 'reason', 'summary', 'subject', 'firstname', 'lastname', 
           'email', 'PT', 'AP', 'PT', '1312', 'lisboa', '', '', '123456789', CareConstants.CASE_STATUS_CLOSED, 'Yes', 
            '+351892320', '2','', '');
        
        //Check that all fields in the case are mapped correctly        
        System.assertEquals('reason', caseWebForm.Reason);
        System.assertEquals('summary', caseWebForm.Description);
        System.assertEquals('subject', caseWebForm.Subject);
        System.assertEquals('firstname lastname', caseWebForm.SuppliedName);
        System.assertEquals('email', caseWebForm.SuppliedEmail);
        System.assertEquals('subject', caseWebForm.Subject);
        System.assertEquals('PT', caseWebForm.Country__c);
        System.assertEquals('AP', caseWebForm.Brand__c);
        System.assertEquals('PT', caseWebForm.Language__c);        
        System.assertEquals('Yes', caseWebForm.CaseSurveyAcceptance__c);
    }    
    
}
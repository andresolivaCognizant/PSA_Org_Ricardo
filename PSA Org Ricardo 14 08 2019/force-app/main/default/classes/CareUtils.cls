/*-----------------------------------------------------------------------------------------------------------//
  * Class Name    : CareUtils
  * Project       : PSA - C1ST - Care
  * Author        : Carmen Hernandez  <carmen.diazhernandez@ext.mpsa.com>
  * Date          : 07/04/2019
  * Description   : Contains useful methods for Care
  *
  *-----------------------------------------------------------------------------------------------------------
  *      Modification Log :
  *-----------------------------------------------------------------------------------------------------------
  *      Developer                Date                     Description    
  *      Carmen Hernandez         07/04/2019               Creation.      
  *-----------------------------------------------------------------------------------------------------------*/
public class CareUtils {
    
    //Constants
    private final static String SPACE_STR           = ' ';
    
    //Instance careMethods
    private static final CareStaticVariables instanceCare = CareStaticVariables.getInstance();   
  
    /*********************************************************************************************************
    * @Method          :   createPersonAccountFromCase
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   06/17/19
    * @Description     :   This method creates a person account from a case
    * @params          :   Case newCase
    * @Returns         :   Account: new person account
    **********************************************************************************************************/
    public static Account createPersonAccountFromCase(Case newCase){
        Map<String, String> mapPicklistValues = instanceCare.getPicklistValues(CareConstants.COUNTRY_FIELD, 
																			CareConstants.KEY_PICKLIST_COUNTRY, false);
        Account newAcc = new Account();
        newAcc.RecordtypeId = PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA);
        newAcc.Brand__c = newCase.Brand__c;
        newAcc.Country__c = newCase.Country__c;
        newAcc.Email__c = newCase.SuppliedEmail;
        newAcc.Phone = newCase.SuppliedPhone;
        newAcc.FiscalId__c = newCase.FiscalID__c;
        if(String.isNotBlank(newCase.SuppliedName) && newCase.SuppliedName.contains(SPACE_STR)){
            newAcc.FirstName = newCase.SuppliedName.substringBefore(SPACE_STR);
            newAcc.LastName = newCase.SuppliedName.substringAfter(SPACE_STR);
        }
        else{
            newAcc.FirstName = newCase.SuppliedName;
        }
        newAcc.PersonMobilePhone = newCase.SuppliedPhone;
        newAcc.MobilePersonalTelephone__pc = newCase.SuppliedPhone;
        newAcc.PersonalEmail__pc = newCase.SuppliedEmail;
        newAcc.NationalId__pc = newCase.SuppliedNationalID__c;
        newAcc.PersonMailingCountry = mapPicklistValues.get(CareConstants.KEY_PICKLIST_COUNTRY+newCase.Country__c);
        newAcc.PersonMailingCity = newCase.SuppliedCity__c;
        newAcc.PersonMailingPostalCode = newCase.SuppliedZipCode__c;
        newAcc.BillingCountry = mapPicklistValues.get(CareConstants.KEY_PICKLIST_COUNTRY+newCase.Country__c);
        newAcc.BillingCity = newCase.SuppliedCity__c;
        newAcc.BillingPostalCode = newCase.SuppliedZipCode__c;

        return newAcc;
    }
    
    /*********************************************************************************************************
    * @Method          :   createPersonAccountFromCase
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   06/17/19
    * @Description     :   This method creates a person account from a case
    * @params          :   Case newCase
    * @params		   :   String firstName
    * @params		   :   String lastName
    * @Returns         :   Account: new person account
    **********************************************************************************************************/
    public static Account createPersonAccountFromCase(Case newCase, String firstName, String lastName){
        Account newAcc = createPersonAccountFromCase(newCase);
        newAcc.FirstName = firstName;
        newAcc.LastName = lastName; 
        
        return newAcc;
    }    

    /*********************************************************************************************************
    * @Method          :   createAccountB2BFromCase
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   06/17/19
    * @Description     :   This method creates a B2B Account from a case
    * @params          :   Case newCase
    * @Returns         :   Account: new B2B account
    **********************************************************************************************************/
    public static Account createAccountB2BFromCase(Case newCase){
        Map<String, String> mapPicklistValues = instanceCare.getPicklistValues(CareConstants.COUNTRY_FIELD, 
																	CareConstants.KEY_PICKLIST_COUNTRY, false);
        Account newAcc = new Account();
        newAcc.RecordtypeId = PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2B);
        newAcc.Brand__c = newCase.Brand__c;
        newAcc.Country__c = newCase.Country__c;
        newAcc.Email__c = newCase.SuppliedEmail;
        newAcc.Phone = newCase.SuppliedPhone;
        newAcc.FiscalId__c = newCase.FiscalID__c;
        newAcc.Name = newCase.SuppliedCompany;
        newAcc.ShippingCountry = mapPicklistValues.get(CareConstants.KEY_PICKLIST_COUNTRY+newCase.Country__c);
        newAcc.ShippingCity = newCase.SuppliedCity__c;
        newAcc.ShippingPostalCode = newCase.SuppliedZipCode__c;
        newAcc.BillingCountry = mapPicklistValues.get(CareConstants.KEY_PICKLIST_COUNTRY+newCase.Country__c);
        newAcc.BillingCity = newCase.SuppliedCity__c;
        newAcc.BillingPostalCode = newCase.SuppliedZipCode__c;

        return newAcc;
    }

    /*********************************************************************************************************
    * @Method          :   createContactB2BFromCase
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   06/17/19
    * @Description     :   This method creates a B2B Contact from a case
    * @params          :   Case newCase
    * @Returns         :   Contact: new B2B2 contact
    **********************************************************************************************************/
    public static Contact createContactB2BFromCase(Case newCase){
        Contact newContact = new Contact();
        newContact.RecordTypeId = PAD.recordTypesMapByDeveloperName.get(Constants.RT_CONTACT_B2B);
        if(String.isNotBlank(newCase.SuppliedName) && newCase.SuppliedName.contains(SPACE_STR)){
            newContact.FirstName = newCase.SuppliedName.substringBefore(SPACE_STR);
            newContact.LastName = newCase.SuppliedName.substringAfter(SPACE_STR);
        }
        else{
            newContact.FirstName = newCase.SuppliedName;
        }
        newContact.ProfessionalEmail__c = newCase.SuppliedEmail;
        newContact.NationalId__c = newCase.SuppliedNationalID__c;
        newContact.MobileProfessionalTelephone__c = newCase.SuppliedPhone;
        newContact.MobilePersonalTelephone__c = newCase.SuppliedPhone;
        newContact.AccountId = newCase.AccountId;        

        return newContact;
    }

    /*********************************************************************************************************
    * @Method          :   createContactB2BFromCase
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   06/17/19
    * @Description     :   This method creates a B2B Contact from a case
    * @params          :   Case newCase
    * @params		   :   firstName
    * @params		   :   lastName
    * @Returns         :   Contact: new B2B2 contact
    **********************************************************************************************************/
    public static Contact createContactB2BFromCase(Case newCase, String firstName, String lastName){
        Contact newContact = createContactB2BFromCase(newCase);
        newContact.FirstName = firstName;
        newContact.LastName = lastName;
        
        return newContact;
    }    

    /*********************************************************************************************************
    * @Method          :   createConsentFromCase
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   06/17/19
    * @Description     :   This method creates a consent from a case
    * @params          :   Case newCase
    * @Returns         :   Consent__c: new consent
    **********************************************************************************************************/
    public static Consent__c createConsentFromCase(Case newCase){
        Consent__c newConsent = new Consent__c();
        newConsent.DocumentType__c = CareConstants.CONSENT_TYPE_WEBFORM;
        newConsent.Purpose__c = CareConstants.CONSENT_PURPOSE_SURVEY;
        newConsent.DocumentBrand__c = newCase.Brand__c;
        newConsent.CollectedCountry__c = newCase.Country__c;
        newConsent.TECH_AccountId__c = newCase.AccountId;
        newConsent.Contact__c = newCase.ContactId;
        newConsent.ProcessedDate__c = System.now();
        if(String.isNotBlank(newCase.SuppliedEmail)){
            newConsent.CheckBox1Meaning__c = CareConstants.CONSENT_BRAND_EMAIL;
            newConsent.CheckBox1Value__c = true;
        }
        if(String.isNotBlank(newCase.SuppliedPhone)){
            newConsent.CheckBox2Meaning__c = CareConstants.CONSENT_BRAND_PHONE;
            newConsent.CheckBox2Value__c = true;
        }
        return newConsent;
    }
    
    /*********************************************************************************************************
    * @Method          :   createCaseFromWebForm
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/04/19
    * @Description     :   This method creates a case from the webform (TO DO: Refactor parameters Webform)
    * @params          :   User parameters (Webform)
    * @Returns         :   Case newCase
    **********************************************************************************************************/    
    public static Case createCaseFromWebForm(Boolean b2b, String reason, String summary, String subject, String firstname, 
        String lastname, String email, String country, String brand, String language, String postCode, String city, 
        String vin, String regNumber, String fiscal, String status, String selectedSurvey, String phone, String category, 
        String rut, String company){
        Case newCase = new Case();
        newCase.Reason = reason;
        newCase.Description = summary;
        newCase.Subject = subject;
        newCase.SuppliedName = firstname + ' ' + lastname;
        newCase.SuppliedEmail = email;
        newCase.Country__c = country;                                    
        newCase.Brand__c = brand;                                    
        newCase.Language__c = language;
        newCase.SuppliedZipCode__c = postCode;
        newCase.SuppliedCity__c = city;
        newCase.VIN__c = vin;
        newCase.RegistrationNumber__c = regNumber;
        newCase.Origin = CareConstants.CASE_ORIGIN_WEBFORM;
        newCase.FiscalID__c = fiscal;
        newCase.Status = status;
        newCase.CaseSurveyAcceptance__c = selectedSurvey;
        newCase.SuppliedPhone = (String.isNotBlank(phone) && phone != 'null')? phone:null;                         
        newCase.CategoryL1__c = (String.isNotBlank(newCase.Country__c) && String.isNotBlank(category))? category:null;
        newCase.SuppliedNationalID__c = (country == 'CL')? rut:null;
        newCase.SuppliedCompany = (b2b && String.isNotBlank(company))? company:null;                                                            
        if(status == CareConstants.CASE_STATUS_CLOSED){
            newCase.CloseReasonL1__c = CareConstants.CASE_CLOSE_REASONL1_INF_REQUEST;
            newCase.CloseReasonL2__c = CareConstants.CASE_CLOSE_REASONL2_REPLIED_KB;
        }  
        return newCase;
    }
}
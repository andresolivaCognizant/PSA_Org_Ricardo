/**
    *   @Class          :   NewLeadOverrideController   
    *
    *   @Author         :   Pedro Párraga <parragabornez.pedrojesus@ext.mpsa.com>
    *   @Created        :   
    *   @Description    :  component controller NewLeadOverride
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description    
    *      Pedro Párraga         29/11/2018                   Creation.
    *      Pedro Párraga         05/06/2019                   Add AuraHandledException       
    *   ----------------------------------------------------------------------------------------------------------------------------
**/
public without sharing class NewLeadOverrideController {
    
    @auraEnabled
    public static List<Lead> isOnlyLead(Id caseId){
        List<Lead> lst_lead = new List<Lead>();
        lst_lead = [Select Id, Name from Lead Where Case__c =: caseId limit 1];
        
        if(!lst_lead.isEmpty()){
            return lst_lead;
        }
        return null;
    }
    
    @auraEnabled
    public static Lead createLead(String caseId, String activity, String leadRequestType, String productCustomerInterest, String productOwned){
        System.debug('createLead');
        
        ErrorUtils oData;
        Lead newLead;

        try{
            List<Case> lst_case = new List<Case>();
            lst_case = [SELECT Id, AccountId, Country__c, Brand__c,Dealer__c, Origin FROM Case WHERE Id = : caseId LIMIT 1];
            
            List<Account> lst_account = new List<Account>();
            lst_account = [SELECT Id, RecordType.DeveloperName, FirstName, Lastname, PersonMobilePhone, MobileProfessionalTelephone__pc, PersonalEmail__pc FROM Account Where Id =: lst_case[0].AccountId AND RecordType.DeveloperName = 'PersonAccount_B2C' LIMIT 1];
            
            String phoneNumber = '';
            String firstName = '';
            String lastName = '';
            String dealer = '';
            String recordType = '';
            String leadSource = '';

            if(lst_case[0].Origin == '5'){
                leadSource = '203';
            }else if(lst_case[0].Origin == '1'){
                leadSource = '209';
            }else if(lst_case[0].Origin == '6'){
                leadSource = '206';
            }else if(lst_case[0].Origin == '2'){
                leadSource = '222';
            }else if(lst_case[0].Origin == '3'){
                leadSource = '205';
            }else if(lst_case[0].Origin == '4'){
                leadSource = '210';
            } 
            
            System.debug('lst_account--->'+lst_account.size());
            
            if(lst_account.isEmpty()){
                System.debug('no account');
                return null;
            }else{
                System.debug('yes account');
                if(lst_account[0].MobileProfessionalTelephone__pc != null){
                   phoneNumber = lst_account[0].MobileProfessionalTelephone__pc; 
                }else{
                   phoneNumber = lst_account[0].PersonMobilePhone; 
                }
            }
                     
            
            
            newLead = new Lead(Case__c = caseId,
                                    Firstname = lst_account[0].FirstName,
                                    LastName = lst_account[0].Lastname,
                                    LandlinePersonalTelephone__c = phoneNumber,
                                    Email = lst_account[0].PersonalEmail__pc ,
                                    Customer__c = lst_account[0].Id,
                                    Status = 'New',                                
                                    LeadType__c = '1',
                                    Activity__c = Activity,
                                    LeadRequestType__c = LeadRequestType,
                                    ProductCustomerInterest__c = ProductCustomerInterest, 
                                    ProductOwned__c = ProductOwned,
                                    LeadCountry__c = lst_case[0].Country__c,
                                    PSABrand__c = lst_case[0].Brand__c,
                                    RecordTypeId = Schema.SObjectType.LEAD.getRecordTypeInfosByName().get('B2C').getRecordTypeId(),
                                    LeadChannel__c = '17',
                                    LeadSource = leadSource);
            if(lst_case[0].Dealer__c != null){
                newLead.CalculatedPOS__c = lst_case[0].Dealer__c;
            }

            insert newlead;
            System.debug('inserto lead '+newLead.id);        
            lst_case[0].Lead__c = newLead.Id;
            update lst_case[0];
            System.debug('actualizo lead');
        
        
        }catch(Exception e) {
            oData = new ErrorUtils(e.getMessage(), e.getTypeName(), e.getLineNumber(), e.getStackTraceString(), null, null);
            throw new AuraHandledException(JSON.serialize(oData));  
        }

        return newLead;
    }

    @auraEnabled
    public static List<Lead> getIdLead(Id caseId){
        List<Lead> lst_lead = [SELECt Id, Name FROM Lead WHERE Case__c =: caseId];
        return lst_lead;

    }

    @auraEnabled
    public static Boolean isCorrectAccount(Id caseId){
        System.debug('isCorrectAccount');
        List<Case> lst_case = new List<Case>();
        lst_case = [SELECT Id, AccountId, Country__c, Brand__c, Origin FROM Case WHERE Id = : caseId LIMIT 1];
        List<Account> lst_account = new List<Account>();
        lst_account = [SELECT Id, RecordType.DeveloperName, FirstName, Lastname, PersonMobilePhone, MobileProfessionalTelephone__pc, PersonalEmail__pc FROM Account Where Id =: lst_case[0].AccountId AND RecordType.DeveloperName = 'PersonAccount_B2C' LIMIT 1];
        if(lst_account.isEmpty()){
            System.debug('no account');
            return false;
        }else{
            return true;
        }
    }
    
}
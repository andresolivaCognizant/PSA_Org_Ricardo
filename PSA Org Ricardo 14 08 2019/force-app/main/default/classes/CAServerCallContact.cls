global with sharing class CAServerCallContact {
    public List<Contact> contactListFound {get;set;}
    public List<Account> accountListFound {get;set;}
    //public List<Case> caseListFound{get;set;}
    //public static String numberar = '+56111111111'; 
    //public static String numberar = '+56222222222'; 
    
    //public List<Lead> leadListFound {get;set;}
    
    public String phoneNumberId {get;set;} 
    public String phoneNumber {get;set;} 
    public Boolean reddenderAccounts{get;set;}
    public Boolean reddenderContacts{get;set;}

    
    // ---------------
    //Constructor
    // ---------------    
    public CAServerCallContact() {
        System.debug('__________________________________ VF Controller: CAServerCallContact');
        if(Test.isRunningTest()){
            this.phoneNumberId  = '+34667295188';
            System.debug('Parametros: '+ apexpages.currentpage().getparameters());
            phoneNumber = '+'+this.phoneNumberId.substring(1);
            System.debug('phoneNumber: '+phoneNumber);
        }else{
            //this.phoneNumberId  = '+34111888999';
            this.phoneNumberId = apexpages.currentpage().getparameters().get('key');
            System.debug('Parametros: '+ apexpages.currentpage().getparameters());
            for(String param: apexpages.currentpage().getparameters().keyset())
            {
                System.debug('===key==='+param);
                System.debug('===value==='+apexpages.currentpage().getparameters().get(param));
            }
            System.debug('_________________________________ VF Controller-Parameters: '+apexpages.currentpage().getparameters());
            System.debug('_________________________________ VF Parameter: SKILL: '+apexpages.currentpage().getparameters().get('XRX_LineID'));
            System.debug('_________________________________ VF Parameter: SKILL: '+apexpages.currentpage().getparameters().get('Eic_ReportGroup'));            
            phoneNumber = '+'+this.phoneNumberId.substring(1);
            System.debug('phoneNumber: '+phoneNumber);
        }
    }

    // ---------------  
    //public Methods
    // ---------------        
    public void doFindPhoneNumber() {   
        System.debug('__________________________________ VF Controller: doFindPhoneNumber');        
        //String numberar = '+56661144940';           
        //String phoneno = '%' + this.phoneNumber;    

         this.accountListFound = [Select Id, Name, FirstName , LastName, Phone from Account Where LandlinePersonalTelephone__pc = : phoneNumber order by Name desc];
         this.contactListFound = [Select Id,Name, FirstName, LastName, AccountId,Account.Name,Phone,MobilePhone, Email  from Contact where LandlineProfessionalTelephone__c = : phoneNumber order by Account.Name desc];
   }

    @RemoteAction
    public static List<Account> searchAccount(String numberar){ 
        System.debug('__________________________________ VF Controller: searchAccount');                
        return [Select Id, Name, FirstName , LastName, Phone from Account Where LandlinePersonalTelephone__pc = : numberar OR MobileProfessionalTelephone__pc = : numberar OR Phone = : numberar order by Name desc];
    }

    @RemoteAction
    public static List<Contact> searchContact(String numberar){
        System.debug('__________________________________ VF Controller: searchContact');                
        return [Select Id,Name, FirstName, LastName, AccountId,Account.Name,Phone,MobilePhone, Email  from Contact where LandlineProfessionalTelephone__c = : numberar order by Account.Name desc];
    }

    @RemoteAction
    public Static List<Case> searchCase(String idObject){
        System.debug('__________________________________ VF Controller: searchCase');                
        return [Select Id  from Case WHERE (AccountId = : idObject OR ContactId = : idObject) and (Status = '1' OR Status = '2' OR Status = '3' OR Status = '4' OR
        Status = '5' OR Status = '6' OR Status = '8') order by Account.Name desc];
    }


    public List<Account> getAccConCases(){
        System.debug('__________________________________ VF Controller: getAccConCases');                
        List<Account> lst_acc =  [select id, Name, Email__c, Phone, MobilePersonalTelephone__pc, PersonalEmail__pc, 
                                (select id, Name, Email, Phone, IsPersonAccount, AccountId, MobilePersonalTelephone__c, PersonalEmail__c from Account.Contacts), 
                                (select id, ContactId, CaseNumber, ContactEmail, ContactPhone, ContactMobile from Cases WHERE 
                                (Status = '1' OR Status = '2' OR Status = '3' OR Status = '4' OR Status = '5' OR Status = '6' OR Status = '8') order by Account.Name) 
                                
                                
                                from Account WHERE MobilePersonalTelephone__pc = : phoneNumber OR 
                                        Phone = : phoneNumber OR MobileProfessionalTelephone__pc = : phoneNumber order by Name desc];

        if(!lst_acc.isEmpty()){
            reddenderAccounts = true;
            return lst_acc;
        }else{
            reddenderAccounts = false;
        }

        return null;
        
    }

    public List<Contact> getContactsCases(){
        System.debug('__________________________________ VF Controller: getContactsCases');                
            List<Contact> lst_contact =  [select id, Name, Email, Phone, IsPersonAccount, AccountId, (select id, ContactId, CaseNumber, ContactEmail, ContactPhone from Cases WHERE (Status = '1' OR Status = '2' OR Status = '3' OR Status = '4' OR
                                        Status = '5' OR Status = '6' OR Status = '8') order by Account.Name) from Contact WHERE (MobilePersonalTelephone__c = : phoneNumber OR Phone = : phoneNumber) AND IsPersonAccount = false order by Name desc];

        if(!lst_contact.isEmpty()){
            reddenderContacts = true;
            return lst_contact;
        }else{
            reddenderContacts = false;
        }

        return null;
        
    }

    @RemoteAction
    public static List<Account> getAccConCasesRemote(String numberPhone){
        System.debug('__________________________________ VF Controller: getAccConCasesRemote');                
        return [select id, Name, Phone, Email__c, BillingCity, 
                (select id, Name, Email, Phone, IsPersonAccount from Contacts), 
                (select id, ContactId, CaseNumber, ContactEmail, ContactPhone from Cases WHERE (Status = '1' OR Status = '2' OR Status = '3' OR Status = '4' OR
                Status = '5' OR Status = '6' OR Status = '8') order by Account.Name) from Account WHERE MobilePersonalTelephone__pc = : numberPhone OR Phone = : numberPhone OR MobileProfessionalTelephone__pc = : numberPhone order by Name desc];
    } 


    @RemoteAction
    public static List<Contact> getContactsCasesRemote(String numberPhone){
        System.debug('__________________________________ VF Controller: getContactsCasesRemote');                
        return [select id, Name, Email, Phone, IsPersonAccount, AccountId, (select id, ContactId, CaseNumber, ContactEmail, ContactPhone from Cases WHERE (Status = '1' OR Status = '2' OR Status = '3' OR Status = '4' OR
                                        Status = '5' OR Status = '6' OR Status = '8') order by Account.Name) from Contact WHERE (MobilePersonalTelephone__c = : numberPhone OR Phone = : numberPhone) AND IsPersonAccount = false order by Name desc];
    } 


    @RemoteAction
    public static String createCase(Id accId){
        System.debug('__________________________________ VF Controller: createCase');                
        Case caso = new Case(Status = '1', AccountId = accId, Origin = '1', Tech_AccountMatch__c = true);
        insert caso;

        return caso.Id;
    } 

    @RemoteAction
    public static String createCase(Id accId, String skill){
        System.debug('__________________________________ VF Controller: createCase ___________ SKILL');  
        System.debug('__________ skill: '+skill);
        Case caso = new Case(Status = '1', AccountId = accId, Origin = '1', Tech_AccountMatch__c = true);
        if(skill!= null && skill!=''){
            System.debug('_____________________ CTITaskCaaseRelation.getValuesFromSkill');
            Map <String, String> mapSkill = CTITaskCaseRelation.getValuesFromSkill(skill);
                if(mapSkill != null){
                    for(String field : mapSkill.keySet()){
                        caso.put(field, mapSkill.get(field));
                    }
                }
        }
        
        insert caso;

        return caso.Id;
    } 

    @RemoteAction
    public static String createCaseContact(Id conId){
        System.debug('__________________________________ VF Controller: createCaseContact');                        
        Case caso = new Case(Status = '1', ContactId = conId, Origin = '1', Tech_AccountMatch__c = true);

        insert caso;

        return caso.Id;
    } 


}
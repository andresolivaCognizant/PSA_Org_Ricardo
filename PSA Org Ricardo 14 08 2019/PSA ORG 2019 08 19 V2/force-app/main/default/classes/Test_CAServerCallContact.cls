@isTest
private class Test_CAServerCallContact {
    
    @isTest static void test_method_one() {
        CAServerCallContact cas = new CAServerCallContact();
        List<Account> lst_acc = new List<Account>();
        List<Contact> lst_con = new List<Contact>();
        List<Case> lst_cas = new List<Case>();
        Account acc = new Account(Name = 'accountName');
        insert acc;

        Contact c=   new Contact (
            AccountId       =   acc.Id,
            FirstName       =   'Contact FirstName',
            LastName        =   'Contact LastName',
            Salutation      =   '1',
            Phone           =   '9867767',
            ACAnonymization__c=true,
            APAnonymization__c=true,
            DSAnonymization__c=false,
            TECH_OptOut__c=true
        );
        
        insert c;
          
        Test.startTest();
            cas.doFindPhoneNumber();
            lst_acc = CAServerCallContact.searchAccount('+56634251273');
            lst_acc = cas.getAccConCases(); 
            lst_con = CAServerCallContact.searchContact('+56634251273');
            lst_cas = CAServerCallContact.searchCase('001asdn7asgddh');
            lst_con = cas.getContactsCases();
            lst_acc = CAServerCallContact.getAccConCasesRemote('+56634251273');
            lst_con = CAServerCallContact.getContactsCasesRemote('+56634251273');
            String caso = CAServerCallContact.createCase(acc.Id);

            lst_con = [SELECT Id FROM Contact];
            //String contact = CAServerCallContact.createCaseContact(lst_con[0].Id);
            CAServerCallContact.createCase(acc.id, 'PSA CC Peugeot pt-PT');
        Test.stoptest();
    } 
}
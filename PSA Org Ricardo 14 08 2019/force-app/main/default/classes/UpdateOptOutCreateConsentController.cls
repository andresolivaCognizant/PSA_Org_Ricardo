/*-----------------------------------------------------------------------------------------------------------//
  * Class Name    : UpdateOptOutCreateConsentController
  * Project       : PSA - C1ST
  * Author        : Pedro Parraga <parragabornez.pedrojesus@ext.mpsa.com>
  * Date          : 02/05/2019
  * Description   : Controller Class of the components: UpdateOptOutCreateConsent_QA, 
  *                                                     UpdateOptOutCreateConsentPersonAccount_QA
  * @Aura
  *               1. check.                 This method checks if the OptOut functionality is available
  *               2. updateOptOut.          Update the Opt-Out flag and create Opt-Out consents
  *-----------------------------------------------------------------------------------------------------------
  *      Modification Log :
  *-----------------------------------------------------------------------------------------------------------
  *      Developer                Date                     Description    
  *      Pedro Parraga            XX/XX/2019               Creation.      
  *      Carmen Hernandez         03/21/2019               Refactor & Add comments
  *-----------------------------------------------------------------------------------------------------------*/
public with sharing class UpdateOptOutCreateConsentController {

    private final static Id RT_ACCOUNT_B2C_PA                   = Schema.SObjectType.ACCOUNT.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId();
    private final static String INVOCATION_CASE                 = 'case';
    private final static String INVOCATION_ACCOUNT              = 'personAccount';
    private final static String GET_AVAILABLE_OPT_OUT           = 'AVAILABLE_OPT_OUT';
    private final static String SAVED_WITH_WARNING              = 'SAVED_WITH_WARNING'; 
    private final static String EMPTY_STR                       = '';

    /*********************************************************************************************************
    * @Method          :   check
    * @Author          :   Pedro Parraga <parragabornez.pedrojesus@ext.mpsa.com>
    * @Created         :   02/05/2019
    * @Description     :   This method checks if the OptOut functionality is available
    * @params	       :   Id : Record Id
    *                  :   String invocation type: From Case: 'case' ; From Account: 'personAccount'
    * @Returns         :   String : Indicate if it is available or why it is not available
    **********************************************************************************************************/
    @auraEnabled   
    public static String check(Id recordId, String invocationType){

        Account currentAccount = new Account();
        String returnStr = EMPTY_STR;
        //From Case 
        if(invocationType == INVOCATION_CASE){

            Case currentCase = [SELECT Id, AccountId, Account.RecordTypeId, Brand__c, Country__c, TECH_OptOutEmailToSend__c 
                                    FROM Case WHERE Id =: recordId LIMIT 1];

            //Cases with account (Required)
            if((currentCase != null) && (currentCase.AccountId != null)){

                //Cases with Account != B2C_PA ==> NOT_AVAILABLE_OPT_OUT
                if(currentCase.Account.RecordTypeId != RT_ACCOUNT_B2C_PA){
                    returnStr = Label.Opt_Out_Not_Permitted_B2B_Account;
                }
                //Opt Out done ==> NOT_AVAILABLE_OPT_OUT
                else if (currentCase.TECH_OptOutEmailToSend__c){
                    returnStr = Label.Opt_Out_warning;
                }                
                //Cases without Brand__c or Country__c ==> NOT_AVAILABLE_OPT_OUT
                else if((currentCase.Brand__c == null) || (currentCase.Country__c == null)){
                    returnStr = Label.Opt_Out_Brand_Country_Warning;
                }
                else{
                    currentAccount = [SELECT PersonContactId, Brand__c, Country__c FROM Account WHERE Id =: currentCase.AccountId LIMIT 1]; 
                    
                    //Cases with Account.Brand__c & Account.Country__c ==> AVAILABLE_OPT_OUT
                    if((currentAccount.Brand__c != null) && (currentAccount.Country__c != null)){
                        returnStr = GET_AVAILABLE_OPT_OUT;
                    }
                    //Exceptional Case : Customer Account has no Brand/and or Country, but it has Consents already existing with Brand and Country 
                    //matching the Optout we are trying to execute ==> AVAILABLE_OPT_OUT
                    else{
                        Integer numConsents = [SELECT COUNT() FROM Consent__c WHERE (Contact__c =: currentAccount.PersonContactId 
                            AND DocumentBrand__c =: currentCase.Brand__c AND CollectedCountry__c =: currentCase.Country__c) LIMIT 1];
                        returnStr = (numConsents >0)? GET_AVAILABLE_OPT_OUT : Label.Opt_Out_Cannot_Execute_Warning; 
                    }
                }
            }
            else{
                returnStr = Label.Opt_Out_Incorrect_Data_Warning;
            }
        }
        //From Person Account 
        else if(invocationType == INVOCATION_ACCOUNT){

            currentAccount = [SELECT PersonContactId, Brand__c, Country__c, TECH_OptOut__pc, RecordTypeId FROM Account WHERE Id =: recordId LIMIT 1];

            //Person Account
            if((currentAccount != null) && (currentAccount.RecordTypeId == RT_ACCOUNT_B2C_PA)){
                
                //Opt Out done ==> NOT_AVAILABLE_OPT_OUT
                if (currentAccount.TECH_OptOut__pc){
                    returnStr = Label.Do_not_contact_warning;
                }
                //Accounts without Brand__c or Country__c ==> NOT_AVAILABLE_OPT_OUT
                else if((currentAccount.Brand__c == null) || (currentAccount.Country__c == null)){
                    returnStr = Label.Opt_Out_Brand_Country_Warning;
                }
                //AVAILABLE_OPT_OUT
                else{
                    //returnStr = GET_AVAILABLE_OPT_OUT;
                    returnStr = updateOptOut(recordId, invocationType);
                }
            }
            //B2B Account ==> NOT_AVAILABLE_OPT_OUT
            else{
                returnStr = Label.Opt_Out_Not_Permitted_B2B_Account;
            }
        }
        return returnStr;
    }

    /*********************************************************************************************************
    * @Method          :   updateOptOut
    * @Author          :   Pedro Parraga <parragabornez.pedrojesus@ext.mpsa.com>
    * @Created         :   02/05/2019
    * @Description     :   Update the Opt-Out flag and create Opt-Out consents
    * @params	       :   Id : Record Id
    *                  :   String invocation type: From Case: 'case' ; From Account: 'personAccount'
    * @Returns         :   String
    **********************************************************************************************************/
    @auraEnabled
    public static String updateOptOut(Id recordId, String invocationType){

        String brand = EMPTY_STR;
        String country = EMPTY_STR;
        String returnStr = EMPTY_STR;
        Boolean showWarning = false;
        Account currentAccount = new Account();

        Savepoint sp = Database.setSavepoint();

        try{
            //From Case
            if(invocationType == INVOCATION_CASE){
                Case currentCase = [SELECT Id, AccountId, Account.Brand__c, Account.Country__c, Account.RecordTypeId, Brand__c, 
                                        Country__c, TECH_OptOutEmailToSend__c FROM Case WHERE Id =: recordId LIMIT 1];
                //Case with Person Account
                if((currentCase.AccountId != null) && (currentCase.Account.RecordTypeId == RT_ACCOUNT_B2C_PA)){

                    currentAccount = [SELECT Id, TECH_OptOut__pc, PersonContactId, Brand__c, Country__c FROM Account 
                                        WHERE Id =: currentCase.AccountId LIMIT 1];

                    showWarning = (currentCase.Account.Brand__c == null || currentCase.Account.Country__c == null);
                    //Set country & brand to generate consents
                    country = currentCase.Country__c;
                    brand = currentCase.Brand__c;
                    //Update currentCase
                    currentCase.TECH_OptOutEmailToSend__c = true;
                    update currentCase;
                }
                else{
                    returnStr = Label.GenericErrorMessage;
                }
            }
            //From Account
            else if(invocationType == INVOCATION_ACCOUNT){
                currentAccount = [SELECT Id, TECH_OptOut__pc, PersonContactId, Brand__c, Country__c FROM Account WHERE Id =: recordId LIMIT 1];

                //Set country & brand to generate consents
                country = currentAccount.Country__c;
                brand = currentAccount.Brand__c;
            }
            
            if(returnStr != Label.GenericErrorMessage){
                //Create Consents
                ConsentOptOut.createConsentsOptOut(currentAccount, country, brand);

                //Set Account.Opt-Out = FALSE
                currentAccount.TECH_OptOut__pc = true;
                update currentAccount;

                returnStr = (showWarning) ? Label.Opt_Out_Successfully_Saved_With_Warning : 
                                (invocationType == INVOCATION_ACCOUNT)? Label.Do_not_contact_success : Label.Opt_Out_succes;
            }
        }
        catch(Exception e){
            Database.rollback(sp);
            returnStr = Label.GenericErrorMessage;
            System.debug('Exception ERROR UpdateOptOutCreateConsentController.updateOptOut -->' + e.getMessage() + ' Line: '+e.getLineNumber());
        }
        return returnStr;
    }    
}
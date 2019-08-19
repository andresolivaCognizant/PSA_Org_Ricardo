/*-----------------------------------------------------------------------------------------------------------//
  * Class Name    : CaseWebFormController
  * Project       : PSA - C1ST - Care
  * Author        : Borja Gay Flores    <gayflores.borja@ext.mpsa.com>
  * Date          : XX/XX/2018
  * Description   : Controller class of CaseWebForm component, needs to be without sharing due to visibility
  * with the community guest users
  *
  *-----------------------------------------------------------------------------------------------------------
  *      Modification Log :
  *-----------------------------------------------------------------------------------------------------------
  *      Developer                Date                     Description    
  *      Borja Gay Flores         XX/XX/2019               Creation.
  *      Carmen Hernandez                                  Updated
  *      Borja Gay Flores                                  Added setted class to without sharing
  *      Carmen Hernandez         06/13/2019               Refactor, Add comments & Changes Query Knowledge (DZ)
  *      Carmen Hernandez		  07/04/2019               Refactor: Include match methods
  *      Martin de Leon           07/04/2019               US: C1STAGILE-450
  *-----------------------------------------------------------------------------------------------------------*/
public without sharing class CaseWebFormController {

    public class picklistVal {
        public string keypck;
        public string labelpck;
    }

    //Instance careMethods
    private static final CareStaticVariables instanceCare = CareStaticVariables.getInstance();   

    /*********************************************************************************************************
    * @Method          :   saveTheFile
    * @Author          :   Borja Gay Flores <gayflores.borja@ext.mpsa.com>
    * @Created         :   XX/XX/XX
    * @Description     :   This method is used to ..
    * @params          :   Id parentId 
    * @params          :   String fileName
    * @params          :   String base64Data
    * @params          :   String contentType
    * @Returns         :   void
    **********************************************************************************************************/    
    @AuraEnabled
    public static void saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Attachment oAttachment = new Attachment();
        oAttachment.parentId = parentId;
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = fileName;
        oAttachment.ContentType = contentType;
        List<Attachment> lstAtt = new List<Attachment>();
        lstAtt.add(oAttachment);
        System.enqueueJob(new EnQueueWebFormAttachment(lstAtt));
    }
 
    /*********************************************************************************************************
    * @Method          :   getCaseNumber
    * @Author          :   Borja Gay Flores <gayflores.borja@ext.mpsa.com>
    * @Created         :   XX/XX/XX
    * @Description     :   This method is used to obtain the case number created of the case created
    * @params          :   String idCase: Case.Id
    * @Returns         :   String: Case Number
    **********************************************************************************************************/        
    @AuraEnabled 
    public static String getCaseNumber(String idCase) {
        List<Case> lstCase = [SELECT id, CaseNumber FROM Case WHERE Id = :idCase];
        
        return ((!lstCase.isEmpty())? lstCase[0].CaseNumber:null);
    }

    /*********************************************************************************************************
    * @Method          :   getKnowledgeArticles
    * @Author          :   Borja Gay Flores <gayflores.borja@ext.mpsa.com>
    * @Created         :   XX/XX/XX
    * @Description     :   This method is used to obtain the first 5 articles related to the subject
    * @params          :   String category: category picklist ???
    * @params          :   String country: ex-> US
    * @params          :   String brand: ex-> AP
    * @params          :   String language: ex-> en
    * @params          :   String languageCode: ex-> en_US
    * @params          :   String subject: free text (by community user)
    * @Returns         :   void
    **********************************************************************************************************/        
    @AuraEnabled
    public static List<Knowledge__kav> getKnowledgeArticles(String category, String country, String brand, 
                                                            String language, String languageCode, String subject) {
		//Get values & labels from the picklist Case.Brand__c, Case.Country__c
        instanceCare.getPicklistValues(CareConstants.COUNTRY_FIELD, CareConstants.KEY_PICKLIST_COUNTRY, false);
        Map<String, String> mapPicklistValues = instanceCare.getPicklistValues(CareConstants.BRAND_FIELD, CareConstants.KEY_PICKLIST_BRAND, false);
                                                                
        //Delete no alphanumerics characters in the subject
        Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9 ]');
        Matcher matcher = nonAlphanumeric.matcher(subject);
        String strSubject = matcher.replaceAll(' ');

        if(String.isBlank(strSubject) && strSubject != ' '){
            return null;
        }
        //Create query Knowledge, If the country is empty, remove the filter: category->Country__c
        String query = String.isNotBlank(country)?
            'FIND {'+strSubject+'} IN ALL FIELDS RETURNING Knowledge__kav (id,Title, URLName,Language where Language =\''+languageCode+
            '\' order by ArticleTotalViewCount desc limit 5) WITH DATA CATEGORY Country__c AT ('+mapPicklistValues.get('COUNTRY'+country)+'__c) And Brand__c AT ('+brand+'__c)':
            'FIND {'+strSubject+'} IN ALL FIELDS RETURNING Knowledge__kav (id,Title, URLName,Language where Language =\''+languageCode+
            '\' order by ArticleTotalViewCount desc limit 5) WITH DATA CATEGORY Brand__c AT ('+brand+'__c)';
        //Execute query Knowledge
        List<List<sObject>> knowledgeRelatedArt =search.query(query); 
        List<Knowledge__kav> lstKnowledge = new List<Knowledge__kav>();
        lstKnowledge = (List<Knowledge__kav>)knowledgeRelatedArt[0];
        
        return lstKnowledge;
    }
    
    /*********************************************************************************************************
    * @Method          :   validateVIN
    * @Author          :   Borja Gay Flores <gayflores.borja@ext.mpsa.com>
    * @Created         :   XX/XX/XX
    * @Description     :   This method is used to validate the VIN (INT91)
    * @params          :   String VIN
    * @params          :   String country
    * @params          :   String lang: language
    * @params          :   String brand
    * @Returns         :   Integer: response server {200, 400 ....}
    **********************************************************************************************************/      
    @AuraEnabled
    public static Integer validateVIN(String vin, String country, String lang, String brand){
        //Language must always be in lower case, Timeout = 3 seconds
        RestInt91.Int91Response req = RestInt91.sendRequest(vin, lang.toLowerCase(), country, brand, 3000);
        return req.result;
    }
    
    /*********************************************************************************************************
    * @Method          :   createCase
    * @Author          :   Borja Gay Flores <gayflores.borja@ext.mpsa.com>
    * @Created         :   XX/XX/XX
    * @Description     :   This method is used to create a new case and match with an existing account
    * @params          :   User parameters
    * @Returns         :   Id : Case.Id
    **********************************************************************************************************/      
    @AuraEnabled
    public static Id createCase(String reason, String category, String subject, String summary, boolean b2b, 
                                String company, String firstname, String lastname, String email, String phone,
                                String postCode, String city, String vin, String regNumber, String country, 
                                String language, String brand, String status, String rut, String fiscal, 
                                String cRole, String selectedSurvey) {																		
        //Create new case
        Case newCase = CareUtils.createCaseFromWebForm(b2b, reason, summary, subject, firstname, lastname, email, country, brand,
                                 language, postCode, city, vin, regNumber, fiscal, status, selectedSurvey, phone, category, rut, company);
        //Create account from case
        Account newAccount = (b2b)? CareUtils.createAccountB2BFromCase(newCase) : CareUtils.createPersonAccountFromCase(newCase, firstName, lastName);
                   
        //Find if there are accounts with this data
        newAccount.Id = findDuplicates(newAccount);
            
        //Matching case.AccountId & case.ContactId (Create account / case if these do not exist)             
        matchingAccountContact(newCase, newAccount, firstName, lastName);   
         
        //Matching case.AssetId (Create asset if it does not exist)            
        Boolean necessaryCreateAsset = matchingAsset(newCase);                                      
                                    
        //Create consent for each person account                         
		if(!b2b){
            Consent__c newConsent = CareUtils.createConsentFromCase(newCase);
            insert newConsent;
        }  
                                    
		//Get Case_FO_Assignation Assignment Rule 
        List <AssignmentRule> caseAssignmentRule = [SELECT Id FROM AssignmentRule WHERE SobjectType =: CareConstants.CASE_OBJECT_NAME AND 
                  										Active = true AND Name =: CareConstants.CASE_ASSIGNMENT_RULE_FO LIMIT 1];
        //Specifies the ID of the assignment rule to run for the case.                              
        if(!caseAssignmentRule.isEmpty()){
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId = caseAssignmentRule.get(0).Id;                                  
            newCase.setOptions(dmlOpts);              
        }
        insert newCase;
        
        //Insert Asset - Asyncronous (INT 91)
        if(necessaryCreateAsset){
            List<Case> lstCases = new List<Case>{newCase};
			System.enqueueJob(new EnqueueAssetsToInsert(lstCases));
        }          
                                    
        return newCase.Id;
    }

    /*********************************************************************************************************
    * @Method          :   appendToFile
    * @Author          :   Borja Gay Flores <gayflores.borja@ext.mpsa.com>
    * @Created         :   XX/XX/XX
    * @Description     :   This method is used to ..
    * @params          :   Id fileId
    * @params          :   String base64Data
    * @Returns         :   void
    **********************************************************************************************************/   
    private static void appendToFile(Id fileId, String base64Data) {

        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Attachment attachedFile = [SELECT Id, Body FROM Attachment WHERE Id = : fileId];

        String existingBody = EncodingUtil.base64Encode(attachedFile.Body);
        attachedFile.Body = EncodingUtil.base64Decode(existingBody + base64Data);
        update attachedFile;
    }

    /*********************************************************************************************************
    * @Method          :   getselectOptions
    * @Author          :   Borja Gay Flores <gayflores.borja@ext.mpsa.com>
    * @Created         :   XX/XX/XX
    * @Description     :   This method is used to obtain the options of a picklist
    * @params          :   String fld: API Name picklist(Case Object) 
    * @Returns         :   String: List of serialized options
    **********************************************************************************************************/      
    @AuraEnabled
    public static String getselectOptions(String fld) {
        
        List<pickListVal> allOpts = new List<pickListVal>();
        
        for (Schema.PicklistEntry a : Case.getSObjectType().getDescribe().fields.getMap().get(fld).getDescribe().getPickListValues()) {
            if (!(fld == CareConstants.CASE_REASON_APINAME && a.getValue() == CareConstants.CASE_REASON_DEALER)){
                pickListVal pck = new pickListVal();
                pck.keypck = a.getValue();
                pck.labelpck = a.getLabel();
                allOpts.add(pck);
            }
        }
        return JSON.serialize(allOpts);
    }
    
    /*********************************************************************************************************
    * @Method          :   getUserCountryAndLang
    * @Author          :   Borja Gay Flores <gayflores.borja@ext.mpsa.com>
    * @Created         :   XX/XX/XX
    * @Description     :   This method is used to obtain the language and country of the user
    * @params          :   String: country;language
    * @Returns         :   void
    **********************************************************************************************************/
    @AuraEnabled
    public static String getUserCountryAndLang() {
        
        User currentUser = [SELECT Id, Name, Country__c, LanguageLocaleKey, Profile.Name, Profile.UserLicense.Name FROM User 
                            WHERE Id = : UserInfo.getUserId() LIMIT 1];
        
        return ((currentUser.Profile.UserLicense.Name == CareConstants.GUEST_USER_LICENSE) ? CareConstants.GUEST_USER:
                    currentUser.Country__c + ';' + currentUser.LanguageLocaleKey.split('_')[0].toUpperCase());
    }


    /*********************************************************************************************************
    * @Method          :   findDuplicates
    * @Author          :   Martin De Leon <martin.deleon@ext.mpsa.com>
    * @Created         :   07/04/19
    * @Description     :   This method is used to search existing accounts with the same data
    * @params          :   Account newAccount: Account to find its duplicates
    * @Returns         :   Id: Id of the duplicate or null if no duplicate
    **********************************************************************************************************/
    private static Id findDuplicates(Account newAccount){

        List<Account> accounts = new List<Account>();
        accounts.add(newAccount);

        Id result = null;

        //Loop on duplicate rules
        for (Datacloud.DuplicateResult dupeResult : Datacloud.FindDuplicates.findDuplicates(accounts).get(0).getDuplicateResults()){
            // Loop Result matching
            for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                //There is a match
                if(matchResult.getSize()!= 0){
                    // This list contains the records already ordered by match probability
                    // so we are only getting the first one IE the most probable match.
                    Datacloud.MatchRecord matchRecord = matchResult.getMatchRecords()[0];

                    result = matchRecord.getRecord().Id;
                }
            }
        }
        return result;
    }    

    /*********************************************************************************************************
    * @Method          :   matchingAccountContact
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/05/2019
    * @Description     :   This method is used to link the case with the account/contact, if these does not exist, 
    *                      a new account/contact are created
    * @params		   :   Case newCase
    * @params          :   Account newAccount
    * @params		   :   String firstName
    * @params		   :   String lastName
    * @Returns         :   Case
    **********************************************************************************************************/
    private static Case matchingAccountContact(Case newCase, Account newAccount, String firstName, String lastName) {
        
       Boolean isDuplicated = (newAccount.Id != null);
       Boolean isB2BAccount = String.isNotBlank(newCase.SuppliedCompany);
       //There is a duplicated account 
       if (isDuplicated) {
           newCase.AccountId = newAccount.Id;
           newCase.TECH_AccountMatch__c = true;
           if(!isB2BAccount){
               newCase.ContactId = [SELECT PersonContactId FROM Account WHERE Id =: newAccount.Id LIMIT 1].PersonContactId;
           }
           else{
               Contact newContact = CareUtils.createContactB2BFromCase(newCase, firstName, lastName);
               insert newContact;
               newCase.ContactId = newContact.Id;               
           }
       }
       //Create new Account
       else {
           
           //Get technical users to be able to assign them as account owners.
           Map<String, Id> mapTechnicalUsers = new Map<String, Id>();
           for(User userIt : [SELECT Id, UserName FROM User WHERE UserName LIKE '%@techpsa.com%' AND Profile.Name = 'Api_Users']){
               mapTechnicalUsers.put(userIt.UserName.substringBefore('@').toUpperCase(), userIt.Id);
           }           
           //Asssign Account Owner -> Technical users
           if(mapTechnicalUsers.containsKey(newCase.Country__c+newCase.Brand__c)){
               newAccount.OwnerId = mapTechnicalUsers.get(newCase.Country__c+newCase.Brand__c);
           }
           //Set TRUE to not execute the method that sends the email 'Quick Opp must be created...'
           AccountTriggerHandler.isCaseWebForm = true;
           insert newAccount;
           AccountTriggerHandler.isCaseWebForm = false;

           //Matching Case-Account
           newCase.AccountId = newAccount.Id;
           
           //Matching Case-Contact
           if(isB2BAccount){
               Contact newContact = CareUtils.createContactB2BFromCase(newCase, firstName, lastName);
               insert newContact;
               newCase.ContactId = newContact.Id;
           }
           else {
               newAccount = [SELECT PersonContactId FROM Account WHERE Id =: newAccount.Id];
               newCase.ContactId = newAccount.PersonContactId;
           }
       }
       return newCase;
   }

    /*********************************************************************************************************
    * @Method          :   matchingAsset
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/05/2019
    * @Description     :   This method is used to link the case with the asset, if it does not exist, a new 
    *                  :   asset is created
    * @params          :   Case newCase
    * @Returns         :   Boolean: Flag that indicates if it is necessary to create an asset
    **********************************************************************************************************/
    private static Boolean matchingAsset(Case newCase) {

       //There is a duplicated Record
       if (String.isNotBlank(newCase.VIN__c)) {
           List<Asset> assetList = [SELECT Id FROM Asset WHERE VIN__c =: newCase.VIN__c LIMIT 1];
           if(!assetList.isEmpty()){
               newCase.AssetId = assetList.get(0).Id;
           }
       }
       return (newCase.AssetId == null && String.isNotBlank(newCase.VIN__c));
   }    
}
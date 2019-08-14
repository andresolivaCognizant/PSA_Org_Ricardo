public without sharing class GeneratePostalLetterController {
	
	public class PickListVal{
		String TemplateId;
		String Name; 
	}

	public static string finalBody {get;set;}
	public static string sContactId = '';
	/*********************************************************************************************************
    * @Method          :   getCaseInfo
    * @Author          :   
    * @Created         :   
    * @Description     :   
    * @params	       :   String: Case ID
    * @Returns         :   List<String>: HTML template rendered
    **********************************************************************************************************/
	@AuraEnabled
	public static List<String> getCaseInfo(string caseId){
		List<Case> lstCase 		= [SELECT id,Country__c,Brand__c from Case where id = :caseId];
		List<String> caseInfo 	= new List<String>();
		if(!lstCase.isEmpty()){
			caseInfo.add(lstCase[0].Country__c);
			caseInfo.add(lstCase[0].Brand__c);
		}
		System.debug('getCaseInfo : ' + caseInfo);
		return caseInfo;
	}
	/*********************************************************************************************************
    * @Method          :   getTemplates
    * @Author          :   
    * @Created         :   
    * @Description     :   
    * @params	       :   String: Country & Brand
    * @Returns         :   String: 
    **********************************************************************************************************/
	@AuraEnabled
	public static String getTemplates(String country, String brand){
		List<PickListVal> lstPCK 		= new List<PickListVal>();
		String fiscal 					= brand + '_' + country + '%';
		String brandFold 				= '%' + brand + ' Letter';
		System.debug('getTemplates. Fiscal : '+fiscal);
		for(EmailTemplate et : [SELECT id,FolderId, Name, DeveloperName,Body, IsActive from EmailTemplate where DeveloperName like :fiscal and Folder.Name Like :brandFold]){
			PickListVal pck 		= new PickListVal();
			pck.TemplateId 			= et.id;
			pck.Name 				= et.Name;
			lstPCK.add(pck);
		}
		return JSON.serialize(lstPCK);
	}
	/*********************************************************************************************************
    * @Method          	:   loadBody
    * @Author          	:   
    * @Created         	:   
    * @Description     	:   
    * @params	       	:   String: templated Id
	* @params			:	String: case Id
    * @Returns         	:   String: String 
	*---------------------------------------------------------------------------------------------------------*
	* Changes:		   :   26/04/2019 RFL - Removed unnecesary vars. Source Code indented. Header Comments added
    **********************************************************************************************************/
	@AuraEnabled
	public static String loadBody(String templatedId, String caseId){
		String bodyT 					= '';
		sContactId						= getCaseData(caseId);
		List<EmailTemplate> lstEmail 	= [SELECT id,FolderId, Name, DeveloperName,HtmlValue , IsActive from EmailTemplate where id = :templatedId];
		if(!lstEmail.isEmpty()){
			bodyT 						= mergeFields(caseId,lstEmail[0].HtmlValue);
		}
		return bodyT;
	}
    /*********************************************************************************************************
    * @Method          :   mergeFields
    * @Author          :   
    * @Created         :   
    * @Description     :   
    * @params	       :   String: Case ID
    * @params          :   String: HTML template
    * @Returns         :   String: HTML template rendered
	*---------------------------------------------------------------------------------------------------------*
	* Changes:		   :   26/04/2019 RFL - Removed the creation of an Account and Contact? Why is it here?
    **********************************************************************************************************/
	public static String mergeFields (String caseId, String htmlValue){
		Messaging.SingleEmailMessage[] previewEmails 	= new Messaging.SingleEmailMessage[]{};
    	Messaging.SingleEmailMessage email 				= new Messaging.SingleEmailMessage();
		List<String> lstSt 								= new List<String>();
    	Savepoint sp 									= Database.setSavepoint();
			/*  Why this code???
			Account a = new Account();
			a.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId();
			a.FirstName = 'testA';
			a.LastName = 'testB';
			a.PersonEmail = 'a@thisdoesnotwork.es';
			insert a;
			List<Account> lstAcc = [SELECT id,PersonContactid from Account where id = :a.id];
			Contact c = new Contact();
			c.id = lstAcc[0].PersonContactId;
			c.Email = 'a@thisdoesnotwork.es';
			update c;
			*/					
      		lstSt.add(htmlValue);
      		String bodyMerged 							= Messaging.renderEmailTemplate(sContactId,caseId,lstSt)[0].getMergedBody();
		Database.rollback(sp);
		finalBody 										= bodyMerged;
		return bodyMerged;
	}
	/*********************************************************************************************************
    * @Method          :   getCaseData
    * @Author          :   
    * @Created         :   
    * @Description     :   
    * @params	       :   String: Case ID
    * @Returns         :   String: Contact ID
    **********************************************************************************************************/
	public static String getCaseData(string caseId){
		List<Case> lstCase 		= [SELECT Id,ContactId, Country__c,Brand__c from Case where id = :caseId];
		return (!lstCase.isEmpty())?lstCase[0].ContactId:'';
	}
	
}
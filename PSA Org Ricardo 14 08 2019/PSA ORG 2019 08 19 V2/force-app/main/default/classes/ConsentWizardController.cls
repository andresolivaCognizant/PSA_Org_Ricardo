public with sharing class ConsentWizardController {
	@TestVisible 
	class MyOParams {
		
	    @AuraEnabled
	    public String brand;
	    
	    @AuraEnabled
	    public String country;
		
		@AuraEnabled
	    public String sURLVF;

	}

 	
	@AuraEnabled
	public static MyOParams getUserDetails() {
		MyOParams sUserDetails 	= new MyOParams();
        String currentUserId 	= UserInfo.getUserID();
		System.debug('getUserDetails: ' + currentUserId);
        List<User> lUsers 		= new List<User>([SELECT Id,Brand__c,LDAPId__c,Country__c,VNRRDICode__c,LanguageLocaleKey,LocaleSidKey FROM User WHERE Id = :currentUserId LIMIT 1]);
        
		for (User usr : lUsers){
		    if (usr.Id == currentUserId){
		        sUserDetails.country 		= usr.Country__c;
		        sUserDetails.brand 			= usr.Brand__c;
		        sUserDetails.sURLVF			= fetchit();
		    }
		}
		System.debug('sUserDetails: ' + sUserDetails);
		return sUserDetails;
	}    
	
	
	@TestVisible 
	class recDetails {
		
	    @AuraEnabled
	    public String name;
	    @AuraEnabled
        public String firstName;
        @AuraEnabled
        public String lastName;
	    @AuraEnabled
	    public String Id;

	}
	
	@AuraEnabled
    public static recDetails getRecordDetails(String objectId) {
        // Perform isAccessible() checks here
        System.debug('getRecordDetails: ' + objectId);
        recDetails sRecDetails 	= new recDetails();
        
        List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();
		
		Map<String,String> objectMap = new Map<String,String>(); 
		
		for(Schema.SObjectType f : gd) {
 			objectMap.put(f.getDescribe().getKeyPrefix(), f.getDescribe().getName());
		}
 
		String prefix =  objectId.substring(0,3);
		String objectName = objectMap.get(prefix);
		System.debug('** SObject Name ** '+objectName);

        String query;
        
        if (objectName == 'Contact'){
        	sRecDetails = getContactDet(objectId);
        } else {
        	sRecDetails = getAccountDet(objectId);
        }
               
        System.debug('getRecordDetails sRecDetails: ' + sRecDetails);
        	         
        return sRecDetails;
    }
    
    private static String fetchit(){

        Map<String, Map<String, Object>> aux = GlobalSettingsUtil.getGlobalSettingAttributes(new Set<String>{'ConsentWizard'},new Set<String>{'LegalContentPL'});
        System.debug('getVFPage' +  aux.get('ConsentWizard').get('LegalContentPL') );
        return  (String) aux.get('ConsentWizard').get('LegalContentPL');

    }


    private static recDetails getContactDet(Id objectId){
    	List<Contact> lstCont = [SELECT Id, Name FROM Contact WHERE Id = :objectId LIMIT 1];
    	
    	recDetails sCntDetails 	= new recDetails();
    	
    	if (lstCont.size()>0){    
	        sCntDetails.name 	= lstCont[0].Name;
	        sCntDetails.Id 		= lstCont[0].Id;
		} 
        return sCntDetails; 
    }
    
    private static recDetails getAccountDet(Id objectId){
    	List<Account> lstAcc = [SELECT Id, Name,FirstName,LastName, PersonContactId FROM Account WHERE Id = :objectId LIMIT 1];
    	
    	recDetails sAccDetails 	= new recDetails();
    	
    	if (lstAcc.size()>0){    
	        sAccDetails.name 		= lstAcc[0].Name;
	        sAccDetails.Id 			= lstAcc[0].PersonContactId;
            sAccDetails.firstName 	= lstAcc[0].FirstName;
            sAccDetails.lastName 	= lstAcc[0].LastName;
		} 
        return sAccDetails; 
    }
    
    @AuraEnabled
    public static Consent__c saveConsent(Consent__c consent, String accountId,String sCountry, Boolean C1, Boolean C2,Boolean C3, Boolean C4, Boolean C5, Boolean C6, Boolean C7, Boolean C8, Boolean C9, Boolean C10) {
        // Perform isAccessible() and isUpdateable() checks here
		System.debug('@@@Consent__c: '+ consent+' accountId: ' +accountId+' sCountry: ' +sCountry+' C1: '+C1+' C2: '+C2+' C3: '+C3+' C4: '+C4+' C5: '+C5+' C6: '+C6+' C7: '+C7+' C8: '+C8+' C9: '+C9+' C10: '+C10);
		try {
			consent.Contact__c 				= accountId;
	        consent.Purpose__c				= 'Marketing&survey';
	        consent.CollectorUserId__c		= UserInfo.getUserID();
	        consent.CollectedDate__c		= Date.today();
	        consent.CollectedCountry__c		= PAD.uCurrentUserName.Country__c;
	        consent.CollectedEntityId__c	= PAD.uCurrentUserName.Contact.Account.Id;
	        consent.DocumentBrand__c		= PAD.uCurrentUserName.Brand__c;
	        consent.DocumentType__c 		= 'WebForm';
	        consent.ProcessedDate__c		= Date.today();
	
	        if(sCountry == 'DZ'){
	        	consent.CheckBox1Meaning__c	= 'MkgPOSEmail';
	        	consent.CheckBox2Meaning__c	= 'MkgPOSSMS';
	        	consent.CheckBox3Meaning__c	= 'MkgPOSPhone';
	        	consent.CheckBox4Meaning__c	= 'MkgPOSMail';
	        	
				If(C1){
					consent.CheckBox1Value__c  	= true;
					consent.CheckBox2Value__c	= true;
					consent.CheckBox3Value__c	= true; 
					consent.CheckBox4Value__c	= true;
				} else{
					consent.CheckBox1Value__c	= false;
					consent.CheckBox2Value__c	= false;
					consent.CheckBox3Value__c	= false;
					consent.CheckBox4Value__c	= false;
				}
				
				consent.CheckBox5Meaning__c = 'MkgBrandEmail';
				consent.CheckBox6Meaning__c	= 'MkgBrandSMS';
				consent.CheckBox7Meaning__c	= 'MkgBrandPhone';
				consent.CheckBox8Meaning__c	= 'MkgBrandMail';
				
				If(C2){
					consent.CheckBox5Value__c   = true;
					consent.CheckBox6Value__c	= true;
					consent.CheckBox7Value__c	= true; 
					consent.CheckBox8Value__c	= true;
				} else {
					consent.CheckBox5Value__c   = false;
					consent.CheckBox6Value__c	= false;
					consent.CheckBox7Value__c	= false; 
					consent.CheckBox8Value__c	= false;					
				}
			}else if(sCountry == 'PL'){
					consent.CheckBox1Meaning__c	= 'MkgPOSBrandEmail';
					consent.CheckBox1Value__c  	= C3;
					consent.CheckBox2Meaning__c	= 'MkgPOSBrandSMS';
					consent.CheckBox2Value__c	= C3;
					consent.CheckBox3Meaning__c	= 'MkgPOSBrandPhone';
					consent.CheckBox3Value__c	= C4; 
					consent.CheckBox7Meaning__c	= 'MkgGroupMail';
					consent.CheckBox7Value__c	= C5;
					
					if (!C5){
						consent.CheckBox5Meaning__c	= 'MkgGroupEmailSMS';
						consent.CheckBox5Value__c	= false;
						consent.CheckBox6Meaning__c	= 'MkgGroupPhone';
						consent.CheckBox6Value__c	= false;
					} else {
						consent.CheckBox5Meaning__c	= 'MkgGroupEmailSMS';
						consent.CheckBox5Value__c	= C6;
						consent.CheckBox6Meaning__c	= 'MkgGroupPhone';
						consent.CheckBox6Value__c	= C7;
					}
					
					consent.CheckBox10Meaning__c= 'MkgPartnersMail';
					consent.CheckBox10Value__c	= C8;
					
					if (!C8){
						consent.CheckBox8Meaning__c	= 'MkgPartnersEmailSMS';
						consent.CheckBox8Value__c	= false;
						consent.CheckBox9Meaning__c	= 'MkgPartnersPhone';
						consent.CheckBox9Value__c	= false;
					} else {
						consent.CheckBox8Meaning__c	= 'MkgPartnersEmailSMS';
						consent.CheckBox8Value__c	= C9;
						consent.CheckBox9Meaning__c	= 'MkgPartnersPhone';
						consent.CheckBox9Value__c	= C10;
					}
									
					consent.CheckBox4Meaning__c = 'MkgPOSBrandMail';
					consent.CheckBox4Value__c  	= true;
			}
			
	        Insert consent;
	        
		} catch(dmlexception e) { 
	    	System.debug('DMLexception ERROR ConsentWizardController.saveConsent --> ' + e.getMessage() + ' Line: '+e.getLineNumber());  
        } catch(exception e){
        	System.debug('exception ERROR ConsentWizardController.saveConsent: ' + e.getMessage()); 
        }    
	        
	    return consent;

    }
    
    public class CWexception extends exception{
        // Custom exception class
    }


}
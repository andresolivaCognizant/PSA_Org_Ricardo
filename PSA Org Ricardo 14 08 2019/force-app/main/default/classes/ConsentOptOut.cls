/*
*   @Class : ConsentOptOut
*
*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
*   @Created        :   28 feb 2018
*   @Description    :   To manage consent Opt Out action.

*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Developer            Date                     Description
*	   Raul Barba			28 feb 2018				 Creation.	
*   ----------------------------------------------------------------------------------------------------------------------------
*/
public class ConsentOptOut {
    
    /*
     * @Method          :   generateConsents
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   28 feb 2018
     * @Description     :   get the contacts for create the consents.
     * @Params          :   Map<Contact> for create the consents.
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
	public static void generateConsents(Map<Id,Contact> mapCon) {
        List<Consent__c> lConsent = new List<Consent__c>();
        List<Contactability__c> lContactability = [select Contact__c, Brand__c, Country__c, EntityID__c  from Contactability__c where Contact__c in :mapCon.keySet()];
        Map<String, Set<String>> mapCountry = new Map<String, Set<String>>();
        Map<String, Set<Id>> mapEntity = new Map<String, Set<Id>>();
        Set<String> countryTemp;
        Set<Id> entityTemp;
        for(Contactability__c cont : lContactability){
            if(cont.Country__c != null){
                if(!mapCountry.containsKey(cont.Brand__c)){
                    countryTemp = new Set<String>();
                    countryTemp.add(cont.Country__c);
                    mapCountry.put(cont.Brand__c,countryTemp);
                }else{
                    mapCountry.get(cont.Brand__c).add(cont.Country__c);
                }
            }
            if(cont.EntityID__c != null){
                if(!mapCountry.containsKey(cont.Brand__c)){
                    entityTemp = new Set<Id>();
                    entityTemp.add(cont.EntityID__c);
                    mapEntity.put(cont.Brand__c,entityTemp);
                }else{
                    mapEntity.get(cont.Brand__c).add(cont.EntityID__c);
                }
            }
        }
        for(Contact c : mapCon.values()){
            lConsent.addAll(contactToConsents(c, mapCountry, mapEntity));
            c.TECH_OptOutRequest__c = False;
            c.TECH_OptOut__c = False;
        }
        insert lConsent;
    }
    
    /*
     * @Method          :   contactToConsents
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   28 feb 2018
     * @Description     :   get a contact for create the consents.
     * @Params          :   Contact for create the consents.
     * @Returns         :   List<Consent__c>
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
	public static List<Consent__c> contactToConsents(Contact con, Map<String, Set<String>> mapCountry, Map<String, Set<Id>> mapEntity) {
        List<Consent__c> lConsent = new List<Consent__c>();
        String meaning = con.TECH_OptOutMeanOfContact__c;
        if(con.TECH_OptOutEntity__c == 'Brand' && meaning != null && mapCountry.containsKey(con.TECH_OptOutBrand__c)){
        	meaning = 'Mkg' + con.TECH_OptOutEntity__c + meaning;
        	for(String country : mapCountry.get(con.TECH_OptOutBrand__c)){
        		lConsent.add(createConsent(con.Id, con.TECH_OptOutBrand__c, country, null, meaning, con.TECH_OptOutRequest__c));
        	}
        }else if(con.TECH_OptOutEntity__c == 'POS' && meaning != null && mapEntity.containsKey(con.TECH_OptOutBrand__c)){
        	meaning = 'Mkg' + con.TECH_OptOutEntity__c + meaning;
        	for(Id entityID : mapEntity.get(con.TECH_OptOutBrand__c)){
        		lConsent.add(createConsent(con.Id, con.TECH_OptOutBrand__c, null, entityID, meaning, con.TECH_OptOutRequest__c));
        	}
        }
        
        return lConsent;    
    }
    
    /*
     * @Method          :   createConsent
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   28 feb 2018
     * @Description     :   create a consent.
     * @Params          :   Contact for create the consents.
     * @Returns         :   Consent__c
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
	public static Consent__c createConsent(Id contactId, String documentBrand, String country, Id entityId, String meaning, Boolean request) {
        Consent__c sConsent = new Consent__c(
                Contact__c             =   contactId, 
                DocumentBrand__c       =   documentBrand,
                DocumentType__c        =   'DoNotContactMe',
                EnteredByCustomer__c   =   False, 
                Purpose__c             =   'Marketing&survey', 
                CheckBox1Meaning__c    =   meaning,
                CheckBox1Value__c      =   False);
        
        if(request){
            sConsent.CollectorUserId__c = UserInfo.getUserId();
            sConsent.CollectedDate__c = datetime.now();
        }
        if(country != null){
        	sConsent.CollectedCountry__c = country;
        }else if(entityId !=null){
        	sConsent.CollectedEntityId__c = entityId;
        }
        
        return sConsent;    
    }

    /*********************************************************************************************************
    * @Method          :   createConsentOptOut
    * @Author          :   Carmen Hernandez <parragabornez.pedrojesus@ext.mpsa.com>
    * @Created         :   02/19/2019
    * @Description     :   Create a list of consents to indicate Opt-Out
    * @params	       :   Account. Consents associated with this account
    *                  :   String. Country
    *                  :   String. Brand
    * @Returns         :   void
    **********************************************************************************************************/
    public static void createConsentsOptOut(Account account, String country, String brand){
		
		List <Consent__c> consentToCreateList = new List <Consent__c>();  
        Set <Id> entityIdSet = new Set <Id>();

        //Query Consent: Get all consents associated with that account & CollectedEntityId__c != null
        for(Consent__c consent : [SELECT CollectedEntityId__c FROM Consent__c WHERE (TECH_AccountId__c =: account.Id AND 
                    Contact__c =: account.PersonContactId AND CollectedCountry__c =: country AND  DocumentBrand__c =: brand AND 
                    CollectedEntityId__c != null)]){
            //Control Duplicates in CollectedEntityId__c
            if(!entityIdSet.contains(consent.CollectedEntityId__c)){
                //Create consents that generate contactabilities with Entity__c:'POS' for each CollectedEntityId__c, all CheckBoxXValue__c = FALSE
                consentToCreateList.add(new Consent__c(
                    TECH_AccountId__c = account.Id,
                    CheckBox1Meaning__c = 'MkgPOSMail',
                    CheckBox1Value__c = false,
                    CheckBox2Meaning__c = 'MkgPOSEmail',
                    CheckBox2Value__c = false,
                    CheckBox3Meaning__c = 'MkgPOSPhoneSMS',
                    CheckBox3Value__c = false,
                    DocumentType__c = 'DoNotContactMe',
                    EnteredByCustomer__c = false,
                    ProcessedDate__c = System.now(),
                    CollectedEntityId__c = consent.CollectedEntityId__c,
                    Contact__c = account.PersonContactId,
                    Purpose__c = 'Marketing&survey',
                    CollectedCountry__c = country,
                    CollectedDate__c = System.now(),
                    DocumentBrand__c = brand));
                entityIdSet.add(consent.CollectedEntityId__c);
            }
        }
        
        //Create consents that generate contactabilities with Entity__c:'Brand', all CheckBoxXValue__c = FALSE
        consentToCreateList.add(new Consent__c(
            	TECH_AccountId__c = account.Id,
                CheckBox1Meaning__c = 'MkgBrandMail',
                CheckBox1Value__c = false,
                CheckBox2Meaning__c = 'MkgBrandEmail',
                CheckBox2Value__c = false,
                CheckBox3Meaning__c = 'MkgBrandPhoneSMS',
                CheckBox3Value__c = false,
                DocumentType__c = 'DoNotContactMe',
                EnteredByCustomer__c = false,
                ProcessedDate__c = System.now(),
            	Contact__c = account.PersonContactId,
            	Purpose__c = 'Marketing&survey',
            	CollectedCountry__c = country,
            	CollectedDate__c = System.now(),
            	DocumentBrand__c = brand));
         
        //Insert consents
        insert consentToCreateList;
    }
}
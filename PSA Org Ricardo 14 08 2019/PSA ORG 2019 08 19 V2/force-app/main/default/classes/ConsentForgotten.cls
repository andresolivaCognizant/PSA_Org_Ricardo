/*
*   @Class : ConsentForgotten
*
*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
*   @Created        :   02 March 2018
*   @Description    :   To manage consent right to be forgotten.

*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Developer            Date                     Description
*	   Raul Barba			02 March 2018				 Creation.	
*   ----------------------------------------------------------------------------------------------------------------------------
*/
public class ConsentForgotten {
    
    public static String purpose1 = 'Marketing&survey';
    public static String purpose2 = 'Geolocation';
    public static String purpose3 = 'Cookies';
    
    public static String meaning1 = 'MkgBrandMail';
    public static String meaning2 = 'MkgBrandEmail';
    public static String meaning3 = 'MkgBrandPhoneSMS';
    public static String meaning4 = 'MkgPOSMail';
    public static String meaning5 = 'MkgPOSEmail';
    public static String meaning6 = 'MkgPOSPhoneSMS';
    
    /*
     * @Method          :   generateConsents
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   02 March 2018
     * @Description     :   get the contacts for create the consents.
     * @Params          :   Map<Contact> for create the consents.
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
	public static void generateConsents(Map<Id,Contact> mapCon) {
        List<Consent__c> lConsent = new List<Consent__c>();
        List<Contactability__c> lContactability = [select Contact__c, Brand__c, Country__c, EntityID__c, Entity__c  from Contactability__c where Contact__c in :mapCon.keySet()];
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
            if(c.ACAnonymization__c){
            	lConsent.addAll(contactToConsents(c, mapCountry, mapEntity, 'AC'));
            }
            if(c.APAnonymization__c){
            	lConsent.addAll(contactToConsents(c, mapCountry, mapEntity, 'AP'));
            }
            if(c.DSAnonymization__c){
            	lConsent.addAll(contactToConsents(c, mapCountry, mapEntity, 'DS'));
            }
            
            for(Contactability__c cont : lContactability){
                if(c.Id == cont.Contact__c){
                    if(c.ACAnonymization__c && c.APAnonymization__c && c.DSAnonymization__c){
                        if(cont.Entity__c == 'Group'){
                            cont.ContactabilityStatus__c = False;
                        }
                    }
                    if(c.ACAnonymization__c && cont.Brand__c == 'AC'){
                        cont.ContactabilityStatus__c = False;
                    }
                    if(c.APAnonymization__c && cont.Brand__c == 'AP'){
                        cont.ContactabilityStatus__c = False;
                    }
                    if(c.DSAnonymization__c && cont.Brand__c == 'DS'){
                        cont.ContactabilityStatus__c = False;
                    }
                }
            }
            
        }
        insert lConsent;
        update lContactability;
    }
    
    /*
     * @Method          :   contactToConsents
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   05 March 2018
     * @Description     :   get a contact for create the consents.
     * @Params          :   Contact for create the consents.
     * @Returns         :   List<Consent__c>
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
	public static List<Consent__c> contactToConsents(Contact con, Map<String, Set<String>> mapCountry, Map<String, Set<Id>> mapEntity, String brand) {
        List<Consent__c> lConsent = new List<Consent__c>();
        if(mapCountry.containsKey(brand)){
        	for(String country : mapCountry.get(brand)){
        		lConsent.add(createConsent(con.Id, brand, country, null, meaning1, meaning2, meaning3, purpose1, null));
                lConsent.add(createConsent(con.Id, brand, country, null, meaning1, meaning2, meaning3, purpose2, null));
                lConsent.add(createConsent(con.Id, brand, country, null, meaning1, meaning2, meaning3, purpose3, null));
        	}
        }
        if(mapEntity.containsKey(brand)){
        	for(Id entityID : mapEntity.get(brand)){
        		lConsent.add(createConsent(con.Id, brand, null, entityID, meaning4, meaning5, meaning6, purpose1, null));
                lConsent.add(createConsent(con.Id, brand, null, entityID, meaning4, meaning5, meaning6, purpose2, null));
                lConsent.add(createConsent(con.Id, brand, null, entityID, meaning4, meaning5, meaning6, purpose3, null));
        	}
        }
        
        return lConsent;    
    }
    
    /*
     * @Method          :   createConsent
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   05 March 2018
     * @Description     :   create a consent.
     * @Params          :   Contact for create the consents.
     * @Returns         :   Consent__c
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
	public static Consent__c createConsent(Id contactId, String documentBrand, String country, Id entityId, String mean1, String mean2, String mean3, String purpose, id PersonContactId) {
        Consent__c sConsent = new Consent__c(
                Contact__c             =   contactId, 
                DocumentBrand__c       =   documentBrand,
                DocumentType__c        =   'RightToBeForgotten',
                EnteredByCustomer__c   =   False, 
                Purpose__c             =   purpose, 
            	CollectorUserId__c 	   =   UserInfo.getUserId(),
            	CollectedDate__c       =   datetime.now(),
            	CheckBox1Meaning__c    =   mean1,
                CheckBox1Value__c      =   False,
        		CheckBox2Meaning__c    =   mean2,
                CheckBox2Value__c      =   False,
        		CheckBox3Meaning__c    =   mean3,
                CheckBox3Value__c      =   False);
        
        if(country != null){
        	sConsent.CollectedCountry__c = country;
        }else if(entityId !=null){
        	sConsent.CollectedEntityId__c = entityId;
        }
        if(PersonContactId != null){
        	sConsent.TECH_AccountId__c = PersonContactId;
        }
        
        return sConsent;    
    }
    
    /*
     * @Method          :   generateConsents
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   13 March 2018
     * @Description     :   get the contacts for create the consents.
     * @Params          :   Map<Id, Account> for create the consents.
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
	public static void generateConsents(Map<Id,Account> mapAcc) {
        List<Consent__c> lConsent = new List<Consent__c>();
        List<Contactability__c> lContactability = [select Contact__c, Brand__c, Country__c, EntityID__c, Entity__c  from Contactability__c where Contact__c in :mapAcc.keySet()];
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
        for(Account a : mapAcc.values()){
            if(a.ACAnonymization__pc){
            	lConsent.addAll(contactToConsents(a, mapCountry, mapEntity, 'AC'));
            }
            if(a.APAnonymization__pc){
            	lConsent.addAll(contactToConsents(a, mapCountry, mapEntity, 'AP'));
            }
            if(a.DSAnonymization__pc){
            	lConsent.addAll(contactToConsents(a, mapCountry, mapEntity, 'DS'));
            }
            
            for(Contactability__c cont : lContactability){
                if(a.PersonContactId == cont.Contact__c){
                    if(a.ACAnonymization__pc && a.APAnonymization__pc && a.DSAnonymization__pc){
                        if(cont.Entity__c == 'Group'){
                            cont.ContactabilityStatus__c = False;
                        }
                    }
                    if(a.ACAnonymization__pc && cont.Brand__c == 'AC'){
                        cont.ContactabilityStatus__c = False;
                    }
                    if (a.APAnonymization__pc && cont.Brand__c == 'AP'){
                        cont.ContactabilityStatus__c = False;
                    }
                    if(a.DSAnonymization__pc && cont.Brand__c == 'DS'){
                        cont.ContactabilityStatus__c = False;
                    }
                }
            }
            
        }
        insert lConsent;
        update lContactability;
    }
    
    /*
     * @Method          :   contactToConsents
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   13 March 2018
     * @Description     :   get a contact for create the consents.
     * @Params          :   Account B2C for create the consents.
     * @Returns         :   List<Consent__c>
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
	public static List<Consent__c> contactToConsents(Account acc, Map<String, Set<String>> mapCountry, Map<String, Set<Id>> mapEntity, String brand) {
        List<Consent__c> lConsent = new List<Consent__c>();
        if(mapCountry.containsKey(brand)){
        	for(String country : mapCountry.get(brand)){
        		lConsent.add(createConsent(acc.PersonContactId, brand, country, null, meaning1, meaning2, meaning3, purpose1, acc.Id));
                lConsent.add(createConsent(acc.PersonContactId, brand, country, null, meaning1, meaning2, meaning3, purpose2, acc.Id));
                lConsent.add(createConsent(acc.PersonContactId, brand, country, null, meaning1, meaning2, meaning3, purpose3, acc.Id));
        	}
        }
        if(mapEntity.containsKey(brand)){
        	for(Id entityID : mapEntity.get(brand)){
        		lConsent.add(createConsent(acc.PersonContactId, brand, null, entityID, meaning4, meaning5, meaning6, purpose1, acc.Id));
                lConsent.add(createConsent(acc.PersonContactId, brand, null, entityID, meaning4, meaning5, meaning6, purpose2, acc.Id));
                lConsent.add(createConsent(acc.PersonContactId, brand, null, entityID, meaning4, meaning5, meaning6, purpose3, acc.Id));
        	}
        }
        
        return lConsent;    
    }

}
/*
*   @Class : ConsentToContactability
*
*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
*   @Created        :   27 feb 2018
*   @Description    :   To manage consent trigger methods

*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Developer            Date                     Description
*	   Raul Barba			27 feb 2018				 Creation.	
*   ----------------------------------------------------------------------------------------------------------------------------
*/
public class ConsentToContactability {

    /*
     * @Method          :   handleonbeforeDelete
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   16 feb 2018
     * @Description     :   Call the actions that handle the after insert trigger.
     * @Params          :   List<Consent__c> records after the insert.
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
	public static void handleonAfterInsert(List<Consent__c> lConsents) {
        List<Contactability__c> lContactabilities = new List<Contactability__c>();
        Map<String,Contactability__c> mapContactabilities = new Map<String,Contactability__c>();
        String complexWhere = '';
        Contactability__c auxCont;
        List<Contactability__c> lContactabilitiesUpdate;
        //Create all the Contactability that the consents need.
        for(Consent__c consent: lConsents){
            lContactabilities.addAll(consentToContactability(consent));
        }
        
        //Create the where of the query for detect all the contactability that is not necesary to create beacuse is already created.
        for(Contactability__c cont : lContactabilities){
            if(complexWhere == ''){
                complexWhere = ' (';
            }else{
                complexWhere =complexWhere + ' or (';
            }
            complexWhere = complexWhere 
                + 'Contact__c = ' + (cont.Contact__c != null ? '\'' + cont.Contact__c + '\'' : null) 
                + ' and Brand__c = ' + (cont.Brand__c != null ? '\'' + cont.Brand__c + '\'' : null) 
                + ' and Entity__c = ' + (cont.Entity__c != null ? '\'' + cont.Entity__c + '\'' : null) 
                + ' and EntityID__c = ' + (cont.EntityID__c != null ? '\'' + cont.EntityID__c + '\'' : null) 
                + ' and Country__c = ' + (cont.Country__c != null ?  '\'' + cont.Country__c + '\'' : null) 
                + ' and Channel__c = ' + (cont.Channel__c != null ? '\'' + cont.Channel__c + '\'' : null) 
                + ' and Purpose__c = ' + (cont.Purpose__c != null ? '\'' + cont.Purpose__c + '\'' : null) + ')';
            mapContactabilities.put(cont.Contact__c + cont.Brand__c + cont.Entity__c + cont.EntityID__c + cont.Country__c + cont.Channel__c + cont.Purpose__c, cont);
        }
        
        //Update all the already contactability records with the new data and add to the list for the upsert. 
        //And remove all the record that is not necessary to create.
        if(complexWhere != ''){
            lContactabilitiesUpdate = Database.query('select Contact__c, Brand__c, Entity__c, EntityID__c, Country__c, Channel__c, Purpose__c, ContactabilityStatus__c, CalculationDate__c from Contactability__c where' + complexWhere);
            for(Contactability__c cont : lContactabilitiesUpdate){
                auxCont = mapContactabilities.get(cont.Contact__c + cont.Brand__c + cont.Entity__c + cont.EntityID__c + cont.Country__c + cont.Channel__c + cont.Purpose__c);
                cont.ContactabilityStatus__c = auxCont.ContactabilityStatus__c;
                cont.CalculationDate__c = datetime.now();
                if (lContactabilities.indexOf(auxCont)>=0)
                {
                    if(auxCont!=null)
                    {
                        lContactabilities.remove(lContactabilities.indexOf(auxCont));
                    }
                } 
            }
            lContactabilities.addAll(lContactabilitiesUpdate);
        }
            
        upsert lContactabilities;
	}
    
    /*
     * @Method          :   consentToContactability
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   16 feb 2018
     * @Description     :   Create all the Contactability records for a Consent.
     * @Params          :   Consent__c record.
     * @Returns         :   List<Contactability__c>
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
	public static List<Contactability__c> consentToContactability(Consent__c consent) {
        List<Contactability__c> lContactabilities = new List<Contactability__c>();
        Map<String, Boolean> checkboxes = consentCheckbox(consent);
        for(String meaning : checkboxes.keySet()){
            if(meaning.contains('POS')){
                lContactabilities.add(new Contactability__c(
                    Contact__c = consent.Contact__c,
                    Brand__c = consent.DocumentBrand__c,
                    Entity__c = 'POS',
                    EntityID__c = consent.CollectedEntityId__c,
                    CalculationDate__c = datetime.now(),
                    Channel__c = getChannel(meaning),
                    ContactabilityStatus__c = checkboxes.get(meaning),
                    Purpose__c = consent.Purpose__c));
            }else if(meaning.contains('Brand')){
                lContactabilities.add(new Contactability__c(
                    Contact__c = consent.Contact__c,
                    Brand__c = consent.DocumentBrand__c,
                    Entity__c = 'Brand',
                    Country__c = consent.CollectedCountry__c,
                    CalculationDate__c = datetime.now(),
                    Channel__c = getChannel(meaning),
                    ContactabilityStatus__c = checkboxes.get(meaning),
                    Purpose__c = consent.Purpose__c));
            }else if(meaning.contains('Group')){
                lContactabilities.add(new Contactability__c(
                    Contact__c = consent.Contact__c,
                    Entity__c = 'Group',
                    CalculationDate__c = datetime.now(),
                    Channel__c = getChannel(meaning),
                    ContactabilityStatus__c = checkboxes.get(meaning),
                    Purpose__c = consent.Purpose__c));
            }else if(meaning.contains('Partners')){
                lContactabilities.add(new Contactability__c(
                    Contact__c = consent.Contact__c,
                    Entity__c = 'Partners',
                    CalculationDate__c = datetime.now(),
                    Channel__c = getChannel(meaning),
                    ContactabilityStatus__c = checkboxes.get(meaning),
                    Purpose__c = consent.Purpose__c));
            }
        }
        
        return lContactabilities;
	}
    
    /*
     * @Method          :   consentToContactability
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   16 feb 2018
     * @Description     :   Create a map with the checkbox information.
     * @Params          :   Consent__c record.
     * @Returns         :   Map<String, Boolean>
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
	public static Map<String, Boolean> consentCheckbox(Consent__c consent) {
        Map<String, Boolean> checkboxes = new Map<String, Boolean>();
        for(Integer i = 1; i <= 10 ; i++){
            String meaning = (String)consent.get('CheckBox' + i + 'Meaning__c');
            if(meaning != null){
                Boolean check = (Boolean)consent.get('CheckBox' + i + 'Value__c');
                if(meaning == 'MkgPOSBrand'){
                    checkboxes.put('MkgPOSMail', check);
                    checkboxes.put('MkgBrandMail', check);
                    checkboxes.put('MkgPOSEmail', check);
                    checkboxes.put('MkgBrandEmail', check);
                    checkboxes.put('MkgPOSSMS', check);
                    checkboxes.put('MkgBrandSMS', check);
                    checkboxes.put('MkgPOSPhone', check);
                    checkboxes.put('MkgBrandPhone', check);
                }else if(meaning == 'MkgGroup'){
                    checkboxes.put('MkgGroupMail', check);
                    checkboxes.put('MkgGroupEmail', check);
                    checkboxes.put('MkgGroupPhone', check);
                    checkboxes.put('MkgGroupSMS', check);
                }else if(meaning == 'MkgPOSPhoneSMS'){
                    checkboxes.put('MkgPOSSMS', check);
                    checkboxes.put('MkgPOSPhone', check);
                }else if(meaning == 'MkgBrandPhoneSMS'){
                    checkboxes.put('MkgBrandSMS', check);
                    checkboxes.put('MkgBrandPhone', check);
                }else if(meaning == 'MkgGroupPhoneSMS'){
                    checkboxes.put('MkgGroupPhone', check);
                    checkboxes.put('MkgGroupSMS', check);
                }else if(meaning == 'MkgPartners'){
                    checkboxes.put('MkgPartnersMail', check);
                    checkboxes.put('MkgPartnersEmail', check);
                    checkboxes.put('MkgPartnersPhone', check);
                    checkboxes.put('MkgPartnersSMS', check);
                }else if(meaning == 'MkgPartnersPhoneSMS'){
                    checkboxes.put('MkgPartnersPhone', check);
                    checkboxes.put('MkgPartnersSMS', check);
                }else if(meaning == 'MkgPOSBrandMail'){
                    checkboxes.put('MkgPOSMail', check);
                    checkboxes.put('MkgBrandMail', check);
                }else if(meaning == 'MkgPOSBrandEMail'){
                    checkboxes.put('MkgPOSEmail', check);
                    checkboxes.put('MkgBrandEmail', check);
                }else if(meaning == 'MkgPOSBrandPhoneSMS'){
                    checkboxes.put('MkgPOSSMS', check);
                    checkboxes.put('MkgPOSPhone', check);
                    checkboxes.put('MkgBrandPhone', check);
                    checkboxes.put('MkgBrandSMS', check);
                }else if(meaning == 'MkgPOSBrandPhone'){
                    checkboxes.put('MkgPOSPhone', check);
                    checkboxes.put('MkgBrandPhone', check);
                }else if(meaning == 'MkgPOSBrandSMS'){
                    checkboxes.put('MkgPOSSMS', check);
                    checkboxes.put('MkgBrandSMS', check);
                }else if(meaning == 'MkgPOSBrandEmailSMS'){
                    checkboxes.put('MkgPOSSMS', check);
                    checkboxes.put('MkgPOSEmail', check);
                    checkboxes.put('MkgBrandEmail', check);
                    checkboxes.put('MkgBrandSMS', check);
                }else if(meaning == 'MkgGroupEmailSMS'){
                    checkboxes.put('MkgGroupSMS', check);
                    checkboxes.put('MkgGroupEmail', check);
                }else if(meaning == 'MkgPartnersEmailSMS'){
                    checkboxes.put('MkgPartnersSMS', check);
                    checkboxes.put('MkgPartnersEmail', check);
                }else{
                    checkboxes.put(meaning, check);
                }
            }
        }
        
        return checkboxes;
	}
    
    /*
     * @Method          :   getChannel
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   16 feb 2018
     * @Description     :   get the Channel of the meaning checkbox.
     * @Params          :   String meaning record.
     * @Returns         :   String Channel
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
	public static String getChannel(String meaning) {
        String channel = null;
        if(meaning.contains('Mail')){
            channel = 'Postal';
        }else if(meaning.contains('Email')){
			channel = 'eMail';
        }else if(meaning.contains('Phone')){
			channel = 'Phone';
        }else if(meaning.contains('SMS')){
			channel = 'SMS';
        }
        return channel;
    }
    
}
/*
*   @Class : ContactTriggerHandler
*
*   @Author         :   Ruben Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
*   @Created        :   20 feb 2018
*   @Description    :   To manage Contact trigger methods

*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Developer            Date                     Description
*      Ruben Moreno         20 feb 2018              Creation.
*   ----------------------------------------------------------------------------------------------------------------------------
*/

public class ContactTriggerHandler {

    private static boolean runtrigger = true;

    /*
     * @Method          :   shouldRunTrigger
     * @Author          :   Ruben Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   20 feb 2018
     * @Description     :   To get the flag that indicate if the trigger should run or not
     * @Params          :   -
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */
    public static boolean shouldRunTrigger() {
        return runtrigger;
    }

    /*
     * @Method          :   dontRunTrigger
     * @Author          :   Ruben Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   20 feb 2018
     * @Description     :   To indicate that the trigger should not run
     * @Params          :   -
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */
    public static void dontRunTrigger() {
        runtrigger = false;
    }

    /*
     * @Method          :   beforeInsert
     * @Author          :   Ruben Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   20 feb 2018
     * @Description     :   Call the actions that handle the before insert trigger.
     * @Params          :   List<Contact> records before the insert.
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */
    public static void beforeInsert(List<Contact> lNewContacts) {
        //##RM## To validate the RUT number populated.
        CL00_RUTValidation.mainFunction(lNewContacts);

        //##RM## To populate email and phone(standard fields)
        PopulateStandardEmailAndPhone.setEmailAndPhone(lNewContacts, null);

        for(Contact l : lNewContacts){
            Standardized.contact(l);
        }

        /* BEGIN - Manuel Medina - C1ST-12624 - New logic to sync Contact.Salutation and Contact.TECH_Salutation__c fields - 31012019 */
        pupulateSalutation(lNewContacts, null);
        /* END - Manuel Medina - 31012019 */
        
        //To validate the NIF Format for Portugal
        PT00_NIFValidation.mainFunction(lNewContacts, true);
        setGeographicalSite(lNewContacts);        
        addressUpdateFromWilayaField(lNewContacts, null);
    }

    /*
     * @Method          :   beforeUpdate
     * @Author          :   Ruben Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   20 feb 2018
     * @Description     :   Call the actions that handle the before update trigger.
     * @Params          :   List<Contact> records before the update, Map<Id, Contact> record before the changes
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */
    public static void beforeUpdate(List<Contact> lNewContacts, map<Id, Contact> mapOldContacts) {
        /* BEGIN - Manuel Medina - C1ST-12624 - New logic to sync Contact.Salutation and Contact.TECH_Salutation__c fields - 31012019 */
        pupulateSalutation( lNewContacts, mapOldContacts );
        /* END - Manuel Medina - 31012019 */

        map<Id, Contact> mapContactOptOut = new map<Id, Contact>();
        map<Id, Contact> mapContactForgotten = new map<Id, Contact>();
        //##RM## Beginning - To validate the RUT number populated.
        List<Contact> lContactsToValidateRUT = new List<Contact>();
        List<Contact> lContactsToValidateNIF = new List<Contact>();
        for(Contact l : lNewContacts){
            if (l.NationalId__c != mapOldContacts.get(l.id).NationalId__c) {
                lContactsToValidateRUT.add(l);
            }
            if (l.TECH_OptOut__c) {
                mapContactOptOut.put(l.id,l);
            }
            if ((l.ACAnonymization__c && !mapOldContacts.get(l.id).ACAnonymization__c) ||
               (l.APAnonymization__c && !mapOldContacts.get(l.id).APAnonymization__c) ||
               (l.DSAnonymization__c && !mapOldContacts.get(l.id).DSAnonymization__c)
            ){
                mapContactForgotten.put(l.id,l);
            }
            if(l.FirstName != mapOldContacts.get(l.Id).FirstName || l.LastName != mapOldContacts.get(l.Id).LastName){
                Standardized.contact(l);
            }
            if((l.NationalId__c != mapOldContacts.get(l.id).NationalId__c) ||   				//Changes in NationaId
               (l.NationalIdType__c != mapOldContacts.get(l.id).NationalIdType__c) ||			//Changes in NationalType
               (l.NationalId2__c!= mapOldContacts.get(l.id).NationalId2__c) ||   				//Changes in NationalId2               
               (l.NationalId2Type__c != mapOldContacts.get(l.id).NationalId2Type__c) ||			//Changes in NationalType2
               (l.NonResidentCustomer__c != mapOldContacts.get(l.id).NonResidentCustomer__c) ||	//Changes in NonResidentCustomer
               (l.RecordTypeId != mapOldContacts.get(l.id).RecordTypeId)){						//Changes in RecordType
                    lContactsToValidateNIF.add(l);
            }
            
        }
        if(!lContactsToValidateRUT.isEmpty())
            CL00_RUTValidation.mainFunction(lContactsToValidateRUT);
        //##RM## End - To validate the RUT number populated.

        //##RM## To populate email and phone(standard fields)
        PopulateStandardEmailAndPhone.setEmailAndPhone(lNewContacts, mapOldContacts);

        if(!mapContactOptOut.isEmpty()){
            ConsentOptOut.generateConsents(mapContactOptOut);
        }
        if(!mapContactForgotten.isEmpty()){
            ConsentForgotten.generateConsents(mapContactForgotten);
        }

        //##RM## To set AvailableLeadTreatment field
        SetFlagAvailableLeadTreatment.setFlaG(lNewContacts, mapOldContacts);
        
        //To validate the NIF Format for Portugal
        if(!lContactsToValidateNIF.isEmpty()){
            PT00_NIFValidation.mainFunction(lNewContacts, false);
        }

        setGeographicalSite(lNewContacts);
        addressUpdateFromWilayaField(lNewContacts, mapOldContacts);
    }

    /*
     * @Method          :   afterInsert
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
     * @Created         :   23 feb 2018
     * @Description     :   Call the actions that handle the after insert trigger.
     * @Params          :   List<Contact> records after the insert.
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */
    public static void afterInsert(List<Contact> lNewContacts) {
        ManualSharingProcess.ManualSharing(ManualSharingProcess.setRecordToShare(lNewContacts));
    }

    /*
    * @Method          :   pupulateSalutation
    * @Author          :   Manuel Medina <manuel.medinaperez@ext.mpsa.com>
    * @Created         :   31 jan 2019
    * @Description     :   N/A
    * @Params          :   List<Contact> lstContacts
    * @Params          :   Map<Id, Contact> mapOldContacts
    * @Returns         :   -
    * @MaxSoqls        :   -
    * @MaxDmls         :   -
    */
    public static void pupulateSalutation(List<Contact> lstContacts, Map<Id, Contact> mapOldContacts){
        for (Contact objContact : lstContacts) {
            if (Trigger.isInsert && String.isNotBlank( objContact.Salutation ) ){
                objContact.TECH_Salutation__c = objContact.Salutation;
            } else if (
                Trigger.isUpdate &&
                String.isNotBlank(objContact.Salutation) &&
                String.isNotBlank(mapOldContacts.get(objContact.Id).Salutation) &&
                objContact.Salutation != mapOldContacts.get(objContact.Id).Salutation
            ){
                objContact.TECH_Salutation__c = objContact.Salutation;
            } else if (
                Trigger.isUpdate &&
                String.isNotBlank(objContact.TECH_Salutation__c)&&
                objContact.TECH_Salutation__c != mapOldContacts.get(objContact.Id).TECH_Salutation__c
            ){
                objContact.Salutation = objContact.TECH_Salutation__c;
            }
        }
    }
    
    /*********************************************************************************************************
    * @Method          :   addressUpdateFromWilayafield
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/02/2019
    * @Description     :   This method updates the address from the XXWilaya__c fields. 
    * 					   This method replaces Contact_PB002_Address_Update_from_Wilaya_field process builder
    * @params	       :   List<Contact>: records before insert/update
    * @params	       :   mapOldContacts: old records before insert/update
    * @Returns         :   void
    **********************************************************************************************************/    
    public static void addressUpdateFromWilayaField(List<Contact> lstContacts, Map<Id, Contact> mapOldContacts){
        for (Contact objContact : lstContacts) {
            if((mapOldContacts == null && String.isNotBlank(objContact.MailingWilaya__c)) ||
               ((mapOldContacts != null) && (mapOldContacts.get(objContact.Id).MailingWilaya__c != objContact.MailingWilaya__c))){           
                   objContact.MailingState = objContact.MailingWilaya__c;
            }            
        }
    }       


    /**
     * Set GeographicalSite__c default value. C1STAGILE-10339
     *
     * @author              Diego Rincón
     * @date                2019-07-04
     * @param       lst     list of contact records being upserted
     * @return              none
     */
    public static void setGeographicalSite(List<Contact> lst) {
        for (Contact c : lst) {
            if (String.isBlank(c.GeographicalSite__c)) {
                c.GeographicalSite__c = c.AccountId;
            }
        }
    }

}
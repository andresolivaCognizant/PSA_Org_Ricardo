/*-----------------------------------------------------------------------------------------------------------//
  * Class Name    : PT00_NIFValidation
  * Project       : PSA - C1ST
  * Author        : Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
  * Date          : 2/13/2019
  * Description   : Class that contains methods to validate the NIF format
  *
  *-----------------------------------------------------------------------------------------------------------
  *      Modification Log :
  *-----------------------------------------------------------------------------------------------------------
  *      Developer                Date                     Description    
  *      Carmen Hernandez         2/13/2019                Creation.    
  *-----------------------------------------------------------------------------------------------------------*/
public class PT00_NIFValidation {
    
    private final static Id RT_ACCOUNTB2C 		            = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId();
    private final static Id RT_LEADB2C 			            = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('B2C').getRecordTypeId();
    private final static Schema.sObjectType LEAD_TYPE       = Schema.Lead.getSObjectType();
    private final static Schema.sObjectType ACCOUNT_TYPE    = Schema.Account.getSObjectType();
    private final static Schema.sObjectType CONTACT_TYPE    = Schema.Contact.getSObjectType();
    private final static String CODE_PORTUGAL 	            = 'PT';
    private final static String CODE_NIF                    = 'NIF';
    private final static String EMPTY_STR                   = '';
    private final static String USER_COUNTRY 	            = [SELECT Country__c FROM User Where Id = :UserInfo.getUserId()].Country__c;
    
 
    /*********************************************************************************************************
    * @Method          :   isvalidNIF
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   2/13/2019
    * @Description     :   Algorithm that checks valid format NIF
    * @params	       :   String NIF: String to check
    * @Returns         :   boolean: return TRUE if it is valid, otherwise FALSE
    **********************************************************************************************************/      
    public static boolean isvalidNIF(String NIF){

        if(NIF.length() == 9 && NIF.isNumeric()){

            Integer sum = 0;
            Integer j = 1;
            Integer factorMultiply = 9;
            Integer eachNumber = 0;
            Integer subtract = 0;
            Integer finalNumber = 0;

            for(Integer i=0; i<NIF.length(); i++){
                if(i != 8){
                    eachNumber = integer.valueof(NIF.substring(i,j)) * factorMultiply; 
                    sum += eachNumber;     
                    factorMultiply--;
                }
                if(j < NIF.length()){
                    j++;
                }  
            }
            subtract = sum - (sum / 11 * 11);
            finalNumber = 11 - subtract;
            
            if(finalNumber > 9){
                finalNumber = 0;
            }
            return(!(finalNumber != Integer.valueof(NIF.substring(NIF.length()-1, NIF.length()))));
        }
		else{
            return false;
        }
    }

    /*********************************************************************************************************
    * @Method          :   mainFunction
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   2/13/2019
    * @Description     :   Method that adds an error message if the format is invalid
    * @params	       :   List<sObject> lsObjects: List of objects to check
    *                  :   Boolean isInsert: return TRUE if it is insert event, otherwise FALSE
    * @Returns         :   void
    **********************************************************************************************************/       
    public static void mainFunction(List<sObject> lSObjects, Boolean isInsert){
        try{
            Schema.sObjectType objectType; 
            if(lSObjects!= null && lSObjects.size()>0){
                objectType = lSObjects.get(0).getSObjectType();

                for(sObject oObject : lSObjects){
                    //OBJECT LEAD
                    if(objectType == LEAD_TYPE){
                        Lead oLead = (Lead) oObject;
                        //LEAD B2C, Check National ID, In leads is not checked the NationalType field (by default NIF)
                        if(oLead.recordTypeid == RT_LEADB2C){
                            if(oLead.LeadCountry__c == CODE_PORTUGAL && oLead.NationalId__c != null){
                                if(!isvalidNIF(oLead.NationalId__c)){
                                    //If is a invalid value It'll be reset (only reset in creation)
                                    if(isInsert){
                                        oLead.NationalId__c = null;
                                    }
                                    else{
                                        oLead.NationalId__c.addError(Label.NIFValidation);
                                    }
                                }
                            }
                        }
                    //OBJECT CONTACT
                    }else if(objectType == CONTACT_TYPE){
                        Contact oContact = (Contact) oObject;
                        //All CONTACTs, Check National ID 
                        if(USER_COUNTRY == CODE_PORTUGAL &&  oContact.NationalIdType__c == CODE_NIF &&
                            !oContact.NonResidentCustomer__c && oContact.NationalId__c != null){
                            if(!isvalidNIF(oContact.NationalId__c)){
                                oContact.NationalId__c.addError(Label.NIFValidation);
                            }  
                        }
                        //All CONTACTs, check National ID2
                        if(USER_COUNTRY == CODE_PORTUGAL && oContact.NationalId2Type__c == CODE_NIF &&
                            !oContact.NonResidentCustomer__c && oContact.NationalId2__c != null){
                            if(!isvalidNIF(oContact.NationalId2__c)){
                                oContact.NationalId2__c.addError(Label.NIFValidation);
                            }
                        }
                    //OBJECT ACCOUNT    
                    }else if(objectType == ACCOUNT_TYPE){
                        Account oAccount = (Account) oObject; 
                        //ACCOUNTs B2C
                        if(oAccount.recordTypeid == RT_ACCOUNTB2C){
                            //ACCOUNT B2C, check National ID
                            if(USER_COUNTRY == CODE_PORTUGAL && oAccount.NationalIdType__pc == CODE_NIF && 
                            !oAccount.NonResidentCustomer__pc && oAccount.NationalId__pc != null){
                                if(!isvalidNIF(oAccount.NationalId__pc)){
                                    oAccount.NationalId__pc.addError(Label.NIFValidation);
                                }
                            }
                            //ACCOUNT B2C, check National ID2                        
                            if(USER_COUNTRY == CODE_PORTUGAL && oAccount.NationalId2Type__pc == CODE_NIF && 
                            !oAccount.NonResidentCustomer__pc && oAccount.NationalId2__pc != null){
                                if(!isvalidNIF(oAccount.NationalId2__pc)){
                                    oAccount.NationalId2__pc.addError(Label.NIFValidation);
                                }
                            }
                        }
                    }
                }
            }      
        }catch(DmlException e){
			System.debug('DmlException ERROR PT00_NIFValidation.validateNIF -->' + e.getMessage() + ' Line: '+e.getLineNumber());
        }catch(Exception e){
            System.debug('Exception ERROR PT00_NIFValidation.validateNIF -->' + e.getMessage() + ' Line: '+e.getLineNumber());
        }   
    }

}
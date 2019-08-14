public class CL00_RUTValidation {
    
    private final static id RT_ACCOUNTB2C 		= Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2C_PA').getRecordTypeId();
	private final static id RT_ACCOUNTB2B 		= Schema.SObjectType.ACCOUNT.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
    private final static id RT_LEADB2C 			= Schema.SObjectType.Lead.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
	private final static id RT_LEADB2B 			= Schema.SObjectType.Lead.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
    private final static String CODE_CHILE 		= 'CL';
    private final static String USER_COUNTRY 	= [SELECT Country__c FROM User Where Id = :UserInfo.getUserId()].Country__c;
    private final static string MSG_DUPLICATE 	= Label.RUTDuplicate;
    
    public static boolean validateRut(String rut) {
        boolean validacion = false;
        
        try {
            rut = rut.toUpperCase();
            rut = rut.replace('.', '');
            rut = rut.replace('-', '');
            Integer rutAux = Integer.valueof(rut.substring(0, rut.length() - 1));
            
            String dv = String.valueof(rut.charAt(rut.length() - 1));
            
            Integer m = 0; 
            Integer s = 1;
            
            for (; rutAux != 0; rutAux /= 10) {
                s = math.mod((s + math.mod(rutAux,10) * (9 - math.mod(m++,6))), 11);
            }
            
            if (dv == String.valueOf((s != 0 ? s + 47 : 75))) {
                validacion = true;
            }
            
        } catch (Exception e) {
            System.debug('CL00_RUTValidation.validateRut ERROR -->' + e.getMessage() + ' Line: '+e.getLineNumber());
            return validacion;
            
        }
        System.debug('*** RUT is correct?: '+validacion);
		return validacion;
	}
    
    
    public static void mainFunction(List<sObject> lSObjects){
        System.debug('*** EXECUTING RUT VALIDATION ***');
        List<sObject> lsObjectCL = new List<sObject>();
        try{
                       
            for(sObject oObject : lSObjects){
                
                if(oObject.getSObjectType() == Schema.Lead.getSObjectType()){
                    Lead oLead = (Lead) oObject;
                    
                    if(oLead.recordTypeid == RT_LEADB2C){
                        if(oLead.LeadCountry__c== CODE_CHILE && oLead.NationalId__c != null){
                            if(!validateRut(oLead.NationalId__c)){
                                oLead.addError(Label.RUTValidation);
                            }else{
                                lsObjectCL.add(oLead);
                            }
                                
                        }
                        
                    }else if(oLead.recordTypeid == RT_LEADB2B){
                        if(oLead.LeadCountry__c== CODE_CHILE && oLead.FiscalId__c != null){
                            if(!validateRut(oLead.FiscalId__c)){
                                oLead.addError(Label.RUTValidation);
                            }else{
                                lsObjectCL.add(oLead);
                            }
                        }
                        
                    }   
                        
                    
                }else if(oObject.getSObjectType() == Schema.Contact.getSObjectType()){
                    Contact oContact = (Contact) oObject;
                    
                    if(USER_COUNTRY == CODE_CHILE &&  !oContact.NonResidentCustomer__c && oContact.NationalId__c != null){

                        if(!validateRut(oContact.NationalId__c)){
                            oContact.addError(Label.RUTValidation);
                        }else{
                            lsObjectCL.add(oContact);
                        }
                            
                    }
        
                }else if(oObject.getSObjectType() == Schema.Account.getSObjectType()){
                    
                    Account oAccount = (Account) oObject;
                    if(oAccount.recordTypeid == RT_ACCOUNTB2C){

                        if(USER_COUNTRY == CODE_CHILE &&  !oAccount.NonResidentCustomer__pc && oAccount.NationalId__pc != null){
                            if(!validateRut(oAccount.NationalId__pc)){
                                oAccount.addError(Label.RUTValidation);
                            }else{
                                lsObjectCL.add(oAccount);
                            }
                                
                        }
                        
                    }else if(oAccount.recordTypeid == RT_ACCOUNTB2B){
                        System.debug('*** B2B ***');
                        if(oAccount.Country__c == CODE_CHILE && oAccount.FiscalId__c != null){//the condition 'Chile' is temporary.
                            System.debug('*** B2B ENTRA ***');
                            if(!validateRut(oAccount.FiscalId__c)){
                                oAccount.addError(Label.RUTValidation);
                            }else{
                                lsObjectCL.add(oAccount);
                            }
                                
                        }
                        
                        
                    }
                    
                }
                
            }
            
            CL00_RUTValidation.duplicateRut(lsObjectCL);
            
        }catch(DmlException e){
			System.debug('DmlException ERROR CL00_RUTValidation.ValidateRut -->' + e.getMessage() + ' Line: '+e.getLineNumber());
        }catch(Exception e){
            System.debug('Exception ERROR CL00_RUTValidation.ValidateRut-->' + e.getMessage() + ' Line: '+e.getLineNumber());
        }
        
        
            
        
    }
    
    
    public static void duplicateRut(List<sObject> lsObject){
        
        set<string> setRUTContact 	= new set<string>();
        set<string> setRUTAccount 	= new set<string>();
        
        set<string> setRUTContactDB 	= new set<string>();
        set<string> setRUTAccountDB 	= new set<string>();
        set<string> setRUTB2BAccountDB 	= new set<string>();
        
        try{
                       
            for(sObject oObject : lsObject){
                
                if(oObject.getSObjectType() == Schema.Contact.getSObjectType()){
                    Contact oContact = (Contact) oObject;
                    if(oContact.nationalid__c!=null)
                    	setRUTContact.add(oContact.nationalid__c);                  
                    
                            
                }else if(oObject.getSObjectType() == Schema.Account.getSObjectType()){
                    
                    Account oAccount = (Account) oObject;
                    
                    if(oAccount.recordTypeid == RT_ACCOUNTB2C && oAccount.nationalid__pc!=null){
						setRUTAccount.add(oAccount.nationalid__pc);
                       
                    }else if(oAccount.recordTypeid == RT_ACCOUNTB2B && oAccount.FiscalId__c!=null){
                        setRUTAccount.add(oAccount.FiscalId__c);
                       
                    }
                    
                }
                
            }
            
            if(!setRUTContact.isEmpty()){
                
                for(Contact oContact : [SELECT id, nationalid__c,name FROM Contact WHERE nationalid__c IN :setRUTContact and IsPersonAccount = false]){
                    if(oContact.nationalid__c!=null)
                    	setRUTContactDB.add(oContact.nationalid__c);
                    	System.debug('Id: '+oContact.id);
                }
                
                for(sObject oObject : lsObject){
                    Contact oContact = (Contact) oObject;
                    if(setRUTContactDB.contains(oContact.nationalid__c)){
                        oContact.addError(MSG_DUPLICATE);
                    }                                
            	}
                
            }
            
            if(!setRUTAccount.isEmpty()){
                
                for(Account oAccount : [SELECT id, nationalid__pc,fiscalid__c,recordtypeid FROM Account WHERE (nationalid__pc IN :setRUTAccount) OR (fiscalid__c IN :setRUTAccount)]){
                    
                    if(oAccount.recordTypeid == RT_ACCOUNTB2C && oAccount.nationalid__pc!=null){
                        setRUTAccountDB.add(oAccount.nationalid__pc);
                        System.debug('Id 1: '+oAccount.id);
                    }else if(oAccount.recordTypeid == RT_ACCOUNTB2B && oAccount.fiscalid__c!=null){
                        setRUTB2BAccountDB.add(oAccount.fiscalid__c);
                        System.debug('Id 2: '+oAccount.id);

                    }
                   
                }
                
                for(sObject oObject : lsObject){
                    
                    Account oAccount = (Account) oObject;
                    
                    if(oAccount.recordTypeid == RT_ACCOUNTB2C && setRUTAccountDB.contains(oAccount.nationalid__pc)){
						oAccount.addError(MSG_DUPLICATE);
                    }else if(oAccount.recordTypeid == RT_ACCOUNTB2B && setRUTB2BAccountDB.contains(oAccount.FiscalId__c)){
						oAccount.addError(MSG_DUPLICATE);
                    }
                    
                }
                
            }

            
       	}catch(DmlException e){
			System.debug('DmlException ERROR CL00_RUTValidation.duplicateRut -->' + e.getMessage() + ' Line: '+e.getLineNumber());
        }catch(Exception e){
            System.debug('Exception ERROR CL00_RUTValidation.duplicateRut-->' + e.getMessage() + ' Line: '+e.getLineNumber());
        }
        
        
        
    }
    
    
    
    
    
    
    
    

}
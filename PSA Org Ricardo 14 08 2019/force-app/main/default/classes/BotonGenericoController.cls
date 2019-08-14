/**
    *   @Class          :   BotonGenericoController 
    *
    *   @Author         :   Sergio Lopez
    *   @Created        :   07 SEp 2018
    *   @Description    :   Controller Class for BotonGenerico component
    *
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description    
    *      Sergio Lopez             03/08/2018               Creation.      
    *   ----------------------------------------------------------------------------------------------------------------------------
**/

public with sharing class BotonGenericoController{   
  
    /******************************************************************************************
    * Apex Method Name : loadListBtt
    * Created Date     : 07/09/2018
    * Function         : Get all buttons recover from List Button
    * Modification Log :
    -------------------------------------------------------------------------------------------
    * Date                        Developer                                     Description
    * -----------------------------------------------------------------------------------------
    * 07/09/2018                  Sergio López Calvo                            Initial version
    ********************************************************************************************/
    
    @AuraEnabled
    public static List<wrapperBtt> loadListBtt(String listType){  
        //listType = 'Consent';  
        System.debug('@@@loadListBtt ' + listType);  
          
        List<String> bttSet = listType.split(','); 
        
        System.debug('@@@bttSet ' + bttSet);
                
        List<wrapperBtt> listaRellBtt= new List<wrapperBtt>(); 
        
        try{
            // Getting all the buttons in List
            List<BotonGenerico__mdt> listaBtt=[Select Id, Action__c, Component_Name__c, Label, URL__c, Index__c From BotonGenerico__mdt where DeveloperName IN :bttSet order by Index__c, Label];
        
            System.debug('@@@listaBtt: ' + listaBtt);
             
            if (listaBtt.size()>0){ 
                
                // Gettin a wrapper with mandatory data from Boton Generico CMT
                for(BotonGenerico__mdt elemento : listaBtt){                              
                        
                    wrapperBtt ElementoRellBoton= new wrapperBtt();
                        
                    ElementoRellBoton.id=elemento.Id; 
                    ElementoRellBoton.label=elemento.Label;
                    
                    /*if (elemento.Label == 'Consent_Wizard_Poland_Consent'){
                        ElementoRellBoton.label = Label.Consent_Wizard_Poland_Consent;
                    } else if (elemento.Label == 'DMS'){
                        ElementoRellBoton.label = Label.DMS;
                    }*/
                    
                    ElementoRellBoton.action=elemento.Action__c;
                    ElementoRellBoton.component=elemento.Component_Name__c;
                    ElementoRellBoton.url=elemento.URL__c;
                    ElementoRellBoton.index=elemento.Index__c;                         
                        
                    listaRellBtt.add(ElementoRellBoton);
                    
                }
            
                System.debug('@@@Btts: ' + listaRellBtt);  
                
            }else{
                throw new BGenexception('Button not found in List');
            }
            
        } catch(dmlexception e) {
            wrapperBtt ElementoRellBoton= new wrapperBtt();
            ElementoRellBoton.error = 'DMLexception ERROR BotonGenericoController.loadListBtt --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
            listaRellBtt.add(ElementoRellBoton);  
        } catch(exception e){
            wrapperBtt ElementoRellBoton= new wrapperBtt();
            ElementoRellBoton.error = 'exception ERROR BotonGenericoController.loadListBtt: ' + e.getMessage(); 
            listaRellBtt.add(ElementoRellBoton);           
        }
        
        return listaRellBtt;
        
    }

    public class wrapperBtt {
        
        @AuraEnabled public String id{get;set;}
        @AuraEnabled public String action{get;set;}
        @AuraEnabled public String label{get;set;}
        @AuraEnabled public String component{get;set;}
        @AuraEnabled public String url{get;set;}
        @AuraEnabled public decimal index{get;set;} 
        @AuraEnabled public String error{get;set;}
                
        public wrapperBtt(){
            
            id = '';
            action= '';
            label= '';
            component='';
            url='';
            index=0; 
            error='';          
            
        }
    }
    
    public class BGenexception extends exception{
        // Custom exception class
    }

    /* CORS CALL */
    @AuraEnabled        
    public static Map<String,String> dmsWakeUpbyCORS(String sRecordId_A, String sRecordId_B){
        System.debug('@@@DMSWakeUpbyCORS ' + sRecordId_A);  

        return dmsCallOutsController.DMSWakeUpbyCORS(sRecordId_A, sRecordId_B);
    }

    /* SERVER TO SERVER CALL */
    @AuraEnabled        
    public static boolean dmsWakeUpbyServer(String sRecordId){        
        System.debug('@@@DMSWakeUpbyServer ' + sRecordId);  

        return dmsCallOutsController.DMSWakeUpbyServer(sRecordId);
    }
}
/*----------------------------------------------------------------------------------------------------------------------------------------
    Apex Class Name: Programar_Ctrl
    Version:         1.0
    Created Date:    07/02/2017
    Function:        Recupera datos de cabecera del componente Programar para id de la cuenta remitido en parametros 
    Author:          CAP dev (Sergio López Calvo)
    Company:         Capgemini
            
    History: 
    <Date>                  <Dev Name>              					<Change Description>
    07/02/2017              Capgemini dev(Sergio López Calvo)       	Initial version
    
----------------------------------------------------------------------------------------------------------------------------------------*/
public with sharing class Programar_Ctrl {
	
	/******************************************************************************************
	* Apex Method Name : Programar_Ctrl
	* Created Date     : 12/12/2016
	* Function         : TO DO
	* Modification Log :
	-------------------------------------------------------------------------------------------
	* Date                        Developer                						Description
	* -----------------------------------------------------------------------------------------
	* 14/12/2016                  Capgemini dev(Alberto Martínez López)       	Initial version
	********************************************************************************************/
   	@AuraEnabled
    public static String getEventos() {
    	try{
    		String gestorId = UserInfo.getUserId();
	    	system.debug('gestorId'+gestorId);
	    	String StringRetorno='';
	    	List<Event> eventos=[Select id, Subject, StartDateTime, EndDateTime, WhatId, What.Name, OwnerId, AccountId, Description from Event where OwnerId=:gestorId];
	    	system.debug('@@@@Eventos a devolver-->'+eventos);
	    	List<WrapperResult> retorno=new List<WrapperResult>();
	    	for (Event eDiario: eventos){
	    		WrapperResult uRet=new WrapperResult();
	    		uRet.id=eDiario.id;
	    		uRet.Subject=eDiario.Subject;
	    		//uRet.WhoId=eDiario.WhoId;
	    		//Ojo, si volvemos atras cambiar en la query y el wrapper
	    		uRet.WhatId=eDiario.WhatId;
	    		uRet.OwnerId=eDiario.OwnerId;
	    		system.debug('@@@@@eDiario.WhatId: '+ eDiario.WhatId);
	    		uRet.WhatName=eDiario.WhatId!=null?eDiario.What.Name:null;
	    		uRet.StartDateTime=eDiario.StartDateTime;
	    		uRet.EndDateTime=eDiario.EndDateTime;
	    		uRet.Description= eDiario.Description;
	    		retorno.add(uRet);
	    		uRet=null;
	    	}
	    	
	    				
			//if(Test.isRunningTest()){
   			//Lanzamos excepcion para cubrir el maximo numero de lines de la clase en los text
    			//throw new ErrorsManager.APEXException('Error de test');
   			//}
   			
	    	StringRetorno=JSON.serialize(retorno);
			return StringRetorno;
			
    	}catch(exception e){
    		/*//Se genera el error y se guarda en un registro
	    	ErrorsManager.addError(e, 
			Programar_Ctrl.class.getName(), 
			ErrorsManager.Causante.DML, false);
			ErrorsManager.flush();*/
			String ret='';
			return ret;
		}
    }
    
    @TestVisible private static String getNameFromAccount(String accId){
    	List<Account> acc = [SELECT Name From Account WHERE Id =:accId LIMIT 1];
    	String name = acc[0].Name;
    	return name;
    }
    
    public class WrapperResult{
    	String id, Subject, WhatId,OwnerId,WhatName, Description;
    	Datetime StartDateTime, EndDateTime;
    	public WrapperResult(){
    		
    	}
 
    }
    
	/******************************************************************************************
	* Apex Method Name : getAcctData
	* Created Date     : 07/02/2017
	* Function         : Recupera datos de cabecera del componente Programar para id de la cuenta
	* Modification Log :
	-------------------------------------------------------------------------------------------
	* Date                        Developer                						Description
	* -----------------------------------------------------------------------------------------
	* 07/02/2017                  Capgemini dev(Sergio López Calvo)       	Initial version
	********************************************************************************************/
	    
    @AuraEnabled
    public static String getAcctData(String accId) {
    	
    	system.debug('@@@getAccountData: ' + accId);       	 
   
    		
    			list <Account> infoAccount = [SELECT Id, Name FROM Account WHERE id = :accId];
    			 
	    			Account acc = infoAccount[0];
	    			system.debug('@@@List acc: ' + acc);
	    			return JSON.serialize(acc);
	    		  	
	     	
    	  				
    }
	
	/******************************************************************************************
	* Apex Method Name : addEvent
	* Created Date     : 20/03/2017
	* Function         : Inserta Evento desde el componente Programar
	* Modification Log :
	-------------------------------------------------------------------------------------------
	* Date                        Developer                						Description
	* -----------------------------------------------------------------------------------------
	* 20/03/2017                  Capgemini dev(Sergio López Calvo)       	Initial version
	********************************************************************************************/
	
	@AuraEnabled
	public static boolean addEvent(String id, String startDateTime, String asunto, String mContacto, Integer durationInMinutes, Boolean concertada, String description) {
		boolean retorno = false;
		
		String gestorId = UserInfo.getUserId();
		system.debug('gestorId'+gestorId);
		
        try{
        	//Insertamos el evento desde programar
        	system.debug('@@@@@inside addEvent');
        	system.debug('@@@@Id: ' + id);
			system.debug('@@@@Asunto: ' + asunto);
			system.debug('@@@@StartDateTime: ' + startDateTime);
			system.debug('@@@@Med Contacto: ' + mContacto);
			system.debug('@@@@DurationInMinutes: ' + durationInMinutes);
			system.debug('@@@@Concertada: ' + concertada);
			system.debug('@@@@Description: ' + description);       								
        	
			list<Event> listToInsert = new list<Event>();			
            
        	//Si tenemos ids desde parametros entramos
			if(id!=null && id!=' '){
        		//Damos de alta el Evento por el id que llega en parametros
		        	
	        	Event evento = new Event ();
	        	evento.WhatId = id;
				evento.OwnerId = gestorId;

				//Formateamos fecha de string a DateTime			
				String srcString=startDateTime;

				system.debug('@@@@@inside addEvent - fecha: ' + srcString);
				
				String yy=srcString.subString(0,4);				
				String mm=srcString.subString(5,7);				
				String dd=srcString.subString(8,10);				
				String hh=srcString.subString(11,13);				
				String mn=srcString.subString(14,16);				
				String ss=srcString.subString(17,19);
				String ms='20';				
				
				Date myDate = Date.newInstance(integer.valueOf(yy), 
     				integer.valueOf(mm), 
     				integer.valueOf(dd));
     				
				Time myTime = Time.newInstance(integer.valueOf(hh),
     				integer.valueOf(mn),
     				integer.valueOf(ss),
     				integer.valueOf(ms));
				
				DateTime myDateTime = DateTime.newInstanceGMT(myDate, myTime);    				     			
     							
				system.debug('@@@@@inside addEvent - MyDate: ' + myDateTime);				
				
	        	evento.StartDateTime = myDateTime;
	        	//evento.StartDateTime = datetime.valueOf(srcString);
	        	
	        	//evento.StartDateTime = evento.StartDateTime + (1/24);
	        	system.debug('@@@@@inside addEvent - StartDateTime: ' + evento.StartDateTime);
	        	// TO DO Lo mantenemos comentado por si finalmente usamos description, hay dudas
				evento.Subject = asunto;
	        	evento.Description = description;
	        	//evento.Observaciones__c = description;
	        	//evento.Medio_de_contacto__c = mContacto;
	        	evento.DurationInMinutes = integer.valueof(durationInMinutes); 
	        	//evento.Concertada_con_el_cliente__c = concertada;
	        	
	        	listToInsert.add(evento);
	            system.debug('@@@@@ List to insert : listToInsert ' + listToInsert);  	 
	            if(listToInsert!=null && listToInsert.size()>0){
	                //Insertamos en BBDD        	
	            	Database.SaveResult[] results = Database.insert(listToInsert,false);
	            	for (Database.SaveResult sr : results) {
                    	if (sr.isSuccess()) {
                        	system.debug('@@@@@Evento insertada/actualizada correctamente . Linea Reclamo ID: ' + sr.getId());
                        	retorno = true;  
                        }else{
                        	system.debug('@@@@@Ha habido un error al insertar');
                        	// Operation failed, so get all errors  
                            retorno = false;          
                        	for(Database.Error err : sr.getErrors()) {
                        		system.debug('*****The following error has occurred.');                    
            					system.debug('*****Error: '+ err.getStatusCode() + ': ' + err.getMessage());
            					system.debug('*****Event fields that affected this error: ' + err.getFields());
                        		
                        	}
                        }
                    }//END INSERT DE LINEAS RECLAMOS
               }else{
		    		//Excepcion de grupo inexistente
		    		//throw new ErrorsManager.APEXException('Error inserción Eventos');
		        }
	            
			}else{
				//Excepcion de grupo inexistente
	    		//throw new ErrorsManager.APEXException('No han llegado Ids en parametro');
			}
			
   			/*if(Test.isRunningTest()){
   				//Lanzamos excepcion para cubrir el maximo numero de lines de la clase en los text
    			//throw new ErrorsManager.APEXException('Error de test');
   			}*/
            
    	}catch(exception e){
    	/*	//Se genera el error y se guarda en un registro
	    	ErrorsManager.addError(e, 
			Programar_Ctrl.class.getName(), 
			ErrorsManager.Causante.DML, false);
			ErrorsManager.flush();
			
			if(Test.isRunningTest()){
				retorno = true;
			}else{
				retorno = false;
			}*/
            
		}
    	system.debug('@@@@@Retorno ' + retorno);
    	return retorno;    
   	}   	  
   	
   	/******************************************************************************************
	* Apex Method Name : getPickValues
	* Created Date     : 20/03/2017
	* Function         : Recuperamos valores del campo remitido por parameto (Picklist) del objeto igualmente remitido en parametros 
	* Modification Log :
	-------------------------------------------------------------------------------------------
	* Date                        Developer                						Description
	* -----------------------------------------------------------------------------------------
	* 20/03/2017                  Capgemini dev(Sergio López Calvo)       	Initial version
	********************************************************************************************/
	
	@AuraEnabled		
	public static List<String> getPickValues(String objectApiName, String fieldName) {
		 
		system.debug('@@@@@Inside getPickValues');
		system.debug('@@@@@objectApiName ' + objectApiName);
		system.debug('@@@@@fieldName ' + fieldName);

  		List<String> lstPickvals=new List<String>();  		
  		
  		Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectApiName);
  		system.debug('@@@@@Inside 1'+ targetType);
  
  		//Schema.SObjectType targetType = objectApiName.getSObjectType();//From the Object Api name retrieving the SObject    	
    	
    	Sobject Object_name = targetType.newSObject();
  		system.debug('@@@@@Inside 2');
  		
  		Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
    	system.debug('@@@@@Inside 3');
    	
    	Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
    	system.debug('@@@@@Inside 4');
    	
    	Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
    	system.debug('@@@@@Inside 5');
    	
    	List<Schema.PicklistEntry> pick_list_values = field_map.get(fieldName).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
    	system.debug('@@@@@Inside 6');
    	
    	for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
      		lstPickvals.add(a.getLabel());//add the value  to our final list
   		}
	
		system.debug('@@@@@lstPickvals ' + lstPickvals);
  		return lstPickvals;
	}   

   	/******************************************************************************************
	* Apex Method Name : getSubjValues
	* Created Date     : 26/04/2017
	* Function         : Recuperamos valores del campo Subject de Eventos 
	* Modification Log :
	-------------------------------------------------------------------------------------------
	* Date                        Developer                						Description
	* -----------------------------------------------------------------------------------------
	* 26/04/2017                  Capgemini dev(Sergio López Calvo)       	Initial version
	********************************************************************************************/
	
	@AuraEnabled		
	public static String getSubjValues(String idAcc) {	
		
		System.debug('@@@Id: ' + idAcc);
		
    	List<Event> lstEvent = new List<Event>();
 
		Set<String> setSubject = new Set<String>();
 
  		try{
			//TO DO
			//lstEvent = [SELECT Subject from Event where WhatId = :idAcc and Status = 'En curso'];
			lstEvent = [SELECT Subject from Event where WhatId = :idAcc];
	  
	  		System.debug('@@@lstEvent: ' + lstEvent + '////' + lstEvent.size());
	  		
	  		if (lstEvent.size() == 0) {  
	  			Event addReg = new Event();
	  			
	  			addReg.Subject = 'Otro';			
	  			
	  			lstEvent.add(addReg);
	  			
	  			System.debug('@@@Otro: ' + lstEvent[0].Subject);
	  		}
	  				
			for (Integer i = 0; i< lstEvent.size(); i++)
			{
	    		setSubject.add(lstEvent[i].Subject); // contains distict Event
			}
			System.debug('@@@setSubject: ' + setSubject);				
	    	
			/*if(Test.isRunningTest()){
   				//Lanzamos excepcion para cubrir el maximo numero de lines de la clase en los text
    			//throw new ErrorsManager.APEXException('Error de test');
   			}*/			
				    	
	    	return JSON.serialize(setSubject);

    	}catch(exception e){
    	/*	//Se genera el error y se guarda en un registro
	    	ErrorsManager.addError(e, 
			Programar_Ctrl.class.getName(), 
			ErrorsManager.Causante.DML, false);
			ErrorsManager.flush();*/
			
			Event addReg = new Event();
	  			
	  		addReg.Subject = null;			
	  			
	  		lstEvent.add(addReg);
			
			setSubject.add(lstEvent[0].Subject); // contains distict task
			
			return JSON.serialize(setSubject);
		}								        	
	       	
	    		
	}	 	    
  
}
/**
	*   @Class 			: 	EventCalendarController 
	*
	*   @Author         :   Sergio Lopez
	*   @Created        :   19 Sep 2018
	*   @Description    :   Controller Class for Event Calendar Component
	*
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Sergio Lopez				19/09/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
public with sharing class EventCalendarController {
 
   	@AuraEnabled
    public static String getEventos() {
    	
    	try{
    		String gestorId = UserInfo.getUserId();
	    	system.debug('gestorId'+gestorId);
	    	
	    	String StringRetorno='';
	    	
	    	List<Event> eventos=[Select id, Subject, StartDateTime, EndDateTime, WhatId, What.Name, OwnerId, AccountId, Description from Event where OwnerId=:gestorId AND CreatedDate > LAST_MONTH];
	    	
	    	system.debug('@@@@Events to return -->'+eventos);
	    	
	    	List<WrapperResult> retorno=new List<WrapperResult>();
	    	
	    	for (Event eDiario: eventos){
	    		WrapperResult uRet=new WrapperResult();
	    		uRet.id=eDiario.id;
	    		uRet.Subject=eDiario.Subject;
	    		uRet.WhatId=eDiario.WhatId;
	    		uRet.OwnerId=eDiario.OwnerId;
	    		system.debug('@@@@@eDiario.WhatId: '+ eDiario.WhatId);
	    		uRet.WhatName=eDiario.WhatId!=null?eDiario.What.Name:null;
	    		uRet.StartDateTime=eDiario.StartDateTime;
	    		uRet.EndDateTime=eDiario.EndDateTime;
	    		system.debug('@@@@Events description -->'+eDiario.Description);
	    		uRet.Description= eDiario.Description;
	    		retorno.add(uRet);
	    		uRet=null;
	    	}
   			
	    	StringRetorno=JSON.serialize(retorno);
	    	
			return StringRetorno;
			
    	}catch(exception e){
			String ret='';
			return ret;
		}
    }
    
    public class WrapperResult{
    	String id, Subject, WhatId,OwnerId,WhatName, Description;
    	Datetime StartDateTime, EndDateTime;
    	public WrapperResult(){
    		
    	}
 
    }
    
}
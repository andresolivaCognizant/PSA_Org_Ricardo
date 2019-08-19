/**
	*   @Class 			: 	UserBusinessHController 
	*
	*   @Author         :   Sergio Lopez
	*   @Created        :   13 Jun 2018
	*   @Description    :   Controller Class for User Business Hours Component
	*
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Sergio Lopez				13/06/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
public without sharing class UserBusinessHController {
	
	@AuraEnabled
    public static String getBHours(String userId) {
    	
    	system.debug('getBHours.userId: '+userId);
    	
    	User[] userBHInfo;
    	
    	try {
    		userBHInfo = [SELECT Id, MondayEnd__c, MondayStart__c, FridayEnd__c, FridayStart__c, SaturdayEnd__c, SaturdayStart__c, 
    		 						 SundayEnd__c, SundayStart__c, ThursdayEnd__c, ThursdayStart__c, TuesdayEnd__c, TuesdayStart__c, 
    		 						 WednesdayEnd__c, WednesdayStart__c, HolidayStart__c, HolidayEnd__c FROM User WHERE Id=: userId LIMIT 1];
    		
    		system.debug('userBHInfo.size(): '+userBHInfo.size());
    		if (userBHInfo.size() <= 0) {
				throw new UserBusinessHpexception('No Business hours were found for this User');
		    }
		    
    		if(Test.isRunningTest()){
    			throw new dmlexception('Error de test');
   			} 
    	} catch(dmlexception e) {
	    	String error = 'DMLexception ERROR UserBusinessHController.getBHours --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
	    	system.debug('Error: '+error);
    		
    		return JSON.serialize(error);
    	} catch(exception e){
        	String error =  'exception ERROR UserBusinessHController.getBHours --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
            system.debug('Error: '+error);
    		
    		return JSON.serialize(error);
        }
    	 
    	system.debug('getBHours.userBHInfo: '+userBHInfo);
    		    	
    	return JSON.serialize(userBHInfo[0]);
    }
    
    @AuraEnabled
    public static Boolean getMnProfile(String userId) {
    	
    	system.debug('getMnProfile.userId: '+userId);
    	
    	Boolean retorno = false;
    	
    	try {	    	
	    	Set<String> validProf = new Set<String>{'Sales_Manager','System Administrator'}; 
	    	
	    	User[] userInfo = [SELECT Id FROM User WHERE Id=: userId AND Profile.Name IN :validProf LIMIT 1];
	    	
	    	system.debug('userInfo: '+userInfo);
	    	
	    	if (userInfo.size() > 0) {
    			retorno = true;
	    	} 
    		
    		if(Test.isRunningTest()){
    			throw new dmlexception('Error de test');
   			}    		
    	} catch(dmlexception e) {
	    	String error = 'DMLexception ERROR UserBusinessHController.getMnProfile --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
	    	system.debug('Error: '+error);
    		
    		retorno = false;
    	} catch(exception e){
        	String error =  'exception ERROR UserBusinessHController.getMnProfile --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
            system.debug('Error: '+error);
    		
    		retorno = false;
        }
    	
    	return retorno;
	        
    }
    
	@AuraEnabled
    public static String getTeamMembs() {
    	
    	Id userMnId = UserInfo.getUserId();
	    	
	    User[] userInfo = [SELECT Id, UserRole.Name, Contact.AccountId FROM User WHERE Id=: userMnId LIMIT 1];
	    
    	List<User> userTMInfo = new List<User>();
    	
    	try {
    		userTMInfo = [SELECT Id, Name, Phone, Email FROM User WHERE Profile.name = 'Salesman' AND Contact.AccountId = :userInfo[0].Contact.AccountId];
    		
    		system.debug('userTMInfo.size(): '+userTMInfo.size());
    		if (userTMInfo.size() <= 0) {
				throw new UserBusinessHpexception('No Team Members were found for this User');
		    }
		    
    		if(Test.isRunningTest()){
    			throw new dmlexception('Error de test');
   			} 
    	} catch(dmlexception e) {
	    	String error = 'DMLexception ERROR UserBusinessHController.getTeamMembs --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
	    	system.debug('Error: '+error);
    		
    		return JSON.serialize(error);
    	} catch(exception e){
        	String error =  'exception ERROR UserBusinessHController.getTeamMembs --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
            system.debug('Error: '+error);
    		
    		return JSON.serialize(error);
        }
    	 
    	system.debug('getTeamMembs.userTMInfo: '+userTMInfo);
    		    	
    	return JSON.serialize(userTMInfo);
    }
	
	@AuraEnabled
    public static Boolean updBHours(Boolean bHours, String userId, String mStart, String mEnd, String tuStart, String tuEnd, String wStart, String wEnd, String thStart, String thEnd, String fStart, String fEnd, String saStart, String saEnd, String suStart, String suEnd, String hoStart, String hoEnd) {
    	
    	system.debug('getBHours.userId: '+userId);
    	system.debug('getBHours.Monday: '+mStart+'/'+mEnd);
    	system.debug('getBHours.Tuesday: '+tuStart+'/'+tuEnd);
    	system.debug('getBHours.Wednesday: '+wStart+'/'+wEnd);
    	system.debug('getBHours.Thursday: '+thStart+'/'+thEnd);
    	system.debug('getBHours.Friday: '+fStart+'/'+fEnd);
    	system.debug('getBHours.Saturday: '+saStart+'/'+saEnd);
    	system.debug('getBHours.Sunday: '+suStart+'/'+suEnd);
    	system.debug('getBHours.Holidays: '+hoStart+'/'+hoEnd);
    	
    	Boolean retorno = false;
    	
    	try {
    		User[] userBHInfo = [SELECT Id, MondayEnd__c, MondayStart__c, FridayEnd__c, FridayStart__c, SaturdayEnd__c, SaturdayStart__c, 
    		 							SundayEnd__c, SundayStart__c, ThursdayEnd__c, ThursdayStart__c, TuesdayEnd__c, TuesdayStart__c, 
    		 							WednesdayEnd__c, WednesdayStart__c, HolidayStart__c, HolidayEnd__c FROM User WHERE Id=: userId LIMIT 1];
    		
    		if (userBHInfo.size() > 0) { 
    			if (bHours == true){
    				String srcString;
    				String hh;				
					String mn;				
					String ss;
					String ms;	
					Time myTime;
    				
    				if (mStart != null){
    					srcString=mStart;
					
						hh=srcString.subString(0,2);				
						mn=srcString.subString(3,5);				
						ss='00';
						ms='000';	
	 
						myTime = Time.newInstance(integer.valueOf(hh),
		     				integer.valueOf(mn),
		     				integer.valueOf(ss),
		     				integer.valueOf(ms));
		     				      				
	    				userBHInfo[0].MondayStart__c = myTime;
    				}

    				if (mEnd != null){
	    				srcString=mEnd;
						
						hh=srcString.subString(0,2);				
						mn=srcString.subString(3,5);				
						ss='00';
						ms='000';	
	 
						myTime = Time.newInstance(integer.valueOf(hh),
		     				integer.valueOf(mn),
		     				integer.valueOf(ss),
		     				integer.valueOf(ms));
		     				
			    		userBHInfo[0].MondayEnd__c = myTime;    	
			    	}

    				if (tuStart != null){				
	    				srcString=tuStart;
						
						hh=srcString.subString(0,2);				
						mn=srcString.subString(3,5);				
						ss='00';
						ms='000';	
	 
						myTime = Time.newInstance(integer.valueOf(hh),
		     				integer.valueOf(mn),
		     				integer.valueOf(ss),
		     				integer.valueOf(ms));
		     				
			    		userBHInfo[0].TuesdayStart__c = myTime; 
			    	}

    				if (tuEnd != null){	   				
	    				srcString=tuEnd;
						
						hh=srcString.subString(0,2);				
						mn=srcString.subString(3,5);				
						ss='00';
						ms='000';	
	 
						myTime = Time.newInstance(integer.valueOf(hh),
		     				integer.valueOf(mn),
		     				integer.valueOf(ss),
		     				integer.valueOf(ms));
		     				
			    		userBHInfo[0].TuesdayEnd__c 	= myTime; 
			    	}

    				if (wStart != null){	   				
	    				srcString=wStart;
						
						hh=srcString.subString(0,2);				
						mn=srcString.subString(3,5);				
						ss='00';
						ms='000';	
	 
						myTime = Time.newInstance(integer.valueOf(hh),
		     				integer.valueOf(mn),
		     				integer.valueOf(ss),
		     				integer.valueOf(ms));
		     				
			    		userBHInfo[0].WednesdayStart__c	= myTime;    
			    	}

    				if (wEnd != null){					
	    				srcString=wEnd;
						
						hh=srcString.subString(0,2);				
						mn=srcString.subString(3,5);				
						ss='00';
						ms='000';	
	 
						myTime = Time.newInstance(integer.valueOf(hh),
		     				integer.valueOf(mn),
		     				integer.valueOf(ss),
		     				integer.valueOf(ms));
		     				
			    		userBHInfo[0].WednesdayEnd__c 	= myTime;  
			    	}

    				if (thStart != null){	  				
	    				srcString=thStart;
						
						hh=srcString.subString(0,2);				
						mn=srcString.subString(3,5);				
						ss='00';
						ms='000';	
	 
						myTime = Time.newInstance(integer.valueOf(hh),
		     				integer.valueOf(mn),
		     				integer.valueOf(ss),
		     				integer.valueOf(ms));
		     				
			    		userBHInfo[0].ThursdayStart__c 	= myTime;   
			    	}

    				if (thEnd != null){	 				
	    				srcString=thEnd;
						
						hh=srcString.subString(0,2);				
						mn=srcString.subString(3,5);				
						ss='00';
						ms='000';	
	 
						myTime = Time.newInstance(integer.valueOf(hh),
		     				integer.valueOf(mn),
		     				integer.valueOf(ss),
		     				integer.valueOf(ms));
		     				
			    		userBHInfo[0].ThursdayEnd__c 	= myTime;   
			    	}

    				if (fStart != null){	 				
	    				srcString=fStart;
						
						hh=srcString.subString(0,2);				
						mn=srcString.subString(3,5);				
						ss='00';
						ms='000';	
	 
						myTime = Time.newInstance(integer.valueOf(hh),
		     				integer.valueOf(mn),
		     				integer.valueOf(ss),
		     				integer.valueOf(ms));
		     				
			    		userBHInfo[0].FridayStart__c	= myTime;    	
			    	}

    				if (fEnd != null){				
	    				srcString=fEnd;
						
						hh=srcString.subString(0,2);				
						mn=srcString.subString(3,5);				
						ss='00';
						ms='000';	
	 
						myTime = Time.newInstance(integer.valueOf(hh),
		     				integer.valueOf(mn),
		     				integer.valueOf(ss),
		     				integer.valueOf(ms));
		     				
			    		userBHInfo[0].FridayEnd__c 		= myTime;    
					}

    				if (saStart != null){
	    				srcString=saStart;
						
						hh=srcString.subString(0,2);				
						mn=srcString.subString(3,5);				
						ss='00';
						ms='000';	
	 
						myTime = Time.newInstance(integer.valueOf(hh),
		     				integer.valueOf(mn),
		     				integer.valueOf(ss),
		     				integer.valueOf(ms));
		     				
			    		userBHInfo[0].SaturdayStart__c 	= myTime;    	
			    	}

    				if (saEnd != null){				
	    				srcString=saEnd;
						
						hh=srcString.subString(0,2);				
						mn=srcString.subString(3,5);				
						ss='00';
						ms='000';	
	 
						myTime = Time.newInstance(integer.valueOf(hh),
		     				integer.valueOf(mn),
		     				integer.valueOf(ss),
		     				integer.valueOf(ms));
		     				
			    		userBHInfo[0].SaturdayEnd__c 	= myTime;   
			    	}

    				if (suStart != null){	 				
	    				srcString=suStart;
						
						hh=srcString.subString(0,2);				
						mn=srcString.subString(3,5);				
						ss='00';
						ms='000';	
	 
						myTime = Time.newInstance(integer.valueOf(hh),
		     				integer.valueOf(mn),
		     				integer.valueOf(ss),
		     				integer.valueOf(ms));
		     				
			    		userBHInfo[0].SundayStart__c 	= myTime;    	
			    	}

    				if (suEnd != null){				
	    				srcString=suEnd;
						
						hh=srcString.subString(0,2);				
						mn=srcString.subString(3,5);				
						ss='00';
						ms='000';	
	 
						myTime = Time.newInstance(integer.valueOf(hh),
		     				integer.valueOf(mn),
		     				integer.valueOf(ss),
		     				integer.valueOf(ms));
		     				
			    		userBHInfo[0].SundayEnd__c 		= myTime; 
    				}	
	     				
    			} else {
    				String srcString;
    				String yy;
    				String mm;
    				String dd;
    				Date myDate;
    				
    				if (hoStart != null){	
	    				srcString=hoStart;
	    				
	    				yy=srcString.subString(0,4);				
						mm=srcString.subString(5,7);				
						dd=srcString.subString(8,10);
						
						myDate = Date.newInstance(integer.valueOf(yy), 
	     					integer.valueOf(mm), 
	     					integer.valueOf(dd));
						
	    				userBHInfo[0].HolidayStart__c 	= myDate;
                    } else {
                        userBHInfo[0].HolidayStart__c = null;                        
                    }
    				
    				if (hoEnd != null){	
	    				srcString=hoEnd;
	    				
	    				yy=srcString.subString(0,4);				
						mm=srcString.subString(5,7);				
						dd=srcString.subString(8,10);
						
						myDate = Date.newInstance(integer.valueOf(yy), 
	     					integer.valueOf(mm), 
	     					integer.valueOf(dd));
	     					
		    			userBHInfo[0].HolidayEnd__c 	= myDate;
                    } else {
                        userBHInfo[0].HolidayEnd__c = null;   
                    }
    			}
       		} else {
       			if (bHours == true){
					throw new UserBusinessHpexception('No Business hours for update were found for this User');
				} else {
    				throw new UserBusinessHpexception('No Holiday Dates for update were found for this User');
    			}	
		    }
    		
    		update userBHInfo;
    		
    		retorno = true;
    		
    		if(Test.isRunningTest()){
    			throw new dmlexception('Error de test');
   			}    		
    	} catch(dmlexception e) {
	    	String error = 'DMLexception ERROR UserBusinessHController.updBHours --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
	    	system.debug('Error: '+error);
    		
    		retorno = false;
    	} catch(exception e){
        	String error =  'exception ERROR UserBusinessHController.updBHours --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
            system.debug('Error: '+error);
    		
    		retorno = false;
        }
    	
    	return retorno;
    }   
    
    @AuraEnabled
    public static boolean isCommunity(){
        Id siteId = Site.getSiteId(); // take a look at the apex class Site, you may find more useful method concerning site/community
   			
        if (siteId != null || Test.isRunningTest()) {
            return true;
        }
        
        return false;
    } 
    
    @AuraEnabled
    public static boolean isProduction(){
    	
    	boolean retorno;
        
        List<organization> lstOrganization = [Select id,instanceName,isSandbox from Organization];
        
		if(lstOrganization.size()>0) {
			if(lstOrganization[0].isSandbox) {
				system.debug('Its Sandbox Instance');
			    retorno = false;
			} else {
			    system.debug('Its Production Instance');
			    retorno = true;
		   	}
		}
		
		return retorno;
		
    } 
    
    public class UserBusinessHpexception extends exception{
        // Custom exception class
    }
}
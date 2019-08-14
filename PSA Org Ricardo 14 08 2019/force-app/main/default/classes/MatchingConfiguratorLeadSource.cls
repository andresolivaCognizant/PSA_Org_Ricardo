/**
	*   @Class : MatchingConfiguratorLeadSource.cls
	*
	*   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
	*   @Created        :   25 05 2018
	*   @Description    :   Match leads with Email field of Accounts when the Lead Source is 329.
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description
	*	   Rubén Moreno				25/05/2018				 Creation.		
	*	   Rubén Moreno				26/06/2018				 Add Nurturing status if the account is not found.	
	*   ----------------------------------------------------------------------------------------------------------------------------
**/

public class MatchingConfiguratorLeadSource {
     
    public static void mainProcess(List<Lead> lLeads){
        Set<String> setEmails 			= new Set<String>();
        map<String,Lead> mapEmailLead 	= new map<String,Lead>();
        list<Lead> lLeadToCreate		= new list<Lead>();
        set<String> setEmailFound		= new set<String>();
        
        for(Lead oLead: lLeads){
            if(oLead.Email!=null){
                setEmails.add(oLead.Email);
            	mapEmailLead.put(oLead.Email,oLead);
            }
            
        }
        
        for(Account oAccount : [SELECT id,PersonEmail,OwnerId FROM Account WHERE isPersonAccount = true AND PersonEmail IN : setEmails]){
            if(mapEmailLead.get(oAccount.PersonEmail) != null){
                mapEmailLead.get(oAccount.PersonEmail).Customer__c 	= oAccount.id;
            	mapEmailLead.get(oAccount.PersonEmail).Status 		= 'Nurturing';
           		mapEmailLead.get(oAccount.PersonEmail).OwnerId 		= oAccount.OwnerId;
                setEmailFound.add(oAccount.PersonEmail);
            }
        }
            
        for(Lead oLead: lLeads){
            
            if(!setEmailFound.contains(oLead.Email))
                oLead.OwnerId = Label.API_USER;
            	oLead.Status  = 'Nurturing';
            
		}
	}

}
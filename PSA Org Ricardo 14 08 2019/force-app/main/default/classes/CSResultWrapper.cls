global with sharing class CSResultWrapper {

/*@
@ - Name         : CSResultWrapper
@ - Author       : DXC
@ - Date         : 18/01/2018
@ - Description  : This apex class is a sObject records wrapper for a 
@ - lightning table
@ -
@ - History:
@ Date         Author  Version  Comments
@ -----------  -----   -------  ---------------------------------------
@ 18/01/2018   DXC     1.0    	 Initial version rfernandezlo
@*/

    @AuraEnabled
    public Integer page { get;set; }

    @AuraEnabled
    public Integer total { get;set; }
    
	@AuraEnabled
    public Integer pageEnd { get;set; }
    
    @AuraEnabled
    public List<sObject> sObjectrecords { get;set; }

    @AuraEnabled
    public Map<Id,Boolean> sObjectrecordAccess { get;set; }
    
}
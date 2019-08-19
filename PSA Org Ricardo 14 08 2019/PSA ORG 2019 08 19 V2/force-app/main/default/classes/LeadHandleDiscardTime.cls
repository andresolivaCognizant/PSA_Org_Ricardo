/*
-- - Name         : LeadHandleDiscardTime
-- - Author       : DXC. Ruben Fernandez
-- - Date         : 09/03/2018
-- - Description  : Manage Lead discard times
--
-- - History:
-- Date         Author  Version  Comments
-- -----------  -----   -------  ---------------------------------------
-- 09/03/2018   DXC     1.0      Initial version rfernandezlo
*/
public with sharing class LeadHandleDiscardTime {
	
	private static Map<String,Integer> mapDiscardTimes = new Map<String,Integer>();
	private static final String DISCARDTIME_SETTING	= 'DiscardTime%';
	
	/* */
	private static void loadDefaultValues(){
		for (LeadDiscardTimeSetting__mdt lVal : [SELECT Days__c,Brand__c,Country__c FROM LeadDiscardTimeSetting__mdt where QualifiedApiName Like :DISCARDTIME_SETTING]){
			mapDiscardTimes.put(lVal.Brand__c + lVal.Country__c, Integer.valueOf(lVal.Days__c));
		}
			
            
	}
	/* */
	public static void handleDiscardTime(List<Lead> lstLeads){
		Date dToday = date.Today();
		loadDefaultValues();
		for(Lead l : lstLeads){
			if( mapDiscardTimes.containsKey(l.PSABrand__c + l.LeadCountry__c)){
				Integer iDays			= mapDiscardTimes.get(l.PSABrand__c + l.LeadCountry__c);
				l.TECH_DiscardTime__c 	= dToday.addDays(iDays);
			}
		}
	}
}
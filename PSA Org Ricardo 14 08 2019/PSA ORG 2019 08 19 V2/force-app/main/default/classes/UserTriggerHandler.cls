/*
*   @Class : UserTriggerHandler
*
*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
*   @Created        :   22 feb 2018
*   @Description    :   To manage user trigger methods

*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Developer            Date                     Description
*	   Raul Barba			22 feb 2018				 Creation.	
*   ----------------------------------------------------------------------------------------------------------------------------
*/
public class UserTriggerHandler {
    
    private static boolean runtrigger = true;
    
    /*
     * @Method          :   shouldRunTrigger
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   22 feb 2018
     * @Description     :   To get the flag that indicate if the trigger should run or not
     * @Params          :   -
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
	public	static	boolean	shouldRunTrigger() {
		return runtrigger;
	}
    
    
    /*
     * @Method          :   dontRunTrigger
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   22 feb 2018
     * @Description     :   To indicate that the trigger should not run
     * @Params          :   -
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
	public	static	void	dontRunTrigger() {
		runtrigger = false;
	}
    
    /*
     * @Method          :   afterInsert
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   22 feb 2018
     * @Description     :   Call the actions that handle the after insert trigger.
     * @Params          :   Map<Id, User> records after the insert.
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
	public static void afterInsert(Map<Id, User> mapUsers) {
        List<User> lUsers = [select id, Profile.Name, Contact.Account.Id, Contact.Account.Country__c, profile.UserLicense.name, IsActive, 
                             Contact.Account.TECH_PublicGroups__c, Contact.Account.TECH_PublicGroupsContract__c, Contact.Account.RecordType.DeveloperName, 
                             Contact.Account.RecordTypeId, Contact.Account.isPartner, Contact.Account.VNPrincipalSite__c, 
                             Contact.Account.TECH_VNContractActive__c, Contact.Account.VNContractNumber__c, 
                             Contact.Account.SiteGeoIdPK__c, Contact.Account.BillingCountry 
                             from User 
                             where id in :mapUsers.keySet()];
        ManagersPublicGroup.PopulatedPublicGroup(lUsers);
        ManagersPublicGroupContract.PopulatedPublicGroup(lUsers);
    }

}
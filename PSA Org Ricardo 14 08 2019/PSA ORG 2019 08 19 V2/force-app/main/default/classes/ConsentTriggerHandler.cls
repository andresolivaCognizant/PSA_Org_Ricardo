/*
*   @Class : ConsentTriggerHandler
*
*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
*   @Created        :   16 feb 2018
*   @Description    :   To manage consent trigger methods

*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Developer            Date                     Description
*	   Raul Barba			16 feb 2018				 Creation.	
*   ----------------------------------------------------------------------------------------------------------------------------
*/
public class ConsentTriggerHandler {

    private static boolean runtrigger = true;
    
    
    /*
     * @Method          :   shouldRunTrigger
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   16 feb 2018
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
	 * @Created         :   16 feb 2018
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
	 * @Created         :   16 feb 2018
     * @Description     :   Call the actions that handle the after insert trigger.
     * @Params          :   List<Consent__c> records after the insert.
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
	public static void afterInsert(List<Consent__c> lConsents) {
        ConsentToContactability.handleonAfterInsert(lConsents);
	}
    
    /*
     * @Method          :   beforeInsert
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   06 April 2018
     * @Description     :   Call the actions that handle the before insert trigger.
     * @Params          :   List<Consent__c> records before the insert.
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
	public static void beforeInsert(List<Consent__c> lConsents) {
		Map<id, Consent__c> mContactConsent = new Map<id, Consent__c>();
        for(Consent__c con : lConsents){
            if(con.TECH_AccountId__c == null){
                mContactConsent.put(con.Contact__c, con);
            }
        }
        List<Contact> lContact = [select id, AccountId from contact where id in:mContactConsent.keyset()];
        for(Contact cont : lContact){
        	mContactConsent.get(cont.id).TECH_AccountId__c = cont.AccountId;
        }
	}
    
}
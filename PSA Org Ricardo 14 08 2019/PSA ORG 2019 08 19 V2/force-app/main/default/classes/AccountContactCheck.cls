/*
*   @Class : AccountContactCheck
*
*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
*   @Created        :   21 March 2018
*   @Description    :   To create the relationship between the contact populated in the 
						lead field customer contact and the account populated in the lead field customer

*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Developer            Date                     Description
*	   Raul Barba			21 March 2018				 Creation.	
*   ----------------------------------------------------------------------------------------------------------------------------
*/
public class AccountContactCheck {
    
    /*
     * @Method          :   generateRelations
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   21 March 2018
     * @Description     :   create relation between the contact populated in the 
							lead field customer contact and the account populated in the lead field customer.
     * @Params          :   List<Lead> 
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
	public static void generateRelations(List<Lead> lLead) {
        List<AccountContactRelation> lrelation = new List<AccountContactRelation>();
        for(Lead lead : lLead){
            if(lead.Customer__c != null && lead.CustomerContact__c != null){
                lrelation.add(getRelation(lead.Customer__c, lead.CustomerContact__c));
            }
        }
        
        Database.DMLOptions dml = new Database.DMLOptions();
		dml.DuplicateRuleHeader.AllowSave = true; 
        Database.insert(lrelation, dml);
    }
    
    
    /*
     * @Method          :   getRelation
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   21 March 2018
     * @Description     :   create relation between a contact and an account.
     * @Params          :   List<Lead> 
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
	public static AccountContactRelation getRelation(Id account, Id contact) {
        AccountContactRelation acr = new AccountContactRelation(); 
        acr.Accountid = account;
        acr.Contactid = contact;
            
        return acr;
    }

}
/*
*   @Class : Standardized
*
*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
*   @Created        :   06 march 2018
*   @Description    :   For Standardized fields

*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Developer            Date                     Description
*	   Raul Barba			06 march 2018			  Creation.	
*      C1STRUN2210          10 june  2019             Evolution of removeAccent to standarizeString and include a standardization of CorporateName__c
*   ----------------------------------------------------------------------------------------------------------------------------
*/
public class Standardized {
    
    /*
     * @Method          :   accountB2C
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   06 feb 2018
     * @Description     :   Standardized account B2C.
     * @Params          :   Account for standardized.
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
	public static void accountB2C(Account acc) {
        if(acc.FirstName != null){
            acc.StandardizedFirstName__pc = GeneralUtils.standarizeString(acc.FirstName);
        }
        if(acc.LastName != null){
           acc.StandardizedLastName__pc = GeneralUtils.standarizeString(acc.LastName);
        }  
    }
    
    /*
     * @Method          :   accountNotB2C
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   06 feb 2018
     * @Description     :   Standardized account B2B and Dealer.
     * @Params          :   Account for standardized.
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */	
	public static void accountNotB2C(Account acc) {
        
        
        // Standarized company name
        if(acc.Name != null){
           acc.StandardizedCompanyName__c = GeneralUtils.standarizeString(acc.Name);            
        }
        
        /* C1STRUN-2210 MODIFICATION - Standarize the CorporateName__c */
        // Standarized corporate name
        if(acc.CorporateName__c == null){
            if (acc.StandardizedCompanyName__c != null){
                acc.StandardizedCorporateName__c = acc.StandardizedCompanyName__c;
            }else{
                acc.StandardizedCorporateName__c = '';
            }
        }else{
            acc.StandardizedCorporateName__c = GeneralUtils.standarizeString(acc.CorporateName__c);
            
        }
        /* END OF THE RUN MODIFICATION */

    }
    
    /*
     * @Method          :   contact
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   06 feb 2018
     * @Description     :   Standardized contact.
     * @Params          :   contact for standardized.
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
	public static void contact(Contact con) {
        if(con.FirstName != null){
           con.StandardizedFirstName__c = GeneralUtils.standarizeString(con.FirstName);
        }
        if(con.LastName != null){
            con.StandardizedLastName__c = GeneralUtils.standarizeString(con.LastName);
        } 
    }
}
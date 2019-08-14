/*-----------------------------------------------------------------------------------------------------------//
  * Class Name    : EmailMessageConstants
  * Project       : PSA - C1ST
  * Author        : Ruben Fernandez
  * Date          : 04/25/2019
  * Description   : Class for EmailMessage Constants
  *
  *-----------------------------------------------------------------------------------------------------------
  *      Modification Log :
  *-----------------------------------------------------------------------------------------------------------
  *      Developer               Date                   Description    
  *      Ruben Fernandez         04/25/2019             Creation.     
  *-----------------------------------------------------------------------------------------------------------*/

public class EmailMessageConstants {
    
    //Email Address Values
    public static final String ADDRESS_CITROEN  					= 'citroen';
    public static final String ADDRESS_DSAUTOMOBILES      = 'dsautomobiles';
    public static final String ADDRESS_PEUGEOT  					= 'peugeot';
    
    // OWA Domain
    public static final String OWA_EMAIL_DOMAIN           = '@my-customerportal.com';
    public static final String OWA_EMAIL_DOMAIN_FILTER    = (Test.isRunningTest())?'%@%':'%@my-customerportal.com';

    //Case Brand Values
    public static final String CASE_BRAND_CITROEN 		    = 'AC';
    public static final String CASE_BRAND_DSAUTOMOBILES 	= 'DS';
    public static final String CASE_BRAND_PEUGEOT 	      = 'AP';
    
}
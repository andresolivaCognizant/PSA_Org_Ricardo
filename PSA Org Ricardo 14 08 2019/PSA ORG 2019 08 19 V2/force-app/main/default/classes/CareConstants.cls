/*-----------------------------------------------------------------------------------------------------------//
  * Class Name    : CareConstants
  * Project       : PSA - C1ST
  * Author        : Carmen Hernandez     <carmen.diazhernandez@ext.mpsa.com>
  * Date          : 04/23/2019
  * Description   : Class for Care Constants
  *
  *-----------------------------------------------------------------------------------------------------------
  *      Modification Log :
  *-----------------------------------------------------------------------------------------------------------
  *      Developer                Date                     Description    
  *      Carmen Hernandez         04/23/2019               Creation.     
  *-----------------------------------------------------------------------------------------------------------*/
public class CareConstants {
    
    public static final String CASE_OBJECT_NAME						= 'Case';
    public static final String CASE_ASSIGNMENT_RULE_FO				= 'Case_FO_Assignation';
    
    //Case Origin Picklist Values
    public static final String CASE_ORIGIN_PHONE					= '1';
    public static final String CASE_ORIGIN_CHAT						= '2';    
    public static final String CASE_ORIGIN_WEBFORM					= '3';  
    public static final String CASE_ORIGIN_SOCIAL_NETWORK			= '4';        
    public static final String CASE_ORIGIN_EMAIL					= '5';    
    public static final String CASE_ORIGIN_LETTER					= '6'; 
    public static final String CASE_ORIGIN_WEB						= 'Web';
    
    //Case Status Picklist Values
    public static final String CASE_STATUS_OPEN						= '1';
    public static final String CASE_STATUS_TAKEN_INTO_ACCOUNT		= '2';
	public static final String CASE_STATUS_CUSTOMER_WAITING			= '3';
    public static final String CASE_STATUS_BUSINESS_WAITING			= '4';
    public static final String CASE_STATUS_POS_WAITING				= '5';
    public static final String CASE_STATUS_UPDATED_BY				= '6';
    public static final String CASE_STATUS_CLOSED					= '7';
    public static final String CASE_STATUS_REOPENED					= '8';
    public static final String CASE_STATUS_LOCKED					= '9';
    
    //Case Reason Picklist Values
    public static final String CASE_REASON_INFORMATION_REQUEST 		= '1';
    public static final String CASE_REASON_COMPLAINT 				= '2';
    public static final String CASE_REASON_COMMERCIAL_INFORMATION 	= '3';
    public static final String CASE_REASON_OTHER					= '4';
    public static final String CASE_REASON_DEALER					= '5';
    public static final String CASE_REASON_APINAME					= 'Reason';
    
    //Case Categories Values
    public static final String CASE_CATEGORYL1_SAVING_PLAN_FI		= '1038';
    
    //Close Reason L1 Values
    public static final String CASE_CLOSE_REASONL1_INF_REQUEST		= '94';
    
    //Close Reason L2 Values
    public static final String CASE_CLOSE_REASONL2_REPLIED_KB		= '2000';
    
	//About Consents
	public static final String CONSENT_TYPE_WEBFORM					= 'WebForm';
	public static final String CONSENT_PURPOSE_SURVEY				= 'Marketing&survey';
	public static final String CONSENT_BRAND_EMAIL					= 'MkgBrandEmail';
	public static final String CONSENT_BRAND_PHONE					= 'MkgBrandPhoneSMS';
    
    //Util get values from Case picklists
    public static final String KEY_PICKLIST_COUNTRY					= 'COUNTRY';
    public static final String KEY_PICKLIST_BRAND					= 'BRAND';
    public static final String COUNTRY_FIELD						= 'Country__c';
    public static final String BRAND_FIELD							= 'Brand__c';

    //Others
    public static final String GUEST_USER_LICENSE					= 'Guest User License';
    public static final String GUEST_USER							= 'guest';
    public static final String ANONYMOUS 							= 'ANONYMOUS';
    public static final String BH_SAVING_PLAN_AR					= '-PLAN-AHORRO';
    public static final String BH_CEC								= 'CEC-';
}
/*-----------------------------------------------------------------------------------------------------------//
  * Class Name    : AccountConstants
  * Project       : PSA - C1ST
  * Author        : Ruben Fernandez     <carmen.diazhernandez@ext.mpsa.com>
  * Date          : 06/01/2019
  * Description   : Class for Account Constants
  *
  *-----------------------------------------------------------------------------------------------------------
  *      Modification Log :
  *-----------------------------------------------------------------------------------------------------------
  *      Developer                Date                     Description    
  *      Ruben Fernandez          06/01/2019               Creation.     
  *-----------------------------------------------------------------------------------------------------------*/
public with sharing class AccountConstants {
    //Account Type Picklist Values
    public final static String ACCOUNT_TYPE_PROSPECT        = 'Prospect';
    public final static String ACCOUNT_TYPE_CUSTOMER        = 'Customer';
    public final static String ACCOUNT_TYPE_OLDCUSTOMER     = 'OldCustomer';
    //Account Source Picklist Values
    public final static String ACCOUNT_SOURCE_VISITSHOW     = 'Visit Showroom';
    //Account Status Picklist Values
    public final static String ACCOUNT_STATUS_ANONYMISED    = 'Anonymised';

    // Account Record Types Ids
    public final static Id ACCOUNT_RT_B2C                    = PAD.getRecordTypeIdByDeveloperName('Account','PersonAccount_B2C');
    public final static Id ACCOUNT_RT_B2B                    = PAD.getRecordTypeIdByDeveloperName('Account','Account_B2B');
    public final static Id ACCOUNT_RT_DEALER                 = PAD.getRecordTypeIdByDeveloperName('Account','Account_DealerPartner'); 

    //User Values
    public final static String USER_COUNTRY_CL               = 'CL';
    public final static String USER_COUNTRY_PT               = 'PT';
}
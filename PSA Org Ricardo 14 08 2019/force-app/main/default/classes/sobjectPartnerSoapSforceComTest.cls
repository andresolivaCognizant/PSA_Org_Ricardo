/**
 * Salesforce
 * @author              Antoine Audollent(aaudollent@salesforce.com)
 * Project:             PSA - Customer First
 * Description:         Unit tests to validate the behavior of partnerSoapSforceCom class.
 *
 * Changes (version)
 * -------------------------------------------------------------------------------------------------
 *              No.     Date            Author                  Description
 *              ----    ------------    --------------------    ------------------------------------
 * @version     1.0     2019-04-02      Antoine Audollent       Class creation. Code coverage: 100%.
 *
 */
@isTest
private class sobjectPartnerSoapSforceComTest {
    static testMethod void test_sObject_x(){
        new sobjectPartnerSoapSforceCom.sObject_x('Holiday', null, null, null, null, null, null, null, null, null, null, null, null, null);
		new sobjectPartnerSoapSforceCom.sObject_x('Holiday', null, null, null, null, null, null);
        new sobjectPartnerSoapSforceCom.sObject_x('BusinessHours' ,null ,null ,null ,null ,null ,null ,null ,null ,null ,null ,null ,null ,null ,null ,null ,null ,null , null);
        new sobjectPartnerSoapSforceCom.sObject_x('BusinessHours' ,null ,null ,null ,null ,null ,null ,null ,null ,null ,null ,null ,null ,null ,null ,null ,null ,null ,null , null);
    }
}
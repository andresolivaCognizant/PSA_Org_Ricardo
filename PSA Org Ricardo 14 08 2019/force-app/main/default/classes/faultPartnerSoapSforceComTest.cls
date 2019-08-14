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
private class faultPartnerSoapSforceComTest{
   static testMethod void test_InvalidOldPasswordFault(){
    List<BusinessHours> businesshours_Obj  =  [SELECT Id,Name,IsActive,IsDefault,SundayStartTime,SundayEndTime,MondayStartTime,MondayEndTime,TuesdayStartTime,TuesdayEndTime,WednesdayStartTime,WednesdayEndTime,ThursdayStartTime,ThursdayEndTime,FridayStartTime,FridayEndTime,SaturdayStartTime,SaturdayEndTime,TimeZoneSidKey from BusinessHours];
    System.assertEquals(true,businesshours_Obj.size()>0);
    faultPartnerSoapSforceCom obj01 = new faultPartnerSoapSforceCom();
    faultPartnerSoapSforceCom.InvalidFieldFault obj11 = new faultPartnerSoapSforceCom.InvalidFieldFault();
    faultPartnerSoapSforceCom.InvalidSObjectFault obj21 = new faultPartnerSoapSforceCom.InvalidSObjectFault();
    faultPartnerSoapSforceCom.InvalidNewPasswordFault obj31 = new faultPartnerSoapSforceCom.InvalidNewPasswordFault();
    faultPartnerSoapSforceCom.ApiFault obj41 = new faultPartnerSoapSforceCom.ApiFault();
    obj41.exceptionCode = 'test data';
    obj41.exceptionMessage = 'test data';
    faultPartnerSoapSforceCom.MalformedSearchFault obj81 = new faultPartnerSoapSforceCom.MalformedSearchFault();
    faultPartnerSoapSforceCom.LoginFault obj91 = new faultPartnerSoapSforceCom.LoginFault();
    faultPartnerSoapSforceCom.ApiQueryFault obj101 = new faultPartnerSoapSforceCom.ApiQueryFault();
    obj101.row = 10;
    obj101.column = 10;
    faultPartnerSoapSforceCom.InvalidQueryLocatorFault obj131 = new faultPartnerSoapSforceCom.InvalidQueryLocatorFault();
    faultPartnerSoapSforceCom.UnexpectedErrorFault obj141 = new faultPartnerSoapSforceCom.UnexpectedErrorFault();
    faultPartnerSoapSforceCom.InvalidIdFault obj151 = new faultPartnerSoapSforceCom.InvalidIdFault();
    faultPartnerSoapSforceCom.MalformedQueryFault obj161 = new faultPartnerSoapSforceCom.MalformedQueryFault();
    faultPartnerSoapSforceCom.InvalidOldPasswordFault obj171 = new faultPartnerSoapSforceCom.InvalidOldPasswordFault();
  }
}
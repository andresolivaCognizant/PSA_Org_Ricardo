/*
-- - Name         : Constants
-- - Author       : Salesforce Antoine Audollent
-- - Date         : 01/03/2019 
-- - Description  : class containing all constants
--
-- - History:
-- Date         Author          Version  Comments
-- -----------  -----           -------  ---------------------------------------
-- 01/03/2018   AAU             1.0      Initial version 
*/
public class Constants {
    /***************************************************************************************************************************
    *                                          RECORD TYPE DEVELOPER NAME                                                      *
    ****************************************************************************************************************************/
    //All key values od map PAD.recordTypesMapByDeveloperName
    public static final String RT_ACCOUNT_B2B = 'Account_Account_B2B';
    public static final String RT_ACCOUNT_B2C = 'Account_Account_B2C';
    public static final String RT_ACCOUNT_B2C_PA = 'Account_PersonAccount_B2C';
    public static final String RT_ACCOUNT_DEALER = 'Account_Account_DealerPartner';

    public static final String RT_CONTACT_PARTNER_USER = 'Contact_PartnerUser';
    public static final String RT_CONTACT_B2B = 'Contact_B2BContact';    

    public static final String RT_LEAD_B2B = 'Lead_B2B';
    public static final String RT_LEAD_B2C = 'Lead_B2C';
    
    public static final String RT_CAMPAIGN_DMCAMPAIGN = 'Campaign_DMCampaign';

    public static final String RT_SBQQ_QUOTE_CPQ_QUOTE = 'SBQQ__Quote__c_CPQ_Quote';
    public static final String RT_SBQQ_QUOTE_CPQ_ORDER_FORM = 'SBQQ__Quote__c_CPQ_Order_Form';
    public static final String RT_SBQQ_QUOTE_OPV_VD = 'SBQQ__Quote__c_OPVOrderFormVD';
    public static final String RT_SBQQ_QUOTE_OPV_VN = 'SBQQ__Quote__c_OPVOrderFormVN';
    public static final String RT_SBQQ_QUOTE_OPV_VO = 'SBQQ__Quote__c_OPV_OrderForm_VO';
    public static final String RT_OPPORTUNITY_FLEET_REQUEST = 'Opportunity_FleetRequestOpportunity';

    /***************************************************************************************************************************
    *                                                    SOBJECT TYPE                                                          *
    ****************************************************************************************************************************/
    public static final String SOT_ACCOUNT = 'Account';
    public static final String SOT_ASSET = 'Asset';
    public static final String SOT_ASSET_RELATION = 'AccountContactAssetRelation__c';
    public static final String SOT_TELE_ALERT = 'TeleAlert__c';
    public static final String SOT_LEAD = 'Lead';
    public static final String SOT_CASE = 'Case';
    public static final String SOT_EMAIL_TEMPLATE = 'EmailTemplate';
    public static final String SOT_USER = 'User';
    public static final String SOT_GROUP = 'Group';
    public static final String SOT_QUEUES_OBJECT = 'QueuesObject';
    public static final String SOT_KNOWLEDGE = 'Knowledge__kav';
    public static final String SOT_CASE_ARTICLE = 'CaseArticle';
    public static final String SOT_TASK = 'Task';
    public static final String SOT_ATTACHMENT = 'Attachment';
    public static final String SOT_SBQQ_QUOTE = 'SBQQ__Quote__c';
    public static final String SOT_ORDER = 'Order';
    public static final String SOT_OPPORTUNITY = 'Opportunity';

    /***************************************************************************************************************************
    *                                          			    BRANDS                                                  *
    ****************************************************************************************************************************/
    public static final String BRAND_CITROEN = 'AC';
    public static final String BRAND_PEUGEOT = 'AP';
    public static final String BRAND_DSAUTOMOBILES = 'DS';
    public static final String BRAND_ALL = 'All';

    /***************************************************************************************************************************
    *                                                       OTHERS                                                             *
    ****************************************************************************************************************************/
    
    //contains api field value, determine if its value must be increment (used in TestDataFactoryUtil.createSobjectList methods)
    public static final list<String> LIST_API_FIELD_TO_INCREMENT = new list<String>{'lastname', 'name'};
    
}
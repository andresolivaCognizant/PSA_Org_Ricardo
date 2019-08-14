/*-----------------------------------------------------------------------------------------------------------//
* Class Name	: SalesConstants
* Project		: PSA - C1ST
* Author		: Ricardo Pereira
* Date			: 10/07/2019
* Description	: Class for Sales Constants
*
*-----------------------------------------------------------------------------------------------------------*/
public with sharing class SalesConstants {

    // Opportunity RecordTypes
    public static final Map<String, Schema.RecordTypeInfo> MAP_OPP_RT = Opportunity.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
    public static final Id OPP_RT_Aftersales_Opportunity = MAP_OPP_RT.get('Aftersales_Opportunity').getRecordTypeId();
	public static final Id OPP_RT_FleetRequestOpportunity = MAP_OPP_RT.get('FleetRequestOpportunity').getRecordTypeId();
	public static final Id OPP_RT_OPV_Quote = MAP_OPP_RT.get('OPV_Quote').getRecordTypeId();
	public static final Id OPP_RT_Opportunity_Record_Type = MAP_OPP_RT.get('Opportunity_Record_Type').getRecordTypeId();
	public static final Id OPP_RT_QuickOpportunity = MAP_OPP_RT.get('QuickOpportunity').getRecordTypeId();

	//SBQQ_Quote__c RecordTypes
	public static final Map<String, Schema.RecordTypeInfo> MAP_SBQQ_QUOTE_RT = SBQQ__Quote__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
	public static final Id SBQQ_QUOTE_RT_CPQ_QUOTE = MAP_SBQQ_QUOTE_RT.get('CPQ_Quote').getRecordTypeId();
	public static final Id SBQQ_QUOTE_RT_OPV_QUOTE = MAP_SBQQ_QUOTE_RT.get('OPV_Quote').getRecordTypeId();
	public static final Id SBQQ_QUOTE_RT_CPQ_ORDER_FORM = MAP_SBQQ_QUOTE_RT.get('CPQ_Order_Form').getRecordTypeId();
	public static final Id SBQQ_QUOTE_RT_OPV_ORDER_FORM_VN = MAP_SBQQ_QUOTE_RT.get('OPVOrderFormVN').getRecordTypeId();
	public static final Id SBQQ_QUOTE_RT_OPV_ORDER_FORM_VD = MAP_SBQQ_QUOTE_RT.get('OPVOrderFormVD').getRecordTypeId();
	// Opportunity.StageName values
	public static final String OPP_STAGE_NEEDS_ANALYSIS = '1';
	public static final String OPP_STAGE_NEGOTIATION = '2';
	public static final String OPP_STAGE_QUOTE = '3';
	public static final String OPP_STAGE_CONTRACT = '4';
	public static final String OPP_STAGE_ORDER = '5';
	public static final String OPP_STAGE_CLOSED_WON = '6';
	public static final String OPP_STAGE_CLOSED_LOST = '7';
	public static final String OPP_STAGE_QUALIFICATION = '8';
	public static final String OPP_STAGE_PROPOSAL = '9';

	//Order.Status Picklist values
	public static final String ORDER_STATUS_CANCELLED = '0';
	public static final String ORDER_STATUS_CUSTOMER_WITHOUT_CAR = '2';
	public static final String ORDER_STATUS_CUSTOMER_WITH_CAR = '3';
	public static final String ORDER_STATUS_VD_INCOMPLETE = '4';
	public static final String ORDER_STATUS_VD_COMPLETE = '8';
	public static final String ORDER_STATUS_DELIVERED = '9';
	
	//Order.Order_Type__c Picklist values
	public static final String ORDER_ORDER_TYPE_VN = 'VN';
	public static final String ORDER_ORDER_TYPE_VO = 'VO';
	public static final String ORDER_ORDER_TYPE_VD = 'VD';

	//SBQQ__Quote.SBQQ__Status__c Picklist values
	public static final String SBQQ_QUOTE_STATUS_DRAFT = '1';
	public static final String SBQQ_QUOTE_STATUS_ACTIVE = '2';
	public static final String SBQQ_QUOTE_STATUS_CONFIG_INTERNET = '3';
	public static final String SBQQ_QUOTE_STATUS_WITH_ORDER = '4';
	public static final String SBQQ_QUOTE_STATUS_WITH_ORDER_FORM = '5';
	public static final String SBQQ_QUOTE_STATUS_EXPIRED = '6';
	public static final String SBQQ_QUOTE_STATUS_CANCELED = '7';
    
    //AccountContactAssetRelation__c.AccountRole__c
    public static final String ACCOUNT_ASSET_RELATIONSHIP_ACCOUNTROLE_OWNER = 'Owner';
    public static final String ACCOUNT_ASSET_RELATIONSHIP_ACCOUNTROLE_KEEPER = 'Keeper';
    public static final String ACCOUNT_ASSET_RELATIONSHIP_ACCOUNTROLE_DRIVER = 'Driver';
    public static final String ACCOUNT_ASSET_RELATIONSHIP_ACCOUNTROLE_OLDOWNER = 'OldOwner';
    public static final String ACCOUNT_ASSET_RELATIONSHIP_ACCOUNTROLE_OLDDRIVER = 'OldDriver';
    public static final String ACCOUNT_ASSET_RELATIONSHIP_ACCOUNTROLE_OLDKEEPER = 'OldKeeper';

	//Task.Type
	public static final String TASK_TYPE_APPEL = 'Appel';
	public static final String TASK_TYPE_REUNION = 'Réunion';
	public static final String TASK_TYPE_Autre = 'Autre';

	//Task.Priority__c
	public static final String TASK_PRIORITY_HIGH = 'High';
	public static final String TASK_PRIORITY_NORMAL = 'Normal';
	public static final String TASK_PRIORITY_LOW = 'Low';

	// Task.Status
	public static final String TASK_STATUS_0 = '0';
	
	// Task.CallStatus__c
	public static final String TASK_CALLSTATUS_1 = '1';
}
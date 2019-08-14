/*-----------------------------------------------------------------------------------------------------------//
* Class Name	: FlowOppTypeInputController
* Project		: PSA - C1ST
* Author		: Ricardo Pereira
* Date			: 03/07/2019
* Description	: This class provides functionality to Aura component FlowOppTypeInput
*
* @Aura 
*               1. getTypeOptions			Change records owner
*               2. getOpportunityOptions	GetUser List Views for a specific sObject
* @Private
*               1.
*-----------------------------------------------------------------------------------------------------------*/
public class FlowOppTypeInputController{

	/*********************************************************************************************************
	* @Method			:	getTypeOptions
	* @Author			:	Ricardo Pereira
	* @Created			:	03/07/2019
	* @Description		:	Retrieves all quote types available for a certain country.
	* @params			:	String. Related country.
	* @Returns			:	List of Combobox options ready to use containing the available types.
	**********************************************************************************************************/
	@AuraEnabled
	public static List<ComboboxOption> getTypeOptions(String country){

		List<ComboboxOption> lstTypeOptions = new List<ComboboxOption>();

		String tempCountrySearch = '%' + country + '%';

		for(UtilSetting__mdt setting: [SELECT Value__c FROM UtilSetting__mdt 
									WHERE DeveloperName LIKE 'QuoteType%'
									AND Value2__c LIKE :tempCountrySearch]){

			lstTypeOptions.add(new ComboboxOption(setting.Value__c));

		}

		return lstTypeOptions;
	}
	
	/*********************************************************************************************************
	* @Method			:	getOpportunityOptions
	* @Author			:	Ricardo Pereira
	* @Created			:	03/07/2019
	* @Description		:	Retrieves all opportunities of the selected type related to an Account.
	* @params			:	String. Related account.
	* @params			:	String. Opportunity type.
	* @Returns			:	List of Combobox options ready to use containing the available opportunities.
	**********************************************************************************************************/
	@AuraEnabled
	public static List<ComboboxOption> getOpportunityOptions(String accountId, String type){

		// Get current user VNContractNumber
		String VNContractNumber = ''; 
		List<User> lstCurrentUser = [SELECT Account.VNContractNumber__c FROM User
									WHERE Id = :UserInfo.getUserId()];
		if(lstCurrentUser != null && !lstCurrentUser.isEmpty() 
			&& lstCurrentUser[0].Account != null && lstCurrentUser[0].Account.VNContractNumber__c != null){

			VNContractNumber = lstCurrentUser[0].Account.VNContractNumber__c;
		}
		
		// Retrieve opportunities
		List<ComboboxOption> lstOppOptions = new List<ComboboxOption>();

		lstOppOptions.add(new ComboboxOption('', 'No One'));

		for(Opportunity opp: [SELECT Id, Name FROM Opportunity 
									WHERE AccountId = :accountId
									AND Activity__c = :type
									AND IsSamePartner__c = true
									AND VNContractNumber__c = :VNContractNumber
									AND RecordTypeId = :SalesConstants.OPP_RT_Opportunity_Record_Type
									AND StageName NOT IN (:SalesConstants.OPP_STAGE_CONTRACT,
															:SalesConstants.OPP_STAGE_ORDER,
															:SalesConstants.OPP_STAGE_CLOSED_WON,
															:SalesConstants.OPP_STAGE_CLOSED_LOST,
															:SalesConstants.OPP_STAGE_QUALIFICATION,
															:SalesConstants.OPP_STAGE_PROPOSAL)
									]){

			lstOppOptions.add(new ComboboxOption(opp.Id, opp.Name));

		}

		return lstOppOptions;
	}


	/*-----------------------------------------------------------------------------------------------------------//
	* Class Name	: FlowOppTypeInputController.ComboboxOption
	* Project		: PSA - C1ST
	* Author		: Ricardo Pereira
	* Date			: 03/07/2019
	* Description	: Wrapper that implements the structure of a single option for lightning:combobox
	*-----------------------------------------------------------------------------------------------------------*/
	public class ComboboxOption{
		@AuraEnabled public String value;
		@AuraEnabled public String label;

		public ComboboxOption(String value, String label){
			this.value = value;
			this.label = label;
		}
		
		public ComboboxOption(String value){
			this.value = value;
			this.label = value;
		}

	}
}
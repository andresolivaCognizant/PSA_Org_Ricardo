@isTest
private class PSA_CPQ_Custom_SearchTest {

	@TestSetup
	static void makeData(){

			Account account = TestDataFactoryUtil.createAccount(new map<String, Object>{
					'FirstName'								=> 'Account FirstName',
					'LastName'								=> 'Account LastName',
					'Salutation'							=> '1',
					'PersonalEmail__pc'				=> 'testaccB2C@test.com',
					'TECH_CreatedFromLead__c'	=> true,
					'SiteGeoIdPK__c'					=> '0000000000',
					'CompanyActivityType__c'	=> '0',
					'Country__c'							=> 'FR',
					'RecordTypeId'						=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA)
				}, true);
		
			Opportunity opportunity = TestDataFactoryUtil.createOpportunities(new map<String, Object>{
					'Name'	  			=>	'opportunity name', 
					'StageName'   	=> 'FR1',
					'AccountId'     => account.id,
					'CloseDate'     => System.today(),
					'Activity__c'   => 'VN',
					'Country__c'    => 'es',
					'Segment__c'		=> '27',
					'FundingForm__c'=> '1',
					'RecordTypeId'	=> PAD.recordTypesMapByDeveloperName.get(Constants.RT_OPPORTUNITY_FLEET_REQUEST)
				}, true);

			Pricebook2 price2 = new Pricebook2(
				Name = 'Peugeot Chile');
			insert price2;

			Product2 product2 = new 	Product2(
				Name = 'Name');

			insert product2;

			Id pricebookId = Test.getStandardPricebookId();

			SBQQ__Quote__C quotes = TestDataFactoryUtil.createSbqqQuote(new map<String, Object>{
					'SBQQ__PricebookId__c'	=> pricebookId,
					'SBQQ__Opportunity2__c' => opportunity.id,
					'ProtocolAccountID__c'  => account.id
				} ,true);

				//}
		
	}
	
	@isTest static void global_test_01() {

				SBQQ__Quote__c sbquote = [SELECT id, SBQQ__PricebookId__c  from SBQQ__Quote__c limit 1];

				Map<String,Object> fieldValuesMap = new Map<String,Object>();
				fieldValuesMap.put('id', sbquote);

				Test.startTest();
				PSA_CPQ_Custom_Search custom = new PSA_CPQ_Custom_Search();
				custom.isFilterHidden(null, null);
				String filter = custom.getFilterDefaultValue(null, null);
				Boolean search = custom.isSearchCustom(null, null);
				String add = custom.getAdditionalSearchFilters(null, null);
				Boolean suggest = custom.isSuggestCustom(null, null);
				Boolean input = custom.isInputHidden(null, null);
				String defaul = custom.getInputDefaultValue(null, null);
				String sugg = custom.getAdditionalSuggestFilters(null, null);

				List<PricebookEntry> list_price = custom.search(sbquote, fieldValuesMap);
				List<PricebookEntry> lst_price_two = custom.suggest(sbquote, fieldValuesMap);


				Test.stopTest();

		
	}



}
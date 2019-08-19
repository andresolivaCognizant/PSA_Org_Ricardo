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
 * @version     1.0     2019-04-01      Antoine Audollent       Class creation. Code coverage: 100%.
 *
 */
@isTest
private class partnerSoapSforceComTest {
    @isTest
    static void coverTypes() {
        new partnerSoapSforceCom.InvalidateSessionsResult();

        new partnerSoapSforceCom.describePrimaryCompactLayoutsResponse_element();
        new partnerSoapSforceCom.changeOwnPassword_element();
        new partnerSoapSforceCom.DescribeAppMenuResult();
        new partnerSoapSforceCom.DescribeColor();
        new partnerSoapSforceCom.MergeResult();
        new partnerSoapSforceCom.describeDataCategoryGroupStructures_element();
        new partnerSoapSforceCom.queryResponse_element();
        new partnerSoapSforceCom.CallOptions_element();
        new partnerSoapSforceCom.SaveResult();
        new partnerSoapSforceCom.describeDataCategoryGroups_element();
        new partnerSoapSforceCom.ExtendedErrorDetails();
        new partnerSoapSforceCom.upsert_element();
        new partnerSoapSforceCom.updateResponse_element();
        new partnerSoapSforceCom.MergeRequest();
        new partnerSoapSforceCom.RecordTypeInfo();
        new partnerSoapSforceCom.sendEmailResponse_element();
        new partnerSoapSforceCom.DescribeRelatedContentItem();
        new partnerSoapSforceCom.describeSObjectsResponse_element();
        new partnerSoapSforceCom.DescribeQuickActionResult();
        new partnerSoapSforceCom.JunctionIdListNames();
        new partnerSoapSforceCom.UpsertResult();
        new partnerSoapSforceCom.deleteByExampleResponse_element();
        new partnerSoapSforceCom.describeQuickActionsResponse_element();
        new partnerSoapSforceCom.LeadConvert();
        new partnerSoapSforceCom.RenderEmailTemplateError();
        new partnerSoapSforceCom.DescribeAvailableQuickActionResult();
        new partnerSoapSforceCom.EmptyRecycleBinResult();
        new partnerSoapSforceCom.RenderStoredEmailTemplateRequest();
        new partnerSoapSforceCom.SingleEmailMessage();
        new partnerSoapSforceCom.DescribeSearchScopeOrderResult();
        new partnerSoapSforceCom.DescribeSoftphoneScreenPopOption();
        new partnerSoapSforceCom.describeSearchScopeOrder_element();
        new partnerSoapSforceCom.create_element();
        new partnerSoapSforceCom.LimitInfoHeader_element();
        new partnerSoapSforceCom.describeDataCategoryMappingsResponse_element();
        new partnerSoapSforceCom.MassEmailMessage();
        new partnerSoapSforceCom.renderStoredEmailTemplateResponse_element();
        new partnerSoapSforceCom.NameCaseValue();
        new partnerSoapSforceCom.describeApprovalLayout_element();
        new partnerSoapSforceCom.SetPasswordResult();
        new partnerSoapSforceCom.retrieveQuickActionTemplates_element();
        new partnerSoapSforceCom.retrieve_element();
        new partnerSoapSforceCom.DeleteResult();
        new partnerSoapSforceCom.SearchLayoutField();
        new partnerSoapSforceCom.DescribeQuickActionDefaultValue();
        new partnerSoapSforceCom.describePrimaryCompactLayouts_element();
        new partnerSoapSforceCom.describeGlobalThemeResponse_element();
        new partnerSoapSforceCom.query_element();
        new partnerSoapSforceCom.describeLayout_element();
        new partnerSoapSforceCom.describeSObjectListViewsResponse_element();
        new partnerSoapSforceCom.DescribeVisualForceResult();
        new partnerSoapSforceCom.DescribeSoftphoneLayoutInfoField();
        new partnerSoapSforceCom.DebuggingHeader_element();
        new partnerSoapSforceCom.PackageVersion();
        new partnerSoapSforceCom.DataCategoryGroupSobjectTypePair();
        new partnerSoapSforceCom.SearchRecord();
        new partnerSoapSforceCom.DescribeLayoutButtonSection();
        new partnerSoapSforceCom.AllOrNoneHeader_element();
        new partnerSoapSforceCom.DescribeSoftphoneLayoutResult();
        new partnerSoapSforceCom.describeDataCategoryMappings_element();
        new partnerSoapSforceCom.LocaleOptions_element();
        new partnerSoapSforceCom.DescribeDataCategoryMappingResult();
        new partnerSoapSforceCom.DescribeLayoutSaveOption();
        new partnerSoapSforceCom.describeSearchLayoutsResponse_element();
        new partnerSoapSforceCom.UserTerritoryDeleteHeader_element();
        new partnerSoapSforceCom.FindDuplicatesResult();
        new partnerSoapSforceCom.describeSearchLayouts_element();
        new partnerSoapSforceCom.address();
        new partnerSoapSforceCom.sendEmail_element();
        new partnerSoapSforceCom.LogInfo();
        new partnerSoapSforceCom.DeletedRecord();
        new partnerSoapSforceCom.emptyRecycleBin_element();
        new partnerSoapSforceCom.SearchResult();
        new partnerSoapSforceCom.DescribeColumn();
        new partnerSoapSforceCom.describeLayoutResponse_element();
        new partnerSoapSforceCom.login_element();
        new partnerSoapSforceCom.undelete_element();
        new partnerSoapSforceCom.ChangeOwnPasswordResult();
        new partnerSoapSforceCom.DescribeCompactLayoutsResult();
        new partnerSoapSforceCom.DescribeDataCategoryGroupStructureResult();
        new partnerSoapSforceCom.GetUserInfoResult();
        new partnerSoapSforceCom.EmailFileAttachment();
        new partnerSoapSforceCom.sendEmailMessageResponse_element();
        new partnerSoapSforceCom.findDuplicates_element();
        new partnerSoapSforceCom.getServerTimestamp_element();
        new partnerSoapSforceCom.Email();
        new partnerSoapSforceCom.DescribeIcon();
        new partnerSoapSforceCom.executeListView_element();
        new partnerSoapSforceCom.deleteByExample_element();
        new partnerSoapSforceCom.loginResponse_element();
        new partnerSoapSforceCom.QueryOptions_element();
        new partnerSoapSforceCom.describeGlobalResponse_element();
        new partnerSoapSforceCom.RenderEmailTemplateBodyResult();
        new partnerSoapSforceCom.EmailHeader_element();
        new partnerSoapSforceCom.getServerTimestampResponse_element();
        new partnerSoapSforceCom.findDuplicatesByIdsResponse_element();
        new partnerSoapSforceCom.ReportChartComponent();
        new partnerSoapSforceCom.DescribeQuickActionListItemResult();
        new partnerSoapSforceCom.describeAvailableQuickActionsResponse_element();
        new partnerSoapSforceCom.describeSObjects_element();
        new partnerSoapSforceCom.undeleteResponse_element();
        new partnerSoapSforceCom.describePathAssistantsResponse_element();
        new partnerSoapSforceCom.OwnerChangeOptions_element();
        new partnerSoapSforceCom.DescribeLayoutItem();
        new partnerSoapSforceCom.describeAppMenuResponse_element();
        new partnerSoapSforceCom.resetPasswordResponse_element();
        new partnerSoapSforceCom.Canvas();
        new partnerSoapSforceCom.ProcessResult();
        new partnerSoapSforceCom.RelatedListColumn();
        new partnerSoapSforceCom.findDuplicatesResponse_element();
        new partnerSoapSforceCom.queryMoreResponse_element();
        new partnerSoapSforceCom.FieldLevelSearchMetadata();
        new partnerSoapSforceCom.MatchRecord();
        new partnerSoapSforceCom.SoqlSubQueryCondition();
        new partnerSoapSforceCom.describeGlobal_element();
        new partnerSoapSforceCom.DescribeApprovalLayoutResult();
        new partnerSoapSforceCom.describeApprovalLayoutResponse_element();
        new partnerSoapSforceCom.DescribeLayoutSection();
        new partnerSoapSforceCom.setPasswordResponse_element();
        new partnerSoapSforceCom.ActionOverride();
        new partnerSoapSforceCom.processResponse_element();
        new partnerSoapSforceCom.DescribeGlobalResult();
        new partnerSoapSforceCom.sendEmailMessage_element();
        new partnerSoapSforceCom.searchResponse_element();
        new partnerSoapSforceCom.DescribeLayoutResult();
        new partnerSoapSforceCom.changeOwnPasswordResponse_element();
        new partnerSoapSforceCom.DescribePathAssistant();
        new partnerSoapSforceCom.AdditionalInformationMap();
        new partnerSoapSforceCom.FilteredLookupInfo();
        new partnerSoapSforceCom.MatchResult();
        new partnerSoapSforceCom.DescribeCompactLayout();
        new partnerSoapSforceCom.CurrencyConversionHeader_element();
        new partnerSoapSforceCom.Field();
        new partnerSoapSforceCom.invalidateSessionsResponse_element();
        new partnerSoapSforceCom.describeSoftphoneLayoutResponse_element();
        new partnerSoapSforceCom.PicklistEntry();
        new partnerSoapSforceCom.DescribeSearchLayoutResult();
        new partnerSoapSforceCom.AllowFieldTruncationHeader_element();
        new partnerSoapSforceCom.mergeResponse_element();
        new partnerSoapSforceCom.DescribeSoqlListViewParams();
        new partnerSoapSforceCom.ExecuteListViewRequest();
        new partnerSoapSforceCom.DescribePathAssistantField();
        new partnerSoapSforceCom.DescribeDataCategoryGroupResult();
        new partnerSoapSforceCom.DescribeThemeItem();
        new partnerSoapSforceCom.RenderStoredEmailTemplateResult();
        new partnerSoapSforceCom.DebuggingInfo_element();
        new partnerSoapSforceCom.describeAllTabsResponse_element();
        new partnerSoapSforceCom.DescribeSObjectResult();
        new partnerSoapSforceCom.deleteResponse_element();
        new partnerSoapSforceCom.LeadConvertResult();
        new partnerSoapSforceCom.KnowledgeSettings();
        new partnerSoapSforceCom.LoginScopeHeader_element();
        new partnerSoapSforceCom.update_element();
        new partnerSoapSforceCom.ChildRelationship();
        new partnerSoapSforceCom.RelatedList();
        new partnerSoapSforceCom.ChangeEventHeader();
        new partnerSoapSforceCom.describeNouns_element();
        new partnerSoapSforceCom.location();
        new partnerSoapSforceCom.renderEmailTemplate_element();
        new partnerSoapSforceCom.DuplicateRuleHeader_element();
        new partnerSoapSforceCom.SearchSnippet();
        new partnerSoapSforceCom.DataCategory();
        new partnerSoapSforceCom.DescribeAppMenuItem();
        new partnerSoapSforceCom.ProcessSubmitRequest();
        new partnerSoapSforceCom.describeNounsResponse_element();
        new partnerSoapSforceCom.DeleteByExampleResult();
        new partnerSoapSforceCom.SoqlConditionGroup();
        new partnerSoapSforceCom.describeSObjectListViews_element();
        new partnerSoapSforceCom.DescribeLayout();
        new partnerSoapSforceCom.ListViewOrderBy();
        new partnerSoapSforceCom.SearchResultsMetadata();
        new partnerSoapSforceCom.resetPassword_element();
        new partnerSoapSforceCom.describeSObject_element();
        new partnerSoapSforceCom.getDeleted_element();
        new partnerSoapSforceCom.RenderEmailTemplateResult();
        new partnerSoapSforceCom.describeSoqlListViews_element();
        new partnerSoapSforceCom.invalidateSessions_element();
        new partnerSoapSforceCom.describeVisualForce_element();
        new partnerSoapSforceCom.FieldDiff();
        new partnerSoapSforceCom.DescribeSoqlListViewsRequest();
        new partnerSoapSforceCom.describeAppMenu_element();
        new partnerSoapSforceCom.describeQuickActionsForRecordType_element();
        new partnerSoapSforceCom.describeDataCategoryGroupsResponse_element();
        new partnerSoapSforceCom.SessionHeader_element();
        new partnerSoapSforceCom.retrieveMassQuickActionTemplatesResponse_element();
        new partnerSoapSforceCom.ResetPasswordResult();
        new partnerSoapSforceCom.DescribePathAssistantStep();
        new partnerSoapSforceCom.setPassword_element();
        new partnerSoapSforceCom.DescribeQuickActionListResult();
        new partnerSoapSforceCom.GetUpdatedResult();
        new partnerSoapSforceCom.ExecuteListViewResult();
        new partnerSoapSforceCom.merge_element();
        new partnerSoapSforceCom.RelatedListSort();
        new partnerSoapSforceCom.search_element();
        new partnerSoapSforceCom.DuplicateError();
        new partnerSoapSforceCom.describeTabsResponse_element();
        new partnerSoapSforceCom.SendEmailResult();
        new partnerSoapSforceCom.MruHeader_element();
        new partnerSoapSforceCom.createResponse_element();
        new partnerSoapSforceCom.describeVisualForceResponse_element();
        new partnerSoapSforceCom.logout_element();
        new partnerSoapSforceCom.GetServerTimestampResult();
        new partnerSoapSforceCom.retrieveQuickActionTemplatesResponse_element();
        new partnerSoapSforceCom.QueryResult();
        new partnerSoapSforceCom.delete_element();
        new partnerSoapSforceCom.DescribeSoqlListViewResult();
        new partnerSoapSforceCom.GetDeletedResult();
        new partnerSoapSforceCom.DescribeNounResult();
        new partnerSoapSforceCom.EntitySpellCorrectionMetadata();
        new partnerSoapSforceCom.queryMore_element();
        new partnerSoapSforceCom.SearchLayoutFieldsDisplayed();
        new partnerSoapSforceCom.emptyRecycleBinResponse_element();
        new partnerSoapSforceCom.PicklistForRecordType();
        new partnerSoapSforceCom.DescribeLayoutFeedView();
        new partnerSoapSforceCom.describeCompactLayoutsResponse_element();
        new partnerSoapSforceCom.StringList();
        new partnerSoapSforceCom.RecordTypeMapping();
        new partnerSoapSforceCom.convertLead_element();
        new partnerSoapSforceCom.StreamingEnabledHeader_element();
        new partnerSoapSforceCom.AnalyticsCloudComponent();
        new partnerSoapSforceCom.RelatedContent();
        new partnerSoapSforceCom.SearchLayoutButton();
        new partnerSoapSforceCom.PerformQuickActionRequest();
        new partnerSoapSforceCom.DuplicateResult();
        new partnerSoapSforceCom.getUserInfo_element();
        new partnerSoapSforceCom.DescribeTab();
        new partnerSoapSforceCom.LabelsSearchMetadata();
        new partnerSoapSforceCom.describeQuickActionsForRecordTypeResponse_element();
        new partnerSoapSforceCom.EntitySearchPromotionMetadata();
        new partnerSoapSforceCom.process_element();
        new partnerSoapSforceCom.DescribeTabSetResult();
        new partnerSoapSforceCom.DescribeSearchableEntityResult();
        new partnerSoapSforceCom.LoginResult();
        new partnerSoapSforceCom.describeKnowledgeSettings_element();
        new partnerSoapSforceCom.LimitInfo();
        new partnerSoapSforceCom.EntityIntentQueryMetadata();
        new partnerSoapSforceCom.describeSoftphoneLayout_element();
        new partnerSoapSforceCom.renderStoredEmailTemplate_element();
        new partnerSoapSforceCom.describeThemeResponse_element();
        new partnerSoapSforceCom.performQuickActionsResponse_element();
        new partnerSoapSforceCom.QuickActionTemplateResult();
        new partnerSoapSforceCom.DescribeSoqlListView();
        new partnerSoapSforceCom.upsertResponse_element();
        new partnerSoapSforceCom.describeDataCategoryGroupStructuresResponse_element();
        new partnerSoapSforceCom.retrieveResponse_element();
        new partnerSoapSforceCom.convertLeadResponse_element();
        new partnerSoapSforceCom.getDeletedResponse_element();
        new partnerSoapSforceCom.describeSearchableEntities_element();
        new partnerSoapSforceCom.RenderEmailTemplateRequest();
        new partnerSoapSforceCom.describeCompactLayouts_element();
        new partnerSoapSforceCom.getUserInfoResponse_element();
        new partnerSoapSforceCom.describeKnowledgeSettingsResponse_element();
        new partnerSoapSforceCom.findDuplicatesByIds_element();
        new partnerSoapSforceCom.renderEmailTemplateResponse_element();
        new partnerSoapSforceCom.queryAll_element();
        new partnerSoapSforceCom.SearchRecordMetadata();
        new partnerSoapSforceCom.executeListViewResponse_element();
        new partnerSoapSforceCom.RecordTypesSupported();
        new partnerSoapSforceCom.NamedLayoutInfo();
        new partnerSoapSforceCom.describeAllTabs_element();
        new partnerSoapSforceCom.retrieveMassQuickActionTemplates_element();
        new partnerSoapSforceCom.PackageVersionHeader_element();
        new partnerSoapSforceCom.DescribeSoftphoneLayoutSection();
        new partnerSoapSforceCom.performQuickActions_element();
        new partnerSoapSforceCom.getUpdated_element();
        new partnerSoapSforceCom.DisableFeedTrackingHeader_element();
        new partnerSoapSforceCom.DescribeLayoutFeedFilter();
        new partnerSoapSforceCom.describeSearchableEntitiesResponse_element();
        new partnerSoapSforceCom.EntitySearchMetadata();
        new partnerSoapSforceCom.DescribeLayoutButton();
        new partnerSoapSforceCom.DescribeGlobalSObjectResult();
        new partnerSoapSforceCom.DescribeSoftphoneLayoutItem();
        new partnerSoapSforceCom.ProcessRequest();
        new partnerSoapSforceCom.NameObjectValuePair();
        new partnerSoapSforceCom.ListViewRecordColumn();
        new partnerSoapSforceCom.AssignmentRuleHeader_element();
        new partnerSoapSforceCom.describeQuickActions_element();
        new partnerSoapSforceCom.DescribePathAssistantsResult();
        new partnerSoapSforceCom.describeAvailableQuickActions_element();
        new partnerSoapSforceCom.SoqlCondition();
        new partnerSoapSforceCom.DescribeApprovalLayout();
        new partnerSoapSforceCom.describeTabs_element();
        new partnerSoapSforceCom.SearchLayoutButtonsDisplayed();
        new partnerSoapSforceCom.SendEmailError();
        new partnerSoapSforceCom.VisualforcePage();
        new partnerSoapSforceCom.ProcessWorkitemRequest();
        new partnerSoapSforceCom.describeSearchScopeOrderResponse_element();
        new partnerSoapSforceCom.describeTheme_element();
        new partnerSoapSforceCom.RelationshipReferenceTo();
        new partnerSoapSforceCom.NameValuePair();
        new partnerSoapSforceCom.describeSoqlListViewsResponse_element();
        new partnerSoapSforceCom.OwnerChangeOption();
        new partnerSoapSforceCom.FieldComponent();
        new partnerSoapSforceCom.DescribeThemeResult();
        new partnerSoapSforceCom.DescribeLayoutRow();
        new partnerSoapSforceCom.DescribeSoftphoneLayoutCallType();
        new partnerSoapSforceCom.Error();
        new partnerSoapSforceCom.ScopeInfo();
        new partnerSoapSforceCom.RecordTypeCompactLayoutMapping();
        new partnerSoapSforceCom.CustomLinkComponent();
        new partnerSoapSforceCom.DescribeGlobalTheme();
        new partnerSoapSforceCom.SoqlWhereCondition();
        new partnerSoapSforceCom.PerformQuickActionResult();
        new partnerSoapSforceCom.KnowledgeLanguageItem();
        new partnerSoapSforceCom.describePathAssistants_element();
        new partnerSoapSforceCom.logoutResponse_element();
        new partnerSoapSforceCom.getUpdatedResponse_element();
        new partnerSoapSforceCom.ListViewColumn();
        new partnerSoapSforceCom.SoqlNotCondition();
        new partnerSoapSforceCom.UndeleteResult();
        new partnerSoapSforceCom.describeSObjectResponse_element();
        new partnerSoapSforceCom.DescribeLayoutComponent();
        new partnerSoapSforceCom.FieldLayoutComponent();
        new partnerSoapSforceCom.ListViewRecord();
        new partnerSoapSforceCom.queryAllResponse_element();
        new partnerSoapSforceCom.describeGlobalTheme_element();

    }

    @isTest
    static void coverMethods(){
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        new partnerSoapSforceCom.Soap().describeAllTabs();
        new partnerSoapSforceCom.Soap().describeDataCategoryGroupStructures(null, null);
        new partnerSoapSforceCom.Soap().describeDataCategoryGroups(null);
        new partnerSoapSforceCom.Soap().findDuplicates(null);
        new partnerSoapSforceCom.Soap().process(null);
        new partnerSoapSforceCom.Soap().describeGlobal();
        new partnerSoapSforceCom.Soap().getUserInfo();
        new partnerSoapSforceCom.Soap().describeGlobalTheme();
        new partnerSoapSforceCom.Soap().describeApprovalLayout(null, null);
        new partnerSoapSforceCom.Soap().describePrimaryCompactLayouts(null);
        new partnerSoapSforceCom.Soap().queryMore(null);
        new partnerSoapSforceCom.Soap().describeSearchableEntities(null);
        new partnerSoapSforceCom.Soap().describeLayout(null, null, null);
        new partnerSoapSforceCom.Soap().describeAppMenu(null, null);
        new partnerSoapSforceCom.Soap().convertLead(null);
        new partnerSoapSforceCom.Soap().describeSObjectListViews(null, null, null, null, null);
        new partnerSoapSforceCom.Soap().delete_x(null);
        new partnerSoapSforceCom.Soap().login(null, null);
        new partnerSoapSforceCom.Soap().queryAll(null);
        new partnerSoapSforceCom.Soap().update_x(null);
        new partnerSoapSforceCom.Soap().emptyRecycleBin(null);
        new partnerSoapSforceCom.Soap().describeCompactLayouts(null, null);
        new partnerSoapSforceCom.Soap().changeOwnPassword(null, null);
        new partnerSoapSforceCom.Soap().describeSoqlListViews(null);
        new partnerSoapSforceCom.Soap().describePathAssistants(null, null, null);
        new partnerSoapSforceCom.Soap().describeAvailableQuickActions(null);
        new partnerSoapSforceCom.Soap().getDeleted(null, null, null);
        new partnerSoapSforceCom.Soap().describeTabs();
        new partnerSoapSforceCom.Soap().retrieveMassQuickActionTemplates(null, null);
        new partnerSoapSforceCom.Soap().search_x(null);
        new partnerSoapSforceCom.Soap().sendEmail(null);
        new partnerSoapSforceCom.Soap().getUpdated(null, null, null);
        new partnerSoapSforceCom.Soap().sendEmailMessage(null);
        new partnerSoapSforceCom.Soap().describeQuickActionsForRecordType(null, null);
        new partnerSoapSforceCom.Soap().renderEmailTemplate(null);
        new partnerSoapSforceCom.Soap().upsert_x(null, null);
        new partnerSoapSforceCom.Soap().query(null);
        new partnerSoapSforceCom.Soap().describeQuickActions(null);
        new partnerSoapSforceCom.Soap().performQuickActions(null);
        new partnerSoapSforceCom.Soap().describeSObjects(null);
        new partnerSoapSforceCom.Soap().describeKnowledgeSettings();
        new partnerSoapSforceCom.Soap().undelete_x(null);
        new partnerSoapSforceCom.Soap().retrieve_x(null, null, null);
        new partnerSoapSforceCom.Soap().describeTheme(null);
        new partnerSoapSforceCom.Soap().deleteByExample(null);
        new partnerSoapSforceCom.Soap().describeNouns(null, null, null);
        new partnerSoapSforceCom.Soap().findDuplicatesByIds(null);
        new partnerSoapSforceCom.Soap().executeListView(null);
        new partnerSoapSforceCom.Soap().renderStoredEmailTemplate(null);
        new partnerSoapSforceCom.Soap().describeVisualForce(null, null);
        new partnerSoapSforceCom.Soap().describeSObject(null);
        new partnerSoapSforceCom.Soap().getServerTimestamp();
        new partnerSoapSforceCom.Soap().retrieveQuickActionTemplates(null, null);
        new partnerSoapSforceCom.Soap().setPassword(null, null);
        new partnerSoapSforceCom.Soap().resetPassword(null);
        new partnerSoapSforceCom.Soap().describeSoftphoneLayout();
        new partnerSoapSforceCom.Soap().create(null);
        new partnerSoapSforceCom.Soap().describeSearchLayouts(null);
        new partnerSoapSforceCom.Soap().merge_x(null);
        new partnerSoapSforceCom.Soap().invalidateSessions(null);
        new partnerSoapSforceCom.Soap().describeDataCategoryMappings();
        new partnerSoapSforceCom.Soap().logout();
        new partnerSoapSforceCom.Soap().describeSearchScopeOrder(null);
    }




    //Generic Mock
    private class WebServiceMockImpl implements WebServiceMock
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {
            if(request instanceof partnerSoapSforceCom.describeAllTabs_element)
                response.put('response_x', new partnerSoapSforceCom.describeAllTabsResponse_element());
            else if(request instanceof partnerSoapSforceCom.describeDataCategoryGroupStructures_element)
                response.put('response_x', new partnerSoapSforceCom.describeDataCategoryGroupStructuresResponse_element());
            else if(request instanceof partnerSoapSforceCom.describeDataCategoryGroups_element)
                response.put('response_x', new partnerSoapSforceCom.describeDataCategoryGroupsResponse_element());
            else if(request instanceof partnerSoapSforceCom.findDuplicates_element)
                response.put('response_x', new partnerSoapSforceCom.findDuplicatesResponse_element());
            else if(request instanceof partnerSoapSforceCom.process_element)
                response.put('response_x', new partnerSoapSforceCom.processResponse_element());
            else if(request instanceof partnerSoapSforceCom.describeGlobal_element)
                response.put('response_x', new partnerSoapSforceCom.describeGlobalResponse_element());
            else if(request instanceof partnerSoapSforceCom.getUserInfo_element)
                response.put('response_x', new partnerSoapSforceCom.getUserInfoResponse_element());
            else if(request instanceof partnerSoapSforceCom.describeGlobalTheme_element)
                response.put('response_x', new partnerSoapSforceCom.describeGlobalThemeResponse_element());
            else if(request instanceof partnerSoapSforceCom.describeApprovalLayout_element)
                response.put('response_x', new partnerSoapSforceCom.describeApprovalLayoutResponse_element());
            else if(request instanceof partnerSoapSforceCom.describePrimaryCompactLayouts_element)
                response.put('response_x', new partnerSoapSforceCom.describePrimaryCompactLayoutsResponse_element());
            else if(request instanceof partnerSoapSforceCom.queryMore_element)
                response.put('response_x', new partnerSoapSforceCom.queryMoreResponse_element());
            else if(request instanceof partnerSoapSforceCom.describeSearchableEntities_element)
                response.put('response_x', new partnerSoapSforceCom.describeSearchableEntitiesResponse_element());
            else if(request instanceof partnerSoapSforceCom.describeLayout_element)
                response.put('response_x', new partnerSoapSforceCom.describeLayoutResponse_element());
            else if(request instanceof partnerSoapSforceCom.describeAppMenu_element)
                response.put('response_x', new partnerSoapSforceCom.describeAppMenuResponse_element());
            else if(request instanceof partnerSoapSforceCom.convertLead_element)
                response.put('response_x', new partnerSoapSforceCom.convertLeadResponse_element());
            else if(request instanceof partnerSoapSforceCom.describeSObjectListViews_element)
                response.put('response_x', new partnerSoapSforceCom.describeSObjectListViewsResponse_element());
            else if(request instanceof partnerSoapSforceCom.delete_element)
                response.put('response_x', new partnerSoapSforceCom.deleteResponse_element());
            else if(request instanceof partnerSoapSforceCom.login_element)
                response.put('response_x', new partnerSoapSforceCom.loginResponse_element());
            else if(request instanceof partnerSoapSforceCom.queryAll_element)
                response.put('response_x', new partnerSoapSforceCom.queryAllResponse_element());
            else if(request instanceof partnerSoapSforceCom.update_element)
                response.put('response_x', new partnerSoapSforceCom.updateResponse_element());
            else if(request instanceof partnerSoapSforceCom.emptyRecycleBin_element)
                response.put('response_x', new partnerSoapSforceCom.emptyRecycleBinResponse_element());
            else if(request instanceof partnerSoapSforceCom.describeCompactLayouts_element)
                response.put('response_x', new partnerSoapSforceCom.describeCompactLayoutsResponse_element());
            else if(request instanceof partnerSoapSforceCom.changeOwnPassword_element)
                response.put('response_x', new partnerSoapSforceCom.changeOwnPasswordResponse_element());
            else if(request instanceof partnerSoapSforceCom.describeSoqlListViews_element)
                response.put('response_x', new partnerSoapSforceCom.describeSoqlListViewsResponse_element());
            else if(request instanceof partnerSoapSforceCom.describePathAssistants_element)
                response.put('response_x', new partnerSoapSforceCom.describePathAssistantsResponse_element());
            else if(request instanceof partnerSoapSforceCom.describeAvailableQuickActions_element)
                response.put('response_x', new partnerSoapSforceCom.describeAvailableQuickActionsResponse_element());
            else if(request instanceof partnerSoapSforceCom.getDeleted_element)
                response.put('response_x', new partnerSoapSforceCom.getDeletedResponse_element());
            else if(request instanceof partnerSoapSforceCom.describeTabs_element)
                response.put('response_x', new partnerSoapSforceCom.describeTabsResponse_element());
            else if(request instanceof partnerSoapSforceCom.retrieveMassQuickActionTemplates_element)
                response.put('response_x', new partnerSoapSforceCom.retrieveMassQuickActionTemplatesResponse_element());
            else if(request instanceof partnerSoapSforceCom.search_element)
                response.put('response_x', new partnerSoapSforceCom.searchResponse_element());
            else if(request instanceof partnerSoapSforceCom.sendEmail_element)
                response.put('response_x', new partnerSoapSforceCom.sendEmailResponse_element());
            else if(request instanceof partnerSoapSforceCom.getUpdated_element)
                response.put('response_x', new partnerSoapSforceCom.getUpdatedResponse_element());
            else if(request instanceof partnerSoapSforceCom.sendEmailMessage_element)
                response.put('response_x', new partnerSoapSforceCom.sendEmailMessageResponse_element());
            else if(request instanceof partnerSoapSforceCom.describeQuickActionsForRecordType_element)
                response.put('response_x', new partnerSoapSforceCom.describeQuickActionsForRecordTypeResponse_element());
            else if(request instanceof partnerSoapSforceCom.renderEmailTemplate_element)
                response.put('response_x', new partnerSoapSforceCom.renderEmailTemplateResponse_element());
            else if(request instanceof partnerSoapSforceCom.upsert_element)
                response.put('response_x', new partnerSoapSforceCom.upsertResponse_element());
            else if(request instanceof partnerSoapSforceCom.query_element)
                response.put('response_x', new partnerSoapSforceCom.queryResponse_element());
            else if(request instanceof partnerSoapSforceCom.describeQuickActions_element)
                response.put('response_x', new partnerSoapSforceCom.describeQuickActionsResponse_element());
            else if(request instanceof partnerSoapSforceCom.performQuickActions_element)
                response.put('response_x', new partnerSoapSforceCom.performQuickActionsResponse_element());
            else if(request instanceof partnerSoapSforceCom.describeSObjects_element)
                response.put('response_x', new partnerSoapSforceCom.describeSObjectsResponse_element());
            else if(request instanceof partnerSoapSforceCom.describeKnowledgeSettings_element)
                response.put('response_x', new partnerSoapSforceCom.describeKnowledgeSettingsResponse_element());
            else if(request instanceof partnerSoapSforceCom.undelete_element)
                response.put('response_x', new partnerSoapSforceCom.undeleteResponse_element());
            else if(request instanceof partnerSoapSforceCom.retrieve_element)
                response.put('response_x', new partnerSoapSforceCom.retrieveResponse_element());
            else if(request instanceof partnerSoapSforceCom.describeTheme_element)
                response.put('response_x', new partnerSoapSforceCom.describeThemeResponse_element());
            else if(request instanceof partnerSoapSforceCom.deleteByExample_element)
                response.put('response_x', new partnerSoapSforceCom.deleteByExampleResponse_element());
            else if(request instanceof partnerSoapSforceCom.describeNouns_element)
                response.put('response_x', new partnerSoapSforceCom.describeNounsResponse_element());
            else if(request instanceof partnerSoapSforceCom.findDuplicatesByIds_element)
                response.put('response_x', new partnerSoapSforceCom.findDuplicatesByIdsResponse_element());
            else if(request instanceof partnerSoapSforceCom.executeListView_element)
                response.put('response_x', new partnerSoapSforceCom.executeListViewResponse_element());
            else if(request instanceof partnerSoapSforceCom.renderStoredEmailTemplate_element)
                response.put('response_x', new partnerSoapSforceCom.renderStoredEmailTemplateResponse_element());
            else if(request instanceof partnerSoapSforceCom.describeVisualForce_element)
                response.put('response_x', new partnerSoapSforceCom.describeVisualForceResponse_element());
            else if(request instanceof partnerSoapSforceCom.describeSObject_element)
                response.put('response_x', new partnerSoapSforceCom.describeSObjectResponse_element());
            else if(request instanceof partnerSoapSforceCom.getServerTimestamp_element)
                response.put('response_x', new partnerSoapSforceCom.getServerTimestampResponse_element());
            else if(request instanceof partnerSoapSforceCom.retrieveQuickActionTemplates_element)
                response.put('response_x', new partnerSoapSforceCom.retrieveQuickActionTemplatesResponse_element());
            else if(request instanceof partnerSoapSforceCom.setPassword_element)
                response.put('response_x', new partnerSoapSforceCom.setPasswordResponse_element());
            else if(request instanceof partnerSoapSforceCom.resetPassword_element)
                response.put('response_x', new partnerSoapSforceCom.resetPasswordResponse_element());
            else if(request instanceof partnerSoapSforceCom.describeSoftphoneLayout_element)
                response.put('response_x', new partnerSoapSforceCom.describeSoftphoneLayoutResponse_element());
            else if(request instanceof partnerSoapSforceCom.create_element)
                response.put('response_x', new partnerSoapSforceCom.createResponse_element());
            else if(request instanceof partnerSoapSforceCom.describeSearchLayouts_element)
                response.put('response_x', new partnerSoapSforceCom.describeSearchLayoutsResponse_element());
            else if(request instanceof partnerSoapSforceCom.merge_element)
                response.put('response_x', new partnerSoapSforceCom.mergeResponse_element());
            else if(request instanceof partnerSoapSforceCom.invalidateSessions_element)
                response.put('response_x', new partnerSoapSforceCom.invalidateSessionsResponse_element());
            else if(request instanceof partnerSoapSforceCom.describeDataCategoryMappings_element)
                response.put('response_x', new partnerSoapSforceCom.describeDataCategoryMappingsResponse_element());
            else if(request instanceof partnerSoapSforceCom.logout_element)
                response.put('response_x', new partnerSoapSforceCom.logoutResponse_element());
            else if(request instanceof partnerSoapSforceCom.describeSearchScopeOrder_element)
                response.put('response_x', new partnerSoapSforceCom.describeSearchScopeOrderResponse_element());

            return;
        }
    }

}
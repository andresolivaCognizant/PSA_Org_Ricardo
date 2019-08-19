@isTest
private class SolvedByKnowledgeTemplateControllerTest {
    
    @isTest static void test_method_one() {
        Account account = (Account)TestDataFactoryUtil.createSobject(Constants.SOT_ACCOUNT, new map<String, Object>{
                'FirstName'             => 'Account FirstName testMethod sobject',
                'LastName'              => 'Account LastNametest sobject',
                'Salutation'            => '1',
                'PersonEmail'                 => 'b2ctestMethod2@test.com',
                'PersonalEmail__pc'     => 'b2ctestMethod2@test.com',
                'RecordTypeId'		    => PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA)
        }, true);
        
        
        Case caso = new Case(Status = '1', Origin = CareConstants.CASE_ORIGIN_WEBFORM, Language__c = 'EN ', Brand__c = 'DS', Country__c = 'ES', SuppliedName = 'Supplied Name', accountId = account.id, SuppliedEmail = 'b2ctestMethod2@test.com');
        insert caso;

        Knowledge__kav knowledgeKav = new Knowledge__kav(Title = 'Title', UrlName = 'URl-Test');
        insert knowledgeKav;

        Knowledge__kav know = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id = : knowledgeKav.Id];

        CaseArticle casoArticle = new CaseArticle(ArticleLanguage = 'pt_PT', CaseId = caso.Id, KnowledgeArticleId = know.KnowledgeArticleId);
        insert casoArticle; 

        Test.startTest();
        	SolvedByKnowledgeTemplateController classObject = new SolvedByKnowledgeTemplateController();
        	classObject.caseId = caso.Id;  
            List<String> lst_strings = classObject.getKnowledgeArticlesRelated();
        Test.stopTest();
    }

     @isTest static void test_method_two() {
        Account account = (Account)TestDataFactoryUtil.createSobject(Constants.SOT_ACCOUNT, new map<String, Object>{
                'FirstName'             => 'Account FirstName testMethod sobject',
                'LastName'              => 'Account LastNametest sobject',
                'Salutation'            => '1',
                'PersonEmail'                 => 'b2ctestMethod2@test.com',
                'PersonalEmail__pc'     => 'b2ctestMethod2@test.com',
                'RecordTypeId'		    => PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA)
        }, true);

        
        Case caso = new Case(Status = '1', Origin = CareConstants.CASE_ORIGIN_WEBFORM, Language__c = 'EN ', Brand__c = 'DS', Country__c = 'ES', SuppliedName = 'Supplied Name', accountId = account.id, SuppliedEmail = 'b2ctestMethod2@test.com');
        insert caso;

        Knowledge__kav knowledgeKav = new Knowledge__kav(Title = 'Title', UrlName = 'URl-Test');
        insert knowledgeKav;

        Knowledge__kav know = [SELECT KnowledgeArticleId, ArticleNumber FROM Knowledge__kav WHERE Id = : knowledgeKav.Id];

        CaseArticle casoArticle = new CaseArticle(ArticleLanguage = 'pt_PT', CaseId = caso.Id, KnowledgeArticleId = know.KnowledgeArticleId);
        insert casoArticle;
     
        Test.startTest();
        	SolvedByKnowledgeTemplateController classObject = new SolvedByKnowledgeTemplateController();
        	classObject.caseId = caso.Id;  
            List<String> lst_strings = classObject.getKnowledgeArticlesRelated();
        Test.stopTest();

     }


     @isTest static void test_method_three() {
        Account account = (Account)TestDataFactoryUtil.createSobject(Constants.SOT_ACCOUNT, new map<String, Object>{
                'FirstName'             => 'Account FirstName testMethod sobject',
                'LastName'              => 'Account LastNametest sobject',
                'Salutation'            => '1',
                'PersonEmail'           => 'b2ctestMethod2@test.com',
                'PersonalEmail__pc'     => 'b2ctestMethod2@test.com',
                'RecordTypeId'		    => PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA)
        }, true);

        Case caso = new Case(Status = '1', Origin = CareConstants.CASE_ORIGIN_WEBFORM, Language__c = 'EN ', Brand__c = 'DS', Country__c = 'ES', SuppliedName = 'Supplied Name', accountId = account.id, SuppliedEmail = 'b2ctestMethod2@test.com');
        insert caso;

        Knowledge__kav knowledgeKav = new Knowledge__kav(Title = 'Title', UrlName = 'URl-Test');
        insert knowledgeKav;    

        Knowledge__kav know = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id = : knowledgeKav.Id];

        CaseArticle casoArticle = new CaseArticle(ArticleLanguage = 'pt_PT', CaseId = caso.Id, KnowledgeArticleId = know.KnowledgeArticleId);
        insert casoArticle;  

        Test.startTest();
        	SolvedByKnowledgeTemplateController classObject = new SolvedByKnowledgeTemplateController();
        	classObject.caseId = caso.Id;  
            List<String> lst_strings = classObject.getKnowledgeArticlesRelated();
        Test.stopTest();

     }
    
    
}
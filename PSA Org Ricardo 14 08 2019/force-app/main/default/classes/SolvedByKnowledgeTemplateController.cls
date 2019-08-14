global with sharing class SolvedByKnowledgeTemplateController {

	public String caseId{get;set;}

	public List<String> getKnowledgeArticlesRelated(){
		List<Case> lstCase = new List<Case>();
		String idiom = '';
		String brand = '';
		lstCase = [SELECT id,Brand__c,Country__c,Language__c from Case where id = :caseId];

		idiom = lstCase[0].Language__c.toLowerCase()+'_'+lstCase[0].Country__c;

		if(lstCase[0].Brand__c == 'AP'){
			brand = 'peugeot';
		}
		else if(lstCase[0].Brand__c == 'AC'){
			brand = 'citroen';
		}
		else if(lstCase[0].Brand__c == 'DS'){
			brand = 'dsautomobiles';
		}
		List<CaseArticle> lstCaseArt = new List<CaseArticle>();
		List<String> lstKnowUrl = new List<String>();
		lstCaseArt = [Select id, KnowledgeArticle.ArticleNumber from CaseArticle where CaseId = :caseId];

		if(!lstCaseArt.isEmpty()){
			String lstKnowArtId = '(\'';
			for(CaseArticle casArt : lstCaseArt){
				lstKnowArtId+=casArt.KnowledgeArticle.ArticleNumber+'\',\'';
			}
			System.debug(lstKnowArtId);
			lstKnowArtId=lstKnowArtId.removeEnd(',\'')+')';

			List<Knowledge__kav> lstKnow = new List<Knowledge__kav>();
			String query = 'Select id,URLName,Title from Knowledge__kav where ArticleNumber IN '+lstKnowArtId;
			lstKnow = Database.query(query);

			if(!lstKnow.isEmpty()){
				for(Knowledge__kav know : lstKnow){
					lstKnowUrl.add(System.Label.KBCommunityURL+brand+'/s/article/'+know.URLName+'?language='+idiom);
				}
			}
		}
		return lstKnowUrl;
	}
}
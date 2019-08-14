/**
    *   @Class          : 
    *   @Author         : Pedro Párraga
    *   @Created        : 19/06/2019
    *   @Description    : Test for 
    *
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description    
    *      Pedro Párraga            19/06/2019               Creation.      
    *   ----------------------------------------------------------------------------------------------------------------------------
**/
@isTest
private class MetadataMigrationControllerTest {
	
	@isTest static void test_method_one() {
		Test.startTest();
			MetadataMigrationController metadata = new MetadataMigrationController(); 
			metadata.csvFileBody = EncodingUtil.base64Decode(PAD.getToken());  
			String sId = 'Id';
			List<String> fieldName = new List<String>();
			fieldName.add('Id');
			metadata.fieldNamesForDisplay = fieldName;
			metadata.opTypeFieldObjCreation = 'METADATAAPEX';
			metadata.csFieldObjCreation = 'Quote';
			metadata.cmtFieldObjCreation = 'CustomerMandatoryData__mdt';
			metadata.csNameApexMetadata = 'csNameApexMetadata';
			metadata.cmdNameApexMetadata = 'cmdNameApexMetadata';
			metadata.jsonMappingApexMetadata = 'jsonMappingApexMetadata';
			PageReference page = metadata.migrateAsIsWithObjCreation();
			PageReference page1 = metadata.migrateAsIsMapping();
			PageReference page2 = metadata.migrateSimpleMapping();
			PageReference page3 = metadata.migrateCustomMapping();
		Test.stopTest();
	}
}
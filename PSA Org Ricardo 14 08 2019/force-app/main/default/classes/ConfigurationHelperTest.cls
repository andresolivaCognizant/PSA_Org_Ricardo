@isTest
private class ConfigurationHelperTest {
	
	@isTest static void test_method_one() {
		Test.startTest();
			List<EnhancedHeaderConfig__mdt> lstMdt = ConfigurationHelper.getEnhancedHeaderConfig('');
		Test.stopTest();
	}
}
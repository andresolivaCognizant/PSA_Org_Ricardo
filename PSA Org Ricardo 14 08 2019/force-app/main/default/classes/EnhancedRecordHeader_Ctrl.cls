/*
     * @Name            :   EnhancedRecordHeader_Ctrl
     * @Author          :   Ricardo Pereira Ramirez
     * @Created         :   11/12/2018
     * @Methods (aura)
                        -  getRecordDetails. Retrieves info of a given Id dynamically
     * @Methods (private)
                        -
*/
public class EnhancedRecordHeader_Ctrl {

    /*
     * @Method          :   getRecordDetails
     * @Description     :   Retrieves info of a given Id dynamically
     * @Params          :   recordId
     * @Returns         :   Object: Object details
     */
    @AuraEnabled
    public static Map<String, Object> getRecordDetails(String recordId) {

        Map<String, Object> response = new Map<String, Object>();
        response.put('recordId',recordId);

        try {
            Id recId = String.escapeSingleQuotes(recordId);
            String query = '';

            if (Order.sObjectType == recId.getsObjectType()) {
                query = 'SELECT Id, OrderNumber FROM Order WHERE Id =:recordId';
            } else {
                query = 'SELECT Id, Name FROM ' + recId.getsObjectType() +  ' WHERE Id =:recordId';
            }

            List<SObject> queryResult = Database.query(query);
            response.put('record',queryResult[0]);

        } catch(StringException e) {
            throw new AuraHandledException('Exception: Invalid Id');
        } catch(Exception e) {
            throw new AuraHandledException('Something went wrong. Please, contact your system administrator. Exception: ' +e);
        }

        return response;
    }

    /*
     * @Method          :   getEnhancedHeaderConfig
     * @Description     :   Retrieves the configuration for a header
     * @Params          :   configName
     * @Returns         :   EnhancedHeaderConfig
     */
    @AuraEnabled
    public static String getEnhancedHeaderConfig(String configName) {

        List<EnhancedHeaderConfig__mdt> lstConfigs = ConfigurationHelper.getEnhancedHeaderConfig(configName);

        if(!lstConfigs.isEmpty()){
            return lstConfigs[0].ConfigJSON__c;
        }

        return '{"error":"No config found"}';
    }


    /*
     * @Method          :   getAccountDetails
     * @Description     :   Retrieves info of the Account related to the record
     * @Params          :   recordId
     * @Returns         :   Object: Account details
     */
    @AuraEnabled
    public static Map<String, Object> getAccountDetails(String recordId) {

        Map<String, Object> response = new Map<String, Object>();

        String accountField = 'AccountId';

        Id recId = String.escapeSingleQuotes(recordId);
        String query = '';

        if (Order.sObjectType == recId.getsObjectType()) {

            query = 'SELECT AccountId, Name FROM Order WHERE Id =:recordId';

        } else if (SBQQ__Quote__c.sObjectType == recId.getsObjectType()) {

            query = 'SELECT SBQQ__Account__c, Name FROM SBQQ__Quote__c WHERE Id =:recordId';

            accountField = 'SBQQ__Account__c';
        } else {

            query = 'SELECT AccountId, Name FROM ' + recId.getsObjectType() +  ' WHERE Id =:recordId';
        }

        List<SObject> queryResult = Database.query(query);

        Sobject result = queryResult[0];

        String accountId = (String)result.get(accountField);

        return getRecordDetails(accountId);
    }

}
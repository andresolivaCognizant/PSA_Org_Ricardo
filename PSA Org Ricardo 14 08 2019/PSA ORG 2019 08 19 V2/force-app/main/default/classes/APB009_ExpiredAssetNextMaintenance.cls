global class APB009_ExpiredAssetNextMaintenance implements Database.Batchable<sObject> {

    private final String query;

    global APB009_ExpiredAssetNextMaintenance() {
        // find owned assets with expired next maintenance date
        query = 
            'SELECT Id, Brand__c, Country__c, LastModifiedDate ' +
            'FROM Asset ' +
            'WHERE ' +
                'TECH_ActiveOwnerCounter__c > 0 AND ' +
                'NextMaintenanceDate__c != null AND ' +
                'NextMaintenanceDate__c < TODAY';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Asset> scope) {
        Set<Id> setIds = new Set<Id>();

        for (Asset a : scope) {
            if (System.today() < a.LastModifiedDate.addMonths(AssetUtils.matchingConfig(a).MaxLastActivity__c.intValue())) {
                setIds.add(a.Id);
            }
        }

        if (!setIds.isEmpty()) {
            // call queueable
            AssetUtils.AssetQualifying j = new AssetUtils.AssetQualifying(setIds);
            Id jobID = System.enqueueJob(j);
            System.debug('Next maintenance job Id: ' + jobId);
        }
    }

    global void finish(Database.BatchableContext BC) {

    }

}
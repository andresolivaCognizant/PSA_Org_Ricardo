public without sharing class LeadTreatmentTime {

    public static void setTreatmentDueDate(List<Lead> lst) {
        Map<String, String> map_act = new Map<String, String>();

        for (UtilSetting__mdt a : [
            SELECT MasterLabel, QualifiedApiName, Value__c, Value2__c
            FROM UtilSetting__mdt
            WHERE QualifiedApiName LIKE 'LeadSLAConfigurationT%'
        ]) {
            map_act.put(a.Value__c, a.Value2__c);
        }

        Set<Id> set_owner = new Set<Id>();

        for (Lead l : lst) {
            set_owner.add(l.OwnerId);
        }

        Map<Id, User> map_usr = new Map<Id, User>([
            SELECT Id, Contact.AccountId
                FROM User
                WHERE
                    Id IN :set_owner AND
                    Contact.AccountId != null
        ]);

        Map<Id, String> map_sla_keys = new Map<Id, String>();
        Map<Id, String> map_bhr_keys = new Map<Id, String>();

        for (Lead l : lst) {
            if (map_usr.containsKey(l.OwnerId)) {
                map_sla_keys.put(
                    l.Id,
                    l.LeadCountry__c +
                    l.PSABrand__c +
                    map_act.get(l.Activity__c) +
                    l.LeadType__c +
                    map_usr.get(l.OwnerId).Contact.AccountId
                );
                map_bhr_keys.put(
                    l.Id,
                    'LEAD' +
                    l.LeadCountry__c +
                    l.PSABrand__c +
                    map_act.get(l.Activity__c) +
                    l.LeadType__c +
                    map_usr.get(l.OwnerId).Contact.AccountId
                );
            }
        }

        Map<String, LeadSLAConfiguration__mdt> map_sla =
            new Map<String, LeadSLAConfiguration__mdt>();

        for (LeadSLAConfiguration__mdt sla : [
            SELECT Id, DeveloperName, SLAFirstAction__c
            FROM LeadSLAConfiguration__mdt
            WHERE DeveloperName IN :map_sla_keys.values()
        ]) {
            map_sla.put(sla.DeveloperName, sla);
        }

        Map<String, BusinessHours> map_bhr = new Map<String, BusinessHours>();

        for (BusinessHours bh : [
            SELECT Id, Name
            FROM BusinessHours
            WHERE Name IN :map_bhr_keys.values()
        ]) {
            map_bhr.put(bh.Name, bh);
        }

        for (Lead l : lst) {
            if (
                map_sla_keys.containsKey(l.Id) &&
                map_bhr_keys.containsKey(l.Id) &&
                map_sla.containsKey(map_sla_keys.get(l.Id)) &&
                map_bhr.containsKey(map_bhr_keys.get(l.Id))
            ) {
                l.TreatmentDueDate__c = BusinessHours.add(
                    map_bhr.get(map_bhr_keys.get(l.Id)).Id,
                    System.now(),
                    (6 * (10.0.pow(4)) * map_sla.get(map_sla_keys.get(l.Id)).SLAFirstAction__c).intValue()
                );
            }
        }
    }

}
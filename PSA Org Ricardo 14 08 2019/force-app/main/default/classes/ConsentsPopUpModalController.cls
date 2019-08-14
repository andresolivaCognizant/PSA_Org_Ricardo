public class ConsentsPopUpModalController {

    @AuraEnabled
    public static Map<String, Object> getConsents(Id aId) {
        Map<String, Object> m = new Map<String, Object>();
        List<Account> c = new List<Account>([
            SELECT Id, TECH_UnsubscribeURL__c, (SELECT Id FROM Consents1__r)
            FROM Account
            WHERE Id = :aId
        ]);
        
        if (
            !c.isEmpty() &&
            !c.get(0).Consents1__r.isEmpty() &&
            null != c.get(0).TECH_UnsubscribeURL__c
        ) {
            m.put('hasConsent', true);
            m.put('updateUrl', c.get(0).TECH_UnsubscribeURL__c);
        } else {
            m.put('hasConsent', false);
            m.put('updateUrl', null);
        }
        
        m.put('id', aId);
        return m;
    }

    @AuraEnabled
    public static Map<String, Object> getUserInfo() {
        Id uId = System.UserInfo.getUserId();
        Map<String, Object> m = new Map<String, Object>();
        List<User> u = new List<User>([
            SELECT Id, Contact.AccountId, Contact.Account.RecordType.DeveloperName
            FROM User
            WHERE
                Id = :uId AND
                Contact.AccountId != null AND
                Contact.Account.RecordType.DeveloperName = 'Account_DealerPartner'
        ]);

        if (!u.isEmpty()) {
            m.put('hasDealerId', true);
            m.put('sObject', u.get(0));
        } else {
            m.put('hasDealerId', false);
            m.put('sObject', null);
        }

        m.put('id', uId);
        return m;
    }

    @AuraEnabled
    public static Map<Id, WorkshopAppointment__c> getAppointmentInfo(String req) {
        List<Id> lst = new List<Id>();
        
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(req);
        for (Object o : (List<Object>) m.get('ids')) {
            lst.add((Id) o);
        }
        
       

        if (lst.isEmpty()) {
            return new Map<Id, WorkshopAppointment__c>([
                SELECT Id, AppointmentStatus__c, Driver__c
                FROM WorkshopAppointment__c
                ORDER BY LastModifiedDate DESC
                LIMIT 50
            ]);
        }

        return new Map<Id, WorkshopAppointment__c>([
            SELECT Id, AppointmentStatus__c, Driver__c
            FROM WorkshopAppointment__c
            WHERE Id IN :lst
            ORDER BY LastModifiedDate DESC
        ]);
    }

}
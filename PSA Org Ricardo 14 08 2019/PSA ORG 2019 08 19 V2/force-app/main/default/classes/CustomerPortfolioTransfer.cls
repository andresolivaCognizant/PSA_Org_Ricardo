public class CustomerPortfolioTransfer {

    public static final User running_user;

    static {
        running_user = [
            SELECT Id, Brand__c
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ].get(0);
    }

    @AuraEnabled 
    public static Map<String, Object> getVnContractList(String req){ 

        Map<String, Object> res = new Map<String, Object>();
        List<sObject> lst = new List<sObject>();
        
        try {
            User u = [
                SELECT Id, Profile.Name, VNRRDICode__c, RAorAgentRRDICode__c
                FROM User
                WHERE Id = :running_user.Id
            ];
            
            switch on (u.Profile.Name) {
                when 'Subsidiary_MKT_Sales_Manager', 'System Administrator' {
                    lst = new List<Account>([
                        SELECT Id, VNContractNumber__c
                        FROM Account
                        WHERE
                            VNPrincipalSite__c = true AND
                            VNContractNumber__c != null
                        ORDER BY VNContractNumber__c ASC
                    ]);
                }
            }

            res.put('hasError', false);
            res.put('error', null);
            res.put(
            'payload',
                new Map<String, Object>{
                    'user' => u,
                    'data' => lst
                }
            );
        } catch(Exception e) {
            res.put('hasError', true);
        }

        return res;
    }

    @AuraEnabled 
    public static Map<String, Object> getAgentContractList(String req){ 

        Map<String, Object> res = new Map<String, Object>();
        List<sObject> lst = new List<sObject>();
        
        try {
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(req);

            lst = new List<PartnerAccountLink__c>([
                SELECT Id, SubscriberId__r.AgentContractNumber__c
                FROM PartnerAccountLink__c
                WHERE
                    SubscriberId__r.AgentContractNumber__c != null AND
                    ProviderId__c IN (
                        SELECT Id
                        FROM Account
                        WHERE VNContractNumber__c = :(String) m.get('vn_contract')
                    )
            ]);

            res.put('hasError', false);
            res.put('error', null);
            res.put('payload', lst);

        } catch(Exception e) {
            res.put('hasError', true);
        }

        return res;
    }

    @AuraEnabled 
    public static Map<String, Object> getUserList(String req){ 

        Map<String, Object> res = new Map<String, Object>();
        List<sObject> lst = new List<sObject>();
        
        try {
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(req);

            lst = new List<User>([
                SELECT Id, Profile.Name, Name, VNRRDICode__c, RAorAgentRRDICode__c
                FROM User
                WHERE VNRRDICode__c = :(String) m.get('vn_contract')
            ]);

            res.put('hasError', false);
            res.put('error', null);
            res.put('payload', lst);

        } catch(Exception e) {
            res.put('hasError', true);
        }

        return res;
    }

    @AuraEnabled 
    public static Map<String, Object> getAvailableActivity(String req){ 

        Map<String, Object> res = new Map<String, Object>();
        String query = '';

        try {
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(req);
            // selected source object
            Map<String, Object> mapS = (Map<String, Object>) m.get('source');
            List<Id> lstO = new List<Id>();
            
            for (Object o : (List<Object>) m.get('user_id')) {
                lstO.add((Id) o);
            }

            String filter_city = m.get('city') == null ? null :
                String.escapeSingleQuotes((String) m.get('city'));
            String filter_code = m.get('postal_code') == null ? null :
                String.escapeSingleQuotes((String) m.get('postal_code'));

            query = 
                'SELECT ' + 
                    'Id, ' +
                    'Name, ' +
                    'BillingCity, ' +
                    'BillingPostalCode, ' +
                    'Owner.Name, ' +
                    'RecordType.DeveloperName, ' +
                    'ACAccountStatus__c, ' +
                    'APAccountStatus__c, ' +
                    'DSAccountStatus__c ' +
                'FROM Account ' +
                'WHERE OwnerId IN :lstO';

            if (null != filter_city) {
                query =+ 'AND BillingCity = \'' + filter_city + '\'';
            }

            if (null != filter_code) {
                query =+ 'AND BillingPostalCode = \'' + filter_code + '\'';
            }

            // activity map
            Map<Id, Object> mapA = new Map<Id, Object>();
            
            for (Account a : Database.query(query)) {
                mapA.put(
                    a.Id,
                    new Map<String, Object>{
                        'Id'            => a.Id,
                        'Name'          => a.Name,
                        'sObjectType'   => 'Account',
                        'PostalCode'    => a.BillingPostalCode,
                        'City'          => a.BillingCity,
                        'Owner'         => a.Owner.Name,
                        'Type'          => getCustomerType(a),
                        'Status'        => getCustomerStatus(a)
                    }
                );
            }

            for (Lead l : [
                SELECT
                    Id,
                    Name,
                    Owner.Name,
                    OwnerId,
                    PostalCode,
                    City,
                    CustomerType__c,
                    Customer__c,
                    Customer__r.OwnerId,
                    Customer__r.Name,
                    Customer__r.BillingCity,
                    Customer__r.BillingPostalCode,
                    Customer__r.Owner.Name,
                    Customer__r.RecordType.DeveloperName,
                    Customer__r.ACAccountStatus__c,
                    Customer__r.APAccountStatus__c,
                    Customer__r.DSAccountStatus__c
                FROM Lead
                WHERE
                    Status = 'New' AND
                    Customer__c NOT IN :lstO AND
                    (OwnerId IN :lstO OR Customer__r.OwnerId IN :lstO)
            ]) {
                if (
                    null == l.Customer__c &&
                    lstO.contains(l.OwnerId) &&
                    !mapA.containsKey(l.Id)
                ) {
                    mapA.put(
                        l.Id,
                        new Map<String, Object>{
                            'Id'            => l.Id,
                            'Name'          => l.Name,
                            'sObjectType'   => 'Lead',
                            'PostalCode'    => l.PostalCode,
                            'City'          => l.City,
                            'Owner'         => l.Owner.Name,
                            'Type'          => getCustomerType(l),
                            'StatusAC'      => 'Prospect',
                            'StatusAP'      => 'Prospect',
                            'StatusDS'      => 'Prospect'
                        }
                    );
                    continue;
                }
                if (
                    null != l.Customer__r.OwnerId &&
                    lstO.contains(l.Customer__r.OwnerId) &&
                    !mapA.containsKey(l.Customer__c)
                ) {
                    mapA.put(
                        l.Customer__c,
                        new Map<String, Object>{
                            'Id'            => l.Customer__c,
                            'Name'          => l.Customer__r.Name,
                            'sObjectType'   => 'Account',
                            'PostalCode'    => l.Customer__r.BillingPostalCode,
                            'City'          => l.Customer__r.BillingCity,
                            'Owner'         => l.Customer__r.Owner.Name,
                            'Type'          => getCustomerType(l.Customer__r),
                            'Status'        => getCustomerStatus(l.Customer__r)
                        }
                    );
                }
            }

            for (Opportunity o : [
                SELECT
                    Id,
                    AccountId,
                    Account.Name,
                    Account.BillingCity,
                    Account.BillingPostalCode,
                    Account.Owner.Name,
                    Account.RecordType.DeveloperName,
                    Account.ACAccountStatus__c,
                    Account.APAccountStatus__c,
                    Account.DSAccountStatus__c
                FROM Opportunity
                WHERE
                    StageName IN ('6', '7', 'FR4', 'FR5') AND
                    OwnerId IN :lstO AND
                    AccountId != null AND
                    AccountId NOT IN :mapA.keySet()
            ]) {
                if (mapA.containsKey(o.AccountId)) {
                    continue;
                }

                mapA.put(
                    o.AccountId,
                    new Map<String, Object>{
                        'Id'            =>  o.AccountId,
                        'Name'          =>  o.Account.Name,
                        'sObjectType'   =>  'Account',
                        'PostalCode'    =>  o.Account.BillingPostalCode,
                        'City'          =>  o.Account.BillingCity,
                        'Owner'         =>  o.Account.Owner.Name,
                        'Type'          =>  getCustomerType(o.Account),
                        'Status'        =>  getCustomerStatus(o.Account)
                    }
                );
            }

            for (SBQQ__Quote__c q : [
                SELECT
                    Id,
                    SBQQ__Account__c,
                    SBQQ__Account__r.Name,
                    SBQQ__Account__r.BillingCity,
                    SBQQ__Account__r.BillingPostalCode,
                    SBQQ__Account__r.Owner.Name,
                    SBQQ__Account__r.RecordType.DeveloperName,
                    SBQQ__Account__r.ACAccountStatus__c,
                    SBQQ__Account__r.APAccountStatus__c,
                    SBQQ__Account__r.DSAccountStatus__c
                FROM SBQQ__Quote__c
                WHERE
                    OwnerId IN :lstO AND
                    SBQQ__Account__c != null AND
                    SBQQ__Account__c NOT IN :mapA.keySet()
            ]) {
                if (mapA.containsKey(q.SBQQ__Account__c)) {
                    continue;
                }

                mapA.put(
                    q.SBQQ__Account__c,
                    new Map<String, Object>{
                        'Id'            => q.SBQQ__Account__c,
                        'Name'          => q.SBQQ__Account__r.Name,
                        'sObjectType'   => 'Account',
                        'PostalCode'    => q.SBQQ__Account__r.BillingPostalCode,
                        'City'          => q.SBQQ__Account__r.BillingCity,
                        'Owner'         => q.SBQQ__Account__r.Owner.Name,
                        'Type'          => getCustomerType(q.SBQQ__Account__r),
                        'Status'        => getCustomerStatus(q.SBQQ__Account__r)
                    }
                );
            }

            for (ServiceContract__c c : [
                SELECT
                    Id,
                    Account__c,
                    Account__r.Name,
                    Account__r.BillingCity,
                    Account__r.BillingPostalCode,
                    Account__r.Owner.Name,
                    Account__r.RecordType.DeveloperName,
                    Account__r.ACAccountStatus__c,
                    Account__r.APAccountStatus__c,
                    Account__r.DSAccountStatus__c
                FROM ServiceContract__c
                WHERE
                    OwnerId IN :lstO AND
                    Account__c != null AND
                    Account__c NOT IN :mapA.keySet()
            ]) {
                if (mapA.containsKey(c.Account__c)) {
                    continue;
                }

                mapA.put(
                    c.Account__c,
                    new Map<String, Object>{
                        'Id'            => c.Account__c,
                        'Name'          => c.Account__r.Name,
                        'sObjectType'   => 'Account',
                        'PostalCode'    => c.Account__r.BillingPostalCode,
                        'City'          => c.Account__r.BillingCity,
                        'Owner'         => c.Account__r.Owner.Name,
                        'Type'          => c.Account__r.RecordType.DeveloperName,
                        'Status'      => getCustomerStatus(c.Account__r)
                    }
                );
            }

            res.put('hasError', false);
            res.put('error', null);
            res.put('payload', mapA.values());

        } catch(Exception e) {
            res.put('hasError', true);
        }

        return res;
    }
    
    @AuraEnabled 
    public static Map<String, Object> insertTransferRequest(String req){ 

        Map<String, Object> res = new Map<String, Object>();

        try {
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(req);
            
            // source and destination
            Map<String, Object> mapS = (Map<String, Object>) m.get('source');
            Map<String, Object> mapD = (Map<String, Object>) m.get('destination');

            System.debug(mapS.containsKey('vn_contract'));

            CustomerPortfolioTransfer__c t = new CustomerPortfolioTransfer__c(
                Status__c                           = '1',
                SourceVNContractNumber__c           = mapS.containsKey('vn_contract') ? (String) mapS.get('vn_contract') : null,
                SourceAgentContractNumber__c        = mapS.containsKey('agent_contract') ? (String) mapS.get('agent_contract') : null,
                SourceUser__c                       = mapS.containsKey('user_id') ? (Id) mapS.get('user_id') : null,
                DestinationVNContractNumber__c      = mapD.containsKey('vn_contract') ? (String) mapD.get('vn_contract') : null,
                DestinationAgentContractNumber__c   = mapD.containsKey('agent_contract') ? (String) mapD.get('agent_contract') : null,
                DestinationUser__c                  = mapD.containsKey('user_id') ? (Id) mapD.get('user_id') : null
            );

            insert t;

            List<CustomerPortfolioTransferMember__c> lstM = new List<CustomerPortfolioTransferMember__c>();


            for (Object o : (List<Object>) m.get('rows')) {
                lstM.add(new CustomerPortfolioTransferMember__c(
                    CustomerPortfolioTransfer__c = t.Id,
                    Record_ID__c = (Id) o
                ));
            }

            insert lstM;

            res.put('hasError', false);
            res.put('error', null);
            res.put('payload', t.Id);

        } catch(Exception e) {
            res.put('hasError', true);
        }

        return res;
    }

    public static String getCustomerType(SObject r) {
        switch on (r.Id.getSObjectType().getDescribe().getName()) {
            when 'Account' {
                switch on (((Account) r).RecordType.DeveloperName) {
                    when 'Account_B2C' {
                        return 'B2C';
                    }
                    when 'Account_B2B' {
                        return 'B2B';
                    }
                    when 'PersonAccount_B2C' {
                        return 'B2C';
                    }
                }
           }
            when 'Lead' {
                switch on (((Lead) r).CustomerType__c) {
                    when '1' {
                        return 'B2C';
                    }
                    when '2' {
                        return 'B2B';
                    } 
                }
           }
        }
        return null;
    }

    public static String getCustomerStatus(Account a) {
        switch on running_user.Brand__c {
            when 'AC' {
                return getBrandStatus(a.ACAccountStatus__c);
            }
            when 'AP' {
                return getBrandStatus(a.APAccountStatus__c);
            }
            when 'DS' {
                return getBrandStatus(a.DSAccountStatus__c);
            }
            when else {
                return null;
            }
        }
    }

    public static string getBrandStatus(String s) {
        switch on s {
            when 'Prospect', 'Customer' {
                return s;
            }
            when else {
                return null;
            }
        }
    }

}
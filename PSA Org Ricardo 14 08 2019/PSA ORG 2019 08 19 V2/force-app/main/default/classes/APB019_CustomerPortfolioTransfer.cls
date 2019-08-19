/**
 * Salesforce
 * @author              Diego Rincón (DR) href=<diego.rincon@ext.mpsa.com>
 * Project:             PSA - Customer First
 * Description:         Batchable class to process Customer Portofio Transfer requests stored in
 *                      CustomerPortfolioTransfer__c records.
 *
 * Changes (version)
 * -------------------------------------------------------------------------------------------------
 *              No.     Date            Author                  Description
 *              ----    ------------    --------------------    ------------------------------------
 * @version     1.0     2018-11-26      Diego Rincón (DR)       Class creation.
 */


global class APB019_CustomerPortfolioTransfer implements Database.Batchable<sObject> {
    private final String query;
    // list of requests being processed per chunk
    private final List<Id> lstR;

    public APB019_CustomerPortfolioTransfer() {
        // find all children from CustomerPortfolioTransfer__c records with 'New' status.
        query = 
            'SELECT Id, Record_ID__c, TECH_SObjectType__c, CustomerPortfolioTransfer__c, CustomerPortfolioTransfer__r.DestinationUser__c ' +
            'FROM CustomerPortfolioTransferMember__c ' +
            'WHERE ' +
                'CustomerPortfolioTransfer__r.Status__c = \'1\' AND ' +
                'Status__c = null';

        System.debug(query);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<CustomerPortfolioTransferMember__c> scope) {
        Map<Id, CustomerPortfolioTransferMember__c> mapS =
            new Map<Id, CustomerPortfolioTransferMember__c>(scope);

        List<CustomerPortfolioTransferEvent__e> lstE = new List<CustomerPortfolioTransferEvent__e>();
        // parent ids
        Set<Id> setT = new Set<Id>();


        // list of sObjects to update / create
        List<sObject> dmlList = new List<sObject>();
        List<Database.SaveResult> srList = new List<Database.SaveResult>();
        Map<Id, List<String>> mapF = new Map<Id, List<String>>();

        // map with records to reassign with corresponding origin
        Map<Id, Id> mapL = new Map<Id,Id>(); // leads
        Map<Id, Id> mapA = new Map<Id,Id>(); // accounts
        Map<Id, Id> mapO = new Map<Id,Id>(); // other

        // list of sObjects to update / insert
        List<sObject> lstU = new List<sObject>();

        for (CustomerPortfolioTransferMember__c m : scope) {
            mapO.put(m.Record_ID__c, m.Id);
            switch on m.TECH_SObjectType__c {
                when 'Lead' {
                    mapL.put(m.Record_ID__c, m.Id);
                }
                when 'Account' {
                    mapA.put(m.Record_ID__c, m.Id);
                }
            }
        }

        for (Lead l : [
            SELECT Id, OwnerId
            FROM Lead
            WHERE Id IN: mapL.keySet()
        ]) {
            if (l.OwnerId != mapS.get(mapO.get(l.Id)).CustomerPortfolioTransfer__r.DestinationUser__c) {
                l.OwnerId = mapS.get(mapO.get(l.Id)).CustomerPortfolioTransfer__r.DestinationUser__c;
                System.debug('New owner: ' + mapS.get(mapO.get(l.Id)).CustomerPortfolioTransfer__r.DestinationUser__c);
                lstU.add(l);
            }
        }

        // raise database errors for negative testing purposes
        if (Test.isRunningTest() && !lstU.isEmpty()) {
            ((Lead) lstU.get(0)).OwnerId = '001u00000000000000';
        }

        srList = Database.update(lstU, false);


        // lead update error handling - start
        for (Integer i = 0; i < lstU.size(); i++) {
            if (!srList.get(i).isSuccess()) {
                if (!mapF.containsKey(mapO.get(lstU.get(i).Id))) {
                    mapF.put(
                        mapO.get(lstU.get(i).Id),
                        new List<String>()
                    );
                }

                for (Database.Error e : srList.get(i).getErrors()) {
                    mapF.get(mapO.get(lstU.get(i).Id)).add(
                        '[' + lstU.get(i).Id + '] ' + e.statuscode + ': ' + e.message
                    );
                }
            }
        }
        // lead update error handling - end

        lstU.clear();
        srList.clear();

        for (Lead l : [
            SELECT Id, OwnerId, Customer__c
            FROM Lead
            WHERE
                Customer__c IN: mapA.keySet() AND
                Id NOT IN :mapL.keySet()
        ]) {

            mapO.put(
                l.Id,
                mapA.get(l.Customer__c)
            );

            System.debug('New owner: ' + mapS.get(mapO.get(l.Id)).CustomerPortfolioTransfer__r.DestinationUser__c);

            if (l.OwnerId != mapS.get(mapA.get(l.Customer__c)).CustomerPortfolioTransfer__r.DestinationUser__c) {
                l.OwnerId = mapS.get(mapA.get(l.Customer__c)).CustomerPortfolioTransfer__r.DestinationUser__c;
                lstU.add(l);
            }
        }

        srList = Database.update(lstU, false);

        // customer lead update error handling - start
        for (Integer i = 0; i < lstU.size(); i++) {
            if (!srList.get(i).isSuccess()) {
                if (!mapF.containsKey(mapO.get(lstU.get(i).Id))) {
                    mapF.put(
                        mapO.get(lstU.get(i).Id),
                        new List<String>()
                    );
                }

                for (Database.Error e : srList.get(i).getErrors()) {
                    mapF.get(mapO.get(lstU.get(i).Id)).add(
                        '[' + lstU.get(i).Id + '] ' + e.statuscode + ': ' + e.message
                    );
                }
            }
        }
        // customer lead update error handling - end

        lstU.clear();
        srList.clear();

        for (Opportunity o : [
            SELECT Id, OwnerId, AccountId
            FROM Opportunity
            WHERE
                StageName IN ('6', '7','FR4', 'FR5') AND
                AccountId IN :mapA.keySet()
        ]) {
            mapO.put(
                o.Id,
                mapA.get(o.AccountId)
            );

            if (o.OwnerId != mapS.get(mapA.get(o.AccountId)).CustomerPortfolioTransfer__r.DestinationUser__c) {
                o.OwnerId = mapS.get(mapA.get(o.AccountId)).CustomerPortfolioTransfer__r.DestinationUser__c;
                lstU.add(o);
            }
        }

        // raise database errors for negative testing purposes
        if (Test.isRunningTest() && !lstU.isEmpty()) {
            ((Opportunity) lstU.get(0)).OwnerId = '001u00000000000000';
        }

        srList = Database.update(lstU, false);

        // opportunity update error handling - start
        for (Integer i = 0; i < lstU.size(); i++) {
            if (!srList.get(i).isSuccess()) {
                if (!mapF.containsKey(mapO.get(lstU.get(i).Id))) {
                    mapF.put(
                        mapO.get(lstU.get(i).Id),
                        new List<String>()
                    );
                }

                for (Database.Error e : srList.get(i).getErrors()) {
                    mapF.get(mapO.get(lstU.get(i).Id)).add(
                        '[' + lstU.get(i).Id + '] ' + e.statuscode + ': ' + e.message
                    );
                }
            }
        }
        // opportunity update error handling - end

        lstU.clear();
        srList.clear();

        for (SBQQ__Quote__c q : [
            SELECT Id, SBQQ__Account__c
            FROM SBQQ__Quote__c
            WHERE SBQQ__Account__c IN :mapA.keySet()
        ]) {
            mapO.put(
                q.Id,
                mapA.get(q.SBQQ__Account__c)
            );

            lstU.add(new SBQQ__Quote__Share(
                ParentId = q.Id,
                UserOrGroupId = mapS.get(mapA.get(q.SBQQ__Account__c)).CustomerPortfolioTransfer__r.DestinationUser__c,
                RowCause = 'Manual',
                AccessLevel = 'Edit'
            ));
        }

        for (ServiceContract__c c : [
            SELECT Id, Account__c
            FROM ServiceContract__c
            WHERE Account__c IN :mapA.keySet()
        ]) {
            mapO.put(
                c.Id,
                mapA.get(c.Account__c)
            );

            /* this block won't work unless sharing is restricted
            lstU.add(new ServiceContract__Share(
                ParentId = c.Id,
                UserOrGroupId = mapS.get(mapA.get(c.Account__c)).CustomerPortfolioTransfer__r.DestinationUser__c,
                RowCause = 'Manual',
                AccessLevel = 'Edit'
            ));
            */
        }

        // raise database errors for negative testing purposes
        if (Test.isRunningTest() && !lstU.isEmpty()) {
            ((SBQQ__Quote__Share) lstU.get(0)).UserOrGroupId = '001u00000000000000';
        }
        
        srList = Database.insert(lstU, false);

        // sharing records insert error handling - start
        for (Integer i = 0; i < lstU.size(); i++) {
            if (!srList.get(i).isSuccess()) {
                if (!mapF.containsKey(mapO.get(lstU.get(i).Id))) {
                    mapF.put(
                        mapO.get(lstU.get(i).Id),
                        new List<String>()
                    );
                }

                for (Database.Error e : srList.get(i).getErrors()) {
                    mapF.get(mapO.get(lstU.get(i).Id)).add(
                        '[' + lstU.get(i).Id + '] ' + e.statuscode + ': ' + e.message
                    );
                }
            }
        }
        // sharing records insert error handling - end

        // set status based on errors encountered during executuion
        for (CustomerPortfolioTransferMember__c m : scope) {
            // affected parent records
            setT.add(m.CustomerPortfolioTransfer__c);
            
            if (mapF.containsKey(m.Id)) {
                // write errors
                m.Status__c = 'Error';
                m.Errormessage__c = String.join(mapF.get(m.Id), '\n');
                continue;
            }
            // successful operation
            m.Status__c = 'Success';
        }

        update scope;


        // set parent status when all childen are processed
        for (CustomerPortfolioTransfer__c t : [
            SELECT Id, DestinationUser__c
            FROM CustomerPortfolioTransfer__c
            WHERE
                Id IN :setT AND
                TECH_PendingMembers__c = 0
        ]) {
            lstE.add(new CustomerPortfolioTransferEvent__e(
                CustomerPortfolioTransferId__c  = t.Id,
                TargetObjectId__c               = t.DestinationUser__c
            ));
        }

        EventBus.publish(lstE);
    }

    global void finish(Database.BatchableContext BC) {
    }


}
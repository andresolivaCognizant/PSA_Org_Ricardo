global with sharing class LeadHandleProcessInvocable {

     @InvocableMethod(
        label       = 'PB: Handle Processes'
        description = 'Dealler Allocation + Assigment + Treatment Time.'
    )

    global static void handleProcess(List<ObjectRequest> requests){

        System.debug( 'LeadHandleProcessInvocable.handleProcess: ' + requests );
        List<Id> lstRecords = new List<Id>();
        List<Id> lstLeadId = new List<Id>();

        for (ObjectRequest r : requests) {
            lstRecords.add(r.recordId);
        }

        if(!lstRecords.isEmpty()) {
            LeadDealerAllocation.handleDealerAllocation(lstRecords);
        }

        // C1STRUN-1948 - begin
        if (lstRecords.size() == 1) {
            List<Lead> lst_l = new List<Lead>([
                SELECT
                    Id,
                    Name,
                    Status,
                    FirstName,
                    LastName,
                    TECH_Web2Lead__c,
                    OwnerId,
                    Company
                FROM Lead
                WHERE Id IN: lstRecords AND TECH_Web2Lead__c = true
            ]);

            if(!lst_l.isEmpty() && lst_l.get(0).TECH_Web2Lead__c) {
                SendEmailOwnerChanged.sendEmail(
                    lst_l, new Map<Id, Lead> {
                        lst_l.get(0).Id => new Lead(
                            Id      = lst_l.get(0).Id,
                            OwnerId = null
                        )
                    }
                );

                FlatAllocation.mainFunction(
                    lst_l, new Map<Id, Lead> {
                        lst_l.get(0).Id => new Lead(
                            Id      = lst_l.get(0).Id,
                            OwnerId = null
                        )
                    }
                );
            }
        }
        // C1STRUN-1948 - end
    }

    @future
    public static void asyncHandleDealerAllocation(List<Id> lst) {
        List<Id> lstLeadId = new List<Id>();

        for (Lead l : [
            SELECT Id
            FROM Lead
            WHERE
                Id IN : lst AND
                Latitude != null AND
                Longitude != null AND
                CalculatedPOS__c = null
        ]) {
            lstLeadId.add(l.Id);
        }

        LeadDealerAllocation.handleDealerAllocation(lstLeadId);
    }

    global class ObjectRequest {

        @InvocableVariable(
            label           = 'Record ID'
            description     = 'The record to be processed'
            required        = true
        )
        global String recordId;

    }
}
public without sharing class PushLeadToDealer {

    @AuraEnabled
    public static Map<String, Object> allocateLeads(String request) {
        Map<String, Object> response = new Map<String, Object>();

        try {
            Map<String, Object> map_req =
                (Map<String, Object>) JSON.deserializeUntyped(request);

            List<Id> lst_ids = (List<Id>) JSON.deserializeStrict(
                JSON.serialize(map_req.get('lst_ids')),
                List<Id>.class
            );

            List<Lead> lst_l = [
                SELECT
                    FirstName,
                    LastName,
                    Street,
                    City,
                    Country,
                    PostalCode,
                    Latitude,
                    Longitude,
                    Phone,
                    NationalId__c,
                    DestinationGeographicalCode__c,
                    DestinationPOSCode__c,
                    Company,
                    BrandOwnedVehicle__c,
                    Email,
                    LeadCountry__c,
                    Activity__c,
                    CustomerType__c,
                    LeadChannel__c,
                    LeadRequestType__c,
                    LeadSource,
                    LeadType__c,
                    CustomerContact__c,
                    MarketingCode__c,
                    BirthDate__c,
                    TECH_DealerPdVInternal__c,
                    FiscalId__c,
                    VINOwnedVehicle__c,
                    MobileProfessionalTelephone__c,
                    LandlineProfessionalTelephone__c,
                    RecordTypeId,
                    LandlinePersonalTelephone__c,
                    MobilePersonalTelephone__c,
                    Customer__c,
                    LocalIdOfCustomer__c,
                    CalculatedPOS__c,
                    CalculatedPOS__r.AgentFlag__c,
                    CalculatedPOS__r.RAFlag__c,
                    CalculatedPOS__r.LeadFilters__c,
                    CalculatedPOS__r.TECH_AfterSalesManager__c,
                    CalculatedPOS__r.TECH_SalesManager__c,
                    CalculatedPOS__r.TECH_SalesManagerAgent__c,
                    VehicleRegistrationNumber__c,
                    PSABrand__c,
                    TreatmentDueDate__c,
                    OwnerId,
                    CreatedDate,
                    TECH_Web2Lead__c,
                    TECH_Web2LeadAssignment__c
                FROM Lead
                WHERE Id IN :lst_ids
            ];

            LeadDealerAllocation.setDealerAllocation(lst_l);
            LeadAssigmentProcess.handleAssigmentProcess(lst_l, false, true);

            response.put('hasError', false);
            response.put('payload', new Map<Id, Lead>(lst_l));

        } catch (Exception e) {
            response.clear();
            response.put('hasError', true);
        }

        return response;
    }

    @AuraEnabled
    public static Map<String, Object> updateLeads(String request) {
        Map<String, Object> response = new Map<String, Object>();

        try {
            Map<String, Object> map_req =
                (Map<String, Object>) JSON.deserializeUntyped(request);

            List<Lead> lst_l = (List<Lead>) JSON.deserializeStrict(
                JSON.serialize(map_req.get('lst_leads')),
                List<Lead>.class
            );

            update lst_l;

            Set<Id> set_owner = new Set<Id>();
            for (Lead l : lst_l) {
                if (l.OwnerId != null) {
                    set_owner.add(l.OwnerId);
                }
            }

            Map<Id, User> map_owner = new Map<Id, User>([
                SELECT Id, Name
                FROM User
                WHERE Id IN :set_owner
            ]);

            response.put('hasError', false);
            response.put('payload', new Map<String, Object>{
                'map_lead'  => new Map<Id, Lead>(lst_l),
                'map_owner' => map_owner
            });

        } catch (Exception e) {
            response.clear();
            response.put('hasError', true);
        }

        return response;
    }
}
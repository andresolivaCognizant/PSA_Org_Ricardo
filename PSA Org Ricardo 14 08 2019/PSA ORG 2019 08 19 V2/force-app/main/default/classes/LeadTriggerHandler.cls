/*
*   @Class : LeadTriggerHandler.cls
*
*   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
*   @Created        :   05 feb 2018
*   @Description    :   To manage leads trigger methods

*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Developer            Date                     Description
*      Ruben Moreno         05 feb 2018              Creation.
*      Ruben Moreno         22 may 2018              ##RM22/5/2018## Added the follow funcionality: if the lead is template lead, afterinsert dont works.
*      Ruben Moreno         25 may 2018              ##RM25/5/2018## Added the follow funcionality: if the LeadSource2__c = 329, afterinsert dont works.
*      Ruben Moreno         15 jun 2018              ##RM15/6/2018## Added the follow funcionality: update nurturing leads.
*      Ruben Moreno         22 aug 2018              ##RM22/8/2018## Added the follow funcionality: to calculate DestinationGeographicalCode__c for template leads.
*      Diego Rincon         29 jan 2019              Trigger bypassing logic added.
*   ----------------------------------------------------------------------------------------------------------------------------
*/
public with sharing class LeadTriggerHandler {

    private static boolean runtrigger = true;

    /*
     * @Method          :   shouldRunTrigger
     * @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   05 feb 2018
     * @Description     :   To get the flag that indicate if the trigger should run or not
     * @Params          :   -
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */
    public static boolean shouldRunTrigger() {
        return runtrigger;
    }

    /*
     * @Method          :   dontRunTrigger
     * @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   05 feb 2018
     * @Description     :   To indicate that the trigger should not run
     * @Params          :   -
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */
    public static void dontRunTrigger() {
        runtrigger = false;
    }

    /*
     * @Method          :   beforeInsert
     * @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   05 feb 2018
     * @Description     :   Call the actions that handle the before insert trigger.
     * @Params          :   List<Lead> records before the changes.
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
    public static void beforeInsert(List<Lead> lNewLeads) {
        // user / operation based trigger bypassing
        if (!PAD.canTrigger('Lead_BeforeInsert')) {
            return;
        }
        
        List<Lead> lLeadsConfigurator = new List<Lead>();//##RM25/5/2018##
     
        //##RM## To validate the RUT number populated.
        CL00_RUTValidation.mainFunction(lNewLeads);
        //##RM## To discard leads that matches with any blacklist record.
        LeadDiscardProcess.mainProcess(lNewLeads);

         // DXC: Added methods to handle Dealer Allocation - Custom Assigment //
        LeadHandleDiscardTime.handleDiscardTime(lNewLeads);
        // DXC: End Change //

        //##RM25/5/2018##  -  START CHANGE
        for (Lead oLead : lNewLeads) {
            if(oLead.TECH_TemplateLead__c == false && oLead.LeadSource2__c == '329')//##RM25/5/2018##
                lLeadsConfigurator.add(oLead);
        }

        if (!lLeadsConfigurator.isEmpty()) {
            MatchingConfiguratorLeadSource.mainProcess(lLeadsConfigurator);
        }
        
        //##RM25/5/2018##  -  END CHANGE
        
        //##RM## To update leads as nurturing lead.
        NurturingLeadProcess.mainProcess(lNewLeads);
        PopulateAllocationToPoS.populatePoSfieldsOnInsert(lNewLeads);
        LeadUtils.calcFields(lNewLeads);
        
        //To validate the NIF Format for Portugal
        PT00_NIFValidation.mainFunction(lNewLeads, true);
    }

    /*
     * @Method          :   beforeUpdate
     * @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   05 feb 2018
     * @Description     :   Call the actions that handle the before update trigger.
     * @Params          :   List<Lead> records after the changes, Map<Id, Lead> record before the changes
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */
    public static void beforeUpdate(List<Lead> lNewLeads, Map<Id, Lead> mapOldLeads) {
        // user / operation based trigger bypassing
        if (!PAD.canTrigger('Lead_BeforeUpdate')) {
            return;
        }

        LeadUtils.setCallCount(new Map<Id, Lead>(lNewLeads));

        //##RM## Beginning - To validate the RUT number populated.
        List<Lead> lLeadsToValidateRUT = new List<Lead>();
        List<Lead> lLeadsToChangeOwner = new List<Lead>();
        List<Lead> lLeadsToChangeActualTreatmentDate = new List<Lead>();
        List<Lead> lLeadsToValidateNIF = new List<Lead>();
        
        for (Lead l : lNewLeads) {
            if (l.NationalId__c != mapOldLeads.get(l.id).NationalId__c || l.FiscalId__c != mapOldLeads.get(l.id).FiscalId__c){
                lLeadsToValidateRUT.add(l);
            }
            if(l.OwnerId != mapOldLeads.get(l.Id).OwnerId){
                lLeadsToChangeOwner.add(l);
            }
            if(l.OwnerId != mapOldLeads.get(l.Id).OwnerId || l.Status != mapOldLeads.get(l.Id).Status){
                lLeadsToChangeActualTreatmentDate.add(l);
            }
            if(l.NationalId__c != mapOldLeads.get(l.id).NationalId__c || l.RecordTypeId != mapOldLeads.get(l.id).RecordTypeId || l.LeadCountry__c != mapOldLeads.get(l.id).LeadCountry__c){
                lLeadsToValidateNIF.add(l);
            }
        }

        if (!lLeadsToValidateRUT.isEmpty()) {
            CL00_RUTValidation.mainFunction(lLeadsToValidateRUT);
        }
        //##RM## End - To validate the RUT number populated.
         
        LeadSharing.grantAccessToLead(lNewLeads, mapOldLeads);
        // US 1051 - I: CALCULATED POS WAS ALWAYS INFORMED WITH VN, THAT'S NOT RIGHT
        // US C1STRUN-1343 I
        PopulateAllocationToPoS.populatePoSfields(lNewLeads, mapOldLeads);
        // US C1STRUN-1343 E
        // US 1051 - E
        
        /* BEIN - Manuel Medina - SDH_APV Merge - Line commented because method signature was changed to LeadUtils.setActualTreatmentDate(mapOldLeads, lNewLeads, 'UPDATE_LEAD'); - 03052019 */
        //LeadUtils.setTreatmentDate(mapOldLeads, lNewLeads);
        /* END - Manuel Medina - 03052019 */
        
        if(!lLeadsToChangeOwner.isEmpty()){
           LeadUtils.dtDueDate(lLeadsToChangeOwner, 'process'); 
        }

        //Execute only when a lead change Status or OwnerId
        if(!lLeadsToChangeActualTreatmentDate.isEmpty()){
            LeadUtils.setActualTreatmentDate(mapOldLeads, lNewLeads, 'UPDATE_LEAD');
        }

        //To validate the NIF Format for Portugal
        if(!lLeadsToValidateNIF.isEmpty()){
            PT00_NIFValidation.mainFunction(lNewLeads, false);
        }
    }

    /*
     * @Method          :   afterInsert
     * @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   05 feb 2018
     * @Description     :   Call the actions that handle the after insert trigger
     * @Params          :   List<Lead> records after the changes
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */
    public static void afterInsert(List<Lead> lNewLeads) {
        // user / operation based trigger bypassing
        if (!PAD.canTrigger('Lead_AfterInsert')) {
            return;
        }

        List<Lead> lLeadsToProcess          = new List<Lead>();
        List<Lead> lLeadsToProcessAssign    = new List<Lead>();
        Map<Id, List<Id>> mapOwnerToShare   = new Map<Id, List<Id>>();
        List<Id> lOwner;
        //##RM22/5/2018##
        for(Lead oLead : lNewLeads){
            lOwner = new List<Id>();
            if(/*oLead.TECH_TemplateLead__c == false && */oLead.LeadSource2__c != '329' && oLead.TECH_NurturingLead__c == false)//##RM25/5/2018##                
                lLeadsToProcess.add(oLead);
            if(oLead.Customer__c != null){
                lOwner.add(oLead.ownerId);
                mapOwnerToShare.put(oLead.Customer__c, lOwner);
            }
        }

        List<Lead> lstLeadsToUpdate = new List<Lead>([
            SELECT FirstName,LastName,Street,City,Country,PostalCode,Latitude,
            Longitude,Phone,NationalId__c,DestinationGeographicalCode__c,DestinationPOSCode__c,Company,BrandOwnedVehicle__c,
            Email,LeadCountry__c,Activity__c,CustomerType__c,LeadChannel__c,LeadRequestType__c,LeadSource,LeadType__c,CustomerContact__c,
            MarketingCode__c,BirthDate__c,TECH_DealerPdVInternal__c,FiscalId__c,VINOwnedVehicle__c,MobileProfessionalTelephone__c,
            LandlineProfessionalTelephone__c,RecordTypeId,LandlinePersonalTelephone__c,MobilePersonalTelephone__c,Customer__c,
            CalculatedPOS__c,LocalIdOfCustomer__c,CalculatedPOS__r.AgentFlag__c,CalculatedPOS__r.RAFlag__c, CalculatedPOS__r.TECH_AfterSalesManager__c,
            CalculatedPOS__r.TECH_SalesManager__c,CalculatedPOS__r.TECH_SalesManagerAgent__c,CalculatedPOS__r.LeadFilters__c,VehicleRegistrationNumber__c,
            PSABrand__c,TreatmentDueDate__c,OwnerId,CreatedDate,TECH_Web2Lead__c,TECH_isMysteryLead__c,TECH_TemplateLead__c, TECH_Web2LeadAssignment__c
            FROM Lead
            WHERE Id IN: lLeadsToProcess
        ]);//##RM22/5/2018##

        //##RM## Call to allocation matching class for match leads with B2B accounts, B2B accounts, B2B contacts.
        AllocationMatchingProcess.matchingProcess(lstLeadsToUpdate);
        
        // DXC: Added methods to handle Dealer Allocation - Custom Assigment //
        LeadDealerAllocation.setDealerAllocation(lstLeadsToUpdate);
        
        for(Lead oLead : lstLeadsToUpdate){//##RM22/8/2018##
            if(oLead.TECH_TemplateLead__c==false)
                lLeadsToProcessAssign.add(oLead);
        }

        LeadAssigmentProcess.handleAssigmentProcess(lLeadsToProcessAssign, false, false);
        
        UpdateRecords(lstLeadsToUpdate);
        UpdateRecords(lLeadsToProcessAssign);
        // DXC: END Change //
                
        //ManualSharingProcess
        ManualSharingProcess.ManualSharing(ManualSharingProcess.setRecordToShare(lNewLeads));
        
        if(!mapOwnerToShare.isEmpty()){
            System.debug('__________ENTRA: '+mapOwnerToShare);
            ManualSharingProcess.ManualSharing(mapOwnerToShare);
        }
        
        //#### to update TECH_COUNTERSALESMAN__C
        FlatAllocation.mainFunction(lNewLeads, null);
        LeadUtils.allocateWebToLeadRecords(lNewLeads);
    }

    /*
     * @Method          :   afterUpdate
     * @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   05 feb 2018
     * @Description     :   Call the actions that handle the after update trigger.
     * @Params          :   List<Lead> records after the changes, Map<Id, Lead> record before the changes
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
    public static void afterUpdate(List<Lead> lNewLeads, Map<Id, Lead> mapOldLeads) {
        // user / operation based trigger bypassing
        if (!PAD.canTrigger('Lead_AfterUpdate')) {
            return;
        }

        List<Lead> lLeadsSharing = new List<Lead>();
        List<Lead> lLeadsUpdated = new List<Lead>();
        List<Lead> lLeadsToChangeOwner = new List<Lead>();
        Map<Id, List<Id>> mapOwnerToShare = new Map<Id, List<Id>>();
        List<Id> lOwner;
        for(Lead l : lNewLeads){
            lOwner = new List<Id>();
            System.debug(' afterUpdate LEAD ' + l.latitude + ' Longitude ' + l.longitude);
            if((l.CalculatedPOS__c != null) && (l.CalculatedPOS__c != mapOldLeads.get(l.id).CalculatedPOS__c)){
                lLeadsSharing.add(l);
            }
            if((l.CalculatedPOS__c == null && l.latitude != null && l.longitude !=null)){
                lLeadsUpdated.add(l);
            }
            if((l.Customer__c != null) && (l.Customer__c != mapOldLeads.get(l.id).Customer__c)){
                lOwner.add(l.ownerId);
                mapOwnerToShare.put(l.Customer__c, lOwner);
            }/* SLC - else if((l.Customer__c != null) && (l.ownerId != mapOldLeads.get(l.id).ownerId)){
                lOwner.add(l.ownerId);
                mapOwnerToShare.put(l.Customer__c, lOwner);
            } SLC - */ 
            
            //if(l.OwnerId != mapOldLeads.get(l.Id).OwnerId){
            //    lLeadsToChangeOwner.add(l);
            //}
        }
        if(!mapOwnerToShare.isEmpty()){
            System.debug('__________ENTRA: '+mapOwnerToShare);
            ManualSharingProcess.ManualSharing(mapOwnerToShare);
        }
        if(!lLeadsSharing.isEmpty()){
            System.debug('__________ENTRA: '+lLeadsSharing);
            ManualSharingProcess.ManualSharing(ManualSharingProcess.setRecordToShare(lLeadsSharing));
        }

        SendEmailOwnerChanged.sendEmail(lNewLeads, mapOldLeads);
        //#### to update TECH_COUNTERSALESMAN__C
        FlatAllocation.mainFunction(lNewLeads, mapOldLeads);
        AccountTriggerHandler.isLeadConversionProcess = true;
        LeadUtils.startConversion(mapOldLeads, lNewLeads);
        LeadUtils.fireAllocation(mapOldLeads, lNewLeads);

        dontRunTrigger();
    }

    /*
     * @Method          :   UpdateRecords
     * @Author          :   DXC: Rubén Fernandez
     * @Created         :   07 feb 2018
     * @Description     :   Update the changes done on lead.
     * @Params          :   List<Lead> records after the changes, Map<Id, Lead> record before the changes
     * @Returns         :   Boolean. True if OK, otherwise False.
     */
    private static boolean UpdateRecords(List<Lead> lstUpdateLeads){
        System.debug('##>> LeadTriggerHandler START UpdateRecords <<: ' + lstUpdateLeads.size());
    
        if (!lstUpdateLeads.isEmpty()){
            try {
                Update lstUpdateLeads;
                return true;
            } catch (Exception e) {
                system.debug('### LeadTriggerHandler.UpdateRecords Error : ' + e.getMessage());
                return false;
            }
        }
        return false;
    }
    
}
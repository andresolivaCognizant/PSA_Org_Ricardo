/**
    *   @Class : APS009_ScheduleMysteryLeadsMain
    *
    *   @Author         :   Ruben Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
    *   @Created        :   17 5 2018
    *   @Description    :   
    
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description    
    *      Ruben Moreno             17/5/2018                Creation.      
    *   ----------------------------------------------------------------------------------------------------------------------------
**/

public class APS009_ScheduleMysteryLeadsMain implements Schedulable{
    
    String sSource;
    Integer iNumLeads;
    String sCountry;
    
    
    public APS009_ScheduleMysteryLeadsMain(String sSource,String sCountry,Integer iNumLeads){
        this.sSource        = sSource;
        this.iNumLeads      = iNumLeads;
        this.sCountry       = sCountry;
        
                
    }
        
    public void execute(SchedulableContext sc) {
        
        System.debug('ML_sSource: '+sSource);
        System.debug('ML_sSiteGeoId: '+sCountry);
        System.debug('ML_iNumLeads: '+iNumLeads);
        
        Integer iCountLeadToClone   = 0;
        List<Lead> lLeadsToClone    = new List<Lead>();
        List<Lead> lLeadsToInsert   = new List<Lead>(); 
        Set<id> setIdTemplateLead   = new Set<id>();
        

        
        for(Lead l : [SELECT FirstName,LastName,Street,City,Country,PostalCode,Latitude, Longitude,Phone,NationalId__c,DestinationGeographicalCode__c,DestinationPOSCode__c,Company,BrandOwnedVehicle__c,
            		  Email,LeadCountry__c,Activity__c,CustomerType__c,LeadChannel__c,LeadRequestType__c,LeadSource,LeadType__c,CustomerContact__c,MarketingCode__c,BirthDate__c,TECH_DealerPdVInternal__c,
                      FiscalId__c,VINOwnedVehicle__c,MobileProfessionalTelephone__c,LandlineProfessionalTelephone__c,RecordTypeId,LandlinePersonalTelephone__c,MobilePersonalTelephone__c,Customer__c,
            		  CalculatedPOS__c,LocalIdOfCustomer__c,CalculatedPOS__r.AgentFlag__c,CalculatedPOS__r.RAFlag__c, CalculatedPOS__r.TECH_AfterSalesManager__c,
                      CalculatedPOS__r.TECH_SalesManager__c,CalculatedPOS__r.TECH_SalesManagerAgent__c,CalculatedPOS__r.LeadFilters__c,VehicleRegistrationNumber__c,
                      PSABrand__c,TreatmentDueDate__c,OwnerId,CreatedDate,TECH_Web2Lead__c,TECH_isMysteryLead__c,TECH_TemplateLead__c FROM Lead where TECH_TemplateLead__c = true]){
                          
            if(!setIdTemplateLead.contains(l.id)){
                if(sSource == 'Email'){
                    if(l.Email != null && l.LeadCountry__c==sCountry){
                        if(iCountLeadToClone < iNumLeads){
                            lLeadsToClone.add(l);
                            if(l.DestinationGeographicalCode__c!=null){
                                setIdTemplateLead.add(l.Id);
                            }
                            
                        }
                        iCountLeadToClone += 1; 
                        continue;//to avoid duplicates.
                    }
    
                }else if(sSource == 'Phone'){
                    
                    if((l.Phone != null || l.LandlinePersonalTelephone__c!= null || l.LandlineProfessionalTelephone__c!= null || l.MobilePersonalTelephone__c!= null || l.MobileProfessionalTelephone__c!= null ) && l.LeadCountry__c==sCountry){
                        if(iCountLeadToClone < iNumLeads){
                            lLeadsToClone.add(l);
                            if(l.DestinationGeographicalCode__c!=null){
                                setIdTemplateLead.add(l.Id);
                            }
                        }
                        iCountLeadToClone += 1; 
                    }
                    
                }
                
            }
                
        }
        
        System.debug('ML_lLeadsToClone: '+lLeadsToClone);
        if(!lLeadsToClone.isEmpty()){
            
                
            lLeadsToInsert = lLeadsToClone.clone();
            
            for(Lead oLead : lLeadsToInsert){
                oLead.ownerId = UserInfo.getUserId();
                oLead.id = null;
                oLead.CreatedDate = null;
                oLead.TECH_Web2Lead__c = false;
                oLead.TECH_isMysteryLead__c = true;
                //oLead.DestinationGeographicalCode__c = sSiteGeoId;
                oLead.TECH_TemplateLead__c = false;
                //oLead.CalculatedPOS__c = null;
            }
            
            try{
                
                database.insert(lLeadsToInsert,true);
                System.debug('ML_setIdTemplateLead: '+setIdTemplateLead);
                List<Lead> lLeadsToDelete = [Select id from lead where Id IN :setIdTemplateLead AND TECH_TemplateLead__c = true]; 
                System.debug('ML_lLeadsToDelete EMPTY?: '+lLeadsToDelete);
                database.delete(lLeadsToDelete,true);
                System.debug('ML_lLeadsToInsert: '+lLeadsToInsert);
                
                
            }catch(System.DmlException e){
                System.debug('DmlException ERROR APS009_ScheduleMysteryLeadsMain -->' + e.getMessage() + ' Line: '+e.getLineNumber());
            }catch(Exception e){
                System.debug('Exception ERROR APS009_ScheduleMysteryLeadsMain-->' + e.getMessage() + ' Line: '+e.getLineNumber());
            }       
            
        }
                        

    }
    

}
/*
-- - Name         : LeadAssigmentProcess
-- - Author       : DXC. Ruben Fernandez
-- - Date         : 05/02/2018
-- - Description  : Custom Lead Assigment Process
--
-- - History:
-- Date         Author          Version  Comments
-- -----------  -----           -------  ---------------------------------------
-- 05/02/2018   DXC             1.0      Initial version rfernandezlo
-- 08/05/2018   RUBEN MORENO    1.1      Added conditions in if clause (Line 317 ##RM 8/5/18 ## )
-- 04/05/2018   RUBEN MORENO    1.2      Added checking holidays in the assignment.
-- 05/07/2018   DXC             1.3      Fixed issue (C1STRUN-346)	
-- 10/08/2018   DXC             1.4      Flat Allocation - Opportunity Owner. C1STAGILE-3607
-- 03/10/2018   DXC             1.5      Adding fix to known issue with Metadata query
-- 08/10/2018   RUBEN MORENO    1.6      Adding opportunity ordination by created date.
-- 30/10/2018   RUBEN MORENO    1.7      Fixed issue (C1STRUN-1012)
-- 20/02/2019   DIEGO RINCÓN    1.8      Second execution rules support added (C1STAGILE-6689).
*/
public with sharing class LeadAssigmentProcess {

    private static Map<String, LeadAssignmentRuleProcess__mdt> mapRules = new Map<String, LeadAssignmentRuleProcess__mdt>();
    private static Map<String, List<lead>> mapLeadsbyRules              = new Map<String, List<Lead>>();
    private static Map<Id,Account> mapDealerInfo                        = new Map<Id,Account>();
    private static Map<String, String> mapObjectTypeByPrefix            = new Map<String, String>();
    private static Map<Id,Id> mapOpportunityOwners                      = new Map<Id,Id>();
    private static Map<Id,String> mapAccountOppDestinations             = new Map<Id,String>();
    private static Map<Id,Id> mapDealerContacts                         = new Map<Id,Id>();
    private static Map<Id,List<Id>> mapAccountContacts                  = new Map<Id,List<Id>>();
    private static List<Lead> lstUpdatedLeads                           = new List<Lead>();
    private static final String GLOBAL_RULE                             = 'ALL';
    private static final String SALESMAN_ROLE                           = 'Worker';
    private static final List<String> SRA_ROLES                         = new List<String>{'Manager', 'Worker'};

    private static final Map<String, String> mapDays                     = new Map<String, String>{
        'Mon' => 'MondayStart__c',
        'Tue' => 'TuesdayStart__c',
        'Wed' => 'WednesdayStart__c',
        'Thu' => 'ThursdayStart__c',
        'Fri' => 'FridayStart__c',
        'Sat' => 'SaturdayStart__c',
        'Sun' => 'SundayStart__c'
    };

    /**
     * Fire lead assignment process based on the settings defined in
     * LeadAssignmentRuleProcess__mdt custom metadatata records.
     *
     * @author                              Rubén Fernández
     * @date                                2018-05-02
     * @param       lstLeads                list of leads to be assigned
     * @param       bUpdate                 specifies whether a DML operation
     *                                      is issued to store updated values
     * @param       isSecondExecution       specifies whether second execution
     *                                      rules should be taken into account
     *                                      for lead assignment
     * @return                              none
     */
    public static void handleAssigmentProcess(List<Lead> lstLeads, Boolean bUpdate, Boolean isSecondExecution) {

        System.debug('##>> LeadAssigmentProcess.handleAssigmentProcess START 1 << '+lstLeads +' // '+bUpdate);
        loadDefaultValues(isSecondExecution);
        String sType                    =   '';             // Contains the rule type to be applied
        Set<Id> setAccountIdCustomer    = new Set<Id>();    // To query opportunites\contacts\users
        Set<Id> setAccountIdDealer      = new Set<Id>();    // To query opportunites\contacts\users
        Boolean bPrioritize             = false;            // Indicates when the first rule must be applieded.
        List<Lead> lLeadPos             = new List<Lead>();

        // Optimized loop, better performance. 
        for (Integer i=0; i< lstLeads.size(); i++){
            AssignLeadsByRules(lstLeads.get(i));
            if(lstLeads.get(i).Customer__c!= null){
                setAccountIdCustomer.add(lstLeads.get(i).Customer__c);
            }
            System.debug('##>> LeadAssigmentProcess.handleAssigmentProcess START 2 << '  +lstLeads.get(i).CalculatedPOS__c);
            if(lstLeads.get(i).CalculatedPOS__c!= null){
                setAccountIdDealer.add(lstLeads.get(i).CalculatedPOS__c);
                lLeadPos.add(lstLeads.get(i));
            }
        }

        getOpportunityOwner(setAccountIdCustomer);
        getSalesManByDealer(setAccountIdDealer,lLeadPos);
        getDealersbyLead(setAccountIdDealer);

        system.debug('##>> mapLeadsbyRules: '+mapLeadsbyRules);
        for(String sPos : mapLeadsbyRules.keySet()){
            system.debug('##>> mapLeadsbyRules sPos: '+sPos);
            // Rule
            LeadAssignmentRuleProcess__mdt oLARP    = mapRules.get(sPos);
            // Leads
            List<Lead> lstAuxLeads = mapLeadsbyRules.get(sPos);
            sType                                   = oLARP.TargetType__c;
            bPrioritize                             = oLARP.PrioritizeknownSalesman__c;
            System.debug('##>> LeadAssigmentProcess.handleAssigmentProcess.sType : ' + sType + '  · bPrioritize: ' +bPrioritize);
            //Sales Manager, Sales Man, Queue, RANDOM
            if(sType=='Sales Manager'){
                /* start dxc 03/10/2018 */
                if(bPrioritize){
                    List<Lead> lstNotFoundLeads = FirstAssignmentBySalesMan(lstAuxLeads);
                    if(!lstNotFoundLeads.isEmpty()){
                        AssignLeadBySalesManager(lstNotFoundLeads,null);
                    }
                }else{
                    AssignLeadBySalesManager(lstAuxLeads,null);
                }

                /* end dxc 03/10/2018 */
                //AssignLeadBySalesManager(lstAuxLeads,null);
            }else if(sType=='Sales Man'){
                /* start dxc 03/10/2018 */
                if(bPrioritize){
                    List<Lead> lstNotFoundLeads = FirstAssignmentBySalesMan(lstAuxLeads);
                    if(!lstNotFoundLeads.isEmpty()){
                        AssignLeadBySalesMan(lstNotFoundLeads,oLARP.TargetValue__c);
                    }
                }else{
                    AssignLeadBySalesMan(lstAuxLeads,oLARP.TargetValue__c);
                }
                /* end dxc 03/10/2018 */
                //AssignLeadBySalesMan(lstAuxLeads,oLARP.TargetValue__c);
            }else if(sType=='Queue'){
                /* start dxc 03/10/2018 */
                if(bPrioritize){
                    List<Lead> lstNotFoundLeads = FirstAssignmentBySalesMan(lstAuxLeads);
                    if(!lstNotFoundLeads.isEmpty()){
                        AssignLeadBySalesQueue(lstNotFoundLeads,oLARP.TargetValue__c);
                    }
                }else{
                    AssignLeadBySalesQueue(lstAuxLeads,oLARP.TargetValue__c);
                }  
                /* end dxc 03/10/2018 */
                //AssignLeadBySalesQueue(lstAuxLeads,oLARP.TargetValue__c);
            }else if(sType=='RANDOM'){
                 /* start dxc 03/10/2018 */
                 if(bPrioritize){
                    List<Lead> lstNotFoundLeads = FirstAssignmentBySalesMan(lstAuxLeads);
                    if(!lstNotFoundLeads.isEmpty()){
                        // --> Updated by RM <-- //
                        AssignLeadBySalesmanLoad( lstNotFoundLeads, true );
                        // --> Updated by RM <-- //
                    }
                }else{
                    // --> Updated by RM <-- //
                    AssignLeadBySalesmanLoad( lstAuxLeads, false );
                    // --> Updated by RM <-- //
                }       
                /*end dxc 03/10/2018 */
                // --> Updated by RM <-- //
                //AssignLeadBySalesmanLoad(lstAuxLeads);
                // --> Updated by RM <-- //
            }       
        }
        system.debug('##>> lstLeads: '+lstLeads.size()+' // '+lstLeads);
        if(!lstLeads.isEmpty()){
            LeadUtils.dtDueDate(lstLeads, 'process');
            System.debug('*** TDD: '+lstLeads);
            if(bUpdate){
                UpdateRecords(lstLeads);
            }
        }
        System.debug('##>> LeadAssigmentProcess.handleAssigmentProcess END <<');
    }

    /*  Name        : FirstAssignmentBySalesMan
        Description : First Assigment. Assign Lead based on Sales Man
        @PARAM      : Lead --> Record to be assigned
        @OUTPUT     : list<Lead>. Not processed leads.
    */  
    private static list<Lead> FirstAssignmentBySalesMan(list<Lead> lstLeads){
        // Make sure sTargetValue is a QUEUE Id
        System.debug('##>> LeadAssigmentProcess.FirstAssignmentBySalesMan: ');
        list<Lead> lstNotFound  = new List<Lead>();
        Integer iSize           = lstLeads.size();
        for (Integer i=0; i< iSize; i++){
            System.debug('##>> LeadAssigmentProcess.FirstAssignmentBySalesMan.Customer__c :  ' + lstLeads.get(i).Customer__c + ' >> mapOpportunityOwners :  ' + mapOpportunityOwners.size());
            if(lstLeads.get(i).Customer__c!=null){
                if(mapOpportunityOwners.containsKey(lstLeads.get(i).Customer__c)){
                    lstLeads.get(i).OwnerId = mapOpportunityOwners.get(lstLeads.get(i).Customer__c);
                    lstUpdatedLeads.add(lstLeads.get(i));
                }else{
                    lstNotFound.add(lstLeads.get(i));
                }
            }else{
                lstNotFound.add(lstLeads.get(i));
            }
        }
        return lstNotFound;
    }

    /*  Name        : AssignLeadBySalesManager
        Description : Assign Lead Owner based on Sales Manager
        @PARAM      : Lead --> Record to be assigned
                    : sTargetValue --> New Owner / Criteria
        @OUTPUT     : Lead OwnerId updated with the new value
    */
    @TestVisible
    private static void AssignLeadBySalesManager(list<Lead> lstLeads, String sTargetValue){
        System.debug('##>> LeadAssigmentProcess.AssignLeadBySalesManager START <<##');  
        Integer iSize       = lstLeads.size();
        String sActivity    = '';
        for (Integer i=0; i< iSize; i++){
            System.debug('##>> LeadAssigmentProcess.AssignLeadBySalesManager.TECH_DealerAgentFlag__c :  ' + lstLeads.get(i).CalculatedPOS__c);
            // Case of an Agent Geo Site
            sActivity       = lstLeads.get(i).Activity__c;
            if(lstLeads.get(i).CalculatedPOS__c!=null){
                if(mapDealerInfo.get(lstLeads.get(i).CalculatedPOS__c)!=null && (mapDealerInfo.get(lstLeads.get(i).CalculatedPOS__c).AgentFlag__c || mapDealerInfo.get(lstLeads.get(i).CalculatedPOS__c).RAFlag__c)){
//                if(mapDealerInfo.get(lstLeads.get(i).CalculatedPOS__c).AgentFlag__c || mapDealerInfo.get(lstLeads.get(i).CalculatedPOS__c).RAFlag__c){
                    if( mapDealerInfo.get(lstLeads.get(i).CalculatedPOS__c).TECH_SalesManagerAgent__c != null){
                        lstLeads.get(i).OwnerId = mapDealerInfo.get(lstLeads.get(i).CalculatedPOS__c).TECH_SalesManagerAgent__c;    
                    }else{
                        setSalesManagerOwner(lstLeads.get(i),sActivity);
                    }
                }else{
                    setSalesManagerOwner(lstLeads.get(i),sActivity);
                }
            }
        }
        System.debug('##>> LeadAssigmentProcess.AssignLeadBySalesManager END <<##');
    }
    /*  Name        : setSalesManagerOwner
        Description : Assign Lead Owner based on Activity and After Sales Manager
        @PARAM      : Lead --> Record to be assigned
                    : sActivity --> Activity Type
        @OUTPUT     : void Lead OwnerId updated with the new value
    */ 
    @TestVisible
    private static void setSalesManagerOwner(Lead oLead, String sActivity){
        //System.debug('##>> LeadAssigmentProcess.setSalesManagerOwner START <<## Lead ' +  mapDealerInfo.get(oLead.CalculatedPOS__c).TECH_AfterSalesManager__c  + 
        //             ' <--> ' + mapDealerInfo.get(oLead.CalculatedPOS__c).TECH_AfterSalesManager__c + ' sActivity' + sActivity);
        if((sActivity.equals('APV') || sActivity.equals('ACC') || sActivity.equals('PR')) && mapDealerInfo.containsKey(oLead.CalculatedPOS__c) &&mapDealerInfo.get(oLead.CalculatedPOS__c).TECH_AfterSalesManager__c != null ){
            oLead.OwnerId       = mapDealerInfo.get(oLead.CalculatedPOS__c).TECH_AfterSalesManager__c;
            lstUpdatedLeads.add(oLead);
        }else{
            //System.debug('##>> LeadAssigmentProcess.setSalesManagerOwner: TECH_SalesManager__c ' + mapDealerInfo.get(oLead.CalculatedPOS__c).TECH_SalesManager__c);
            if(mapDealerInfo.get(oLead.CalculatedPOS__c) != null && mapDealerInfo.get(oLead.CalculatedPOS__c).TECH_SalesManager__c!=null){
                oLead.OwnerId   = mapDealerInfo.get(oLead.CalculatedPOS__c).TECH_SalesManager__c;
                lstUpdatedLeads.add(oLead);
            }
        }
        System.debug('##>> LeadAssigmentProcess.setSalesManagerOwner END <<##');
    }

    /*  Name        : AssignLeadBySalesMan
        Description : Assign Lead Owner based on Sales Man
        @PARAM      : Lead --> Record to be assigned
                    : sTargetValue --> New Owner / Criteria
        @OUTPUT     : Lead OwnerId updated with the new value
    */  
    @TestVisible
    private static void AssignLeadBySalesMan(list<Lead> lstLeads, String sTargetValue){
        // Make sure sTargetValue is a QUEUE Id
        System.debug('##>> LeadAssigmentProcess.AssignLeadBySalesMan: ' + sTargetValue);
        if(!String.isEmpty(sTargetValue)){
            Integer iSize   = lstLeads.size();
            for (Integer i=0; i< iSize; i++){
                lstLeads.get(i).OwnerId = (Id)sTargetValue;
                lstUpdatedLeads.add(lstLeads.get(i));
            }
        }else{
            Integer iSize   = lstLeads.size();
            for (Integer i=0; i< iSize; i++){
                System.debug('##>> LeadAssigmentProcess.AssignLeadBySalesMan.Customer__c :  ' + lstLeads.get(i).Customer__c + 
                             ' >> mapOpportunityOwners :  ' + mapOpportunityOwners.size());
                if(mapOpportunityOwners.containsKey(lstLeads.get(i).Customer__c)){
                    lstLeads.get(i).OwnerId = mapOpportunityOwners.get(lstLeads.get(i).Customer__c);
                    lstUpdatedLeads.add(lstLeads.get(i));
                }
            }
        }
    }
    /*  Name        : AssignLeadBySalesQueue
        Description : Assign Lead Owner based on a Queue
        @PARAM      : Lead --> Record to be assigned
                    : sTargetValue --> New Owner / Criteria
        @OUTPUT     : Lead OwnerId updated with the new value
    */
    @TestVisible
    private static void AssignLeadBySalesQueue(list<Lead> lstLeads, String sTargetValue){

        // Make sure sTargetValue is a QUEUE Id
        System.debug('##>> LeadAssigmentProcess.AssignLeadBySalesQueue: ' + mapObjectTypeByPrefix.containskey(sTargetValue.substring(0,3)));
        if(mapObjectTypeByPrefix.containskey(sTargetValue.substring(0,3))){
            System.debug('##>> LeadAssigmentProcess.AssignLeadBySalesQueue: ' + mapObjectTypeByPrefix.get(sTargetValue.substring(0,3)));
            if(mapObjectTypeByPrefix.get(sTargetValue.substring(0,3))=='GROUP'){
                System.debug('##>> LeadAssigmentProcess.AssignLeadBySalesQueue: ' + sTargetValue);
                Integer iSize   = lstLeads.size();
                for (Integer i=0; i< iSize; i++){
                    lstLeads.get(i).OwnerId = (Id)sTargetValue;
                    lstUpdatedLeads.add(lstLeads.get(i));
                }
            }
        }
    }

    /*  Name        : AssignLeadsByRules
        Description : Group all Leads by the rule assigned.
        @PARAM      : Lead --> Record to be assigned
        @OUTPUT     : Map updated with all assigments
    */
    private static void AssignLeadsByRules(Lead oLead){
        List<Lead> auxLeads = new List<Lead>();
        for(LeadAssignmentRuleProcess__mdt oRule : mapRules.values()){
            if(CheckRuleValues(oRule, oLead)){
                if(mapLeadsbyRules.containsKey(oRule.MasterLabel)){
                    auxLeads = mapLeadsbyRules.get(oRule.MasterLabel);
                }
                auxLeads.add(oLead);
                mapLeadsbyRules.put(oRule.MasterLabel, auxLeads);
                break;
            }
        }
    }
    /*  Name        : CheckRuleValues
        Description : Check when a record match a rule
        @PARAM      : Lead --> Record to match with the rule
                    : LeadAssignmentRuleProcess__mdt --> The meta data (The rule)
        @OUTPUT     : Boolean. True if lead match the rule, otherwise false
    */
    private static boolean CheckRuleValues(LeadAssignmentRuleProcess__mdt oRule, Lead oLead){
        System.debug('##>> LeadAssigmentProcess.CheckRuleValues START <<');     
        Boolean bResult = true;
        System.debug('##>> LeadAssigmentProcess.CheckRuleValues.' +
        ' Rule Name: '          + oRule.MasterLabel         +
        ' Activity__c: '        + oRule.Activity__c         + ' , ' +   oLead.Activity__c +
        ' Brand__c: '           + oRule.Brand__c            + ' , ' +   oLead.PSABrand__c +
        ' Country__c: '         + oRule.Country__c          + ' , ' +   oLead.LeadCountry__c +
        ' CustomerType__c: '    + oRule.CustomerType__c     + ' , ' +   oLead.CustomerType__c +
        ' LeadChannel__c: '     + oRule.LeadChannel__c      + ' , ' +   oLead.LeadChannel__c +
        ' LeadRequestType__c: ' + oRule.LeadRequestType__c  + ' , ' +   oLead.LeadRequestType__c +
        ' LeadSource__c: '      + oRule.LeadSource__c       + ' , ' +   oLead.LeadSource +
        ' LeadType__c: '        + oRule.LeadType__c         + ' , ' +   oLead.LeadType__c +
        ' DealerGrouping__c: '  + oRule.DealerGrouping__c   + ' , ' +   oLead.CalculatedPOS__c +
        ' PdVInternal__c: '     + oRule.PdVInternal__c      + ' , ' +   oLead.TECH_DealerPdVInternal__c +
        ' SiteGeoIdPK__c: '     + oRule.SiteGeoIdPK__c      + ' , ' +   oLead.DestinationGeographicalCode__c +
        ' MarketingCode__c: '   + oRule.MarketingCode__c    + ' , ' +   oLead.MarketingCode__c +
        ' Web 2 Lead: '   		+ oLead.TECH_Web2Lead__c );

        bResult = CheckFieldRuleValue(oRule.Activity__c,oLead.Activity__c,false);
        bResult = (bResult)?CheckFieldRuleValue(oRule.Brand__c,oLead.PSABrand__c,false):bResult;
        bResult = (bResult)?CheckFieldRuleValue(oRule.Country__c,oLead.LeadCountry__c,false):bResult;
        bResult = (bResult)?CheckFieldRuleValue(oRule.CustomerType__c,oLead.CustomerType__c,false):bResult;
        bResult = (bResult)?CheckFieldRuleValue(oRule.LeadChannel__c,oLead.LeadChannel__c,false):bResult;
        bResult = (bResult)?CheckFieldRuleValue(oRule.LeadRequestType__c,oLead.LeadRequestType__c,false):bResult;
        bResult = (bResult)?CheckFieldRuleValue(oRule.LeadSource__c,oLead.LeadSource,false):bResult;
        bResult = (bResult)?CheckFieldRuleValue(oRule.LeadType__c,oLead.LeadType__c,false):bResult;
        bResult = (bResult)?CheckFieldRuleValue(oRule.MarketingCode__c,oLead.MarketingCode__c,false):bResult;
        String  sAuxValue = (oLead.CalculatedPOS__c!=null?oLead.CalculatedPOS__r.LeadFilters__c:'');
        bResult = (bResult)?CheckFieldRuleValue(oRule.DealerGrouping__c,sAuxValue,true):bResult;
        bResult = (bResult)?CheckFieldRuleValue(String.ValueOf(oRule.PdVInternal__c), String.ValueOf(oLead.TECH_DealerPdVInternal__c),false):bResult;
        bResult = (bResult)?CheckFieldRuleValue(oRule.SiteGeoIdPK__c, oLead.DestinationGeographicalCode__c,false):bResult;

        if(oLead.TECH_Web2Lead__c && !oLead.TECH_Web2LeadAssignment__c){
            oLead.TECH_Web2LeadAssignment__c    = true;
        }
        System.debug('##>> LeadAssigmentProcess.CheckRuleValues.bResult: ' + bResult);
        System.debug('##>> LeadAssigmentProcess.CheckRuleValues END <<');
        return bResult;
    }
    /*  Name        : CheckFieldRuleValue
        Description : Check when a record field is equal to a match field rule
        @PARAM      : sKeyValue --> The rule value
                    : sFieldValue --> The record field value
        @OUTPUT     : Boolean. True if both values are equals, otherwise false
    */
    @TestVisible
    private static boolean CheckFieldRuleValue(String sKeyValue, String sFieldValue, Boolean bOption){      
        //System.debug('##>> LeadAssigmentProcess.CheckFieldRuleValue  key: ' + sKeyValue  + '  Value ' + sFieldValue );
        if(String.isEmpty(sKeyValue) && String.isEmpty(sFieldValue)){
            return true;
        }else if(!String.isEmpty(sKeyValue) && sKeyValue.equals(GLOBAL_RULE)){//##RM 8/5/18 ## before---> else if(sKeyValue.equals(GLOBAL_RULE))
             return true;
        }else{
            if(bOption){
                return (!String.isEmpty(sKeyValue) && !String.isEmpty(sFieldValue) && sKeyValue.indexOf(sFieldValue)>=0)?true:false;//##RM 8/5/18 ## before---> return (sKeyValue.indexOf(sFieldValue)>=0)?true:false;
            }else{
                return (!String.isEmpty(sKeyValue) && !String.isEmpty(sFieldValue) && sKeyValue.equals(sFieldValue))?true:false;//##RM 8/5/18 ## before---> return (sKeyValue.equals(sFieldValue))?true:false;
            }
        }
    }
    //* Name        : UpdateRecords
    //  Description : Update records
    //  @PARAM      : lstUpdateLeads --> List of Records to update
    //  @OUTPUT     : Boolean. True if success, otherwise false
    //*/
    @TestVisible
    private static boolean UpdateRecords(List<Lead> lstUpdateLeads){
        System.debug('##>> LeadAssigmentProcess START UpdateRecords <<: ' + lstUpdateLeads.size());
    
        if(!lstUpdateLeads.isEmpty()){
            try{
                Update lstUpdateLeads;
                return true;
            }catch(Exception e){
                system.debug('### LeadAssigmentProcess.UpdateRecords Error : ' + e.getMessage());
                return false;
            }
        }
        return false;
    }

    /**
     * Retrieve all active lead assignment rules and store them on a map.
     *
     * @author                              Rubén Fernández
     * @date                                2018-05-02
     * @param       isSecondExecution       specifies whether second execution
     *                                      rules should be queried
     * @return                              none
     */
    private static void loadDefaultValues(Boolean isSecondExecution){
        System.debug('##>> LeadAssigmentProcess.loadDefaultValues START <<');

        for (LeadAssignmentRuleProcess__mdt m : (Test.isRunningTest() ?
            [
                SELECT
                    MasterLabel,
                    QualifiedApiName,
                    Active__c,
                    Activity__c,
                    Brand__c,
                    Country__c,
                    CustomerType__c,
                    DealerGrouping__c,
                    LeadChannel__c,
                    LeadRequestType__c,
                    LeadSource__c,
                    LeadType__c,
                    MarketingCode__c,
                    Sort__c,
                    SiteGeoIdPK__c,
                    PdVInternal__c,
                    TargetType__c,
                    TargetValue__c,
                    PrioritizeknownSalesman__c
                FROM LeadAssignmentRuleProcess__mdt
                WHERE
                    Active__c = false AND
                    QualifiedApiName LIKE 'TECH_CONF%' AND
                    SecondExecution__c = :isSecondExecution
                ORDER BY Sort__c ASC
            ] :
            [
                SELECT
                    MasterLabel,
                    QualifiedApiName,
                    Active__c,
                    Activity__c,
                    Brand__c,
                    Country__c,
                    CustomerType__c,
                    DealerGrouping__c,
                    LeadChannel__c,
                    LeadRequestType__c,
                    LeadSource__c,
                    LeadType__c,
                    MarketingCode__c,
                    Sort__c,
                    SiteGeoIdPK__c,
                    PdVInternal__c,
                    TargetType__c,
                    TargetValue__c,
                    PrioritizeknownSalesman__c
                FROM LeadAssignmentRuleProcess__mdt
                WHERE
                    Active__c = true AND
                    SecondExecution__c = :isSecondExecution
                ORDER BY Sort__c ASC
            ]
        )) {
            mapRules.put(m.MasterLabel, m);
        }
        getObjectPrefix();
        System.debug('##>> LeadAssigmentProcess.loadDefaultValues END << '+mapRules);
    }

    /*  Name        : getObjectPrefix
        Description : Get system object prefix.
        @PARAM      : 
        @OUTPUT     : void. Map mapObjectTypeByPrefix updated.
    */
    private static void getObjectPrefix(){
        System.debug('##>> LeadAssigmentProcess.getObjectPrefix START <<');
       //Loop through all the sObject types returned by Schema
        for(Schema.SObjectType stype : Schema.getGlobalDescribe().values()){
            mapObjectTypeByPrefix.put(stype.getDescribe().getKeyPrefix(),stype.getDescribe().getName());
        }
        System.debug('##>> LeadAssigmentProcess.getObjectPrefix END << '+mapObjectTypeByPrefix);       
    }
    /*  Name        : getOpportunityOwner
        Description : Assign Lead Owner based on Sales Manager Random
        @PARAM      : setAccounts -->  Set of Account IDs
        @OUTPUT     : Map of Owners by Account
    */
    private static void getOpportunityOwner(Set<Id> setAccounts){
        /* start Ruben Moreno 22/10/2018 */
        
        /*AggregateResult[] groupedResults = [SELECT AccountId,OwnerId,MAX(CreatedDate) FROM Opportunity WHERE AccountId IN : setAccounts AND Owner.IsActive = true GROUP BY AccountId, OwnerId];
        for (AggregateResult ar : groupedResults)  {
            System.debug('#AccountId ID '+ ar.get('AccountId') + ' #OwnerId ' + ar.get('OwnerId'));
            mapOpportunityOwners.put( (Id)ar.get('AccountId'),(Id)ar.get('OwnerId'));
        }*/
        
        for (Opportunity opp : [SELECT AccountId,OwnerId,Createddate,DestinationPOSCode__c FROM Opportunity WHERE AccountId IN : setAccounts AND Owner.IsActive = true Order BY AccountId DESC ,Createddate asc])  {
            System.debug('#AccountId ID '+ opp.AccountId + ' #OwnerId ' + opp.OwnerId);
            mapOpportunityOwners.put(opp.AccountId,opp.OwnerId);
            mapAccountOppDestinations.put(opp.AccountId,opp.DestinationPOSCode__c);
        }
        
        /* end Ruben Moreno 22/10/2018 */        
    }
    /*  Name        : getDealersbyLead
        Description : All Dealers linked to the leads.
        @PARAM      : setAccounts -->  Set of Account IDs
        @OUTPUT     : Map of Dealers by Id
    */    
    private static void getDealersbyLead(Set<Id> setAccounts){
         mapDealerInfo  = new Map<Id, Account>([SELECT Id, AgentFlag__c,RAFlag__c,TECH_SalesManagerAgent__c,TECH_AfterSalesManager__c,TECH_SalesManager__c FROM Account WHERE Id IN : setAccounts]);
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------------------------->>
    // FLAT ALLOCATION: Ruben Moreno
    //---------------------------------------------------------------------------------------------------------------------------------------------------------------->>
    /*  Name        : getOpportunityOwner
        Author      : Ruben Moreno
        Description : Assign Lead Owner based on Sales Manager Random
        @PARAM      : setAccounts -->  Set of Account IDs
        @OUTPUT     : Map of Owners by Account
        A
    */
    public static void getSalesManByDealer(Set<Id> setAccounts, List<Lead> lLeadToProcess){

        if(!lLeadToProcess.isEmpty()) {
            LeadUtils.dtDueDate(lLeadToProcess, 'process');
        }

        String sDay                         = '';
        map <id,datetime> mapIdDealerDtime  = new map <id,datetime>();
        map <id,id> mapIdUserDealer         = new map <id,id>();
        List<User> lUserCounter             = new List<User>();

        for(Lead l : lLeadToProcess){
            mapIdDealerDtime.put(l.CalculatedPOS__c, l.TreatmentDueDate__c);
        }

        System.debug('______________>'+mapIdDealerDtime);

        for (User usrAux : [
            SELECT
                Id,
                Username,
                ContactId,
                Contact.AccountId,
                MondayStart__c,
                MondayEnd__c,
                TuesdayStart__c,
                TuesdayEnd__c,
                WednesdayStart__c,
                WednesdayEnd__c,
                ThursdayStart__c,
                ThursdayEnd__c,
                FridayStart__c,
                FridayEnd__c,
                SaturdayStart__c,
                SaturdayEnd__c,
                SundayStart__c,
                SundayEnd__c,
                HolidayStart__c,
                HolidayEnd__c,
                TimeZoneSidKey
            FROM User
            WHERE
                (ContactId IN : mapOpportunityOwners.keySet() OR  Contact.AccountId IN : setAccounts)
                AND UserRoleId IN (SELECT Id FROM UserRole WHERE PortalRole IN : SRA_ROLES)
                AND Contact.AvailableLeadTreatment__c = true AND IsActive = true
            ORDER BY Contact.TECH_CounterSalesman__c ASC
        ]){
            System.debug('##RM## LAP__ usrAux:'+usrAux);
            mapDealerContacts.put(usrAux.ContactId, usrAux.Id);
            mapIdUserDealer.put(usrAux.Id,usrAux.Contact.AccountId);
            lUserCounter.add(usrAux);
        }

        if(!lUserCounter.isEmpty()){

            for(User usrAux : lUserCounter){
                
                /* BEGIN - Manuel Medina - Bug C1STAGILE-4376 fix; adding one day to validate if an user has or not holidays for tomorrow - 19082018 */
                //if(usrAux.HolidayStart__c != null && usrAux.HolidayEnd__c != null && usrAux.HolidayStart__c <= System.today().Adddays(1) && System.today() <= usrAux.HolidayEnd__c){
                if(usrAux.HolidayStart__c != null && usrAux.HolidayEnd__c != null && mapIdUserDealer.get(usrAux.id)!=null && mapIdDealerDtime.get(mapIdUserDealer.get(usrAux.id))!=null && usrAux.HolidayStart__c <= mapIdDealerDtime.get(mapIdUserDealer.get(usrAux.id)) && mapIdDealerDtime.get(mapIdUserDealer.get(usrAux.id)) <= usrAux.HolidayEnd__c.adddays(1)){
                /* END - Manuel Medina - 19082018 */
                
                   System.debug('##RM## LAP__ EN VACACIONES 1:'+usrAux.Username);
                   System.debug('##RM## LAP__ EN VACACIONES AccountId 1:'+usrAux.Contact.AccountId);
                   System.debug('##RM## LAP__ EN VACACIONES usrAux 1:'+usrAux);
                   continue;   
                    
               }else if(mapIdUserDealer.get(usrAux.id)!=null && mapIdDealerDtime.get(mapIdUserDealer.get(usrAux.id))!=null){
    
                    /* BEGIN Ruben Fernandez 25092018 US: C1STAGILE-4837 */
                    Datetime dtNowWithTimeZone      = LeadUtils.dtAdjustTimeZone(mapIdDealerDtime.get(mapIdUserDealer.get(usrAux.id)), usrAux.TimeZoneSidKey);
                    List<String> lTimeNow           = String.valueof(dtNowWithTimeZone).split(' ')[1].split(':');
                    // List<String> lTimeNow = String.valueof(System.now()).split(' ')[1].split(':');
                    /* END - Ruben Fernandez - 25092018 */

                   //Time tNow = Time.newInstance(Integer.valueof(lTimeNow[0]),Integer.valueof(lTimeNow[1]),0,0);

                   // current datetime is shifted to salesman's time zone to perform calculations
                   // using the same reference - C1STRUN-1499
                   DateTime adjusted_now_dt =  Datetime.valueOfGmt(
                       System.now().format('yyyy-MM-dd HH:mm:ss', usrAux.TimeZoneSidKey)
                   );
 
                   Time tNow = adjusted_now_dt.timeGmt();

                   switch on mapIdDealerDtime.get(mapIdUserDealer.get(usrAux.id)).format('EEE'){
                       when 'Mon'{
                           sDay = saveContacts(usrAux, usrAux.MondayStart__c, usrAux.MondayEnd__c, 'Mon', tNow); 
                       }
                       when 'Tue'{
                           sDay = saveContacts(usrAux, usrAux.TuesdayStart__c, usrAux.TuesdayEnd__c, 'Tue', tNow); 
                       }
                       when 'Wed'{
                           sDay = saveContacts(usrAux, usrAux.WednesdayStart__c, usrAux.WednesdayEnd__c, 'Wed', tNow); 
                       }                       
                       when 'Thu'{
                           sDay = saveContacts(usrAux, usrAux.ThursdayStart__c, usrAux.ThursdayEnd__c, 'Thu', tNow); 
                       }
                       when 'Fri'{
                           sDay = saveContacts(usrAux, usrAux.FridayStart__c, usrAux.FridayEnd__c, 'Fri', tNow); 
                       }
                       when 'Sat'{
                           sDay = saveContacts(usrAux, usrAux.SaturdayStart__c, usrAux.SaturdayEnd__c, 'Sat', tNow); 
                       }
                       when 'Sun'{
                           sDay = saveContacts(usrAux, usrAux.SundayStart__c, usrAux.SundayEnd__c, 'Sun', tNow); 
                       }
                   }
                   
               }
            }
        }

        if(mapAccountContacts.isEmpty()){//there is not assignation. The assignation will be tomorrow.
            System.debug('##RM## LAP__ 3. horas ....');

            String sSetAccount = '';
            String sSetOppOwners = '';

            for(Id i :mapOpportunityOwners.keySet()){
                sSetOppOwners = sSetOppOwners + '\'' + i + '\',';
            }

            if(sSetOppOwners!= ''){
                sSetOppOwners = '(' + sSetOppOwners.removeEnd(',') + ')';
            }

            for(Id i :setAccounts){
                sSetAccount = sSetAccount + '\'' + i + '\',';
            }
             
            if(sSetAccount!= ''){
                sSetAccount = '(' +  sSetAccount.removeEnd(',')  + ')';
            }

            String sQuery;

            if(sSetAccount != '' && sSetOppOwners!= ''){

                sQuery = 'SELECT Id, Username,Contactid, Contact.AccountId,MondayStart__c,MondayEnd__c,TuesdayStart__c,TuesdayEnd__c,WednesdayStart__c,WednesdayEnd__c,' +
                'ThursdayStart__c,ThursdayEnd__c,FridayStart__c,FridayEnd__c,SaturdayStart__c,SaturdayEnd__c,SundayStart__c, SundayEnd__c,HolidayStart__c,' +
                'HolidayEnd__c,TimeZoneSidKey FROM User  Where (ContactId IN ' + sSetOppOwners + ' OR  Contact.AccountId IN '+ sSetAccount +') AND ' +
                'UserRoleId IN (SELECT Id FROM UserRole WHERE PortalRole IN :SRA_ROLES) AND Contact.AvailableLeadTreatment__c=true AND IsActive=true ' +
                'order by ' + mapDays.get(sDay) + ' ASC NULLS LAST , Contact.TECH_CounterSalesman__c ASC';
                
            }else if(sSetAccount == '' && sSetOppOwners== ''){
                //setAccounts can not be null
                sQuery = null;
                
            }else if(sSetAccount != '' && sSetOppOwners== ''){
                
                sQuery = 'SELECT Id, Username,Contactid, Contact.AccountId,MondayStart__c,MondayEnd__c,TuesdayStart__c,TuesdayEnd__c,WednesdayStart__c,WednesdayEnd__c,' +
                'ThursdayStart__c,ThursdayEnd__c,FridayStart__c,FridayEnd__c,SaturdayStart__c,SaturdayEnd__c,SundayStart__c, SundayEnd__c,HolidayStart__c,' +
                'HolidayEnd__c,TimeZoneSidKey FROM User  Where Contact.AccountId IN '+ sSetAccount +' AND ' +
                'UserRoleId IN (SELECT Id FROM UserRole WHERE PortalRole IN :SRA_ROLES) AND Contact.AvailableLeadTreatment__c=true AND IsActive=true ' +
                'order by ' + mapDays.get(sDay) + ' ASC NULLS LAST , Contact.TECH_CounterSalesman__c ASC';
                
            } else if (sSetAccount == '' && sSetOppOwners!= '') {
                //setAccounts can not be null
                sQuery = null;
            }

            List<User> LUsrAux = new List<User>();
            SYSTEM.DEBUG('##RM## LAP__ sQuery: '+sQuery);
            try {
                LUsrAux = (!test.isRunningTest())?database.query(sQuery):[SELECT Id, Username,Contactid, Contact.AccountId,MondayStart__c,MondayEnd__c,TuesdayStart__c,TuesdayEnd__c,WednesdayStart__c,WednesdayEnd__c,
                ThursdayStart__c,ThursdayEnd__c,FridayStart__c,FridayEnd__c,SaturdayStart__c,SaturdayEnd__c,SundayStart__c, SundayEnd__c,HolidayStart__c,
                HolidayEnd__c,TimeZoneSidKey FROM User  Where ContactId != null LIMIT 10];
            } catch(Exception e) {
                System.debug('ERROR: '+ e);
            }

            if (LUsrAux!=null && !LUsrAux.isEmpty()) {
                
                for(User usrAux : LUsrAux){
                    System.debug('##RM## LAP__ usrAux 2:'+usrAux);

                    if (usrAux.HolidayStart__c != null && usrAux.HolidayEnd__c != null && mapIdUserDealer.get(usrAux.id)!=null && mapIdDealerDtime.get(mapIdUserDealer.get(usrAux.id))!=null && usrAux.HolidayStart__c <= mapIdDealerDtime.get(mapIdUserDealer.get(usrAux.id)) && mapIdDealerDtime.get(mapIdUserDealer.get(usrAux.id)) <= usrAux.HolidayEnd__c.adddays(1)){
                        System.debug('##RM## LAP__ EN VACACIONES 2:'+usrAux.Username);
                        System.debug('##RM## LAP__ EN VACACIONES AccountId 2:'+usrAux.Contact.AccountId);
                        System.debug('##RM## LAP__ EN VACACIONES usrAux 2:'+usrAux);
                        continue;
                    } else {
                        System.debug('##RM## LAP__ there are some salesmans working...' +usrAux.Contact.AccountId);
                        if(mapAccountContacts.containsKey(usrAux.Contact.AccountId)){
                            mapAccountContacts.get(usrAux.Contact.AccountId).add(usrAux.ContactId);      
                        }else{
                            mapAccountContacts.put(usrAux.Contact.AccountId,new List<Id>{usrAux.ContactId});
                        }
                        
                    }
                }
            }
            
        }
        
        System.debug('##RM## LAP__ 2 mapAccountContacts:'+mapAccountContacts);

        if(mapAccountContacts.isEmpty() || (test.isRunningTest())){//there is not assignation. The assignation will be checking the holidays.

            System.debug('##RM## LAP__ 3. vacaciones ....');

            for (User usrAux : (!test.isRunningTest()) ? 
                [
                    SELECT
                        Id,
                        Username,
                        ContactId,
                        Contact.AccountId,
                        MondayStart__c,
                        MondayEnd__c,
                        TuesdayStart__c,
                        TuesdayEnd__c,
                        WednesdayStart__c,
                        WednesdayEnd__c,
                        ThursdayStart__c,
                        ThursdayEnd__c,
                        FridayStart__c,
                        FridayEnd__c,
                        SaturdayStart__c,
                        SaturdayEnd__c,
                        SundayStart__c,
                        SundayEnd__c,
                        HolidayStart__c,
                        HolidayEnd__c,
                        TimeZoneSidKey
                    FROM User
                    WHERE
                        (ContactId IN : mapOpportunityOwners.keySet() OR Contact.AccountId IN : setAccounts) AND
                        UserRoleId IN (SELECT Id FROM UserRole WHERE PortalRole =: SALESMAN_ROLE) AND
                        Contact.AvailableLeadTreatment__c = true AND
                        IsActive = true
                    ORDER BY HolidayEnd__c ASC NULLS LAST
                ] : [
                    SELECT
                        Id,
                        Username,
                        ContactId,
                        Contact.AccountId,
                        MondayStart__c,
                        MondayEnd__c,
                        TuesdayStart__c,
                        TuesdayEnd__c,
                        WednesdayStart__c,
                        WednesdayEnd__c,
                        ThursdayStart__c,
                        ThursdayEnd__c,
                        FridayStart__c,
                        FridayEnd__c,
                        SaturdayStart__c,
                        SaturdayEnd__c,
                        SundayStart__c,
                        SundayEnd__c,
                        HolidayStart__c,
                        HolidayEnd__c,
                        TimeZoneSidKey
                    FROM User
                    WHERE ContactId != null
                    LIMIT 10
                ]
            ){
                if (mapAccountContacts.containsKey(usrAux.Contact.AccountId)){
                    mapAccountContacts.get(usrAux.Contact.AccountId).add(usrAux.ContactId);
                } else {
                    mapAccountContacts.put(usrAux.Contact.AccountId,new List<Id>{usrAux.ContactId});
                }
            }
        }
    }

    /**
     * Assign lead owner based on dealer's salesmen load. This version
     * implements C1STAGILE-6444.
     *
     * @author                          Diego Rincón
     * @date                            2019-03-26
     * @param       lstLeads            leads to be assigned
     * @param       blnPrioritize       specifies whether exisiting
     *                                  opportunities should be taken
     *                                  into account
     * @return                          none
     */
    @TestVisible
    private static void AssignLeadBySalesmanLoad(List<Lead> lstLeads, Boolean blnPrioritize ){
        System.debug('*****************    AssignLeadBySalesmanLoad     ******************');
        List<Lead> lst_flat = new List<Lead>();

        for (Lead l : lstLeads) {
            if (
                blnPrioritize &&
                null != l.Customer__c &&
                mapOpportunityOwners.containsKey(l.Customer__c) &&
                null != mapAccountOppDestinations.get(l.Customer__c) &&
                l.DestinationPOSCode__c == mapAccountOppDestinations.get(l.Customer__c)
            ) {
                l.OwnerId = mapOpportunityOwners.get(l.Customer__c);
            } else if (
                !mapAccountContacts.values().isEmpty() &&
                null != l.CalculatedPOS__c != null &&
                mapAccountContacts.containsKey(l.CalculatedPOS__c)
            ) {
                lst_flat.add(l);
            }
        }

        if (!lst_flat.isEmpty()) {
            LeadUtils.flatAssignment(
                lst_flat,
                LeadUtils.eventsQualifyingOwners(
                    lst_flat,
                    LeadUtils.activityQualifyingOwners(lst_flat, mapAccountContacts)
                )
            );
        }
    }
    
    private static String saveContacts(User usrAux, Time startDate, Time endDate, String sDayStr, Time tNow){
        
        String sDay = ''; 
        if((startDate <= tNow && tNow <= endDate)|| startDate == null || endDate == null){
            if(mapAccountContacts.containsKey(usrAux.Contact.AccountId)){
                mapAccountContacts.get(usrAux.Contact.AccountId).add(usrAux.ContactId);      
            }else{
                mapAccountContacts.put(usrAux.Contact.AccountId,new List<Id>{usrAux.ContactId});
            }
        }else if(startDate> tNow){
            sDay = sDayStr;
            
        }
        return sDay; 

    }
       
}
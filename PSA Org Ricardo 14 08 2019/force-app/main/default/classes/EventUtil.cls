global with sharing class EventUtil {

    private static final string TOKEN = '##';
    private static final string DUEDATE_NOW = 'NOW';

    global class WrapperActivity {
        @InvocableVariable
           global Id idsObject;
        
        @InvocableVariable
           global string sNameActivityProcess;
        
        @InvocableVariable
           global Id idAssignedTo;
    }

    @InvocableMethod(label='Create Activity')
    public static void createActivity(List<WrapperActivity> lWrActivity){

        if(lWrActivity!=null && !lWrActivity.isEmpty() && lWrActivity[0].sNameActivityProcess!=null && lWrActivity[0].idAssignedTo!=null && lWrActivity[0].idsObject!=null){

            String sSelectQuery = '';
            String sWhereQuery = '';

            List<ActivityManagement__mdt> lDataActivity = [SELECT MappingFieldsTarget__c,DueDate__c,Duration__c,DueDateComplement__c,EventType__c,Priority__c,SourceObject__c,StartDate__c,Status__c,Subject__c,TargetObject__c,Type__c
                                                            FROM ActivityManagement__mdt
                                                               WHERE label= :lWrActivity[0].sNameActivityProcess];

            System.debug('lDataActivity-->'+lDataActivity);
            if (lDataActivity!=null && !lDataActivity.isEmpty()) {
                try {

                    Map<String, String> mapFieldsTarget = (Map<String,String>) JSON.deserialize(lDataActivity[0].MappingFieldsTarget__c, Map<String,String>.class);
                    sObject sObjTarget;//Activity sObjTargetect

                    // creating activity object
                    if(lDataActivity[0].TargetObject__c!=null && lDataActivity[0].SourceObject__c!=null){
                         sObjTarget = Schema.getGlobalDescribe().get(lDataActivity[0].TargetObject__c).newsObject();
                    }

                    if(sObjTarget!=null){
                        sObjTarget.put('RecordTypeId',[SELECT id from RecordType where SobjectType =:lDataActivity[0].TargetObject__c AND Name = :lDataActivity[0].EventType__c].Id);//RECORDTYPE
                        sObjTarget.put('WhoId',lWrActivity[0].idsObject);//WHO
                        sObjTarget.put('OwnerId',lWrActivity[0].idAssignedTo);//ASSIGNTO(OWNER)                        
                        sObjTarget.put(mapFieldsTarget.get('Duration__c'), (Integer)lDataActivity[0].Duration__c); //duration

                        if(lDataActivity[0].DueDate__c!=null && lDataActivity[0].DueDate__c.contains(TOKEN)){
                            sSelectQuery += lDataActivity[0].DueDate__c.replace(TOKEN,'') + ', ';
                        }

                        if(lDataActivity[0].Priority__c!=null && lDataActivity[0].Priority__c.contains(TOKEN)){
                            sSelectQuery += 'toLabel('+lDataActivity[0].Priority__c.replace(TOKEN,'') + ') , ';
                        }

                        if(lDataActivity[0].Status__c!=null && lDataActivity[0].Status__c.contains(TOKEN)){
                            sSelectQuery += 'toLabel('+lDataActivity[0].Status__c.replace(TOKEN,'') + ') , ';
                        }

                        if(lDataActivity[0].Type__c!=null && lDataActivity[0].Type__c.contains(TOKEN)){
                            sSelectQuery += 'toLabel('+lDataActivity[0].Type__c.replace(TOKEN,'') + ') , ';
                        }

                        if(lDataActivity[0].Subject__c!=null && lDataActivity[0].Subject__c.contains(TOKEN)){
                            sSelectQuery += 'toLabel('+lDataActivity[0].Subject__c.replace(TOKEN,'') + ') , ';
                        }

                        if(sSelectQuery!=''){
                            String sQuery = 'SELECT '+sSelectQuery.removeEnd(' , ')+' FROM '+lDataActivity[0].SourceObject__c+' WHERE id = \''+lWrActivity[0].idsObject+'\'';
                            System.debug('QUERY: '+sQuery);

                            String listType = 'List<' + lDataActivity[0].SourceObject__c + '>';
                               List<SObject> lcastRecords = (List<SObject>)Type.forName(listType).newInstance();

                            lcastRecords = Database.query(sQuery);

                            if(lcastRecords!=null && !lcastRecords.isEmpty()){
                                List <String> lDate = new List <String>();
                                List <String> lDateFormat = new List <String>();
                                List <String> lTime = new List <String>();

                                System.debug('lDataActivity[0].DueDate__c: '+lDataActivity[0].DueDate__c);
                                if(lDataActivity[0].DueDate__c.toUpperCase().contains(DUEDATE_NOW)){ //NOW
                                    System.debug(' DueDate__c: '+lDataActivity[0].DueDate__c);
                                    System.debug(' DueDateComplement__c: '+lDataActivity[0].DueDateComplement__c);
                                    DateTime dtDueDate = system.now().addHours((Integer)lDataActivity[0].DueDateComplement__c);
                                    sObjTarget.put(mapFieldsTarget.get('DueDate__c'), dtDueDate);                                            

                                    //startDate = dueDate - Duration (Not configured in Custom Metadata type)
                                     sObjTarget.put(mapFieldsTarget.get('StartDate__c'), dtDueDate.addMinutes(((Integer)lDataActivity[0].Duration__c)*(-1)));  

                                }else if(!lDataActivity[0].DueDate__c.contains(TOKEN)){ //SPECIFIC VALUE 
                                    sObjTarget.put(mapFieldsTarget.get('DueDate__c'), lDataActivity[0].DueDate__c);                                            

                                    //startDate = dueDate - Duration (Not configured in Custom Metadata type)
                                    lDate = lDataActivity[0].DueDate__c.split(' ');
                                    lTime = lDate[1].split(':');
                                    lDateFormat = lDate[0].split('-');

                                    DateTime dtDueDate = DateTime.newInstanceGmt(Integer.valueOf(lDateFormat[0]), Integer.valueOf(lDateFormat[1]), Integer.valueOf(lDateFormat[2]), Integer.valueOf(lTime[0]), Integer.valueOf(lTime[1]), Integer.valueOf(lTime[2]));
                                    sObjTarget.put(mapFieldsTarget.get('StartDate__c'), dtDueDate.addMinutes(((Integer)lDataActivity[0].Duration__c)*(-1)));  

                                }else{//DUEDATE INHERITED OF OBJECT
                                    sObjTarget.put(mapFieldsTarget.get('DueDate__c'), lcastRecords[0].get(lDataActivity[0].DueDate__c.replace(TOKEN,'')));

                                    //startDate = dueDate - Duration (Not configured in Custom Metadata type)
                                    lDate = String.valueof(lcastRecords[0].get(lDataActivity[0].DueDate__c.replace(TOKEN,''))).split(' ');
                                    lTime = lDate[1].split(':');
                                    lDateFormat = lDate[0].split('-');
                                    
                                    DateTime dtDueDate = DateTime.newInstanceGmt(Integer.valueOf(lDateFormat[0]), Integer.valueOf(lDateFormat[1]), Integer.valueOf(lDateFormat[2]), Integer.valueOf(lTime[0]), Integer.valueOf(lTime[1]), Integer.valueOf(lTime[2]));
                                    sObjTarget.put(mapFieldsTarget.get('StartDate__c'), dtDueDate.addMinutes(((Integer)lDataActivity[0].Duration__c)*(-1)));                               
                                }

                                if(!lDataActivity[0].Priority__c.contains(TOKEN)){//priority
                                    sObjTarget.put(mapFieldsTarget.get('Priority__c'), lDataActivity[0].Priority__c);

                                }else{
                                    sObjTarget.put(mapFieldsTarget.get('Priority__c'), lcastRecords[0].get(lDataActivity[0].Priority__c.replace(TOKEN,'')));
                                }

                                if(!lDataActivity[0].Status__c.contains(TOKEN)){//status
                                    sObjTarget.put(mapFieldsTarget.get('Status__c'), lDataActivity[0].Status__c);
                                }else{
                                    sObjTarget.put(mapFieldsTarget.get('Status__c'), lcastRecords[0].get(lDataActivity[0].Status__c.replace(TOKEN,'')));
                                }
                                
                                if(!lDataActivity[0].Type__c.contains(TOKEN)){//type
                                    sObjTarget.put(mapFieldsTarget.get('Type__c'), lDataActivity[0].Type__c);
                                }else{
                                    sObjTarget.put(mapFieldsTarget.get('Type__c'), lcastRecords[0].get(lDataActivity[0].Type__c.replace(TOKEN,'')));
                                }
                                
                                if(!lDataActivity[0].Subject__c.contains(TOKEN)){//subject
                                    sObjTarget.put(mapFieldsTarget.get('Subject__c'), lDataActivity[0].Subject__c);
                                }else{
                                    sObjTarget.put(mapFieldsTarget.get('Subject__c'), lcastRecords[0].get(lDataActivity[0].Subject__c.replace(TOKEN,'')));
                                }
                            }

                        } else {
                            List <String> lDate = new List <String>();
                            List <String> lDateFormat = new List <String>();
                            List <String> lTime = new List <String>();

                            if(lDataActivity[0].DueDate__c.toUpperCase().contains(DUEDATE_NOW)){ //NOW
                                DateTime dtDueDate = system.now().addHours((Integer)lDataActivity[0].DueDateComplement__c);
                                sObjTarget.put(mapFieldsTarget.get('DueDate__c'), dtDueDate);                                            
                                
                                //startDate = dueDate - Duration (Not configured in Custom Metadata type)
                                sObjTarget.put(mapFieldsTarget.get('StartDate__c'), dtDueDate.addMinutes(((Integer)lDataActivity[0].Duration__c)*(-1)));  
                                
                            }else if(!lDataActivity[0].DueDate__c.contains(TOKEN)){ //SPECIFIC VALUE 
                                sObjTarget.put(mapFieldsTarget.get('DueDate__c'), lDataActivity[0].DueDate__c);                                            
                                
                                //startDate = dueDate - Duration (Not configured in Custom Metadata type)
                                lDate = lDataActivity[0].DueDate__c.split(' ');
                                lTime = lDate[1].split(':');
                                lDateFormat = lDate[0].split('-');
                                
                                DateTime dtDueDate = DateTime.newInstanceGmt(Integer.valueOf(lDateFormat[0]), Integer.valueOf(lDateFormat[1]), Integer.valueOf(lDateFormat[2]), Integer.valueOf(lTime[0]), Integer.valueOf(lTime[1]), Integer.valueOf(lTime[2]));
                                sObjTarget.put(mapFieldsTarget.get('StartDate__c'), dtDueDate.addMinutes(((Integer)lDataActivity[0].Duration__c)*(-1)));  
                                
                            }   
                            
                            sObjTarget.put(mapFieldsTarget.get('Priority__c'), lDataActivity[0].Priority__c);
                            sObjTarget.put(mapFieldsTarget.get('Type__c'), lDataActivity[0].Type__c);
                            sObjTarget.put(mapFieldsTarget.get('Subject__c'), lDataActivity[0].Subject__c);
                        }
                        
                        // insert the activity
                        Database.insert(sObjTarget);
                    }
                    System.debug('______sObjTarget______ '+sObjTarget);
                }catch(Exception e){
                    System.debug('EventUtil.createActivity ERROR -->' + e.getMessage() + ' Line: '+e.getLineNumber());
                }
            }
        }
    }

    /**
     * TODO
     * This method is intended to replicate, bulkifie and simplifie the behaviour of the method EventUtil.createActivity() 
     *
     * @author				Ricardo Pereira
     * @date				2019-01-30
     * @param				TBD
     * @return				TBD
     */
    /*public static void createActivityTODO(List<WrapperActivity> lWrActivity){
        
        if(lWrActivity!=null && !lWrActivity.isEmpty()){
            
            Set<String> setActivityProcessNames = new Set<String>();
            Set<String> setAssigneToIds = new Set<String>();
            Set<String> setSObjects = new Set<String>();
            for(WrapperActivity wrp: lWrActivity){
                if(wrp.sNameActivityProcess!=null 
                && wrp.idAssignedTo!=null 
                && wrp.idsObject!=null){

                    setActivityProcessNames.add(wrp.sNameActivityProcess);
                    setAssigneToIds.add(wrp.idAssignedTo);
                    setSObjects.add(wrp.idsObject);

                }
            }
            String sSelectQuery = '';
            String sWhereQuery = '';
            
            List<ActivityManagement__mdt> lDataActivity = [SELECT MappingFieldsTarget__c,DueDate__c,Duration__c,DueDateComplement__c,EventType__c,Priority__c,SourceObject__c,
                                                            StartDate__c,Status__c,Subject__c,TargetObject__c,Type__c
                                                            FROM ActivityManagement__mdt
                                                               WHERE label IN :setActivityProcessNames];

           
            System.debug('lDataActivity-->'+lDataActivity);            
            if(lDataActivity!=null && !lDataActivity.isEmpty()){
                
                try{
                    // MAP < Activity Process Name, < RequieredField, ActualFieldName >>
                    Map<String, Map<String, String>> mapFieldsTarget = new Map<String, Map<String, String>>();
                    Map<String, SObject> lstSObjTarget = new Map<String, SObject>();//Activity sObjTargetect

                    
                    for(ActivityManagement__mdt actMan: lDataActivity){
                        mapFieldsTarget.put(actMan.label, (Map<String,String>) JSON.deserialize(actMan.MappingFieldsTarget__c, Map<String,String>.class));

                        // creating activity object
                        if(actMan.TargetObject__c!=null && actMan.SourceObject__c!=null){
                            // sObjTarget.put(,Schema.getGlobalDescribe().get(actMan.TargetObject__c).newsObject());
                        }
                    }

                }catch(Exception e){
                    System.debug('EventUtil.createActivity ERROR -->' + e.getMessage() + ' Line: '+e.getLineNumber());
                }
            }
        }
    }*/

    /**
     * This method generates events from leads. 
     * It replicates, bulkifies and simplifies the behaviour of the method EventUtil.createActivity() 
     * asumming the ActivityManagement__mdt is TaskEvent.
     *
     * @author				Ricardo Pereira
     * @date				2019-01-30
     * @param	List<Lead>	list of lead records
     * @return	List<Event>	created events
     */
    public static List<Event> createEventsFromLead(List<Lead> lstLeads){

        List<Event> lstEventsToInsert = new List<Event>();
        for(Lead lead: lstLeads){
            lstEventsToInsert.add(new Event(
                Subject             = lead.LeadRequestType__c,
                StartDateTime       = Datetime.now(),
                EndDateTime         = Datetime.now().addMinutes(10),
                DurationInMinutes   = 10,
                Type                = 'Call',
                Priority__c         = 'High',
                Status__c           = '0',
                OwnerId             = lead.OwnerId
            ));
        }

        insert lstEventsToInsert;
        return lstEventsToInsert;
    }

    /**
     * Set technical field value for Activity standard object
     * reporting purposes. C1STAGILE-4962.
     *
     * @author              Diego Rincón
     * @date                2019-04-25
     * @param       lst     list of event records being upserted
     * @return              none
     */
    public static void setActivityType(List<Event> lst) {
        for (Event e : lst) {
            e.TECH_ActivityType__c = e.Type;
        }
    }
}
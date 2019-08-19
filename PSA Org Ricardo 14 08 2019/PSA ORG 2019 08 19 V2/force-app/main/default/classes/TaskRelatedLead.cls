public class TaskRelatedLead {

    private final static string REACHED             = '0';
    private final static string UNREACHED           = '1';
    private final static string RT_TASKEVENTS       = 'TaskEvents';
    private final static string NURTURING           = 'Nurturing';
    private final static string LEAD_QUALIFICATION  = 'Client unreached';
    private final static string NAME_PROCESS        = 'LeadAttemptCalls';

    /*
     * @Method          :   manageTaskEvent
     * @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   14 feb 2018
     * @Description     :   To manage calls to Leads.
     * @Params          :   -
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */
    public static void manageCallsToLeads(List<Task> lTasks){

        Id idRTeventTask = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get(RT_TASKEVENTS).getRecordTypeId(); //task event record type
        Set<Id> setLeadsCloseEvent = new Set<Id>();
        List<Event> lEventToUpdate = new List<Event>();//events to update on closed status
        List<Lead> lLeadsToUpdate = new List<Lead>();//leads to update status and Qualification  result
        List<Lead> lLeadsToAssignTask = new List<Lead>();//leads to assign a task.
        List<EventUtil.WrapperActivity> lwr = new List<EventUtil.WrapperActivity>();//wrapper to create task events.

        // create a set of all the unique ownerIds
        Set<id> setWhoIds = new Set<id>();

        for (Task t : lTasks)
            //if(t.Subject.contains(LEAD_SUBJECT)) 
            setWhoIds.add(t.whoId); 

        // query for extract lead attempt calls for all leads.
        Map<Id, Lead> mapIdLead = new Map<Id, Lead>([
            SELECT Id, LeadAttemptCalls__c, OwnerId, IsConverted
            FROM Lead
            WHERE Id IN :setWhoIds
        ]);
        System.debug('***mapIdLead: '+mapIdLead);
        for(Task itemTask : lTasks){
            System.debug('***Task: '+itemTask);
            if (itemTask.CallStatus__c == REACHED){
                setLeadsCloseEvent.add(itemTask.WhoId);
            } else if(itemTask.CallStatus__c == UNREACHED && !mapIdLead.isEmpty()){
          
                //increase +1 attemps
                if (mapIdLead.get(itemTask.whoId).LeadAttemptCalls__c!=null){
                    mapIdLead.get(itemTask.whoId).LeadAttemptCalls__c += 1;
                } else {
                    mapIdLead.get(itemTask.whoId).LeadAttemptCalls__c = 1;
                }

                // LeadAttemptCalls__c is more or equal than 3(Label)
                if (
                    mapIdLead.get(itemTask.whoId).LeadAttemptCalls__c >= Integer.valueof(Label.NumberOfCallsLead) &&
                    !mapIdLead.get(itemTask.whoId).IsConverted
                ){
                    mapIdLead.get(itemTask.whoId).Status = NURTURING;
                    mapIdLead.get(itemTask.whoId).LeadQualificationResult__c = LEAD_QUALIFICATION;
                    lLeadsToUpdate.add(mapIdLead.get(itemTask.whoId));

                } else {
                    lLeadsToUpdate.add(mapIdLead.get(itemTask.whoId));//add to list of leads to update the increase +1
                    lLeadsToAssignTask.add(mapIdLead.get(itemTask.whoId));
                }
            }
        }
        
        //create a task event to call lead.
        if(!lLeadsToAssignTask.isEmpty()){
            
            EventUtil.WrapperActivity wr = new EventUtil.WrapperActivity();
            wr.idsObject=lLeadsToAssignTask[0].id;
            wr.sNameActivityProcess=NAME_PROCESS;
            wr.idAssignedTo=lLeadsToAssignTask[0].ownerid; 

            lwr.add(wr);

            EventUtil.createActivity(lwr);
        }

        try{
            //close task events because the owner logs a call in reached status.
            if(!setLeadsCloseEvent.isEmpty()){
                for(Event e : [Select id,status__c FROM Event Where WhoId IN :setLeadsCloseEvent AND status__c = '0' AND recordTypeid = :idRTeventTask]){
                    e.status__c = '1';
                    lEventToUpdate.add(e);
                }
                System.debug('lEventToUpdate:__ '+lEventToUpdate);
                Database.update(lEventToUpdate,true);
            }

            //update leads.
            if(!lLeadsToUpdate.isEmpty()){
                System.debug('lLeadsToUpdate:__ B'+lLeadsToUpdate);
                Database.update(lLeadsToUpdate,true);
                System.debug('lLeadsToUpdate:__ A'+lLeadsToUpdate);
            }

        } catch (DMLexception e) {
            System.debug('TaskRelatedLead.manageCallsToLeads ERROR -->' + e.getMessage() + ' Line: '+e.getLineNumber());
        } catch (Exception e){
            System.debug('TaskRelatedLead.manageCallsToLeads ERROR --> ' + e.getMessage() + ' Line: '+e.getLineNumber());
        }
    }
}
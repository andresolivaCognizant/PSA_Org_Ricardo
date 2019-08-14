/*
*   @Class : TaskTriggerHandler.cls
*
*   @Author         :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
*   @Created        :   14 feb 2018
*   @Description    :   To manage tasks trigger methods

*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Developer            Date                     Description
*	   Ruben Moreno			14 feb 2018				 Creation.	
	   Borja Gay			2019/05/15				 Added RunTriggerMethod
*   ----------------------------------------------------------------------------------------------------------------------------
*/
public class TaskTriggerHandler {
    
    private static boolean runtrigger 				= true;
    private final static string REACHED 			= '0';
    private final static string UNREACHED 			= '1';
    
    /*
     * @Method          :   shouldRunTrigger
     * @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   14 feb 2018
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
     * @Created         :   14 feb 2018
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
     * @Method          :   runTrigger
     * @Author          :   Borja Gay
     * @Created         :   15 may 2019
     * @Description     :   To indicate that the trigger should be run
     * @Params          :   -
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
    public static void runTrigger() {
        runtrigger = true;
    }
    /*
     * @Method          :   beforeInsert
     * @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   14 feb 2018
     * @Description     :   Call the actions that handle the before insert trigger.
     * @Params          :   List<Task> records before the changes.
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */
    public static void beforeInsert(List<Task> lNewTasks) {
        TaskUtils.setActivityType(lNewTasks);

        for(Task tsk : lNewTasks){
            if(null == tsk.CallStatus__c){
                tsk.CallStatus__c = '0';
            }
        }

        CTITaskCaseRelation.populateCaseInfo(lNewTasks);
    }

    /*
     * @Method          :   beforeUpdate
     * @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   14 feb 2018
     * @Description     :   Call the actions that handle the before update trigger.
     * @Params          :   List<Task> records after the changes, Map<Id, Task> record before the changes
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
    public static void beforeUpdate(List<Task> lNewTasks, Map<Id, Task> mapOldTasks) {
        TaskUtils.setActivityType(lNewTasks);
    }
    
    /*
     * @Method          :   afterInsert
     * @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   14 feb 2018
     * @Description     :   Call the actions that handle the after insert trigger
     * @Params          :   List<Task> records after the changes
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
    public static void afterInsert(List<Task> lNewTasks) {
        Set<Id> set_leads = new Set<Id>();
        for(Task ta : lNewTasks){
            set_leads.add(ta.WhoId);
        }

        List<Lead> lstLeads = [
            SELECT
                Id,
                Status,
                OwnerId,
                Owner.Name,
                LeadCountry__c,
                PSABrand__c,
                Activity__c,
                LeadType__c,
                CalculatedPOS__c,
                CreatedDate,
                ActualFirstEmailSentDate__c,
                CECActualTreatmentDate__c,
                CECTreatmentDueDate__c,
                TreatmentDueDate__c
            FROM Lead
            WHERE Id IN: set_leads
        ];

        if(!set_leads.isEmpty()){
            // C1STAGILE-6688 - begin
            update TaskUtils.changeParentLeadStatus(lstLeads);
            // C1STAGILE-6688 - end
            LeadUtils.dtDueDate(lstLeads, 'task');
        }
        
        TaskUtils.manageTeleAlertCalls(lNewTasks);
        TaskUtils.manageLeadCalls(lNewTasks);
    }

    /*
     * @Method          :   afterUpdate
     * @Author          :   Rubén Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
     * @Created         :   14 feb 2018
     * @Description     :   Call the actions that handle the after update trigger.
     * @Params          :   List<Task> records after the changes, Map<Id, Task> record before the changes
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
    /*public static void afterUpdate(List<Task> lNewTasks, Map<Id, Task> mapOldTasks) {
        
    }*/    

    public static void afterDelete(List<Task> lst_old) {
        // C1STAGILE-7653 - begin
        TaskUtils.updateParentTeleAlertCallCounter(lst_old);
        // C1STAGILE-7653 - end
    }

    public static void afterUndelete(List<Task> lst_new) {
        // C1STAGILE-7653 - begin
        TaskUtils.updateParentTeleAlertCallCounter(lst_new);
        // C1STAGILE-7653 - end
    }
}
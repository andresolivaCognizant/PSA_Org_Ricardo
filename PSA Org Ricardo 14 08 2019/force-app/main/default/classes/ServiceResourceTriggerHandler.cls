/**
 * Name:            ServiceResourceTriggerHandler
 * @author:         Diego Rincón (DR) href=<diego.rincon@ext.mpsa.com>
 * Project:         PSA
 * Description:     Helper class to dispatch actions for every operation type in
 *                  ServiceResource sObject main trigger.
 *
 * Changes (version)
 * -------------------------------------------------------------------------------------------------
 *              No.     Date            Author                  Description
 *              ----    ------------    --------------------    ------------------------------------
 * @version     1.0     2018-09-20      Diego Rincón (DR)       Class creation.
 *                      2019-03-28      Sergio Lopez            Inactive Users related to Service Resource now on batch process, not compatible with Future method (US 1018)
 *
 */

public class ServiceResourceTriggerHandler {

    //US 1018 - B
    private static Boolean runtrigger = true;
    //US 1018 - E
    public static Boolean isAfterUndeleteFirstRun   = true;
    public static Boolean isBeforeInsertFirstRun    = true;
    public static Boolean isBeforeUpdateFirstRun    = true;
    public static Boolean isBeforeDeleteFirstRun    = true;
    public static Boolean isAfterInsertFirstRun     = true;
    public static Boolean isAfterUpdateFirstRun     = true;
    public static Boolean isAfterDeleteFirstRun     = true;

    //US 1018 - B
    /*
     * @Method          :   shouldRunTrigger
     * @Author          :   Sergio Lopez
     * @Created         :   02 apr 2018
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
     * @Author          :   Sergio Lopez
     * @Created         :   02 apr 2018
     * @Description     :   To indicate that the trigger should not run
     * @Params          :   -
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */     
    public static void dontRunTrigger() {
        runtrigger = false;
    }
    //US 1018 - E

    /*
    uncomment as needed

    private Boolean beforeInsertHasRun() {
        if (isBeforeInsertFirstRun) {
            return isBeforeInsertFirstRun = false;
        }
        return true;
    }

*/
    public static Boolean testAuxMethod(Boolean bAfter){
        Boolean bResult;
        If(bAfter){
            bResult = beforeUpdateHasRun();
        }else{
        	bResult = afterUpdateHasRun();
        }
        return bResult;
    }
    private static Boolean beforeUpdateHasRun() {
        if (isBeforeUpdateFirstRun) {
            return isBeforeUpdateFirstRun = false;
        }
        return true;
    }
    
    /*

    private Boolean beforeDeleteHasRun() {
        if (isBeforeDeleteFirstRun) {
            return isBeforeDeleteFirstRun = false;
        }
        return true;
    }

    private Boolean afterInsertHasRun() {
        if (isAfterInsertFirstRun) {
            return isAfterInsertFirstRun = false;
        }
        return true;
    }

    */
	
    private static Boolean afterUpdateHasRun() {
        if (isAfterUpdateFirstRun) {
            return isAfterUpdateFirstRun = false;
        }
        return true;
    }

    /*
    private Boolean afterDeleteHasRun() {
        if (isAfterDeleteFirstRun) {
            return isAfterDeleteFirstRun = false;
        }
        return true;
    }

    private Boolean afterUndeleteHasRun() {
        if (isAfterUndeleteFirstRun) {
            return isAfterUndeleteFirstRun = false;
        }
        return true;
    }

    public void beforeInsert(List<WorkshopAppointment__c> lstNewRows) {
        if (beforeInsertHasRun()) {
            return;
        }
        // call actions
    }


    public void beforeUpdate(
        List<ServiceResource> lstOldRows,
        List<ServiceResource> lstNewRows,
        Map<Id, ServiceResource> mapOldRows,
        Map<Id, ServiceResource> mapNewRows
    ) {
        if(beforeUpdateHasRun()) {
            return;
        }
    
        // call actions

    }
 */

   public void afterUpdate(
        List<ServiceResource> lstOldRows,
        List<ServiceResource> lstNewRows,
        Map<Id, ServiceResource> mapOldRows,
        Map<Id, ServiceResource> mapNewRows
    ) {
        System.debug('@@ ServiceResourceTriggerHandler.afterUpdate');
        boolean isBatch = System.isBatch();

        // US 1018 - B
        //if(!Test.isRunningTest() && (afterUpdateHasRun() || isBatch || shouldRunTrigger())) {
            //runtrigger = true;
        // US 1018 - E
            //return;
        //}
        ServiceResourceUtils.isDeactivated(mapOldRows, mapNewRows);
    }

}
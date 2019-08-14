/**
* Salesforce
* @author				Diego Rincón (DR) href=<diego.rincon@ext.mpsa.com>
* Project:				PSA - Customer First
* Description:			Helper class to handle bussiness logic related to the
*						WorkshopAppointment__c sObject.
*
* Changes (version)
* -------------------------------------------------------------------------------------------------
*				No.		Date			Author					Description
*				----	------------	--------------------	-----------------------------------
* @version		1.0		2018-##-##		Diego Rincón (DR)		Class creation.
* @version		2.0		2019-07-02		Manuel Medina (MM)		Method definitions was changed from non-static to static.
*
*/
public class WorkshopAppointmentTriggerHandler {

	public static Boolean isAfterUndeleteFirstRun				= true;
	public static Boolean isBeforeInsertFirstRun				= true;
	public static Boolean isBeforeUpdateFirstRun				= true;
	public static Boolean isBeforeDeleteFirstRun				= true;
	public static Boolean isAfterInsertFirstRun					= true;
	public static Boolean isAfterUpdateFirstRun					= true;
	public static Boolean isAfterDeleteFirstRun					= true;

	private static Boolean beforeInsertHasRun(){
		if( isBeforeInsertFirstRun ){
			return isBeforeInsertFirstRun						= false;
		}
		
		return true;
	}

	private static Boolean beforeUpdateHasRun(){
		if( isBeforeUpdateFirstRun ){
			return isBeforeUpdateFirstRun						= false;
		}

		return true;
	}

	
	private static Boolean beforeDeleteHasRun(){
		if( isBeforeDeleteFirstRun ){
			return isBeforeDeleteFirstRun						= false;
		}

		return true;
	}

	private static Boolean afterInsertHasRun(){
		if( isAfterInsertFirstRun ){
			return isAfterInsertFirstRun						= false;
		}

		return true;
	}

	private static Boolean afterUpdateHasRun(){
		if( isAfterUpdateFirstRun ){
			return isAfterUpdateFirstRun						= false;
		}

		return true;
	}

	private static Boolean afterDeleteHasRun(){
		if( isAfterDeleteFirstRun ){
			return isAfterDeleteFirstRun						= false;
		}

		return true;
	}

	private static Boolean afterUndeleteHasRun(){
		if( isAfterUndeleteFirstRun ){
			return isAfterUndeleteFirstRun						= false;
		}

		return true;
	}
	
	public static void beforeInsert( List<WorkshopAppointment__c> lstNewRows ){
		if( beforeInsertHasRun() ){
			return;
		}

		WorkshopAppointmentUtils.setName(lstNewRows);
	}

	public static void beforeUpdate(
		List<WorkshopAppointment__c> lstOldRows,
		List<WorkshopAppointment__c> lstNewRows,
		Map<Id, WorkshopAppointment__c> mapOldRows,
		Map<Id, WorkshopAppointment__c> mapNewRows
	){
		if(beforeUpdateHasRun()){
			return;
		}

		WorkshopAppointmentUtils.setName(lstNewRows);
		WorkshopAppointmentUtils.validateServiceBoxUpdate( lstNewRows );
	}

   public static void afterUpdate(
		List<WorkshopAppointment__c> lstOldRows,
		List<WorkshopAppointment__c> lstNewRows,
		Map<Id, WorkshopAppointment__c> mapOldRows,
		Map<Id, WorkshopAppointment__c> mapNewRows
	){
		if(afterUpdateHasRun()){
			return;
		}

		WorkshopAppointmentUtils.matchTelealert(lstNewRows);
	}

	public static void afterInsert(
		List<WorkshopAppointment__c> lstNewRows,
		Map<Id, WorkshopAppointment__c> mapNewRows
	){
		if (afterInsertHasRun()){
			return;
		}

		WorkshopAppointmentUtils.matchTelealert(lstNewRows);
		WorkshopAppointmentUtils.setRecurrentPos(lstNewRows);
	}

	public static void afterUndelete(
		List<WorkshopAppointment__c> lstNewRows,
		Map<Id, WorkshopAppointment__c> mapNewRows
	){
		if (afterUndeleteHasRun()){
			return;
		}

		WorkshopAppointmentUtils.matchTelealert(lstNewRows);

	}

}
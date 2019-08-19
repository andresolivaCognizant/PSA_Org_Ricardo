/**
* Salesforce
* @author				Diego Rincón (DR) href=<diego.rincon@ext.mpsa.com>
* Project:				PSA - Customer First
* Description:			Trigger to handle bussiness logic related to the
*						WorkshopAppointment__c sObject.
*
* Changes (version)
* -------------------------------------------------------------------------------------------------
*				No.		Date			Author					Description
*				----	------------	--------------------	-----------------------------------
* @version		1.0		2019-03-12		Diego Rincón (DR)		Class creation.
*
*/
trigger WorkshopAppointmentTrigger on WorkshopAppointment__c ( after insert, before insert, after update, before update, after delete, before delete, after undelete ){

	switch on Trigger.operationType {
		when AFTER_INSERT {
			if(PAD.canTrigger('WorkshopAppointmentTrigger_AfterInsert')){
				WorkshopAppointmentTriggerHandler.afterInsert(Trigger.new, Trigger.newMap);
			}
		}
		
		when BEFORE_INSERT {
			if(PAD.canTrigger('WorkshopAppointmentTrigger_BeforeInsert')){
				WorkshopAppointmentTriggerHandler.beforeInsert(Trigger.new);
			}
		}

		when AFTER_UPDATE {
			if(PAD.canTrigger('WorkshopAppointmentTrigger_AfterUpdate')){
				WorkshopAppointmentTriggerHandler.afterUpdate(
					Trigger.old, Trigger.new,
					Trigger.oldMap, Trigger.newMap
				);
			}
		}

		when BEFORE_UPDATE {
			if(PAD.canTrigger('WorkshopAppointmentTrigger_BeforeUpdate')){
				WorkshopAppointmentTriggerHandler.beforeUpdate(
					Trigger.old, Trigger.new,
					Trigger.oldMap, Trigger.newMap
				);
			}
			
		}

		when AFTER_DELETE {
		}

		when BEFORE_DELETE {
		}

		when AFTER_UNDELETE {
			if(PAD.canTrigger('WorkshopAppointmentTrigger_AfterUndelete')){
				WorkshopAppointmentTriggerHandler.afterUndelete(Trigger.new, Trigger.newMap);
			}
		}
	}
}
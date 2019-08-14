/*
*   @Class : AccountContactRelationTrigger
*
*   @Author         :   Dario Correnti <dcorrenti@salesforce.com>
*   @Created        :   21/09/2018 
*   @Description    :   Trigger for AccountContactRelation
*
*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Developer            Date                     Description
*
*   ----------------------------------------------------------------------------------------------------------------------------
*/

trigger AccountContactRelationTrigger on AccountContactRelation (before insert) {
	AccountContactRelationTriggerHandler trHandler = new AccountContactRelationTriggerHandler();

	if(AccountContactRelationTriggerHandler.shouldRunTrigger()) {
		if (Trigger.isBefore) {
			if (Trigger.isInsert) {
				AccountContactRelationTriggerHandler.beforeInsert(Trigger.New);
            }
		}
	}
}
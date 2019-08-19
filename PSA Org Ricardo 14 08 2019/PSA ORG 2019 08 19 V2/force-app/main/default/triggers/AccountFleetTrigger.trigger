trigger AccountFleetTrigger on AccountFleet__c (before insert) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            AccountFleetTriggerHandler.setAccountFleetCountryandCurrency(trigger.new);
        }
    }
}
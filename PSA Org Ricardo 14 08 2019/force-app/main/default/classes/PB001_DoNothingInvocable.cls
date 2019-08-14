global with sharing class PB001_DoNothingInvocable {
	
    @InvocableMethod(
        label       = 'PB: Do Nothing'
        description = 'Prevent an update from a Process Builder.'
    )

    global static void requestMessage( List<UpdateRequest> requests ) {

        System.debug( 'DoNothingInvocable START: ' + requests.size() );
        //List<Id> lstRecords	            = new List<Id>(); 		
	
        //for(UpdateRequest r : requests){
        //	lstRecords.add(r.sfRecordId);
     	//}
     	System.debug( 'DoNothingInvocable END');
        //
    }
    // -----------------------------------------------------------------
    // INVOCABLE CLASS: PARAMS
    // -----------------------------------------------------------------
    global class UpdateRequest {

        @InvocableVariable(
            label           = 'Salesforce Record Id'
            description     = 'The record to update'
        )
        global String sfRecordId;

    }
    

}
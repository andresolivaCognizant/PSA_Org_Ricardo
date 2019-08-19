public class DealerSalesmenCalendarsController {

    @AuraEnabled
    public static Map<String, Object> getEvents(String request){

        Map<String, Object> response = new Map<String, Object>();

        try {
            Map<String, Object> map_req = (Map<String, Object>) JSON.deserializeUntyped(request);

            List<User> lst_u = new List<User>([
                SELECT
                    Id, Name, Activity__c
                FROM User
                WHERE Contact.AccountId = :(Id) map_req.get('record_id') AND ISACTIVE=TRUE
            ]);

            List<Event> lst_e = new List<Event>([
                SELECT
                    Id,
                    Subject,
                    StartDateTime,
                    EndDateTime,
                    OwnerId
                FROM Event
                WHERE OwnerId IN :lst_u
            ]);
			
            Datetime dateToCvrt;
			Integer offset;
			Datetime local;
             
            for (Event evt : lst_e){
                dateToCvrt = evt.StartDateTime;
				offset = UserInfo.getTimezone().getOffset(dateToCvrt);
				evt.StartDateTime = dateToCvrt.addSeconds(offset/1000);
                dateToCvrt = evt.EndDateTime;
				offset = UserInfo.getTimezone().getOffset(dateToCvrt);
				evt.EndDateTime = dateToCvrt.addSeconds(offset/1000); 
            }  
            
            response.put('payload', new Map<String, Object>{
                'users'     => new Map<Id, User>(lst_u),
                'events'    => lst_e
            });
 
            response.put('hasError', false);


        } catch (Exception e) {
            response.put('hasError', true);
        }

        return response;
    }
}
public class TeleAlertStatusChangeController {

    @AuraEnabled 
    public static Map<String, Object> getData(String request){ 

        Map<String, Object> map_req =
            (Map<String, Object>) JSON.deserializeUntyped(request);

        Map<String, Object> res = new Map<String, Object>();

        List<VehicleEvent__x> lstE = [
            SELECT ExternalId, Alertlabel__c, Telealertresultcode__c, Telealertresultlabel__c FROM VehicleEvent__x
                WHERE Telealertid__c = :(Id) map_req.get('record_id')
        ];

        res.put('payload_data', lstE);

        res.put('payload_picklist', (Map<String, Object>) GlobalSettingsUtil.getCustomMetadataRecords('VehicleEventStatus__mdt', new List<String>{'MasterLabel','Code__c'},
                                    null, true)
        );

        return res;
    }

    @AuraEnabled
    public static Map<String, Object> saveData(String recordId, String code, String label, String dealer, String status, List<VehicleEvent__x> lstVehicleEvent){ 
        System.debug('saveData:');
        // map of vehicle events in the request
        Map<Id, VehicleEvent__x> mapE = new Map<Id, VehicleEvent__x>();
        
        // list of changed VehicleEvent__x records to be updated
        List<VehicleEvent__x> lstU = new List<VehicleEvent__x>();

        if(status == '3' && label == System.Label.Appointment_Created){
            Integer oneVehicleWhitAppo = 0;
            String codeMultiAlert = System.Label.Multiple_Alert;
            for (VehicleEvent__x w : lstVehicleEvent) {
                if(oneVehicleWhitAppo == 0){
                    w.telealertresultcode__c    = code;
                    w.telealertresultlabel__c   = label;
                    lstU.add(w); 
                    oneVehicleWhitAppo++;                  
                }else{
                    w.telealertresultcode__c    = code;
                    w.telealertresultlabel__c   = codeMultiAlert;
                    lstU.add(w);
                }
            }
        }else{
            for (VehicleEvent__x w : lstVehicleEvent) {
                w.telealertresultcode__c    = code;
                w.telealertresultlabel__c   = label;
                lstU.add(w);
            }            
        }

        if(!Test.isRunningTest()){
            Database.updateImmediate(lstU);
        }

        TeleAlert__c t = new TeleAlert__c(
            Id = recordId,
            APVDealer__c = dealer,
            Status__c = status
        );

        update t;

        return null;
    }

}
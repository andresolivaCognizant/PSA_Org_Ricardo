public without sharing class OlbAppointment {

    @AuraEnabled
    public static Map<String, Object> getAppointmentId(String request) {
        Map<String, Object> res = new Map<String, Object>();

        Map<String, Object> map_req =
            (Map<String, Object>) JSON.deserializeUntyped(request);

        try {
            TeleAlert__c t = [
                SELECT
                    Id,
                    Priority__c,
                    Brand__c,
                    Country__c,
                    Asset__r.VIN__c,
                    Asset__r.LastKnownRegistrationNumber__c,
                    Account__r.Brand__c,
                    Account__r.RRDICode__c,
                    Account__r.SiteGeoIdPK__c,
                    Account__r.TECH_Salutation__pc,
                    Account__r.FirstName,
                    Account__r.LastName,
                    Account__r.PersonEmail,
                    Account__r.LandlinePersonalTelephone__pc,
                    Account__r.LandlineProfessionalTelephone__pc,
                    WorkshopAppointmentID__r.Mobility__c,
                    Asset__r.Brand__c,
                    Account__r.MobilePersonalTelephone__pc,
                    APVDealer__c,
                    APVDealer__r.Brand__c,
                    APVDealer__r.RAContractNumber__c,
                    APVDealer__r.AgentContractNumber__c,
                    APVDealer__r.SiteGeoIdPK__c,
                    APVDealer__r.RRDICode__c
                FROM TeleAlert__c
                WHERE Id = :(Id) map_req.get('id')
            ];

            List<TeleAlertSetting__mdt> lst_md = new List<TeleAlertSetting__mdt>([
                SELECT Id, OlbUrl__c
                FROM TeleAlertSetting__mdt
                WHERE
                    Brand__c = :t.Brand__c AND
                    Country__c = :t.Country__c AND
                    OlbUrl__c != null
            ]);

            if (lst_md.isEmpty()) {
                res.put('has_error', true);
                res.put('error', 'No URL was found for this subsidiary');
                return res;
            }

            User currentUser= [SELECT Id,Country__c FROM User WHERE Id=:UserInfo.getUserId()];

            Map<String, Map<String, Object>> ws_param = 
                GlobalSettingsUtil.getGlobalSettingAttributes(
                    new Set<String>{'OlbAppointmentWS'},
                    new Set<String>{
                        'OlbEndpoint',
                        'OlbClientSecret',
                        'OlbSourceSystem',
                        'OlbSourceUser',
                        'OlbClientCertificateName'
                    }
                );

            HttpRequest http_req = new HttpRequest();
            http_req.setEndpoint((String) ws_param.get('OlbAppointmentWS').get('OlbEndpoint'));
            http_req.setMethod('POST');

            http_req.setHeader('Content-Type', 'application/json');
            http_req.setHeader(
                'X-SourceSystem',
                (String) ws_param.get('OlbAppointmentWS').get('OlbSourceSystem')
            );
            http_req.setHeader(
                'X-SourceUser',
                (String) ws_param.get('OlbAppointmentWS').get('OlbSourceUser')
            );
            http_req.setHeader(
                'X-Timestamp',
                System.now().format('yyyy-MM-dd\'T\'hh:mm:ss')
            );
            http_req.setHeader(
                'X-ClientSecret',
                (String) ws_param.get('OlbAppointmentWS').get('OlbClientSecret')
            );

            http_req.setClientCertificateName(
                (String) ws_param.get('OlbAppointmentWS').get('OlbClientCertificateName')
            );

            // create a JSONGenerator object
            // pass true to the constructor for pretty print formatting
            JSONGenerator g = JSON.createGenerator(true);

            g.writeStartObject();
                g.writeStringField('IdIncident', t.Id);
                g.writeStringField('CultureCode', currentUser.Country__c);
                g.writeStringField('BrandCode', t.Asset__r.Brand__c);
                g.writeNumberField('TypeAlert', Integer.valueOf(t.Priority__c));
                g.writeStringField('VIN', t.Asset__r.VIN__c);

                if (null != t.Asset__r.LastKnownRegistrationNumber__c) {
                    g.writeStringField('Registration', t.Asset__r.LastKnownRegistrationNumber__c);
                }

                g.writeNumberField('CivilityCode', Integer.valueOf(t.Account__r.TECH_Salutation__pc));
                g.writeStringField('Name', t.Account__r.LastName);
                g.writeStringField('Firstname', t.Account__r.FirstName);
                g.writeStringField('EMail', t.Account__r.PersonEmail);

                if (null != t.Account__r.LandlinePersonalTelephone__pc) {
                    g.writeNumberField('Telephone', Long.valueOf(t.Account__r.LandlinePersonalTelephone__pc.replaceAll('[^0-9]','')));
                } else if (null != t.Account__r.LandlineProfessionalTelephone__pc){
                    g.writeNumberField('Telephone', Long.valueOf(t.Account__r.LandlineProfessionalTelephone__pc.replaceAll('[^0-9]','')));
                } else{
                    g.writeNumberField('Telephone', Long.valueOf(t.Account__r.MobilePersonalTelephone__pc.replaceAll('[^0-9]','')));
                }

                if (null != t.WorkshopAppointmentID__r.Mobility__c) {
                    g.writeStringField('Mobility', String.valueOf(t.WorkshopAppointmentID__r.Mobility__c));
                }

                if (null != t.APVDealer__r.Brand__c) {
                    g.writeStringField('DealerBrandCode', t.APVDealer__r.Brand__c);
                }               

                g.writeStringField('RrdiId', (null != t.APVDealer__r.RAContractNumber__c)?t.APVDealer__r.RAContractNumber__c:t.APVDealer__r.AgentContractNumber__c);
                g.writeStringField('GeoID', t.APVDealer__r.SiteGeoIdPK__c);

                if (Test.isRunningTest()) {
                    g.writeNumberField(
                        'mock_status',
                        (Integer) map_req.get('mock_status')
                    );
                }
            g.writeEndObject();

            http_req.setBody(g.getAsString());

            // new http object to send the request object
            Http http = new Http();

            // a response object is generated as a result of the request
            HTTPResponse http_res = http.send(http_req);

            switch on http_res.getStatusCode() {
                when 200 {
                    res.put('has_error', false);
                    res.put('payload', new Map<String, Object>{
                        'olb_res' => http_res.getBody(),
                        'url_lst' => lst_md
                    });
                }
                when else {
                    res.put('has_error', true);
                    res.put('payload', http_res.getStatus());
                    System.debug( '##'+http_res.getBody());
                }
            }
            

        } catch (CalloutException e) {
            res.clear();
            res.put('has_error', true);
            res.put('error', e);
        }

        return res;
    }

}
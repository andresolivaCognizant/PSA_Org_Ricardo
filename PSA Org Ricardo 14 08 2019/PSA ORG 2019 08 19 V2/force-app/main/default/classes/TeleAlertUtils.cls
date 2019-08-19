/**
 * Name:            TeleAlertUtils
 * @author:         Diego Rincón (DR) href=<diego.rincon@ext.mpsa.com>
 * Project:         PSA
 * Description:     Helper class to handle bussiness logic related to the TeleAlert__c sObject.
 *
 * Changes (version)
 * -------------------------------------------------------------------------------------------------
 *              No.     Date            Author                  Description
 *              ----    ------------    --------------------    ------------------------------------
 * @version     1.0     2018-09-21      Diego Rincón (DR)       Class creation.
 *
 */

public class TeleAlertUtils {

    private static final String MD_DEFAULT_RECORD = 'ALL';

    private static final Map<Id, User> API_USER_MAP;

    @TestVisible private static List<Map<String, Object>> TEST_EXT_OBJ_MOCK = 
            new List<Map<String, Object>>();
 
    static {
        Set<String> set_un = new Set<String>();

        for (GlobalSettingAttributes__mdt md : [
            SELECT Id, AttributeValue__c, GlobalSetting__c
            FROM GlobalSettingAttributes__mdt
            WHERE
                DeveloperName LIKE 'Int89ApiUserName%' AND
                GlobalSetting__r.DeveloperName = 'TeleAlertInt89' 
        ]) {
            set_un.add(md.AttributeValue__c);
        }

        API_USER_MAP = new Map<Id, User>([
            SELECT Id
            FROM User
            WHERE UserName IN :set_un
        ]);
    }

    public static final Map<String, Object> TELEALERT_SETTINGS =
        (Map<String, Object>) GlobalSettingsUtil.getCustomMetadataRecords(
            'TeleAlertSetting__mdt',
            new List<String>{
                'Country__c',
                'Brand__c',
                'QueueId__c',
                'CallAttempts__c',
                'EventStartDateTime__c',
                'EventEndDateTime__c'
            },
            null,
            true
        );

    public static final Map<String, Object> TREATMENT_TIMES = 
        (Map<String, Object>) GlobalSettingsUtil.getCustomMetadataRecords(
            'VehicleEventTreatmentTime__mdt',
            new List<String>{'Country__c','Brand__c','AlertCategory__c','TreatmentTime__c'},
            null,
            true
        );
    
    public static final Map<String, Object> EVENT_BILLABILITY = 
        (Map<String, Object>) GlobalSettingsUtil.getCustomMetadataRecords(
            'VehicleEventBilling__mdt',
            new List<String>{'Country__c','Brand__c','Type__c','BillabilityThreshold__c'},
            null,
            true
        );

    public static Object matchingConfig(TeleAlert__c t) {
        String strB = String.isNotBlank(t.Brand__c) ? t.Brand__c.trim() : null;
        String strC = String.isNotBlank(t.Country__c) ? t.Country__c.trim() : null;

        if (
            null != strB &&
            null != strC &&
            null != TELEALERT_SETTINGS.get(strC + strB)
        ) {
            return TELEALERT_SETTINGS.get(strC + strB);
        }

        if (null != strB && null != TELEALERT_SETTINGS.get(strB)) {
            return TELEALERT_SETTINGS.get(strB);
        }

        if (null != strC && null != TELEALERT_SETTINGS.get(strC)) {
            return TELEALERT_SETTINGS.get(strC);
        }

        return null;
    }

    public static Object eventTreatmentTimeMatch(VehicleEvent__x e) {

        String strB = String.isNotBlank(e.telealertid__r.Brand__c) ? e.telealertid__r.Brand__c.trim() : null;
        String strC = String.isNotBlank(e.telealertid__r.Country__c) ? e.telealertid__r.Country__c.trim() : null;
        String strA = String.isNotBlank(e.alerttypecode__c) ? e.alerttypecode__c.trim() : null;

        if (
            null != strB &&
            null != strC &&
            null != strA &&
            null != TREATMENT_TIMES.get(strC + strB + strA)
        ) {
            return TREATMENT_TIMES.get(strC + strB + strA);
        }

        return TREATMENT_TIMES.get(MD_DEFAULT_RECORD);
    }
    
    public static Object eventBillabilityMatch(VehicleEvent__x e) {

        String strB = String.isNotBlank(e.telealertid__r.Brand__c) ? e.telealertid__r.Brand__c.trim() : null;
        String strC = String.isNotBlank(e.telealertid__r.Country__c) ? e.telealertid__r.Country__c.trim() : null;
        String strT = String.isNotBlank(e.alertcode__c) ? e.alertcode__c.trim() : null;

        if (
            null != strB &&
            null != strC &&
            null != strT &&
            null != EVENT_BILLABILITY.get(strC + strB + strT)
        ) {
            return EVENT_BILLABILITY.get(strC + strB + strT);
        }

        return EVENT_BILLABILITY.get(MD_DEFAULT_RECORD);
    }

    /**
     * @author          Diego Rincón (DR)
     * @date            2019-06-24
     * @description     Call to enqueable class to update TeleAlert__c children 
     *                  VehicleEvent__x records.
     * @param           Map from trigger context.
     * @return          none
     */
    public static void updateEvents(Map<Id, TeleAlert__c> map_new) {
        if (!System.isQueueable()) {
            AsyncUpdateTeleAlertEvents j = new AsyncUpdateTeleAlertEvents(map_new.keySet());
            System.enqueueJob(j);
        }
    }

    public static void assignRecord(List<TeleAlert__c> lst) {
        for (TeleAlert__c t : lst) {
            if (API_USER_MAP.containsKey(t.OwnerId)) {
                getOwner(t);
            }
        }
    }

    public static void getOwner(TeleAlert__c t) {
        if (matchingConfig(t) != null) {
            Map<String, Object> obj_md = (Map<String, Object>) matchingConfig(t);
            t.OwnerId = obj_md.get('QueueId__c') == null ? t.OwnerId : (Id) obj_md.get('QueueId__c');
            // assigned queue is stored for bussiness hours calculations
            t.TECH_LastQueueId__c = Group.sObjectType == t.OwnerId.getSObjectType() ? t.OwnerId : null;
        }
    }

    public static void hasUserTakenOwnership(
        Map<Id, TeleAlert__c> mapOldRows,
        Map<Id, TeleAlert__c> mapNewRows
    ) {
        for (Id key : mapNewRows.keySet()) {
            if (
                Group.sObjectType == mapOldRows.get(key).OwnerId.getSObjectType() &&
                User.sObjectType == mapNewRows.get(key).OwnerId.getSObjectType() &&
                '1' == mapOldRows.get(key).Status__c
            ) {
                // when an user takes ownership, change status to: taken into account
                mapNewRows.get(key).Status__c = '2';
            }
        }
    }

    public static void isStatusChanged(
        Map<Id, TeleAlert__c> mapOldRows,
        Map<Id, TeleAlert__c> mapNewRows
    ) {
        // directory of TeleAlert__c record id and the
        // status that should be assigned to its VehicleEvent__x records
        Map<Id, String> mapS = new Map<Id, String>();
        List<TeleAlert__c> lstT = new List<TeleAlert__c>();
        

        for (Id key : mapNewRows.keySet()) {
            if (mapOldRows.get(key).Status__c != mapNewRows.get(key).Status__c) {
                switch on mapNewRows.get(key).Status__c {
                    // appointment created
                    when '3' {
                        lstT.add(new TeleAlert__c(
                            Id            = mapNewRows.get(key).Id,
                            ClosedDate__c = System.now()
                        ));
                    }

                    // not reached
                    when '4' {
                        mapS.put(mapNewRows.get(key).Id, '8');
                        lstT.add(new TeleAlert__c(
                            Id            = mapNewRows.get(key).Id,
                            ClosedDate__c = System.now()
                        ));
                    }

                    // discarded
                    when '5' {
                        lstT.add(new TeleAlert__c(
                            Id            = mapNewRows.get(key).Id,
                            ClosedDate__c = System.now()
                        ));
                    }
                    
                    // send to dealer
                    when '6' {
                        // do nothing
                    }
                    
                }
            }
        }

        update lstT;

        if (!mapS.isEmpty() && !System.isQueueable()) {
            AsyncUpdateChildren asyncJob = new AsyncUpdateChildren(mapS);
            System.enqueueJob(asyncJob);
        }
    }


    /**
     * Log a call task rollup field logic. C1STAGILE-7653.
     *
     * @author              Diego Rincón
     * @date                2019-05-09
     * @param       lst     list of TeleAlert records being updated
     * @return              none
     */
    public static void setCallCount(Map<Id, TeleAlert__c> map_t) {
        Map<Id, AggregateResult> map_ar = new Map<Id, AggregateResult>([
            SELECT WhatId Id, COUNT(Id)
            FROM Task
            WHERE
                WhatId IN :map_t.keySet() AND
                TaskSubtype = 'Call'
            GROUP BY WhatId
        ]);

        for (Id key : map_t.keySet()) {
            if (map_ar.containsKey(key)) {
                map_t.get(key).LogCallsCounter__c = (Decimal) map_ar.get(key).get('expr0');
                continue;
            }
            map_t.get(key).LogCallsCounter__c = 0;
        }
    }

    public class AsyncUpdateTeleAlertEvents implements System.Queueable {
        private Set<Id> setT = new Set<Id>();

        // set of assets related to events' parent TeleAlert
        private Set<Id> setA = new Set<Id>();
        private List<VehicleEvent__x> lstE = new List<VehicleEvent__x>();
        private Map<Id, Asset> mapA = new Map<Id, Asset>();
        private Map<Id, VehicleEvent__x> mapE = new Map<Id, VehicleEvent__x>();
        private Map<Id, Id> mapH = new Map<Id, Id>();

        private Map<Id, TeleAlert__c> mapT = new Map<Id, TeleAlert__c>();

        public AsyncUpdateTeleAlertEvents(Set<Id> s) {
            this.setT = s;
        }

        public void execute(QueueableContext context) {
            Set<Id> setQ = new Set<Id>();
            for (TeleAlert__c t : [
                SELECT Id, TECH_LastQueueId__c
                FROM TeleAlert__c
                WHERE Id IN :setT
            ]) {
                if (t.TECH_LastQueueId__c != null) {
                    setQ.add(t.TECH_LastQueueId__c);
                }
            }

            Map<String, Id> mapQ = new Map<String, Id>();

            // current or former queue telealert's owner directory
            for (Group g : [
                SELECT
                    Id, 
                    DeveloperName,
                    Type
                FROM Group
                WHERE
                    Type = 'Queue' AND
                    Id IN :setQ
            ]) {
                mapQ.put(g.DeveloperName, g.Id);
            }

            setQ.clear();

            // business hours related to queues
            for (BusinessHours h : [
                SELECT Id, Name
                FROM BusinessHours
                WHERE Name IN :mapQ.keySet()
            ]) {
                mapH.put(
                    mapQ.get(h.Name),
                    h.Id
                );
            }

            // related asset records
            mapA = new Map<Id, Asset>([
                SELECT
                    Id,
                    (
                        SELECT
                            ExternalId,
                            assetid__c,
                            alerttypecode__c,
                            createddate__c
                        FROM Vehicle_Events2__r
                    )
                FROM Asset
                WHERE Id IN (
                    SELECT assetid__c
                    FROM VehicleEvent__x
                    WHERE telealertid__c IN :setT
                )
            ]);

            // telealert records' vehicle events
            for (VehicleEvent__x e : Test.isRunningTest() ? getMockExternalData() : [
                SELECT
                    Id,
                    assetid__c,
                    treatmentduedate__c,
                    billable__c,
                    createddate__c,
                    alertcode__c,
                    alertcategorycode__c,
                    alerttypecode__c,
                    telealertid__r.Brand__c,
                    telealertid__r.Country__c,
                    telealertid__r.TECH_LastQueueId__c
                FROM VehicleEvent__x
                WHERE telealertid__c IN :setT
            ]) {
                // treatment time lookup
                Map<String, Object> objMetadataT = (Map<String, Object>) eventTreatmentTimeMatch(e);

                if (mapH.containsKey(e.telealertid__r.TECH_LastQueueId__c)) {
                    e.treatmentduedate__c = BusinessHours.add(
                        mapH.get(e.telealertid__r.TECH_LastQueueId__c),
                        e.createddate__c,
                        ((3.6.pow(6)) * (Decimal) objMetadataT.get('TreatmentTime__c')).longValue()
                    );
                } else {
                    e.treatmentduedate__c = e.createddate__c.addHours(
                        ((Decimal) objMetadataT.get('TreatmentTime__c')).intValue()
                    );
                }

                // billability calculation
                if (mapA.containsKey(e.assetid__c)) {
                    for (VehicleEvent__x x : mapA.get(e.assetid__c).Vehicle_Events2__r) {
                        if (e.Id != x.Id && e.alerttypecode__c == x.alerttypecode__c) {
                            Map<String, Object> objMetadataB = (Map<String, Object>) eventBillabilityMatch(e);
                            if (x.createddate__c.addDays(((Decimal) objMetadataB.get('BillabilityThreshold__c')).intValue()) > e.createddate__c) {
                                e.billable__c = true;
                            }
                        }
                    }
                }

                lstE.add(e);
            }

            if (!Test.isRunningTest()) {
                Database.updateImmediate(lstE);
            }

            // loop to choose earliest treatment due date
            for (TeleAlert__c t : [
                SELECT
                Id, OwnerId, Country__c, Brand__c, DueDate__c,
                (
                    SELECT ExternalId, treatmentduedate__c
                    FROM Vehicle_Events__r
                    ORDER BY treatmentduedate__c ASC NULLS LAST
                    LIMIT 1
                )
                FROM TeleAlert__c
                WHERE Id IN: setT
            ]) {
                for (
                    VehicleEvent__x v : Test.isRunningTest() ?
                    getMockExternalData() : t.Vehicle_Events__r
                ) {
                    if (t.DueDate__c != v.treatmentduedate__c) {
                        mapT.put(t.Id, new TeleAlert__c(
                            Id          = t.Id,
                            DueDate__c  = v.treatmentduedate__c
                        ));
                    }
                }
            }

            // loop to choose the highest priority
            for (TeleAlert__c t : [
                SELECT
                Id, Priority__c,
                (
                    SELECT alerttypecode__c
                    FROM Vehicle_Events__r
                    ORDER BY alerttypecode__c ASC NULLS LAST
                    LIMIT 1
                )
                FROM TeleAlert__c
                WHERE Id IN: setT
            ]) {
                for (
                    VehicleEvent__x v : Test.isRunningTest() ?
                    getMockExternalData() : t.Vehicle_Events__r
                ) {
                    if (t.Priority__c != v.alerttypecode__c) {
                        if (mapT.containsKey(t.Id)) {
                            mapt.get(t.Id).Priority__c = v.alerttypecode__c;
                            continue;
                        }

                        mapT.put(t.Id, new TeleAlert__c(
                            Id          = t.Id,
                            Priority__c = v.alerttypecode__c
                        ));
                    }
                }
            }

            update mapT.values();
        }
    }

    public class AsyncUpdateChildren implements System.Queueable {

        private Map<Id, String> mapS;
        List<VehicleEvent__x> lstE = new List<VehicleEvent__x>();

        public AsyncUpdateChildren(Map<Id, String> m) {
            this.mapS = m;
        }

        public void execute(QueueableContext context) {
            for (VehicleEvent__x e : [
                SELECT ExternalId, telealertid__c, telealertresultcode__c
                FROM VehicleEvent__x
                WHERE telealertid__c IN :mapS.keySet()
            ]) {
                if (e.telealertresultcode__c != mapS.get(e.telealertid__c)) {
                    e.telealertresultcode__c = mapS.get(e.telealertid__c);
                    lstE.add(e);
                }
            }

            Database.updateImmediate(lstE);
        }
    }

    /**
     * Return dummy VehicleEvent__x records for test classes.
     *
     * @author      Diego Rincón
     * @date        2019-06-10
     * @param       none
     * @return      list of VehicleEvent__x from static configuration.
     */
    public static List<VehicleEvent__x> getMockExternalData() {
        List<VehicleEvent__x> ret = new List<VehicleEvent__x>();

        for (Map<String, Object> m : TEST_EXT_OBJ_MOCK) {
            ret.add(new VehicleEvent__x(
                pcscontractnumber__c    = m.containsKey('pcscontractnumber__c') ?
                    (Decimal) m.get('pcscontractnumber__c') : null,

                telealertid__r          = m.containsKey('telealertid__r') ?
                    (TeleAlert__c) m.get('telealertid__r') : null,

                createddate__c          = System.now(),
                treatmentduedate__c     = System.now().addMinutes(10),
                alerttypecode__c        = '1'
            ));
        }

        return ret;
    }

}
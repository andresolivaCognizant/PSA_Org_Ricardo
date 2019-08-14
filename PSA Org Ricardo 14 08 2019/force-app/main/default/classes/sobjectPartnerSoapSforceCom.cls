//Generated by wsdl2apex

public class sobjectPartnerSoapSforceCom {
    public class sObject_x {
        public String id;
        public String type_x;
        public String name;
        public String isActive;
        public String isDefault;                   
        public String mondayStartTime;
        public String mondayEndTime;
        public String tuesdayStartTime;
        public String tuesdayEndTime;
        public String wednesdayStartTime;
        public String wednesdayEndTime;
        public String thursdayStartTime;
        public String thursdayEndTime;
        public String fridayStartTime;
        public String fridayEndTime;

        public String saturdayStartTime;
        public String saturdayEndTime;
        public String sundayStartTime;
        public String sundayEndTime;

        public String timeZonesIdKey;


        public String description;
        public String activityDate;
        public String isAllDay;
        public String endTimeInMinutes;
        public String isRecurrence;
        public String recurrenceDayOfMonth;
        public String recurrenceDayOfWeekMask;
        public String recurrenceEndDateOnly;
        public String recurrenceInstance;
        public String recurrenceInterval;
        public String recurrenceMonthOfYear;
        public String recurrenceStartDate;
        public String recurrenceType;
        public String startTimeInMinutes;


        private String[] field_order_type_info;

        //Holiday
        public sObject_x(String type_x, String name, String description, String activityDate, String isAllDay, String startTimeInMinutes, String endTimeInMinutes, String isRecurrence,
                         String recurrenceDayOfWeekMask, String recurrenceInstance, String recurrenceInterval, String recurrenceStartDate, String recurrenceType, String recurrenceEndDateOnly){
            this.type_x = type_x;
            this.name = name;
            this.description = description;
            this.activityDate = activityDate;
            this.isAllDay = isAllDay;

            this.startTimeInMinutes = startTimeInMinutes;
            this.endTimeInMinutes = endTimeInMinutes;
            this.isRecurrence = isRecurrence;
            this.recurrenceDayOfWeekMask = recurrenceDayOfWeekMask;
            this.recurrenceInstance = recurrenceInstance;
            this.recurrenceInterval = recurrenceInterval;
            this.recurrenceStartDate = recurrenceStartDate;
            this.recurrenceType = recurrenceType;
            this.recurrenceEndDateOnly = recurrenceEndDateOnly;
            

            if(type_x == 'Holiday'){
                field_order_type_info = new String[]{'type_x', 'name', 'description', 'activityDate', 'isAllDay', 'startTimeInMinutes', 'endTimeInMinutes', 'isRecurrence', 'recurrenceDayOfWeekMask', 
                'recurrenceInstance', 'recurrenceInterval', 'recurrenceStartDate', 'recurrenceType', 'recurrenceEndDateOnly'};               
            }
        }

        //Holiday
        public sObject_x(String type_x, String name, String description, String activityDate, String isAllDay, String startTimeInMinutes, String endTimeInMinutes){
            this.type_x = type_x;
            this.name = name;
            this.description = description;
            this.activityDate = activityDate;
            this.isAllDay = isAllDay;
            this.startTimeInMinutes = startTimeInMinutes;
            this.endTimeInMinutes = endTimeInMinutes;

            if(type_x == 'Holiday'){
                field_order_type_info = new String[]{'type_x', 'name', 'description', 'activityDate', 'isAllDay', 'startTimeInMinutes', 'endTimeInMinutes'};               
            }
        }

        //Business Hour insert
        public sObject_x(String type_x, String name, String isActive, String isDefault, String mondayStartTime, String mondayEndTime,
                                            String tuesdayStartTime, String tuesdayEndTime, String wednesdayStartTime, String wednesdayEndTime, 
                                            String thursdayStartTime, String thursdayEndTime, String fridayStartTime, String fridayEndTime, 
                                            String saturdayStartTime, String saturdayEndTime, String sundayStartTime, String sundayEndTime, String timeZonesIdKey){

                           
            this.type_x = type_x;
            this.name = name;
            this.isActive = isActive;
            this.isDefault = isDefault;
            this.mondayStartTime = mondayStartTime;
            this.mondayEndTime = mondayEndTime;
            this.tuesdayStartTime = tuesdayStartTime;
            this.tuesdayEndTime = tuesdayEndTime;
            this.wednesdayStartTime = wednesdayStartTime;
            this.wednesdayEndTime = wednesdayEndTime;
            this.thursdayStartTime = thursdayStartTime;
            this.thursdayEndTime = thursdayEndTime;
            this.fridayStartTime = fridayStartTime;
            this.fridayEndTime = fridayEndTime;
            this.saturdayStartTime = saturdayStartTime;
            this.saturdayEndTime = saturdayEndTime;
            this.sundayStartTime = sundayStartTime;
            this.sundayEndTime = sundayEndTime;
            this.timeZonesIdKey = timeZonesIdKey;

            if(type_x == 'BusinessHours'){
                field_order_type_info = new String[]{'type_x','fieldsToNull','id','name','isActive','isDefault','mondayStartTime',
                        'mondayEndTime','tuesdayStartTime','tuesdayEndTime','wednesdayStartTime','wednesdayEndTime','thursdayStartTime','thursdayEndTime',
                        'fridayStartTime','fridayEndTime', 'saturdayStartTime', 'saturdayEndTime', 'sundayStartTime', 'sundayEndTime', 'timeZonesIdKey'};               
            }
        }

        //Business Hour update
        public sObject_x(String type_x, String id, String name, String isActive, String isDefault, String mondayStartTime, String mondayEndTime,
                                            String tuesdayStartTime, String tuesdayEndTime, String wednesdayStartTime, String wednesdayEndTime, 
                                            String thursdayStartTime, String thursdayEndTime, String fridayStartTime, String fridayEndTime, 
                                            String saturdayStartTime, String saturdayEndTime, String sundayStartTime, String sundayEndTime, String timeZonesIdKey){
                            
            this.id = id; 
            this.type_x = type_x;
            this.name = name;
            this.isActive = isActive;
            this.isDefault = isDefault;
            this.mondayStartTime = mondayStartTime;
            this.mondayEndTime = mondayEndTime;
            this.tuesdayStartTime = tuesdayStartTime;
            this.tuesdayEndTime = tuesdayEndTime;
            this.wednesdayStartTime = wednesdayStartTime;
            this.wednesdayEndTime = wednesdayEndTime;
            this.thursdayStartTime = thursdayStartTime;
            this.thursdayEndTime = thursdayEndTime;
            this.fridayStartTime = fridayStartTime;
            this.fridayEndTime = fridayEndTime;
            this.saturdayStartTime = saturdayStartTime;
            this.saturdayEndTime = saturdayEndTime;
            this.sundayStartTime = sundayStartTime;
            this.sundayEndTime = sundayEndTime;
            this.timeZonesIdKey = timeZonesIdKey;

            if(type_x == 'BusinessHours'){
                field_order_type_info = new String[]{'type_x','fieldsToNull','id','name','isActive','isDefault','mondayStartTime',
                        'mondayEndTime','tuesdayStartTime','tuesdayEndTime','wednesdayStartTime','wednesdayEndTime','thursdayStartTime','thursdayEndTime',
                        'fridayStartTime','fridayEndTime', 'saturdayStartTime', 'saturdayEndTime', 'sundayStartTime', 'sundayEndTime', 'timeZonesIdKey'};               
            }
        }


        private String[] name_type_info = new String[]{'name','urn:sobject.partner.soap.sforce.com',null,'1','1','false'};
        private String[] isActive_type_info = new String[]{'isActive','urn:sobject.partner.soap.sforce.com',null,'1','1','false'};
        private String[] isDefault_type_info = new String[]{'isDefault','urn:sobject.partner.soap.sforce.com',null,'1','1','false'};
        private String[] mondayStartTime_type_info = new String[]{'mondayStartTime','urn:sobject.partner.soap.sforce.com',null,'1','1','false'};
        private String[] mondayEndTime_type_info = new String[]{'mondayEndTime','urn:sobject.partner.soap.sforce.com',null,'1','1','false'};
        private String[] tuesdayStartTime_type_info = new String[]{'tuesdayStartTime','urn:sobject.partner.soap.sforce.com',null,'1','1','false'};
        private String[] tuesdayEndTime_type_info = new String[]{'tuesdayEndTime','urn:sobject.partner.soap.sforce.com',null,'1','1','false'};
        private String[] wednesdayStartTime_type_info = new String[]{'wednesdayStartTime','urn:sobject.partner.soap.sforce.com',null,'1','1','false'};
        private String[] wednesdayEndTime_type_info = new String[]{'wednesdayEndTime','urn:sobject.partner.soap.sforce.com',null,'1','1','false'};
        private String[] thursdayStartTime_type_info = new String[]{'thursdayStartTime','urn:sobject.partner.soap.sforce.com',null,'1','1','false'};
        private String[] thursdayEndTime_type_info = new String[]{'thursdayEndTime','urn:sobject.partner.soap.sforce.com',null,'1','1','false'};
        private String[] fridayStartTime_type_info = new String[]{'fridayStartTime','urn:sobject.partner.soap.sforce.com',null,'1','1','false'};
        private String[] fridayEndTime_type_info = new String[]{'fridayEndTime','urn:sobject.partner.soap.sforce.com',null,'1','1','false'};

        private String[] saturdayStartTime_type_info = new String[]{'saturdayStartTime','urn:sobject.partner.soap.sforce.com',null,'1','1','false'};
        private String[] saturdayEndTime_type_info = new String[]{'saturdayEndTime','urn:sobject.partner.soap.sforce.com',null,'1','1','false'};
        private String[] sundayStartTime_type_info = new String[]{'sundayStartTime','urn:sobject.partner.soap.sforce.com',null,'1','1','false'};
        private String[] sundayEndTime_type_info = new String[]{'sundayEndTime','urn:sobject.partner.soap.sforce.com',null,'1','1','false'};

        private String[] timeZonesIdKey_type_info = new String[]{'timeZonesIdKey','urn:sobject.partner.soap.sforce.com',null,'1','1','false'};

        private String[] description_type_info = new String[]{'description','urn:sobject.partner.soap.sforce.com',null,'1','1','false'};
        private String[] activityDate_type_info = new String[]{'activityDate','urn:sobject.partner.soap.sforce.com',null,'1','1','false'};
        private String[] isAllDay_type_info = new String[]{'isAllDay','urn:sobject.partner.soap.sforce.com',null,'1','1','false'};

        private String[] endTimeInMinutes_type_info = new String[]{'endTimeInMinutes','urn:sobject.partner.soap.sforce.com',null,'1','1','false'};
        private String[] isRecurrence_type_info = new String[]{'isRecurrence','urn:sobject.partner.soap.sforce.com',null,'1','1','false'};
        private String[] recurrenceDayOfWeekMask_type_info = new String[]{'recurrenceDayOfWeekMask','urn:sobject.partner.soap.sforce.com',null,'1','1','false'};
        private String[] recurrenceInstance_type_info = new String[]{'recurrenceInstance','urn:sobject.partner.soap.sforce.com',null,'1','1','false'};
        private String[] recurrenceInterval_type_info = new String[]{'recurrenceInterval','urn:sobject.partner.soap.sforce.com',null,'1','1','false'};
        private String[] recurrenceStartDate_type_info = new String[]{'recurrenceStartDate','urn:sobject.partner.soap.sforce.com',null,'1','1','false'};
        private String[] recurrenceType_type_info = new String[]{'recurrenceType','urn:sobject.partner.soap.sforce.com',null,'1','1','false'};
        private String[] recurrenceEndDateOnly_type_info = new String[]{'recurrenceEndDateOnly','urn:sobject.partner.soap.sforce.com',null,'1','1','false'};
        private String[] startTimeInMinutes_type_info = new String[]{'startTimeInMinutes','urn:sobject.partner.soap.sforce.com',null,'1','1','false'};
        
        public String[] fieldsToNull;
       
        private String[] type_x_type_info = new String[]{'type','urn:sobject.partner.soap.sforce.com',null,'1','1','false'};
        private String[] fieldsToNull_type_info = new String[]{'fieldsToNull','urn:sobject.partner.soap.sforce.com',null,'0','-1','true'};
        private String[] id_type_info = new String[]{'id','urn:sobject.partner.soap.sforce.com',null,'1','1','true'};
        private String[] apex_schema_type_info = new String[]{'urn:sobject.partner.soap.sforce.com','true','false'};
        
    }
}
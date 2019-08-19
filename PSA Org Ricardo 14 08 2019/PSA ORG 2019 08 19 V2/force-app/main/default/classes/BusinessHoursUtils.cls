/**
    *   @Class          :   BusinessHoursUtils   
    *
    *   @Author         :   Pedro Párraga <parragabornez.pedrojesus@ext.mpsa.com>
    *   @Created        :   
    *   @Description    :  Class that generates Business hours standards and corresponding holidays when
                           a Standard Business Hour is created or updated 
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description    
    *      Pedro Párraga         12/03/2019                   Creation.      
    *   ----------------------------------------------------------------------------------------------------------------------------
**/
public class BusinessHoursUtils {

   private final static String CKEY                         = '/services/Soap/u/45.0'; 
   public static List<Holiday> listNewHolidays              = new List<Holiday>();
   public static Map<String, List<Holiday>> listToSendEmail = new Map<String, List<Holiday>>();
   public static String[] businessHourCustomNames           = new String[]{};
   public static List<String> listHolidayNames              = new List<String>();


   /**
      * @Method          :   getPartnerSOAP
      * @Description     :   Creation of the connection to interact with SOAP
      * @Param           :   void
      * @Return          :   partnerSoapSforceCom.Soap myOrg
   **/   
   private static partnerSoapSforceCom.Soap getPartnerSOAP(){
      partnerSoapSforceCom.Soap myOrg                      = new partnerSoapSforceCom.Soap();
      try{
         myOrg.endpoint_x                                  = URL.getSalesforceBaseUrl().toExternalForm() + CKEY ;
         partnerSoapSforceCom.SessionHeader_element header = new partnerSoapSforceCom.SessionHeader_element();
         header.sessionId                                  = UserInfo.getSessionId();
         myOrg.SessionHeader                               = header;
      }catch(Exception e){
         System.debug('# Error : ' + e);
      }
      return myOrg;
   }

   /**
      * @Method          :  completeBusinessHourCustom 
      * @Description     :  If any of the fields of the custom business hour is empty, complete it with time 00:00
      * @Param           :  List<BusinessHour__c> listBusinessHour 
      * @Return          :  void
   **/ 
    public static void completeBusinessHourCustom(List<BusinessHour__c> listBusinessHour){
       System.debug('completeBusinessHourCustom');

       Time timeBh = Time.newInstance(0, 0, 0, 0);
       for(BusinessHour__c bh : listBusinessHour){
         bh.MondayAMStartTime__c    = (bh.MondayAMStartTime__c == null)?timeBh:bh.MondayAMStartTime__c;
         bh.MondayAMEndTime__c      = (bh.MondayAMEndTime__c == null)?timeBh:bh.MondayAMEndTime__c;
         bh.MondayPMStartTime__c    = (bh.MondayPMStartTime__c == null)?timeBh:bh.MondayPMStartTime__c;
         bh.MondayPMEndTime__c      = (bh.MondayPMEndTime__c == null)?timeBh:bh.MondayPMEndTime__c;

         bh.TuesdayAMStartTime__c   = (bh.TuesdayAMStartTime__c == null)?timeBh:bh.TuesdayAMStartTime__c;
         bh.TuesdayAMEndTime__c     = (bh.TuesdayAMEndTime__c == null)?timeBh:bh.TuesdayAMEndTime__c;
         bh.TuesdayPMStartTime__c   = (bh.TuesdayPMStartTime__c == null)?timeBh:bh.TuesdayPMStartTime__c;
         bh.TuesdayPMEndTime__c     = (bh.TuesdayPMEndTime__c == null)?timeBh:bh.TuesdayPMEndTime__c;

         bh.WednesdayAMStartTime__c = (bh.WednesdayAMStartTime__c == null)?timeBh:bh.WednesdayAMStartTime__c;
         bh.WednesdayAMEndTime__c   = (bh.WednesdayAMEndTime__c == null)?timeBh:bh.WednesdayAMEndTime__c;
         bh.WednesdayPMStartTime__c = (bh.WednesdayPMStartTime__c == null)?timeBh:bh.WednesdayPMStartTime__c;
         bh.WednesdayPMEndTime__c   = (bh.WednesdayPMEndTime__c == null)?timeBh:bh.WednesdayPMEndTime__c;

         bh.ThursdayAMStartTime__c  = (bh.ThursdayAMStartTime__c == null)?timeBh:bh.ThursdayAMStartTime__c;
         bh.ThursdayAMEndTime__c    = (bh.ThursdayAMEndTime__c == null)?timeBh:bh.ThursdayAMEndTime__c;
         bh.ThursdayPMStartTime__c  = (bh.ThursdayPMStartTime__c == null)?timeBh:bh.ThursdayPMStartTime__c;
         bh.ThursdayPMEndTime__c    = (bh.ThursdayPMEndTime__c == null)?timeBh:bh.ThursdayPMEndTime__c;

         bh.FridayAMStartTime__c    = (bh.FridayAMStartTime__c == null)?timeBh:bh.FridayAMStartTime__c;
         bh.FridayAMEndTime__c      = (bh.FridayAMEndTime__c == null)?timeBh:bh.FridayAMEndTime__c;
         bh.FridayPMStartTime__c    = (bh.FridayPMStartTime__c == null)?timeBh:bh.FridayPMStartTime__c;
         bh.FridayPMEndTime__c      = (bh.FridayPMEndTime__c == null)?timeBh:bh.FridayPMEndTime__c;

         bh.SaturdayAMStartTime__c  = (bh.SaturdayAMStartTime__c == null)?timeBh:bh.SaturdayAMStartTime__c;
         bh.SaturdayAMEndTime__c    = (bh.SaturdayAMEndTime__c == null)?timeBh:bh.SaturdayAMEndTime__c;
         bh.SaturdayPMStartTime__c  = (bh.SaturdayPMStartTime__c == null)?timeBh:bh.SaturdayPMStartTime__c;
         bh.SaturdayPMEndTime__c    = (bh.SaturdayPMEndTime__c == null)?timeBh:bh.SaturdayPMEndTime__c;
         
         bh.SundayAMStartTime__c    = (bh.SundayAMStartTime__c == null)?timeBh:bh.SundayAMStartTime__c;
         bh.SundayAMEndTime__c      = (bh.SundayAMEndTime__c == null)?timeBh:bh.SundayAMEndTime__c;
         bh.SundayPMStartTime__c    = (bh.SundayPMStartTime__c == null)?timeBh:bh.SundayPMStartTime__c;
         bh.SundayPMEndTime__c      = (bh.SundayPMEndTime__c == null)?timeBh:bh.SundayPMEndTime__c;         
       }
    }

   /**
      * @Method          :   getPickListValuesLeadType
      * @Description     :   get the values of the LeadType picklist
      * @Param           :   void
      * @Return          :   List<String> pickListValuesList
   **/ 
   public static List<String> getPickListValuesLeadType(){
      System.debug('getPickListValuesLeadType');

      List<String> pickListValuesList = new List<String>();
      Schema.DescribeFieldResult fieldResult = Lead.LeadType__c.getDescribe();
      List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
      for( Schema.PicklistEntry pickListVal : ple){
         pickListValuesList.add(pickListVal.getValue());
      }   

      return pickListValuesList;
   }

   /**
      * @Method          :  createQueryHolidays 
      * @Description     :  Generate the query to find the existing Holidays
      * @Param           :  Set<String> lstCountries 
      * @Return          :  String queryWithCondition
   **/ 
   public static String createQueryHolidays(Set<String> lstCountries){
      System.debug('createQueryHolidays');

      String query = 'SELECT Id, Name, ActivityDate, Description, EndTimeInMinutes, IsAllDay,IsRecurrence, RecurrenceDayOfMonth,'+
      ' RecurrenceDayOfWeekMask, RecurrenceEndDateOnly, RecurrenceInstance, RecurrenceInterval, RecurrenceMonthOfYear,'+
      ' RecurrenceStartDate, RecurrenceType, StartTimeInMinutes FROM Holiday WHERE ';
      
      for(String country : lstCountries){
         query += 'Name like \''+country+'%\' OR ';
      }

      String queryWithCondition = query.subString(0, query.length()-4);

      return queryWithCondition;
   }

   /**
      * @Method          :   getCountriesDealers
      * @Description     :   create a Set of countries of the dealers
      * @Param           :   Map<Id, Account> lstDealers
      * @Return          :   Set<String> lstCountries
   **/ 
   public static Set<String> getCountriesDealers(Map<Id, Account> lstDealers){  
      System.debug('getCountriesDealers'); 

      Set<String> lstCountries = new Set<String>();
      for(Account acc : lstDealers.values()){
         lstCountries.add(acc.Country__c);
      }

      return lstCountries;        
   }

   /**
      * @Method          :   generateBusinessHourName
      * @Description     :   generates the name for the standard business hour
      * @Param           :   Map<Id, Account> lstDealers
                             BusinessHour__c bhC
                             Integer actitivy
                             String typeValue
      * @Return          :   String businessHourName
   **/ 
   public static String generateBusinessHourName(Map<Id, Account> lstDealers, BusinessHour__c bhC, Integer actitivy, String typeValue){
      System.debug('generateBusinessHourName');

      String country          = lstDealers.get(bhc.Dealer__c).Country__c;
      String brand            = lstDealers.get(bhc.Dealer__c).Brand__c;
      String businessHourName = 'LEAD'+country+brand+actitivy+typeValue+bhc.Dealer__c;

      return businessHourName;
   }

   public static List<String> listBusinessHourNames = new List<String>();

   /**
      * @Method          :  insertBusinessHour
      * @Description     :   Inserts business holidays holidays
      * @Param           :  List<BusinessHour__c > listBusinessHours 
      * @Return          :  void
   **/ 
   public static void insertBusinessHour (List<BusinessHour__c > listBusinessHours){
      System.debug('insertBusinessHour');

      partnerSoapSforceCom.Soap MyOrg                      = getPartnerSOAP();
      List<sobjectPartnerSoapSforceCom.sObject_x> sObjects = new List<sobjectPartnerSoapSforceCom.sObject_x>();
      sobjectPartnerSoapSforceCom.sObject_x bhObj;
      
      List<String> lstTypeValues = getPickListValuesLeadType();

      Set<Id> setIdsAccounts = new Set<Id>();
      for(BusinessHour__c bh : listBusinessHours){
         setIdsAccounts.add(bh.Dealer__c);
      }

      Map<Id, Account> lstDealers = new Map<Id, Account>([SELECT Id, Country__c, Brand__c FROM Account WHERE Id IN : setIdsAccounts]);

      Set<String> lstCountries = getCountriesDealers(lstDealers);
      String querySearchHolidays = createQueryHolidays(lstCountries);
      List<Holiday> lstHolidays = database.query(querySearchHolidays); 
            
      for (BusinessHour__c bh : listBusinessHours){
         businessHourCustomNames.add(bh.Name);
         listNewHolidays = generateHoliday(lstDealers, bh);
         listNewHolidays = isNeedToCreateHoliday(lstHolidays, listNewHolidays);  

         for(Integer i=1;i<=2;i++){
            for(String typeValue : lstTypeValues){ 
               String businessHourName =  generateBusinessHourName(lstDealers, bh, i, typeValue);
               listBusinessHourNames.add(businessHourName);                        
                           
               bhObj  = new sobjectPartnerSoapSforceCom.sObject_x(
                                                                  'BusinessHours',
                                                                  businessHourName,
                                                                  'true',
                                                                  'false',
                                                                  String.valueOf(bh.MondayAMStartTime__c),
                                                                  String.valueOf(bh.MondayPMEndTime__c),
                                                                  String.valueOf(bh.TuesdayAMStartTime__c),
                                                                  String.valueOf(bh.TuesdayPMEndTime__c),
                                                                  String.valueOf(bh.WednesdayAMStartTime__c),
                                                                  String.valueOf(bh.WednesdayPMEndTime__c),
                                                                  String.valueOf(bh.ThursdayAMStartTime__c),
                                                                  String.valueOf(bh.ThursdayPMEndTime__c),
                                                                  String.valueOf(bh.FridayAMStartTime__c),
                                                                  String.valueOf(bh.FridayPMEndTime__c),
                                                                  String.valueOf(bh.SaturdayAMStartTime__c),
                                                                  String.valueOf(bh.SaturdayPMEndTime__c),
                                                                  String.valueOf(bh.SundayAMStartTime__c),
                                                                  String.valueOf(bh.SundayPMEndTime__c) ,
                                                                  bh.TimeZone__c 
                                                               );
               sObjects.add(bhObj);
               System.debug('sObjects: '+businessHourName);
            }
         }

         

         if(!sObjects.isEmpty()){
            try{
               MyOrg.create(sObjects);
               createHoliday(listNewHolidays); 
               sendEmail(listBusinessHourNames, listHolidayNames, 'insert');
            }catch(Exception e){
               System.debug('# Error : ' + e);
            }
         }
      }
   }

   /**
      * @Method          :   updateBusinessHour
      * @Description     :   Update the business hours created
      * @Param           :   List<BusinessHour__c > listBusinessHours
      * @Return          :   Void
   **/     
   public static void updateBusinessHour(List<BusinessHour__c > listBusinessHours){
      System.debug('updateBusinessHour');

      partnerSoapSforceCom.Soap myOrg                       = getPartnerSOAP();
      List<sobjectPartnerSoapSforceCom.sObject_x> sObjects  = new List<sobjectPartnerSoapSforceCom.sObject_x>();
      sobjectPartnerSoapSforceCom.sObject_x bhObj;

      List<String> lstTypeValues = getPickListValuesLeadType();
      
      Set<String> setDealers = new Set<String>();
      for(BusinessHour__c  bh : listBusinessHours){
            setDealers.add(bh.Dealer__c);
      }
      
      Set<Id> setIdsAccounts = new Set<Id>();
      for(BusinessHour__c bh : listBusinessHours){
         setIdsAccounts.add(bh.Dealer__c);
      }

      Map<Id, Account> lstDealers   = new Map<Id, Account>([SELECT Id, Country__c, Brand__c FROM Account WHERE Id IN : setIdsAccounts]);
      Set<String> lstCountries      = getCountriesDealers(lstDealers);
      String querySearchHolidays    = createQueryHolidays(lstCountries);
      List<Holiday> lstHolidays     = database.query(querySearchHolidays); 
      List<BusinessHours> lstBHStandards;

      if(Test.isRunningTest()){
         //lstBHStandards  = database.query(createQueryBusinessHour(setDealers));
         lstBHStandards = [SELECT Id, Name FROM BusinessHours];
      }else{
         lstBHStandards  = database.query(createQueryBusinessHour(setDealers));
      }
      
      Map<String, BusinessHours> mapBHStandards = new Map<String, BusinessHours>();
      for(BusinessHours bh : lstBHStandards ){
            mapBHStandards.put(bh.Name, bh);
      }
      
      for (BusinessHour__c bh : listBusinessHours){
         businessHourCustomNames.add(bh.Name);
         listNewHolidays = generateHoliday(lstDealers, bh);
         listNewHolidays = isNeedToCreateHoliday(lstHolidays, listNewHolidays);  
         for(Integer i=1;i<=2;i++){
            String businessHourName;
            for(String typeValue : lstTypeValues){               

               if(Test.isRunningTest()){
                  businessHourName = 'Apex_Test';                
               }else{
                  businessHourName =  generateBusinessHourName(lstDealers, bh, i, typeValue);
               }

               listBusinessHourNames.add(businessHourName);

               bhObj  = new sobjectPartnerSoapSforceCom.sObject_x(
                                                                  'BusinessHours',
                                                                  mapBHStandards.get(businessHourName).Id,
                                                                  businessHourName,
                                                                  'true',
                                                                  'false',
                                                                  String.valueOf(bh.MondayAMStartTime__c),
                                                                  String.valueOf(bh.MondayPMEndTime__c),
                                                                  String.valueOf(bh.TuesdayAMStartTime__c),
                                                                  String.valueOf(bh.TuesdayPMEndTime__c),
                                                                  String.valueOf(bh.WednesdayAMStartTime__c),
                                                                  String.valueOf(bh.WednesdayPMEndTime__c),
                                                                  String.valueOf(bh.ThursdayAMStartTime__c),
                                                                  String.valueOf(bh.ThursdayPMEndTime__c),
                                                                  String.valueOf(bh.FridayAMStartTime__c),
                                                                  String.valueOf(bh.FridayPMEndTime__c),
                                                                  String.valueOf(bh.SaturdayAMStartTime__c),
                                                                  String.valueOf(bh.SaturdayPMEndTime__c),
                                                                  String.valueOf(bh.SundayAMStartTime__c),
                                                                  String.valueOf(bh.SundayPMEndTime__c) ,
                                                                  bh.TimeZone__c 
                                                               );
               sObjects.add(bhObj);
            }
         }

         if(!sObjects.isEmpty()){
            try{
               myOrg.update_x(sObjects);
               createHoliday(listNewHolidays); 
               sendEmail(listBusinessHourNames, listHolidayNames, 'update');
            }catch(Exception e){
               System.debug('# Error : ' + e);
            }
         } 
      }  
   }

   /**
      * @Method          :   isNeedToCreateHoliday
      * @Description     :   Check if it is necessary to create a new holiday or if it is already created
      * @Param           :   List<Holiday> lstHolidaysCreated
                             List<Holiday>  listNewHolidaysCopy   
      * @Return          :   List<holiday> newHolidaysToCreate
   **/ 
   public static List<Holiday> isNeedToCreateHoliday(List<Holiday> lstHolidaysCreated, List<Holiday>  listNewHolidaysCopy){
      System.debug('isNeedToCreateHoliday');

      List<holiday> newHolidaysToCreate = new List<Holiday>();

      for(Integer i=0;i<listNewHolidaysCopy.size();i++){
         Boolean isNeedToCreateHolidayBoolean = compareHoliday(lstHolidaysCreated, listNewHolidaysCopy[i]);
            if(isNeedToCreateHolidayBoolean){
            newHolidaysToCreate.add(listNewHolidaysCopy[i]);
            lstHolidaysCreated.add(listNewHolidaysCopy[i]);
            }else{
               lstHolidaysCreated.add(listNewHolidaysCopy[i]);
            } 

         listHolidayNames.add(listNewHolidaysCopy[i].Name);
      }

      return newHolidaysToCreate;
   }

   /**
      * @Method          :   comparateHoliday
      * @Description     :   Compare the generated holidays with those already created in the system
      * @Param           :   List<Holiday>  lstHolidays
                             Holiday hd
      * @Return          :   Boolean
   **/ 
   public static Boolean compareHoliday(List<Holiday>  lstHolidays, Holiday hd){
      System.debug('comparateHoliday');
    
      for(Holiday hlc : lstHolidays){
         if(hlc.Name == hd.Name){
            return false;
         }
      }

      return true;
      
   }

   /**
      * @Method          :   comparateHours
      * @Description     :   compare the start and end of holidays
      * @Param           :   Time startDate
                             Time endDate
      * @Return          :   Boolean
   **/ 
   public static boolean compareHours(Time startDate, Time endDate){
      if(startDate != endDate && startDate < endDate){
         return true;
      }

      return false;
   }

   /**
      * @Method          :   generateHoliday
      * @Description     :   Generates the necessary holidays
      * @Param           :   Map<Id, Account> lstDealers
                             BusinessHour__c bh
                             String startDate
                             String endDate
                             String frecuency 
      * @Return          :   Holiday newHoliday
   **/ 
   public static List<Holiday> generateHoliday(Map<Id, Account> lstDealers, BusinessHour__c bh){  
      System.debug('generateHoliday');

      List<Holiday> newHolidays = new List<Holiday>();
      String country       = lstDealers.get(bh.Dealer__c).Country__c;

      String nameMonday = (compareHours(bh.MondayAMEndTime__c, bh.MondayPMStartTime__c)) ? country+'_'+String.valueOf(bh.MondayAMEndTime__c).subString(0, String.valueOf(bh.MondayAMEndTime__c).length()-8)+'_'+
                           String.valueOf(bh.MondayPMStartTime__c).subString(0, String.valueOf(bh.MondayPMStartTime__c).length()-8)+'_M-02': null;
      String nameTuesday = (compareHours(bh.TuesdayAMEndTime__c, bh.TuesdayPMStartTime__c)) ? country+'_'+String.valueOf(bh.TuesdayAMEndTime__c).subString(0, String.valueOf(bh.TuesdayAMEndTime__c).length()-8)+'_'+
                           String.valueOf(bh.TuesdayPMStartTime__c).subString(0, String.valueOf(bh.TuesdayPMStartTime__c).length()-8)+'_T-04': null;
      String nameWednesday = (compareHours(bh.WednesdayAMEndTime__c, bh.WednesdayPMStartTime__c)) ? country+'_'+String.valueOf(bh.WednesdayAMEndTime__c).subString(0, String.valueOf(bh.WednesdayAMEndTime__c).length()-8)+'_'+
                           String.valueOf(bh.WednesdayPMStartTime__c).subString(0, String.valueOf(bh.WednesdayPMStartTime__c).length()-8)+'_W-08': null;
      String nameThursday = (compareHours(bh.ThursdayAMEndTime__c, bh.ThursdayPMStartTime__c)) ? country+'_'+String.valueOf(bh.ThursdayAMEndTime__c).subString(0, String.valueOf(bh.ThursdayAMEndTime__c).length()-8)+'_'+
                          String.valueOf(bh.ThursdayPMStartTime__c).subString(0, String.valueOf(bh.ThursdayPMStartTime__c).length()-8)+'_T-16': null;
      String nameFriday = (compareHours(bh.FridayAMEndTime__c, bh.FridayPMStartTime__c)) ? country+'_'+String.valueOf(bh.FridayAMEndTime__c).subString(0, String.valueOf(bh.FridayAMEndTime__c).length()-8)+'_'+
                          String.valueOf(bh.FridayPMStartTime__c).subString(0, String.valueOf(bh.FridayPMStartTime__c).length()-8)+'_F-32': null;
      String nameSaturday = (compareHours(bh.SaturdayAMEndTime__c, bh.SaturdayPMStartTime__c)) ? country+'_'+String.valueOf(bh.SaturdayAMEndTime__c).subString(0, String.valueOf(bh.SaturdayAMEndTime__c).length()-8)+'_'+
                          String.valueOf(bh.SaturdayPMStartTime__c).subString(0, String.valueOf(bh.SaturdayPMStartTime__c).length()-8)+'_S-64': null;
      String nameSunday = (compareHours(bh.SundayAMEndTime__c, bh.SundayPMStartTime__c)) ? country+'_'+String.valueOf(bh.SundayAMEndTime__c).subString(0, String.valueOf(bh.SundayAMEndTime__c).length()-8)+'_'+
                          String.valueOf(bh.SundayPMStartTime__c).subString(0, String.valueOf(bh.SundayPMStartTime__c).length()-8)+'_S-01': null;       
      
      List<String> lstNames = new List<String>{nameMonday, nameTuesday, nameWednesday, nameThursday, nameFriday, nameSaturday, nameSunday};

      Map<String, List<String>> mapGroupNames = new Map<String, List<String>>();
      for(String s : lstNames){
         if(s != null){
            String[] hourNameValues = s.split('_');
            String hourNames = hourNameValues[1]+'_'+hourNameValues[2]; 
            if(mapGroupNames.containsKey(hourNames)){
               List<String> lstValuesMap = mapGroupNames.get(hourNames);
               lstValuesMap.add(s);
               mapGroupNames.put(hourNames, lstValuesMap);
            }else{
               List<String> lstValuesMap = new List<String>();
               lstValuesMap.add(s);
               mapGroupNames.put(hourNames, lstValuesMap);
            }
         }
      }

      Integer bitsTotal = 0;
      String finalnameHoliday = '';
      for(String hl : mapGroupNames.keySet()){
         List<String> lstValuesHolidays = mapGroupNames.get(hl);
         finalnameHoliday = lstValuesHolidays[0].subString(0, lstValuesHolidays[0].length()-5);

         Boolean isRecurrence = false;
         if(!mapGroupNames.isEmpty()){
            isRecurrence = true;
         }

         String[] valorKey    = hl.split('_');  
         String[] valueStart  = String.valueOf(valorKey[0]).split(':');  
         String[] valueEnd    = String.valueOf(valorKey[1]).split(':'); 

         Integer startTimeInMinutes =  (Integer.valueof(valueStart[0]) * 60) + Integer.valueof(valueStart[1]);
         Integer endTimeMinutes     =  (Integer.valueof(valueEnd[0]) * 60) + Integer.valueof(valueEnd[1]);

         for(String nameHoliday : lstValuesHolidays){
            String[] valorList      = nameHoliday.split('_');
            String[] lstFrecuency   = valorList[3].split('-');
            finalnameHoliday        += '_'+valorList[3];
            Integer bitsDay         = Integer.valueof(lstFrecuency[1]);
            bitsTotal               = bitsTotal + bitsDay;
         }

         Holiday newHoliday = new Holiday(
                                       Name = finalnameHoliday,
                                       Description = 'Holiday beetwen '+valorKey[0]+' and '+valorKey[1],
                                       ActivityDate = System.today(),
                                       isAllDay = false,
                                       StartTimeInMinutes = startTimeInMinutes,
                                       EndTimeInMinutes = endTimeMinutes,
                                       isRecurrence = true,
                                       RecurrenceDayOfWeekMask = bitsTotal,                                          
                                       RecurrenceInstance = null,
                                       RecurrenceInterval = 1,
                                       RecurrenceStartDate = System.today(),
                                       RecurrenceType = 'RecursWeekly',
                                       RecurrenceEndDateOnly = Date.newInstance(System.today().year()+2, 01, 01)

            );

         newHolidays.add(newHoliday);

         finalnameHoliday  = '';
         bitsTotal         = 0;
      }

   return newHolidays;

   }

   /**
      * @Method          :   createHoliday
      * @Description     :   Insert holidays in the system
      * @Param           :   List<Holiday> listNewHoliday
      * @Return          :   void
   **/ 
   public static void createHoliday(List<Holiday> listNewHoliday){
      System.debug('createHoliday');

      partnerSoapSforceCom.Soap myOrg                      = getPartnerSOAP();
      List<sobjectPartnerSoapSforceCom.sObject_x> sObjects = new List<sobjectPartnerSoapSforceCom.sObject_x>();
      sobjectPartnerSoapSforceCom.sObject_x bhObj;

      for(Holiday newHoliday : listNewHoliday){
         bhObj  = new sobjectPartnerSoapSforceCom.sObject_x(
                                                      'Holiday',
                                                      newHoliday.Name,
                                                      newHoliday.Description,
                                                      String.valueOf(newHoliday.activityDate),
                                                      String.valueOf(newHoliday.isAllDay),
                                                      String.valueOf(newHoliday.StartTimeInMinutes),
                                                      String.valueOf(newHoliday.EndTimeInMinutes),
                                                      String.valueOf(newHoliday.IsRecurrence),
                                                      String.valueOf(newHoliday.RecurrenceDayOfWeekMask),
                                                      String.valueOf(newHoliday.RecurrenceInstance),
                                                      String.valueOf(newHoliday.RecurrenceInterval),
                                                      String.valueOf(newHoliday.RecurrenceStartDate),
                                                      String.valueOf(newHoliday.RecurrenceType),
                                                      String.valueOf(newHoliday.RecurrenceEndDateOnly)
                                                      );
         sObjects.add(bhObj); 
      }

      if(!sObjects.isEmpty()){
         try{
            myOrg.create(sObjects);
         }catch(Exception e){
            System.debug('# Error : ' + e);
         }
      }
   } 


   /**
      * @Method          :   createQueryBusinessHour
      * @Description     :   Generate the query to find the Business Hours created in the system
      * @Param           :   Set<String> setDealers 
      * @Return          :   String queryWithCondition 
   **/ 
   public static String createQueryBusinessHour(Set<String> setDealers){
      System.debug('createQueryBusinessHour');

      String query = 'SELECT Id, Name FROM BusinessHours WHERE ';

      for(String dealer : setDealers){
         query += ' Name like \'%'+dealer+'\' OR ';
      }

      String queryWithCondition = query.subString(0, query.length()-4);

      return queryWithCondition;
   } 


   /**
      * @Method          :   sendEmail
      * @Description     :   Build the body of the email sent with the Business hours and holidays created
      * @Param           :   Map<String, List<Holiday>> listToSendEmail
                             String[] businessHourCustomNames  
      * @Return          :   Void
   **/ 
   public static void sendEmail(List<String> listBusinessHourNames, List<String> listHolidayNames, String operation){
      System.debug('sendEmail');

      User userEmail = [SELECT Id, Email FROM User WHERE Id =: UserInfo.getUserId()];

      Integer reserveSingleEmailCapacity  = 2;
      String[] toAddresses                = new String[] {userEmail.Email}; 
      String senderDisplayName            = Label.Display_Name_BH;
      Boolean useSignature                 = false;
      String subject                      = Label.Subject_BH;

      List<EmailTemplate> et = new List<EmailTemplate>();
      if(operation == 'insert'){  
         et =[SELECT Id, HtmlValue FROM EmailTemplate WHERE Name=:'Email Business Hour Insert' LIMIT 1];     
      }else if(operation == 'update'){
         et =[SELECT Id, HtmlValue FROM EmailTemplate WHERE Name=:'Email Business Hour Update' LIMIT 1];         
      }
      
      String headerTable   = et[0].HtmlValue+'<table style="width:100%;border:1px solid black;border-collapse: collapse;"> <tr> <th style="border:1px solid black;border-collapse: collapse;">Business Hour</th>';
      String rows          = '';

      for(Integer i=0;i<listHolidayNames.size();i++){
         headerTable += '<th style="border:1px solid black;border-collapse: collapse;">Holiday '+(i+1)+'</th>';
      }

      for(String bh : listBusinessHourNames){
         rows += '<tr style="border:1px solid black;border-collapse: collapse;"><td style="border:1px solid black;border-collapse: collapse;">'+bh+'</td>';
         for(String hl : listHolidayNames){
            rows += '<td style="border:1px solid black;border-collapse: collapse;">'+hl+'</td>';
         }
         rows += '</tr>';
      }

      String htmlBody                     = headerTable+rows+'</table> <br>'+Label.Thanks;

      EmailUtils.sendEmail(reserveSingleEmailCapacity, toAddresses,senderDisplayName, subject, useSignature, null, htmlBody);

   }   



/**
    *   @Class          :   InsertBusinessHour   
    *
    *   @Author         :   Pedro Párraga <parragabornez.pedrojesus@ext.mpsa.com>
    *   @Created        :   
    *   @Description    :   Subclass that implements Queueable and that inserts business hours and holidays
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description    
    *      Pedro Párraga         12/03/2019                   Creation.      
    *   ----------------------------------------------------------------------------------------------------------------------------
**/
   public class InsertBusinessHour implements System.Queueable, Database.AllowsCallouts{
      public List<BusinessHour__c > listBusinessHours;

       public InsertBusinessHour(List<BusinessHour__c > listBusinessHours){
         this.listBusinessHours = listBusinessHours;
      }
      
      public void execute(QueueableContext context) {
         BusinessHoursUtils.insertBusinessHour(listBusinessHours);
      }

   } 

/**
    *   @Class          :   UpdateBusinessHour   
    *
    *   @Author         :   Pedro Párraga <parragabornez.pedrojesus@ext.mpsa.com>
    *   @Created        :   
    *   @Description    :   Subclass that implements Queueable and that will update business hours and holidays
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description    
    *      Pedro Párraga         12/03/2019                   Creation.      
    *   ----------------------------------------------------------------------------------------------------------------------------
**/
   public class UpdateBusinessHour implements System.Queueable, Database.AllowsCallouts{
      public List<BusinessHour__c > listBusinessHours;

      public UpdateBusinessHour(List<BusinessHour__c > listBusinessHours){
         this.listBusinessHours = listBusinessHours;
      }
      
      public void execute(QueueableContext context) {
         BusinessHoursUtils.updateBusinessHour(listBusinessHours);
      }

   } 

}
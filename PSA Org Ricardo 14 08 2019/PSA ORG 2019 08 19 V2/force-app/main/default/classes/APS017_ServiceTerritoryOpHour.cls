/**
  *   @Class        : APS017_ServiceTerritoryOpHour
  *
  *   @Author       : Sergio Lopez
  *   @Created      : 19 Sep 2018
  *   @Description  : Schedulable for programming daily the APB017_ServiceTerritoryOpHour
  
  *   ----------------------------------------------------------------------------------------------------------------------------
  *   Modification Log :
  *   ----------------------------------------------------------------------------------------------------------------------------
  *   Developer              Date                 Description  
  *   Sergio Lopez        19/09/2018           Creation.    
  *   ----------------------------------------------------------------------------------------------------------------------------
**/
global class APS017_ServiceTerritoryOpHour implements Schedulable{
  global void execute(SchedulableContext sc) {
      APB017_ServiceTerritoryOpHour b = new APB017_ServiceTerritoryOpHour(); 
      database.executebatch(b);
   }
}
/**
  *   @Class        : APS006_LeadDiscard
  *
  *   @Author       : Ruben Fernandez
  *   @Created      : 20 Mar 2018
  *   @Description  : Schedulable for programming daily the APB006_DiscardLeadsbatch
  
  *   ----------------------------------------------------------------------------------------------------------------------------
  *   Modification Log :
  *   ----------------------------------------------------------------------------------------------------------------------------
  *   Developer              Date                 Description  
  *   Ruben Fernandez        20/03/2018           Creation.    
  *   ----------------------------------------------------------------------------------------------------------------------------
**/
global class APS006_LeadDiscard implements Schedulable{
  global void execute(SchedulableContext sc) {
      APB006_DiscardLeads b = new APB006_DiscardLeads(); 
      database.executebatch(b);
   }
}
/**
  *   @Class        : APS008_QuoteExpired
  *
  *   @Author       : Sergio Lopez
  *   @Created      : 26 Abr 2018
  *   @Description  : Schedulable for programming daily the APB008_QuoteExpired
  
  *   ----------------------------------------------------------------------------------------------------------------------------
  *   Modification Log :
  *   ----------------------------------------------------------------------------------------------------------------------------
  *   Developer              Date                 Description  
  *   Sergio Lopez        26/04/2018              Creation.   
  *   Rubén Moreno			 29/11/2018 		  Scope = 10, in order to sure 10 emails
  *   ----------------------------------------------------------------------------------------------------------------------------
**/
global class APS008_QuoteExpired implements Schedulable{
  global void execute(SchedulableContext sc) {
      APB008_QuoteExpired b = new APB008_QuoteExpired(); 
      database.executebatch(b,10);
   }
}
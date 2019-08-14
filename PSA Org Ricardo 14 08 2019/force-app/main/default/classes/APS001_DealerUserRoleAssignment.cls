/**
	*   @Class : APS001_DealerUserRoleAssignment
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   07 Feb 2018
	*   @Description    :   Schedulable for programming daily the APB001_DealerUserRoleAssignment batch
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Raul Barba				07/2/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
global class APS001_DealerUserRoleAssignment  implements Schedulable{
	global void execute(SchedulableContext sc) {
      APB001_DealerUserRoleAssignment b = new APB001_DealerUserRoleAssignment(); 
      database.executebatch(b);
   }
}
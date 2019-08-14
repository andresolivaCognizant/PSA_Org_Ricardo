/**
	*   @Class : APS003_ManagersPublicGroup
	*
	*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	*   @Created        :   21 Feb 2018
	*   @Description    :   Schedulable for programming daily the APB003_ManagersPublicGroup batch
	
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Raul Barba				21/2/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
public class APS003_ManagersPublicGroup implements Schedulable{
	public void execute(SchedulableContext sc) {
      APB003_ManagersPublicGroup b = new APB003_ManagersPublicGroup(); 
      database.executebatch(b);
   }
    

}
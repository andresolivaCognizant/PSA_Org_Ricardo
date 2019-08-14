/*
*   @Class : EventCecDelete
*
*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
*   @Created        :   13 feb 2018
*   @Description    :   To manage events trigger methods

*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Developer            Date                     Description
*	   Raul Barba			13 feb 2018				 Creation.	
*   ----------------------------------------------------------------------------------------------------------------------------
*/
public with sharing class EventCecDelete {
	
    /*
     * @Method          :   handleonbeforeDelete
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   13 feb 2018
     * @Description     :   Call the actions that handle the before delete trigger.
     * @Params          :   List<Events> records before the changes.
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
	public static void handleonbeforeDelete(List<Event> lEvents) {
        //The profile of the user that eliminates the events is obtained
        Id id1 = UserInfo.getProfileId();
        List<Profile> profiles = [Select Name from Profile where id = :id1 or Name = 'CEC Agent' or Name = 'CEC Supervisor'];
        String profileName;
        Id idAgent;
        Id idSupervisor;
        for(Profile pro : profiles){
            if(pro.id == id1){
                profileName = pro.Name;
            }
            if(pro.Name == 'CEC Agent'){
                idAgent = pro.id;
            }else if(pro.Name == 'CEC Supervisor'){
                idSupervisor = pro.id;
            }
        }
        //The ids of all users of the cec are obtained
        List<Id> cecUsersId= new List<id>();
        for(User u : [Select Id from User where ProfileId = :idAgent or  ProfileId = :idSupervisor]){
            cecUsersId.add(u.Id);
        }
        
        for (event e : lEvents) 
        {	
            if(profileName == 'Salesman' && e.CreatedById != UserInfo.getUserId()){ 
                //A Salesman can not delete an event created by another user
                e.addError('Event Cannot be deleted');
            }else if((profileName == 'CEC Agent' || profileName == 'CEC Supervisor') && !cecUsersId.contains(e.CreatedById)){
                //A CEC user can not delete an event not created by a CEC user
                e.addError('Event Cannot be deleted');
            }
            
        }
	}
}
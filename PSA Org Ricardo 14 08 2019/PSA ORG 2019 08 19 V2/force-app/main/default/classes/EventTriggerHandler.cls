/*
*   @Class : EventTriggerHandler
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
public class EventTriggerHandler {
    
    private static boolean runtrigger = true;
    
    
    /*
     * @Method          :   shouldRunTrigger
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
     * @Created         :   13 feb 2018
     * @Description     :   To get the flag that indicate if the trigger should run or not
     * @Params          :   -
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
    public	static	boolean	shouldRunTrigger() {
        return runtrigger;
    }
    
    
    /*
     * @Method          :   dontRunTrigger
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
     * @Created         :   13 feb 2018
     * @Description     :   To indicate that the trigger should not run
     * @Params          :   -
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */		
    public	static	void	dontRunTrigger() {
        runtrigger = false;
    }

    /*
     * @Method          :   beforeInsert
     * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
     * @Created         :   13 feb 2018
     * @Description     :   Call the actions that handle the before delete trigger.
     * @Params          :   List<Events> records before the changes.
     * @Returns         :   -
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */
    public static void beforeDelete(List<Event> lEvents) {
        EventCecDelete.handleonbeforeDelete(lEvents);
    }

    public static void beforeInsert(List<Event> lst_new_rows) {
        EventUtil.setActivityType(lst_new_rows);
    }

    public static void beforeUpdate(
        List<Event> lst_old_rows, Map<Id, Event> map_old_rows,
        List<Event> lst_new_rows, Map<Id, Event> map_new_rows
    ) {
        EventUtil.setActivityType(lst_new_rows);
    }

}
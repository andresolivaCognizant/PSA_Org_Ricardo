/**
*   @Class          :   APS021_UpdateRelationship
*   @Author         :   Nerea Leguinazabal
*   @Created        :   3/07/2019
*   @Description    :   Scheduler for APB021_UpdateAssetAccountRelationship for Asset object
*
*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Author             Date             Description
*      Nerea Leguinazabal 3/07/2019       Creation.
*   ----------------------------------------------------------------------------------------------------------------------------
**/ 

public class APS021_UpdateRelationshipAsset implements Schedulable {

    //public static String CRON_EXP = '0 0 0 * * ?';
    public static String obj = 'Asset';

    public void execute(SchedulableContext sc) {
        
        APB021_UpdateAssetAccountRelationship b = new APB021_UpdateAssetAccountRelationship(obj);
        Database.executeBatch(b);
          
    }

}
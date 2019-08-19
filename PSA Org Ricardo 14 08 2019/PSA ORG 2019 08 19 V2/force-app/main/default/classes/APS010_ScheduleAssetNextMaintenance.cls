public class APS010_ScheduleAssetNextMaintenance implements Schedulable {
    
    public void execute(SchedulableContext sc) {
        APB009_ExpiredAssetNextMaintenance bch = new APB009_ExpiredAssetNextMaintenance();
        Database.executeBatch(bch, 200);
    }

}
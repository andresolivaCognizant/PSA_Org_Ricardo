public without sharing class InsertAsyncQueueable implements Queueable {
    
    private List<sObject> sObjectsInsert;
    private List<sObject> sObjectsDelete;
    
    public InsertAsyncQueueable(List<sObject> sObjectsInsert,List<sObject> sObjectsDelete) {
        this.sObjectsInsert = sObjectsInsert;
        this.sObjectsDelete = sObjectsDelete;

    }
    

    public void execute(QueueableContext context) {
        
        try{

            Database.insert(sObjectsInsert,false);
            Database.delete(sObjectsDelete,true);
			System.debug('sObjectsInsert: '+sObjectsInsert);
            
        }catch(DMLexception e) {
            System.debug('InsertAsyncQueueable.execute ERROR -->' + e.getMessage() + ' Line: '+e.getLineNumber());
        } catch (Exception e){
            System.debug('InsertAsyncQueueable.execute ERROR --> ' + e.getMessage() + ' Line: '+e.getLineNumber());
        }
        
        
    }
    
}
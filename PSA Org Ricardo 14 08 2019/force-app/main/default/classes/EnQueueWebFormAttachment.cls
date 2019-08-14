public class EnQueueWebFormAttachment  implements Queueable , Database.AllowsCallouts{
  private List<Attachment> lstAtt;
    
    public EnQueueWebFormAttachment(List<Attachment> lstAtt){
        if(lstAtt!=null && !lstAtt.isEmpty()){
            this.lstAtt = lstAtt;
        }  
    }
    //Execute list content one by one.
    public void execute(QueueableContext context) {
        if(this.lstAtt!=null && !this.lstAtt.isEmpty()){
            System.debug('-------------------------------------->Entro en el QUEUE');
            insert this.lstAtt;
        }
    }
  
}
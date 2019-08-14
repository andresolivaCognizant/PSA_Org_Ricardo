/*-----------------------------------------------------------------------------------------------------------//
  * Class Name    : EnqueueAssetsToUpdate
  * Project       : PSA - C1ST
  * Author        : Borja Gay Flores    <gayflores.borja@ext.mpsa.com>
  * Date          : XX/XX/2018 
  * Description   : Description .....
  *
  * @Private
  *               1.
  * @Public
  *               1. EnqueueAssetsToUpdate. Returns a class object to be enqueue.
  *               2. execute.               Stars a new Queueable process.
  *-----------------------------------------------------------------------------------------------------------
  *      Modification Log :
  *-----------------------------------------------------------------------------------------------------------
  *      Developer                Date                     Description    
  *      Borja Gay Flores         XX/XX/2019               Creation.      
  *-----------------------------------------------------------------------------------------------------------*/
public class EnqueueAssetsToUpdate  implements Queueable , Database.AllowsCallouts{
  private List<Asset> lstAsset;
  //avoid System.CalloutException: You have uncommitted work pending. Please commit or rollback before calling out in test class 
  // more info https://salesforce.stackexchange.com/questions/203070/uncommitted-work-pending-in-unit-test-with-trigger-and-queueable-callout/203078
  @TestVisible static Boolean makeCallout = true;
	
	/*********************************************************************************************************
    * @Method          :   EnqueueAssetsToUpdate
    * @Author          :   Borja Gay Flores <gayflores.borja@ext.mpsa.com>
    * @Created         :   XX/XX/XX
    * @Description     :   This method is used to ..
    * @params	       :   List<Asset> : lstAsset
    * @Returns         :   
    **********************************************************************************************************/
	public EnqueueAssetsToUpdate(List<Asset> lstAsset){
		if(lstAsset!=null && !lstAsset.isEmpty()){
			this.lstAsset = lstAsset;
		}  
	}

	/*********************************************************************************************************
    * @Method          :   execute
    * @Author          :   Borja Gay Flores <gayflores.borja@ext.mpsa.com>
    * @Created         :   XX/XX/XX
    * @Description     :   This method is used to ..
    * @params	       :   QueueableContext : context
    * @Returns         :   
    **********************************************************************************************************/
	public void execute(QueueableContext context) {
		if(this.lstAsset!=null && !this.lstAsset.isEmpty()){
			for(Asset a : this.lstAsset){
                if (makeCallout) performCallout(a);
				
			}
			update this.lstAsset;
		}
	}
    
    public static void performCallout(Asset a){
        RestInt91.Int91Response resp = RestInt91.sendRequest(a.VIN__c, a.Language__c.toLowerCase(), a.Country__c, a.Brand__c, 120000);
        if(resp.result == 200){
            a.LCDV16__c = resp.lcdv16;
            a.LCDV9__c = resp.lcdv9;
            a.FamilyDescription__c = resp.familyDescription;
            a.AssetDestinationUsage__c = resp.genreDeProduitLabel;
            a.Brand__c = resp.marqueCommercialLabel;
            a.Model__c = resp.ligneDeProduitLabel;
            a.ShapeCode__c = resp.silhouetteCode;
            a.ShapeDescription__c  = resp.silhouetteLabel;
            a.FinishingCode__c = resp.finitionCode;
            a.FinishingDescription__c = resp.finitionLabel;
            a.EngineCode__c = resp.moteurCode;
            a.EngineDescription__c = resp.moteurLabel;
            a.GearboxCode__c = resp.boiteDeVitesseCode;
            a.GearboxDescription__c = resp.boiteDeVitesseLabel;
        }
    }
  
}
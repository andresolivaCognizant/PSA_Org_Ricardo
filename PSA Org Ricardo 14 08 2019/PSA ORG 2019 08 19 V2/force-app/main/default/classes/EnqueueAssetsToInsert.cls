/*-----------------------------------------------------------------------------------------------------------//
  * Class Name    : EnqueueAssetsToInsert
  * Project       : PSA - C1ST
  * Author        : Carmen Hernandez    <carmen.diazhernandez@ext.mpsa.com>
  * Date          : 05/23/2019
  * Description   : This class creates asset when the VIN is valid and calls the INT91 interface to validate VIN
  *
  *-----------------------------------------------------------------------------------------------------------
  *      Modification Log :
  *-----------------------------------------------------------------------------------------------------------
  *      Developer                Date                     Description    
  *      Carmen Hernandez         05/23/2019               Creation.      
  *-----------------------------------------------------------------------------------------------------------*/
public class EnqueueAssetsToInsert implements Queueable , Database.AllowsCallouts{
    
    private final static Id RT_ASSET_PSA_VEHICLE    = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('PSAVehicle').getRecordTypeId();
    
    private List<Case> lstCase;
    @TestVisible static Boolean makeCallout = true;      

    /*********************************************************************************************************
    * @Method          :   EnqueueAssetsToInsert
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   05/23/2019
    * @Description     :   Constructor EnqueueAssetsToInsert
    * @params	       :   List<Case> lstCase: new Cases without Asset
    * @Returns         :   void
    **********************************************************************************************************/        
	public EnqueueAssetsToInsert(List<Case> lstCase){
		if(lstCase!=null && !lstCase.isEmpty()){
			this.lstCase = lstCase;
		}  
	}    

    /*********************************************************************************************************
    * @Method          :   execute
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   05/23/2019
    * @Description     :   This method is used to create assets (when VIN is valid) and update cases 
    * @params	       :   QueableContext context
    * @Returns         :   void
    **********************************************************************************************************/          
	public void execute(QueueableContext context) {
        Set<String> setValidVINs = new Set<String>();
        Map<String, String> mapValidVINsCases = new Map<String, String>();
		if(this.lstCase!=null && !this.lstCase.isEmpty()){
            
            List<Asset> lstAssetsToCreate = new List<Asset>();
			for(Case caseIt : this.lstCase){
                
                if (makeCallout) {
                    Asset newAsset = performCallout(caseIt);
                    if(newAsset != null){
                        lstAssetsToCreate.add(newAsset);
                        setValidVINs.add(newAsset.VIN__c);
                        mapValidVINsCases.put(caseIt.VIN__c, caseIt.Id);
                    }
                }
			}            
            
            //Insert new Assets & Match Case-Account
            if(!lstAssetsToCreate.isEmpty()){
                //Insert new Assets
                insert lstAssetsToCreate;
                
                //Query Cases To Update Relation Case-Asset
                Map <String, Case> mapCurrentCases = new Map<String, Case>();
                for(Case caseIt: [SELECT Id, VIN__c FROM Case WHERE Id IN: mapValidVINsCases.values()]) {
                    mapCurrentCases.put(caseIt.VIN__c, caseIt);
                }
                
                //Update Cases -> Match Case-Account  
                List<Case> lstCasesToUpdate = new List<Case>();              
                for(Asset assetIt: lstAssetsToCreate){
                    Case caseTmp = mapCurrentCases.get(assetIt.VIN__c);
                    caseTmp.AssetId = assetIt.Id;
                    lstCasesToUpdate.add(caseTmp);
                }
                if(!lstCasesToUpdate.isEmpty()){
                    update lstCasesToUpdate;
                }
            }
		}
	}    

    /*********************************************************************************************************
    * @Method          :   performCallout
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   05/23/2019
    * @Description     :   This method is used to call Int91 and validate the VIN
    * @params	       :   Case caseTmp
    * @Returns         :   Asset
    **********************************************************************************************************/       
    public static Asset performCallout(Case caseTmp){
        RestInt91.Int91Response response = RestInt91.sendRequest(caseTmp.VIN__c, caseTmp.Language__c.toLowerCase(), 
                                                                 caseTmp.Country__c, caseTmp.Brand__c, 120000);
        Asset newAsset = new Asset();
        if(response.result == 200){
            newAsset.RecordtypeId = RT_ASSET_PSA_VEHICLE;
            newAsset.AssetType__c = 'VN';             
            //Fields that depend on the Case
            newAsset.Name = caseTmp.VIN__c;
            newAsset.VIN__c = caseTmp.VIN__c;
            newAsset.LastKnownRegistrationNumber__c = caseTmp.RegistrationNumber__c;
            newAsset.AccountId = caseTmp.AccountId;
            newAsset.Brand__c  = caseTmp.Brand__c;
            newAsset.Country__c  = caseTmp.Country__c;
            newAsset.Language__c = caseTmp.Language__c; 
            //Fields that depend on the response INT91
            newAsset.LCDV16__c = response.lcdv16;
            newAsset.LCDV9__c = response.lcdv9;
            newAsset.FamilyDescription__c = response.familyDescription;
            newAsset.AssetDestinationUsage__c = response.genreDeProduitLabel;
            newAsset.Brand__c = response.marqueCommercialLabel;
            newAsset.Model__c = response.ligneDeProduitLabel;
            newAsset.ShapeCode__c = response.silhouetteCode;
            newAsset.ShapeDescription__c  = response.silhouetteLabel;
            newAsset.FinishingCode__c = response.finitionCode;
            newAsset.FinishingDescription__c = response.finitionLabel;
            newAsset.EngineCode__c = response.moteurCode;
            newAsset.EngineDescription__c = response.moteurLabel;
            newAsset.GearboxCode__c = response.boiteDeVitesseCode;
            newAsset.GearboxDescription__c = response.boiteDeVitesseLabel;  
        }
        else{
            newAsset = null;
        }
        return newAsset;
    }    
}
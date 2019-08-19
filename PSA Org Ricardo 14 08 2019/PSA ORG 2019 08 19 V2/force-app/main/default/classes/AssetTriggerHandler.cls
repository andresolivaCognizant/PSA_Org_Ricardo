/*-----------------------------------------------------------------------------------------------------------//
  * Class Name    : AssetTriggerHandler
  * Project       : PSA - C1ST
  * Author        : Ruben Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
  * Date          : 04/11/2018
  * Description   : To manage Asset trigger methods
  *
  *-----------------------------------------------------------------------------------------------------------
  *      Modification Log :
  *-----------------------------------------------------------------------------------------------------------
  *      Developer                Date                     Description    
  *	     Ruben Moreno		     11 Apr 2018			   Creation.		  
  *-----------------------------------------------------------------------------------------------------------*/
public class AssetTriggerHandler {
	
    //Attributes
	private static Boolean runtrigger 			= true;
    public static Set <Id> processedRecords 	= new Set<Id>();
    

    /*********************************************************************************************************
    * @Method          :   shouldRunTrigger
    * @Author          :   Ruben Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
    * @Created         :   04/11/2018
    * @Description     :   This method is used to get the flag that indicate if the trigger should run or not
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/
	public static boolean shouldRunTrigger() {
		return runtrigger;
	}

    /*********************************************************************************************************
    * @Method          :   dontRunTrigger
    * @Author          :   Ruben Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
    * @Created         :   04/11/2018
    * @Description     :   This method is used to indicate that the trigger should not run
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/
	public static void dontRunTrigger() {
		runtrigger = false;
	}

    /*********************************************************************************************************
    * @Method          :   beforeInsert
    * @Author          :   Ruben Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
    * @Created         :   04/11/2018
    * @Description     :   This method is used to call the actions that handle the before insert trigger.
    * @params	       :   List<Asset> : Trigger.new
    * @Returns         :   void
    **********************************************************************************************************/
	public static void beforeInsert( List<Asset> lstNewRows ) {
		AssetUtils.setDefaultMaintenancePlan(lstNewRows);
		AssetUtils.transformFields( lstNewRows );
	}

    /*********************************************************************************************************
    * @Method          :   afterInsert
    * @Author          :   Ruben Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
    * @Created         :   04/11/2018
    * @Description     :   This method is used to call the actions that handle the after insert trigger.
    * @params	       :   Map<Id, Asset> : Trigger.newMap
    * @Returns         :   void
    **********************************************************************************************************/
	public static void afterInsert(Map<Id, Asset> mapNewRows) {
		
        //Control Recursion
		if( processedRecords.containsAll(mapNewRows.keySet()) ){
			return;
		}
        if(PAD.canTrigger('AllObjects_All_Interfaces')){
            AssetUtils.createAssetAccountRelation(mapNewRows.values());
        }
        if( !System.isQueueable() && !System.isBatch()){
            AssetUtils.callingWebhook(null,mapNewRows);
            AssetUtils.PredictiveMileageAsync j  = new AssetUtils.PredictiveMileageAsync(mapNewRows.keySet());
            Id jobID = System.enqueueJob(j); 
        }            
        
        //Add record to control the recursion
		processedRecords.addAll(mapNewRows.keySet());
	}


    /*********************************************************************************************************
    * @Method          :   beforeUpdate
    * @Author          :   Ruben Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
    * @Created         :   04/11/2018
    * @Description     :   This method is used to call the actions that handle the before update trigger.
    * @params	       :   List<Asset> : Trigger.new 
    * @params          :   Map<Id,Asset> : Trigger.oldMap
    * @Returns         :   void
    **********************************************************************************************************/
	public static void beforeUpdate( List<Asset> lstAssets, Map<Id, Asset> mapOldAssetById ){

        //Control Recursion
		if(processedRecords.containsAll(mapOldAssetById.keySet())){
			return;
		}        
        AssetUtils.validateAccountId( lstAssets, mapOldAssetById );
        AssetUtils.transformFields( lstAssets, mapOldAssetById );
	}


    /*********************************************************************************************************
    * @Method          :   afterUpdate
    * @Author          :   Ruben Moreno Leyva <ruben.morenoleyva@ext.mpsa.com>
    * @Created         :   04/11/2018
    * @Description     :   This method is used to call the actions that handle the after update trigger.
    * @params	       :   Map<Id,Asset> : Trigger.newMap 
    * @params          :   Map<Id,Asset> : Trigger.oldMap
    * @Returns         :   void
    **********************************************************************************************************/
	public static void afterUpdate(Map<Id, Asset> mapOldRows, Map<Id, Asset> mapNewRows) {
        
        //Control Recursion
		if(processedRecords.containsAll(mapNewRows.keySet())){
			return;
		}
        AssetUtils.dispatchNextMaintenanceCalc(mapOldRows, mapNewRows);
        AssetUtils.callingWebhook(mapOldRows,mapNewRows);
        AssetUtils.changeVINAndLastKnownRegistrationNumber(mapNewRows, mapOldRows);			
        
        //Add record to control the recursion
        processedRecords.addAll(mapNewRows.keySet());		
		
	}
}
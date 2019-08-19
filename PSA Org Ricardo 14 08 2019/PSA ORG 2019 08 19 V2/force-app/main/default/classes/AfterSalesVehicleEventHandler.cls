/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			AfterSales
* Description:		Handler class to apply logic over Vehicle Event when a record is created.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------

* @version	1.0		2018-08-03		Manuel Medina (MM)		Initial definition.
*********************************************************************************************************/
public class AfterSalesVehicleEventHandler {
	
	/**
	* @Method: 		validateVehicleEventRules
	* @param: 		Map<String, VehicleEvent__x> mapVehicleEventById
	* @Description:	Validates a given list of vehicle event records to determines if the asset related have to be updated.
	* @author 		Manuel Medina - 03082018
	*/
	public static void validateVehicleEventRules( Map<String, VehicleEvent__x> mapVehicleEventById ){
		Map<String, APVVehicleEventRules__mdt> mapVehicleEventRuleByValidationResult			= new Map<String, APVVehicleEventRules__mdt>( getAPVehicleEventRules() );
		Map<String, Asset> mapAssetById															= new Map<String, Asset>();
		mapVehicleEventById																		= new Map<String, VehicleEvent__x>( getVehicleEventDetails( mapVehicleEventById ) );
		Map<Id, Asset> mapAssetsToUpdateById													= new Map<Id, Asset>();
		
		for( VehicleEvent__x objVehicleEvent : mapVehicleEventById.values() ){
			mapAssetById.put( objVehicleEvent.assetid__c, null );
		}
		
		mapAssetById																			= new Map<String, Asset>( [
																									SELECT Id,
																										LastAPVVisitMileage__c,
																										LastAPVVisitDate__c,
																										LastAPVVisitMileageSource__c,
																										RealMileage__c,
																										RealMileageDate__c,
																										RealMileageSource__c,
																										LastMaintenanceMileage__c,
																										LastMaintenanceDate__c
																									FROM Asset
																									WHERE Id IN: mapAssetById.keySet()
																								] );
																								
		for( VehicleEvent__x objVehicleEvent : mapVehicleEventById.values() ){
			Asset objRelatedAsset																= new Asset();
			objRelatedAsset																		= mapAssetById.get( objVehicleEvent.assetid__c );
			
			String strRealDateValidation														= getFieldValidation( objVehicleEvent.realmileagedate__c, objRelatedAsset.RealMileageDate__c, 'DATE' );
			String strRealMileageValidation														= getFieldValidation( objVehicleEvent.realmileage__c, objRelatedAsset.RealMileage__c, 'MILEAGE' );
			
			String strAPVDateValidation															= getFieldValidation( objVehicleEvent.realmileagedate__c, objRelatedAsset.LastAPVVisitDate__c, 'DATE' );
			String strAPVMileageValidation														= getFieldValidation( objVehicleEvent.realmileage__c, objRelatedAsset.LastAPVVisitMileage__c, 'MILEAGE' );
			
			String strMaintenanceDateValidation													= getFieldValidation( objVehicleEvent.realmileagedate__c, objRelatedAsset.LastMaintenanceDate__c, 'DATE' );
			String strMaintenanceMileageValidation												= getFieldValidation( objVehicleEvent.realmileage__c, objRelatedAsset.LastMaintenanceMileage__c, 'MILEAGE' );
			
			String strRealValidation															= objRelatedAsset.RealMileageSource__c + objVehicleEvent.realmileagesource__c + strRealDateValidation + strRealMileageValidation;
			String strAPVValidation																= objRelatedAsset.LastAPVVisitMileageSource__c + objVehicleEvent.realmileagesource__c + strAPVDateValidation + strAPVMileageValidation;
			String strMaintenanceValidation														= 'APV' + objVehicleEvent.realmileagesource__c + strMaintenanceDateValidation + strMaintenanceMileageValidation;
			
			if( mapVehicleEventRuleByValidationResult.containsKey( strRealValidation ) ){
				objRelatedAsset.RealMileage__c													= objVehicleEvent.realmileage__c;
				objRelatedAsset.RealMileageDate__c												= objVehicleEvent.realmileagedate__c;
				objRelatedAsset.RealMileageSource__c											= objVehicleEvent.realmileagesource__c;
				
				mapAssetsToUpdateById.put( objRelatedAsset.Id, objRelatedAsset );
			}
			
			if( ( objVehicleEvent.bvvfileid__c != null && !objVehicleEvent.bvvfileid__r.MaintenanceStep__c ) || ( objVehicleEvent.bvvfileid__c == null ) && mapVehicleEventRuleByValidationResult.containsKey( strAPVValidation ) ){
				objRelatedAsset.LastAPVVisitMileage__c											= objVehicleEvent.realmileage__c;
				objRelatedAsset.LastAPVVisitDate__c												= objVehicleEvent.realmileagedate__c;
				objRelatedAsset.LastAPVVisitMileageSource__c									= objVehicleEvent.realmileagesource__c;
				
				mapAssetsToUpdateById.put( objRelatedAsset.Id, objRelatedAsset );
			}
			
			if( objVehicleEvent.bvvfileid__c != null && objVehicleEvent.bvvfileid__r.MaintenanceStep__c && mapVehicleEventRuleByValidationResult.containsKey( strMaintenanceValidation ) ){
				objRelatedAsset.LastMaintenanceMileage__c										= objVehicleEvent.realmileage__c;
				objRelatedAsset.LastMaintenanceDate__c											= objVehicleEvent.realmileagedate__c;
				
				mapAssetsToUpdateById.put( objRelatedAsset.Id, objRelatedAsset );
			}
			
			if( String.isBlank( objRelatedAsset.RealMileageSource__c ) ){
				objRelatedAsset.RealMileage__c													= objVehicleEvent.realmileage__c;
				objRelatedAsset.RealMileageDate__c												= objVehicleEvent.realmileagedate__c;
				objRelatedAsset.RealMileageSource__c											= objVehicleEvent.realmileagesource__c;
				
				mapAssetsToUpdateById.put( objRelatedAsset.Id, objRelatedAsset );
			}
		}
		
		update mapAssetsToUpdateById.values();
	}
	
	/**
	* @Method: 		getFieldValidation
	* @param: 		Object objSoruceField
	* @param: 		Object objTargetField
	* @param: 		String strValidationType
	* @Description:	Gets additional information for each VehicleEvent created.
	* @author 		Manuel Medina - 06082018
	*/
	public static String getFieldValidation( Object objSoruceField, Object objTargetField, String strValidationType ){
		Date dtSourceField																		= null;
		Date dtTargetField																		= null;
		
		Double dbSourceField																	= 0;
		Double dbTargetField																	= 0;
		
		if( objSoruceField == null || objTargetField == null ){
			return 'NN';
		}
		
		switch on strValidationType {
			when 'DATE' {
				dtSourceField																	= Date.valueOf( objSoruceField );
				dtTargetField																	= Date.valueOf( objTargetField );
				
				if( dtSourceField > dtTargetField ){
					return 'GT';
					
				}else if( dtSourceField < dtTargetField ){
					return 'LT';
					
				}else if( dtSourceField == dtTargetField ){
					return 'EQ';
				}
			}
			
			when 'MILEAGE' {
				dbSourceField																	= Double.valueOf( objSoruceField );
				dbTargetField																	= Double.valueOf( objTargetField );
				
				if( dbSourceField > dbTargetField ){
					return 'GT';
					
				}else if( dbSourceField < dbTargetField ){
					return 'LT';
					
				}else if( dbSourceField == dbTargetField ){
					return 'EQ';
				}
			}
			
		}
        
        return '';
	}
	
	/**
	* @Method: 		validateVehicleEventRules
	* @param: 		N/A
	* @Description:	Gets additional information for each VehicleEvent created.
	* @author 		Manuel Medina - 06082018
	*/
	public static Map<String, VehicleEvent__x> getVehicleEventDetails( Map<String, VehicleEvent__x> mapVehicleEventById ){
		Map<String, VehicleEvent__x> m															= new Map<String, VehicleEvent__x>( [
																									SELECT Id,
																										assetid__c,
																										bvvfileid__c,
																										bvvfileid__r.MaintenanceStep__c,
																										realmileage__c,
																										realmileagedate__c,
																										realmileagesource__c
																									FROM VehicleEvent__x
																									WHERE Id IN: mapVehicleEventById.keySet()
																								] );
																								
		return Test.isRunningTest() ? mapVehicleEventById : m;
	}
	
	/**
	* @Method: 		validateVehicleEventRules
	* @param: 		N/A
	* @Description:	Gets APV vehicle event rules setup on APVVehicleEventRules__mdt custom metadata type
	* @author 		Manuel Medina - 06082018
	*/
	public static Map<String, APVVehicleEventRules__mdt> getAPVehicleEventRules(){
		Map<String, APVVehicleEventRules__mdt> mapVehicleEventRuleByValidationResult			= new Map<String, APVVehicleEventRules__mdt>();
		List<APVVehicleEventRules__mdt> lstMDTVehicleEventRules									= new List<APVVehicleEventRules__mdt>( [
																									SELECT Id,
																										AssetSource__c,
																										VehicleEventMileageSource__c,
																										VehicleEventMileageDate__c,
																										VehicleEventMileage__c
																									FROM APVVehicleEventRules__mdt
																								] );
																								
		for( APVVehicleEventRules__mdt mdtRule : lstMDTVehicleEventRules ){
			mapVehicleEventRuleByValidationResult.put( mdtRule.AssetSource__c + mdtRule.VehicleEventMileageSource__c + mdtRule.VehicleEventMileageDate__c + mdtRule.VehicleEventMileage__c, mdtRule );
		}
		
		return mapVehicleEventRuleByValidationResult;
	}
}
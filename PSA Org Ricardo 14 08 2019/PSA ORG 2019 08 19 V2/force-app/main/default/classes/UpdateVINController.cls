public with sharing class UpdateVINController {
	public class Int91Result {
		public string result;
		public string assetId;
	}
	public class VINFields{
		public string vinId;
		public string accId;
		public string vin;
		public string lang;
		public string country;
		public string brand;
	}
	@AuraEnabled
	public static String getVINInfo(string vinId, string vin, string lang, string country, string brand, string accId) {
		Int91Result resu = new Int91Result();
		RestInt91.Int91Response resp = RestInt91.sendRequest(vin, lang.toLowerCase(), country, brand, 5000);
		if (resp.result == 200) {
			List<Asset> lstVIN = new List<Asset>();
			lstVIN = [SELECT id from Asset where VIN__c =:vin];
			/*Do Field Mapping */
			if (!lstVIN.isEmpty()) {
				lstVIN[0].LCDV16__c = resp.lcdv16;
				lstVIN[0].LCDV9__c = resp.lcdv9;
				lstVIN[0].FamilyDescription__c = resp.familyDescription;
				lstVIN[0].AssetDestinationUsage__c = resp.genreDeProduitLabel;
				lstVIN[0].Brand__c = resp.marqueCommercialLabel;
				lstVIN[0].Model__c = resp.ligneDeProduitLabel;
				lstVIN[0].ShapeCode__c = resp.silhouetteCode;
				lstVIN[0].ShapeDescription__c  = resp.silhouetteLabel;
				lstVIN[0].FinishingCode__c = resp.finitionCode;
				lstVIN[0].FinishingDescription__c = resp.finitionLabel;
				lstVIN[0].EngineCode__c = resp.moteurCode;
				lstVIN[0].EngineDescription__c = resp.moteurLabel;
				lstVIN[0].GearboxCode__c = resp.boiteDeVitesseCode;
				lstVIN[0].GearboxDescription__c = resp.boiteDeVitesseLabel;

				update lstVIN;
				resu.result = '' + resp.result;
				if(vinId == lstVIN[0].id){
					resu.assetId = vinId;
				}
				else{
					resu.assetId = lstVIN[0].id;
				}
			}
			else{
				Asset newAsset = new Asset();
				Id psaRT = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('PSAVehicle').getRecordTypeId();
				newAsset.LCDV16__c = resp.lcdv16;
				newAsset.LCDV9__c = resp.lcdv9;
				newAsset.FamilyDescription__c = resp.familyDescription;
				newAsset.AssetDestinationUsage__c = resp.genreDeProduitLabel;
				newAsset.AssetType__c = 'VN';
				newAsset.Brand__c = resp.marqueCommercialLabel;
				newAsset.Model__c = resp.ligneDeProduitLabel;
				newAsset.ShapeCode__c = resp.silhouetteCode;
				newAsset.ShapeDescription__c  = resp.silhouetteLabel;
				newAsset.FinishingCode__c = resp.finitionCode;
				newAsset.FinishingDescription__c = resp.finitionLabel;
				newAsset.EngineCode__c = resp.moteurCode;
				newAsset.EngineDescription__c = resp.moteurLabel;
				newAsset.GearboxCode__c = resp.boiteDeVitesseCode;
				newAsset.GearboxDescription__c = resp.boiteDeVitesseLabel;
				newAsset.VIN__c = vin;
				newAsset.AccountId = accId;
				newAsset.Name = vin;
				upsert newAsset;

				resu.result = '' + resp.result;
				resu.assetId = newAsset.id;
			}
		}
		else{
			resu.result = '' + resp.result;
			resu.assetId = resp.message;

		}
		String resuString = JSON.serialize(resu);
		return resuString;
	}

	@AuraEnabled
	public static void updateVIN(string caseId,string vinId){
		Case cas = new Case();
		cas.id = caseId;
		cas.AssetId = vinId;
		update cas;

	}

	@AuraEnabled
	public static String getInfoCase(string caseId){
		List<Case> lstCase = new List<Case>();
		VINFields wrp = new VINFields();
		lstCase = [SELECT id,AccountId,Language__c,Brand__c,VIN__c,AssetId,Country__c from Case where id = :caseId];
		if(!lstCase.isEmpty()){	
			System.debug(lstCase);
			wrp.vinId = lstCase[0].AssetId;
			wrp.accId = lstCase[0].AccountId;
			wrp.vin = lstCase[0].VIN__c;
			wrp.brand = lstCase[0].Brand__c;
			wrp.lang = lstCase[0].Language__c;
			wrp.country = lstCase[0].Country__c;
		}

		return JSON.serialize(wrp);
	}
	@AuraEnabled
	public static Boolean getCaseVIN(string caseId){
		Boolean result = false;
		List<Case> lstCase = [SELECT id,VIN__c from Case where id = : caseId];
	  	if(!lstCase.isEmpty()){
			  if(lstCase[0].VIN__c != null && lstCase[0].VIN__c != ''){
				  result = true;
			  }
		  }
		return result;
	}
}
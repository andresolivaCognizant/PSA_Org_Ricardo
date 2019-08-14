/*-----------------------------------------------------------------------------------------------------------//
 * Class Name : APB021_UpdateRelationshipTest
 * Project : PSA - C1ST
 * Author : Nerea Leguinazabal
 * Date : 24/06/2019
 * Description : Test class for APB021_UpdateRelationship
 *-----------------------------------------------------------------------------------------------------------*/
@istest
private class APB021_UpdateRelationshipTest {
	
	@testSetup static void setup() {
		//Create Accounts
		List<Account> accLst = new List<Account>();
		String recordTypeId = PAD.getRecordTypeIdByDeveloperName('Account','Account_B2B');

		for (Integer i=0;i<200;i++) {
			Account acc = new Account(
				Name                =   'TESTB2B_'+i,
				FiscalId__c         =   '30.686.957-'+i,
				RecordTypeId      	=   recordTypeId
			);
			accLst.add(acc);
			
		}
		insert accLst;
	
		//Create Assets
		TestDataFactoryUtil.createAssetBulk(200,accLst.get(0));
		
	}
				
	

	@isTest(SeeAllData=false)
	static void updateAssetAccountRelationshipTestAccount() {
		
		List<Account> accLst = [SELECT id,Description FROM Account LIMIT 200];
		
		for (Account acc : accLst) {
			acc.Description =  'Account is updated';
		}
		
		//Update created Accounts with new names
		update accLst;

		Test.startTest();
			APB021_UpdateAssetAccountRelationship b = new APB021_UpdateAssetAccountRelationship('Account'); 
			Database.executeBatch(b); 
		Test.stopTest();

		//Retrieve AccountContactAssetRelation__c
		List<AccountContactAssetRelation__c> relationLst = [SELECT 	AssetId__r.Name,
																	AssetId__r.LastKnownRegistrationNumber__c,
																	AccountId__r.TECH_FiscalId__c,
																	AccountId__r.LandlinePersonalTelephone__pc,
																	AccountId__r.PersonEmail,
																	AssetId__r.VIN__c,
																	AccountId__r.Name,
																	AccountId__r.BillingPostalCode,
																	TECH_AssetVIN__c,
																	TECH_AssetModel__c,
																	TECH_AssetLastKnownRegistrationNumber__c,
																	TECH_AccountName__c,
																	TECH_AccountFiscalID__c,
																	TECH_AccountPhone__c,
																	TECH_AccountEmail__c,
																	TECH_AccountBillingPostalCode__c,
																	AssetId__r.Model__c,
																	AccountId__r.LandlineProfessionalTelephone__pc,
																	AccountId__r.MobilePersonalTelephone__pc,
																	AccountId__r.MobileProfessionalTelephone__pc,
																	AccountId__r.Phone,
																	AccountId__r.TECH_NationalId__c 	
																	FROM AccountContactAssetRelation__c WHERE AccountId__c IN :accLst];
																	
		for (AccountContactAssetRelation__c acRelation: relationLst) {
				//Assert
				System.assertEquals(acRelation.AssetId__r.VIN__c,acRelation.TECH_AssetVIN__c);
				System.assertEquals(acRelation.AssetId__r.Name + ' ' + acRelation.AssetId__r.Model__c,acRelation.TECH_AssetModel__c);
				System.assertEquals(acRelation.AssetId__r.LastKnownRegistrationNumber__c,acRelation.TECH_AssetLastKnownRegistrationNumber__c);
				System.assertEquals(acRelation.AccountId__r.Name,acRelation.TECH_AccountName__c);
				System.assertEquals(acRelation.AccountId__r.TECH_FiscalId__c+ ' ' + acRelation.AccountId__r.TECH_NationalId__c,acRelation.TECH_AccountFiscalID__c );
				System.assertEquals(acRelation.AccountId__r.PersonEmail,acRelation.TECH_AccountEmail__c);
				System.assertEquals(acRelation.AccountId__r.BillingPostalCode,acRelation.TECH_AccountBillingPostalCode__c);
				
		}
			
		
	}

	@isTest(SeeAllData=false)
	static void updateAssetAccountRelationshipTestAsset() {
		List<Asset> assLst = [SELECT id,Description FROM Asset];
		
				
		for (Asset ass : assLst) {
				ass.Description =  'Asset is updated';
		}
		//Update created Accounts with new names
		update assLst;
	
		Test.startTest();
				APB021_UpdateAssetAccountRelationship b = new APB021_UpdateAssetAccountRelationship('Asset'); 
				Database.executeBatch(b,150); 
		Test.stopTest();

		//Retrieve AccountContactAssetRelation__c
		List<AccountContactAssetRelation__c> relationLst = [SELECT  AssetId__r.Name,
																	AssetId__r.LastKnownRegistrationNumber__c,
																	AccountId__r.TECH_FiscalId__c,
																	AccountId__r.LandlinePersonalTelephone__pc,
																	AccountId__r.PersonEmail,
																	AssetId__r.VIN__c,
																	AccountId__r.Name,
																	AccountId__r.BillingPostalCode,
																	TECH_AssetVIN__c,
																	TECH_AssetModel__c,
																	TECH_AssetLastKnownRegistrationNumber__c,
																	TECH_AccountName__c,
																	TECH_AccountFiscalID__c,
																	TECH_AccountPhone__c,
																	TECH_AccountEmail__c,
																	TECH_AccountBillingPostalCode__c,
																	AssetId__r.Model__c,
																	AccountId__r.LandlineProfessionalTelephone__pc,
																	AccountId__r.MobilePersonalTelephone__pc,
																	AccountId__r.MobileProfessionalTelephone__pc,
																	AccountId__r.Phone,
																	AccountId__r.TECH_NationalId__c  
																	FROM AccountContactAssetRelation__c WHERE AssetId__c IN :assLst];
		for (AccountContactAssetRelation__c acRelation: relationLst) {
				//Assert
				System.assertEquals(acRelation.AssetId__r.VIN__c,acRelation.TECH_AssetVIN__c);
				System.assertEquals(acRelation.AssetId__r.Name + ' ' + acRelation.AssetId__r.Model__c,acRelation.TECH_AssetModel__c);
				System.assertEquals(acRelation.AssetId__r.LastKnownRegistrationNumber__c,acRelation.TECH_AssetLastKnownRegistrationNumber__c);
				System.assertEquals(acRelation.AccountId__r.Name,acRelation.TECH_AccountName__c);
				System.assertEquals(acRelation.AccountId__r.TECH_FiscalId__c+ ' ' + acRelation.AccountId__r.TECH_NationalId__c,acRelation.TECH_AccountFiscalID__c );
				System.assertEquals(acRelation.AccountId__r.PersonEmail,acRelation.TECH_AccountEmail__c);
				System.assertEquals(acRelation.AccountId__r.BillingPostalCode,acRelation.TECH_AccountBillingPostalCode__c);
		}
		
		}
	
	}
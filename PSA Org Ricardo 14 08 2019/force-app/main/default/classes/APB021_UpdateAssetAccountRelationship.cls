/*-----------------------------------------------------------------------------------------------------------//
 * Class Name : APB021_UpdateAssetAccountRelationship
 * Project : PSA - C1ST
 * Author : Nerea Leguinazabal
 * Date : 24/06/2019
 * Description : update related AssetAccountRelationship when Account or Asset is updated
 * History:
-- Date         Author          Version  Comments
-- -----------  -------------   -------  ---------------------------------------
-- 24/06/2019   nleguinazabal   1.0      Initial version nleguinazabal
*-----------------------------------------------------------------------------------------------------------*/

global class APB021_UpdateAssetAccountRelationship implements Database.Batchable<sObject> {

    //global variables
    static String objectId;
    private static String query;
    private String objUpdated;
    

    public APB021_UpdateAssetAccountRelationship(String objType) {
        //type of object to be checked
        this.objUpdated=objType;
    }
	
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        if(objUpdated== 'Account'){
            objectId='AccountId__c';
        }else {
            objectId='AssetId__c';
        }
        
        //query related AccountContactAssetRelation__c 
        query = 'SELECT Id, AccountId__c,AssetId__c,AssetId__r.Name,AssetId__r.VIN__c,AssetId__r.Model__c,AssetId__r.LastKnownRegistrationNumber__c,AccountId__r.Name,AccountId__r.TECH_FiscalId__c,AccountId__r.TECH_Phone__c,AccountId__r.BillingPostalCode,AccountId__r.PersonEmail,AccountId__r.LandlinePersonalTelephone__pc,AccountId__r.LandlineProfessionalTelephone__pc,AccountId__r.MobilePersonalTelephone__pc,AccountId__r.MobileProfessionalTelephone__pc,AccountId__r.Phone,TECH_AssetVIN__c,TECH_AssetModel__c,TECH_AssetLastKnownRegistrationNumber__c,TECH_AccountEmail__c,AccountId__r.TECH_NationalId__c FROM AccountContactAssetRelation__c WHERE ' 
                + objectId +' IN (SELECT Id FROM ' + objUpdated+' WHERE LastModifiedDate>= TODAY)';
        return Database.getQueryLocator(query);
 
    }

    global void execute(Database.BatchableContext bc, List<AccountContactAssetRelation__c> records){
        // process each batch of records
        try {
            //assign new values to fields for AccountContactAssetRelation__c
            for(AccountContactAssetRelation__c obj : records){
                obj.TECH_AssetVIN__c                            = obj.AssetId__r.VIN__c;
                obj.TECH_AssetModel__c                          = obj.AssetId__r.Name + ' ' + obj.AssetId__r.Model__c;
                obj.TECH_AssetLastKnownRegistrationNumber__c    = obj.AssetId__r.LastKnownRegistrationNumber__c;
                obj.TECH_AccountName__c                         = obj.AccountId__r.Name;
                obj.TECH_AccountFiscalID__c                     = obj.AccountId__r.TECH_FiscalId__c + ' ' + obj.AccountId__r.TECH_NationalId__c;
                obj.TECH_AccountPhone__c                        = String.valueOf(obj.AccountId__r.LandlinePersonalTelephone__pc + ' ' + obj.AccountId__r.LandlineProfessionalTelephone__pc + ' ' + obj.AccountId__r.MobilePersonalTelephone__pc + ' ' + obj.AccountId__r.MobileProfessionalTelephone__pc + ' ' + obj.AccountId__r.Phone).replace( 'null', '' ).trim();
                obj.TECH_AccountEmail__c                        = obj.AccountId__r.PersonEmail;
                obj.TECH_AccountBillingPostalCode__c            = obj.AccountId__r.BillingPostalCode;
        }
            Database.update(records);
        } catch (Exception e) {
            System.debug('Exception ERROR PF: APB021_UpdateAssetAccountRelationship-->' + e.getMessage() + ' Line: '+e.getLineNumber());
        }
        

    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    

}
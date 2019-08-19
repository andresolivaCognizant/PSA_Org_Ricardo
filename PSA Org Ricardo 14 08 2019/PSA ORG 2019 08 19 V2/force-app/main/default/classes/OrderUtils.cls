/*
-- - Name			: OrderUtils
-- - Author			: Ricardo Pereira
-- - Date			: 21/02/2019
-- - Description	: Util Class.
--
-- - History:
-- Date			Author			Version		Comments
-- -----------  -----   		-------		---------------------------------------
-- 21/02/2019	RPR				1.0			Initial version
-- 09/07/2019	C1STRUN-2252	1.1			In case new funcionality for a matching Order-Asset with same VIN. 
-- 18/08/2019   Andrés Oliva    1.2         Included apex method  updateOrderFormToActiveStatus in order to fulfill JIRA  user story  C1STDEPLOY-231
*/
public with sharing class OrderUtils{
    
    private static final Map<String,Schema.RecordTypeInfo> MAP_ASSET_RT =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName();
    
    /*
     * @Method          :   updateOrderFormToActiveStatus
     * @Author          :   Andrés Oliva <andres.oliva@cognizant.com>
     * @Created         :   14 agust 2019
     * @Description     :   This method make apex solution for JIRA C1STDEPLOY-231. If order is canceled, the related list Order Form must be update status to active.  
     * @Params          :   List<Order > records after the changes, Map<Id, Order > record before the changes    
     */		
    public static void updateOrderFormToActiveStatus( List<Order > listNewOrder, Map<Id, Order > mapOldOrder )
    {
        try 
        {
            set< id > setIdCancellQuotes = new set< id >();
            for( Order  varOrder: listNewOrder  ) 
            {
                if(         varOrder.OrderFormId__c != null && 
                    (       varOrder.Status.equalsIgnoreCase ( system.label.SBQQ_cancellStatus_lbl ) 
                        &&  mapOldOrder.get( varOrder.id ).Status.equalsIgnoreCase( system.label.SBQQ_cancellStatus_lbl  )
                    ) 
                  )
                {
                    setIdCancellQuotes.add( varOrder.OrderFormId__c );
                }
            }
            list< SBQQ__Quote__c > lstOrderForm = [SELECT id,SBQQ__Status__c FROM SBQQ__Quote__c WHERE  id IN: setIdCancellQuotes ];
            if( !lstOrderForm.isEmpty())
            {
                for( SBQQ__Quote__c varForm: lstOrderForm  )
                {
                    varForm.SBQQ__Status__c  =   system.label.SBQQ_activeStatus_lbl;
                }
                update lstOrderForm ;
            }
        } 
        catch (Exception e ) 
        {
            system.debug('\n error with C1STDEPLOY-231 @@@' + e.getMessage() );
            throw e;
        }        
    }      
    /*
* @Method          :   callBUSingleOrderMethods
* @Description     :   This method processes methods for a single Order on before update (the order might be modified). 
* @Params          :   Order newOrder current state of the order
* @Params          :   Order oldOrder state of the order before the update (null if its an insertion)
*/ 
    public static void callBUSingleOrderMethods(Order newOrder, Order oldOrder) {
        
        
/**C1STRUN-2252. In case an asset with same VIN does not exits, create a new Asset. In case that it exists, update the AccountContactAssetRelation__c and create a new one if Order.Driver__c
*  is not null and another one if Order.Leaser__c is also not null **/
        
        // Booleans to check if the Asset has a previous Relation in order to put PosessionChangeConfirmation__c as true
        boolean hasPreviousOwnerRelation = false;
        boolean hasPreviousKeeperRelation = false;
        boolean hasPreviousDriverRelation = false;
        
        // Booleans to check if the Relation AccountContactAssetRelation__c has been already created with same parents which are the Account and the Asset
        boolean relationSameAccountSameVINOwner = false;
        boolean relationSameAccountSameVINKeeper = false;
        boolean relationSameAccountSameVINDriver = false;
        
        
        List<AccountContactAssetRelation__c> insertAccountContactAssetRelation = new List<AccountContactAssetRelation__c>();
        List<Asset> lstNewAssets = new List <Asset>();   
                
        Map <Id, List<AccountContactAssetRelation__c>> mapIdRelations = new Map <Id, List<AccountContactAssetRelation__c>>();        
        List<Asset> assetsWithSameVin = [Select Id, 
                                         (select Id, AccountRole__c, AccountId__c, AssetId__c  FROM Account_Contact_Asset_Relations__r 
                                          WHERE AccountRole__c = 'Owner' OR AccountRole__c = 'keeper' OR AccountRole__c = 'Driver')
                                         FROM Asset WHERE VIN__C =: newOrder.VIN__c];
        System.debug('##AssetsWithSameVIN' + assetsWithSameVin);
        
        // Only one Asset can have the same VIN because the VIN__C Field is Unique, so it will only be one match.
        if (!assetsWithSameVin.isEmpty()){
            Id assetId = assetsWithSameVin[0].Id;
            for (AccountContactAssetRelation__c a1 : assetsWithSameVin[0].Account_Contact_Asset_Relations__r ){                
                switch on a1.AccountRole__c{
                    when 'Owner'{ 
                        if (a1.AccountId__c == newOrder.AccountId && a1.AssetId__c == assetId){
                            relationSameAccountSameVINOwner = true;
                        } 
                        hasPreviousOwnerRelation = true;
                    }
                    when 'Keeper'{
                        if (a1.AccountId__c == newOrder.Leaser__c && a1.AssetId__c == assetId) {
                            relationSameAccountSameVINKeeper = true;
                        }
                        hasPreviousKeeperRelation = true;
                    }
                    when 'Driver'{
                        if (a1.AccountId__c == newOrder.Driver__c && a1.AssetId__c == assetId){
                            relationSameAccountSameVINDriver = true;
                        } 
                        hasPreviousDriverRelation = true;            
                    }
                }
                
            }
        }
        
        
        if(newOrder.Status == '9' 
           && (oldOrder == null || newOrder.Status != oldOrder.Status) 
           && assetsWithSameVin.isEmpty() ){
               
               lstNewAssets = createAssetsFromOrder(newOrder);
               if(!lstNewAssets.isEmpty()){
                   newOrder.AssetId__c = lstNewAssets[0].Id;
               }
               
           } else if(newOrder.Status == '9' 
                     && (oldOrder == null || newOrder.Status != oldOrder.Status) 
                     && !assetsWithSameVin.isEmpty()){      
                         
                         if (relationSameAccountSameVINOwner == false){
                             AccountContactAssetRelation__c newAccountContactAssetRelation = new AccountContactAssetRelation__c(
                                 AccountId__c = newOrder.AccountId,
                                 AssetId__c = assetsWithSameVin[0].Id,
                                 RelationBeginDate__c = System.today(),
                                 RegistrationNumber__c = newOrder.RegistrationNumber__c,
                                 RegistrationDate__c = newOrder.RegistrationDate__c,
                                 AccountRole__c = 'Owner'                             
                             );
                             if (hasPreviousOwnerRelation == true){
                                 newAccountContactAssetRelation.PosessionChangeConfirmation__c = true;
                             } 
                             
                             insertAccountContactAssetRelation.add(newAccountContactAssetRelation);
                             
                         }
                         if (newOrder.Driver__c != null && relationSameAccountSameVINDriver == false){
                             AccountContactAssetRelation__c driverAccountContactAssetRelation = new AccountContactAssetRelation__c(
                                 AccountId__c = newOrder.Driver__c,
                                 AssetId__c = assetsWithSameVin[0].Id,                                
                                 AccountRole__c = 'Driver',
                                 RelationBeginDate__c  = System.today()
                             );
                             
                             if (hasPreviousDriverRelation == true){
                                 driverAccountContactAssetRelation.PosessionChangeConfirmation__c = true;
                             }
                             insertAccountContactAssetRelation.add(driverAccountContactAssetRelation);                             
                         } 
                         
                         if(newOrder.Leaser__c != null && relationSameAccountSameVINKeeper == false){                             
                             AccountContactAssetRelation__c leaserAccountContactAssetRelation = new AccountContactAssetRelation__c(
                                 AccountId__c = NewOrder.Leaser__c,
                                 AssetId__c = assetsWithSameVin[0].Id,
                                 AccountRole__c = 'Keeper',
                                 RelationBeginDate__c  = System.today()                                 
                             );
                             
                             if (hasPreviousKeeperRelation == true) {
                                 leaserAccountContactAssetRelation.PosessionChangeConfirmation__c = true;
                             }                                                        
                             insertAccountContactAssetRelation.add(leaserAccountContactAssetRelation);                             
                         }
                     }
        
        if (!insertAccountContactAssetRelation.isEmpty()){            
            try {
                System.debug('##List of AccountContactAssetRelation to  Insert' + insertAccountContactAssetRelation);
                insert insertAccountContactAssetRelation;
            } catch (Exception e ) {
                System.debug('### An error occurred on OrderUtils: ' + e.getMessage());
            }             
        } 
        
        /** END of C1STRUN-2252 modifications **/                         
        
        
    }
    /*
* @Method          :   createAssetsFromOrder
* @Description     :   This methods creates Assets retrieving info from Orders.
* @Params          :   Order Order to be processed
* @Returns         :   List<Asset> Created assets
*/ 
    public static List<Asset> createAssetsFromOrder(Order order) {
        List<Asset> lstCreatedAssets = new List<Asset>();
        
        Map<Id,OrderCodesWrapper> mapIdOrderCodesWrp = new Map<Id,OrderCodesWrapper>();
        
        // New asset basic info
        Asset newAsset = new Asset(
            AccountId = order.AccountId,
            Brand__c = order.Brand__c,
            Country__c = order.Country__c,
            OptionalFeatures__c = order.Options__c,
            FirstRegistrationNumber__c = order.RegistrationNumber__c,
            Status = order.VehicleStatus__c,
            LCDV16__c = order.LCDV16__c,
            VIN__c = order.VIN__c,
            Name = order.VIN__c != null? order.VIN__c: order.OrderId__c + ' ASSET',
            AssetType__c = order.Order_Type__c,
            VIS__c = order.VIN__c != null && order.VIN__c.length() >= 8? order.VIN__c.right(8): '',
            OnTheRoadFirstDate__c = order.RealDeliveryDate__c,
            OrderId__c = order.Id,
            InteriorTrimColorCode__c = order.InteriorTrimColorCode__c,
            InteriorTrimColorDescription__c = order.InteriorTrimColorDescription__c,
            ExteriorTrimColorCode__c = order.ExteriorTrimColorCode__c,
            ExteriorTrimColorDescription__c = order.ExteriorTrimColorDescription__c,
            WarrantyBeginDate__c = order.RealDeliveryDate__c,
            ExternalId__c = order.VIN__c != null? order.VIN__c: order.Country__c + '_' + order.RegistrationNumber__c,
            AssetDestinationUsage__c = order.VPVU__c
        );
        
        
        if(order.AvailabilityDate__c != null){
            newAsset.ProductionYear__c = order.AvailabilityDate__c.year();
        }
        
        newAsset.RecordTypeId = getAssetRTByBrand(order.Brand__c);
        
        if(order.LCDV16__c != null && order.LCDV16__c.length() == 16){
            newAsset = getLCDVInfo(order, newAsset);
        }else{
            newAsset = getVOInfo(order, newAsset);
        }
        
        lstCreatedAssets.add(newAsset);
        insert lstCreatedAssets;
        
        return lstCreatedAssets;
    }
    
    
    /*
* @Method          :   getLCDVInfo
* @Description     :   This methods fills an asset with the info obtianed with the LCDV16 codes
*/
    @SuppressWarnings('PMD.CyclomaticComplexity')
    //CyclomaticComplexity warning suppressed. Ternary ifs needed.
    private static Asset getLCDVInfo(Order order, Asset newAsset){
        //Obtain the needed codes from LCDV16
        OrderCodesWrapper ordCodWrp = getOrderCodeWrpInstance(order);
        
        List<User> ownerInfo = [SELECT LanguageLocaleKey FROM User WHERE Id =:order.OwnerId];
        
        if(ordCodWrp != null && ownerInfo != null && !ownerInfo.isEmpty()){
            
            
            if ( !Schema.sObjectType.PSARangeDescription__c.fields.Description__c.isAccessible()
                || !Schema.sObjectType.PSARangeDescription__c.fields.Type__c.isAccessible()  ){ // CRUD Enforcement needed due to PMD rule
                    throw new CRUDException('No read access of PSARangeDescription__c');
                }
            
            //Obtain the description from LCDV16 codes
            List<PSARangeDescription__c> lstPSARangeDescs = 
                [SELECT Description__c, Type__c
                 FROM PSARangeDescription__c
                 WHERE Country__c =: order.Country__c 
                 AND Brand__c =: order.Brand__c 
                 AND Language__c =: ownerInfo[0].LanguageLocaleKey.left(2).toUpperCase()
                 AND Active__c = true
                 AND ((Code__c =: ordCodWrp.familyCode AND Type__c = 'LCDV4' AND RefersTo__c =: null)
                      OR (Code__c =: ordCodWrp.shapeCode AND Type__c = 'Shape' AND RefersTo__c =: ordCodWrp.familyCode)
                      OR (Code__c =: ordCodWrp.finishingCode AND  Type__c = 'Finishing' AND RefersTo__c =: ordCodWrp.familyCode)
                      OR (Code__c =: ordCodWrp.engineCode AND  Type__c = 'Engine' AND RefersTo__c =: ordCodWrp.familyCode)
                      OR (Code__c =: ordCodWrp.gearboxCode AND  Type__c = 'Gearbox' AND RefersTo__c =: ordCodWrp.familyCode)
                      OR (Code__c =: order.LCDV16__c AND  Type__c = 'LCDV16')
                     ) ]; 
            
            Map<String, PSARangeDescription__c> mapPSARangeDescriptions = new Map<String, PSARangeDescription__c>(); // Map<desc.Type__c, Object>
            for(PSARangeDescription__c rangeDesc: lstPSARangeDescs){
                
                mapPSARangeDescriptions.put(rangeDesc.Type__c, rangeDesc);
            }
            
            // Fill codes and desciptions in asset
            newAsset.FamilyCode__c = ordCodWrp.familyCode;
            newAsset.FamilyDescription__c = mapPSARangeDescriptions.containsKey('LCDV4')? mapPSARangeDescriptions.get('LCDV4').Description__c : '';
            newAsset.ShapeCode__c = ordCodWrp.shapeCode;
            newAsset.ShapeDescription__c = mapPSARangeDescriptions.containsKey('Shape')? mapPSARangeDescriptions.get('Shape').Description__c : '';
            newAsset.FinishingCode__c = ordCodWrp.finishingCode;
            newAsset.FinishingDescription__c = mapPSARangeDescriptions.containsKey('Finishing')? mapPSARangeDescriptions.get('Finishing').Description__c : '';
            newAsset.EngineCode__c = ordCodWrp.engineCode;
            newAsset.EngineDescription__c = mapPSARangeDescriptions.containsKey('Engine')? mapPSARangeDescriptions.get('Engine').Description__c : '';
            newAsset.GearboxCode__c = ordCodWrp.gearboxCode;
            newAsset.GearboxDescription__c = mapPSARangeDescriptions.containsKey('Gearbox')? mapPSARangeDescriptions.get('Gearbox').Description__c : '';
            newAsset.LCDV9__c = order.LCDV16__c.left(9);
            newAsset.Model__c = mapPSARangeDescriptions.containsKey('LCDV16')? mapPSARangeDescriptions.get('LCDV16').Description__c : '';
        }
        
        return newAsset;
    }
    
    
    /*
* @Method          :   getAssetRTByBrand
* @Description     :   Returns a RecordTypeId depending on the brand
*/ 
    private static Id getAssetRTByBrand(String brand){
        
        if('AP'.equals(brand)
           || 'AC'.equals(brand)
           || 'DS'.equals(brand)){
               
               return MAP_ASSET_RT.get('PSAVehicle').getRecordTypeId();
           }else{
               return MAP_ASSET_RT.get('NonPSAVehicle').getRecordTypeId();
           }
    }
    
    /*
* @Method          :   getOrderCodeWrpInstance
* @Description     :   This methods encapsulates OrderCodesWrapper intantiation, so a null can be return
*/ 
    private static OrderCodesWrapper getOrderCodeWrpInstance(Order order){
        if(order.LCDV16__c != null && order.LCDV16__c.length() == 16){
            return new OrderCodesWrapper(order);
        }else{
            return null;
        }
    }
    
    /*
* @Method          :   getVOInfo
* @Description     :   Retrives needed info from OrderForm for VO Orders.
*/
    private static Asset getVOInfo(Order order, Asset newAsset){
        
        // Retrieve OrderForm info
        for(SBQQ__Quote__c orderForm: 
            [SELECT GearboxDescription__c, EngineDescription__c, ProductionYear__c
             FROM SBQQ__Quote__c WHERE Id =: order.OrderFormId__c]){ // for loop+Query used to improve efficiency eventhough just one record is expected
                 
                 newAsset.GearboxDescription__c = orderForm.GearboxDescription__c;
                 newAsset.Model__c = order.VOModel__c;
                 newAsset.EngineDescription__c = orderForm.EngineDescription__c;
                 
                 if(newAsset.ProductionYear__c == null){
                     newAsset.ProductionYear__c = orderForm.ProductionYear__c;
                 }
                 
             }
        
        return newAsset;
    }
	/*
	* @Method          :   createAutomaticContactTask
	* @Description     :   This method creates tasks to contact automatically to the orders
	* @Params          :   setOrderId set of Orders to be processed
	* @Returns         :   void
	*/ 
    public static void createAutomaticContactTask(Set<id> setOrderId) {
		List<Order> lstOrders = new List<Order>();
		List<Task> lstTask = new List<Task>();
		lstOrders = [SELECT id, Opportunity.OwnerId, Brand__c, Country__c, AccountId, ShipToContactId,Account.RecordType.DeveloperName, Account.TECH_PersonContactId__c, RealDeliveryDate__c FROM 
		Order WHERE status =:SalesConstants.ORDER_STATUS_DELIVERED AND Order_Type__c =:SalesConstants.ORDER_ORDER_TYPE_VN AND Id IN :setOrderId];
		if(!lstOrders.isEmpty()){
			Map<String,AutomaticContactConfig__mdt> mapAutoContactConfig = getAutoContactConfig();
			if(!mapAutoContactConfig.KeySet().isEmpty()){
				for(Order order : lstOrders){
					if(mapAutoContactConfig.containsKey(order.Country__c+order.Brand__c+'Delivery')){
						Task deliveryTask = createAutoContactConfigTask(order,mapAutoContactConfig,'Delivery');
						lstTask.add(deliveryTask);
					}
					if(mapAutoContactConfig.containsKey(order.Country__c+order.Brand__c+'Loyalty')){
						Task loyaltyTask = createAutoContactConfigTask(order,mapAutoContactConfig,'Loyalty');
						lstTask.add(loyaltyTask);
					}
				}
			}
		}
		if(!lstTask.isEmpty()){
			insert lstTask;
		}
	}
	/*
	* @Method          :   getAutoContactConfig
	* @Description     :   This method gets all data from AutomaticContactConfig__mdt
	* @Params          :   
	* @Returns         :   map with all metadata
	*/ 
	public static Map<String,AutomaticContactConfig__mdt> getAutoContactConfig(){
		Map<String,AutomaticContactConfig__mdt> mapAutoContactConfig = new Map<String,AutomaticContactConfig__mdt>();
		for(AutomaticContactConfig__mdt mdtAutoContactConfig : [SELECT id, Brand__c, Country__c, Process__c, DaysToDue__c,Type__c FROM AutomaticContactConfig__mdt]){
			mapAutoContactConfig.put(mdtAutoContactConfig.Country__c+mdtAutoContactConfig.Brand__c+mdtAutoContactConfig.Process__c,mdtAutoContactConfig);
		}
		return mapAutoContactConfig;
	}
	/*
	* @Method          :   createAutoContactConfigTask
	* @Description     :   This method creates a task for an order with a specific process
	* @Params          :   Order order to create the task for
    * @Params          :   Map<String,AutomaticContactConfig> mapAutoContactConfig config for auto contact task creation
    * @Params          :   String process process indicated to create the task
	* @Returns         :   map with all metadata
	*/ 
	public static Task createAutoContactConfigTask(Order order, Map<String,AutomaticContactConfig__mdt> mapAutoContactConfig, String process){
			Task tsk = new Task();
			integer daysDue = Integer.valueOf(mapAutoContactConfig.get(order.Country__c+order.Brand__c+process).DaysToDue__c);
			tsk.OwnerId = order.Opportunity.OwnerId;
			if(order.Account.RecordType.DeveloperName == Constants.RT_ACCOUNT_B2B){
				tsk.WhoId = order.ShipToContactId;
			}
			else{
				tsk.WhoId = order.Account.TECH_PersonContactId__c;
			}
			tsk.WhatId = order.AccountId;
			tsk.Priority__c = SalesConstants.TASK_PRIORITY_NORMAL;
			tsk.ActivityDate = order.RealDeliveryDate__c.addDays(daysDue);
			if(process == 'Delivery'){
				tsk.Subject = Label.AutomaticContactTaskSubjectDelivery;
			}
			else{
				tsk.Subject = Label.AutomaticContactTaskSubjectLoyalty;
			}
            //Andrés Oliva  start 12/08/2019 Add type from custom metadata
            if( mapAutoContactConfig.ContainsKey(order.Country__c+order.Brand__c+process) && mapAutoContactConfig.get(order.Country__c+order.Brand__c+process).Type__c != null) 
            {
                 tsk.Type = mapAutoContactConfig.get(order.Country__c+order.Brand__c+process).Type__c;  //
            }
           
			return tsk;
	}

    
    /*
-- - Name			: OrderCodesWrapper
-- - Author			: Ricardo Pereira
-- - Date			: 21/02/2019
-- - Description	: Util subClass. This helps to calculate the codes needed to obtain the related PSARangeDescription__c info
--
-- - History:
-- Date			Author	Version		Comments
-- -----------  -----   -------		---------------------------------------
-- 21/02/2019	RPR		1.0			Initial version
*/
    private class OrderCodesWrapper{
        // IF LCDV16CODE = 0123456789ABCDFG
        protected String familyCode;//0123
        protected String shapeCode;//45
        protected String finishingCode;//6
        protected String engineCode;//78
        protected String gearboxCode;//9
        protected Id orderId;
        
        private OrderCodesWrapper(Order order){
            
            this.orderId = order.Id;
            this.familyCode = order.LCDV16__c.left(4);
            this.shapeCode = order.LCDV16__c.substring(4,6);
            this.finishingCode = order.LCDV16__c.substring(6,7);
            this.engineCode = order.LCDV16__c.substring(7,9);
            this.gearboxCode = order.LCDV16__c.substring(9,10);
            
        }
    }
}
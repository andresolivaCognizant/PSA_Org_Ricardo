/*
*   @Class : AssetRelationTriggerHandler.cls
*
*   @Author         :   Diego Rincón <diego.rincon@ext.mpsa.com>
*   @Created        :   07 may 2018
*   @Description    :   To manage Account Asset Relation trigger methods
*   --------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   --------------------------------------------------------------------------------------------------------------------
*      Developer            Date                    Description
*      Diego Rincón         07 may 2018             Creation.
*      Ruben Fernandez .    05 feb 2019             Merge from duplicate handler. 
*													Added:   shouldRunTrigger, dontRunTrigger, changeStatus
*													Updated: after Insert & after Update methods.
*      Antoine Audollent    05 apr 2019             Added: buildTechExtId, getRelationEndDateFormatted
*                                                   Updated: before insert & after insert
*	   Ruben Fernandez		04 jun 2019				Added custom bypass for Interfaces Team.
*	   Nerea Leguinazabal	12 jul 2019				Added SalesConstants for AccountRole__c
*   --------------------------------------------------------------------------------------------------------------------
*/
public class AssetRelationTriggerHandler {

	private static Boolean runtrigger = true;
    public static Set <Id> processedRecords 	= new Set<Id>();

	// upserted records which do not have to be updated in further trigger executions
	public static List<AccountContactAssetRelation__c> recordsToExclude = new List<AccountContactAssetRelation__c>();

	// roles which shouldn't have duplicates per asset record
	
	private static final Set<String> ROLES_TO_CHECK = new Set<String>{
		SalesConstants.ACCOUNT_ASSET_RELATIONSHIP_ACCOUNTROLE_OWNER,
		SalesConstants.ACCOUNT_ASSET_RELATIONSHIP_ACCOUNTROLE_KEEPER,
		SalesConstants.ACCOUNT_ASSET_RELATIONSHIP_ACCOUNTROLE_DRIVER,
		SalesConstants.ACCOUNT_ASSET_RELATIONSHIP_ACCOUNTROLE_OLDKEEPER
	};
        
    /*********************************************************************************************************
    * @Method          :   shouldRunTrigger
    * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
    * @Created         :   20 feb 2018
    * @Description     :   To get the flag that indicate if the trigger should run or not
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/   
	public static boolean shouldRunTrigger() {
		return runtrigger;
	}

    /*********************************************************************************************************
    * @Method          :   dontRunTrigger
    * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
    * @Created         :   20 feb 2018
    * @Description     :   To indicate that the trigger should not run
    * @params	       :   void
    * @Returns         :   void
    **********************************************************************************************************/     
	public static void dontRunTrigger() {
		runtrigger = false;
	}        
        
    /*********************************************************************************************************
    * @Method          :   beforeInsert
    * @Author          :   Diego Rincón
    * @Created         :   07 may 2018
    * @Description     :   Call the actions to be performed on trigger's before insert context.
    * @params	       :   List<AccountContactAssetRelation__c> records with new data.
    * @Returns         :   void
    **********************************************************************************************************/ 
	public static void beforeInsert(List<AccountContactAssetRelation__c> lstNewRelations) {
		
		for (AccountContactAssetRelation__c r : lstNewRelations) {
			setRelationBeginDate(r);
			buildTechExtId(r);	//C1STAGILE-8193
		}
		filterRelationList(lstNewRelations);
	}
         
    /*********************************************************************************************************
    * @Method          :   afterInsert
    * @Author          :   Diego Rincón
    * @Created         :   07 may 2018
    * @Description     :   Call the actions to be performed on trigger's after insert context.
    * @params	       :   Map<Id, AccountContactAssetRelation__c> records with new data.
    * @Returns         :   void
    **********************************************************************************************************/ 
	public static void afterInsert(Map<Id, AccountContactAssetRelation__c> mapNewRows) {
		
        //Control Recursion
		if( processedRecords.containsAll(mapNewRows.keySet()) ){
			return;
		}
	
		if(PAD.canTrigger('AllObjects_All_Interfaces') && !System.isBatch() && !System.isQueueable()){
            updatePossession(mapNewRows);
            updateAssetOwner(mapNewRows);
            ChangeAccountStatus.mainFunction(mapNewRows.values()); //Change the XXAccountStatus__c field in Account	
		}
        if(!System.isQueueable()){
            if(PAD.sUserTypeCode == '1' && PAD.sUserDMS){
                SAPIWebhook.ProcessRecords(mapNewRows.values(),0); //C1STAGILE-5760 15/11/2018. Added connection to DMS 
            }              
        }
		recordsToExclude.addAll(mapNewRows.values());
        //Add record to control the recursion
		processedRecords.addAll(mapNewRows.keySet());
	}        
       
    /*********************************************************************************************************
    * @Method          :   beforeUpdate
    * @Author          :   Diego Rincón
    * @Created         :   07 may 2018
    * @Description     :   Call the actions to be performed on trigger's before update context.
    * @params	       :   Map<Id, AccountContactAssetRelation__c> records with new data.
    * @Returns         :   void
    **********************************************************************************************************/    
	public static void beforeUpdate(Map<Id, AccountContactAssetRelation__c> mapOldRows, Map<Id, AccountContactAssetRelation__c> mapNewRows) {

        //Control Recursion
		if(processedRecords.containsAll(mapNewRows.keySet())){
			return;
		}        
        
        //Verify changes in fields to execute code only when it is neccesary
		Map<Id, AccountContactAssetRelation__c> mapChangedRecords = new Map<Id, AccountContactAssetRelation__c>();
		for (Id i : mapOldRows.keySet()) {
			//Verify changes in AccountRole__c
			if (mapOldRows.get(i).AccountRole__c != mapNewRows.get(i).AccountRole__c) {
				mapChangedRecords.put(i, mapNewRows.get(i));
			}
		}
        //Methods beforeUpdate
		filterRelationList(mapChangedRecords.values());
		for (AccountContactAssetRelation__c r : mapNewRows.values()) {
			buildTechExtId(r);	//C1STAGILE-8193
		}
	}

 	/*********************************************************************************************************
    * @Method          :   afterUpdate
    * @Author          :   Diego Rincón
    * @Created         :   07 may 2018
    * @Description     :   Call the actions to be performed on trigger's after update context.
    * @params	       :   Map<Id, AccountContactAssetRelation__c> records with new data.
    * @Returns         :   void
    **********************************************************************************************************/ 
	public static void afterUpdate(Map<Id, AccountContactAssetRelation__c> mapOldRows,Map<Id, AccountContactAssetRelation__c> mapNewRows){
		
        //Control Recursion
		if(processedRecords.containsAll(mapNewRows.keySet())){
			return;
		}
		recordsToExclude.addAll(mapNewRows.values());

		if(PAD.canTrigger('AllObjects_All_Interfaces') && !System.isBatch() && !System.isQueueable()){
            
            //Verify changes in fields to execute code only when it is neccesary
			Map<Id, AccountContactAssetRelation__c> mapChangedRecords = new Map<Id, AccountContactAssetRelation__c>();
			List<AccountContactAssetRelation__c> lAccAssetRelationToChangeAccountStatus = new List<AccountContactAssetRelation__c>();   
			for (Id i : mapOldRows.keySet()) {
				//Verify changes in AccountRole__c
				if (mapOldRows.get(i).AccountRole__c != mapNewRows.get(i).AccountRole__c) {
					mapChangedRecords.put(i, mapNewRows.get(i));
				}
				//Verify changes in RelationEndDate__c
				if(mapOldRows.get(i).RelationEndDate__c != mapNewRows.get(i).RelationEndDate__c){
					lAccAssetRelationToChangeAccountStatus.add(mapNewRows.get(i));
				}
			}			
            //Methods afterUpdate
            updatePossession(mapChangedRecords);
            updateAssetOwner(mapNewRows);
            ChangeAccountStatus.mainFunction(lAccAssetRelationToChangeAccountStatus); //Change the XXAccountStatus__c field in Account
		}
        if(!System.isQueueable()){
            if( PAD.sUserTypeCode == '1' && PAD.sUserDMS){  //C1STAGILE-5760 15/11/2018. Added connection to DMS 
                SAPIWebhook.ProcessRecords(mapNewRows.values(),0);
            }             
        }
		//Add record to control the recursion
		processedRecords.addAll(mapNewRows.keySet());  
	}

    
    
    
    
	/*********************************************************************************************************
    * @Method          :   updatePosession
    * @Author          :   Diego Rincón
    * @Created         :   08 may 2018
    * @Description     :   Update Account Asset Relation records, currently linked to an Asset that
	*				   :   has a new primary onwer / keeper role, to guarantee that an Asset has a
	*				   :   single active Keeeper and Owner.
    * @params	       :   Map<Id, AccountContactAssetRelation__c> records which are likely to hold
	*				   :   a new primary owner / keeper relation to an asset.
    * @Returns         :   void
    **********************************************************************************************************/     
	public static void updatePossession(Map<Id, AccountContactAssetRelation__c> mapNewRows) {

		// map to store the new role being edited per Asset record
		Map<Id, String> mapAssetNewRole = new Map<Id, String>();
		for (AccountContactAssetRelation__c r : mapNewRows.values()) {
			if (null != r.AssetId__c && null == mapAssetNewRole.get(r.AssetId__c)) {
				mapAssetNewRole.put(r.AssetId__c, r.AccountRole__c);
			}
		}

		if (!mapAssetNewRole.isEmpty()) {
			AfterSalesUtils.vehiclePossessionUpdate(mapNewRows, mapAssetNewRole);
		}
	}

	/*
	 * @Method          :   getNewRoleVal
	 * @Author          :   Diego Rincón
	 * @Created         :   08 may 2018
	 * @Description     :   Assign Account Role field on a Account Asset Relation record based on
							its parent Asset new role. 
	 * @Params          :   String with the role being created to an asset.
							Existing Account Asset Relation whose acount role should be updated as a
							new relation record has been upserted.
	 * @Returns         :   None.
	 */
	public static void getNewRoleVal(String newRelRole, AccountContactAssetRelation__c r) {
		switch on newRelRole {
			when 'Owner' {
				switch on r.AccountRole__c {
					when 'Owner' {
						r.AccountRole__c = SalesConstants.ACCOUNT_ASSET_RELATIONSHIP_ACCOUNTROLE_OLDOWNER;
						System.debug('AccountRole__c'+r.AccountRole__c);
						setRelationEndDate(r);
					}
					when 'Keeper' {
						r.AccountRole__c = SalesConstants.ACCOUNT_ASSET_RELATIONSHIP_ACCOUNTROLE_OLDKEEPER;
						setRelationEndDate(r);
					}
					when 'Driver' {
						r.AccountRole__c = SalesConstants.ACCOUNT_ASSET_RELATIONSHIP_ACCOUNTROLE_OLDDRIVER;
						setRelationEndDate(r);
					}
				}
			}
			when 'Keeper' {
				switch on r.AccountRole__c {
					when 'Keeper' {
						r.AccountRole__c = SalesConstants.ACCOUNT_ASSET_RELATIONSHIP_ACCOUNTROLE_OLDKEEPER;
						setRelationEndDate(r);
					}
				}
			}
			when 'Driver' {
				switch on r.AccountRole__c {
					when 'Driver' {
						r.AccountRole__c = SalesConstants.ACCOUNT_ASSET_RELATIONSHIP_ACCOUNTROLE_OLDDRIVER;
						setRelationEndDate(r);
					}
				}               
			}
		}
	}
	
	public static void setRelationBeginDate(AccountContactAssetRelation__c r){
		r.RelationBeginDate__c = r.RelationBeginDate__c == null ? System.today() : r.RelationBeginDate__c;
	}

	

	public static void setRelationEndDate(AccountContactAssetRelation__c r){
		r.RelationEndDate__c = r.RelationEndDate__c == null ? System.today() : r.RelationEndDate__c;
	}

	/*
	 * @Method          :   filterRelationList
	 * @Author          :   Diego Rincón
	 * @Created         :   08 may 2018
	 * @Description     :   Filter Account Asset Relation records, with Owner or
							Keeper roles, that need to be validated before
							saving changes to the database.
	 * @Params          :   List<AccountContactAssetRelation__c> records with new data.
	 * @Returns         :   None.
	 */
	public static void filterRelationList(List<AccountContactAssetRelation__c> lstRec) {

		// map to store rows which should be checked
		Map<AccountContactAssetRelation__c, Id> mapRelationWithAsset =
			new Map<AccountContactAssetRelation__c, Id>();

		// filter records to check
		for (AccountContactAssetRelation__c r : lstRec) {
			if (null != r.AssetId__c && ROLES_TO_CHECK.contains(r.AccountRole__c)) {
				mapRelationWithAsset.put(r, r.AssetId__c);
		   }
		   // clear confirmation checkbox for irrelevant roles
			if (!ROLES_TO_CHECK.contains(r.AccountRole__c)) {
				r.PosessionChangeConfirmation__c = false;
		   }
	   }

		// verify if related assets have additional owners / keepers		
		if (!mapRelationWithAsset.isEmpty()) {
			checkPossesion(mapRelationWithAsset);
		}
	}

	/*
	 * @Method          :   filterRelationList
	 * @Author          :   Diego Rincón
	 * @Created         :   09 may 2018
	 * @Description     :   Check whether an asset is related to additional ownwers or keepers.
	 * @Params          :   Map of AccountContactAssetRelation__c records with new data as key with
							their parent asset id as a value.
	 * @Returns         :   None.
	 */
	public static void checkPossesion (Map<AccountContactAssetRelation__c, Id> mapRelationWithAsset) {

		Map<Id, WrapperAssetPossesion> mapAssetPosession = new Map<Id, WrapperAssetPossesion>();

		List<AggregateResult> mapCountRoles = new List<AggregateResult>([	SELECT AssetId__c, AccountRole__c, COUNT(Id) cnt 
																			FROM AccountContactAssetRelation__c
																			WHERE AccountRole__c != null AND 
																			Id NOT IN : mapRelationWithAsset.keySet() AND 
																			AssetId__c IN :mapRelationWithAsset.values()
																			GROUP BY ROLLUP(AssetId__c, AccountRole__c)]);

		for (AggregateResult r : mapCountRoles) {
				// create a key/value pair if Asset Id is not found in map
				if (null == mapAssetPosession.get((Id) r.get('AssetId__c'))) {
					mapAssetPosession.put((Id) r.get('AssetId__c'), new WrapperAssetPossesion());
				}
				// populate counter on map
				assignCount(mapAssetPosession.get((Id) r.get('AssetId__c')),r);
		}

		for (AccountContactAssetRelation__c s : mapRelationWithAsset.keySet()) {
			if (null != mapAssetPosession.get(s.AssetId__c) &&!s.PosessionChangeConfirmation__c) {

				if (s.AccountRole__c=='Owner'&&mapAssetPosession.get(s.AssetId__c).countOwner > 0) {
						s.addError(Label.AssetPossessionOwnerError);
				}else if (s.AccountRole__c=='Keeper'&&mapAssetPosession.get(s.AssetId__c).countKeeper > 0){
						s.addError(Label.AssetPossessionKeeperError);
						
				}else if(s.AccountRole__c=='OldKeeper'&&mapAssetPosession.get(s.AssetId__c).countDriver > 0){
						s.addError(Label.AssetPossessionOldKeeperError);
				}
			}
		}
	}


	public static void assignCount (WrapperAssetPossesion w, AggregateResult r) {
		switch on (String) r.get('AccountRole__c') {
			when 'Owner' {
				w.countOwner = (Integer) r.get('cnt');
			}
			when 'Keeper' {
				w.countKeeper = (Integer) r.get('cnt');
			}
			when 'Driver' {
				w.countDriver = (Integer) r.get('cnt');
			}
		}
	}


	public class WrapperAssetPossesion {
		public Integer countOwner       {get; set;}
		public Integer countKeeper      {get; set;}
		public Integer countDriver      {get; set;}

		public WrapperAssetPossesion() {
			this.countOwner     = 0;
			this.countKeeper    = 0;
			this.countDriver    = 0;
		}
	}

	

 	/*********************************************************************************************************
    * @Method          :   UpdateAssetOwner
    * @Author          :   Diego Rincón
    * @Created         :   2018-07-16
    * @Description     :   Class to update the AccountId field on Asset sObject when a new AccountContactAssetRelation__c 
    *                  :   record having Owner role is successfully inserted or updated.
    * @params	       :   Map of AccountContactAssetRelation__c records.
    * @Returns         :   void
	-- Date         Author              Version  Comments
    -- -----------  -------------       -------  ---------------------------------------
    -- 08/05/2018   Diego Rincón        1.0       ...
    -- 01/07/2019   Nerea Leguinazabal  1.1       Changed the method to be shyncronous
    **********************************************************************************************************/   
	public static void updateAssetOwner(Map<Id, AccountContactAssetRelation__c> m) {
		Map<Id, AccountContactAssetRelation__c> mapRecords = m;
		Map<Id, Asset> mapAssets = new Map<Id, Asset>();
	
		for (AccountContactAssetRelation__c r : mapRecords.values()) {
			if (
				'Owner' == r.AccountRole__c &&
				null == mapAssets.get(r.AssetId__c) &&
				null != r.AssetId__c &&
				null != r.AccountId__c
			) {
				mapAssets.put(
					r.AssetId__c,
					new Asset(
						Id          = r.AssetId__c,
						AccountId   = r.AccountId__c
					)
				);
			}
		}

		// only update Asset records if AccountId field needs to change
		if(!mapAssets.isEmpty()) {
			for (Asset a : [
				SELECT Id, AccountId
				FROM Asset
				WHERE Id IN :mapAssets.values()
			]) {
				if (a.AccountId == mapAssets.get(a.Id).AccountId) {
					mapAssets.remove(a.Id);
				}
			}

			/* BEGIN - Manuel Medina - C1STAGILE-6528 - Allow change the Asset.AccountId field - 30012019 */
			AssetUtils.blnAllowChangeAccountId = true;
			/* END - Manuel Medina - 30012019 */

			update mapAssets.values();
		}
	}


	/*********************************************************************************************************
	* @Method          :   buildTechExtId
	* @Author          :   Antoine Audollent
	* @Created         :   04/04/2019
	* @Description     :   build sf field TechExtId__c with the following format AccountId_c+'-'+AssetId__c +'-'+AccountRole__c+'-'+(RelationEndDate_c,YYMMDD)
	* @params	       :   list<AccountContactAssetRelation__c> Trigger.new in before event of insert/update
	* @Returns         :   void
	**********************************************************************************************************/
	public static void buildTechExtId(AccountContactAssetRelation__c accountContactAssetRelation) {
		accountContactAssetRelation.TECHExtId__c = accountContactAssetRelation.AccountId__c + '_' + accountContactAssetRelation.AssetId__c + '_' + accountContactAssetRelation.AccountRole__c+ '_' +  getRelationEndDateFormatted(accountContactAssetRelation.RelationEndDate__c);
	}

	/*********************************************************************************************************
	* @Method          :   getRelationEndDateFormatted
	* @Author          :   Antoine Audollent
	* @Created         :   05/04/2019
	* @Description     :   format RelationEndDate to format requested YYMMDD as string or empty string if date is null 
	* @params	       :   Date RelationEndDate
	* @Returns         :   String date formatted or empty string
	**********************************************************************************************************/
	private static String getRelationEndDateFormatted(Date RelationEndDate){

		if(RelationEndDate == null){
			return '';
		}

		Integer day = RelationEndDate.day();
		Integer month = RelationEndDate.month();
		Integer year = RelationEndDate.year();
		Datetime dtRelationEndDate = Datetime.newInstance(year, month, day);

		return String.valueOf(dtRelationEndDate.format('yyMMdd'));
	}

}
/**
* Salesforce
* @author 			NN
* Project:			Sales & B2B
* Description:		Manages Account/Contact standard fields.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	2.0		2019-04-29		Manuel Medina (MM)		Method preventOverride was added.
*********************************************************************************************************/
public class PopulateStandardEmailAndPhone {
	
	/*Start Update. Method changed to ByDeveloperName instead of ByName */
	private final static id RT_PERSONACCOUNT 	= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount_B2C').getRecordTypeId();
	private final static id RT_CONTACTB2B 	= Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('B2BContact').getRecordTypeId();
	//private final static id RT_ACCOUNTB2C     = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C_PA').getRecordTypeId();
	//private final static id RT_CONTACTB2B     = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Label.RTContactB2B).getRecordTypeId();
	/* End Update */

	/**
	* @Method: 		setEmailAndPhone
	* @param: 		List<sObject> lNewRecords
	* @param: 		map<id,sObject> mapIdOldRecords
	* @Description:	Sets standard fields based on custom field values.
	* @author 		NN - ddMMyyyy
	*/
	public static void setEmailAndPhone(List<sObject> lNewRecords, map<id,sObject> mapIdOldRecords){
        
        Set<Id> setAccounts = new Set<Id>();
		for(sObject sObj : lNewRecords){
			if(sObj.getSObjectType() == Schema.Contact.getSObjectType()){
				setAccounts.add((Id)sObj.get('AccountId'));
			}
		}
		Map<ID, Account> mapAccounts;
		if(setAccounts!= null && setAccounts.size()>0){
			mapAccounts = new Map<Id, Account>([SELECT Id, Country__c FROM Account WHERE Id IN: setAccounts]); 
		}
		
		for(sObject sObj : lNewRecords){
			
			if(sObj.getSObjectType() == Schema.Contact.getSObjectType()){
				
				Contact oContact = (Contact) sObj;
				//Test
				if(oContact.recordTypeid == RT_CONTACTB2B){
					
					if(mapIdOldRecords == null){//Trigger.insert

						/* BEGIN - Manuel Medina - C1STAGILE-9249 - Logic to prevent PersonEmail override - 04292019 */
						//oContact.Email = oContact.ProfessionalEmail__c;
						oContact					= ( Contact ) preventOverride( oContact, 'Email', 'ProfessionalEmail__c', true );
						/* END - Manuel Medina - 04292019 */

						if(oContact.LandlineProfessionalTelephone__c!=null){
							oContact.Phone = (oContact.LandlineProfessionalTelephone__c.contains('+'))?oContact.LandlineProfessionalTelephone__c:'+'+oContact.LandlineProfessionalTelephone__c;
						}
						if(oContact.MobileProfessionalTelephone__c!=null){
						oContact.MobilePhone = (oContact.MobileProfessionalTelephone__c.contains('+'))?oContact.MobileProfessionalTelephone__c:'+'+oContact.MobileProfessionalTelephone__c;
						}
						/*START C1STAGILE-6384 RFL 27/12/2108 */
                        if(mapAccounts.containsKey(oContact.AccountId)){
                            oContact.TECH_ContactCountry__c = mapAccounts.get(oContact.AccountId).Country__c;
                        }
						/*START C1STAGILE-6384 RFL 27/12/2108 */
					}else{//Trigger.Update
						
						/* BEGIN - Manuel Medina - C1STAGILE-9249 - Logic to prevent PersonEmail override - 04292019 */
						//if(oContact.ProfessionalEmail__c != mapIdOldRecords.get(oContact.id).get('ProfessionalEmail__c')){
						if( oContact.ProfessionalEmail__c != mapIdOldRecords.get( oContact.id ).get( 'ProfessionalEmail__c' ) || ( String.isBlank( oContact.Email ) && String.isNotBlank( oContact.ProfessionalEmail__c ) ) ){
							//oContact.Email = oContact.ProfessionalEmail__c;
							oContact					= ( Contact ) preventOverride( oContact, 'Email', 'ProfessionalEmail__c', false );
						}
						/* END - Manuel Medina - 04292019 */

						if(oContact.LandlineProfessionalTelephone__c != mapIdOldRecords.get(oContact.id).get('LandlineProfessionalTelephone__c')){
							if(oContact.LandlineProfessionalTelephone__c!=null){
								oContact.Phone = (oContact.LandlineProfessionalTelephone__c.contains('+'))?oContact.LandlineProfessionalTelephone__c:'+'+oContact.LandlineProfessionalTelephone__c;
							}						
						}
						
						if(oContact.MobileProfessionalTelephone__c != mapIdOldRecords.get(oContact.id).get('MobileProfessionalTelephone__c')){
							if(oContact.MobileProfessionalTelephone__c!=null){
							oContact.MobilePhone = (oContact.MobileProfessionalTelephone__c.contains('+'))?oContact.MobileProfessionalTelephone__c:'+'+oContact.MobileProfessionalTelephone__c;
							}
						}
						/*START C1STAGILE-6384 RFL 27/12/2108 */
                        if(mapAccounts.containsKey(oContact.AccountId)){
                            oContact.TECH_ContactCountry__c = mapAccounts.get(oContact.AccountId).Country__c;
                        }
						/*END C1STAGILE-6384 RFL 27/12/2108 */    
					}
				}
			}else if(sObj.getSObjectType() == Schema.Account.getSObjectType()){
				
				Account oAccount = (Account) sObj;
				if(oAccount.recordTypeid == RT_PERSONACCOUNT){
					if(mapIdOldRecords == null){//Trigger.insert
						
						/* BEGIN - Manuel Medina - C1STAGILE-9249 - Logic to prevent PersonEmail override - 04292019 */
						//oAccount.PersonEmail = oAccount.PersonalEmail__pc;
						oAccount					= ( Account ) preventOverride( oAccount, 'PersonEmail', 'PersonalEmail__pc', true );
						/* END - Manuel Medina - 04292019 */

						if(oAccount.LandlinePersonalTelephone__pc!=null){
							oAccount.Phone = (oAccount.LandlinePersonalTelephone__pc.contains('+'))?oAccount.LandlinePersonalTelephone__pc:'+'+oAccount.LandlinePersonalTelephone__pc;
						}
						if(oAccount.MobilePersonalTelephone__pc!=null){
							oAccount.PersonMobilePhone = (oAccount.MobilePersonalTelephone__pc.contains('+'))?oAccount.MobilePersonalTelephone__pc:'+'+oAccount.MobilePersonalTelephone__pc;
						}
						/*START C1STAGILE-6384 RFL 27/12/2108 */
						oAccount.TECH_ContactCountry__pc = oAccount.Country__c;
						/*END C1STAGILE-6384 RFL 27/12/2108 */
					}else{//Trigger.Update
					
						/* BEGIN - Manuel Medina - C1STAGILE-9249 - Logic to prevent PersonEmail override - 04292019 */
						//if(oAccount.PersonalEmail__pc != mapIdOldRecords.get(oAccount.id).get('PersonalEmail__pc')){
						if( oAccount.PersonalEmail__pc != mapIdOldRecords.get( oAccount.id ).get( 'PersonalEmail__pc' ) || ( String.isBlank( oAccount.PersonEmail ) && String.isNotBlank( oAccount.PersonalEmail__pc ) ) ){
							//oAccount.PersonEmail = oAccount.PersonalEmail__pc;
							oAccount					= ( Account ) preventOverride( oAccount, 'PersonEmail', 'PersonalEmail__pc', false );
						}
						/* END - Manuel Medina - 04292019 */
						
						if(oAccount.LandlinePersonalTelephone__pc != mapIdOldRecords.get(oAccount.id).get('LandlinePersonalTelephone__pc')){
							if(oAccount.LandlinePersonalTelephone__pc!=null){
								oAccount.Phone = (oAccount.LandlinePersonalTelephone__pc.contains('+'))?oAccount.LandlinePersonalTelephone__pc:'+'+oAccount.LandlinePersonalTelephone__pc;
							}
						}
						
						if(oAccount.MobilePersonalTelephone__pc != mapIdOldRecords.get(oAccount.id).get('MobilePersonalTelephone__pc')){
							if(oAccount.MobilePersonalTelephone__pc!=null){
								oAccount.PersonMobilePhone = (oAccount.MobilePersonalTelephone__pc.contains('+'))?oAccount.MobilePersonalTelephone__pc:'+'+oAccount.MobilePersonalTelephone__pc;
							}
						}
						/*START C1STAGILE-6384 RFL 27/12/2108 */
						if(oAccount.TECH_ContactCountry__pc != mapIdOldRecords.get(oAccount.id).get('Country__c')){
							oAccount.TECH_ContactCountry__pc = oAccount.Country__c;
						}
						/*END C1STAGILE-6384 RFL 27/12/2108 */ 
					}                   
				}
			}            
		}        
	}

	/**
	* @Method: 		preventOverride
	* @param: 		SObject sObjRecord
	* @param: 		String strFieldAPIName
	* @param: 		String strFieldSourceAPIName
	* @Description:	Prevents fields override based on source field.
	* @author 		Manuel Medina - 29042019
	*/
	public static SObject preventOverride( SObject sObjRecord, String strFieldTargetAPIName, String strFieldSourceAPIName, Boolean blsIsInsert ){
		sObjRecord.put( strFieldTargetAPIName,
			blsIsInsert && sObjRecord.get( strFieldTargetAPIName ) != null ?
				sObjRecord.get( strFieldTargetAPIName ) : 
				( sObjRecord.get( strFieldTargetAPIName ) != sObjRecord.get( strFieldSourceAPIName ) && sObjRecord.get( strFieldTargetAPIName ) != null && sObjRecord.get( strFieldSourceAPIName ) != null ) || sObjRecord.get( strFieldSourceAPIName ) != null ?
					sObjRecord.get( strFieldSourceAPIName ) :
					sObjRecord.get( strFieldTargetAPIName )
		);

		return sObjRecord;
	}
}
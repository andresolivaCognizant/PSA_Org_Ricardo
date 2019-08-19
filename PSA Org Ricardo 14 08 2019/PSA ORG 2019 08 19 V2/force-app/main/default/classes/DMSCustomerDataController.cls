/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			AfterSales
* Description:		DMSCustomerData controller class.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2018-06-19		Manuel Medina (MM)		Initial definition.
*********************************************************************************************************/
public with sharing class DMSCustomerDataController {

	@AuraEnabled 
	public static AccountExtRef__c objAccountExtRef					{get; set;}
	
	/**
	* @Method: 		getDMSCustomerData
    * @param: 		String strAccountId
	* @Description: Get DMS customer data given the accountId.
	* @author 		Manuel Medina - 19062018
	*/
	@AuraEnabled 
	public static String getDMSCustomerData( String strAccountId ){
		objAccountExtRef											= new AccountExtRef__c();

		try{
			if( !String.valueOf( Id.valueOf( strAccountId ).getSObjectType() ).equals( 'Account' ) && String.valueOf( Id.valueOf( strAccountId ).getSObjectType() ).equals( 'WorkshopAppointment__c' ) ){
				strAccountId										= [SELECT Id,
																			Driver__c
																		FROM WorkshopAppointment__c
																		WHERE Id =: strAccountId
																		LIMIT 1
																	].Driver__c;
			}
			
			Map<Id, AccountExtRef__c> mapAccountExtRefByAccountId	= new Map<Id, AccountExtRef__c>( getRelatedAccExtRef( new Set<Id>{ strAccountId } ) );
			objAccountExtRef										= mapAccountExtRefByAccountId.containsKey( strAccountId ) ? mapAccountExtRefByAccountId.get( strAccountId ) : objAccountExtRef;

			return objAccountExtRef.Id;
		
		}catch( Exception e ){
			System.debug( '\n\n\n\t<<<<<<<<< ExceptionType >>>>>>>>> \n\t\t@@--> getCause > ' + e.getCause() + '\n\t\t@@--> getLineNumber > ' + e.getLineNumber() + '\n\t\t@@--> getMessage > '+ e.getMessage() + '\n\t\t@@--> getStackTraceString > '+ e.getStackTraceString() + '\n\t\t@@--> getTypeName > ' + e.getTypeName() + '\n\n' );
			
			return 'ERROR\n\n\n\t<<<<<<<<< ExceptionType >>>>>>>>> \n\t\t@@--> getCause > ' + e.getCause() + '\n\t\t@@--> getLineNumber > ' + e.getLineNumber() + '\n\t\t@@--> getMessage > '+ e.getMessage() + '\n\t\t@@--> getStackTraceString > '+ e.getStackTraceString() + '\n\t\t@@--> getTypeName > ' + e.getTypeName() + '\n\n';
		}
		
		return null;
	}

	/**
	* @Method: 		getRelatedAccExtRef
    * @param: 		Set<Id> setAccountIds
	* @Description:	Returns a map with AccountExtRef__c records based on a given set of Account ids.
	* @author 		Manuel Medina - 20022019
	*/
	public static Map<Id, AccountExtRef__c> getRelatedAccExtRef( Set<Id> setAccountIds ){
		Map<Id, AccountExtRef__c> mapAccountExtRefByAccountId		= new Map<Id, AccountExtRef__c>();
		List<AccountExtRef__c> lstAccountExternals					= new List<AccountExtRef__c>( [
																		SELECT Id,
																			Balance__c,
																			CustomerAccountNumber__c,
																			ExternalId__c,
																			Dealer__c,
																			Account__c
																		FROM AccountExtRef__c
																		WHERE Account__c IN: setAccountIds
																		AND System__c = 'DMS'
																		AND Dealer__c IN (
																			SELECT AccountId
																			FROM User
																			WHERE Id =: System.UserInfo.getUserId()
																		)
																		ORDER BY ExternalId__c DESC
																	] );

		for( AccountExtRef__c objAccExtRef : lstAccountExternals ){
			if( !mapAccountExtRefByAccountId.containsKey( objAccExtRef.Account__c ) ){
				mapAccountExtRefByAccountId.put( objAccExtRef.Account__c, objAccExtRef );
			}
		}

		return mapAccountExtRefByAccountId;
	}

	/**
	* @Method: 		getDMSData
    * @param: 		String strAccountId
	* @Description: Get DMS customer data given the accountId.
	* @author 		Manuel Medina - 19022019
	*/
	@AuraEnabled 
	public static AccountExtRef__c getDMSData( String strAccountId ){
		getDMSCustomerData( strAccountId );

		return objAccountExtRef;
	}
}
/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			AfterSales
* Description:		Proccess which generate a CSV file from specific data related to Promo Refunding process.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2018-08-07		Manuel Medina (MM)		Initial definition.
*********************************************************************************************************/
global class APB013_PromoRefundingManagementFile implements Database.Batchable<sobject>, Database.AllowsCallouts, Database.Stateful{
	
	global Map<Id, Opportunity> mapFleetOpportunityById					{get; set;}
	
	global String strSOQL												{get; set;}
	global String strSOQLWhere											{get; set;}
	global String strOrdersCSV											{get; set;}
	global String strPromotionsCSV										{get; set;}
	global String strFleetOffersCSV										{get; set;}
	
	/**
	* @Method: 		APB013_PromoRefundingManagementFile
	* @param: 		N/A
	* @Description:	N/A
	* @author 		Manuel Medina - 08082018
	*/
	global APB013_PromoRefundingManagementFile(){
		this.mapFleetOpportunityById									= new Map<Id, Opportunity>();
		
		this.strOrdersCSV												= '';
		this.strPromotionsCSV											= '';
		this.strFleetOffersCSV											= '';
		this.strSOQL													= 'SELECT Id, ' +
																			'ParentOpportunity__c, ' +
																			'RecordType.DeveloperName, ' +
																			'( ' +
																				'SELECT Id, ' +
																					'SupplyOrderId__c, ' +
																					'OrderCreationDate__c, ' +
																					'DealerId__c, ' +
																					'DealerId__r.VNContractNumber__c, ' +
																					'OpportunityId, ' +
																					'Account.SalesChannel__c, ' +
																					'FleetCode__c, ' +
																					'OrderFormId__c, ' +
																					'OrderFormId__r.OPV_OfferCode__c, ' +
																					'OwnerId, ' +
																					'OrderFormId__r.BasePrice__c, ' +
																					'OrderFormId__r.TotalOptions__c, ' +
																					'UseType__c, ' +
																					'toLabel( OrderFormId__r.FundingForm__c ), ' +
																					'OrderFormId__r.FundingCompany__c, ' +
																					'Account.Name, ' +
																					'Account.FiscalId__c, ' +
																					'Account.TECH_fiscalId__c, ' +
																					'Account.NationalId__pc, ' +
																					'Account.RecordType.DeveloperName, ' +
																					'AccountId, ' +
																					'OrderFormId__r.LCDV16__c, ' +
																					'OrderFormId__r.ColorCode__c, ' +
																					'OrderFormId__r.InteriorTrimCode__c, ' +
																					'OrderFormId__r.QuotesWithOrderForms__c, ' +
																					'OrderFormId__r.QuotesWithOrderForms__r.SBQQ__Opportunity2__c, ' +
																					'OrderFormId__r.QuotesWithOrderForms__r.LCDV16__c, ' +
																					'OrderFormId__r.QuotesWithOrderForms__r.ColorCode__c, ' +
																					'OrderFormId__r.QuotesWithOrderForms__r.InteriorTrimCode__c, ' +
																					'OrderFormId__r.QuotesWithOrderForms__r.OptionCodes__c, ' +
																					'OrderFormId__r.QuotesWithOrderForms__r.ProductionYear__c, ' +
																					'OrderFormId__r.QuotesWithOrderForms__r.SubsidiaryPartAmount__c, ' +
																					'OrderFormId__r.QuotesWithOrderForms__r.SubsidiaryPartPercentage__c, ' +
																					'OrderFormId__r.QuotesWithOrderForms__r.DealerPartAmount__c, ' +
																					'OrderFormId__r.QuotesWithOrderForms__r.DealerPartPercentage__c, ' +
																					'OrderFormId__r.QuotesWithOrderForms__r.BasePrice__c, ' +
																					'OrderFormId__r.QuotesWithOrderForms__r.TotalOptions__c, ' +
																					'OrderFormId__r.QuotesWithOrderForms__r.SBQQ__Opportunity2__r.OrderStartDate__c, ' +
																					'OrderFormId__r.QuotesWithOrderForms__r.SBQQ__Opportunity2__r.OrderEndDate__c, ' +
																					'PromotionCode__c ' +
																				'FROM Orders ' +
																				'WHERE OrderCreationDate__c = YESTERDAY ' + 
																				'AND DealerId__r.Country__c = \'PL\' ' +
																			'), ' +
																			'( ' +
																				'SELECT Id, ' +
																					'SBQQ__Opportunity2__c, ' +
																					'LCDV16__c, ' +
																					'ColorCode__c, ' +
																					'InteriorTrimCode__c, ' +
																					'OptionCodes__c, ' +
																					'ProductionYear__c, ' +
																					'SubsidiaryPartAmount__c, ' +
																					'SubsidiaryPartPercentage__c, ' +
																					'DealerPartAmount__c, ' +
																					'DealerPartPercentage__c, ' +
																					'BasePrice__c, ' +
																					'TotalOptions__c, ' +
																					'SBQQ__Opportunity2__r.OrderStartDate__c, ' +
																					'SBQQ__Opportunity2__r.OrderEndDate__c ' +
																				'FROM SBQQ__Quotes2__r ' +
																			') ' +
																		'FROM Opportunity ';
	}
	
	/**
	* @Method: 		start
	* @param: 		Database.BatchableContext BC
	* @Description:	N/A
	* @author 		Manuel Medina - 06082018
	*/
	global Database.QueryLocator start( Database.BatchableContext BC ) {
		this.strSOQLWhere												= 'WHERE Id IN ( ' +
																			'SELECT OpportunityId ' +
																			'FROM Order ' +
																			'WHERE OrderCreationDate__c = YESTERDAY ' + 
																			'AND DealerId__r.Country__c = \'PL\' ' +
																		')';
		
		return Database.getQueryLocator( strSOQL + strSOQLWhere );
	}
	
	/**
	* @Method: 		execute
	* @param: 		Database.BatchableContext BC
	* @param: 		List<SObject> scope
	* @Description:	N/A
	* @author 		Manuel Medina - 06082018
	*/
	global void execute( Database.BatchableContext BC, List<Opportunity> lstOpportunities ){
		Set<Id> setParentOpportunityIds									= new Set<Id>();
		Set<Id> setQuoteIds												= new Set<Id>();
		Map<Id, User> mapOrderOwnerById									= new Map<Id, User>();
		Map<String, SBQQ__Quote__c> mapFleetQuoteByKey					= new Map<String, SBQQ__Quote__c>();
		Map<String, SBQQ__Quote__c> mapDiscountsByQuoteId				= new Map<String, SBQQ__Quote__c>();
		
		for( Opportunity objOpportunity : lstOpportunities ){
			if( String.isNotEmpty( objOpportunity.ParentOpportunity__c ) ){
				setParentOpportunityIds.add( objOpportunity.ParentOpportunity__c );
			}
		}
		 
		this.mapFleetOpportunityById.putAll(
			( List<Opportunity> ) Database.query( this.strSOQL + 'WHERE Id IN: setParentOpportunityIds' )
		);
		
		for( Opportunity objFleetOpportunity : mapFleetOpportunityById.values() ){
			for( SBQQ__Quote__c objFleetQuote : mapFleetOpportunityById.get( objFleetOpportunity.Id ).SBQQ__Quotes2__r ){
				String strKey											= objFleetQuote.LCDV16__c + objFleetQuote.ColorCode__c + objFleetQuote.InteriorTrimCode__c;
				
				mapFleetQuoteByKey.put( strKey, objFleetQuote );
			}
		}
		
		for( Opportunity objOpportunity : lstOpportunities ){
			for( Order objOrder : objOpportunity.Orders ){
				mapOrderOwnerById.put( objOrder.OwnerId, null );
				
				if( objOrder.OrderFormId__c != null && String.isNotBlank( objOrder.OrderFormId__r.QuotesWithOrderForms__c ) ){
					setQuoteIds.add( objOrder.OrderFormId__r.QuotesWithOrderForms__c );
				}
			}
		}
		
		mapDiscountsByQuoteId											= getQuoteDiscounts( setQuoteIds );
		mapOrderOwnerById												= new Map<Id, User>( [
																			SELECT Id,
																				Name,
																				LDAPId__c
																			FROM User
																			WHERE Id IN: mapOrderOwnerById.keySet()
																		] );
		
		for( Opportunity objOpportunity : lstOpportunities ){
			for( Order objOrder : objOpportunity.Orders ){
				String strNUMCCLT										= String.isNotBlank( objOrder.SupplyOrderId__c ) && objOrder.SupplyOrderId__c.contains( '_' ) ? objOrder.SupplyOrderId__c.substringAfterLast( '_' ) : objOrder.SupplyOrderId__c;
				
				String strKey											= objOrder.OrderFormId__r.LCDV16__c + objOrder.OrderFormId__r.ColorCode__c + objOrder.OrderFormId__r.InteriorTrimCode__c;
				
				Double dbBasePrice										= objOrder.OrderFormId__c != null && objOrder.OrderFormId__r.QuotesWithOrderForms__c != null && objOrder.OrderFormId__r.QuotesWithOrderForms__r.BasePrice__c != null ? objOrder.OrderFormId__r.QuotesWithOrderForms__r.BasePrice__c : 0;
				Double dbTotalOptions									= objOrder.OrderFormId__c != null && objOrder.OrderFormId__r.QuotesWithOrderForms__c != null && objOrder.OrderFormId__r.QuotesWithOrderForms__r.TotalOptions__c != null ? objOrder.OrderFormId__r.QuotesWithOrderForms__r.TotalOptions__c : 0;
				
				List<Object> lstOrderCSVRow								= new List<Object>();
				lstOrderCSVRow.add( 'O' );
				lstOrderCSVRow.add( strNUMCCLT );
				lstOrderCSVRow.add( objOrder.OrderCreationDate__c != null ? Datetime.newInstance( objOrder.OrderCreationDate__c, Time.newInstance( 0, 0, 0, 0 ) ).format( 'yyyy-MM-dd' ) : '' );
				lstOrderCSVRow.add( objOrder.DealerId__c != null ? objOrder.DealerId__r.VNContractNumber__c : null );
				lstOrderCSVRow.add( objOrder.Account.SalesChannel__c );
				lstOrderCSVRow.add( objOrder.FleetCode__c );
				lstOrderCSVRow.add( objOrder.OrderFormId__c != null ? objOrder.OrderFormId__r.OPV_OfferCode__c : null );
				lstOrderCSVRow.add( mapOrderOwnerById.get( objOrder.OwnerId ).Name );
				lstOrderCSVRow.add( mapOrderOwnerById.get( objOrder.OwnerId ).LDAPId__c );
				lstOrderCSVRow.add( dbBasePrice + dbTotalOptions );
				lstOrderCSVRow.add( objOrder.UseType__c );
				lstOrderCSVRow.add( objOrder.OrderFormId__c != null ? objOrder.OrderFormId__r.FundingForm__c : '' );
				lstOrderCSVRow.add( objOrder.OrderFormId__c != null && objOrder.OrderFormId__r.FundingCompany__c != null ? objOrder.OrderFormId__r.FundingCompany__c.substringAfter( 'PL_' ) : '' );
				lstOrderCSVRow.add( objOrder.Account.Name );
				lstOrderCSVRow.add( objOrder.Account.RecordType.DeveloperName.equals( 'Account_B2B' ) && String.isNotBlank( objOrder.Account.TECH_FiscalId__c ) ? objOrder.Account.TECH_FiscalId__c : '' );
				lstOrderCSVRow.add( objOrder.AccountId );
				
				this.strOrdersCSV										+= String.join( lstOrderCSVRow, ';' ) + '\n';
				
				List<Object> lstFleetOfferCSVRow						= new List<Object>();
				
				if( mapFleetQuoteByKey.containsKey( strKey ) ){
					lstFleetOfferCSVRow.add( 'F' );
					lstFleetOfferCSVRow.add( strNUMCCLT  );
					lstFleetOfferCSVRow.add( mapFleetQuoteByKey.get( strKey ).SBQQ__Opportunity2__c );
					lstFleetOfferCSVRow.add( mapFleetQuoteByKey.get( strKey ).LCDV16__c );
					lstFleetOfferCSVRow.add( mapFleetQuoteByKey.get( strKey ).ColorCode__c );
					lstFleetOfferCSVRow.add( mapFleetQuoteByKey.get( strKey ).InteriorTrimCode__c );
					lstFleetOfferCSVRow.add( mapFleetQuoteByKey.get( strKey ).OptionCodes__c );
					lstFleetOfferCSVRow.add( mapFleetQuoteByKey.get( strKey ).ProductionYear__c );
					lstFleetOfferCSVRow.add( mapFleetQuoteByKey.get( strKey ).SubsidiaryPartAmount__c );
					lstFleetOfferCSVRow.add( mapFleetQuoteByKey.get( strKey ).SubsidiaryPartPercentage__c != null ? mapFleetQuoteByKey.get( strKey ).SubsidiaryPartPercentage__c.intValue() : null );
					lstFleetOfferCSVRow.add( mapFleetQuoteByKey.get( strKey ).DealerPartAmount__c );
					lstFleetOfferCSVRow.add( mapFleetQuoteByKey.get( strKey ).DealerPartPercentage__c != null ?  mapFleetQuoteByKey.get( strKey ).DealerPartPercentage__c.intValue() : null );
					lstFleetOfferCSVRow.add( mapFleetQuoteByKey.get( strKey ).SBQQ__Opportunity2__r.OrderStartDate__c != null ? Datetime.newInstance( mapFleetQuoteByKey.get( strKey ).SBQQ__Opportunity2__r.OrderStartDate__c, Time.newInstance( 0, 0, 0, 0 ) ).format( 'yyyy-MM-dd' ) : '' );
					lstFleetOfferCSVRow.add( mapFleetQuoteByKey.get( strKey ).SBQQ__Opportunity2__r.OrderEndDate__c != null ? Datetime.newInstance( mapFleetQuoteByKey.get( strKey ).SBQQ__Opportunity2__r.OrderEndDate__c, Time.newInstance( 0, 0, 0, 0 ) ).format( 'yyyy-MM-dd' ) : '' );
				}
				
				if( !lstFleetOfferCSVRow.isEmpty() ){
					this.strFleetOffersCSV								+= String.join( lstFleetOfferCSVRow, ';' ) + '\n';
				}
				
				for( Discount__c objDiscount : ( objOrder.OrderFormId__c != null && mapDiscountsByQuoteId.containsKey( objOrder.OrderFormId__r.QuotesWithOrderForms__c ) ? mapDiscountsByQuoteId.get( objOrder.OrderFormId__r.QuotesWithOrderForms__c ).Discounts__r : new List<Discount__c>() ) ){
					List<Object> lstPromotionCSVRow							= new List<Object>();
					lstPromotionCSVRow.add( 'P' );
					lstPromotionCSVRow.add( strNUMCCLT );
					lstPromotionCSVRow.add( objDiscount.DiscountType__c );
					lstPromotionCSVRow.add( objOrder.PromotionCode__c );
					/* BEGIN - Manuel Medina - C1ST-10592 - Values of DiscountSubsidiaryType and DiscountDealerType were changed from 1 (PERCENTAGE) to 0 (AMOUNT) - 21112018 */
					lstPromotionCSVRow.add( objDiscount.SubsidiaryPartAmount__c );
					lstPromotionCSVRow.add( 0 );//DiscountSubsidiaryType
					lstPromotionCSVRow.add( objDiscount.DealerPartAmount__c );
					lstPromotionCSVRow.add( 0 );//DiscountDealerType
					/* END - Manuel Medina - 21112018 */
					
					this.strPromotionsCSV								+= String.join( lstPromotionCSVRow, ';' ) + '\n';
				}
			}
		}
	}
	
	/**
	* @Method: 		finish
	* @param: 		Database.BatchableContext BC
	* @Description:	N/A
	* @author 		Manuel Medina - 06082018
	*/
	global void finish( Database.BatchableContext BC ){
		Boolean blnSendAttachtment										= true;
		
		OPV_PromoRefundingFileSettings__mdt mdtPromoRefundingFile		= new OPV_PromoRefundingFileSettings__mdt();
		mdtPromoRefundingFile											= [SELECT Id,
																				AttachmentName__c,
																				EmailTemplate__c,
																				OrganizationWideEmailAddress__c,
																				SendEmailTo__c
																			FROM OPV_PromoRefundingFileSettings__mdt
																			WHERE DeveloperName = 'PromoRefunding'
																		];
		
		Messaging.EmailFileAttachment attPromoRefundingFile				= new Messaging.EmailFileAttachment();
		attPromoRefundingFile.contenttype								= 'text/csv; charset=UTF-8';
		attPromoRefundingFile.filename									= mdtPromoRefundingFile.AttachmentName__c + ' - ' + System.now().format( 'dd MMM yy' ) + '.csv';
		
		if( String.isNotBlank( strOrdersCSV ) || String.isNotBlank( strFleetOffersCSV ) || String.isNotBlank( strPromotionsCSV ) ){
			attPromoRefundingFile.body									= Blob.valueOf( strOrdersCSV + strFleetOffersCSV + strPromotionsCSV );
		}else{
			blnSendAttachtment											= false;
		}
		
		EmailTemplate ePromoRefunding									= new EmailTemplate();
		ePromoRefunding													= [SELECT Id
																			FROM EmailTemplate
																			WHERE DeveloperName =: mdtPromoRefundingFile.EmailTemplate__c
																			LIMIT 1
																		];
																		
		OrgWideEmailAddress eWideEmailAddres							= [SELECT Id
																			FROM OrgWideEmailAddress
																			WHERE Address =: mdtPromoRefundingFile.OrganizationWideEmailAddress__c
																			LIMIT 1
																		];
		
		Messaging.SingleEmailMessage msgFile							= new Messaging.SingleEmailMessage();
		msgFile.setOrgWideEmailAddressId( eWideEmailAddres.Id );
		msgFile.setToAddresses( mdtPromoRefundingFile.SendEmailTo__c.split( ';' ) );
		msgFile.setTemplateId( ePromoRefunding.Id );
		msgFile.setTargetObjectId( System.UserInfo.getUserId() );
		msgFile.setSaveAsActivity( false );
		
		if( blnSendAttachtment ){
			msgFile.setFileAttachments( new List<Messaging.EmailFileAttachment>{ attPromoRefundingFile } );
		}
		
		Messaging.sendEmail( new Messaging.SingleEmailMessage[] { msgFile } );
	}
	
	/**
	* @Method: 		getQuoteDiscounts
	* @param: 		Set<Id> setQuoteIds
	* @Description:	Returns alld discounts related to given set of quoute ids.
	* @author 		Manuel Medina - 06082018
	*/
	public Map<String, SBQQ__Quote__c> getQuoteDiscounts( Set<Id> setQuoteIds ){
		Map<String, SBQQ__Quote__c> mapDiscountsByQuoteId				= new Map<String, SBQQ__Quote__c>( [
																			SELECT Id,
																				( 
																					SELECT Id,
																						Quote__c,
																						DiscountType__c,
																						DiscountDescription__c,
																						SubsidiaryPartAmount__c,
																						DealerPartAmount__c
																					FROM Discounts__r
																				)
																			FROM SBQQ__Quote__c
																			WHERE Id IN: setQuoteIds
																		] );
																		
		return mapDiscountsByQuoteId;
	}
}
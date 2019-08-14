/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			AfterSales
* Description:		Wrapper class which represents the AfterSalesVehicleInterventions lightning component
*					expected structure to allow tables construction.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2018-06-27		Manuel Medina (MM)		Initial definition.
*********************************************************************************************************/
public class WRP001_AfterSalesIntervention {
	
	public static Map<String, Map<String, String>> mapOutValueByInValue_bkp;
	public static Map<String, DMSCurrencyAccess> mapDMSCurrencyAccessByDossierId_bkp;
	
	@AuraEnabled public List<Factures> factures												{get; set;}
	
	@AuraEnabled public Map<String, List<Interventions>> dossiers							{get; set;}
	@AuraEnabled public Map<String, Map<String, String>> mapOutValueByInValue				{get; set;}
	@AuraEnabled public Map<String, DMSCurrencyAccess> mapDMSCurrencyAccessByDossierId		{get; set;}
	
	/**
	* @Method: 		WRP001_AfterSalesIntervention
	* @param: 		N/A
	* @Description:	Wrapper constructor to load mapOutValueByInValue which contains SFDC values.
	* @author 		Manuel Medina - 31072018
	*/
	public WRP001_AfterSalesIntervention(){
		if( mapDMSCurrencyAccessByDossierId_bkp != null ){
			mapDMSCurrencyAccessByDossierId													= new Map<String, DMSCurrencyAccess>( mapDMSCurrencyAccessByDossierId_bkp );
		}
		
		if( mapOutValueByInValue_bkp == null ){
			getMapOutValueByInValue();
			
			WRP001_AfterSalesIntervention.mapOutValueByInValue_bkp							= new Map<String, Map<String, String>>( mapOutValueByInValue );
		}else{
			mapOutValueByInValue															= new Map<String, Map<String, String>>( WRP001_AfterSalesIntervention.mapOutValueByInValue_bkp );
		}
	}
	
	/**
	* @Method: 		WRP001_AfterSalesIntervention
	* @param: 		List<Factures> factures
	* @param: 		Map<String, List<interventions>> dossiers
	* @Description:	Wrapper constructor.
	* @author 		Manuel Medina - 27072018
	*/
	public WRP001_AfterSalesIntervention( List<Factures> factures, Map<String, List<interventions>> dossiers, Map<String, DMSCurrencyAccess> mapDMSCurrencyAccessByDossierId ){
		this.mapDMSCurrencyAccessByDossierId												= new Map<String, DMSCurrencyAccess>( mapDMSCurrencyAccessByDossierId );
		this.factures																		= factures;
		this.dossiers																		= dossiers;
		
		for( Factures objFacture : factures ){
			String strLibelle																= getHighestIntervention( dossiers.get( objFacture.dossierId ) );
			objFacture.strDescription														= strLibelle;
		}
		
		mapDMSCurrencyAccessByDossierId_bkp													= new Map<String, DMSCurrencyAccess>( mapDMSCurrencyAccessByDossierId );
	}
	
	/**
	* @Method: 		getHighestIntervention
	* @param: 		List<Interventions> lstInterventions
	* @Description: Gets the libelle for the highest intervention.
	* @author 		Manuel Medina - 27072018
	*/
	public String getHighestIntervention( List<Interventions> lstInterventions ){
		String strLibelle																	= '';
		Double dbHightestPrixHt																= 0;
		Boolean blnInterventionsWithoutPrice												= false;
		
		for( Interventions objIntervention : ( lstInterventions != null ? lstInterventions : new List<Interventions>() ) ){
			if( String.isNotBlank( objIntervention.prixTtc_bkp ) && Double.valueOf( objIntervention.prixTtc_bkp ) >= dbHightestPrixHt ){
				strLibelle																	= objIntervention.libelle;
				dbHightestPrixHt															= Double.valueOf( objIntervention.prixTtc_bkp );
				blnInterventionsWithoutPrice												= true;
			}
		}
		
		dbHightestPrixHt																	= 0;
		
		if( !blnInterventionsWithoutPrice ){
			for( Interventions objIntervention : ( lstInterventions != null ? lstInterventions : new List<Interventions>() ) ){
				objIntervention.strPiecesTotal												= String.isBlank( objIntervention.strPiecesTotal ) ? '0' : objIntervention.strPiecesTotal;
				objIntervention.strOperationsTotal											= String.isBlank( objIntervention.strOperationsTotal ) ? '0' : objIntervention.strOperationsTotal;
				
				Double dbTotal																= Double.valueOf( objIntervention.strPiecesTotal_bkp ) + Double.valueOf( objIntervention.strOperationsTotal_bkp );
				
				if( dbTotal >= dbHightestPrixHt ){
					strLibelle																= objIntervention.libelle;
					dbHightestPrixHt														= dbTotal;
				}
			}
		}
		
		return strLibelle;
	}
	
	/**
	* @Method: 		getMapOutValueByInValue
	* @param: 		N/A
	* @Description: Gets a map with SFDC label values.
	* @author 		Manuel Medina - 31072018
	*/
	public void getMapOutValueByInValue(){
		mapOutValueByInValue																= new Map<String, Map<String, String>>();
		List<APVHeaderWSValueTransformation__mdt> lstWSInOuts								= new List<APVHeaderWSValueTransformation__mdt>( [
																								SELECT Id,
																									InputType__c,
																									InputSubtype__c,
																									InputValue__c,
																									OutputValue__c
																								FROM APVHeaderWSValueTransformation__mdt
																							] );
																	
		for( APVHeaderWSValueTransformation__mdt mdtWSInOut : lstWSInOuts ){
			String strKey																	= mdtWSInOut.InputType__c + mdtWSInOut.InputSubtype__c;
			
			if( mapOutValueByInValue.containsKey( strKey ) ){
				mapOutValueByInValue.get( strKey ).put( mdtWSInOut.InputValue__c, mdtWSInOut.OutputValue__c );
				
			}else if( !mapOutValueByInValue.containsKey( strKey ) ){
				mapOutValueByInValue.put( strKey, new Map<String, String>{ mdtWSInOut.InputValue__c => mdtWSInOut.OutputValue__c } );
			}
		}
	}
	
	/**
	* @Method: 		getSFDCValue
	* @param: 		String strType
	* @param: 		String strSubtype
	* @param: 		String strInputValue
	* @Description: Gets SFDC value base on type, subtype and input value.
	* @author 		Manuel Medina - 31072018
	*/
	public String getSFDCValue( String strType, String strSubtype, String strInputValue ){
		if( mapOutValueByInValue.containsKey( strType + strSubtype ) && mapOutValueByInValue.get( strType + strSubtype ).containsKey( strInputValue ) ){
			return mapOutValueByInValue.get( strType + strSubtype ).get( strInputValue );
		}
		
		return strInputValue;
	}
	
	/**
	* @Method: 		formatCurrency
	* @param: 		String strCurrentValue
	* @param: 		String strDossierId
	* @Description:	Formats a given currency value based on DMS access and CurrencyISOCode.
	* @author 		Manuel Medina - 01082018
	*/
	public String formatCurrency( String strCurrentValue, String strDossierId ){
		Decimal dcCurrentValue																= String.isNotBlank( strCurrentValue ) ? Decimal.valueOf( strCurrentValue ) : 0;
		strCurrentValue																		= dcCurrentValue.format().replaceAll( '(,[0-9]{0,})', ',' + dcCurrentValue.toPlainString().substringAfter( '.' ) );
		
		if( mapDMSCurrencyAccessByDossierId != null && mapDMSCurrencyAccessByDossierId.containsKey( strDossierId ) && !mapDMSCurrencyAccessByDossierId.get( strDossierId ).blnIsVisible ){
			//return strCurrentValue.replaceAll( '[0-9]', '*' ).replace( '.', '' ).replace( ',', '' ) + ' ' + mapDMSCurrencyAccessByDossierId.get( strDossierId ).strCurrency;
			return '******';
			
		}else if( mapDMSCurrencyAccessByDossierId != null && mapDMSCurrencyAccessByDossierId.containsKey( strDossierId ) && mapDMSCurrencyAccessByDossierId.get( strDossierId ).blnIsVisible ){
			return strCurrentValue + ' ' + mapDMSCurrencyAccessByDossierId.get( strDossierId ).strCurrency;
		}
		
		return strCurrentValue;
	}
	
	/**
	* @Method: 		hiddeValue
	* @param: 		String strCurrentValue
	* @Description:	Hidde values if the current dealer does not have access.
	* @author 		Manuel Medina - 21012018
	*/
	public String hiddeValue( String strCurrentValue, String strDossierId ){
		if( mapDMSCurrencyAccessByDossierId != null && mapDMSCurrencyAccessByDossierId.containsKey( strDossierId ) && !mapDMSCurrencyAccessByDossierId.get( strDossierId ).blnIsVisible ){
			//return strCurrentValue.replaceAll( '[\\w]', '*' ).replace( '.', '' );
			return '******';
		}
		
		return strCurrentValue;
	}
	
	public class Factures {
		public WRP001_AfterSalesIntervention clsMain										{get{
																								return new WRP001_AfterSalesIntervention();
																							} set;}
																							
		@AuraEnabled public String id_bkp													{get; set;}
		@AuraEnabled public String id														{get{
																								id_bkp = id;
																								
																								return clsMain.hiddeValue( id, dossierId_bkp );
																							} set;}
		@AuraEnabled public String dossierId_bkp											{get; set;}
		@AuraEnabled public String dossierId												{get{
																								dossierId_bkp = dossierId;
			
																								return clsMain.hiddeValue( dossierId, dossierId_bkp );
																							} set;}
		@AuraEnabled public String idDms_bkp												{get; set;}
		@AuraEnabled public String idDms													{get{
																								idDms_bkp = idDms;
			
																								return clsMain.hiddeValue( idDms, dossierId_bkp );
																							} set;}
		@AuraEnabled public String strDate													{get{
																								if( String.isNotBlank( strDate ) ){
																									Date dtValue = Date.valueOf( strDate.replaceAll( '([0-9]{4})([0-9]{2})([0-9]{2})', '$1-$2-$3' ) );
																									return dtValue.format();
																								}else{
																									return '';
																								}
																							} set;}
		@AuraEnabled public String kilometrage												{get; set;}
		@AuraEnabled public String montantClient											{get; set;}
		@AuraEnabled public String montantGarantie											{get; set;}
		@AuraEnabled public String montantAssurance											{get; set;}
		@AuraEnabled public String commentaire												{get; set;}
		@AuraEnabled public String strDescription											{get; set;}
		@AuraEnabled public String strAmount_bkp											{get; set;}
		@AuraEnabled public String strAmount												{get{ 
																								String strTotal = String.valueOf( ( String.isNotBlank( montantClient ) ? Double.valueOf( montantClient ) : 0 ) + ( String.isNotBlank( montantGarantie ) ? Double.valueOf( montantGarantie ) : 0 ) + ( String.isNotBlank( montantAssurance ) ? Double.valueOf( montantAssurance ) : 0 ) );
																								strAmount_bkp = strTotal;
																								
																								return clsMain.formatCurrency( strTotal, dossierId_bkp );
																							} set;}
		@AuraEnabled public String strImputation											{get{
																								Double dbMontantClient = String.isNotBlank( montantClient ) ? System.Math.abs( Double.valueOf( montantClient ) ) : 0;
																								Double dbMontantGarantie = String.isNotBlank( montantGarantie ) ? System.Math.abs( Double.valueOf( montantGarantie ) ) : 0;
																								Double dbMontantAssurance = String.isNotBlank( montantAssurance ) ? System.Math.abs( Double.valueOf( montantAssurance ) ) : 0;
																								
																								if( dbMontantClient > dbMontantGarantie && dbMontantClient > dbMontantAssurance ){
																									return clsMain.hiddeValue( clsMain.getSFDCValue( 'INVOICE', 'IMPUTATION', '1' ), dossierId_bkp );
																									
																								}else if( dbMontantGarantie > dbMontantClient && dbMontantGarantie > dbMontantAssurance ){
																									return clsMain.hiddeValue( clsMain.getSFDCValue( 'INVOICE', 'IMPUTATION', '2' ), dossierId_bkp );
																									
																								}else if( dbMontantAssurance > dbMontantClient && dbMontantAssurance > dbMontantGarantie ){
																									return clsMain.hiddeValue( clsMain.getSFDCValue( 'INVOICE', 'IMPUTATION', '3' ), dossierId_bkp );
																								}
																								return '';
																							} set;}
	}
	
	public class Interventions {
		public WRP001_AfterSalesIntervention clsMain										{get{
																								return new WRP001_AfterSalesIntervention();
																							} set;}
																	
		@AuraEnabled public String id														{get; set;}
		@AuraEnabled public String dossierId_bkp											{get; set;}
		@AuraEnabled public String dossierId												{get{
																								dossierId_bkp = dossierId;
			
																								return clsMain.hiddeValue( dossierId, dossierId_bkp );
																							} set;}
		@AuraEnabled public String panierId													{get; set;}
		@AuraEnabled public String type														{get{
																								return clsMain.getSFDCValue( 'INTERVENTION', 'TYPE', type );
																							} set;}
		@AuraEnabled public String libelle													{get; set;}
		@AuraEnabled public String prixTtc_bkp												{get; set;}
		@AuraEnabled public String prixTtc													{get{
																								return clsMain.formatCurrency( prixTtc, dossierId_bkp );
																							} set;}
		@AuraEnabled public String prixHt_bkp												{get; set;}
		@AuraEnabled public String prixHt													{get{
																								return clsMain.formatCurrency( prixHt, dossierId_bkp );
																							} set;}
		@AuraEnabled public String forfaitReference											{get; set;}
		@AuraEnabled public String imputationCode											{get; set;}
		@AuraEnabled public String imputationType											{get{
																								String strImputationType = clsMain.getSFDCValue( 'INTERVENTION', 'IMPUTATIONTYPE', imputationType );
			
																								return clsMain.hiddeValue( strImputationType, dossierId_bkp );
																							} set;}
		@AuraEnabled public String commentaire												{get; set;}
		@AuraEnabled public String strPiecesTotal_bkp										{get; set;}
		@AuraEnabled public String strPiecesTotal											{get{
																								Double dbTotal = 0;
																								for( Piece objPiece : pieces.piece ){
																									dbTotal += ( String.isNotBlank( objPiece.strSubTotal_bkp ) ? Double.valueOf( objPiece.strSubTotal_bkp ) : 0 );
																								}
																								
																								strPiecesTotal_bkp = String.valueOf( Decimal.valueOf( dbTotal ).setScale( 2 ) );
																								
																								return clsMain.formatCurrency( String.valueOf( Decimal.valueOf( dbTotal ).setScale( 2 ) ), dossierId_bkp );
																							} set;}
		@AuraEnabled public String strOperationsTotal_bkp									{get; set;}
		@AuraEnabled public String strOperationsTotal										{get{
																								Double dbTotal = 0;
																								for( Operation objOperation : operations.operation ){
																									dbTotal += ( String.isNotBlank( objOperation.prixTtc_bkp ) ? Double.valueOf( objOperation.prixTtc_bkp ) : 0 );
																								}
																								strOperationsTotal_bkp = String.valueOf( Decimal.valueOf( dbTotal ).setScale( 2 ) );
																								
																								return clsMain.formatCurrency( String.valueOf( Decimal.valueOf( dbTotal ).setScale( 2 ) ), dossierId_bkp );
																							} set;}
		@AuraEnabled public Pieces pieces													{get; set;}
		@AuraEnabled public Operations operations											{get; set;}
		
		public Interventions(){
			this.pieces																		= new Pieces();
			this.operations																	= new Operations();
		}
	}
	
	public class Pieces {
		@AuraEnabled public List<Piece> piece												{get; set;}
		
		public Pieces(){
			this.piece																		= new List<Piece>();
		}
	}
	
	public class Piece {
		public WRP001_AfterSalesIntervention clsMain										{get{
																								return new WRP001_AfterSalesIntervention();
																							} set;}
		
		@AuraEnabled public String interventionId											{get; set;}
		@AuraEnabled public String reference												{get; set;}
		@AuraEnabled public String referenceLocale											{get; set;}
		@AuraEnabled public String libelle													{get; set;}
		@AuraEnabled public String imputationCode											{get; set;}
		@AuraEnabled public String imputationType											{get; set;}
		@AuraEnabled public String prixTtc_bkp												{get; set;}
		@AuraEnabled public String prixTtc													{get{
																								prixTtc_bkp = prixTtc;
																								return clsMain.formatCurrency( prixTtc, interventionId );
																							} set;}
		@AuraEnabled public String prixHt_bkp												{get; set;}
		@AuraEnabled public String prixHt													{get{
																								prixHt_bkp = prixHt;
																								return clsMain.formatCurrency( prixHt, interventionId );
																							} set;}
		@AuraEnabled public String quantite_bkp												{get; set;}
		@AuraEnabled public String quantite													{get{
																								quantite_bkp = quantite;
																								
																								return ( String.isBlank( quantite ) ? '1' : clsMain.hiddeValue( quantite, interventionId ) );
																							} set;}
		@AuraEnabled public String strSubTotal_bkp											{get; set;}
		@AuraEnabled public String strSubTotal												{get{
																								Double dbSubTotal = ( String.isNotBlank( prixTtc_bkp ) ? Double.valueOf( prixTtc_bkp ) : 0 ) * ( String.isNotBlank( quantite_bkp ) ? Double.valueOf( quantite_bkp ) : 1 );
																								strSubTotal_bkp = String.valueOf( Decimal.valueOf( dbSubTotal ).setScale( 2 ) );
																								
																								return clsMain.formatCurrency( String.valueOf( Decimal.valueOf( dbSubTotal ).setScale( 2 ) ), interventionId );
																							} set;}
	}
	
	public class Operations {
		@AuraEnabled public List<Operation> operation										{get; set;}
		
		public Operations(){
			this.operation																	= new List<Operation>();
		}
	}
	
	public class Operation {
		public WRP001_AfterSalesIntervention clsMain										{get{
																								return new WRP001_AfterSalesIntervention();
																							} set;}
		
		@AuraEnabled public String interventionId											{get; set;}
		@AuraEnabled public String code														{get{
																								return clsMain.hiddeValue( code, interventionId );
																							} set;}
		@AuraEnabled public String type														{get{
																								return clsMain.hiddeValue( clsMain.getSFDCValue( 'OPERATION', 'TYPE', type ), interventionId );
																							} set;}
		@AuraEnabled public String libelle													{get; set;}
		@AuraEnabled public String imputationCode											{get; set;}
		@AuraEnabled public String imputationType											{get; set;}
		@AuraEnabled public String tempsFacture												{get{
																								return clsMain.hiddeValue( tempsFacture, interventionId );
																							} set;}
		@AuraEnabled public String taux														{get; set;}
		@AuraEnabled public String metier													{get; set;}
		@AuraEnabled public String technicite												{get; set;}
		@AuraEnabled public String prixTtc_bkp												{get; set;}
		@AuraEnabled public String prixTtc													{get{
																								prixTtc_bkp = prixTtc;
																								return clsMain.formatCurrency( prixTtc, interventionId );
																							} set;}
		@AuraEnabled public String prixHt_bkp												{get; set;}
		@AuraEnabled public String prixHt													{get{
																								prixHt_bkp = prixHt;
																								return clsMain.formatCurrency( prixHt, interventionId );
																							} set;}
	}
	
	public class DMSCurrencyAccess {
		@AuraEnabled public Boolean blnIsVisible											{get; set;}
		@AuraEnabled public String strCurrency												{get; set;}
		@AuraEnabled public String strPdvId													{get; set;}
		
		public DMSCurrencyAccess( Boolean blnIsVisible, String strCurrency, String strPdvId ){
			this.blnIsVisible																= blnIsVisible;
			this.strCurrency																= String.isNotBlank( strCurrency ) ? strCurrency : '';
			this.strPdvId																	= String.isNotBlank( strPdvId ) ? strPdvId : '';
		}
	}
}
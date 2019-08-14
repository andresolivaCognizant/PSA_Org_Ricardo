/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			AfterSales
* Description:		Server side controller to AfterSalesVehicleInterventions lightning component.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------

* @version	1.0		2018-07-27		Manuel Medina (MM)		Initial definition.
*********************************************************************************************************/
public class AfterSalesVehicleInterventionsController {
	
	/**
	* @Method: 		getVehicleInterventions
    * @param: 		String strRequest
	* @Description: Gets vehicle interventios base on 
	* @author 		Manuel Medina - 19062018
	*/
	@AuraEnabled 
	public static Map<String, Object> getVehicleInterventions( String strRequest ){
		Map<String, Object> mapRequest										= new Map<String, Object>( ( Map<String, Object> ) JSON.deserializeUntyped( strRequest ) );
		Map<String, Object> mapResponse										= new Map<String, Object>{
																				'hasError'		=> false,
																				'ERROR'			=> '',
																				'REQUEST'		=> mapRequest,
																				'result'		=> ''
																			};
		try{
			APVHeaderInterventionsWSSettings__mdt mdtInterventionsWS		= new APVHeaderInterventionsWSSettings__mdt();
			mdtInterventionsWS												= [SELECT Id,
																					DeveloperName,
																					Endpoint__c,
																					SourceSystem__c,
																					SourceUser__c,
																					ClientSecret__c,
																					ClientCertificateName__c
																				FROM APVHeaderInterventionsWSSettings__mdt
																				WHERE DeveloperName =: 'INTERVENTIONS'
																				LIMIT 1
																			];
			
			HttpRequest req													= new HttpRequest();
			req.setEndpoint( mdtInterventionsWS.Endpoint__c + String.valueOf( mapRequest.get( 'strVIN' ) ).toUpperCase() );
			req.setMethod( 'GET' );
			req.setClientCertificateName( mdtInterventionsWS.ClientCertificateName__c );
			req.setHeader( 'Content-Type', 'application/json' );
			req.setHeader( 'X-SourceSystem', mdtInterventionsWS.SourceSystem__c );
			req.setHeader( 'X-SourceUser', mdtInterventionsWS.SourceUser__c );
			req.setHeader( 'X-Timestamp', System.now().format( 'yyyy-MM-dd' ) + 'T' + System.now().format( 'hh:mm:ss' ) );
			req.setHeader( 'X-ClientSecret', mdtInterventionsWS.ClientSecret__c );
			req.setTimeout( 120000 );
			
			Http http														= new Http();
			HTTPResponse res												= http.send( req );
			
			if( res.getStatusCode() != 200 ){
				throw new APVException( String.valueOf( res.getStatusCode() ) + ' ' + res.getStatus() );
			}
			
			String strResponse												= res.getBody();
			//String strResponse												= '{ "rechercheDossiersReponse": { "statutCode": "0", "statutTexte": "recherche ok [usr = \'MZPC1T02\', vin = \'VF3LWNFPCES178580\', pdv = \'null\']", "dossiers": [ { "dossier": { "id": "42853925", "idDms": "16057*1001377", "pdvId": "D02445A", "interventions": [ { "intervention": { "id": "83680724", "dossierId": "42853925", "type": "0", "libelle": "Intervention 1000", "prixTtc": 5162.4102, "prixHt": 4338.1602, "imputationType": "1", "pieces": [ { "piece": { "interventionId": "83680724", "reference": "9673999980", "libelle": "BOITIER CDE GMV", "imputationType": "1", "prixTtc": 4377.0098, "prixHt": 3678.1599, "quantite": 1 } } ], "operations": [ { "operation": { "interventionId": "83680724", "code": "12E0OA", "type": "1", "libelle": "REMPLACEMENT BOITIER COMMANDE GROUPE MOTOVENTILATE", "imputationType": "1", "tempsFacture": "0.3", "prixTtc": 785.4, "prixHt": 660 } } ] } } ], "factures": [ { "facture": { "id": "42763377", "dossierId": "42853925", "date": "2018-10-03", "kilometrage": 84282, "montantClient": 5162.4102, "montantGarantie": 0, "montantAssurance": 0, "commentaire": "BNA DIDOUCHE MOURAD : 001 00601 0300 051 899 55 SOCIETE GENERALE : 02100022113000013003" } } ] } }, { "dossier": { "id": "42852360", "idDms": "7661*5001074", "pdvId": "D02445A", "interventions": [ { "intervention": { "id": "83679062", "dossierId": "42852360", "type": "0", "libelle": "Intervention 1000", "prixTtc": 4010.8701, "prixHt": 3370.48, "imputationType": "1", "pieces": [ { "piece": { "interventionId": "83679062", "reference": "0000016488", "libelle": "JOINT", "imputationType": "1", "prixTtc": 160.04, "prixHt": 134.49, "quantite": 1 } }, { "piece": { "interventionId": "83679062", "reference": "9818914980", "libelle": "FILTRE A HUILE", "imputationType": "1", "prixTtc": 886.35, "prixHt": 744.83, "quantite": 1 } }, { "piece": { "interventionId": "83679062", "referenceLocale": "510004", "libelle": "HUILE TOTAL 7000", "imputationType": "1", "prixTtc": 2022, "prixHt": 1699.16, "quantite": 3.25 } } ], "operations": [ { "operation": { "interventionId": "83679062", "code": "01E8DA", "type": "1", "libelle": "VIDANGE,PLEIN,CARTOUCHE MOTEUR OPERATION DE SERVIC", "imputationType": "1", "tempsFacture": "0.4", "prixTtc": 942.48, "prixHt": 792 } } ] } } ], "factures": [ { "facture": { "id": "42761814", "dossierId": "42852360", "date": "2018-07-15", "kilometrage": 78654, "montantClient": 4010.8701, "montantGarantie": 0, "montantAssurance": 0, "commentaire": "BNA DIDOUCHE MOURAD : 001 00601 0300 051 899 55 SOCIETE GENERALE : 02100022113000013003" } } ] } }, { "dossier": { "id": "42927900", "idDms": "12985*4001198", "pdvId": "D02445A", "interventions": [ { "intervention": { "id": "83849922", "dossierId": "42927900", "type": "0", "libelle": "Intervention 1000", "prixTtc": 276242.5, "prixHt": 232136.5625, "imputationType": "2", "pieces": [ { "piece": { "interventionId": "83849922", "reference": "9804548280", "libelle": "JOINT CULASSE", "imputationType": "2", "prixTtc": 2627.3501, "prixHt": 2207.8601, "quantite": 1 } }, { "piece": { "interventionId": "83849922", "reference": "0000691489", "libelle": "VIS TH", "imputationType": "2", "prixTtc": 576.28, "prixHt": 484.27, "quantite": 6 } }, { "piece": { "interventionId": "83849922", "reference": "00000514A3", "libelle": "JOINT", "imputationType": "2", "prixTtc": 761.42, "prixHt": 639.85, "quantite": 1 } }, { "piece": { "interventionId": "83849922", "reference": "00000816H6", "libelle": "COURROIE CRANTE", "imputationType": "2", "prixTtc": 2637.6101, "prixHt": 2216.48, "quantite": 1 } }, { "piece": { "interventionId": "83849922", "reference": "00001628HQ", "libelle": "SONDE A OXYGENE", "imputationType": "2", "prixTtc": 16707.8691, "prixHt": 14040.2305, "quantite": 1 } }, { "piece": { "interventionId": "83849922", "reference": "0000170933", "libelle": "JOINT BRIDE ECH", "imputationType": "2", "prixTtc": 457.08, "prixHt": 384.1, "quantite": 1 } }, { "piece": { "interventionId": "83849922", "reference": "00000249C6", "libelle": "PLAQUE", "imputationType": "2", "prixTtc": 2171.49, "prixHt": 1824.78, "quantite": 2 } }, { "piece": { "interventionId": "83849922", "reference": "00000514A2", "libelle": "JOINT", "imputationType": "2", "prixTtc": 1020.16, "prixHt": 857.28, "quantite": 1 } }, { "piece": { "interventionId": "83849922", "reference": "0000312146", "libelle": "JOINT A LEVRE", "imputationType": "2", "prixTtc": 622.36, "prixHt": 522.99, "quantite": 1 } }, { "piece": { "interventionId": "83849922", "reference": "1608816780", "libelle": "JOINT A LEVRE", "imputationType": "2", "prixTtc": 550.55, "prixHt": 462.65, "quantite": 1 } }, { "piece": { "interventionId": "83849922", "reference": "1609266280", "libelle": "CARTER CYL NEUF", "imputationType": "2", "prixTtc": 175374.4688, "prixHt": 147373.5, "quantite": 1 } }, { "piece": { "interventionId": "83849922", "reference": "9801890480", "libelle": "CATALYSEUR", "imputationType": "2", "prixTtc": 32095.8105, "prixHt": 26971.2695, "quantite": 1 } } ], "operations": [ { "operation": { "interventionId": "83849922", "code": "MOM1", "type": "2", "libelle": "APPLICATION TSB", "imputationType": "2", "tempsFacture": "20.8", "prixTtc": 40640.0586, "prixHt": 34151.3086 } } ] } } ], "factures": [ { "facture": { "id": "42835695", "dossierId": "42927900", "date": "2018-12-27", "kilometrage": 81966, "montantClient": 0, "montantGarantie": 276242.5313, "montantAssurance": 0, "commentaire": "BNA DIDOUCHE MOURAD : 001 00601 0300 051 899 55 SOCIETE GENERALE : 02100022113000013003" } } ] } }, { "dossier": { "id": "42927899", "idDms": "12985*1002464", "pdvId": "D02445A", "interventions": [ { "intervention": { "id": "83849923", "dossierId": "42927899", "type": "0", "libelle": "Intervention 1000", "prixTtc": 691.28, "prixHt": 580.91, "imputationType": "1", "pieces": [ { "piece": { "interventionId": "83849923", "referenceLocale": "510004", "libelle": "HUILE TOTAL 7000", "imputationType": "1", "prixTtc": 691.28, "prixHt": 580.91, "quantite": 1 } } ] } } ], "factures": [ { "facture": { "id": "42835693", "dossierId": "42927899", "date": "2018-12-27", "kilometrage": 81966, "montantClient": 691.28, "montantGarantie": 0, "montantAssurance": 0, "commentaire": "BNA DIDOUCHE MOURAD : 001 00601 0300 051 899 55 SOCIETE GENERALE : 02100022113000013003" } } ] } }, { "dossier": { "id": "43045284", "idDms": "24976*1002513", "pdvId": "D02445A", "interventions": [ { "intervention": { "id": "84124585", "dossierId": "43045284", "type": "0", "libelle": "Intervention 1000", "prixTtc": 17477.2598, "prixHt": 14686.7803, "imputationType": "1", "pieces": [ { "piece": { "interventionId": "84124585", "reference": "1609417280", "libelle": "POMPE A EAU", "imputationType": "1", "prixTtc": 5866.6602, "prixHt": 4929.9702, "quantite": 1 } }, { "piece": { "interventionId": "84124585", "reference": "00005960F3", "libelle": "BOUGIE ALLUMAGE", "imputationType": "1", "prixTtc": 2026.67, "prixHt": 1703.08, "quantite": 4 } }, { "piece": { "interventionId": "84124585", "reference": "9818914980", "libelle": "FILTRE A HUILE", "imputationType": "1", "prixTtc": 986.66, "prixHt": 829.13, "quantite": 1 } }, { "piece": { "interventionId": "84124585", "referenceLocale": "510004", "libelle": "HUILE TOTAL 7000", "imputationType": "1", "prixTtc": 2765.1299, "prixHt": 2323.6399, "quantite": 4 } }, { "piece": { "interventionId": "84124585", "reference": "00001206A0", "libelle": "JOINT TORIQUE", "imputationType": "1", "prixTtc": 188.33, "prixHt": 158.26, "quantite": 1 } }, { "piece": { "interventionId": "84124585", "reference": "1637756480", "libelle": "LIQUIDE REFROID", "imputationType": "1", "prixTtc": 1750.8101, "prixHt": 1471.27, "quantite": 1 } }, { "piece": { "interventionId": "84124585", "reference": "00009731AQ", "libelle": "ETANCHEITE", "imputationType": "1", "prixTtc": 1275, "prixHt": 1071.4301, "quantite": 1 } } ], "operations": [ { "operation": { "interventionId": "84124585", "code": "13E37A", "type": "1", "libelle": "VIDANGE - PLEIN - PURGE CIRCUIT DE REFROIDISSEMENT", "imputationType": "1", "tempsFacture": "0.6", "prixTtc": 1570.8, "prixHt": 1320 } }, { "operation": { "interventionId": "84124585", "code": "01E8DA", "type": "1", "libelle": "VIDANGE,PLEIN,CARTOUCHE MOTEUR OPERATION DE SERVIC", "imputationType": "1", "tempsFacture": "0.4", "prixTtc": 1047.2, "prixHt": 880 } } ] } } ], "factures": [ { "facture": { "id": "42950389", "dossierId": "43045284", "date": "2019-01-07", "kilometrage": 78679, "montantClient": 17477.2695, "montantGarantie": 0, "montantAssurance": 0, "commentaire": "BNA DIDOUCHE MOURAD : 001 00601 0300 051 899 55 SOCIETE GENERALE : 02100022113000013003" } } ] } }, { "dossier": { "id": "43519134", "idDms": "27318*1002733", "pdvId": "D02445A", "interventions": [ { "intervention": { "id": "85197287", "dossierId": "43519134", "type": "0", "libelle": "Intervention 1000", "prixTtc": -691.28, "prixHt": -580.91, "imputationType": "1", "pieces": [ { "piece": { "interventionId": "85197287", "referenceLocale": "510004", "libelle": "HUILE TOTAL 7000", "imputationType": "1", "prixTtc": -691.28, "prixHt": -580.91, "quantite": -1 } } ] } } ], "factures": [ { "facture": { "id": "43413275", "dossierId": "43519134", "date": "2019-01-29", "kilometrage": 81966, "montantClient": -691.28, "montantGarantie": 0, "montantAssurance": 0, "commentaire": "BNA DIDOUCHE MOURAD : 001 00601 0300 051 899 55 SOCIETE GENERALE : 02100022113000013003" } } ] } } ] } }';
			strResponse														= strResponse.replaceAll( 'date', 'strDate' );
			
			WRP002_AfterSalesIntervention wrpResponse						= WRP002_AfterSalesIntervention.parse( strResponse );
			mapResponse.put( 'result', getFrontStructure( wrpResponse ) );
			
			return mapResponse;
			
		}catch( APVException e ){
			System.debug( '\n\n\n\t<<<<<<<<< APVExceptionType >>>>>>>>> \n\t\t@@--> getCause > ' + e.getCause() + '\n\t\t@@--> getLineNumber > ' + e.getLineNumber() + '\n\t\t@@--> getMessage > '+ e.getMessage() + '\n\t\t@@--> getStackTraceString > '+ e.getStackTraceString() + '\n\t\t@@--> getTypeName > ' + e.getTypeName() + '\n\n' );
			
			mapResponse.put( 'hasError', true );
			mapResponse.put(
				'ERROR',
				new Map<String, Object>{
					'cause'				=> 'APVExceptionType',
					'lineNumber'		=> e.getLineNumber(),
					'message'			=> e.getMessage(),
					'stackTraceString'	=> e.getStackTraceString(),
					'typeName'			=> e.getTypeName()
				}
			);
			
			return mapResponse;
			
		}catch( Exception e ){
			System.debug( '\n\n\n\t<<<<<<<<< ExceptionType >>>>>>>>> \n\t\t@@--> getCause > ' + e.getCause() + '\n\t\t@@--> getLineNumber > ' + e.getLineNumber() + '\n\t\t@@--> getMessage > '+ e.getMessage() + '\n\t\t@@--> getStackTraceString > '+ e.getStackTraceString() + '\n\t\t@@--> getTypeName > ' + e.getTypeName() + '\n\n' );
			
			mapResponse.put( 'hasError', true );
			mapResponse.put(
				'ERROR',
				new Map<String, Object>{
					'cause'				=> e.getCause(),
					'lineNumber'		=> e.getLineNumber(),
					'message'			=> e.getMessage(),
					'stackTraceString'	=> e.getStackTraceString(),
					'typeName'			=> e.getTypeName()
				}
			);
			
			return mapResponse;
		}
	}
	
	public static WRP001_AfterSalesIntervention getFrontStructure( WRP002_AfterSalesIntervention wrpResponse ){
		WRP001_AfterSalesIntervention wrpFront;
		Map<String, String> mapCurrencyByDMSId													= new Map<String, String>();
		Map<String, List<WRP001_AfterSalesIntervention.Interventions>> mapFacturesByDossierId	= new Map<String, List<WRP001_AfterSalesIntervention.Interventions>>();
		List<WRP001_AfterSalesIntervention.Factures> lstFactures								= new List<WRP001_AfterSalesIntervention.Factures>();
		Map<String, WRP001_AfterSalesIntervention.DMSCurrencyAccess> mapDMSByDossierId			= new Map<String, WRP001_AfterSalesIntervention.DMSCurrencyAccess>();
		
		for( WRP002_AfterSalesIntervention.Dossiers objDossier : ( wrpResponse.rechercheDossiersReponse.dossiers != null ? wrpResponse.rechercheDossiersReponse.dossiers : new List<WRP002_AfterSalesIntervention.Dossiers>() ) ){
			mapCurrencyByDMSId.put( objDossier.dossier.pdvId, '' );
		}
		
		User objUser																			= new User();
		objUser																					= [SELECT Id,
																										ContactId,
																										Contact.AccountId,
																										Contact.Account.RAContractNumber__c,
																										Contact.Account.CurrencyIsoCode
																									FROM User
																									WHERE Id =: System.UserInfo.getUserId()
																									LIMIT 1
																								];
																								
		for( Account objAccount : [SELECT Id, RAContractNumber__c, CurrencyIsoCode FROM Account WHERE RAContractNumber__c IN: mapCurrencyByDMSId.keySet()] ){
			mapCurrencyByDMSId.put( objAccount.RAContractNumber__c, objAccount.CurrencyIsoCode );
		}
		
		for( WRP002_AfterSalesIntervention.Dossiers objDossier : ( wrpResponse.rechercheDossiersReponse.dossiers != null ? wrpResponse.rechercheDossiersReponse.dossiers : new List<WRP002_AfterSalesIntervention.Dossiers>() ) ){
			
			Boolean blnIsVisible																= String.isNotBlank( objDossier.dossier.pdvId ) && objUser.ContactId != null && objUser.Contact.AccountId != null && mapCurrencyByDMSId.containsKey( objUser.Contact.Account.RAContractNumber__c ) && objDossier.dossier.pdvId.equals( objUser.Contact.Account.RAContractNumber__c );
			
			mapDMSByDossierId.put( objDossier.dossier.id, new WRP001_AfterSalesIntervention.DMSCurrencyAccess( blnIsVisible, mapCurrencyByDMSId.get( objDossier.dossier.pdvId ), objDossier.dossier.pdvId ) );
			
			for( WRP002_AfterSalesIntervention.Interventions objIntervention : ( objDossier.dossier.interventions != null ? objDossier.dossier.interventions : new List<WRP002_AfterSalesIntervention.Interventions>() ) ){
				WRP001_AfterSalesIntervention.Interventions objTargetIntervention				= new WRP001_AfterSalesIntervention.Interventions();
				
				for( WRP002_AfterSalesIntervention.Operations objOperations : ( objIntervention.intervention.operations != null ? objIntervention.intervention.operations : new List<WRP002_AfterSalesIntervention.Operations>() ) ){
					objTargetIntervention.operations.operation.add( ( WRP001_AfterSalesIntervention.Operation ) JSON.deserialize( JSON.serialize( objOperations.operation ), WRP001_AfterSalesIntervention.Operation.class ) );
				}
				
				for( WRP002_AfterSalesIntervention.Pieces objPieces : ( objIntervention.intervention.pieces != null ? objIntervention.intervention.pieces : new List<WRP002_AfterSalesIntervention.Pieces>() ) ){
					objTargetIntervention.pieces.piece.add( ( WRP001_AfterSalesIntervention.Piece ) JSON.deserialize( JSON.serialize( objPieces.piece ), WRP001_AfterSalesIntervention.Piece.class ) );
				}
				
				objTargetIntervention.id														= objIntervention.intervention.id;
				objTargetIntervention.dossierId_bkp												= objIntervention.intervention.dossierId;
				objTargetIntervention.dossierId													= objIntervention.intervention.dossierId;
				objTargetIntervention.panierId													= objIntervention.intervention.panierId;
				objTargetIntervention.type														= objIntervention.intervention.type;
				objTargetIntervention.libelle													= objIntervention.intervention.libelle;
				objTargetIntervention.prixTtc													= objIntervention.intervention.prixTtc;
				objTargetIntervention.prixTtc_bkp												= objIntervention.intervention.prixTtc;
				objTargetIntervention.prixHt													= objIntervention.intervention.prixHt;
				objTargetIntervention.prixHt_bkp												= objIntervention.intervention.prixHt;
				objTargetIntervention.forfaitReference											= objIntervention.intervention.forfaitReference;
				objTargetIntervention.imputationCode											= objIntervention.intervention.imputationCode;
				objTargetIntervention.imputationType											= objIntervention.intervention.imputationType;
				objTargetIntervention.commentaire												= objIntervention.intervention.commentaire;
				
				if( mapFacturesByDossierId.containsKey( objDossier.dossier.id ) ){
					mapFacturesByDossierId.get( objDossier.dossier.id ).add( objTargetIntervention );
					
				}else if( !mapFacturesByDossierId.containsKey( objDossier.dossier.id ) ){
					mapFacturesByDossierId.put( objDossier.dossier.id, new List<WRP001_AfterSalesIntervention.Interventions>{ objTargetIntervention } );
				}
				
				mapDMSByDossierId.put( objTargetIntervention.id, new WRP001_AfterSalesIntervention.DMSCurrencyAccess( blnIsVisible, mapCurrencyByDMSId.get( objDossier.dossier.pdvId ), objDossier.dossier.pdvId ) );
			}
			
			for( WRP002_AfterSalesIntervention.Factures objFactures : ( objDossier.dossier.factures != null ? objDossier.dossier.factures : new List<WRP002_AfterSalesIntervention.Factures>() ) ){
				WRP001_AfterSalesIntervention.Factures objFacture								= new WRP001_AfterSalesIntervention.Factures();
				objFacture																		= ( WRP001_AfterSalesIntervention.Factures ) JSON.deserialize( JSON.serialize( objFactures.facture ), WRP001_AfterSalesIntervention.Factures.class );
				objFacture.idDms																= objDossier.dossier.idDms;
				lstFactures.add( objFacture );
			}
		}
		
		wrpFront																				= new WRP001_AfterSalesIntervention( lstFactures, mapFacturesByDossierId, mapDMSByDossierId );
		return wrpFront;
	}
	
	public class APVException extends Exception{}
}
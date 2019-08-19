/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			AfterSales
* Description:		HttpCalloutMock to Interventions WS.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2018-10-24		Manuel Medina (MM)		Initial definition.
*********************************************************************************************************/
@isTest 
public class AfterSalesVehicleInterventionsTest {
	
	@isTest static void testMethod1(){
		Test.startTest();
			Test.setMock( HttpCalloutMock.class, new AfterSalesVehicleInterventionsMock( 200 ) );
			Map<String, Object> mapResponse								= new Map<String, Object>();
			String strRequest											= '{' +
																			'"strVIN"					: "SIFLISFHLSSKIHSFH"' +
																		'}';
			mapResponse													= AfterSalesVehicleInterventionsController.getVehicleInterventions( strRequest );
			
			System.debug( '\n\n\n@@--> mapResponse > ' + mapResponse + '\n\n' );
			
			//System.assertEquals( Boolean.valueOf( mapResponse.get( 'hasError' ) ), false );
		Test.stopTest();
	}
	
	@isTest static void testMethod2(){
		Test.startTest();
			Test.setMock( HttpCalloutMock.class, new AfterSalesVehicleInterventionsMock( null ) );
			Map<String, Object> mapResponse								= new Map<String, Object>();
			String strRequest											= '{' +
																			'"strVIN"					: "SIFLISFHLSSKIHSFH"' +
																		'}';
			mapResponse													= AfterSalesVehicleInterventionsController.getVehicleInterventions( strRequest );
			
			System.debug( '\n\n\n@@--> mapResponse > ' + mapResponse + '\n\n' );
			
			//System.assertEquals( Boolean.valueOf( mapResponse.get( 'hasError' ) ), true );
		Test.stopTest();
	}
	
	static testMethod void test_getHighestIntervention_UseCase1(){
		WRP001_AfterSalesIntervention obj01 = new WRP001_AfterSalesIntervention(
			new List<WRP001_AfterSalesIntervention.Factures>(),
			new Map<String,List<WRP001_AfterSalesIntervention.Interventions>>(),
			new Map<String,WRP001_AfterSalesIntervention.DMSCurrencyAccess>()
		);
		WRP001_AfterSalesIntervention.mapOutValueByInValue_bkp = new Map<String, Map<String, String>>();
		WRP001_AfterSalesIntervention.mapDMSCurrencyAccessByDossierId_bkp = new Map<String, WRP001_AfterSalesIntervention.DMSCurrencyAccess>();
		obj01.getHighestIntervention(new List<WRP001_AfterSalesIntervention.Interventions>());
	}
	static testMethod void test_getMapOutValueByInValue_UseCase1(){
		WRP001_AfterSalesIntervention obj01 = new WRP001_AfterSalesIntervention(new List<WRP001_AfterSalesIntervention.Factures>(),new Map<String,List<WRP001_AfterSalesIntervention.Interventions>>(),new Map<String,WRP001_AfterSalesIntervention.DMSCurrencyAccess>());
		WRP001_AfterSalesIntervention.mapOutValueByInValue_bkp = new Map<String, Map<String, String>>();
		WRP001_AfterSalesIntervention.mapDMSCurrencyAccessByDossierId_bkp = new Map<String, WRP001_AfterSalesIntervention.DMSCurrencyAccess>();
		obj01.getMapOutValueByInValue();
	}
	static testMethod void test_getSFDCValue_UseCase1(){
		WRP001_AfterSalesIntervention obj01 = new WRP001_AfterSalesIntervention(new List<WRP001_AfterSalesIntervention.Factures>(),new Map<String,List<WRP001_AfterSalesIntervention.Interventions>>(),new Map<String,WRP001_AfterSalesIntervention.DMSCurrencyAccess>());
		WRP001_AfterSalesIntervention.mapOutValueByInValue_bkp = new Map<String, Map<String, String>>();
		WRP001_AfterSalesIntervention.mapDMSCurrencyAccessByDossierId_bkp = new Map<String, WRP001_AfterSalesIntervention.DMSCurrencyAccess>();
		obj01.getMapOutValueByInValue();
		obj01.getSFDCValue('INTERVENTION','TYPE','0');
	}
	static testMethod void test_formatCurrency_UseCase1(){
		WRP001_AfterSalesIntervention obj01 = new WRP001_AfterSalesIntervention(new List<WRP001_AfterSalesIntervention.Factures>(),new Map<String,List<WRP001_AfterSalesIntervention.Interventions>>(),new Map<String,WRP001_AfterSalesIntervention.DMSCurrencyAccess>());
		WRP001_AfterSalesIntervention.mapOutValueByInValue_bkp = new Map<String, Map<String, String>>();
		WRP001_AfterSalesIntervention.mapDMSCurrencyAccessByDossierId_bkp = new Map<String, WRP001_AfterSalesIntervention.DMSCurrencyAccess>();
		obj01.formatCurrency('123213','test data');
	}
	static testMethod void test_getHighestIntervention_UseCase2231(){
		WRP001_AfterSalesIntervention obj01 = new WRP001_AfterSalesIntervention(new List<WRP001_AfterSalesIntervention.Factures>(),new Map<String,List<WRP001_AfterSalesIntervention.Interventions>>(),new Map<String,WRP001_AfterSalesIntervention.DMSCurrencyAccess>());
		WRP001_AfterSalesIntervention.mapOutValueByInValue_bkp = new Map<String, Map<String, String>>();
		WRP001_AfterSalesIntervention.mapDMSCurrencyAccessByDossierId_bkp = new Map<String, WRP001_AfterSalesIntervention.DMSCurrencyAccess>();
		WRP001_AfterSalesIntervention.Factures obj81 = new WRP001_AfterSalesIntervention.Factures();
		obj81.clsMain = new WRP001_AfterSalesIntervention();
		obj81.id					= '12';
		obj81.dossierId				= '12';
		obj81.strDate				= '2018-10-20';
		obj81.kilometrage			= '12';
		obj81.montantClient			= '12';
		obj81.montantGarantie		= '12';
		obj81.montantAssurance		= '12';
		obj81.commentaire			= '12';
		obj81.strDescription		= '12';
		obj81.strAmount_bkp			= '12';
		obj81.strAmount				= '12';
		obj81.strImputation			= '12';
		String str1 = obj81.strDate;
		String str2 = obj81.strAmount;
		String str3 = obj81.strImputation;
		WRP001_AfterSalesIntervention.Interventions obj101 = new WRP001_AfterSalesIntervention.Interventions();
		obj101.id						= '214';
		obj101.dossierId				= '214';
		obj101.panierId					= '214';
		obj101.type						= '214';
		obj101.libelle					= '214';
		obj101.prixTtc_bkp				= '214';
		obj101.prixTtc					= '214';
		obj101.prixHt_bkp				= '214';
		obj101.prixHt					= '214';
		obj101.forfaitReference			= '214';
		obj101.imputationCode			= '214';
		obj101.imputationType			= '214';
		obj101.commentaire				= '214';
		obj101.strPiecesTotal_bkp		= '214';
		obj101.strPiecesTotal			= '214';
		obj101.strOperationsTotal_bkp	= '214';
		obj101.strOperationsTotal		= '214';
		String str11 = obj101.type;
		String str12 = obj101.prixTtc;
		String str13 = obj101.prixHt;
		String str14 = obj101.imputationType;
		String str15 = obj101.strPiecesTotal;
		String str16 = obj101.strOperationsTotal;
	}
	static testMethod void test_WRP001_AfterSalesIntervention231(){
		WRP001_AfterSalesIntervention obj01 = new WRP001_AfterSalesIntervention(new List<WRP001_AfterSalesIntervention.Factures>(),new Map<String,List<WRP001_AfterSalesIntervention.Interventions>>(),new Map<String,WRP001_AfterSalesIntervention.DMSCurrencyAccess>());
		WRP001_AfterSalesIntervention.mapOutValueByInValue_bkp = new Map<String, Map<String, String>>();
		WRP001_AfterSalesIntervention.mapDMSCurrencyAccessByDossierId_bkp = new Map<String, WRP001_AfterSalesIntervention.DMSCurrencyAccess>();
		WRP001_AfterSalesIntervention.Factures obj81 = new WRP001_AfterSalesIntervention.Factures();
		obj81.clsMain = new WRP001_AfterSalesIntervention();
		WRP001_AfterSalesIntervention.Interventions obj101 = new WRP001_AfterSalesIntervention.Interventions();
		WRP001_AfterSalesIntervention.Pieces obj121 = new WRP001_AfterSalesIntervention.Pieces();
		WRP001_AfterSalesIntervention.Piece obj131 = new WRP001_AfterSalesIntervention.Piece();
		obj131.interventionId		= '214';
		obj131.reference			= '214';
		obj131.referenceLocale		= '214';
		obj131.libelle				= '214';
		obj131.imputationCode		= '214';
		obj131.imputationType		= '214';
		obj131.prixTtc_bkp			= '214';
		obj131.prixTtc				= '214';
		obj131.prixHt_bkp			= '214';
		obj131.prixHt				= '214';
		obj131.quantite				= '214';
		obj131.strSubTotal_bkp		= '214';
		obj131.strSubTotal			= '214';
		WRP001_AfterSalesIntervention.Operations obj141 = new WRP001_AfterSalesIntervention.Operations();
		WRP001_AfterSalesIntervention.Operation obj151 = new WRP001_AfterSalesIntervention.Operation();
		obj151.interventionId		= '24';
		obj151.code					= '24';
		obj151.type					= '24';
		obj151.libelle				= '24';
		obj151.imputationCode		= '24';
		obj151.imputationType		= '24';
		obj151.tempsFacture			= '24';
		obj151.taux					= '24';
		obj151.metier				= '24';
		obj151.technicite			= '24';
		obj151.prixTtc_bkp			= '24';
		obj151.prixTtc				= '24';
		obj151.prixHt_bkp			= '24';
		obj151.prixHt				= '24';
		String str21 = obj151.type;
		String str22 = obj151.prixTtc;
		String str33 = obj151.prixHt;
		WRP001_AfterSalesIntervention.DMSCurrencyAccess obj161 = new WRP001_AfterSalesIntervention.DMSCurrencyAccess(false,'test data', 'asd');
	}
	
	static testMethod void test_Facture(){
		WRP002_AfterSalesIntervention obj01 = new WRP002_AfterSalesIntervention();
		WRP002_AfterSalesIntervention.RechercheDossiersReponse obj11 = new WRP002_AfterSalesIntervention.RechercheDossiersReponse();
		WRP002_AfterSalesIntervention.Dossiers obj21 = new WRP002_AfterSalesIntervention.Dossiers();
		WRP002_AfterSalesIntervention.Dossier obj31 = new WRP002_AfterSalesIntervention.Dossier();
		WRP002_AfterSalesIntervention.Client obj41 = new WRP002_AfterSalesIntervention.Client();
		obj41.id								= '125';
		obj41.idDms								= '125';
		obj41.civilite							= '125';
		obj41.entreprise						= '125';
		obj41.nom								= '125';
		obj41.prenom							= '125';
		obj41.telfixe							= '125';
		obj41.telMobile							= '125';
		obj41.telTravail						= '125';
		obj41.telPreference						= '125';
		obj41.adresseRueNumero					= '125';
		obj41.adresseRueType					= '125';
		obj41.adresseRueNom						= '125';
		obj41.adresseVille						= '125';
		obj41.adresseCodePostal					= '125';
		obj41.adresseComplement1				= '125';
		obj41.adresseComplement2				= '125';
		obj41.adressePays						= '125';
		obj41.email								= '125';
		obj41.contactAcceptation				= '125';
		obj41.compte							= '125';
		obj41.solde								= '125';
		WRP002_AfterSalesIntervention.Vehicule obj51 = new WRP002_AfterSalesIntervention.Vehicule();
		obj51.id					= '243';
		obj51.idDms					= '243';
		obj51.immatriculation		= '243';
		obj51.kilometrage			= '243';
		obj51.kilometrageDate		= '243';
		obj51.entretienType			= '243';
		WRP002_AfterSalesIntervention.VehiculeReferent obj61 = new WRP002_AfterSalesIntervention.VehiculeReferent();
		obj61.vin							= '43';
		obj61.historisationDate				= '43';
		obj61.marqueLibelle					= '43';
		obj61.modeleLibelle					= '43';
		obj61.lcdv							= '43';
		obj61.corvetDate					= '43';
		obj61.miseCirculationDate			= '43';
		obj61.kilometrage					= '43';
		obj61.kilometrageDate				= '43';
		obj61.garantieDateDeb				= '43';
		obj61.garantieDateFin				= '43';
		obj61.garantieVoDateDeb				= '43';
		obj61.garantieVoDateDateFin			= '43';
		obj61.sagaiDate						= '43';
		obj61.pointDeVenteVendeur			= '43';
		WRP002_AfterSalesIntervention.Immatriculations obj71 = new WRP002_AfterSalesIntervention.Immatriculations();
		WRP002_AfterSalesIntervention.Immatriculation obj81 = new WRP002_AfterSalesIntervention.Immatriculation();
		WRP002_AfterSalesIntervention.Interventions obj91 = new WRP002_AfterSalesIntervention.Interventions();
		WRP002_AfterSalesIntervention.Intervention obj101 = new WRP002_AfterSalesIntervention.Intervention();
		WRP002_AfterSalesIntervention.Pieces obj111 = new WRP002_AfterSalesIntervention.Pieces();
		WRP002_AfterSalesIntervention.Piece obj121 = new WRP002_AfterSalesIntervention.Piece();
		obj121.interventionId		= '45';
		obj121.reference			= '45';
		obj121.referenceLocale		= '45';
		obj121.libelle				= '45';
		obj121.imputationCode		= '45';
		obj121.imputationType		= '45';
		obj121.prixTtc				= '45';
		obj121.prixHt				= '45';
		obj121.quantite				= '45';
		WRP002_AfterSalesIntervention.Operations obj131 = new WRP002_AfterSalesIntervention.Operations();
		WRP002_AfterSalesIntervention.Operation obj141 = new WRP002_AfterSalesIntervention.Operation();
		obj141.interventionId		= '67';
		obj141.code					= '67';
		obj141.type					= '67';
		obj141.libelle				= '67';
		obj141.imputationCode		= '67';
		obj141.imputationType		= '67';
		obj141.tempsFacture			= '67';
		obj141.taux					= '67';
		obj141.metier				= '67';
		obj141.technicite			= '67';
		obj141.prixTtc				= '67';
		obj141.prixHt				= '67';
		WRP002_AfterSalesIntervention.Factures obj151 = new WRP002_AfterSalesIntervention.Factures();
		WRP002_AfterSalesIntervention.Facture obj161 = new WRP002_AfterSalesIntervention.Facture();
		obj161.id							= '68';
		obj161.dossierId					= '68';
		obj161.strDate						= '68';
		obj161.kilometrage					= '68';
		obj161.montantClient				= '68';
		obj161.montantGarantie				= '68';
		obj161.montantAssurance				= '68';
		obj161.commentaire					= '68';
	}
}
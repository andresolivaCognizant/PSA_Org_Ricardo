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
global class AfterSalesVehicleInterventionsMock implements HttpCalloutMock{
	
	global Integer intStatusCode;
	
	global AfterSalesVehicleInterventionsMock( Integer intStatusCode ){
		this.intStatusCode						= intStatusCode;
	}

	global HTTPResponse respond( HTTPRequest req ) {
		
		HTTPResponse res						= new HTTPResponse();
		res.setStatusCode( intStatusCode != null ? intStatusCode : 200 );
		res.setStatus( 'OK' ); 
		
		if( intStatusCode != null ){
			res.setBody( '{ "rechercheDossiersReponse": { "statutCode": "0", "statutTexte": "recherche ok [usr = \'MWPC1T02\', vin = \'VF30E9HZHAS167657\', pdv = \'null\']", "dossiers": [ { "dossier": { "id": "709", "idDms": "20622", "pdvId": "148901N", "interventions": [ { "intervention": { "id": "751", "dossierId": "709", "libelle": "CLIENT EN COMPTE", "imputationCode": "6756", "imputationType": "1", "operations": [ { "operation": { "interventionId": "751", "code": "12", "type": "1", "libelle": "LUSTRAGE AILE ARG", "imputationCode": "6756", "imputationType": "1", "tempsFacture": "1", "prixTtc": 67, "prixHt": 56.02 } }, { "operation": { "interventionId": "751", "code": "74E0WA", "type": "1", "libelle": "DESHABILLAGE VOLET AR", "imputationCode": "6756", "imputationType": "1", "tempsFacture": "0.2", "prixTtc": 13.4, "prixHt": 11.2 } }, { "operation": { "interventionId": "751", "code": "90E2JA", "type": "1", "libelle": "DEPOSE/POSE RETROVISEUR G", "imputationCode": "6756", "imputationType": "1", "tempsFacture": "0.7", "prixTtc": 46.9, "prixHt": 39.21 } }, { "operation": { "interventionId": "751", "code": "BAREME", "type": "1", "libelle": "REMISE EN ETAT VOLET AR", "imputationCode": "6756", "imputationType": "1", "tempsFacture": "0.5", "prixTtc": 40.07, "prixHt": 33.5 } } ] } } ], "factures": [ { "facture": { "id": "709", "dossierId": "709", "date": "2012-09-27", "kilometrage": 76570, "montantClient": 1042.48, "montantGarantie": 0, "montantAssurance": 0, "commentaire": "0137427" } } ] } }, { "dossier": { "id": "46870", "idDms": "22121", "pdvId": "148901N", "interventions": [ { "intervention": { "id": "78785", "dossierId": "46870", "libelle": "CLIENT EN COMPTE", "prixTtc": 199, "prixHt": 166.39, "imputationCode": "6756", "imputationType": "1", "pieces": [ { "piece": { "interventionId": "78785", "reference": "1609614180", "libelle": "CARTE SD RNEG E", "imputationCode": "6756", "imputationType": "1", "prixTtc": 199, "prixHt": 166.39, "quantite": 1 } } ] } } ], "factures": [ { "facture": { "id": "46870", "dossierId": "46870", "date": "2012-12-18", "kilometrage": 85852, "montantClient": 199, "montantGarantie": 0, "montantAssurance": 0, "commentaire": "0193322" } } ] } }, { "dossier": { "id": "46871", "idDms": "48645", "pdvId": "148901N", "interventions": [ { "intervention": { "id": "78786", "dossierId": "46871", "libelle": "CLIENT", "prixTtc": 122.56, "prixHt": 102.48, "imputationCode": "9200", "imputationType": "1", "pieces": [ { "piece": { "interventionId": "78786", "reference": "00006490Y2", "libelle": "EMETTEUR", "imputationCode": "9200", "imputationType": "1", "prixTtc": 96.19, "prixHt": 80.43, "quantite": 1 } } ], "operations": [ { "operation": { "interventionId": "78786", "code": "64EH2A", "type": "1", "libelle": "REMPLACEMENT EMETTEUR CONDAMNATION", "imputationCode": "9200", "imputationType": "1", "tempsFacture": "0.3", "prixTtc": 26.37, "prixHt": 22.05 } } ] } } ], "factures": [ { "facture": { "id": "46871", "dossierId": "46871", "date": "2012-06-13", "kilometrage": 65298, "montantClient": 122.56, "montantGarantie": 0, "montantAssurance": 0, "commentaire": "0191008" } } ] } }, { "dossier": { "id": "46872", "idDms": "41368", "pdvId": "148901N", "interventions": [ { "intervention": { "id": "78787", "dossierId": "46872", "libelle": "CLIENT EN COMPTE", "imputationCode": "6756", "imputationType": "1", "operations": [ { "operation": { "interventionId": "78787", "code": "92E0JA", "type": "1", "libelle": "ECHANGE PARE-BRISE", "imputationCode": "6756", "imputationType": "1", "tempsFacture": "0.6", "prixTtc": 38.03, "prixHt": 31.8 } } ] } } ], "factures": [ { "facture": { "id": "46872", "dossierId": "46872", "date": "2011-06-09", "kilometrage": 32394, "montantClient": 645.02, "montantGarantie": 0, "montantAssurance": 0, "commentaire": "0136498" } } ] } } ] } }' );
		
		}else{
			res.setBody( '{ "exception": "exception" }' );
		}
		
		return res;
	}
}
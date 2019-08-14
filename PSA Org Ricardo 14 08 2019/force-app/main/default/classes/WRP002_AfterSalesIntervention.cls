/**
* Salesforce
* @author 			Manuel Medina manuel.medinaperez@ext.mpsa.com
* Project:			AfterSales
* Description:		Wrapper class which represents BVV-Int19B-WS structure.
*
* Changes (Version)
* -------------------------------------
*			No.		Date			Author					Description
*			-----	----------		--------------------	---------------
* @version	1.0		2018-07-27		Manuel Medina (MM)		Initial definition.
*********************************************************************************************************/
public class WRP002_AfterSalesIntervention{
	
	@AuraEnabled public RechercheDossiersReponse rechercheDossiersReponse	{get; set;}
	
	public WRP002_AfterSalesIntervention(){
		this.rechercheDossiersReponse										= new RechercheDossiersReponse();
	}
	
	public class RechercheDossiersReponse {
		@AuraEnabled public String statutCode								{get; set;}
		@AuraEnabled public String statutTexte								{get; set;}
		@AuraEnabled public List<Dossiers> dossiers							{get; set;}
		@AuraEnabled public VehiculeReferent vehiculeReferent				{get; set;}
		
		public RechercheDossiersReponse(){
			this.dossiers													= new List<Dossiers>();
			this.vehiculeReferent											= new VehiculeReferent();
		}
	}
	
	public class Dossiers {
		@AuraEnabled public Dossier dossier									{get; set;}
		
		public Dossiers(){
			this.dossier													= new Dossier();
		}
	}
	
	public class Dossier {
		@AuraEnabled public String id										{get; set;}
		@AuraEnabled public String idDms									{get; set;}
		@AuraEnabled public String idPanier									{get; set;}
		@AuraEnabled public String pdvId									{get; set;}
		@AuraEnabled public Client client									{get; set;}
		@AuraEnabled public Vehicule vehicule								{get; set;}
		//@AuraEnabled public Interventions interventions						{get; set;}
		@AuraEnabled public List<Interventions> interventions				{get; set;}
		//@AuraEnabled public Factures factures								{get; set;}
		@AuraEnabled public List<Factures> factures							{get; set;}
		
		public Dossier(){
			this.client														= new Client();
			this.vehicule													= new Vehicule();
			//this.interventions												= new Interventions();
			this.interventions												= new List<Interventions>();
			//this.factures													= new Factures();
			this.factures													= new List<Factures>();
		}
	}
	
	public class Client {
		@AuraEnabled public String id										{get; set;}
		@AuraEnabled public String idDms									{get; set;}
		@AuraEnabled public String civilite									{get; set;}
		@AuraEnabled public String entreprise								{get; set;}
		@AuraEnabled public String nom										{get; set;}
		@AuraEnabled public String prenom									{get; set;}
		@AuraEnabled public String telfixe									{get; set;}
		@AuraEnabled public String telMobile								{get; set;}
		@AuraEnabled public String telTravail								{get; set;}
		@AuraEnabled public String telPreference							{get; set;}
		@AuraEnabled public String adresseRueNumero							{get; set;}
		@AuraEnabled public String adresseRueType							{get; set;}
		@AuraEnabled public String adresseRueNom							{get; set;}
		@AuraEnabled public String adresseVille								{get; set;}
		@AuraEnabled public String adresseCodePostal						{get; set;}
		@AuraEnabled public String adresseComplement1						{get; set;}
		@AuraEnabled public String adresseComplement2						{get; set;}
		@AuraEnabled public String adressePays								{get; set;}
		@AuraEnabled public String email									{get; set;}
		@AuraEnabled public String contactAcceptation						{get; set;}
		@AuraEnabled public String compte									{get; set;}
		@AuraEnabled public String solde									{get; set;}
	}
	
	public class Vehicule {
		@AuraEnabled public String id										{get; set;}
		@AuraEnabled public String idDms									{get; set;}
		@AuraEnabled public String immatriculation							{get; set;}
		@AuraEnabled public String kilometrage								{get; set;}
		@AuraEnabled public String kilometrageDate							{get; set;}
		@AuraEnabled public String entretienType							{get; set;}
		@AuraEnabled public VehiculeReferent vehiculeReferent				{get; set;}
		
		public Vehicule(){
			this.vehiculeReferent											= new VehiculeReferent();
		}
	}
	
	public class VehiculeReferent {
		@AuraEnabled public String vin										{get; set;}
		@AuraEnabled public String historisationDate						{get; set;}
		@AuraEnabled public String marqueLibelle							{get; set;}
		@AuraEnabled public String modeleLibelle							{get; set;}
		@AuraEnabled public String lcdv										{get; set;}
		@AuraEnabled public String corvetDate								{get; set;}
		@AuraEnabled public String miseCirculationDate						{get; set;}
		@AuraEnabled public String kilometrage								{get; set;}
		@AuraEnabled public String kilometrageDate							{get; set;}
		@AuraEnabled public String garantieDateDeb							{get; set;}
		@AuraEnabled public String garantieDateFin							{get; set;}
		@AuraEnabled public String garantieVoDateDeb						{get; set;}
		@AuraEnabled public String garantieVoDateDateFin					{get; set;}
		@AuraEnabled public String sagaiDate								{get; set;}
		@AuraEnabled public String pointDeVenteVendeur						{get; set;}
		@AuraEnabled public Immatriculations immatriculations				{get; set;}
		
		public VehiculeReferent(){
			this.immatriculations											= new Immatriculations();
		}
	}
	
	public class Immatriculations {
		@AuraEnabled public List<Immatriculation> immatriculation			{get; set;}
		
		public Immatriculations(){
			this.immatriculation											= new List<Immatriculation>();
		}
	}
	
	public class Immatriculation {
		@AuraEnabled public String pays										{get; set;}
		@AuraEnabled public String StrDate									{get; set;}
	}
	
	public class Interventions {
		//@AuraEnabled public List<Intervention> intervention					{get; set;}
		@AuraEnabled public Intervention intervention						{get; set;}
		
		public Interventions(){
			//this.intervention												= new List<Intervention>();
			this.intervention												= new Intervention();
		}
	}
	
	public class Intervention {
		@AuraEnabled public String id										{get; set;}
		@AuraEnabled public String dossierId								{get; set;}
		@AuraEnabled public String panierId									{get; set;}
		@AuraEnabled public String type										{get; set;}
		@AuraEnabled public String libelle									{get; set;}
		@AuraEnabled public String prixTtc									{get; set;}
		@AuraEnabled public String prixHt									{get; set;}
		@AuraEnabled public String forfaitReference							{get; set;}
		@AuraEnabled public String imputationCode							{get; set;}
		@AuraEnabled public String imputationType							{get; set;}
		@AuraEnabled public String commentaire								{get; set;}
		//@AuraEnabled public Pieces pieces									{get; set;}
		@AuraEnabled public List<Pieces> pieces								{get; set;}
		//@AuraEnabled public Operations operations							{get; set;}
		@AuraEnabled public List<Operations> operations						{get; set;}
		
		public Intervention(){
			//this.pieces														= new Pieces();
			this.pieces														= new List<Pieces>();
			//this.operations													= new Operations();
			this.operations													= new List<Operations>();
		}
	}
	
	public class Pieces {
		//@AuraEnabled public List<Piece> piece								{get; set;}
		@AuraEnabled public Piece piece										{get; set;}
		
		public Pieces(){
			//this.piece														= new List<Piece>();
			this.piece														= new Piece();
		}
	}
	
	public class Piece {
		@AuraEnabled public String interventionId							{get; set;}
		@AuraEnabled public String reference								{get; set;}
		@AuraEnabled public String referenceLocale							{get; set;}
		@AuraEnabled public String libelle									{get; set;}
		@AuraEnabled public String imputationCode							{get; set;}
		@AuraEnabled public String imputationType							{get; set;}
		@AuraEnabled public String prixTtc									{get; set;}
		@AuraEnabled public String prixHt									{get; set;}
		@AuraEnabled public String quantite									{get; set;}
	}
	
	public class Operations {
		//@AuraEnabled public List<Operation> operation						{get; set;}
		@AuraEnabled public Operation operation								{get; set;}
		
		public Operations(){
			//this.operation													= new List<Operation>();
			this.operation													= new Operation();
		}
	}
	
	public class Operation {
		@AuraEnabled public String interventionId							{get; set;}
		@AuraEnabled public String code										{get; set;}
		@AuraEnabled public String type										{get; set;}
		@AuraEnabled public String libelle									{get; set;}
		@AuraEnabled public String imputationCode							{get; set;}
		@AuraEnabled public String imputationType							{get; set;}
		@AuraEnabled public String tempsFacture								{get; set;}
		@AuraEnabled public String taux										{get; set;}
		@AuraEnabled public String metier									{get; set;}
		@AuraEnabled public String technicite								{get; set;}
		@AuraEnabled public String prixTtc									{get; set;}
		@AuraEnabled public String prixHt									{get; set;}
	}
	
	public class Factures {
		//@AuraEnabled public List<Facture> facture							{get; set;}
		@AuraEnabled public Facture facture									{get; set;}
		
		public Factures(){
			//this.facture													= new List<Facture>();
			this.facture													= new Facture();
		}
	}
	
	public class Facture {
		@AuraEnabled public String id										{get; set;}
		@AuraEnabled public String dossierId								{get; set;}
		@AuraEnabled public String strDate									{get; set;}
		@AuraEnabled public String kilometrage								{get; set;}
		@AuraEnabled public String montantClient							{get; set;}
		@AuraEnabled public String montantGarantie							{get; set;}
		@AuraEnabled public String montantAssurance							{get; set;}
		@AuraEnabled public String commentaire								{get; set;}
	}
	
	@AuraEnabled public static WRP002_AfterSalesIntervention parse( String strResponse ){
		return ( WRP002_AfterSalesIntervention ) JSON.deserialize( strResponse, WRP002_AfterSalesIntervention.class );
	}
}
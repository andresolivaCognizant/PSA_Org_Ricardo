/*
*   @Class : OpportunityTriggerHandler
*
*   @Author         :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
*   @Created        :   23 feb 2018
*   @Description    :   To manage Opportunity trigger methods

*   ----------------------------------------------------------------------------------------------------------------------------
*      Modification Log :
*   ----------------------------------------------------------------------------------------------------------------------------
*      Developer            Date                     Description
*      Raul Barba           23 feb 2018              Creation.
*      Ruben Moreno         24 oct 2018              API USER dont execute fleet validations.
*   ----------------------------------------------------------------------------------------------------------------------------
*/
public class OpportunityTriggerHandler {
	
	private static boolean runtrigger = true;
	private final static string PROFILE_NAME = [SELECT Id,Name FROM Profile where id = :UserInfo.getProfileId()].Name;
	
	/*
	 * @Method          :   shouldRunTrigger
	 * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   23 feb 2018
	 * @Description     :   To get the flag that indicate if the trigger should run or not
	 * @Params          :   -
	 * @Returns         :   -
	 * @MaxSoqls        :   -
	 * @MaxDmls         :   -
	 */     
	public static boolean shouldRunTrigger() {
		return runtrigger;
	}
	
	/*
	 * @Method          :   dontRunTrigger
	 * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   23 feb 2018
	 * @Description     :   To indicate that the trigger should not run
	 * @Params          :   -
	 * @Returns         :   -
	 * @MaxSoqls        :   -
	 * @MaxDmls         :   -
	 */     
	public static void dontRunTrigger() {
		runtrigger = false;
	}
	
	/*
	 * @Method          :   beforeInsert
	 * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   23 feb 2018
	 * @Description     :   Call the actions that handle the after insert trigger.
	 * @Params          :   Map<Id, User> records after the insert.
	 * @Returns         :   -
	 * @MaxSoqls        :   -
	 * @MaxDmls         :   -
	 */     
	public static void beforeInsert(List<Opportunity> lNewOpportunity) {
		FleetRequestValidations.minParkValidation(lNewOpportunity);
		OpportunityUtils.getDestinationDealer(lNewOpportunity);
		OpportunityUtils.changeRecordTypeToStandardOpp(lNewOpportunity);
		
		if(PROFILE_NAME != Label.API_UserProfileName){
			OpportunityFleetRequestValidations.validateClone(lNewOpportunity);
		}

		/* BEGIN - Manuel Medina - C1STAGILE-7889 - DM: Process to create campaign influence - 20052019 */
		OpportunityUtils.campaignInfluenceProcess( lNewOpportunity, true );
		/* END - Manuel Medina - 20052019 */
	}
	
	 /*
	 * @Method          :   populateFleetDate
	 * @Author          :   Borja Gay Flores
	 * @Created         :   2 Oct 2018
	 * @Description     :   Populates FleetRequestDate__c for Fleet Request Opportunities
	 * @Params          :   List<Opportunity> lstOpp
	 * @Returns         :   -
	 * @MaxSoqls        :   -
	 * @MaxDmls         :   -
	 */     
	public static void populateFleetDate(List<Opportunity> lstOpp) {
		DateTime fleetDate = DateTime.now();
		id rtFleet = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('FleetRequestOpportunity').getRecordTypeId();
		for(Opportunity opp : lstOpp){
			if(opp.RecordTypeId == rtFleet){
				opp.FleetRequestDate__c = fleetDate;
			}
		}
	}
	
	
	
	/*
	 * @Method          :   afterInsert
	 * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   23 feb 2018
	 * @Description     :   Call the actions that handle the after insert trigger.
	 * @Params          :   Map<Id, User> records after the insert.
	 * @Returns         :   -
	 * @MaxSoqls        :   -
	 * @MaxDmls         :   -
	 */     
	public static void afterInsert(List<Opportunity> lNewOpportunity) {
		ManualSharingProcess.ManualSharing(ManualSharingProcess.setRecordToShare(lNewOpportunity));

		/* BEGIN - Manuel Medina - C1STAGILE-7889 - DM: Process to create campaign influence - 20052019 */
		OpportunityUtils.campaignInfluenceProcess( lNewOpportunity, false );
		/* END - Manuel Medina - 20052019 */
	}
	
	/*
	 * @Method          :   beforeUpdate
	 * @Author          :   Raul Barba Tamargo <raul.barba@ext.mpsa.com>
	 * @Created         :   23 feb 2018
	 * @Description     :   Call the actions that handle the before insert trigger.
	 * @Params          :   Map<Id, User> records after the insert.
	 * @Returns         :   -
	 * @MaxSoqls        :   -
	 * @MaxDmls         :   -
	 */     
	public static void beforeUpdate(List<Opportunity> lNewOpportunity, Map<id,Opportunity> MapOldOpportunity) {
		FleetRequestValidations.minParkValidationEdition(lNewOpportunity,MapOldOpportunity);
		OrderFormValidations.OrderFormValidation(lNewOpportunity);
		OpportunityUtils.getDestinationDealer(lNewOpportunity);
		OpportunityUtils.changeRecordTypeToStandardOpp(lNewOpportunity);        
		// US C1STRUN-1266 - BEGIN
		for (Opportunity Opp : lNewOpportunity){
			if(Opp.ownerId != MapOldOpportunity.get(Opp.id).OwnerId && Label.UserOppShare.contains(PROFILE_NAME)){
				OpportunityUtils.shareOAccWthUser(lNewOpportunity);
			}
		}
		// US C1STRUN-1266 - END
				
		if(PROFILE_NAME != Label.API_UserProfileName){
			OpportunityFleetRequestValidations.blockEdition(lNewOpportunity,MapOldOpportunity);
		}

		//individual methods
		if (lNewOpportunity.size() == 1){
			OpportunityUtils.processBUIndividualOpp(
				lNewOpportunity[0],
				MapOldOpportunity.get(lNewOpportunity[0].Id)
			);
		}
	}
}
/**
* Salesforce
* @author              Diego Rincón (DR) href=<diego.rincon@ext.mpsa.com>
* Project:             PSA - Customer First
* Description:         Helper class to handle bussiness logic related to the
*                      WorkshopAppointment__c sObject.
*
* Changes (version)
* -------------------------------------------------------------------------------------------------
*              No.     Date            Author                  Description
*              ----    ------------    --------------------    ------------------------------------
* @version     1.0     2019-03-12      Diego Rincón (DR)       Class creation.
*
*/
public without sharing class WorkshopAppointmentUtils {

	public static void setName(List<WorkshopAppointment__c> lstObj) {
		for (WorkshopAppointment__c w : lstObj) {
			w.Name =  w.ReceptionDatetime__c != null ?
				w.ReceptionDatetime__c.format() :
				System.now().format();
		}
	}

	/**
	* Updates WorkshopAppointmentId__c lookup field on Telealert__c records
	* when a match based on OLB appointment ID is found. C1STAGILE-4588.
	*
	* @author              Diego Rincón
	* @date                2019-03-12
	* @param       lst     workshop appointment records to be matched
	* @return              none
	*/
	public static void matchTelealert(List<WorkshopAppointment__c> lst) {
		Map<String, WorkshopAppointment__c> map_matching = new Map<String, WorkshopAppointment__c>();

		for (WorkshopAppointment__c w : lst) {
			if (String.isNotBlank(w.AppointmentSBId__c)) {
				map_matching.put(w.AppointmentSBId__c, w);
			}
		}

		if (map_matching.isEmpty()) {
			return;
		}

		List<TeleAlert__c> lst_t = new List<TeleAlert__c>([
			SELECT Id, OLBAppointmentId__c, WorkshopAppointmentId__c
			FROM TeleAlert__c
			WHERE
				WorkshopAppointmentId__c = null AND
				OLBAppointmentId__c IN :map_matching.keySet()
		]);

		for (TeleAlert__c t : lst_t) {
			t.WorkshopAppointmentId__c = map_matching.get(t.OLBAppointmentId__c).Id;
		}

		update lst_t;
	}

	public static void setRecurrentPos(List<WorkshopAppointment__c> lst) {
		Set<Id> set_relation_id = new Set<Id>();
		List<AccountContactAssetRelation__c> lst_update = new List<AccountContactAssetRelation__c>();

		for (WorkshopAppointment__c w : lst) {
			if (null != w.TECH_AccountAssetRelation__c) {
				set_relation_id.add(w.TECH_AccountAssetRelation__c);
			}
		}

		Map<Id, AggregateResult> map_relation = new Map<Id, AggregateResult>([
			SELECT TECH_AccountAssetRelation__c Id
			FROM WorkshopAppointment__c
			WHERE TECH_AccountAssetRelation__c IN :set_relation_id
			GROUP BY TECH_AccountAssetRelation__c
			HAVING COUNT(Id) = 1
		]);

		for (WorkshopAppointment__c w : [
			SELECT
				Id,
				Workshop__c,
				TECH_AccountAssetRelation__c,
				TECH_AccountAssetRelation__r.AssetId__r.Brand__c,
				TECH_AccountAssetRelation__r.AssetId__r.OrderId__r.DealerId__c,
				TECH_AccountAssetRelation__r.AccountId__r.PreferredACDealerAPV__pc,
				TECH_AccountAssetRelation__r.AccountId__r.PreferredAPDealerAPV__pc,
				TECH_AccountAssetRelation__r.AccountId__r.PreferredDSDealerAPV__pc
			FROM WorkshopAppointment__c
			WHERE TECH_AccountAssetRelation__c IN :map_relation.keySet()
		]) {
			lst_update.add(getPosInfo(w));
		}

		update lst_update;
	}

	public static AccountContactAssetRelation__c getPosInfo(WorkshopAppointment__c w) {
		AccountContactAssetRelation__c r = new AccountContactAssetRelation__c(
			Id = w.TECH_AccountAssetRelation__c
		);

		switch on w.TECH_AccountAssetRelation__r.AssetId__r.Brand__c {
			when 'AC' {
				if (null != w.TECH_AccountAssetRelation__r.AccountId__r.PreferredACDealerAPV__pc) {
					r.RecurrentPoS__c           = w.TECH_AccountAssetRelation__r.AccountId__r.PreferredACDealerAPV__pc;
					r.MyMPreferredPoS__c        = w.TECH_AccountAssetRelation__r.AccountId__r.PreferredACDealerAPV__pc;
					r.RecurrentPoSDate__c       = System.today();
					r.MyMPreferredPoSDate__c    = System.today();

					if (null != w.TECH_AccountAssetRelation__r.AssetId__r.OrderId__r.DealerId__c) {
						r.LastVisitPoS__c       = w.TECH_AccountAssetRelation__r.AssetId__r.OrderId__r.DealerId__c;
						r.LastVisitPoSDate__c   = System.today();
					}

					return r;
				}
			}

			when 'AP' {
				if (null != w.TECH_AccountAssetRelation__r.AccountId__r.PreferredAPDealerAPV__pc) {
					r.RecurrentPoS__c           = w.TECH_AccountAssetRelation__r.AccountId__r.PreferredAPDealerAPV__pc;
					r.MyMPreferredPoS__c        = w.TECH_AccountAssetRelation__r.AccountId__r.PreferredAPDealerAPV__pc;
					r.RecurrentPoSDate__c       = System.today();

					if (null != w.TECH_AccountAssetRelation__r.AssetId__r.OrderId__r.DealerId__c) {
						r.LastVisitPoS__c       = w.TECH_AccountAssetRelation__r.AssetId__r.OrderId__r.DealerId__c;
						r.LastVisitPoSDate__c   = System.today();
					}
					
					return r;
				}
			}

			when 'DS' {
				if (null != w.TECH_AccountAssetRelation__r.AccountId__r.PreferredDSDealerAPV__pc) {
					r.RecurrentPoS__c           = w.TECH_AccountAssetRelation__r.AccountId__r.PreferredDSDealerAPV__pc;
					r.MyMPreferredPoS__c        = w.TECH_AccountAssetRelation__r.AccountId__r.PreferredDSDealerAPV__pc;
					r.RecurrentPoSDate__c       = System.today();
					r.MyMPreferredPoSDate__c    = System.today();

					if (null != w.TECH_AccountAssetRelation__r.AssetId__r.OrderId__r.DealerId__c) {
						r.LastVisitPoS__c       = w.TECH_AccountAssetRelation__r.AssetId__r.OrderId__r.DealerId__c;
						r.LastVisitPoSDate__c   = System.today();
					}

					return r;
				}
			}

			when else {
				if (null != w.TECH_AccountAssetRelation__r.AssetId__r.OrderId__r.DealerId__c) {
					r.LastVisitPoS__c       = w.TECH_AccountAssetRelation__r.AssetId__r.OrderId__r.DealerId__c;
					r.RecurrentPoS__c       = w.TECH_AccountAssetRelation__r.AccountId__r.PreferredDSDealerAPV__pc;
					r.LastVisitPoSDate__c   = System.today();
					r.RecurrentPoSDate__c   = System.today();
					return r;
				}
			}
		}

		r.LastVisitPoS__c       = w.Workshop__c;
		r.RecurrentPoS__c       = w.Workshop__c;
		r.LastVisitPoSDate__c   = System.today();
		r.RecurrentPoSDate__c   = System.today();
		return r;
	}

	/**
	* C1STAGILE-6916: Updates WorkshopAppointment__c.TECH_SBConfirmation__c if current user is an API User.
	*
	* @author              Diego Rincón
	* @date                2019-03-12
	* @param       lst     workshop appointment records to be matched
	* @return              none
	*/
	public static void validateServiceBoxUpdate( List<WorkshopAppointment__c> lstNewAppointments ){
		for( WorkshopAppointment__c objAppointment : lstNewAppointments ){
			if( !objAppointment.TECH_SBConfirmation__c ){
				objAppointment.TECH_SBConfirmation__c				= PAD.sUserType.equalsIgnoreCase( 'APIUSER' );
			}
		}
	}
}
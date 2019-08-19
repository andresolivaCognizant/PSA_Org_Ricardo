public without sharing class TaskUtils {


	public static final Set<String> CEC_PROFILES;
	public static final User running_user;


	static {
		running_user = [
			SELECT Id, Brand__c, Profile.Name
			FROM User
			WHERE Id = :UserInfo.getUserId()
		].get(0);


		CEC_PROFILES = new Set<String>{
			'System Administrator',
			'CEC_Agent',
			'CEC_Supervisor',
			'CEC_Dealer_Ext',
			'CEC_Dealer_Int'
		};
	}


	public static List<Lead> changeParentLeadStatus(List<Lead> lst) {
		List<Lead> lst_changed_leads = new List<Lead>();
		if (CEC_PROFILES.contains(running_user.Profile.Name)) {
			for (Lead l : lst) {
				if (l.Status == 'New') {
					l.Status = 'On Going';
					lst_changed_leads.add(l);
				}
			}
		}
		return lst_changed_leads;
	}


	/**
	 * Set technical field value for Activity standard object
	 * reporting purposes. C1STAGILE-4962.
	 *
	 * @author              Diego Rincón
	 * @date                2019-04-25
	 * @param       lst     list of task records being upserted
	 * @return              none
	 */
	public static void setActivityType(List<Task> lst) {
		for (Task t : lst) {
			t.TECH_ActivityType__c = t.Type;
		}
	}


	public static void manageLeadCalls(List<Task> lst) {
		Set<Id> set_l = new Set<Id>();
		Set<Id> set_l_cti = new Set<Id>();
		Set<Id> set_l_sucess = new Set<Id>();
		Set<Id> set_l_callback = new Set<Id>();


		for (Task t : lst) {
			if (
				String.isNotBlank(t.WhoId) &&
				Lead.sObjectType == t.WhoId.getSObjectType()
			) {
				set_l.add(t.WhoId);


				// tasks created by cti should be excluded from callback actions
				if (String.isNotBlank(t.Call_DNIS__c)) {
					set_l_cti.add(t.WhoId);
				}


				switch on t.CallStatus__c {
					when '0' {
						// reached
						set_l_sucess.add(t.WhoId);
					}
					when '1' {
						// unreached
						set_l_callback.add(t.WhoId);
					}
				}
			}
		}


		List<Lead> lst_l = new List<Lead>([
			SELECT
				Id,
				FirstName,
				LastName,
				Street,
				City,
				Country,
				PostalCode,
				Latitude,
				Longitude,
				Phone,
				NationalId__c,
				DestinationGeographicalCode__c,
				DestinationPOSCode__c,
				Company,
				BrandOwnedVehicle__c,
				Email,
				LeadCountry__c,
				Activity__c,
				CustomerType__c,
				LeadChannel__c,
				LeadRequestType__c,
				LeadSource,
				LeadType__c,
				CustomerContact__c,
				MarketingCode__c,
				BirthDate__c,
				TECH_DealerPdVInternal__c,
				FiscalId__c,
				VINOwnedVehicle__c,
				MobileProfessionalTelephone__c,
				LandlineProfessionalTelephone__c,
				RecordTypeId,
				LandlinePersonalTelephone__c,
				MobilePersonalTelephone__c,
				Customer__c,
				LocalIdOfCustomer__c,
				CalculatedPOS__c,
				CalculatedPOS__r.AgentFlag__c,
				CalculatedPOS__r.RAFlag__c,
				CalculatedPOS__r.LeadFilters__c,
				CalculatedPOS__r.TECH_AfterSalesManager__c,
				CalculatedPOS__r.TECH_SalesManager__c,
				CalculatedPOS__r.TECH_SalesManagerAgent__c,
				VehicleRegistrationNumber__c,
				PSABrand__c,
				TreatmentDueDate__c,
				OwnerId,
				CreatedDate,
				TECH_Web2Lead__c,
				TECH_Web2LeadAssignment__c,
				(
					Select Id
					FROM Tasks
					WHERE
						TaskSubtype = 'Call' AND
						CallStatus__c = '1'
				)
			FROM Lead
			WHERE Id IN :set_l
		]);


		set_l_callback.removeAll(set_l_sucess);
		set_l_callback.removeAll(set_l_cti);


		insert leadCallbackActions(set_l_callback, new Map<Id, Lead>(lst_l));
		leadCallbackActions(set_l_cti, new Map<Id, Lead>(lst_l));


		closeLeadEvents(set_l_sucess);


		update lst_l;
	}


	/**
	 * Perform bussiness logic when logging calls related to TeleAlert records.
	 * C1STAGILE-8244.
	 *
	 * @author              Diego Rincón
	 * @date                2019-05-09
	 * @param       lst     list of task records being inserted
	 * @return              none
	 */
	public static void manageTeleAlertCalls(List<Task> lst) {
		Set<Id> set_t_callback = new Set<Id>();
		Set<Id> set_t_sucess = new Set<Id>();
		Set<Id> set_t = new Set<Id>();


		for (Task t : lst) {
			if (
				String.isNotBlank(t.WhatId) &&
				TeleAlert__c.sObjectType == t.WhatId.getSObjectType()
			) {
				set_t.add(t.WhatId);


				switch on t.CallStatus__c {
					when '0' {
						// reached
						set_t_sucess.add(t.WhatId);
					}
					when '1' {
						// unreached
						set_t_callback.add(t.WhatId);
					}
				}
			}
		}


		set_t_callback.removeAll(set_t_sucess);


		closeTelealertEvents(set_t_sucess);


		List<TeleAlert__c> lst_t = new List<TeleAlert__c>([
			SELECT
				Id,
				Status__c,
				Brand__c,
				Country__c,
				OwnerId,
				(
					Select Id
					FROM Tasks
					WHERE
						TaskSubtype = 'Call' AND
						CallStatus__c = '1'
				)
			FROM TeleAlert__c
			WHERE Id IN :set_t
		]);


		insert telealertCallbackActions(
			set_t_callback,
			new Map<Id, TeleAlert__c>(lst_t)
		);


		update lst_t;
	}


	public static List<Event> leadCallbackActions(
		Set<Id> set_l,
		Map<Id, Lead> map_l
	) {
		List<Event> ret = new List<Event>();


		// storing leads' onwers to compare against push to dealer results
		Map<Id, Id> map_o = new Map<Id, Id>();
		List<Lead> lst_l = new List<Lead>();


		for (Id key : set_l) {
			if (map_l.containsKey(key)) {
				map_o.put(key, map_l.get(key).OwnerId);


				if (map_l.get(key).Tasks.size() < LeadUtils.getSubsidiaryConfig(map_l.get(key)).CallAttempts__c.intValue()) {
					ret.add(new Event(
						Subject         = 'Call',
						Status__c       = '0',
						WhoId           = key,
						OwnerId         = UserInfo.getUserId(),
						StartDateTime   = System.now().addHours(2).addMinutes(-10),
						EndDateTime     = System.now().addHours(2),
						Priority__c     = 'Normal',
						Type            = 'Call'
					));
					continue;
				}


				// actions to execute if call attemps per subsidiary are exceeded
				if (null == map_l.get(key).CalculatedPOS__c) {
					map_l.get(key).Status                           = 'Nurturing';
					map_l.get(key).LeadQualificationResult__c       = 'Client unreached';
					continue;
				}


				map_l.get(key).Status                           = 'On Going';
				map_l.get(key).LeadQualificationResult__c       = null;
				lst_l.add(map_l.get(key));
			}
		}


		LeadDealerAllocation.setDealerAllocation(lst_l);
		LeadAssigmentProcess.handleAssigmentProcess(lst_l, false, true);


		for (Lead l : lst_l) {
			if (l.OwnerId == map_o.get(l.Id)) {
				l.OwnerId = LeadUtils.getSubsidiaryConfig(l).FallbackQueueId__c;
			}
		}


		return ret;
	}


	public static List<Event> telealertCallbackActions(
		Set<Id> set_t,
		Map<Id, TeleAlert__c> map_t
	) {
		List<Event> ret = new List<Event>();


		for (Id key : set_t) {
			if (
				map_t.containsKey(key) &&
				map_t.get(key).Tasks.size() >= ((Decimal) ((Map<String, Object>) TeleAlertUtils.matchingConfig(map_t.get(key))).get('CallAttempts__c')).intValue()
			) {
				map_t.get(key).Status__c = '4';
				continue;
			}


			if (User.sObjectType == map_t.get(key).OwnerId.getSObjectType()) {
				ret.add(new Event(
					Subject         = 'Call',
					Status__c       = '0',
					WhatId          = key,
					OwnerId         = map_t.get(key).OwnerId,
					StartDateTime   = System.now().addHours(((Decimal) ((Map<String, Object>) TeleAlertUtils.matchingConfig(map_t.get(key))).get('EventStartDateTime__c')).intValue()),
					EndDateTime     = System.now().addHours(((Decimal) ((Map<String, Object>) TeleAlertUtils.matchingConfig(map_t.get(key))).get('EventEndDateTime__c')).intValue()),
					Priority__c     = 'Normal',
					Type            = 'Call'
				));
			}
		}


		return ret;
	}


	public static void closeLeadEvents(Set<Id> set_l) {
		List<Event> lst_e = new List<Event>([
			SELECT Id
			FROM Event
			WHERE
				WhoId IN : set_l AND
				Status__c = '0'
		]);


		for (Event e : lst_e) {
			e.Status__c = '1';
		}


		update lst_e;
	}


	public static void closeTelealertEvents(Set<Id> set_t) {
		List<Event> lst_e = new List<Event>([
			SELECT Id
			FROM Event
			WHERE
				WhatId IN : set_t AND
				Status__c = '0'
		]);


		for (Event e : lst_e) {
			e.Status__c = '1';
		}


		update lst_e;
	}


	public static void updateParentTeleAlertCallCounter(List<Task> lst) {
		Set<Id> set_telealert_id = new Set<Id>();
		List<TeleAlert__c> lst_update = new List<TeleAlert__c>();


		for (Task t : lst) {
			if (
				t.WhatId != null &&
				t.WhatId.getSObjectType() == TeleAlert__c.sObjectType
			) {
				set_telealert_id.add(t.WhatId);
			}
		}


		for (AggregateResult ar : [
			SELECT WhatId Id, COUNT(Id)
			FROM Task
			WHERE
				WhatId IN :set_telealert_id AND
				TaskSubtype = 'Call' AND
				Status = 'Terminé'
			GROUP BY WhatId
		]) {
			lst_update.add(new TeleAlert__c(
				Id = (Id) ar.get('Id'),
				LogCallsCounter__c = (Decimal) ar.get('expr0')
			));
		}
		update lst_update;
	}

	/*********************************************************************************************************
	* @Method			:	getAutomaticContactDaysToDue
	* @Author			:	Ricardo Pereira
	* @Created			:	29/07/2019
	* @Description		:	// TODO 
	* @params			:	// TODO
	* @Returns			:	// TODO
	**********************************************************************************************************/
	public static Decimal getAutomaticContactDaysToDue(String process){

		List<AutomaticContactConfig__mdt> lstConfigs = [SELECT DaysToDue__c FROM AutomaticContactConfig__mdt
											WHERE Brand__c = :PAD.sUserBrand
											AND Country__c = :PAD.sUserCountry
											AND Process__c = :process];

		if(lstConfigs != null && !lstConfigs.isEmpty()){
			return lstConfigs[0].DaysToDue__c;
		}

		return -1;
	}

}
/**
	*   @Class 			: 	APB017_ServiceTerritoryOpHour 
	*
	*   @Author         :   Sergio Lopez
	*   @Created        :   19 Sep 2018
	*   @Description    :   Create Service Territory Operating hours and Service Territory
	*
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Sergio Lopez				19/09/2018				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/ 
global class APB017_ServiceTerritoryOpHour implements Database.Batchable<sObject> {
	 
	global Database.QueryLocator start(Database.BatchableContext BC) {
		System.debug( 'APB017_ServiceTerritoryOpHour start ');
		String query = 'SELECT Id, Dealer__c, Dealer__r.OperatingHoursId, Dealer__r.Description, Dealer__r.BillingAddress, BusinessHourName__c, Name, MondayAMStartTime__c, MondayAMEndTime__c, MondayPMStartTime__c, MondayPMEndTime__c, TuesdayAMStartTime__c, TuesdayAMEndTime__c, TuesdayPMStartTime__c, TuesdayPMEndTime__c, WednesdayAMStartTime__c, WednesdayAMEndTime__c, WednesdayPMStartTime__c, WednesdayPMEndTime__c, ThursdayAMStartTime__c, ThursdayAMEndTime__c, ThursdayPMStartTime__c, ThursdayPMEndTime__c, FridayAMStartTime__c, FridayAMEndTime__c, FridayPMStartTime__c, FridayPMEndTime__c, SaturdayAMStartTime__c, SaturdayAMEndTime__c, SaturdayPMStartTime__c, SaturdayPMEndTime__c, SundayAMStartTime__c, SundayAMEndTime__c, SundayPMStartTime__c, SundayPMEndTime__c '
            + ' FROM BusinessHour__c '
            + ' WHERE CreatedDate < TOMORROW AND Dealer__r.OperatingHoursId = null';            
            System.debug( 'APB017_ServiceTerritoryOpHour query: '+query);
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<BusinessHour__c> scope) {
   		
   		System.debug( 'APB017_ServiceTerritoryOpHour scope: ' + scope);
   		
   		List<BusinessHour__c> lBHours = new List<BusinessHour__c> ();    
   		List<OperatingHours> lOPHours = new List<OperatingHours> ();
   		List<TimeSlot> lTS = new List<TimeSlot> ();  
   		   		
		for(BusinessHour__c l : scope){  
			lBHours.add(l);   
		} 
		
		
		if(!lBHours.isEmpty()){ 
			try {
				System.debug( 'APB017_ServiceTerritoryOpHour bHours: ' + lBHours);
				
				for (integer i=0;i<lBHours.size();i++) {
					OperatingHours oph = new OperatingHours();
					
					System.debug( 'APB017_ServiceTerritoryOpHour Name: ' + lBHours[i].Name+' // '+string.valueof(lBHours[i].Name));
			 		oph.Name = string.valueof(lBHours[i].Name);		
					
					lOPHours.add(oph);	
				}
				
				System.debug( 'APB017_ServiceTerritoryOpHour lOPHours: ' + lOPHours);
				
				Map<String,OperatingHours> mapOPHours	= new Map<String,OperatingHours>();
				
				Database.SaveResult[] srList = Database.insert(lOPHours, true);
				
				// Iterate through each returned result
				for (Database.SaveResult sr : srList) {
				    if (sr.isSuccess()) {
				        // Operation was successful, so get the ID of the record that was processed
				        System.debug('Successfully inserted OpH ID: ' + sr.getId());
				        System.debug('Successfully inserted OpH: ' + sr);
				        System.debug('Successfully inserted lOPHours: ' + lOPHours);
				    }
				    else {
				        // Operation failed, so get all errors                
				        for(Database.Error err : sr.getErrors()) {
				            System.debug('The following error has occurred.');                    
				            System.debug(err.getStatusCode() + ': ' + err.getMessage());
				            System.debug('Account fields that affected this error: ' + err.getFields());
				        }
				    }
				}
				
				for (OperatingHours op : lOPHours) {
					mapOPHours.put(op.Name,op);
				}
				
				System.debug( 'APB017_ServiceTerritoryOpHour mapOPHours: ' + mapOPHours);
				
				Integer count = 0;
				
				for (BusinessHour__c bh : lBHours) {					 
					count = 0; 
					
					while (count < 14) {
						TimeSlot ts = new TimeSlot();
						
						if (mapOPHours.containsKey( bh.Name ) ){
							ts.OperatingHoursId = mapOPHours.get( bh.Name ).Id; 
						}
						System.debug( 'APB017_ServiceTerritoryOpHour ts.OperatingHoursId: ' + ts.OperatingHoursId);
						
						switch on count {
							//Monday AM
							when 0 {
								System.debug('Count M AM: '+count);
								ts.DayOfWeek = 'Monday';
				 				ts.StartTime = bh.MondayAMStartTime__c;
				 				ts.EndTime   = bh.MondayAMEndTime__c;
				 				
				 				System.debug( 'APB017_ServiceTerritoryOpHour Monday AM: ' + ts.DayOfWeek +' // '+ts.StartTime+' // '+ts.EndTime); 
							}	
							//Monday PM
							when 1 { 
								System.debug('Count M PM: '+count);
								ts.DayOfWeek = 'Monday';
				 				ts.StartTime = bh.MondayPMStartTime__c;
				 				ts.EndTime   = bh.MondayPMEndTime__c;	
				 				
				 				System.debug( 'APB017_ServiceTerritoryOpHour Monday PM: ' + ts.DayOfWeek +' // '+ts.StartTime+' // '+ts.EndTime); 
							}
							//Tuesday AM
							when 2 {
								System.debug('Count Tu AM: '+count);
								ts.DayOfWeek = 'Tuesday';
				 				ts.StartTime = bh.TuesdayAMStartTime__c;
				 				ts.EndTime   = bh.TuesdayAMEndTime__c;
				 				
				 				System.debug( 'APB017_ServiceTerritoryOpHour Tuesday AM: ' + ts.DayOfWeek +' // '+ts.StartTime+' // '+ts.EndTime); 
							}
				 			//Tuesday PM
							when 3 { 
								System.debug('Count Tu PM: '+count);
								ts.DayOfWeek = 'Tuesday';
				 				ts.StartTime = bh.TuesdayPMStartTime__c;
				 				ts.EndTime   = bh.TuesdayPMEndTime__c;
				 				
				 				System.debug( 'APB017_ServiceTerritoryOpHour Tuesday PM: ' + ts.DayOfWeek +' // '+ts.StartTime+' // '+ts.EndTime);
							}
				 			//Wednesday AM
							when 4 {
								
								ts.DayOfWeek = 'Wednesday';
				 				ts.StartTime = bh.WednesdayAMStartTime__c;
				 				ts.EndTime   = bh.WednesdayAMEndTime__c;
				 				
				 				System.debug( 'APB017_ServiceTerritoryOpHour Wednesday AM: ' + ts.DayOfWeek +' // '+ts.StartTime+' // '+ts.EndTime);
							}
				 			//Wednesday PM
							when 5 {
								ts.DayOfWeek = 'Wednesday';
				 				ts.StartTime = bh.WednesdayPMStartTime__c;
				 				ts.EndTime   = bh.WednesdayPMEndTime__c;
				 				
				 				System.debug( 'APB017_ServiceTerritoryOpHour Wednesday PM: ' + ts.DayOfWeek +' // '+ts.StartTime+' // '+ts.EndTime);
							}
				 			//Thursday AM
							when 6 {
								ts.DayOfWeek = 'Thursday';
				 				ts.StartTime = bh.ThursdayAMStartTime__c;
				 				ts.EndTime   = bh.ThursdayAMEndTime__c;
				 				
				 				System.debug( 'APB017_ServiceTerritoryOpHour Thursday AM: ' + ts.DayOfWeek +' // '+ts.StartTime+' // '+ts.EndTime);
							}
				 			//Thursday PM
							when 7 {
								ts.DayOfWeek = 'Thursday';
				 				ts.StartTime = bh.ThursdayPMStartTime__c;
				 				ts.EndTime   = bh.ThursdayPMEndTime__c;
				 				
				 				System.debug( 'APB017_ServiceTerritoryOpHour Thursday PM: ' + ts.DayOfWeek +' // '+ts.StartTime+' // '+ts.EndTime);
							}
				 			//Friday AM
							when 8 {
								ts.DayOfWeek = 'Friday';
				 				ts.StartTime = bh.FridayAMStartTime__c;
				 				ts.EndTime   = bh.FridayAMEndTime__c;
				 				
				 				System.debug( 'APB017_ServiceTerritoryOpHour Friday AM: ' + ts.DayOfWeek +' // '+ts.StartTime+' // '+ts.EndTime);
							}
				 			//Friday PM
							when 9 {
								ts.DayOfWeek = 'Friday';
				 				ts.StartTime = bh.FridayPMStartTime__c;
				 				ts.EndTime   = bh.FridayPMEndTime__c;
				 				
				 				System.debug( 'APB017_ServiceTerritoryOpHour Friday PM: ' + ts.DayOfWeek +' // '+ts.StartTime+' // '+ts.EndTime);
							}
				 			//Saturday AM
							when 10 {
								ts.DayOfWeek = 'Saturday';
				 				ts.StartTime = bh.SaturdayAMStartTime__c;
				 				ts.EndTime   = bh.SaturdayAMEndTime__c;
				 				
				 				System.debug( 'APB017_ServiceTerritoryOpHour Saturday AM: ' + ts.DayOfWeek +' // '+ts.StartTime+' // '+ts.EndTime);
							}
				 			//Saturday PM
							when 11 {
								ts.DayOfWeek = 'Saturday';
				 				ts.StartTime = bh.SaturdayPMStartTime__c;
				 				ts.EndTime   = bh.SaturdayPMEndTime__c;
				 				
				 				System.debug( 'APB017_ServiceTerritoryOpHour Saturday PM: ' + ts.DayOfWeek +' // '+ts.StartTime+' // '+ts.EndTime);
							}
				 			//Sunday AM
							when 12 {
								ts.DayOfWeek = 'Sunday';
				 				ts.StartTime = bh.SundayAMStartTime__c;
				 				ts.EndTime   = bh.SundayAMEndTime__c;	
				 				
				 				System.debug( 'APB017_ServiceTerritoryOpHour Sunday AM: ' + ts.DayOfWeek +' // '+ts.StartTime+' // '+ts.EndTime);
							}
				 			//Sunday PM
							when 13 {
								ts.DayOfWeek = 'Sunday';
				 				ts.StartTime = bh.SundayPMStartTime__c;
				 				ts.EndTime   = bh.SundayPMEndTime__c;	 
				 				
				 				System.debug( 'APB017_ServiceTerritoryOpHour Sunday PM: ' + ts.DayOfWeek +' // '+ts.StartTime+' // '+ts.EndTime);
							}
						} 
						
						System.debug('APB017_ServiceTerritoryOpHour ts: '+ts);
						lTS.add(ts);
						
    					System.debug('Count: '+count);
    					count++;
					}			 		
				}
				
				System.debug('lTS SIZE: '+lTS.size());
				
				Integer j = 0;
				
				while (j < lTS.size()){
					if (lTS.get(j).StartTime == null){
						System.debug('APB017_ServiceTerritoryOpHour lTS: ' + lTS);
						lTS.remove(j);
					} else {
						j++;
					}
				}
				
				insert lTS;	
				
				List<ServiceTerritory> lST = new List<ServiceTerritory> (); 
				
				String name;
				
				for (BusinessHour__c bh : lBHours){
					ServiceTerritory st = new ServiceTerritory ();
					
					st.Account__c = bh.Dealer__c;
					st.IsActive = true; 
					/*st.Address.city	= bh.Dealer__r.BillingAddress.city;
					st.Address.country = bh.Dealer__r.BillingAddress.country;
					st.Address.geocodeAccuracy = bh.Dealer__r.BillingAddress.geocodeAccuracy;	
					st.Address.latitude	= bh.Dealer__r.BillingAddress.latitude;
					st.Address.longitude = bh.Dealer__r.BillingAddress.longitude;	
					st.Address.postalCode = bh.Dealer__r.BillingAddress.postalCode;	
					st.Address.state = bh.Dealer__r.BillingAddress.state;
					st.Address.street = bh.Dealer__r.BillingAddress.street;*/
					st.Description = bh.Dealer__r.Description;
					st.Name = bh.Name; 
					
					System.debug('APB017_ServiceTerritoryOpHour mapOPHours.get( name ).Id: ' + mapOPHours.get( bh.Name ).Id);
					if (mapOPHours.containsKey( bh.Name ) ){
						st.OperatingHoursId = mapOPHours.get( bh.Name ).Id; 
					}
					
					lST.add(st); 
				}
				
				System.debug('APB017_ServiceTerritoryOpHour lST: ' + lST);
				insert lST;
				
				
				List<Account> accToUpd = new List<Account> (); 
				
				for (ServiceTerritory st : lST){
					Account acc = new Account ();
					
					acc.Id = st.Account__c;
					acc.OperatingHoursId = st.OperatingHoursId;  
					
					accToUpd.add(acc); 
				}
				
				System.debug('APB017_ServiceTerritoryOpHour accToUpd: ' + accToUpd);
				update accToUpd;
				
			} catch(dmlexception e) {
		    	string error = 'DMLexception ERROR APB017_ServiceTerritoryOpHour --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
		    	system.debug('Error: '+error);
	        }  catch(exception e){
	        	string error = 'Exception ERROR APB017_ServiceTerritoryOpHour --> ' + e.getMessage() + ' Line: '+e.getLineNumber();
	            system.debug('Error: '+error);
	        } 
		}			
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}
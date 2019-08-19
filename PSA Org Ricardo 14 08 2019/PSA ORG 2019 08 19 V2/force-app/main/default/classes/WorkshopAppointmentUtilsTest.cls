/**
	*   @Class 			: WorkshopAppointmentUtilsTest
	*   @Author         : Pedro Párraga
	*   @Created        : 10 Juli 2019
	*   @Description    : Test for WorkshopAppointmentUtils
	*
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Pedro Párraga			10/06/2019				 Creation.		
	*   ----------------------------------------------------------------------------------------------------------------------------
**/

@isTest
private class WorkshopAppointmentUtilsTest {

	@testSetup static void setup(){

        Account accDealer = new Account(
                Name                =   'TEST MATCH',
                Phone               =   '+843434',
                BillingPostalCode   =   '23456',
                FiscalId__c         =   '30.686.957-4',
                RecordTypeiD        =   PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_DEALER),
                TECH_PublicGroups__c=   userInfo.getUserId(),
				Country__c			= 'ES'
        );
        
        insert accDealer;

        List<Account> lstAcc = new List<Account>();

        Account acc = new Account(
            Salutation			= 	'1',
            FirstName			=	'azerty',
            LastName			=	'Doe REVOKE ACCESS V1',
            PersonalEmail__pc	=	'test@gmail.com',
            BillingPostalCode	=	'73451',
            NationalId__pc		=	'30.686.957-4',
            BillingStreet       =   '45 upper east side',
            APAnonymization__pc	=	true,
            ACAnonymization__pc	=	true,
            DSAnonymization__pc	=	true,
            RecordTypeId		=	PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA),
			Country__c			= 'ES'
        );

        lstAcc.add(acc);

        Account accAP = new Account(
            Salutation			= 	'1',
            FirstName			=	'azerty u',
            LastName			=	'Doe REVOKE ACCESS V1',
            PersonalEmail__pc	=	'test@gmail.com',
            BillingPostalCode	=	'73452',
            NationalId__pc		=	'30.686.957-4',
            BillingStreet       =   '45 upper east side',
            APAnonymization__pc	=	true,
            ACAnonymization__pc	=	true,
            DSAnonymization__pc	=	true,
            RecordTypeId		=	PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA),
            Brand__c			=	'AP',
            PreferredAPDealerAPV__pc = accDealer.Id,
			Country__c			= 'ES'
        );

        lstAcc.add(accAP);

        Account accAC = new Account(
            Salutation			= 	'1',
            FirstName			=	'azerty d',
            LastName			=	'Doe REVOKE ACCESS V1',
            PersonalEmail__pc	=	'test@gmail.com',
            BillingPostalCode	=	'73453',
            NationalId__pc		=	'30.686.957-4',
            BillingStreet       =   '45 upper east side',
            APAnonymization__pc	=	true,
            ACAnonymization__pc	=	true,
            DSAnonymization__pc	=	true,
            RecordTypeId		=	PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA),
            Brand__c			=	'AC',
            PreferredACDealerAPV__pc = accDealer.Id,
			Country__c			= 'ES'
        );

        lstAcc.add(accAC);

        Account accDS = new Account(
            Salutation			= 	'1',
            FirstName			=	'azerty t',
            LastName			=	'Doe REVOKE ACCESS V1',
            PersonalEmail__pc	=	'test@gmail.com',
            BillingPostalCode	=	'73454',
            NationalId__pc		=	'30.686.957-4',
            BillingStreet       =   '45 upper east side',
            APAnonymization__pc	=	true,
            ACAnonymization__pc	=	true,
            DSAnonymization__pc	=	true,
            RecordTypeId		=	PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA),
            Brand__c			=	'DS',
            PreferredDSDealerAPV__pc = accDealer.Id,
			Country__c			= 'ES'
        );

        lstAcc.add(accDS);

        Account accNoDealer = new Account(
            Salutation			= 	'1',
            FirstName			=	'azerty',
            LastName			=	'Doe REVOKE ACCESS V1',
            PersonalEmail__pc	=	'test@gmail.com',
            BillingPostalCode	=	'73456',
            NationalId__pc		=	'30.686.957-4',
            BillingStreet       =   '45 upper east side',
            APAnonymization__pc	=	true,
            ACAnonymization__pc	=	true,
            DSAnonymization__pc	=	true,
            RecordTypeId		=	PAD.recordTypesMapByDeveloperName.get(Constants.RT_ACCOUNT_B2C_PA),
			Country__c			= 'ES'
        );

        lstAcc.add(accNoDealer);

        insert lstAcc;

        List<order> lstOrders = new List<Order>();

		Order ord = new Order(
			AccountId = acc.Id,
			EffectiveDate = System.today(),
			Status = '8',
			OrderId__c = '123456788',
			LCDV16__c = '0123456789abcdef',
			DealerId__c = accDealer.Id
		);

		lstOrders.add(ord);

		Order ordNoDealer = new Order(
			AccountId = accNoDealer.Id,
			EffectiveDate = System.today(),
			Status = '8',
			OrderId__c = '123456789',
			LCDV16__c = '0123456789abcdeg'
		);

		lstOrders.add(ordNoDealer);

		insert lstOrders;

		List<Asset> lstAsset = new List<Asset>();

         Asset asse = new Asset(
            Name                = 'Test Vehicle',
            AssetType__c        = 'VN',
            CurrencyIsoCode     = 'EUR',
            AccountId           = acc.Id,
            LastKnownRegistrationNumber__c = '1',
            VIN__c                         = 'VF7DDMSD0DJ64496M',
            OrderId__c					   = ord.Id
        );

        lstAsset.add(asse);

         Asset asseAC = new Asset(
            Name                = 'Test Vehicle 1',
            AssetType__c        = 'VN',
            CurrencyIsoCode     = 'EUR',
            AccountId           = accAC.Id,
            LastKnownRegistrationNumber__c = '1',
            VIN__c                         = 'VF7DDMSD0DJ64497M',
            Brand__c					   = 'AC'
        );

        lstAsset.add(asseAC);

         Asset asseAP = new Asset(
            Name                = 'Test Vehicle 2',
            AssetType__c        = 'VN',
            CurrencyIsoCode     = 'EUR',
            AccountId           = accAP.Id,
            LastKnownRegistrationNumber__c = '1',
            VIN__c                         = 'VF7DDMSD0DJ64498M',
            Brand__c					   = 'AP'
        );

        lstAsset.add(asseAP);

         Asset asseDS = new Asset(
            Name                = 'Test Vehicle 3',
            AssetType__c        = 'VN',
            CurrencyIsoCode     = 'EUR',
            AccountId           = accDS.Id,
            LastKnownRegistrationNumber__c = '1',
            VIN__c                         = 'VF7DDMSD0DJ64499M',
            Brand__c					   = 'DS'
        );

        lstAsset.add(asseDS);

         Asset asseNoDealer = new Asset(
            Name                = 'Test Vehicle 4',
            AssetType__c        = 'VN',
            CurrencyIsoCode     = 'EUR',
            AccountId           = accNoDealer.Id,
            LastKnownRegistrationNumber__c = '1',
            VIN__c                         = 'VF7DDMSD0DJ64490M',
            OrderId__c					   = ordNoDealer.Id
        );

        lstAsset.add(asseNoDealer);

        insert lstAsset;


	}

	public static List<Asset> getAsset(String parameter){
		return new List<Asset>([SELECT Id, Brand__c, OrderId__r.DealerId__c FROM Asset WHERE Brand__c =:parameter]);
	}

	public static List<Account> getAccount(String parameter){
		return new List<Account> ([SELECT Id, Brand__c FROM Account WHERE BillingPostalCode =: parameter]);
	}

	public static List<AccountContactAssetRelation__c> getAccountContactAssetRelation(String parameter){
		return new List<AccountContactAssetRelation__c> ([SELECT Id, RecurrentPoSDate__c FROM AccountContactAssetRelation__c WHERE AccountId__c =: parameter]);
	}

	
	@isTest static void WorkshopAppointmentUtils() {
		List<Account> lstAcc = getAccount('73451');
		List<Asset> lstAss = getAsset(null);
		List<AccountContactAssetRelation__c> lstR = getAccountContactAssetRelation(lstAcc[0].Id);	

		WorkshopAppointment__c w = new WorkshopAppointment__c(
	        Driver__c = lstAcc[0].Id,
	        Asset__c = lstAss[0].Id,
	        TECH_AccountAssetRelation__c = lstR[0].Id,
	        AppointmentSBId__c = '210918a1F'
	    );

	    Test.startTest();
	    	insert w;
            lstR = getAccountContactAssetRelation(lstAcc[0].Id);
            System.assertEquals(lstR[0].RecurrentPoSDate__c, System.today());
	    Test.stopTest();	
	}

	@isTest static void WorkshopAppointmentUtilsAP() {
		List<Account> lstAcc = getAccount('73452');
		List<Asset> lstAss = getAsset('AP');
		List<AccountContactAssetRelation__c> lstR = getAccountContactAssetRelation(lstAcc[0].Id);	

		WorkshopAppointment__c w = new WorkshopAppointment__c(
	        Driver__c = lstAcc[0].Id,
	        Asset__c = lstAss[0].Id,
	        TECH_AccountAssetRelation__c = lstR[0].Id,
	        AppointmentSBId__c = '220918a1F'
	    );

	    Test.startTest();
	    	insert w;
            lstR = getAccountContactAssetRelation(lstAcc[0].Id);
            System.assertEquals(lstR[0].RecurrentPoSDate__c, System.today());
	    Test.stopTest();	
	}

	@isTest static void WorkshopAppointmentUtilsAC() {
		List<Account> lstAcc = getAccount('73453');
		List<Asset> lstAss = getAsset('AC');
		List<AccountContactAssetRelation__c> lstR = getAccountContactAssetRelation(lstAcc[0].Id);	

		WorkshopAppointment__c w = new WorkshopAppointment__c(
	        Driver__c = lstAcc[0].Id,
	        Asset__c = lstAss[0].Id,
	        TECH_AccountAssetRelation__c = lstR[0].Id,
	        AppointmentSBId__c = '220918a1F'
	    );

        Test.startTest();
            insert w;
            lstR = getAccountContactAssetRelation(lstAcc[0].Id);
            System.assertEquals(lstR[0].RecurrentPoSDate__c, System.today());
        Test.stopTest();	
	}

	@isTest static void WorkshopAppointmentUtilsDS() {
		List<Account> lstAcc = getAccount('73454');
		List<Asset> lstAss = getAsset('DS');
		List<AccountContactAssetRelation__c> lstR = getAccountContactAssetRelation(lstAcc[0].Id);	

		WorkshopAppointment__c w = new WorkshopAppointment__c(
	        Driver__c = lstAcc[0].Id,
	        Asset__c = lstAss[0].Id,
	        TECH_AccountAssetRelation__c = lstR[0].Id,
	        AppointmentSBId__c = '220918a1F'
	    );

        Test.startTest();
            insert w;
            lstR = getAccountContactAssetRelation(lstAcc[0].Id);
            System.assertEquals(lstR[0].RecurrentPoSDate__c, System.today());
        Test.stopTest();	
	}

	@isTest static void WorkshopAppointmentUtilsNoBrand() {
		List<Account> lstAcc = getAccount('73456');
		List<Asset> lstAss = getAsset(null);
		List<AccountContactAssetRelation__c> lstR = getAccountContactAssetRelation(lstAcc[0].Id);	

		String idAsset;

		for(Asset asse : lstAss){
			if(asse.OrderId__r.DealerId__c == null){
				System.debug('aa Id: '+ asse.Id);
				System.debug('aa Brand__c: '+ asse.Brand__c);
				idAsset = asse.Id;
			}
		}

		WorkshopAppointment__c w = new WorkshopAppointment__c(
	        Driver__c = lstAcc[0].Id,
	        Asset__c = idAsset,
	        TECH_AccountAssetRelation__c = lstR[0].Id,
	        AppointmentSBId__c = '220918a1F'
	    );

	    Test.startTest();
		    try{
                insert w;
                lstR = getAccountContactAssetRelation(lstAcc[0].Id);
                System.assertEquals(lstR[0].RecurrentPoSDate__c, System.today());
		    }catch(Exception e){

		    }
	    Test.stopTest();	
	}

    /******************************************************************************************************
	* @Method			: validateServiceBoxUpdateTest
	* @Author			: Manuel Medina
	* @Created			: 08/07/2019
	* @Description		: Test for validateServiceBoxUpdate method.
	******************************************************************************************************/
	public static testMethod void validateServiceBoxUpdateTest() {
		User objUser								= [SELECT Id FROM User WHERE Profile.Name = 'Api_Users' AND IsActive = true LIMIT 1];
		Account objAccount							= [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'PersonAccount_B2C' LIMIT 1];
		Asset objAsset								= [SELECT Id FROM Asset LIMIT 1];

		WorkshopAppointment__c objAppointment		= new WorkshopAppointment__c();
		objAppointment.Name							= 'WAP0002';
		objAppointment.Owner__c						= objAccount.Id;
		objAppointment.Driver__c					= objAccount.Id;
		objAppointment.Asset__c						= objAsset.Id;
		objAppointment.AppointmentRepeatRepair__c	= true;
		objAppointment.AppointmentStatus__c			= '5';
		objAppointment.RestitutionDateTime__c		= System.today().addDays( -1 );
		objAppointment.TECH_SBConfirmation__c		= false;
		
		insert objAppointment;

		Test.startTest();
			System.runAs( objUser ){
				update objAppointment;
			}
		Test.stopTest();

		System.assertEquals( true, [SELECT Id FROM WorkshopAppointment__c WHERE TECH_SBConfirmation__c = true].isEmpty() );
	}
}
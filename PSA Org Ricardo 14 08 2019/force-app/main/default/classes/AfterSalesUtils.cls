public class AfterSalesUtils {
    
    private final static String APV_MD_DEFAULT_VALUE            = 'ALL';
    private final static Integer KMDDV_MIN_THRESHOLD        	= 100;
    private final static Integer DDV_DDG_DIFF_THRESHOLD     	= 30;
    private final static Integer KMC_MAX_THRESHOLD          	= 1000;
    


    // wrapper class to calculate and store data related to an asset, required to perform daily mileage calculations
    public class WrapperMileageInfo {
        public Date ddv         {get; set;}
        public Date ddg         {get; set;}
        public Decimal kmddv    {get; set;}
        public Integer rule     {get; set;}

        public WrapperMileageInfo(Asset a) {
            // set default values
            this.ddv    = null;
            this.ddg    = a.TECH_DebutDate__c;
            this.kmddv  = 0.0;
            this.rule   = 2;

            // assign values if data is enough
            
            getVehicleMileage(this, a);
            getMileageRule(this);
        }
    }
    
    
    /*
     * @Method          : getVehicleMileage
     * @Author          : Diego Rincón
     * @Created         : 16 may 2018
     * @Description     : Calculate vehicle last known mileage value (KMDDV) and date (DDV) pair values.
     * @Params          : WrapperMileageInfo instance, Asset record.
     * @Returns         : None.
     */
    public static void getVehicleMileage(WrapperMileageInfo w, Asset a) {
        if (
            null != a.RealMileageDate__c &&
            null != a.LastAPVVisitDate__c &&
            0 < a.RealMileage__c &&
            0 < a.LastAPVVisitMileage__c
        ) {
            if (a.RealMileageDate__c >= a.LastAPVVisitDate__c) {
                w.ddv       = a.RealMileageDate__c;
                w.kmddv     = a.RealMileage__c.intValue();
                return;
            } else {
                w.ddv       = a.LastAPVVisitDate__c;
                w.kmddv     = a.LastAPVVisitMileage__c.intValue();
                return;
            }
        }

        if (null != a.RealMileageDate__c && 0 < a.RealMileage__c) {
            w.ddv       = a.RealMileageDate__c;
            w.kmddv     = a.RealMileage__c.intValue();
            return;
        }

        if (null != a.LastAPVVisitDate__c && 0 < a.LastAPVVisitMileage__c) {
            w.ddv       = a.LastAPVVisitDate__c;
            w.kmddv     = a.LastAPVVisitMileage__c.intValue();
            return;
        }

    }

    /*
     * @Method          : getMileageRule
     * @Author          : Diego Rincón
     * @Created         : 17 may 2018
     * @Description     : Determine daily estimated mileage calculation rule for an
     *                    instance of the WrapperMileageInfo class.
     * @Params          : WrapperMileageInfo instance.
     * @Returns         : None.
     */
    public static void getMileageRule(WrapperMileageInfo w) {
        if (
            null != w.ddv &&
            null != w.ddg &&
            0 < w.kmddv &&
            KMDDV_MIN_THRESHOLD <= w.kmddv &&
            DDV_DDG_DIFF_THRESHOLD < w.ddg.daysBetween(w.ddv) &&
            KMC_MAX_THRESHOLD > getKmc(w)
        ) {
            w.rule = 1;
        }
    }

    /*
     * @Method          : setMileageValues
     * @Author          : Diego Rincón
     * @Created         : 22 may 2018
     * @Description     : Assign asset's mileage fields from a WrapperMileageInfo instance. 
     * @Params          : WrapperMileageInfo instance, Asset record, Mileage per energy code table.
     * @Returns         : None.
     */
    public static void setMileageValues(WrapperMileageInfo w, Asset a, Map<String, APV_Mileage_Per_Energy__mdt> m) {
      
        switch on w.rule {
            when 1 {
                a.DailyEstimatedMileage__c = getKmc(w);
            }
            when 2 {
                a.DailyEstimatedMileage__c = getKmme(a, m);
            }
        }
    }

    /*
     * @Method          : getKmme
     * @Author          : Diego Rincón
     * @Created         : 17 may 2018
     * @Description     : Calculate estimated average mileage per asset (KMME) 
     * @Params          : Single Asset record, Mileage per energy code table
     * @Returns         : None.
     */
    public static Integer getKmme(Asset v, Map<String, APV_Mileage_Per_Energy__mdt> m) {
        System.debug('Energy table: ' + m);

        String strBrand         = null;
        String strEnergyCode    = null;
        if (String.isNotBlank(v.Brand__c)) {
            strBrand = v.Brand__c.trim();
            if (String.isNotBlank(v.EnergyCode__c)) {
                strEnergyCode = strBrand + v.EnergyCode__c.trim();
            }
        }

        if(null!= strEnergyCode && null != m.get(strEnergyCode)) {
            return m.get(strEnergyCode).Daily_Estimated_Mileage__c.intValue();
        }

        if(null != strBrand && null != m.get(strBrand)) {
            return m.get(strBrand).Daily_Estimated_Mileage__c.intValue();
        }

        return m.get(APV_MD_DEFAULT_VALUE).Daily_Estimated_Mileage__c.intValue();
    }

    /*
     * @Method          : getKmc
     * @Author          : Diego Rincón
     * @Created         : 17 may 2018
     * @Description     : Calculate average mileage per asset (KMC) 
     * @Params          : Single WrapperMileageInfo instance with required values
     * @Returns         : None.
     */
    public static Decimal getKmc(WrapperMileageInfo w) {
        Decimal dblKmc = w.kmddv / w.ddg.daysBetween(w.ddv);
        System.debug('### Asset\'s KMC: ' + dblKmc);
        return dblKmc.setscale(2);
    }

  
    /*********************************************************************************************************
    * @Method          :   vehiclePossessionUpdate
    * @Author          :   Diego Rincón
    * @Created         :   08/05/2018
    * @Description     :   Updatea AccountRole__c for all assets related to the AccountRelationMap
    * @params	       :   Map<Id,AccountContactAssetRelation__c>, Map<Id, String>
    * @Returns         :   void
    -- Date         Author              Version  Comments
    -- -----------  -------------       -------  ---------------------------------------
    -- 08/05/2018   Diego Rincón        1.0       ...
    -- 28/06/2019   Nerea Leguinazabal  1.1       Changed the method to be shyncronous and simplified DML operations
    **********************************************************************************************************/

    public static void vehiclePossessionUpdate (Map<Id,AccountContactAssetRelation__c> accountRelationMap, Map<Id, String> m){
        
        // assets related to input records
        List<Id> lstAsset =new List<Id>();
        
        // related records to be updated
        List<AccountContactAssetRelation__c> lstUpdate
            = new List<AccountContactAssetRelation__c>();
       
        for (AccountContactAssetRelation__c accountRelation: accountRelationMap.values()) {
            lstAsset.add(accountRelation.AssetId__c);
        }

        //Go over the AccountContactAssetRelation__c related to the relationships that tiggered the method
        for (AccountContactAssetRelation__c r : [SELECT Id, AccountRole__c, AssetId__c, RelationEndDate__c FROM AccountContactAssetRelation__c WHERE Id NOT IN :accountRelationMap.keyset() AND AssetId__c IN :lstAsset]) {
            String strOldRole = r.AccountRole__c;
            String strNewRole = r.AccountRole__c;
            
            if (null != m.get(r.AssetId__c)) {
                AssetRelationTriggerHandler.getNewRoleVal(m.get(r.AssetId__c), r);
                strNewRole = r.AccountRole__c;
            }

            if (strNewRole != strOldRole) {
                lstUpdate.add(r);
            }
            
        }
        if (!lstUpdate.isEmpty()) {
            //TODO:Validate CRUD Permission
            update lstUpdate;
        }
        
    }
}
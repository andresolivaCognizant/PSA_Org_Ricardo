/*-----------------------------------------------------------------------------------------------------------//
  * Class Name    : CareStaticVariables
  * Project       : PSA - C1ST
  * Author        : Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
  * Date          : 07/02/2019
  * Description   : This class aims to store results of operations or queries that are common in a transaction,
  * 				avoid executing the same operation several times and reduce the number of queries
  *-----------------------------------------------------------------------------------------------------------
  *      Modification Log :
  *-----------------------------------------------------------------------------------------------------------
  *      Developer                Date                     Description    
  *      Carmen Henandez         07/02/2019                Creation.      
  *      Carmen Hernandez        07/16/2019                Add method getCaseAssignmentRules
  *-----------------------------------------------------------------------------------------------------------*/
public class CareStaticVariables {
    
    //private static variable referencing the class
    private static CareStaticVariables instance = null;
    
    //Cache Case PicklistValues
    private static Map<String, String> mapPicklistValues = new Map<String, String>();
    private static Set<String> picklistNames = new Set<String>();
    //Cache Anonymous Accounts
    private static Set<String> anonymousKeys = new Set<String>();
    private Map<String, Id> anonymousAccsByCountry = new Map<String, Id>();
	//Cache Assets
    private static Set<String> setVINs = new Set<String>();
	private static Map<String, Asset> assetsByVINs = new Map<String, Asset>();
    //Cache Business Hours
    private static Map<String,Id> mapBusinessHoursCEC = new Map<String,String>();
	private static Set<String> setNamesBH = new Set<String>();
    //Cache Case Assignment Rules
    private static Map<String, AssignmentRule> mapAsssignmentRules = new Map<String, AssignmentRule>();
	private static Set<String> setNameAssignmentRules = new Set<String>();    

  	/*********************************************************************************************************
    * @Method          :   getInstance
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/02/2019
    * @Description     :   This method is responsible for creating its class unique instance in case it is not
    *                      created yet and to return that instance.
    * @params	       :   void
    * @Returns         :   CareStaticVariables instance of CareStaticVariables
    **********************************************************************************************************/
    public static CareStaticVariables getInstance(){
        // only initialize if it doesn't already exist
        if (instance == null) {
            instance = new CareStaticVariables ();
        }
        return instance;
    }

  	/*********************************************************************************************************
    * @Method          :   getPicklistValues
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/04/2019
    * @Description     :   This method creates a map with the values/labels of the Case picklists
    * @params	       :   String picklistName: API Name of the picklist
	* @params		   :   String keyPicklist: Key name to include in the values of the picklist
	* @params		   :   Boolean: if true then .getDescribe() method will be executed else records from cache 
    *                      will be returned.
    * @Returns         :   Map<String, String> : Map with the values/labels of the case picklists
    **********************************************************************************************************/
	public Map<String, String> getPicklistValues(String picklistName, String keyPicklist, Boolean clearCache){
		if (!picklistNames.contains(picklistName) || clearCache) {            
            for (Schema.PicklistEntry picklistVal : Case.getSObjectType().getDescribe().fields.getMap().get(picklistName).getDescribe().getPickListValues()) {
                mapPicklistValues.put(keyPicklist+picklistVal.getValue(), picklistVal.getLabel());
            }
            picklistNames.add(picklistName);
		}
		return mapPicklistValues;
	}
    
  	/*********************************************************************************************************
    * @Method          :   getAnonymousAccount
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/02/2019
    * @Description     :   This method obtains the anonymous accounts necessary for cases created from the chat
    * @params	       :   Set<String>: filtered by TECH_IntegrationExtId__c
	* @params		   :   Boolean: if true then soql will be executed else records from cache will be returned.
    * @Returns         :   Map<String, Account>: map{countryName, anonymousAccount}
    **********************************************************************************************************/
	public Map<String,Id> getAnonymousAccsByCountry(Set<String> accountsTofilter, Boolean clearCache){
		if (!anonymousKeys.containsAll(accountsTofilter) || clearCache) {
			for(Account objAcc :  [SELECT Id, Country__c FROM Account WHERE TECH_IntegrationExtId__c IN: accountsTofilter]) {
				anonymousAccsByCountry.put(objAcc.Country__c, objAcc.Id);
			}
			anonymousKeys.addAll(accountsTofilter);
		}
		return anonymousAccsByCountry;
	}

  	/*********************************************************************************************************
    * @Method          :   getAssetsByVINs
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/02/2019
    * @Description     :   This method obtains assets filtered by VINs
    * @params	       :   Set<String>: filterVINs
	* @params		   :   Boolean: if true then soql will be executed else records from cache will be returned.
    * @Returns         :   Map<String, Asset>: map{VIN, Asset}
    **********************************************************************************************************/
	public Map<String, Asset> getAssetsByVINs(Set<String> filterVINs, Boolean clearCache){
		if(!setVINs.containsAll(filterVINs) || clearCache){
			for(Asset objAsset :  [SELECT Id, VIN__c FROM Asset WHERE VIN__c IN: filterVINs]){
				assetsByVINs.put(objAsset.VIN__c.toUpperCase(), objAsset);
			}
			setVINs.addAll(filterVINs);
		}
		return assetsByVINs;
	}
    
  	/*********************************************************************************************************
    * @Method          :   getBusinessHoursByName
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/02/2019
    * @Description     :   This method obtains the Business Hours
    * @params	       :   String: Filtered by the name of the Business Hours (ex: 'CEC%')
	* @params		   :   Boolean: if true then soql will be executed else records from cache will be returned.
    * @Returns         :   Map<String, Id>: map{NameBusinessHours, IdBusinessHours}
    **********************************************************************************************************/
    public Map<String, Id> getBusinessHoursByName(String filterName, Boolean clearCache){
        if(!setNamesBH.contains(filterName) || clearCache){
            for(BusinessHours bh : [SELECT Id, Name FROM BusinessHours WHERE Name LIKE: filterName]){
                mapBusinessHoursCEC.put(bh.Name,bh.Id);
            }
            setNamesBH.add(filterName);
        }
        return mapBusinessHoursCEC;
    }

  	/*********************************************************************************************************
    * @Method          :   getCaseAssignmentRules
    * @Author          :   Carmen Hernandez <carmen.diazhernandez@ext.mpsa.com>
    * @Created         :   07/16/2019
    * @Description     :   This method obtains the Case Assignment Rules
    * @params	       :   String: Filtered by the name of the Case Assginment Rule
	* @params		   :   Boolean: if true then soql will be executed else records from cache will be returned.
    * @Returns         :   Map<String, AssignmentRule>
    **********************************************************************************************************/
    public Map<String, AssignmentRule> getCaseAssignmentRules(String filterName, Boolean clearCache){
        if(!setNameAssignmentRules.contains(filterName) || clearCache){
            for(AssignmentRule objAssignmentRule : [SELECT Id, Name FROM AssignmentRule 
                                                        WHERE SobjectType =: CareConstants.CASE_OBJECT_NAME AND 
                  	                                    Active = true AND Name =: filterName]){
                mapAsssignmentRules.put(objAssignmentRule.Name, objAssignmentRule);
            }
            setNameAssignmentRules.add(filterName);
        }
        return mapAsssignmentRules;
    }
}
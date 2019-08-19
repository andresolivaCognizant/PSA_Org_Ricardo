/**
	*   @Class 			: 	CancelOrderForm 
	*
	*   @Author         :   Ruben Moreno
	*   @Created        :   28 Nov 2018
	*   @Description    :   Cancel order form
	*
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Modification Log :
	*   ----------------------------------------------------------------------------------------------------------------------------
	*      Developer           		Date                     Description	
	*	   Ruben Moreno				28/11/2018				 Creation.		
	*      Sergio Lopez				15/04/1979               C1STAGILE-8192: when an Order Form is manually cancelled, 
    *                                                        its related Quote is moved back from status "With Order Form" to "Active".
    *                                                        The process of changing the Status of the quote now should take into account that:
    *
    *                                                              · If the Expiration Date of the Quote has not passed, the Quote should be moved back to "Active"
    *                                                              · If the Expiration Date of the Quote has passed, the Quote should be moved back to "Expired"
    *      Gema Santiago            30/05/2019               C1ST-18363: when an Order Form is canceled, its Quote status will change to "Expired" if expiration date has passed
    *
	*   ----------------------------------------------------------------------------------------------------------------------------
**/
public with sharing class CancelOrderForm {

    private final static string FAMILY_VERSION          = Label.ProductFamilyVersion;

    public static void mainFunction(
        List<SBQQ__Quote__c> lst_new,
        Map<Id, SBQQ__Quote__c> map_old
    ){
        // cancelled order forms ids
        Set<Id> set_o = new Set<Id>();

        // cancelled order forms' parent quotes ids
        Set<Id> set_q = new Set<Id>();
        
        // Valid Record Type Ids
        Set<Id> setRT = new Set<Id>();
        
        for (RecordType orderRType : [SELECT Id FROM RecordType WHERE Name IN ('CPQ Order Form','OPV Order Form','OPV OrderForm VD','OPV OrderForm VN','OPV OrderForm VO')]){
            setRT.add(orderRType.Id);
        }

        for (SBQQ__Quote__c q : lst_new) {
            if(
                setRT.contains(q.RecordTypeId) &&
                q.SBQQ__Status__c == '7' &&
                q.SBQQ__Status__c != map_old.get(q.Id).SBQQ__Status__c
            ){
                set_o.add(q.Id);
                if (null != q.QuotesWithOrderForms__c) {
                    set_q.add(q.QuotesWithOrderForms__c);
                }
            }
        }

        removeProductFlag(set_o);
        updateParentQuote(set_q);

    }

    /**
     * Remove WithOrderForm__c flag from product records no longer related to
     * active order forms.
     *
     * @author              Diego Rincón
     * @date                2019-01-22
     * @param   of_ids      set of canceled order form ids
     * @return              none
     */
    public static void removeProductFlag(Set<Id> of_ids) {

        if (of_ids.isEmpty()) {
            return;
        }

        // family version products related to cancelled order forms
        Map<Id,Product2> map_p = new Map<Id,Product2>([
            SELECT Id, WithOrderForm__c
            FROM Product2
            WHERE
                Family = :FAMILY_VERSION AND 
                WithOrderForm__c = true AND
                    Id IN (
                    SELECT Product__c
                    FROM OrderFormLine__c
                    WHERE OrderForm__c IN :of_ids
                )
        ]);

        if (map_p.isEmpty()) {
            return;
        }

        // map of products found which are still related to active order forms
        Map<Id, AggregateResult> map_s = new Map<Id, AggregateResult>([
            SELECT Product__c Id
            FROM OrderFormLine__c
            WHERE
                Product__c IN :map_p.keySet() AND 
                OrderForm__r.SBQQ__Status__c != '7'
            GROUP BY Product__c
        ]);

        // list of products whose flag should be removed
        List<Product2> lst_p = new List<Product2>();

        for (Product2 p : map_p.values()) {
            if (!map_s.containsKey(p.Id)) {
                lst_p.add(new Product2(
                    Id                  = p.Id,
                    WithOrderForm__c    = false
                ));
            }
        }

        update lst_p;
    }

    /**
     * Update quote records status to 'Active' when no active order forms
     * related to them are left.
     *
     * @author              Diego Rincón
     * @date                2019-01-22
     * @param   q_ids       set of canceled order forms' parent quote ids
     * @return              none
     */
    public static void updateParentQuote(Set<Id> q_ids) {

        if (q_ids.isEmpty()) {
            return;
        }

        // map of quotes still related to non-canceled order forms (Live Quotes)
        Map<Id, AggregateResult> map_q = new Map<Id, AggregateResult>([
            SELECT QuotesWithOrderForms__c Id
            FROM SBQQ__Quote__c
            WHERE
                QuotesWithOrderForms__c IN :q_ids AND
                SBQQ__Status__c != '7' AND
                QuotesWithOrderForms__r.SBQQ__Status__c != '2' 
                AND QuotesWithOrderForms__r.SBQQ__ExpirationDate__c >= TODAY
            GROUP BY QuotesWithOrderForms__c
        ]);

        // map of quotes still related to non-canceled order forms (NON live Quotes)
        Map<Id, AggregateResult> map_qNonLive = new Map<Id, AggregateResult>([
            SELECT QuotesWithOrderForms__c Id
            FROM SBQQ__Quote__c
            WHERE
                QuotesWithOrderForms__c IN :q_ids AND
                SBQQ__Status__c != '7' AND
                QuotesWithOrderForms__r.SBQQ__Status__c != '2'  
                AND QuotesWithOrderForms__r.SBQQ__ExpirationDate__c < TODAY
            GROUP BY QuotesWithOrderForms__c
        ]);

        // list of quotes whose status should be updated
        List<SBQQ__Quote__c> lst_q = new List<SBQQ__Quote__c>();

        for (Id key : q_ids) {
            if (!map_q.containsKey(key)) {
                lst_q.add(new SBQQ__Quote__c(
                    Id                  = key,
                    SBQQ__Status__c     = '2'
                ));
            }
        }

        update lst_q;
        
        lst_q.clear();
        List<ID> lst_qIDs = new List<ID>();
        for (Id key : q_ids) {
            if (!map_qNonLive.containsKey(key)) {
                lst_qIDs.add(key);
            } 
        }

         List<SBQQ__Quote__c> lst_qToCheck = new List<SBQQ__Quote__c>([SELECT ID , SBQQ__ExpirationDate__c 
            FROM SBQQ__Quote__c WHERE ID IN :lst_qIDs AND SBQQ__Status__c = '2' AND SBQQ__ExpirationDate__c < TODAY]);

         for(SBQQ__Quote__c q:lst_qToCheck){
            q.SBQQ__Status__c='6';
         }

        update lst_q;
    }
}
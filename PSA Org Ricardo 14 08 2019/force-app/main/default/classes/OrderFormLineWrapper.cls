/**
 * Salesforce
 * @author              Diego Rincón (DR) href=<diego.rincon@ext.mpsa.com>
 * Project:             PSA - Customer First
 * Description:         Wrapper class with the comparable interface to sort a list of
 *                      OrderFormLine__c records based on ProductFamily__c field,
 *                      taking into account the priority given in C1ST-8752.
 *
 * Changes (version)
 * -------------------------------------------------------------------------------------------------
 *              No.     Date            Author                  Description
 *              ----    ------------    --------------------    ------------------------------------
 * @version     1.0     2019-01-23      Diego Rincón (DR)       Class creation.
 *
 */

global class OrderFormLineWrapper implements Comparable {

    private Integer sort_order;
    public Integer index {get; set;}
    public OrderFormLine__c obj {get; set;}

    // constructor
    public OrderFormLineWrapper(Integer i, OrderFormLine__c l) {
        this.index      = i;
        this.obj        = l;
        this.sort_order = QuoteExpensesController.map_priority.containsKey(l.ProductFamily__c) ?
            QuoteExpensesController.map_priority.get(l.ProductFamily__c) :
            0;
    }

    // implement the compareTo() method
    public Integer compareTo(Object compareTo) {
        OrderFormLineWrapper p = (OrderFormLineWrapper)compareTo;
        if (this.sort_order == p.sort_order) return 0;
        if (p.sort_order == 0) return -1;
        if (this.sort_order > p.sort_order || this.sort_order == 0) return 1;
        return -1;
    }
}
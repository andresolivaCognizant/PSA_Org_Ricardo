/**
 * Salesforce
 * @author              Diego Rincón (DR) href=<diego.rincon@ext.mpsa.com>
 * Project:             PSA - Customer First
 * Description:         Wrapper class with the comparable interface to sort a list of User records
 *                      based on its related contact's TECH_CounterSalesman__c field.
 *
 * Changes (version)
 * -------------------------------------------------------------------------------------------------
 *              No.     Date            Author                  Description
 *              ----    ------------    --------------------    ------------------------------------
 * @version     1.0     2019-02-12      Diego Rincón (DR)       Class creation.
 *
 */
global class LoadPerUserWrapper implements Comparable {
    public final Id user_id {get; private set;}
    public Integer lead_count {get; set;}

    // constructor
    global LoadPerUserWrapper(User u) {
        this.user_id = u.Id;
        if (
            null == u.Contact.TECH_CounterSalesman__c ||
            u.Contact.TECH_CounterSalesman__c < 1
        ) {
            this.lead_count = 0;
        } else {
            this.lead_count = u.Contact.TECH_CounterSalesman__c.intValue();
        }
    }

    // implement the compareTo() method
    public Integer compareTo(Object compareTo) {
        LoadPerUserWrapper w = (LoadPerUserWrapper) compareTo;
        // this instance and objectToCompareTo are equal
        if (this.lead_count == w.lead_count) {
            return 0;
        }

        // this instance is greater than objectToCompareTo
        if (this.lead_count > w.lead_count) {
            return 1;
        }

        // this instance is less than objectToCompareTo
        return -1;
    }
}
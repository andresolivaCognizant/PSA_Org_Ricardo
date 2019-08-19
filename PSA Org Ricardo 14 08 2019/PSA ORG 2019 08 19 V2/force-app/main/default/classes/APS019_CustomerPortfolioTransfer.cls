/**
 * Salesforce
 * @author              Diego Rincón (DR) href=<diego.rincon@ext.mpsa.com>
 * Project:             PSA - Customer First
 * Description:         Scheduler for APB019_CustomerPortfolioTransfer bathchable class.
 *
 * Changes (version)
 * -------------------------------------------------------------------------------------------------
 *              No.     Date            Author                  Description
 *              ----    ------------    --------------------    ------------------------------------
 * @version     1.0     2018-11-30      Diego Rincón (DR)       Class creation.
 */

public class APS019_CustomerPortfolioTransfer implements Schedulable {

    public void execute(SchedulableContext sc) {
        APB019_CustomerPortfolioTransfer bch = new APB019_CustomerPortfolioTransfer();
        Database.executeBatch(bch, 200);
    }

}
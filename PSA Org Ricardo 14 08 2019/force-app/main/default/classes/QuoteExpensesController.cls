public class QuoteExpensesController {

    public static final Map<String, Integer> map_priority = new Map<String, Integer>{
        'Version'       => 1,
        'Color'         => 2,
        'Interior'      => 3,
        'Options'       => 4,
        'Accesories'    => 5,
        'Services'      => 6
    };

    transient public SBQQ__Quote__c q {get; private set;}
    public String strExpenses {get; private set;}
    public List<String> lstParams {get; private set;}
    public List<PaymentRow> lstPayment {get; private set;}
    public List<ExpensesRow> lstExpenses {get; private set;}
    public List<OrderFormLineWrapper> lstOrderFormLine {get; private set;}
    public List<OrderFormLineRow> lstServices {get; private set;}


    public QuoteExpensesController() {
        Id quoteId  = ApexPages.currentPage().getParameters().get('qid');

        strExpenses         = '';
        lstParams           = new List<String>();
        lstPayment          = new List<PaymentRow>();
        lstExpenses         = new List<ExpensesRow>();
        lstOrderFormLine    = new List<OrderFormLineWrapper>();
        lstServices         = new List<OrderFormLineRow>();

        for (String key : ApexPages.currentPage().getParameters().keySet()) {
            lstParams.add(key + ' :' + ApexPages.currentPage().getParameters().get(key));
        }

        q = [
            SELECT Id, CurrencyIsoCode, ExpensesTotalDiscountAmount__c, CPQTotalExpenses__c, TotalPayments__c,
            (
                SELECT
                    Id,
                    toLabel(FeeType__c),
                    Quote__c,
                    Price__c,
                    DiscountToApply__c,
                    DiscountToApplyAmount__c,
                    TotalToPay__c,
                    CurrencyIsoCode,
                    TotalDiscountAmount__c
                FROM Expenses__r
            ),
            (
                SELECT
                    Id,
                    CDC__c,
                    ProductName__c,
                    ProductFamily__c,
                    Quantity__c,
                    ListPrice__c,
                    PriceVATIncluded__c,
                    CurrencyIsoCode
                FROM OrderFormLines__r
                ORDER BY Product__r.Is_Bundle__c DESC
            ),
            (
                SELECT
                    Id,
                    PaymentAmount__c,
                    Payment_Method__c,
                    DueDateDocument__c,
                    Financial_Institution__c,
                    PaymentDocumentNumber__c
                FROM Payments__r
            )
            FROM SBQQ__Quote__c
            WHERE Id =: quoteId
        ];

        Integer i = 0;

        for (Expenses__c e : q.Expenses__r) {
            i++;
            lstExpenses.add(new ExpensesRow(i, e));
            strExpenses += e.FeeType__c + ', ';
        }

        strExpenses = strExpenses.trim().removeEnd(',');

        i = 0;

        for (OrderFormLine__c l : q.OrderFormLines__r) {
            i++;
            if ('Standard Equipment' != l.ProductFamily__c) {
                lstOrderFormLine.add(new OrderFormLineWrapper(i, l));
            }

            if('Services' == l.ProductFamily__c) {
                lstServices.add(new OrderFormLineRow(i, l));
            }
        }

        i = 0;

        lstOrderFormLine.sort();

        for (OrderFormLineWrapper w : lstOrderFormLine) {
            i ++;
            w.index = i;
        }
        
        i = 0;

        for (Payment__c p : q.Payments__r) {
            i++;
            lstPayment.add(new PaymentRow(i, p));
        }

    }

    public class ExpensesRow {
        public Integer index {get; set;}
        public Expenses__c obj {get; set;}

        public ExpensesRow(Integer i, Expenses__c e) {
            this.index = i;
            this.obj = e;
        }
    }
    
    public class OrderFormLineRow {
        public Integer index {get; set;}
        public OrderFormLine__c obj {get; set;}

        public OrderFormLineRow(Integer i, OrderFormLine__c l) {
            this.index = i;
            this.obj = l;
        }
    }

    public class PaymentRow {
        public Integer index {get; set;}
        public Payment__c obj {get; set;}
        public String formattedDueDate {get; set;}

        public PaymentRow(Integer i, Payment__c p) {
            this.index = i;
            this.obj = p;
            this.formattedDueDate = null == p.DueDateDocument__c ?
                null : p.DueDateDocument__c.format();
        }
    }

}
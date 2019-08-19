public with sharing class NewQuoteController {
    public final Flow.Interview.NewQuote flowInterview {get; set;}
    public NewQuoteController(ApexPages.StandardController stdController) {}
    public String getFinishLoc() { 
         return flowInterview==null? 'home/home.jsp': flowInterview.QuoteID; 
    }
     Public PageReference getFinishPageRef(){
        PageReference pageRef = new PageReference('/' + getfinishLoc());
        pageRef.setRedirect(true);
        return pageRef;
    }
}
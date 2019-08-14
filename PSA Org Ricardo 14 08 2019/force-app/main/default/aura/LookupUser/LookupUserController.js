({
	doInit : function(component,event,helper){
		 //helper.getUserLeadCounts(component, event);
	},
	 
	onfocus : function(component,event,helper){
		var forOpen = component.find("searchRes");

		$A.util.addClass(forOpen, 'slds-is-open');
		$A.util.removeClass(forOpen, 'slds-is-close');

		var getInputkeyWord = '';
		var getWhereClause = component.get('v.whereSearch');

		helper.searchHelper(component,event,getInputkeyWord,getWhereClause);
	},
		
	lostFocus: function(component,event,helper){
		var forOpen = component.find("searchRes");

		if(component.get("v.listOfSearchRecords")!=null){
			var lengthSearchRecords = component.get("v.listOfSearchRecords").length;
			if(lengthSearchRecords == 0){    
					$A.util.addClass(forOpen, 'slds-is-close');
					$A.util.removeClass(forOpen, 'slds-is-open');
			}
		}

		if ((component.get("v.dropdown")) == false) {
			$A.util.addClass(forOpen, 'slds-is-close');
			$A.util.removeClass(forOpen, 'slds-is-open');
		}
	},
		
	handleMouseEnter: function(component,event,helper) {
		component.set("v.dropdown",true);
	},
	
	handleMouseLeave: function(component,event,helper) {
		component.set("v.dropdown",false);
	},
	
	keyPressController : function(component, event, helper) {
		var getInputkeyWord = component.get("v.SearchKeyWord");
		var getWhereClause = component.get('v.whereSearch');

		if( getInputkeyWord.length > 0 ){
			var forOpen = component.find("searchRes");
			$A.util.addClass(forOpen, 'slds-is-open');
			$A.util.removeClass(forOpen, 'slds-is-close');
			helper.searchHelper(component,event,getInputkeyWord,getWhereClause);
		
		}else{  
			component.set("v.listOfSearchRecords", null ); 
			var forclose = component.find("searchRes");
			$A.util.addClass(forclose, 'slds-is-close');
			$A.util.removeClass(forclose, 'slds-is-open');
		}
	}, 
	
	clear :function(component,event,heplper){
		var pillTarget = component.find("lookup-pill");
		var lookUpTarget = component.find("lookupField"); 

		$A.util.addClass(pillTarget, 'slds-hide');
		$A.util.removeClass(pillTarget, 'slds-show');
		$A.util.addClass(lookUpTarget, 'slds-show');
		$A.util.removeClass(lookUpTarget, 'slds-hide');

		component.set("v.SearchKeyWord",null);
		component.set("v.listOfSearchRecords", null );
		component.set("v.selectedRecord", {} );
	},

	handleComponentEvent : function(component, event, helper) {	 
		var selectedRecord = event.getParam("recordByEvent");  
		component.set("v.selectedRecord" , selectedRecord);
			
		var forclose = component.find("lookup-pill");
		$A.util.addClass(forclose, 'slds-show');
		$A.util.removeClass(forclose, 'slds-hide');

		var forclose = component.find("searchRes");
		$A.util.addClass(forclose, 'slds-is-close');
		$A.util.removeClass(forclose, 'slds-is-open');

		var lookUpTarget = component.find("lookupField");
		$A.util.addClass(lookUpTarget, 'slds-hide');
		$A.util.removeClass(lookUpTarget, 'slds-show'); 
	},

	hideSpinner : function (component, event, helper) {
		var spinner = component.find('spinner');
		var evt = spinner.get("e.toggle");

		evt.setParams({ isVisible : false });
		evt.fire();    
	},

	showSpinner : function (component, event, helper) {
		var spinner = component.find('spinner');
		var evt = spinner.get("e.toggle");
		
		evt.setParams({ isVisible : true });
		evt.fire();    
	},
})
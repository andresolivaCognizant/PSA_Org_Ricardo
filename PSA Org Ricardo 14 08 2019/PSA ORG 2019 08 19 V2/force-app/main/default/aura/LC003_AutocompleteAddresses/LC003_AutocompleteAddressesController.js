({    
    doInit: function(component,event,helper){
        component.set("v.listOfSearchRecords", null ); 
        helper.closeTagClass(component,'searchRes');
    },
    onfocus: function(component,event,helper){
        helper.openTagClass(component,'searchRes');
    },
    lostFocus: function(component,event,helper){
        // var forOpen = component.find("searchRes");
        if(component.get("v.listOfSearchRecords")!=null){
          var lengthSearchRecords = component.get("v.listOfSearchRecords").length;
          if(lengthSearchRecords == 0){    
            helper.closeTagClass(component,'searchRes');
          }
        }
        if ((component.get("v.dropdown")) == false) {
            helper.closeTagClass(component,'searchRes');
        }
    },
	handleMouseEnter: function(component,event,helper) {
		component.set("v.dropdown",true);
	},
	handleMouseLeave: function(component,event,helper) {
		component.set("v.dropdown",false);
	},
    keyPressController : function(component, event, helper) {
       // get the search Input keyword   
		var getInputkeyWord = component.get("v.searchKey");     
        if( getInputkeyWord.length > 0 ){
            helper.openTagClass(component,'searchRes');
            helper.displayOptionsLocation(component, getInputkeyWord , $A.get("$Locale.language"));
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
            helper.closeTagClass(component,'searchRes');
        }
	},
    clear: function (component, event, helper) {
        helper.clearComponentConfig(component);
    },
	selectRecord : function(component, event, helper){
        console.log('selectRecord click');
    	var selectedItem 	= event.currentTarget.dataset.record;
        var selectedPlaceId = event.currentTarget.dataset.placeid;

        component.set("v.selectedOption", selectedItem);
        var searchLookup 	= component.find("searchRes");
        $A.util.removeClass(searchLookup, 'slds-is-open');
        var iconDirection 	= component.find("iconDirection");
        $A.util.removeClass(iconDirection, 'slds-input-has-icon_left');
        $A.util.addClass(iconDirection, 'slds-input-has-icon_right');
        component.set("v.searchKey", selectedItem);
		helper.getRouteOptionDetails(component,selectedPlaceId,$A.get("$Locale.language"));
    }
})
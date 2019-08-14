({
    doInit: function (component,event,helper){
        helper.userInfo(component,event);
        helper.getPickListVal(component,'CategoryL1__c','v.optionsType');
        helper.getPickListVal(component,'Reason','v.optionsSupportWith');
        helper.getPickListVal(component,'CaseSurveyAcceptance__c','v.surveyValues');
        helper.getPickListVal(component,'TECH_PhoneCountryCode__c','v.phoneCodeValues');
       
        
        var urlForm = (window.location.href).toString();
        if(urlForm.includes("peugeot")){
            component.set("v.brandAtrib","AP");
        }
        else if(urlForm.includes("citroen")){
            component.set("v.brandAtrib","AC");
        }
        else if(urlForm.includes("ds")){ 
            component.set("v.brandAtrib","DS");
        }
    },
    
    openModel: function(component, event, helper) {
        // for Display Model,set the "isOpen" attribute to "true"
        component.set("v.isOpen", true);
    },
    
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.showLoadingSpinner", false);
        component.set("v.isDisabled",false);
        component.set("v.isOpen", false);
    },
    
    getCaseNumberAlert : function (component,event,helper){
        var isSolved = component.get("v.solved");
        var caseNumber = component.get("v.caseNumber");
        if(!isSolved){
            component.set("v.isDisabled",false);
            var alertText =$A.get("$Label.c.CWF_AlertACK");
            var finalAlert = alertText.replace('#CASENUMBER',caseNumber);
            alert(finalAlert);
            component.set("v.showLoadingSpinner", false);
        }
        var urlForm = (window.location.href).toString();
        var urlHome = (urlForm.split("/case-web-form"));
        window.open(urlHome[0],"_self");
    },
    
    doValidate: function(component, event, helper) {
        component.set('v.hasErrors',false);
        component.set("v.showLoadingSpinner", true);
        component.set("v.isDisabled",true);      
        helper.validateForm(component,event);
    },
    
    doSave : function(component,event,helper){
        component.set('v.isDisabledModal',true);
        helper.insertCase(component,event,'1');
    },
    
    doSaveSolved : function(component,event,helper){
        component.set('v.isDisabledModal',true);
        component.set("v.solved",true);
        helper.insertCase(component,event,'7');
    },
    
    setSelectedCat : function(component,event,helper){
        var selectedValue = event.getParam("value");
        component.set("v.selectedcat",selectedValue);
    },
    
    setSelectedReq : function(component,event,helper){
        var selectedValue = event.getParam("value");
        component.set("v.selectedreq",selectedValue);
    },
    
    setSelectedSurvey : function (component,event,helper){
        var selectedValue = event.getParam("value");
        component.set("v.selectedSurvey",selectedValue);
    },
    setSelectedCountryCode : function(component,event,helper){
        var selectedValue = event.getParam("value");
        component.set("v.selectedCountryCode",selectedValue);
    },
    
    onCheck: function(cmp, evt) {
        var checkCmp = cmp.find("b2bchk");
        cmp.set("v.b2bacc",checkCmp.get("v.value"));
        cmp.set("v.companyAtrib", "");
    },
    
    checkTerm : function(cmp,evt){
        var checkCmp = cmp.find("termsCon");
        cmp.set("v.termsAccep",checkCmp.get("v.value"));
    },
    
    clearFile : function(cmp, evt){
        cmp.set("v.fileName", '');
    },
    
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    },
})
({
    MAX_FILE_SIZE: 4500000,     //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,         //Chunk Max size 750Kb 
    
    insertCase : function (component,event,caseStat){
        var action = component.get("c.createCase");
        action.setParams({
            reason : component.get("v.selectedreq"),
            category: component.get("v.selectedcat"),
            subject: component.get("v.subjectAtrib"),
            summary: component.get("v.summaryAtrib"),
            b2b: component.get("v.b2bacc"),
            company : component.get("v.companyAtrib"),
            firstname: component.get("v.firstNameAtrib"),
            lastname: component.get("v.lastNameAtrib"),
            email: component.get("v.emailAtrib"),
            phone: (component.get("v.selectedCountryCode")).concat(component.get("v.phoneAtrib")),
            postCode:component.get("v.postCodeAtrib"),
            city: component.get("v.cityAtrib"),
            vin: component.get("v.vinAtrib"),
            regNumber:component.get("v.regNumberAtrib"),
            country : component.get("v.countryAtrib"),   
            language : component.get("v.languageAtrib"),
            brand : component.get("v.brandAtrib"),
            status: caseStat,
            rut : component.get("v.RUTAtrib"),
            fiscal : component.get("v.fiscalAtrib"),
            cRole : component.get("v.contactRoleAtrib"),
            selectedSurvey : component.get("v.selectedSurvey")
        });

        // set call back 
        action.setCallback(this, function(response) {
            // store the response  
            var caseValues = response.getReturnValue();
            var state = response.getState();
            //CASE SUCCESS
            if (state === "SUCCESS") {
                var caseId = caseValues;
                component.set("v.parentId",caseId);
                if (component.find("fileId").get("v.files")!= null) {
                    this.uploadHelper(component, event);
                } else {
                    this.getCaseNumberFromSF(component,event);
                }
            }
            //CASE ERROR
            else{
                component.set('v.hasErrors',true);
                component.set("v.isDisabled", false);
                component.set("v.isDisabledModal", false);
            }
            component.set("v.showLoadingSpinner", false);
        });
        // enqueue the action
        $A.enqueueAction(action);
    },
    
    getCaseNumberFromSF : function (component,event){
        var action = component.get("c.getCaseNumber");
        action.setParams({
            idCase : component.get("v.parentId")
        });
        // set call back 
        action.setCallback(this, function(response) {
            // store the response  
            var caseNumber = response.getReturnValue();
            var state = response.getState();
            //CASE SUCCESS
            if (state === "SUCCESS") {
                component.set("v.caseNumber",caseNumber);
            }
            //CASE ERROR
            //else{}
        });
        // enqueue the action
        $A.enqueueAction(action);
    },
    
    userInfo : function (component,event){
            var action = component.get("c.getUserCountryAndLang");
            action.setCallback(this, function(response) {
            var countryLang = response.getReturnValue();
            var state = response.getState();
            //CASE SUCCESS
            if (state === "SUCCESS") {
                if(countryLang != "guest"){
                    var arrayComps = countryLang.split(";");
                    var country = arrayComps[0];
                    var lang = arrayComps[1];
                    component.set("v.countryAtrib", country);
                    component.set("v.languageAtrib", lang);
                }
                else{
                    //IE11 issue
                    var params      = window.location.search.toString();
                    var parameters  = params.split("=");
                    var lang        = parameters[1].split("_")[0];
                    var country     = parameters[1].split("_")[1];
                    //Algeria has prepopulated country
                    var prepopulatedCountry = component.get("v.countryAtrib");                    
                    if(prepopulatedCountry != "DZ"){
                        component.set("v.countryAtrib", country);
                    }
                    component.set("v.languageAtrib", lang.toUpperCase());
                    component.set("v.languageCode", parameters[1]);
                }

                //Store in Custom Metadata !!!!!!                 
                var settingPL = new Map([ ['placeHolderPhone', 'XXXXXXXXX'], ['country', 'PL'],
                                 ['isPostCodeRequired', 'false'], ['urlTermsCond_AP', ''], ['urlTermsCond_AC', ''], ['urlTermsCond_DS', '']]);
                var settingCL = new Map([ ['placeHolderPhone', 'XXXXXXXXX'], ['country', 'CL'],
                                 ['isPostCodeRequired', 'true'], ['urlTermsCond_AP', ''], ['urlTermsCond_AC', ''], ['urlTermsCond_DS', '']]);
                var settingDZ = new Map([ ['placeHolderPhone', 'XXXXXXXXXX'], ['country', 'DZ'],
                                 ['isPostCodeRequired', 'true'], ['urlTermsCond_AP', ''], ['urlTermsCond_AC', ''], ['urlTermsCond_DS', '']]);
                var settingAR = new Map([ ['placeHolderPhone', 'XXXXXXXX'], ['country', 'AR'],
                                 ['isPostCodeRequired', 'false'], ['urlTermsCond_AP', ''], ['urlTermsCond_AC', ''], ['urlTermsCond_DS', '']]);                
                var settingPT = new Map([ ['placeHolderPhone', 'XXXXXXXXX'], ['country', 'PT'],
                                 ['isPostCodeRequired', 'false'], ['urlTermsCond_AP', 'https://www.peugeot.pt/politica-privacidade/'], ['urlTermsCond_AC', 'https://www.citroen.pt/politica-de-privacidade.html'], ['urlTermsCond_DS', 'https://www.dsautomobiles.pt/politica-de-privacidade.html']]);                
                var settingTR = new Map([['placeHolderPhone', 'XXXXXXXXXX'], ['country', 'TR'],
                                 ['isPostCodeRequired', 'false'], ['urlTermsCond_AP', ''], ['urlTermsCond_AC', ''], ['urlTermsCond_DS', '']]);                
                var settingDefault = new Map([['placeHolderPhone', 'XXXXXXXXXXXXX'], ['country', 'Def'],
                                 ['isPostCodeRequired', 'false'], ['urlTermsCond_AP', ''], ['urlTermsCond_AC', ''], ['urlTermsCond_DS', '']]);				
                var settingsCountries = new Map([['PL', settingPL], ['CL', settingCL], ['DZ', settingDZ], ['AR', settingAR], ['PT', settingPT], ['TR', settingTR]]);

                var currentCountry = component.get("v.countryAtrib");
                var currentBrand = component.get("v.brandAtrib");
                var currentSetting = (settingsCountries.has(currentCountry)) ? settingsCountries.get(currentCountry) : settingDefault;
                component.set("v.userSettings.placeHolderPhone", currentSetting.get('placeHolderPhone'));
                component.set("v.userSettings.country", currentSetting.get('country'));
                component.set("v.userSettings.isPostCodeRequired", currentSetting.get('isPostCodeRequired'));
                component.set("v.userSettings.urlTermsCons", ((currentBrand=='AP') ? currentSetting.get('urlTermsCond_AP') :
                                                              (currentBrand=='AC') ? currentSetting.get('urlTermsCond_AC') :
                                                              (currentBrand=='DS') ? currentSetting.get('urlTermsCond_DS'):""));
            }
            //CASE ERROR            
            //else{}
        });
        $A.enqueueAction(action);
    },
    
    checkKnowledge : function (component,event){
        var action = component.get("c.getKnowledgeArticles");
        action.setParams({
            category: component.get("v.selectedcat"),
            country : component.get("v.countryAtrib"),
            brand : component.get("v.brandAtrib"),
            language : component.get("v.languageAtrib"),
            languageCode : component.get("v.languageCode"),
            subject: component.get("v.subjectAtrib")
        });
        action.setCallback(this, function(response) {
            //CASE SUCCESS 
            if (response.getState() == "SUCCESS") {
                var siteValue = component.get("v.brandAtrib");
                var site;
                if(siteValue == "AP"){
                    site = "peugeot";
                }
                else if(siteValue == "AC"){
                    site = "citroen"
                }
                else if(siteValue == "DS"){
                    site = "ds";
                }
                var allValues = response.getReturnValue();
                var params = window.location.search.toString();
                var articles = [];
                if (allValues != null && allValues != undefined && allValues.length && !component.get("v.isOpen")) {
                    for (var index = 0;index<allValues.length;++index) {
                        var article         = {
                            		id         : allValues[index].Id,
                            		title      : allValues[index].Title != undefined ? allValues[index].Title : "",
                            		urlName        : allValues[index].UrlName != undefined ? "article/"+allValues[index].UrlName+params: ""
                        };
                        articles.push( article );
                    }
                    component.set("v.knowledgeArticles",articles);
                    component.set("v.isOpen", true);
                }
                else{
                    component.set("v.showLoadingSpinner",true);
                    component.set("v.isDisabled",true);  
                    this.insertCase(component,event,"1");
                }
            }
            //CASE ERROR
            else{
                component.set("v.hasErrors",true);
                component.set("v.isDisabled",false);
                component.set("v.showLoadingSpinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    
    getPickListVal: function(component, fieldName, elementId) {
       var action = component.get("c.getselectOptions");
        action.setParams({
            "fld": fieldName
        });
        action.setCallback(this, function(response) {
            //CASE SUCCESS
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                var lstValues = JSON.parse(allValues);
                this.handlePickListVal(component,elementId,lstValues);
            }
            //CASE ERROR
            //else{}
            
        });
        $A.enqueueAction(action);
    },

    handlePickListVal : function (component,elementId,lstValues){
        var country = component.get("v.countryAtrib");
        var opts = [];
        for (var index = 0; index < lstValues.length; ++index) {
            //Exclude values for optionsType
            if (elementId == 'v.optionsType' && lstValues[index].keypck == '218') {

            }
            else if (elementId == 'v.optionsType' && country != 'AR' && lstValues[index].keypck == '1038') {

            }
            //Exclude values for optionsSupportWith
            else if (elementId == 'v.optionsSupportWith' && lstValues[index].keypck == '4') {

            }
            else {
                opts.push({
                    class: "optionClass",
                    label: lstValues[index].labelpck,
                    value: lstValues[index].keypck
                });
            }
            //Set default value for countryCodes
            if(elementId == 'v.phoneCodeValues'){
                if (lstValues[index].labelpck.includes(country)) {
                    component.set('v.selectedCountryCode', lstValues[index].keypck);
                }
            }
        }
        component.set(elementId, opts);
    },
    
    validateForm : function(component,event){
        var selectedreq = component.get("v.selectedreq");
        var selectedcat = component.get("v.selectedcat");
        var subject     = component.get("v.subjectAtrib");
        var summary     = component.get("v.summaryAtrib");
        var b2bacc      = component.get("v.b2bacc");
        var company     = component.get("v.companyAtrib");
        var fiscal      = component.get("v.fiscalAtrib");
        var firstName   = component.get("v.firstNameAtrib");
        var lastName    = component.get("v.lastNameAtrib");
        var email       = component.get("v.emailAtrib");
        var rut         = component.get("v.RUTAtrib");
        var country     = component.get("v.countryAtrib");
        var vin         = component.get("v.vinAtrib");
        var zipCode     = component.get("v.postCodeAtrib");
        var acceptT     = component.get("v.termsAccep");
        var selectedSurvey = component.get("v.selectedSurvey");
        var createCase  = true;
        
        //Validate required fields
        if(selectedreq == '' || selectedcat == '' || selectedSurvey == '' || subject == '' || summary == '' 
           || firstName == '' || lastName == '' || email =='' || (b2bacc == true && company =='' ) 
           || (country =='CL' && rut == '' ) || (country!='CL' && zipCode == '')){
            createCase = false;
            component.find('notifLib').showNotice({
                "variant": "error",
                "message": $A.get("$Label.c.CWF_AlertReq"),
            });
            component.set("v.isDisabled",false);
            component.set("v.showLoadingSpinner", false);
        }
        //Validate formats
        else{        
            //Validate if the user has accepted the terms
            if(!acceptT){
                createCase = false;
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "message": $A.get("$Label.c.CWF_AcceptTerms"),
                });
                component.set("v.isDisabled",false);
                component.set("v.showLoadingSpinner", false);
            }    
            //Validate Email format
            var re = /^(([^<>()\[\]\\.,;:\s@ñ"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
            var validMail = re.test(String(email).toLowerCase());
            if(validMail == false){
                createCase = false;
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "message": $A.get("$Label.c.CWF_AlertMail"),
                });
                component.set("v.isDisabled",false);
                component.set("v.showLoadingSpinner", false);
            }
            //Validate RUT format
            var Fn = {
                validaRut : function (rutCompleto) {
                    if (!/^[0-9]+[-|‐]{1}[0-9kK]{1}$/.test( rutCompleto )){
                        return false;
                    }
                    var tmp     = rutCompleto.split('-');
                    var digv    = tmp[1]; 
                    var rut     = tmp[0];
                    if ( digv == 'K' ){ 
                        digv = 'k' ;
                        return (Fn.dv(rut) == digv );
                    }
                },
                dv : function(T){
                    var M=0,S=1;
                    for(;T;T=Math.floor(T/10)){
                        S=(S+T%10*(9-M++%6))%11;
                    }
                    return S?S-1:'k';
                }
            }
            var rutValido = Fn.validaRut(rut);
            if(rutValido == false && country == "CL"){
                createCase = false;
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "message": "Rut no válido",
                });
                component.set("v.isDisabled",false);
                component.set("v.showLoadingSpinner", false);
            }
        }
        //Validate VIN format
        var validFormatVIN;
        if(vin != ""){
            validFormatVIN = (/^[A-Z0-9]{17}$/.test(vin));
            //VIN format
            if (!validFormatVIN){
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "message": $A.get("$Label.c.CWF_VINError"),
                });
                createCase = false;
                component.set("v.isDisabled",false);
                component.set("v.showLoadingSpinner", false);
            }
        }
        //If all the required fields are validated, the formats are correct and the terms have been accepted...
        if(createCase){
            //CheckVIN --> Call Service -> Validate VIN
            if(vin != "" && country != undefined){
                this.validateVIN(component, event);
            }
            //Call Server --> Query Knowledges..
            else{
                this.checkKnowledge(component,event)
            }
        }
    },
    
    validateVIN : function(component,event){ 
        var vin = component.get("v.vinAtrib");
        var action = component.get("c.validateVIN");
        action.setParams({
            vin : vin,
            country: component.get("v.countryAtrib"),
            lang: component.get("v.languageAtrib"),
            brand: component.get("v.brandAtrib")
        });
        //Timeout - Validate VIN: 3 seconds
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var responseServer = response.getReturnValue();
                if(responseServer == 400){
                    component.find('notifLib').showNotice({
                        "variant": "error",
                        "message": $A.get("$Label.c.CWF_VINError"),
                    });
                    component.set("v.isDisabled",false);
                    component.set("v.showLoadingSpinner", false); 
                }
                else{
                    //Call Server
                    this.checkKnowledge(component,event);
                }
            }
            //CASE ERROR
            //else{}            
        });
        $A.enqueueAction(action);
    },
    
    uploadHelper: function(component, event) {
        // start/show the loading spinner   
        // get the selected files using aura:id [return array of files]
        var fileInput = component.find("fileId").get("v.files");
        // get the first file using array index[0]  
        var file = fileInput[0];
        var self = this;
        // check the selected file size, if select file size greater then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            return;
        }
        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
 
            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
            self.uploadProcess(component, file, fileContents);
        });
 
        objFileReader.readAsDataURL(file);
    },
 
    uploadProcess: function(component, file, fileContents) {
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '');
    },
 
    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId) {
        // call the apex method 'saveChunk'
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.saveTheFile");
        action.setParams({
            parentId: component.get("v.parentId"),
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type,
        });
 
        // set call back 
        action.setCallback(this, function(response) {
            // store the response / Attachment Id   
            var state = response.getState();
            if (state === "SUCCESS") {
                this.getCaseNumberFromSF(component,event);
                // handel the response errors        
            } else if (state === "INCOMPLETE") {
                console.log("Incomplete");
            } else if (state === "ERROR") {
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    }
    
})
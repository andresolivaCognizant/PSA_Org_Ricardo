({
	/**
	* Event which fires the function to start a chat request (by accessing the chat API
	component).
	*
	* @param cmp - The component for this state.
	*/
	onStartButtonClick: function (cmp) {
		var prechatFieldComponents = cmp.find("prechatField");
		var apiNamesMap = this.createAPINamesMap(cmp.find("prechatAPI").getPrechatFields());
        var sPageURL = encodeURIComponent(window.location);
 
		//1- Get brand from URL
		var brandValue;
		if (sPageURL.includes("peugeot")){
			brandValue = "AP";
		} else if (sPageURL.includes("citroen")) {
			brandValue = "AC";
		} else if (sPageURL.includes("ds")) {
			brandValue = "DS";
		}        
		//2- Get Country form URL
		var countryValue;
		if (sPageURL.includes("es_ES")) {
			countryValue = "ES";
		} else if (sPageURL.includes("pt_PT")) {
			countryValue = "PT";
		} else if (sPageURL.includes("en_EN")) {
			countryValue = "UK";
		} else if (sPageURL.includes("es_AR")) {
			countryValue = "AR";
		} else if (sPageURL.includes("es_CL")) {
			countryValue = "CL";
		} else if (sPageURL.includes("es_MX")) {
			countryValue = "MX";
		} else if (sPageURL.includes("FR")) {
			countryValue = "DZ";
		}        
        //3- Get Language From URL
        var currentUrl 			= new URL(window.location.href);
		var languageAttribute 	= currentUrl.searchParams.get("language");
		// If it's in an internal web, we must get the info from the settings.
		if($A.util.isUndefinedOrNull(languageAttribute)){
			currentUrl 			= new URL(cmp.find("settingsAPI").getLiveAgentSettings().chatbotAvatarImgURL);
			languageAttribute 	= currentUrl.searchParams.get("language");
		}
		var languageValue 		= (languageAttribute.includes('_'))? languageAttribute.split('_')[0].toUpperCase() : '';
        
        //Get the values inserted by the user
        var listParameters 		= this.createFieldsArray(apiNamesMap, prechatFieldComponents);         
        
        //Get API Names, labels of all PreChat fields
        // - Contact Obj: {0:FirstName, 1:LastName, 2:Email} 
        // - Case Obj:    {3:Brand__c, 4:Subject, 5:CaseSurveyAcceptance__c, 6: Country__c, 7:Reason, 8:Language__c}        
        var infoFields =  cmp.get('v.prechatFieldComponentsCopy');
        
        //CONTACT Object
		var firstName = 	{ label: infoFields[0].label, name: infoFields[0].name, value: '' };
		var lastName =  	{ label: infoFields[1].label, name: infoFields[1].name, value: '' };
		var email =     	{ label: infoFields[2].label, name: infoFields[2].name, value: '' };
        
        //CASE Object
        var brand = 		{ label: infoFields[3].label, name: infoFields[3].name, value: brandValue };
		var subject =    	{ label: infoFields[4].label, name: infoFields[4].name, value: $A.get("$Label.c.Chat_conversation") };        
		var survAccept =	{ label: infoFields[5].label, name: infoFields[5].name, value: listParameters[2].value };
		var country = 		{ label: infoFields[6].label, name: infoFields[6].name, value: countryValue };		
		var caseReason = 	{ label: infoFields[7].label, name: infoFields[7].name, value: "1" };
        var language = 		{ label: infoFields[8].label, name: infoFields[8].name, value: languageValue };    
        
        //Push fields
        var fields = [];
		fields.push(firstName, lastName, email, brand, subject, survAccept, country, caseReason, language);        

		//If the prechat fields pass validation, start a chat.
		cmp.find("prechatAPI").startChat(fields);
	},
	
	/**
	* Create an array of field objects to start a chat from an array of prechat fields.
	*
	* @param fields - Array of prechat field Objects.
	* @returns An array of field objects.
	*/
	createFieldsArray: function (apiNames, fieldCmps) {
		if (fieldCmps.length) {
			return fieldCmps.map(function (fieldCmp) {
				return {
					label: fieldCmp.get("v.label"),
					value: fieldCmp.get("v.value"),
					name: apiNames[fieldCmp.get("v.label")]
				};
			}.bind(this));
		} else {
			return [];
		}
	},
    
	/**
	* Create map of field label to field API name from the pre-chat fields array.
	*
	* @param fields - Array of prechat field Objects.
	* @returns An array of field objects.
	*/
	createAPINamesMap: function (fields) {
		var values = {};
		fields.forEach(function (field) {
			values[field.label] = field.name;
		});
		return values;
	},
    
	/**
	* Create an array in the format $A.createComponents expects.
	*
	* Example:
	* [["componentType", {attributeName: "attributeValue", ...}]]
	*
	* @param prechatFields - Array of prechat field Objects.
	* @returns Array that can be passed to $A.createComponents
	*/
	getPrechatFieldAttributesArray: function (prechatFields) {
	// $A.createComponents first parameter is an array of arrays. Each array contains	
		//the type of component being created, and an Object defining the attributes.
		var prechatFieldsInfoArray = [];
		// For each field, prepare the type and attributes to pass to $A.createComponents.
		prechatFields.forEach(function (field) {
			var componentName = (field.type === "inputSplitName") ? "inputText" : field.type;
			var componentInfoArray = ["ui:" + componentName];
			var attributes = {
				"aura:id": "prechatField",
				required: field.required,
				label: field.label,
				disabled: field.readOnly,
				maxlength: field.maxLength,
				class: field.className,
				value: field.value
			};
			// Special handling for options for an input:select (picklist) component.
			if (field.type === "inputSelect" && field.picklistOptions) attributes.options
				= field.picklistOptions;
			// Append the attributes Object containing the required attributes to render
			//this prechat field.
				componentInfoArray.push(attributes);
			// Append this componentInfoArray to the fieldAttributesArray.
			prechatFieldsInfoArray.push(componentInfoArray);
		});
		return prechatFieldsInfoArray;
	},
    
    hideInputs : function(component){
        var prechatFieldComponents 	= component.find("prechatField");
		var vprechatFields 			= component.find("prechatAPI").getPrechatFields();
		//var fields 					= [];
        var listParameters 			= this.createFieldsArray(vprechatFields, prechatFieldComponents);
        this.renderField(vprechatFields);
        this.getFieldAttributes(component,prechatFieldComponents);
		   
    },
    
    renderField: function(fields) {
        // Dynamically create input HTML element
        // 
        fields.forEach(function(field) {
            
            //console.log(field);
            console.log('field---'+field);
            var componentName = (field.type === "inputSplitName") ? "inputText" : field.type;
            var input = document.createElement("input");
            // Set general attributes
            input.type = componentName;
            input.class = field.label;
            input.placeholder = "Your"+field.label+" here.";
            // Set attributes required for starting a chat
            input.name = field.name;
            input.label = field.label;
            input.options = field.picklistOptions
            input.required= field.required;
            
            // Add email input to the DOM
            document.querySelector(".prechatFields").appendChild(input);
            
        })
    },
});
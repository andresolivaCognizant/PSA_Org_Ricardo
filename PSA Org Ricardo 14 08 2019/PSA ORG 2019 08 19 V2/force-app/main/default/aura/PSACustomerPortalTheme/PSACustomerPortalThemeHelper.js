({
	userInfo : function (component,event){
            var action = component.get("c.getUserCountryAndLang");
            action.setCallback(this, function(response) {
            var countryLang = response.getReturnValue();
            console.log(countryLang);
            var state = response.getState();
            if (state === "SUCCESS") {
                if(countryLang != "guest"){

                    var arrayComps = countryLang.split(";");
                    var country = arrayComps[0];
                    var lang = arrayComps[1];
                    console.log(country);
                    console.log(lang);
                    component.set("v.countryAtrib", country);
                    component.set("v.languageAtrib", lang);

                }
                else{

                   var params = window.location.search.toString();
                   console.log(params);
                   var parameters = params.split("=");
                   console.log(parameters[1]);
                   var lang = parameters[1].split("_")[0];
                   console.log(lang.toUpperCase());
                   var country = parameters[1].split("_")[1];
                   console.log(country);
                   var dz = component.get("v.countryAtrib");
                   if(dz != "DZ"){
                   component.set("v.countryAtrib", country);
                   }
                   component.set("v.languageAtrib", lang.toUpperCase());

                }
            }
        });
        $A.enqueueAction(action);
    }
})
({
  jsCheckMandatoryFields: function(component) {
    var action = component.get("c.checkMandatoryFields");
      action.setParams({
        "req": JSON.stringify({
          "record_id": component.get("v.recordId")
        })
      });

      action.setCallback(this, function(response) {
        this.handleCheckMandatoryFields(component, response);
      });

    $A.enqueueAction(action);
  },

  jsSendRequest: function(component) {
    var action = component.get("c.SendRequest");
      action.setParams({"idOpp" : component.get("v.recordId")})
      action.setCallback(this, function(response) {
        this.handleSendRequest(component, response);
      });

    $A.enqueueAction(action);
  },

  handleSendRequest: function(component, response) {
    var state = response.getState();
    switch (state) {
      case "SUCCESS":

        var res = response.getReturnValue();
        console.log("RES: " + res);
        component.set("v.ServiceResponse", res);
        component.set("v.Spinner", false);
        break;

      case "INCOMPLETE":
        // do something
        break;

      case "ERROR":
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          } 
        } else {
          console.log("Unknown error");
        }
        break;
    }
  },

  handleCheckMandatoryFields: function(component, response) {
    var state = response.getState();
    switch (state) {
      case "SUCCESS":

        // required fields
        var r = {
          "Opportunity" : [
            "FleetCategory__c",
            "ProductionRequest__c",
            "RealQuantity__c",
            "FundingForm__c",
            "FundingCompany__c"
          ],
          "Account" : [
            "Name",
            "NonUniqueFiscalId__c"
          ],
          "SBQQ__Quote__c" : [
            "LCDV16__c",
            "ColorCode__c",
            "InteriorTrimCode__c",
            "ProductionYear__c",
            "Quantity__c",
            "SuggestedDiscountTotalAmount__c"
          ]
        };

        // object with records with missing fields
        var f = {};

        // opportunity record returned by the server
        var o = response.getReturnValue().payload;
        debugger;
            
        // check if any of the returned fields is empty
        r.Opportunity.forEach(function(i) {
          if (!o.hasOwnProperty(i)) {
            if (!f.hasOwnProperty(o.Id)) {
            	if (i == 'FundingCompany__c' && o.FundingForm__c == '1'){ 
            	} else {
            		f[o.Id] = [i];
            	}
            } else {
            	if (i == 'FundingCompany__c' && o.FundingForm__c == '1'){ 
            	} else {
            		f[o.Id].push(i);
            	}     
            }
          }
        });

        r.Account.forEach(function(i) {
          if (!o.Account.hasOwnProperty(i)) {
            if (!f.hasOwnProperty(o.Account.Id)) {
              f[o.Account.Id] = [i];
            } else {
              f[o.Account.Id].push(i);
            }
          }
        });

        if (o.hasOwnProperty("SBQQ__Quotes2__r")) {
          o.SBQQ__Quotes2__r.forEach(function(q) {
            r.SBQQ__Quote__c.forEach(function(i) {
              if (!q.hasOwnProperty(i)) {
                if (!f.hasOwnProperty(q.Id)) {
                  f[q.Id] = [i];
                } else {
                  f[q.Id].push(i);
                }
              }
            });
          });
        }

        if (Object.getOwnPropertyNames(f).length === 0) {
            // send REST request
            this.jsSendRequest(component);
            return;
        }
        
        //console.log("Error message: " + errors[0].message);
        
        var m = $A.get("$Label.c.RESTInt97A_Result_KO");

        for (var rec_id in f) {
            m += ". The record with Id " + rec_id + " has empty values in the following fields " + f[rec_id] + "\n";
        }

        component.set("v.ServiceResponse", m);
        component.set("v.Spinner", false);

        break;

      case "INCOMPLETE":
        // do something
        break;

      case "ERROR":
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          } 
        } else {
          console.log("Unknown error");
        }
        break;
    }
  },


})
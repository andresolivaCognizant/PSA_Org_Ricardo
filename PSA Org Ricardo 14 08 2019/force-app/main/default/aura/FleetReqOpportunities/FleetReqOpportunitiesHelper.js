({
  jsGetReportData: function(component) {
    component.set("v.ui_obj.isLoading", true);
    var action = component.get("c.getReportData");
      action.setParams({
        "request": JSON.stringify({
          "report_dev_name" : "Fleet_Request_Opportunities",
          "filter_api_name" : "Opportunity.Account.Id",
          "filter_value"    : component.get("v.recordId")
        })
      });

      action.setCallback(this, function(response) {
        this.handleReportData(component, response);
      });

    $A.enqueueAction(action);
  },

  handleReportData: function(component, response) {
    var state = response.getState();
    switch (state) {
      case "SUCCESS":
        component.set(
          "v.data",
          JSON.parse(response.getReturnValue().payload)
        );

        // insert datatable to DOM - begin
        $A.createComponent( 
          "lightning:datatable",
          {
            "columns"             : this.getDataTableColumns(JSON.parse(response.getReturnValue().payload)),
            "data"                : this.getDataTableRows(JSON.parse(response.getReturnValue().payload)),
            "keyField"            : "Id",
            "hideCheckboxColumn"  : true,
            "showRowNumberColumn" : true
          },
          function(e, status, errorMessage) {
            var body = [];
            switch (status) {
              case "SUCCESS":
                body.push(e);
                component.set("v.ui_obj.isLoading", false);
                component.find("_body_container").set("v.body", body);

                break;

              case "INCOMPLETE":
                console.log("No response from server or client is offline.");
                break;
  
              case "ERROR":
                console.log("Error: " + errorMessage)
                break;
  
              default:
                break;
            }
          }
        );
        // insert datatable to DOM - end
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

  getDataTableColumns: function(md_obj) {
    var col_info_array = Object.values(md_obj.reportExtendedMetadata.detailColumnInfo);
    var cols = [];

    col_info_array.forEach(element => {
      cols.push({
        "label"     : element.label,
        "type"      : "text",
        "fieldName" : element.name
      });
    });

    debugger;
    return cols.reverse();
    
  },

  getDataTableRows: function(md_obj) {
    var row_info_array = [];
    var rows = [];
    var cols = this.getDataTableColumns(md_obj);
    debugger;

    for (var key in md_obj.factMap) {
      if(md_obj.factMap[key].rows) {
        row_info_array.push(
          ...md_obj.factMap[key].rows
        );
      }
    }

    row_info_array.forEach(element => {
      var row = {};
      element.dataCells.forEach((cell, index) => {
        row[cols[index].fieldName] = cell.label;
      });
      rows.push(row);
    });

    debugger;
    return rows;
  }

})
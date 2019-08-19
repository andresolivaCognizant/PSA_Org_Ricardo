({
  setDefaults: function(component) {
    var s = {
      "disabled"  : false
    }
    
    var t = {
      "disabled"  : true
    }

    var i = {
      "isMassTransfer"      : false,
      "rows"                : [],
      "filter"              : {
        "city"              : '',
        "postal_code"       : '',
        "customer_type"     : '1',
        "customer_status"   : '1'
      }
    }

    component.set("v.user_input_obj", i);
    component.set("v.config_obj.search_btn", s);
    component.set("v.config_obj.transfer_btn", t);
    component.set("v.config_obj.transfer_btn.variant", "brand");

    return;
  }
})
import {LightningElement, api, wire, track} from 'lwc';
import {getRecord} from 'lightning/uiRecordApi';
import getAppointmentId from '@salesforce/apex/OlbAppointment.getAppointmentId';
import error_msg from '@salesforce/label/c.OlbAppointmentLwcError';

export default class OlbAppointment extends LightningElement {

  @api recordId;
  @api apvDealerId;
  @track ui_object;
  iframe_src = 'https://www.groupe-psa.com';
  rec;
  label = {
    error_msg
  };

  @wire(
    getRecord,
    {
      recordId: '$recordId',
      fields: [
        'TeleAlert__c.Id',
        'TeleAlert__c.Brand__c',
        'TeleAlert__c.Country__c',
        'TeleAlert__c.APVDealer__c',
        'TeleAlert__c.Account__r.Brand__c',
        'TeleAlert__c.Account__r.PreferredACDealerAPV__pc',
        'TeleAlert__c.Account__r.PreferredAPDealerAPV__pc',
        'TeleAlert__c.Account__r.PreferredDSDealerAPV__pc'
      ]
    }
  ) wiredRecord({error, data}) {
      if (data && !this.ui_object.spinner.render && this.ui_object.step.value < 10) {
        this.rec = data;
        if (data.fields.APVDealer__c.value) {
          this.ui_object = this.stepProperties(1);
          return;
        }
        switch (data.fields.Account__r.value.fields.Brand__c.value) {
          case 'AC':
            this.apvDealerId = data.fields.Account__r.value.fields.PreferredACDealerAPV__pc.value;
            break;
          case 'AP':
            this.apvDealerId = data.fields.Account__r.value.fields.PreferredAPDealerAPV__pc.value;
            break;
          case 'DS':
            this.apvDealerId = data.fields.Account__r.value.fields.PreferredDSDealerAPV__pc.value;
            break;
          default:
            break;
        }
        if (this.apvDealerId) {
          this.ui_object = this.stepProperties(1);
        }

      } else if (error) {
        this.rec = null;
        // show err msg
      }
  }

  connectedCallback() {
    // initialize component
    if (!this.ui_object) {
      this.ui_object = this.stepProperties(0);
    }
  }

  handleClick() {
    if (this.ui_object.step.value === 1) {
      this.template.querySelector('lightning-record-edit-form').submit();
      this.ui_object = this.stepProperties(10);
      let req_body = {
        "id" : this.rec.fields.Id.value,
      };
      getAppointmentId({"request" : JSON.stringify(req_body)})
        .then(result => {
          if (result.has_error) {
            this.ui_object = this.stepProperties(30);
            return;
          }
          this.iframe_src =
            result.payload.url_lst[0].OlbUrl__c +
            JSON.parse(result.payload.olb_res).GetIdRdvLeadsResponse.GetIdRdvLeadsResult.RdvLeadsId;
          this.ui_object = this.stepProperties(20);
        })
        .catch((error) => {
          console.log("An error occurred" + error);
          this.ui_object = this.stepProperties(30);
        })
    }

    if (this.ui_object.step.value > 19) {
      const evt = new CustomEvent('lwcevent', {
        detail: {}
      });
      this.dispatchEvent(evt);
    }
  }

  handleChange(event) {
    if (event.detail.value.length) {
      this.ui_object = this.stepProperties(1);
      return;
    }
    this.ui_object = this.stepProperties(0);
  }

  // page visibility is based on ui_object.step p* properties (p0, p1, p2, ...)
  setStepObject(step) {
    var obj = {
      "value": step
    };
    switch (step) {
      case 0:
      case 1:
        obj['p' + 0]  = true;
        break;
      case 20:
        obj['p' + 20] = true;
        break;
      case 30:
        obj['p' + 30] = true;
        break;
      default:
        obj['p' + 0]  = true;
        break;
    }
    return obj;
  }

  stepProperties(step) {
    switch (step) {
      case 1:
        return {
          "step": this.setStepObject(step),
          "spinner": {
            "render"    : false
          },
          "button": {
            "label"     : "Go to OLB",
            "disabled"  : false
          }
        }
      case 10:
        return {
          "step": this.setStepObject(step),
          "spinner": {
            "render"    : true
          },
          "button": {
            "label"     : "Loading",
            "disabled"  : true
          }
        }
      case 20:
        return {
          "step": this.setStepObject(step),
          "spinner": {
            "render"    : false
          },
          "button": {
            "label"     : "Close",
            "disabled"  : false
          }
        }
      case 30:
        return {
          "step": this.setStepObject(step),
          "spinner": {
            "render"    : false
          },
          "button": {
            "label"     : "Close",
            "disabled"  : false
          }
        }
      default:
        return {
          "step": this.setStepObject(step),
          "spinner": {
            "render"    : false
          },
          "button": {
            "label"     : "Go to OLB",
            "disabled"  : true
          }
        }
    }
  }

}
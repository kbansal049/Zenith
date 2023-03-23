import { LightningElement, api, track, wire } from "lwc";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";

import RECORDTYPE_ID from "@salesforce/schema/Product_Demo_Instance_Request__c.RecordTypeId";

import extendProvisitioning from "@salesforce/apex/ExtendInteractiveController.ExtendInteractive";
import disableProvisitioning from "@salesforce/apex/ExtendInteractiveController.DisableInteractive";
import reEnableProvisitioning from "@salesforce/apex/ExtendInteractiveController.reEnableInteractive";

import PRODUCT_DEMO from "@salesforce/schema/Product_Demo_Instance_Request__c";

const fields = [RECORDTYPE_ID];

export default class ProvisionInteractive extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  @api requestType;

  @track requestTypeName;

  @track isLoaded = false;
  @track isModalOpen = false;
  @track hasError = false;
  @track isCancel = false;
  @track errMsg;

  @track isRedirect = false;
  @track count = 0;
  @track completed = 5;

  @wire(getObjectInfo, { objectApiName: PRODUCT_DEMO })
  objectInfo;

  @wire(getRecord, { recordId: "$recordId", fields: fields })
  pDemo;

  get recordTypeName() {
    // Returns a map of record type Ids
    let retName = "";
    console.log("---objectInfo--objectInfo--", this.objectInfo);
    console.log("---pDemo---", this.pDemo);
    if (this.objectInfo && this.objectInfo.data) {
      let rtis = this.objectInfo.data.recordTypeInfos;
      let rtId = getFieldValue(this.pDemo.data, RECORDTYPE_ID);

      console.log("---rtId---", rtId);
      let rtSeaqrchId = Object.keys(rtis).find(
        (rti) => rtis[rti].recordTypeId === rtId
      );
      console.log("---rtSeaqrchId---", rtSeaqrchId);
      if (rtSeaqrchId) {
        let rtInfo = rtis[rtSeaqrchId];
        console.log("---rtInfo---", rtInfo);
        if (rtInfo && rtInfo.name) {
          retName = rtInfo.name;
        }
      }
    }
    return retName;
  }

  connectedCallback() {
    console.log("---recordId---", this.recordId);
    console.log("---requestType---", this.requestType);
    if (this.recordId) {
      if (this.requestType === "Request_Extension") {
        this.isLoaded = true;
        this.requestTypeName = "Extension";
        this.isModalOpen = true;
      } else if (this.requestType === "Request_Disable") {
        this.isLoaded = true;
        this.requestTypeName = "Disable";
        this.isModalOpen = true;
      } else if (this.requestType === "Request_ReEnable") {
        this.isLoaded = true;
        this.requestTypeName = "Reenabled";
        this.isModalOpen = true;
      } else {
        this.errMsg = "Please provide a valid requestType.";
        this.hasError = true;
        this.isLoaded = true;
      }
    } else {
      this.errMsg = "Please provide valid record id.";
      this.hasError = true;
      this.isLoaded = true;
    }
  }

  closeModal() {
    this.isModalOpen = false;
    this.isRedirect = false;
    this.isCancel = true;
    this.redirectToRecordPage();
  }

  submitDetails() {
    console.log("---submitDetails called---");
    if (this.requestTypeName === "Disable") {
      this.disableInteractive();
    } else if (this.requestTypeName === "Extension") {
      this.extendInteractive();
    } else if (this.requestTypeName === "Reenabled") {
      this.reEnabledInteractive();
    }
  }

  extendInteractive() {
    console.log("---extendInteractive called---");

    this.isModalOpen = false;
    this.isLoaded = false;

    extendProvisitioning({
      reqId: this.recordId
    })
      .then((result) => {
        this.isLoaded = true;
        console.log("---extendProvisitioning--result--", result);
        this.parseInteractiveResponse(result);
      })
      .catch((error) => {
        this.isLoaded = true;
        console.log("---error--", error);
        let msg = "Integation Request failed, Please contact administartor.";
        this.fireToastEvent("Error Occured,", msg, "error");
      });
  }

  disableInteractive() {
    console.log("---disableInteractive called---");
    this.isModalOpen = false;
    this.isLoaded = false;

    disableProvisitioning({
      reqId: this.recordId
    })
      .then((result) => {
        console.log("---disableProvisitioning--result--", result);
        this.parseInteractiveResponse(result);
      })
      .catch((error) => {
        console.log("---error--", error);
        let msg = "Integation Request failed, Please contact administartor.";
        this.fireToastEvent("Error Occured,", msg, "error");
      });
  }

  reEnabledInteractive() {
    console.log("---reEnabledInteractive called---");
    this.isModalOpen = false;
    this.isLoaded = false;

    reEnableProvisitioning({
      reqId: this.recordId
    })
      .then((result) => {
        console.log("---reEnableProvisitioning--result--", result);
        this.parseInteractiveResponse(result);
      })
      .catch((error) => {
        this.isLoaded = true;
        console.log("---error--", error);
        let msg = "Integation Request failed, Please contact administartor.";
        this.fireToastEvent("Error Occured,", msg, "error");
      });
  }

  parseInteractiveResponse(result) {
    this.isLoaded = true;
    if (result.Status && result.Status === "Success") {
      let msg = "Request submitted successfully";
      this.fireToastEvent("Success", msg, "success");
      this.isRedirect = true;
      this.isCancel = false;
      this.hasError = false;
    } else {
      this.isRedirect = false;
      this.hasError = true;
      this.errMsg = result.errMsg;
      this.fireToastEvent("Error", result.errMsg, "error");
    }
    this.redirectToRecordPage();
  }

  goback() {
    console.log("--goback called--");
    this.hasError = false;
    this.isRedirect = false;
    this.isCancel = true;
    this.redirectToRecordPage();
  }

  fireToastEvent(title, message, variant) {
    //Lightning Toast
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(evt);

    //VF PAge Toast
    const vfPageSuccessToast = new CustomEvent("showToastOnVF", {
      detail: {
        title: title,
        message: message,
        variant: variant
      },
      bubbles: true,
      composed: true
    });
    // Fire the custom event
    this.dispatchEvent(vfPageSuccessToast);
  }

  redirectToRecordPage() {
    //Timer Code Starts
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    this.intervalID = setInterval(
      function () {
        this.count++;
        console.log("--count--", this.count);
        if (this.count === this.completed) {
          clearInterval(this.intervalID);
          this.navigateToProductDemoRequest();
        }
      }.bind(this),
      1000
    );
    //Timer Code Ends
  }

  navigateToProductDemoRequest() {
    console.log("--navigateToProductDemoRequest--", this.recordId);
    if (this.recordId) {
      this[NavigationMixin.Navigate]({
        type: "standard__recordPage",
        attributes: {
          recordId: this.recordId,
          objectApiName: "Product_Demo_Instance_Request__c",
          actionName: "view"
        }
      });
      // Fire the custom event
      const vfPageRedirect = new CustomEvent("redirectToProductDemo", {
        detail: {
          recordId: this.recordId
        },
        bubbles: true,
        composed: true
      });
      this.dispatchEvent(vfPageRedirect);
    }
  }
}
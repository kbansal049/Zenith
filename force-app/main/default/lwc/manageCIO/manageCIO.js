import { LightningElement, wire, track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getCIODetails from "@salesforce/apex/ManageCIOController.getCIODetails";
import getCIODetailsUncached from "@salesforce/apex/ManageCIOController.getCIODetailsUncached";

import saveContactRecords from "@salesforce/apex/ManageCIOController.saveContactRecords";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class ManageCIO extends NavigationMixin(LightningElement) {
  @api recordId;

  @track cioDetail;
  @track conList;

  execOptions;

  @track isWireCompleted;
  @track isLoadedSuccess;

  @track caseCreationList = [];

  @track showConfirmModal = false;

  //Error handling
  @track hasError = false;
  @track errorMsg;

  @track saveContactCalled = false;

  @wire(getCIODetails, { accountID: "$recordId" })
  getRecordsCallback({ data, error }) {
    if (data) {
      this.parseCiOdetails(data);
    } else if (error) {
      window.console.log("Returned To JS error", error);
      this.isLoadedSuccess = true;
    }
  }

  refreshContactList() {
    if (this.recordId) {
      getCIODetailsUncached({ accountID: this.recordId })
        .then((data) => {
         this.parseCiOdetails(data);
        })
        .catch((error) => {
          window.console.log("Returned To JS error", error);
          this.isLoadedSuccess = true;
        });
    }
  }

  parseCiOdetails(data) {
    if (data.hasError) {
      this.hasError = true;
      this.errorMsg = data.errorMsg;
    } else {
      let execVar = JSON.parse(data.execOptions);
      this.execOptions = [];
      this.execOptions.push({ label: "--None--", value: "" });
      for (var i in execVar) {
        this.execOptions.push({ label: i, value: execVar[i] });
      }
      this.cioDetail = data;
      this.conList = data.conList;
      window.console.log("this.execOptions", this.execOptions);
      window.console.log("conList", this.conList);
    }
    this.isLoadedSuccess = true;
  }

  handleCIOReportChange(event) {
    window.console.log("---handleCIOReportChange called---");
    let name = event.currentTarget.name;
    let value = event.detail.value;
    let cList = [];
    this.conList.forEach((conWrap) => {
      let cWrap = { ...conWrap };
      if (conWrap.Con.Id === name) {
        cWrap.Send_Exec_Insights = value;
      }
      cList.push(cWrap);
    });
    this.conList = cList;
    window.console.log("---this.conList---", this.conList);
  }

  resetTheData() {
    window.console.log("---resetTheData called---");
    let cList = [];
    this.conList.forEach((conWrap) => {
      let cWrap = { ...conWrap };
      cWrap.Send_Exec_Insights = cWrap.Con.Send_CIO_Report__c;
      cList.push(cWrap);
    });
    this.conList = cList;
    window.console.log("---this.conList---", this.conList);
  }

  saveContacts() {
    window.console.log(":::::saveContacts called::::::");
    if (this.conList && this.conList.length > 0) {
      //Start Spinner
      this.saveContactCalled = true;

      let cioDet = { ...this.cioDetail };

      let cList = [];
      this.conList.forEach((conWrap) => {
        let cWrap = { ...conWrap };
        cList.push(cWrap);
      });
      cioDet.conList = cList;

      window.console.log("cioDet::::::", cioDet);

      saveContactRecords({ cDetailStr: JSON.stringify(cioDet) })
        .then((result) => {
          window.console.log("result::::::", result);
          if (result.isSucess === true) {
            this.resetErrorDetails();
            this.closeConfirmModal();
            this.showToastMessage(
              "Success!",
              "Contact has been updated succesfully!",
              "success"
            );
            this.isLoadedSuccess = false;
            this.refreshContactList();
          } else {
            this.closeConfirmModal();
            this.hasError = true;
            this.errorMsg = result.errorMsg;
          }
        })
        .catch((error) => {
          this.closeConfirmModal();
          this.hasError = true;
          this.errorMsg = "Unable to save contact records.";
          if (Array.isArray(error.body)) {
            this.errorMsg = error.body.map((e) => e.message).join(", ");
          } else if (typeof error.body.message === "string") {
            this.errorMsg = error.body.message;
          }
        });
    }
  }

  resetErrorDetails() {
    this.hasError = false;
    this.errorMsg = "";
  }

  openConfirmModal() {
    this.resetErrorDetails();
    this.showConfirmModal = true;
    let caseList = [];
    this.conList.forEach((conWrap) => {
      let cWrap = { ...conWrap };
      if (
        conWrap.Send_Exec_Insights != conWrap.Con.Send_CIO_Report__c &&
        conWrap.CreateCase &&
        conWrap.CaseExist == false
      ) {
        caseList.push(cWrap);
      }
    });
    this.caseCreationList = caseList;
  }

  closeConfirmModal() {
    //Close Modal
    this.showConfirmModal = false;
    //Stop Spinner
    this.saveContactCalled = false;
  }

  get willBeCaseCreated() {
    return this.caseCreationList.length > 0 ? true : false;
  }

  gotoContactRecord(event) {
    window.console.log(":::::gotoContactRecord called::::::");
    let data = event.currentTarget.dataset;
    window.console.log("conID---", data.conId);
    if (data.conId) {
      window.open("/" + data.conId, "_blank");
    }
  }

  gotoCaseRecord(event) {
    window.console.log(":::::gotoCaseRecord called::::::");
    let data = event.currentTarget.dataset;
    window.console.log("caseId---", data.caseId);
    if (data.caseId) {
      window.open("/" + data.caseId, "_blank");
    }
  }

  gotoAccountRecord(event) {
    window.console.log(":::::gotoAccountRecord called::::::");
    let data = event.currentTarget.dataset;
    window.console.log("accId---", data.accId);
    if (data.accId) {
      window.open("/" + data.accId);
    }
  }

  navigateToAccountRecord(event) {
    window.console.log(":::::navigateToAccountRecord called::::::");
    let data = event.currentTarget.dataset;
    window.console.log("accId---", data.accId);
    if (data.accId) {
      window.location.assign("/" + data.accId);
      /*if (document.referrer.indexOf(".lightning.force.com") > 0) {
        this[NavigationMixin.Navigate]({
          type: "standard__recordPage",
          attributes: {
            recordId: data.accId,
            actionName: "view"
          }
        });
      } else {
        window.location.assign("/" + data.accId);
      }*/
    }
  }

  showToastMessage(title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant,
      mode: "dismissable"
    });
    this.dispatchEvent(event);
  }

  get isContactListEmpty() {
    return this.conList != undefined && this.conList.length > 0 ? false : true;
  }
}
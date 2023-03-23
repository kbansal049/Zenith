import { LightningElement, api, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import getJiraRecords from "@salesforce/apex/JiraTicketAssociationController.getNonAssoicatedRecord";
import saveJiraRecords from "@salesforce/apex/JiraTicketAssociationController.saveRecords";

export default class AssociateJiraTicket extends NavigationMixin(
  LightningElement
) {
  @api recordId = "0067000000MAmyI";
  @api requestType = "Improvement";

  @track isLoaded = false;
  @track hasError = false;
  @track isCancel = false;
  @track errMsg;

  @track rsltWrap;

  @track mappedList = [];

  @track isRedirect = false;
  @track count = 0;
  @track completed = 5;

  @track isModalOpen = false;

  connectedCallback() {
    console.log("---recordId---", this.recordId);
    console.log("---requestType---", this.requestType);
    if (this.recordId) {
      if (this.requestType === "Improvement") {
        this.isLoaded = true;
      } else if (this.requestType === "Bug") {
        this.isLoaded = true;
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

  @wire(getJiraRecords, { recordId: "$recordId", recordType: "$requestType" })
  wiredCallbackResult(result) {
    this.resultWrapper = "";
    console.log("--result--", JSON.stringify(result));
    if (result.data) {
      //parse result
      console.log("---result.data--", JSON.stringify(result.data));
      if (result.data.isSuccess) {
        this.parseWrapper(result.data);
      } else {
        this.isLoaded = true;
        this.hasError = true;
        this.errMsg = "Error Occurred, kindly contact the administrator.";
        this.errDetail = result.data.errMsg;
      }
    } else if (result.error) {
      //Set Error Details
      this.isLoaded = true;
      this.hasError = true;
      this.errMsg = "Error Occurred, kindly contact the administrator.";
      this.errDetail = result.error;
    }
  }

  parseWrapper(resultWrapper) {
    if (resultWrapper && resultWrapper.recordList) {
      this.rsltWrap = {};
      this.rsltWrap.type = resultWrapper.type;
      let recordWrapperList = [];

      resultWrapper.recordList.forEach((element, index) => {
        recordWrapperList.push({
          rowId: index,
          isSelected: false,
          record: element
        });
      });
      this.rsltWrap.recordWrapperList = recordWrapperList;

      this.isLoaded = true;
      this.hasError = false;
      console.log("---rsltWrap--", JSON.stringify(this.rsltWrap));
    }
  }

  updateTicketSelection(event) {
    console.log("---updateTicketSelection called--");

    // eslint-disable-next-line radix
    let selRowIndex = parseInt(event.target.dataset.rowId);
    let selValue = event.target.checked;
    console.log("---rowIndex--", selRowIndex);
    console.log("---selValue--", selValue);

    if (selRowIndex >= 0) {
      let recordWrapperListNew = [];
      this.rsltWrap.recordWrapperList.forEach((element) => {
        if (element.rowId === selRowIndex) {
          let innerEle = element;
          innerEle.isSelected = selValue;
          recordWrapperListNew.push(innerEle);
        } else {
          recordWrapperListNew.push(element);
        }
      });
      this.rsltWrap.recordWrapperList = recordWrapperListNew;
    }
    console.log("---rsltWrap--", this.rsltWrap);
  }

  openModal() {
    this.isModalOpen = true;
  }
  closeModal() {
    this.isModalOpen = false;
  }

  checkForModalConfirmation() {
    console.log("---checkForModalConfirmation called--");
    this.isLoaded = false;
    if (this.rsltWrap && this.rsltWrap.recordWrapperList) {
      let recordToUpdate = [];
      this.rsltWrap.recordWrapperList.forEach((element) => {
        if (element.isSelected && element.record.Improvement_Opportunity__c) {
          recordToUpdate.push(element.record);
        }
      });
      this.mappedList = recordToUpdate;
      console.log("---mappedList--", this.mappedList);

      if (this.mappedList.length > 0) {
        this.isLoaded = true;
        this.openModal();
      } else {
        this.submitDetails();
      }
      this.isLoaded = true;
    }
  }

  submitDetails() {
    this.closeModal();
    this.isLoaded = false;
    if (this.rsltWrap && this.rsltWrap.recordWrapperList) {
      let recordToUpdate = [];
      this.rsltWrap.recordWrapperList.forEach((element) => {
        if (element.isSelected) {
          recordToUpdate.push(element.record);
        }
      });
      console.log("---recordToUpdate--", recordToUpdate);

      if (recordToUpdate.length > 0) {
        saveJiraRecords({
          records: recordToUpdate,
          parentID: this.recordId,
          parentType: this.rsltWrap.type,
          requestType: this.requestType
        })
          .then((result) => {
            console.log("---submitDetails--result--", result);
            this.parseSaveResponse(result);
          })
          .catch((error) => {
            this.isLoaded = true;
            console.log("---error--", error);
            let msg =
              "Association of JIRA Request failed, Please contact administrator.";
            this.fireToastEvent("Error Occurred,", msg, "error");
          });
      }
    }
  }

  parseSaveResponse(result) {
    this.isLoaded = true;
    if (result.isSuccess) {
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

  redirectToRecordPage() {
    //Timer Code Starts
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    this.intervalID = setInterval(
      function () {
        this.count++;
        console.log("--count--", this.count);
        if (this.count === this.completed) {
          clearInterval(this.intervalID);
          this.navigateToParentRecord();
        }
      }.bind(this),
      1000
    );
    //Timer Code Ends
  }

  navigateToParentRecord() {
    console.log("--navigateToParentRecord--", this.recordId);
    if (this.recordId) {
      this[NavigationMixin.Navigate]({
        type: "standard__recordPage",
        attributes: {
          recordId: this.recordId,
          objectApiName: this.rsltWrap.typeApiName,
          actionName: "view"
        }
      });
      // Fire the custom event
      const vfPageRedirect = new CustomEvent("redirectToRecord", {
        detail: {
          recordId: this.recordId
        },
        bubbles: true,
        composed: true
      });
      this.dispatchEvent(vfPageRedirect);
    }
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

  get showActions() {
    return this.isRedirect || this.isCancel ? false : true;
  }

  get showRecordTable() {
    return this.rsltWrap &&
      this.rsltWrap.recordWrapperList &&
      this.rsltWrap.recordWrapperList.length > 0
      ? true
      : false;
  }
}
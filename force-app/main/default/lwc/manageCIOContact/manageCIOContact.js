import { LightningElement, wire, track, api } from "lwc";

import getCIODetailForContact from "@salesforce/apex/ManageCIOController.getCIODetailForContact";
import getCIODetailForContactUncached from "@salesforce/apex/ManageCIOController.getCIODetailForContactUncached";
import saveContactInformation from "@salesforce/apex/ManageCIOController.saveContactInformation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class ManageCIOContact extends LightningElement {
  @api recordId;

  @track cioDetail;
  @track conDetail;

  execOptions;

  @track isLoadedSuccess;

  @track showConfirmModal = false;

  //Error handling
  @track hasError = false;
  @track errorMsg;

  @track saveContactCalled = false;
  @track showSuceessToast = false;

  @track valueChanged = false;
  @track showValueChangedError = false;


  @track caseCreated = false;


  @wire(getCIODetailForContact, { contactID: "$recordId" })
  getRecordsCallback({ data, error }) {
    if (data) {
      //console.log("result::::::", data);
      this.parsetheContactDetailResult(data);
    } else if (error) {
      console.log("Returned To JS error", error);
      this.isLoadedSuccess = true;
    }
  }

  refreshContact() {
    if (this.recordId) {
      getCIODetailForContactUncached({ contactID: this.recordId })
        .then((data) => {
          //console.log("result::::::", data);
          this.parsetheContactDetailResult(data);
        })
        .catch((error) => {
          console.log("Returned To JS error", error);
          this.isLoadedSuccess = true;
        });
    }
  }

  parsetheContactDetailResult(data) {
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
      this.conDetail = data.conDetail;
    }
    this.isLoadedSuccess = true;
    
    //console.log("this.execOptions", this.execOptions);
    //console.log("this.conDetail", this.conDetail);

    this.valueChanged = false;
  }

  handleCIOReportChange(event) {
    window.console.log("---handleCIOReportChange called---");
    let name = event.currentTarget.name;
    let value = event.detail.value;
    let conDet = { ...this.conDetail };
    if (conDet ) {
      this.valueChanged =  conDet.Con.Send_CIO_Report__c === value ? false : true;
      //If value changes hide Error
      if(this.valueChanged){
        this.showValueChangedError = false;
      }
      conDet.Send_Exec_Insights = value;
      this.conDetail = conDet;
    }
    window.console.log("---this.con---", this.conDetail);
  }

  resetTheData() {
    window.console.log("---resetTheData called---");
    let conDet = { ...this.conDetail };
    conDet.Send_Exec_Insights = this.conDetail.Con.Send_CIO_Report__c;
    this.conDetail = conDet;
    this.valueChanged = false;
    console.log("---this.conDetail---", this.conDetail);
  }

  saveContact() {
    window.console.log(":::::saveContact called::::::");
    if (this.cioDetail && this.conDetail) {
      //Start Spinner
      this.saveContactCalled = true;
      this.caseCreated = false;

      let cioDet = { ...this.cioDetail };
      cioDet.conDetail = this.conDetail;
      //window.console.log("cioDet::::::", JSON.stringify(cioDet));
      saveContactInformation({ cDetailStr: JSON.stringify(cioDet) })
        .then((result) => {
          console.log("result::::::", result);
          if (result.isSucess === true) {
            this.resetErrorDetails();
            this.closeConfirmModal();

            if(result.isContactUpdated){
              this.openShowSucessToast();
            }

            if(result.isCaseCreated){
              this.caseCreated = true;
            }
            
            this.isLoadedSuccess = false;
            this.refreshContact();
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
    if(this.valueChanged){
      this.resetErrorDetails();
      this.showConfirmModal = true;
      this.showValueChangedError = false;
    }else{
      this.showValueChangedError = true;
    }
  }

  closeConfirmModal() {
    //Close Modal
    this.showConfirmModal = false;
    //Stop Spinner
    this.saveContactCalled = false;
  }

  get willBeCaseCreated() {
    return this.conDetail.MatchesDomainCriteria === false ? true : false;
  }

  get isContactValid() {
    return this.conDetail && this.conDetail.validContact === true
      ? true
      : false;
  }

  get isCaseExist() {
    return this.conDetail && this.conDetail.CaseExist === true ? true : false;
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

  navigateToContactRecord(event) {
    let data = event.currentTarget.dataset;
    window.console.log("conId---", data.conId);
    if (data.conId) {
      window.location.assign("/" + data.conId);
    }
  }

  openShowSucessToast() {
    this.showSuceessToast = true;
    setTimeout(() => {
      this.closeShowSucessToast();
    }, 3000);
  }

  closeShowSucessToast() {
    this.showSuceessToast = false;
  }

  get isDropDownvalueChanged(){
    return this.valueChanged ? true : false;
  }

}
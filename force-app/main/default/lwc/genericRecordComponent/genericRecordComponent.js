import { LightningElement, api, track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getSObjetFieldsFromFieldSet from "@salesforce/apex/recordDetailLWCController.getSObjetFieldsFromFieldSet";
import getSObjectDetails from "@salesforce/apex/recordDetailLWCController.getSObjectDetails";

export default class GenericRecordComponent extends NavigationMixin(
  LightningElement
) {
  @api rtId;
  @api objectApiName;
  @api recordId;

  @api cmptitle;
  @api fldSetAPIName;
  @api cmpReadOnly;
  @api cmpDensity;
  @api cmpColumns;
  @api defaultvals;
  @api relApiName;
  @api relValue;

  //Computed varibales
  @track title;
  @track fldSetWrapper;
  @track fldSetWithDetails = [];

  //For Apex Refresh
  wiredfldresult;

  //Loading
  @track isLoaded = false;
  @track isFormLoaded = false;

  //Error handling
  @track hasError;
  @track errMsg;
  @track errDetail;
  @track showDetailError = false;

  //Edit Form Error Handling
  @track hasErrorEdit;
  @track errMsgEdit;
  @track errDetailEdit;
  @track showDetailErrorEdit = false;
  @track isFormEditLoadAction = false;

  @api sectionExpand = false;

  @track sectionCollapse = false;
  @track sectionBodyCSS = "slds-m-bottom_x-large slds-show";

  @track hasErrorValidationExpected;
  @track hasErrorValidationExpectedMessage;
  @track hasErrorValidationNext;
  @track hasErrorValidationNextMessage;
  @track errMsgProject='';
  @track showErrorMessage='';
  @track errMsgStartDate='';
  @track showErrorMessageStartDate='';
  @wire(getSObjetFieldsFromFieldSet, {
    fieldSetName: "$fldSetAPIName",
    ObjectName: "$objectApiName"
  })
  wiredCallbackResult(result) {
    this.wiredfldresult = result;
    if (result.data) {
      //parse result
      this.parseFldsetWrapper(result.data);
    } else if (result.error) {
      //Set Error Details
      this.isLoaded = true;
      this.hasError = true;
      this.errMsg = "Error Occured, kindly contact the administrator.";
      this.errDetail = result.error;
    }
  }

  connectedCallback() {
    console.log("--recordId---", this.recordId);
    console.log("--objectApiName---", this.objectApiName);
    console.log("--fldSetAPIName---", this.fldSetAPIName);
    console.log("--sectionExpand---", this.sectionExpand);
    console.log("--sectionCollapse---", this.sectionCollapse);
    if (this.sectionExpand) {
      this.sectionCollapse = true;
      this.sectionBodyCSS = "slds-m-bottom_x-large slds-show";
    } else {
      this.sectionCollapse = false;
      this.sectionBodyCSS = "slds-m-bottom_x-large slds-hide";
    }
  }

  renderedCallback() {
    const style = document.createElement("style");
    style.innerText = `.disableSelection .slds-input__icon_right[title="Clear Selection"]{display: none;}`;
    this.template.querySelector("div").appendChild(style);
  }

  loadSobjectFieldsandDetailsAgain() {
    console.log("--loadSobjectFieldsandDetails---");
    getSObjetFieldsFromFieldSet({
      fieldSetName: this.fldSetAPIName,
      ObjectName: this.objectApiName
    })
      .then((result) => {
        //console.log("--loadSobjectFieldsandDetails--result---",result);
        this.parseFldsetWrapper(result);
      })
      .catch((error) => {
        //Set Error Details
        this.isLoaded = true;
        this.hasErrorEdit = true;
        this.errMsgEdit = "Error Occured, kindly contact the administrator.";
        this.errDetailEdit = JSON.stringify(error);
        console.log("----Error--", JSON.stringify(error));
      });
  }

  parseFldsetWrapper(data) {
    console.log("--parseFldsetWrapper--called--");
    let resultWrapper = data;

    if (resultWrapper.hasError) {
      //Set Error Details
      this.isLoaded = true;
      this.hasError = true;
      this.errMsg = resultWrapper.errorMsg;
      this.errDetail = resultWrapper.errorDetail;
    } else {
      //Get Field Set Label
      let fldSetTitle;
      if (resultWrapper.fldSetLabel) {
        fldSetTitle = resultWrapper.fldSetLabel;
      }
      //Set Title
      this.title = this.cmptitle != undefined ? this.cmptitle : fldSetTitle;

      let fld = [];
      resultWrapper.fldList.forEach((ele) => {
        fld.push(ele.fieldAPIName);
      });
      this.fields = fld;
      //console.log("--fields---", JSON.stringify(this.fields));

      if (this.recordId) {
        //Call APEX :: get sObject Record
        getSObjectDetails({
          recordID: this.recordId,
          fldList: fld
        })
          .then((result) => {
            console.log("--getSObjectDetails--result--", result);
            let recordDetail = result;

            //Set values in fldWrapper
            let newFldList = [];
            resultWrapper.fldList.forEach((ele) => {
              let fieldValue;
              if (recordDetail.hasOwnProperty(ele.fieldAPIName)) {
                fieldValue = recordDetail[ele.fieldAPIName];
              }
              newFldList.push({ ...ele, fieldValue });
            });
            console.log("--newFldList--", newFldList);
            this.fldSetWithDetails = newFldList;

            //Reset Error Details
            this.isLoaded = true;
            this.hasError = false;
            this.errMsg = resultWrapper.errorMsg;
            this.errDetail = resultWrapper.errorDetail;
          })
          .catch((error) => {
            this.isLoaded = true;
            this.hasError = true;
            this.errorMessage =
              "Unable to get the record detail. Please contact administrator.";
            this.errDetail = JSON.stringify(error);
            console.log("--error--", JSON.stringify(error));
          });
      } else {
        //Reset Error Details
        this.isLoaded = true;
        this.hasError = false;
        this.errMsg = "";
        this.errDetail = "";

        //Set values in fldWrapper
        let newFldList = [];

        let fields = {};

        resultWrapper.fldList.forEach((ele) => {
          let fieldValue = "";
          if (fields && fields[ele]) {
            fieldValue = fields[ele];
          }
          console.log(ele);
          console.log(ele.fieldType);
          console.log(ele && ele.fieldType && ele.fieldType == 'BOOLEAN');
          if(ele && ele.fieldType && ele.fieldType == 'BOOLEAN'){
            if(!fieldValue){
              fieldValue = false;
            }
            console.log('inside boolean');
          }
          console.log('outside boolean');
          newFldList.push({ ...ele, fieldValue });
        });
        console.log("--newFldList--", newFldList);
        this.fldSetWithDetails = newFldList;
      }
    }
    this.fldSetWrapper = resultWrapper;
  }

  handleEditLoad(event) {
    this.isFormLoaded = true;
  }

  handleReset(event) {
    const inputFields = this.template.querySelectorAll("lightning-input-field");
    if (inputFields) {
      inputFields.forEach((field) => {
        field.reset();
      });
    }
    //Reset Edit Form Error Details
    this.resetEditErrorDetails();
  }

  handleCancel(event) {
    this.dispatchEvent(new CustomEvent("standardcreatecancelevt"));
  }

  handleEditSubmit(event) {
    this.errMsgProject='';
    this.errMsgStartDate='';
    this.hasErrorValidationExpected=false;
    this.hasErrorValidationNext=false;
    this.hasErrorValidationNextMessage=false;
    this.isLoaded = false;
    event.preventDefault();
    const fields = event.detail.fields;
    if (this.rtId) {
      fields.RecordTypeId = this.rtId;
    }
    if (this.defaultvals) {
      this.defaultvals.forEach((el) => {
        if (el && el.name && el.value) {
          fields[el.name] = el.value;
        }
      });
    }
    if (this.relApiName && this.relValue) {
      fields[this.relApiName] = this.relValue;
    }

    console.log('Log 1');
    if(this.fldSetAPIName == 'Project_Fields_New' || this.fldSetAPIName == 'Project_Fields_Edit'){
      var currentDate= new Date();
     
      console.log('Expected Date Field Anup -->'+fields['Project_Completion_Date_Expected__c']);
      console.log('Next Date Field Anup -->'+fields['Next_Step_Completion_Date__c']);
      console.log('Current Date '+ currentDate);
      var expectedDate =new Date(fields['Next_Step_Completion_Date__c']);
      var expectedDate = fields['Project_Completion_Date_Expected__c'];
      var nextDate = fields['Next_Step_Completion_Date__c'];
      var projectStartDate= fields['Project_Start_Date__c'];
      var projectStartDateType = new Date(projectStartDate);
      var nextDateType = new Date(nextDate);
      var expectedDateType = new Date(expectedDate);
      expectedDateType.setHours(0,0,0,0);
      nextDateType.setHours(0,0,0,0);
      currentDate.setHours(0,0,0,0);
      projectStartDateType.setHours(0,0,0,0);
      console.log('expectedDate--->'+expectedDateType);
      console.log('currentDateOnly --->'+currentDate);
      //Added by Ankit - IBA-630 - Start
      var projectStatus = fields['Project_Status__c'];
      //if in Create mode and expectedDateType < currentDate
      if(!this.recordId &&  expectedDateType < currentDate){
        console.log('Log expect');
          this.hasErrorValidationExpected=true;
          this.errMsgProject = 'Expected Date';
      }
      if(!this.recordId &&  nextDateType < projectStartDateType){
        console.log('Log start date');
          this.hasErrorValidationNextMessage=true;
          this.errMsgStartDate='Next step completion date cannot be less than Project start date.';
      }
      if(projectStatus != 'Completed' && nextDateType < currentDate){
        console.log('Log next');
          this.hasErrorValidationNext=true;
          if(this.hasErrorValidationExpected == true){
            this.errMsgProject += ',';
          }
          this.errMsgProject += 'Next Step Completion Date';
      }
      //Added by Ankit - IBA-630 - End

      if(this.hasErrorValidationExpected == true || this.hasErrorValidationNext == true){
        this.errMsgProject += ' cannot be a past date.';
        this.showErrorMessage = true;
        this.isLoaded=true;
      }
      if(this.hasErrorValidationNextMessage == true){
        this.showErrorMessageStartDate = true;
        this.isLoaded=true;
      }
      else{
        this.showErrorMessage = false;
        this.showErrorMessageStartDate=false;
        this.errMsgProject = '';
        this.errMsgStartDate ='';
        this.template.querySelector("lightning-record-edit-form").submit(fields);
      }
    }
    else{
      this.template.querySelector("lightning-record-edit-form").submit(fields);
    }
  }

  handleEditSuccess(event) {
    console.log("--handleEditSubmit called--");

    //this.isLoaded = true;

    //Reset Edit Form Error Details
    this.resetEditErrorDetails();

    // eslint-disable-next-line @lwc/lwc/no-api-reassignments
    this.recordId = event.detail.id;

    const evt = new ShowToastEvent({
      title: "Success:",
      message: "Record has been updated Succesfully.",
      variant: "success"
    });
    this.dispatchEvent(evt);

    //Refresh Data from Apex
    //return refreshApex(this.wiredfldresult);

    this.dispatchEvent(new CustomEvent("standardcreatesaveevt"));
    this.dispatchEvent(new CustomEvent("standardcreatecancelevt"));

    //this.loadSobjectFieldsandDetailsAgain();
  }

  navigateToRecord(event) {
    console.log("--navigateToRecord called--");
    let navigateRecordID = event.target.dataset.targetId;
    console.log("--navigateRecordID--", navigateRecordID);
    if (navigateRecordID) {
      // Navigate to the Record View Page
      this[NavigationMixin.Navigate]({
        type: "standard__recordPage",
        attributes: {
          recordId: navigateRecordID,
          actionName: "view"
        }
      });
    }
  }

  handleEditError(event) {
    console.log("--handleEditError called--");
    this.isLoaded = true;
    console.log("--handleEditError--", JSON.stringify(event.detail));
    const errMessage = event.detail.message;
    const errDet = event.detail.detail;
    if (errMessage != "Cannot read property 'value' of undefined") {
      this.hasErrorEdit = true;
      this.errMsgEdit = errMessage;
      this.errDetailEdit = errDet;
    }
  }

  showDetailErrorMessage() {
    this.showDetailError = true;
  }

  showDetailErrorMessageEdit() {
    this.showDetailErrorEdit = true;
  }

  resetEditErrorDetails() {
    this.hasErrorEdit = false;
    this.errMsgEdit = null;
    this.errDetailEdit = null;
    this.showDetailErrorEdit = false;
  }

  toggleSectionVisibility() {
    if (this.sectionCollapse === true) {
      this.sectionCollapse = false;
      this.sectionBodyCSS = "slds-m-bottom_x-large slds-hide";
    } else {
      this.sectionCollapse = true;
      this.sectionBodyCSS = "slds-m-bottom_x-large slds-show";
    }
  }

  get sectionButtonType() {
    let ret = "utility:chevrondown";
    if (this.sectionCollapse) {
      ret = "utility:chevrondown";
    } else {
      ret = "utility:chevronright";
    }
    return ret;
  }

  get showEditAction() {
    return this.cmpReadOnly === true ? false : true;
  }

  get componentDensity() {
    return this.cmpDensity == undefined ? "auto" : this.cmpDensity;
  }

  get componentColumns() {
    if (this.cmpColumns == undefined) {
      return "slds-col slds-size_1-of-2 slds-p-horizontal_x-small";
    } else {
      if (this.cmpColumns === "1") {
        return "slds-col slds-size_1-of-1 slds-p-horizontal_x-small";
      } else {
        return "slds-col slds-size_1-of-2 slds-p-horizontal_x-small";
      }
    }
  }
}
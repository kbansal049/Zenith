import { LightningElement, track, wire, api } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import USER_ID from "@salesforce/user/Id";
import Case_Object from "@salesforce/schema/Case";
import { getRecord } from "lightning/uiRecordApi";
import getDomainstoExcludeList from "@salesforce/apex/CaseDetailLWCController.getDomains";
import getPortalDetail from "@salesforce/apex/CreateCaseController.getZscalerPortalDetails";
import saveFile from "@salesforce/apex/CreateCaseController.saveFile";
import saveCaseRecord from "@salesforce/apex/CreateCaseController.saveCaseRecord";
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
//import checkAccess from '@salesforce/apex/AiseraChatbotController.accessChatbot';
//import checkCreateCaseAccess from '@salesforce/apex/AiseraChatbotController.createCaseEnabled';
//import getUserDetails from '@salesforce/apex/AiseraChatbotController.getUserDetails';
import { NavigationMixin } from 'lightning/navigation';
//import getSessionCustomSettings from '@salesforce/apex/AiseraChatbotController.getSessionCustomSettings';

const userfieldstoQuery = [
  "User.ContactId",
  "User.Service_Level__c",
  "User.AccountId",
  "User.TimeZoneSidKey",
  "User.Phone",
  "User.Name",
  "User.Preferred_Method_of_Contact__c"
];

export default class caseCreateLWC extends LightningElement {
  //file upload
  @api recordId;
  @api showAccount;
  @api customerPortal; //Added by Anup
  
  @track zOrgId = "";
  @track zOrgPortalName = "";

  @track fileName = "";
  @track UploadFile = "Upload File";
  @track loading = true;
  @track isSubmitted = false;
  @track errmsg = "";
  @track accountId = "";
  @track ContactId = "";
  @track phonenum = "";
  @track timezone = "";
  @track recordTypeId = "";
  @track showPriorityMessage = false;
  @track remChars = "9950 characters remaining";
  @track userId = USER_ID;
  @track contentIds = [];
  @track emailerr = "";
  @track isDeception = false;
  @track hasInterceptAccess = false;
  @track preferredContactMethod = "";
  @track detailsTemplate = '';
  @track defaultTemplate = '';
  @track isZIAZCC=false;
  @track isProblem=false;
  @track showQuestionTypeMessage = false; //Anup - IBA-1758


  filesUploaded = [];
  file;
  fileContents;
  fileReader;
  content;
  MAX_FILE_SIZE = 1500000;
  @track caseRecord = {};
  @track blockedemails = [];

  //Added by Anup - Start
  @track dependentPicklist;

  //Added by Anup - Start
 // @track showCreateCaseError = false;
  @track zacSessionIdSS;
  @track zacSessionIdLS;
  @track urlParameter;
  @track createCaseDisable = false;
  @track loadPage = true;
  @track sessionIdFromCreateCase;
  @track backupUrl = '';
  @track useCustomSessionId = false;
  @track customSessionId;
  
    /* @wire(getSessionCustomSettings)
    sessionCustomSetting({error, data}){
        if(data != undefined){
         this.customSessionId = data.Session_Id__c;
        }
    }*/

 /* @wire(checkCreateCaseAccess)
  checkCreateAccess({ error, data }) {
     this.createCaseDisable = data;
     if(data != undefined){
      if(data != 'No Session Id'){
        this.customSessionId=data;
        if(this.customerPortal == true && this.useCustomSessionId == false){
           if(this.urlParameter!=undefined){
             if(this.urlParameter!=this.customSessionId){
               console.log('URL parameter'+ this.urlParameter);
               this.showCreateCaseError = true;
             }
           }else{
             this.showCreateCaseError = true;
           }
         }

         if(this.showCreateCaseError == true){
            getUserDetails()
            .then(result => {
              var userDetails = result;
              var orgId='';
              if(userDetails.portalDetails.zScalerORGId){
                  orgId=userDetails.portalDetails.zScalerORGId;
              }
              var sessionId2 = Math.random().toString(36).substr(2, 12);
              localStorage.setItem('zacSessionId',sessionId2);
              window.webchat = {
                  sessionId: this.customSessionId,
                  userEmail: userDetails.email,
                  userFullName: userDetails.fullName,
                  accountId: userDetails.accountId,
                  contactId: userDetails.contactId,
                  cloudId: orgId
              }
              var d=document,s=d.createElement('script');
              s.innerText=`loadChat();`
              d.getElementsByTagName('head')[0].appendChild(s);
            })
            .catch(error => {
                this.error = error;
            });
         }else{
          var d=document,s=d.createElement('script');
          s.innerText=`loadChat();`
          d.getElementsByTagName('head')[0].appendChild(s);
         }
      }
      this.loadPage = true;
     }
     
  }*/
    
 /* @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if(this.customerPortal == true){
      if (currentPageReference) {
        const urlValue = currentPageReference.state.sessionId;
        this.urlParameter = urlValue;
        if(localStorage.getItem('zacSessionId')){
          this.zacSessionIdLS = localStorage.getItem('zacSessionId');
        }
        /*if(sessionStorage.getItem('zacSessionId')){
          this.zacSessionIdSS = sessionStorage.getItem('zacSessionId');
        }
      }
    }
  }*/
 //Added by Anup - End


  @wire(getPicklistValuesByRecordType, { objectApiName: Case_Object, recordTypeId: '0120g0000009ujLAAQ' })
  fetchPicklist({error,data}){
    if(data && data.picklistFieldValues){
      this.dependentPicklist = data.picklistFieldValues["Case_Sub_Category__c"];
    }
  }
  //Added by Anup - End

  //Added by Anup - Aisera - Start
 /* @wire(checkAccess)
    checkInterceptAccess({ error, data }) {
        if(data == 'true'){
            if(this.customerPortal == true){
              this.hasInterceptAccess = true;
            }
        }
    }*/
  //Added by Anup - Aisera - End
  
  @wire(getPortalDetail)
  getPortalDetailFromSAML({ data, error }) {
    if (data) {
      console.log("--getPortalDetailFromSAML--", JSON.stringify(data));

      //CR#921
      this.caseRecord["Previous_Zscaler_Org_Id__c"] = data.zScalerORGId;
      this.caseRecord["Previous_Product_Type__c"] = data.zScalerORGPortalName;

      if (data.zScalerORGId) {
        this.zOrgId = data.zScalerORGId;
        this.caseRecord['zscaler_org_id__c'] = this.zOrgId;
      }
      if (data.zScalerORGPortalName) {
        this.zOrgPortalName = data.zScalerORGPortalName;
        this.caseRecord['Product_New__c'] = this.zOrgPortalName;
        if(this.zOrgPortalName == 'Zscaler Deception' && !this.showAccount){
          this.isDeception = true;
        }
      }
    } else if (error) {
      let message = "Unknown error";
      if (Array.isArray(error.body)) {
        message = error.body.map((e) => e.message).join(", ");
      } else if (typeof error.body.message === "string") {
        message = error.body.message;
      }
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error getting Org ID from SAML History.",
          message: "" + message,
          variant: "error"
        })
      );
    }
  }

  @wire(getDomainstoExcludeList)
  domainstoExclude({ data, error }) {
    if (data) {
      this.blockedemails = data;
    } else if (error) {
      this.blockedemails = undefined;
    }
  }

  @wire(getObjectInfo, { objectApiName: Case_Object })
  objectInfo;

  handleFieldChange(e) {
    if(e.currentTarget.fieldName == 'Case_Category__c'){
      this.fetchDependentValue(e.target.value);
    }
    this.caseRecord[e.currentTarget.fieldName] = e.target.value;
    //Added by Anup - Start
    if(e.currentTarget.fieldName == 'Product_New__c'){
      if(e.target.value == 'Zscaler Deception' && !this.showAccount){
        this.isDeception = true;
      }else{
        this.isDeception = false;
      }
    }

    if(e.currentTarget.fieldName == 'Product_New__c'){
      if(e.target.value == 'ZIA' || e.target.value == 'Zscaler Client Connector'){
        this.isZIAZCC = true;
      }else{
        this.isZIAZCC = false;
      }
    }
    if(e.currentTarget.fieldName == 'Case_Type__c'){
      if(e.target.value == 'Problem'){
        this.isProblem = true;
      }else{
        this.isProblem = false;
      }
    }

    if(e.currentTarget.fieldName == 'Priority_Deception__c'){
      if(e.target.value == 'Urgent'){
        this.caseRecord['Priority'] = 'Medium (P3)';
      }
      if(e.target.value == 'Normal'){
        this.caseRecord['Priority'] = 'Low (P4)';
      }

      this.caseRecord[e.currentTarget.fieldName] = e.target.value;
    }
    //Added by Anup - End
    let pathArray = window.location.pathname.split("/");
    let portalname = pathArray[1];
    if (portalname == "partners") {
        if(this.isProblem && this.isZIAZCC){
          this.detailsTemplate = ' 1: Describe the issue:\n 2: Please attach the snapshot depicting the issue.\n 3: Is it impacting a single user/ multiple users/multiple locations:\n 4: Please attach the snapshot of ip.zscaler.com from an affected machine. \n 5: Is Remote assistance to Zscaler Admin UI enabled, Yes/NO: \n 6: If it\'s a performance issue, please share the forward MTR towards the Zscaler data center IP. If there is a tunnel make sure ICMP goes out of the tunnel for MTR.';}
        else{
          this.detailsTemplate = '';
        }
    }
 //Anup - IBA-1758 - Start
    if(e.currentTarget.fieldName == 'Case_Type__c'){
      if(e.target.value == 'Question'){
        this.caseRecord['Priority'] = 'Medium (P3)';
        this.template.querySelector('.Priority').value = 'Medium (P3)';
        this.template.querySelector('.Priority').disabled = true;
        this.showQuestionTypeMessage = true;
      }
      else{
        this.template.querySelector('.Priority').disabled = false;
        this.showQuestionTypeMessage = false;
      }
    }
    //Anup - IBA-1758 - End
  }

  get loadData() {
    // Returns a map of record type Ids
    if (
      this.objectInfo &&
      this.objectInfo.data &&
      this.objectInfo.data.recordTypeInfos
    ) {
      const rtis = this.objectInfo.data.recordTypeInfos;
      this.recordTypeId = Object.keys(rtis).find(
        (rti) => rtis[rti].name === "Support"
      );
    } else if (this.objectInfo && this.objectInfo.data) {
      this.recordTypeId = "$objectInfo.data.defaultRecordTypeId";
    }
    this.caseRecord["RecordTypeId"] = this.recordTypeId;
    if (
      this.recordTypeId &&
      (this.accountId || this.phonenum || this.timezone) &&
      !this.isSubmitted
    ) {
      this.loading = false;
    }
    let pathArray = window.location.pathname.split("/");
    let portalname = pathArray[1];
    if (portalname == "partners") {
      this.showAccount = true;
    }
    return (
      this.recordTypeId && (this.accountId || this.phonenum || this.timezone)
    );
  }

  @wire(getRecord, { recordId: USER_ID, fields: userfieldstoQuery })
  wireuser({ error, data }) {
    if (error) {
      let message = "Unknown error";
      if (Array.isArray(error.body)) {
        message = error.body.map((e) => e.message).join(", ");
      } else if (typeof error.body.message === "string") {
        message = error.body.message;
      }
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error loading Logged in User Request",
          message: "" + message,
          variant: "error"
        })
      );
    } else if (data) {
      this.usrinfo = data;
      /*if (this.usrinfo.fields.AccountId.value) {
        this.accountId = this.usrinfo.fields.AccountId.value;
      }*/
      //CR 2891 Added by Chetan-Start
      let pathArray = window.location.pathname.split("/");
      console.log('HREF-->'+window.location.href);
      let pathArray2 = window.location.href.split("=");
      console.log('Path' +pathArray2);
      let portalname = pathArray[1];
      let accname= pathArray2[1];
      console.log('Account Name-->' + accname);
      console.log('Account Name user-->'+ this.usrinfo.fields.AccountId.value);
      if (portalname == "partners" && accname!=undefined) {
        this.accountId = accname;
        this.caseRecord["AccountId"] = this.accountId;
      }else
      {
        console.log('Account Name else-->');
        this.accountId = this.usrinfo.fields.AccountId.value;
      }
      //CR 2891 Added by Chetan-End
      if (this.usrinfo.fields.ContactId.value) {
        this.ContactId = this.usrinfo.fields.ContactId.value;
      }
      if (this.usrinfo.fields.Phone.value) {
        this.phonenum = this.usrinfo.fields.Phone.value;
        this.caseRecord["Preferred_Contact_Number__c"] = this.phonenum;
      }
      if (this.usrinfo.fields.TimeZoneSidKey.value) {
        this.timezone = this.usrinfo.fields.TimeZoneSidKey.value;
        this.caseRecord["Preferred_Contact_Time_Zone__c"] = this.timezone;
      }
      if(this.usrinfo.fields.Name.value){
        this.userFullName = this.usrinfo.fields.Name.value;
      }
      if(this.usrinfo.fields.Preferred_Method_of_Contact__c.value){
        this.preferredContactMethod = this.usrinfo.fields.Preferred_Method_of_Contact__c.value;
        this.caseRecord["Preferred_Method_of_Contact__c"] = this.preferredContactMethod;
      }
    }
  }

  handleload(event) {
    this.loading = true;
    this.isSubmitted = true;
  }

  handleSubmit(event) {
    let pathArray = window.location.pathname.split("/");
    let portalname = pathArray[1];
    this.checkemail();
    if (this.errmsg) {
      window.scrollTo(0, 0);
      event.preventDefault();
      return;
    }
    this.loading = true;
    this.isSubmitted = true;
    event.preventDefault(); // stop the form from submitting
    const fields = event.detail.fields;
    if ((!this.caseRecord["Description"] || this.caseRecord["Description"] == this.defaultTemplate) && portalname == "partners") {
      this.loading = false;
      this.dispatchEvent(
        new ShowToastEvent({
        title: "Error !",
        message: "Description cannot be blank",
        variant: "error"
        })
    );
    return;
    }
    this.caseRecord["ContactId"] = this.ContactId;
    this.caseRecord["AccountId"] = this.accountId;
    /*if (!this.showAccount) {
      this.caseRecord["AccountId"] = this.accountId;
    }
    if (!fields.AccountId) {
      this.caseRecord["AccountId"] = this.accountId;
    }*/

    let Origin = "";
    if (!this.showAccount) {
      Origin = "Support Portal";
    } else {
      Origin = "Partner Portal";
    }

    this.caseRecord["Origin"] = Origin;
    this.caseRecord["Data_Access_Authorization_Provided__c"] =
      fields.Data_Access_Authorization_Provided__c;

    //console.log('--this.caseRecord--', this.caseRecord)
      saveCaseRecord({ objCase: this.caseRecord, contDocIds: this.contentIds })
      .then((result) => {
        this.loading = true;
        this.recordId = result;
        //this.handleFileSave();
        localStorage.clear();
        this.cancelCase();
        this.navigateToRecordViewPage();
      })
      .catch((error) => {
        // Showing errors if any while inserting the files
        console.log(error);
        if (error) {
          let message = "Error: ";
          if (Array.isArray(error.body)) {
            message += error.body.map((e) => e.message).join(", ");
          } else if (typeof error.body.message === "string") {
            message += error.body.message;
          } else if (
            error.body.pageErrors &&
            error.body.pageErrors[0] &&
            error.body.pageErrors[0].message &&
            error.body.pageErrors[0].message.indexOf("INVALID_MARKUP") != -1
          ) {
            message += "HTML Tags are not supported in Description";
          }
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error Saving Case",
              message: "" + message,
              variant: "error"
            })
          );
        }
        this.loading = false;
      });
    //this.template.querySelector('lightning-record-edit-form').submit(fields);
  }

  handleSuccess(event) {
    localStorage.clear();
  }
  handleError(event) {
    console.log('Handle error Called');
    this.loading = false;
  }
  showtoast(mes) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Case Submitted!",
        message: "" + mes,
        variant: "success"
      })
    );
  }
  cancelCase() {
    this.contentIds = [];
    const inputFields = this.template.querySelectorAll("lightning-input-field");
    if (inputFields) {
      inputFields.forEach((field) => {
        field.reset();
      });
    }
  }

  handleCancel() {
    let pathArray = window.location.pathname.split("/");
    let portalname = pathArray[1];
    window.location = "/" + portalname + "/s/";
  }
  get acceptedFormats() {
    return [".pdf", ".png", ".jpg", ".jpeg"];
  }
  handleFilesChange(event) {
    if (event.target.files.length > 0) {
      this.filesUploaded = event.target.files;
      this.fileName = event.target.files[0].name;
    }
  }
  handleFileSave() {
    if (this.filesUploaded.length > 0) {
      this.uploadHelper();
    } else {
      this.showtoast("Case created successfully");
      this.cancelCase();
      this.navigateToRecordViewPage();
    }
  }
  uploadHelper() {
    this.file = this.filesUploaded[0];
    if (this.file.size > this.MAX_FILE_SIZE) {
      window.console.log("File Size is too long");
      return;
    }
    // create a FileReader object
    this.fileReader = new FileReader();
    // set onload function of FileReader object
    this.fileReader.onloadend = () => {
      this.fileContents = this.fileReader.result;
      let base64 = "base64,";
      this.content = this.fileContents.indexOf(base64) + base64.length;
      this.fileContents = this.fileContents.substring(this.content);

      // call the uploadProcess method
      this.saveToFile();
    };

    this.fileReader.readAsDataURL(this.file);
  }

  saveToFile() {
    saveFile({
      idParent: this.recordId,
      strFileName: this.file.name,
      base64Data: encodeURIComponent(this.fileContents)
    })
      .then((result) => {
        this.fileName = this.fileName + " - Uploaded Successfully";
        this.UploadFile = "File Uploaded Successfully";
        // Showing Success message after file insert
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success!!",
            message: "Case created successfully",
            variant: "success"
          })
        );
        this.cancelCase();
        this.fileName = "";
        this.navigateToRecordViewPage();
      })
      .catch((error) => {
        // Showing errors if any while inserting the files
        if (error) {
          let message = "Error: ";
          if (Array.isArray(error.body)) {
            message = error.body.map((e) => e.message).join(", ");
          } else if (typeof error.body.message === "string") {
            message = error.body.message;
          }
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error while uploading File",
              message: "" + message,
              variant: "error"
            })
          );
        }
      });
  }
  navigateToRecordViewPage() {
    // View a custom object record.
    let pathArray = window.location.pathname.split("/");
    let portalname = pathArray[1];
    window.location = "/" + portalname + "/s/case/" + this.recordId;
  }
  changeProduct(event) {
    if (event.detail.value == "Urgent (P1)") {
      this.showPriorityMessage = true;
    } else {
      this.showPriorityMessage = false;
    }
    this.handleFieldChange(event);
  }
  handleDescchange(event) {
    let desc = event.detail.value;

    if (event.detail.value) {
      desc = "";
      event.detail.value.split("\n").forEach(function (el) {
        if (el) {
          desc += "<p>" + el + "</p>";
        } else {
          desc += "<p>&nbsp;</p>";
        }
      });
      if (desc.length > 9950) {
        this.errmsg = "Description cannot be more than 9950 characters.";
        this.remChars = "Description cannot be more than 9950 characters.";
      } else {
        this.errmsg = "";
        this.remChars = 9950 - desc.length + " characters remaining.";
        this.caseRecord["Description"] = desc;
      }
    } else {
      this.remChars = "9950 characters remaining";
      this.caseRecord["Description"] = desc;
    }
  }
  handleUploadFinish(event) {
    const uploadedFiles = event.detail.files;
    this.loading = false;
    this.isSubmitted = false;
    if (uploadedFiles) {
      uploadedFiles.forEach((file) => {
        this.contentIds.push(file.documentId);
      });
    }
  }
  handleEmailchange(event) {
    this.caseRecord["Customer_CC_List__c"] = event.target.value;
  }
  checkemail() {
    let cclst = this.caseRecord["Customer_CC_List__c"];
    if (cclst) {
      let reg = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,})$/;
      let cclstsplit = cclst.split(" ").join("").split(";");
      let countofsc = (cclst.match(/;/g) || []).length;
      let countofattherate = (cclst.match(/@/g) || []).length;
      if (
        !(countofsc == countofattherate || countofattherate == countofsc + 1)
      ) {
        this.emailerr = "Please seperate the emails by semi-colon";
        this.errmsg = "Please seperate the emails by semi-colon";
        return;
      }
      let publicemail = false;
      let invalid = false;
      for (let em1 in cclstsplit) {
        let em = cclstsplit[em1];
        if (em) {
          if (reg.test(em)) {
            let domain = em.indexOf("@") != -1 ? em.split("@")[1] : "";

            if (domain && this.blockedemails.includes(domain)) {
              this.emailerr = "Public Email domains cannot be entered";
              this.errmsg = "Public Email domains cannot be entered";
              this.showcommentmandatorymessage = true;
              publicemail = true;
              break;
            }
          } else {
            this.emailerr = "Invalid Email";
            this.errmsg = "Invalid Email";
            this.showcommentmandatorymessage = true;
            invalid = true;
            break;
          }
        }
      }
      if (!publicemail && !invalid) {
        if (cclst[cclst.length - 1] != ";") {
          cclst += ";";
        }
        this.caseRecord["Customer_CC_List__c"] = cclst;
        this.emailerr = "";
        this.errmsg = "";
        this.showcommentmandatorymessage = false;
      }
    }
  }


  //Added by Anup - Start
  fetchDependentValue(category){
    const selectedVal = category;
    let controllerValues = this.dependentPicklist.controllerValues;
    this.dependentPicklist.values.forEach(depVal => {
      depVal.validFor.forEach(depKey =>{
        if(depKey === controllerValues[selectedVal]){
          if(category === depVal.label){
            this.template.querySelector('.Case_Sub_Category__c').value = depVal.label;
          }
        }
      });
    });
  }
  //Added by Anup - End
}
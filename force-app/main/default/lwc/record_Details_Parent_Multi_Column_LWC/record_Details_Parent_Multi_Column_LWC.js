import { LightningElement, api, track, wire } from "lwc";
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getSObjetFieldsFromFieldSet from "@salesforce/apex/recordDetailParentLWCController.getSObjetFieldsFromFieldSet";
import getSObjectDetails from "@salesforce/apex/recordDetailParentLWCController.getSObjectDetails";


export default class Record_Details_Parent_Multi_Column_LWC extends NavigationMixin(LightningElement) {

    @api objectApiName;
    @api sObjectNameTemp;
    @api recordId;
    
    @api cmptitle;
    @api fldSetAPIName;
    @api cmpReadOnly;
    @api cmpDensity;
    @api cmpColumns;

    //Computed varibales
    @track title;
    @track fldSetWrapper;
    @track fldSetWithDetails = [];
    @track partnerSdrName;

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

    @track editForm = false;

    @track sectionExpand = true;
    @api sectionCollapse = false;
    @track sectionBodyCSS = "slds-m-bottom_x-large slds-show";

    @wire(getSObjetFieldsFromFieldSet, {
        fieldSetName: "$fldSetAPIName",
        ObjectName: "$sObjectNameTemp"
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
       
        if (this.sectionCollapse) {
            this.sectionExpand = false;
            this.sectionBodyCSS = "slds-m-bottom_x-large slds-hide";
        } else {
            this.sectionExpand = true;
            this.sectionBodyCSS = "slds-m-bottom_x-large slds-show";
        }
    }

    renderedCallback() {
        const style = document.createElement('style');
        style.innerText = `.disableSelection .slds-input__icon_right[title="Clear Selection"]{display: none;}`;
        this.template.querySelector('div').appendChild(style);
    }


    loadSobjectFieldsandDetailsAgain() {
       
        getSObjetFieldsFromFieldSet({
            fieldSetName: this.fldSetAPIName,
            ObjectName: this.sObjectNameTemp
        })
            .then(result => {
                
                this.parseFldsetWrapper(result);
            })
            .catch(error => {
                //Set Error Details
                this.isLoaded = true;
                this.hasErrorEdit = true;
                this.errMsgEdit = "Error Occured, kindly contact the administrator.";
                this.errDetailEdit = JSON.stringify(error);
               
            });
    }




    parseFldsetWrapper(data) {
       
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
            resultWrapper.fldList.forEach(ele => {
                fld.push(ele.fieldAPIName);
            });
            this.fields = fld;
           

            //Call APEX :: get sObject Record
            getSObjectDetails({
                recordID: this.recordId,
                fldList: fld
            })
                .then(result => {
                  
                    let recordDetail = result;
                    if(recordDetail.hasOwnProperty('Sales_Territory__r')){
                        this.partnerSdrName = recordDetail.Sales_Territory__r.Partner_SDR_Name__c;
                        
                    }
                    console.log('***'+JSON.stringify(recordDetail));
                    let newSobj = {};
                    for (let key in recordDetail) {
                        if (recordDetail.hasOwnProperty(key)) {
                            let value = recordDetail[key];
                            if(key.includes('__r')){
                              
                                for (let key2 in value) {
                                    let value2 = value[key2];
                                  
                                    let newKey = key + '.'+ key2;
                                    newSobj[newKey] = value2;
                                }
                            }else{
                               
                                newSobj[key] = value;
                            }
                        }
                    }
                   console.log('newSobj--',newSobj);
                    //Set values in fldWrapper
                    let newFldList = [];
                    resultWrapper.fldList.forEach(ele => {
                        let fieldValue;
                        if (newSobj.hasOwnProperty(ele.fieldAPIName)) {
                            fieldValue = newSobj[ele.fieldAPIName];
                        }
                        newFldList.push({ ...ele, fieldValue });
                    });
                    
                   console.log('newFldList--',newFldList);
                    this.fldSetWithDetails = newFldList;
                    
                    //Reset Error Details
                    this.isLoaded = true;
                    this.hasError = false;
                    this.errMsg = resultWrapper.errorMsg;
                    this.errDetail = resultWrapper.errorDetail;
                })
                .catch(error => {
                    this.isLoaded = true;
                    this.hasError = true;
                    this.errorMessage =
                        "Unable to get the record detail. Please contact administrator.";
                    this.errDetail = JSON.stringify(error);
                 
                });
        }
        this.fldSetWrapper = resultWrapper;
      
    }

    handleEditLoad(event) {
        this.isFormLoaded = true;
    }

    handleReset(event) {
        const inputFields = this.template.querySelectorAll("lightning-input-field");
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
        //Reset Edit Form Error Details
        this.resetEditErrorDetails();
        //Open View Form
        this.editForm = false;
    }

    handleEditSubmit(event) {
        this.isLoaded = false;
        event.preventDefault();
        const fields = event.detail.fields;
        //fields.ZPA_Use_Cases__c = 'dmfgdfggdfgmdg';
        this.template.querySelector("lightning-record-edit-form").submit(fields);
    }

    handleEditSuccess(event) {
      

        //this.isLoaded = true;
        this.editForm = false;

        //Reset Edit Form Error Details
        this.resetEditErrorDetails();

        const evt = new ShowToastEvent({
            title: "Success:",
            message: "Record has been updated Succesfully.",
            variant: "success"
        });
        this.dispatchEvent(evt);
       //Refresh Data from Apex
        //return refreshApex(this.wiredfldresult);
        this.loadSobjectFieldsandDetailsAgain();

    }


    navigateToRecord(event) {
      
        let navigateRecordID = event.target.dataset.targetId;      
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
       
        this.isLoaded = true;
        this.editForm = true;    
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

    setEditFormValue() {
        this.editForm = this.editForm === true ? false : true;
        //Reset Edit Form Error Details
        this.resetEditErrorDetails();
    }

    toggleSectionVisibility() {
        if (this.sectionExpand === true) {
            this.sectionExpand = false;
            this.sectionBodyCSS = "slds-m-bottom_x-large slds-hide";
        } else {
            this.sectionExpand = true;
            this.sectionBodyCSS = "slds-m-bottom_x-large slds-show";
        }
    }

    get sectionButtonType() {
        if (this.sectionExpand) {
            return "utility:chevrondown";
        } else {
            return "utility:chevronright";
        }
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
import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getSObjetFieldsFromFieldSet from "@salesforce/apex/recordDetailLWCController.getSObjetFieldsFromFieldSet";
import getSObjectDetails from "@salesforce/apex/recordDetailLWCController.getSObjectDetails";
import getMainDetails from "@salesforce/apex/CustomPathController.getMainDetails";

export default class GenericRecordEditFormLWC extends LightningElement {

    @api objectApiName;
    @api recordId;
    @api opportunityId;
    @api projectId;
    @api accountId;
    @api recordTypeId;

    @api cmptitle;
    @api fldSetAPIName;
    @api cmpReadOnly;
    @api cmpDensity;
    @api cmpColumns;

    //Computed varibales
    @track title;
    @track fldSetWrapper;
    @track fldSetWithDetails = [];
    @track showTopSites = false;
    @track showAddAnotherButton = false;
    @track countOfSites = 1;
    @track showSecond = false;
    @track showThird = false;
    @track showFourth = false;
    @track showFifth = false;

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
        ObjectName: "$objectApiName"
    })
    wiredCallbackResult(result) {
        console.log('wiredcallbackresult ');
        this.handleSpinnerLoad(true);
        this.wiredfldresult = result;
        if(this.fldSetAPIName==='ZPA_POC_Top_5_Sites'){
            this.showTopSites = true;
            this.showAddAnotherButton = true;
        }
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

    parseFldsetWrapper(data) {
        console.log("--parseFldsetWrapper--called--");
        let resultWrapper = data;

        if (resultWrapper.hasError) {
            //Set Error Details
            //this.isLoaded = true;
            
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
            if(this.recordId){
                getSObjectDetails({
                    recordID: this.recordId,
                    fldList: fld
                })
                    .then(result => {
                        let recordDetail = result;
    
                        //Set values in fldWrapper
                        let newFldList = [];
                        resultWrapper.fldList.forEach(ele => {
                            let fieldValue;
                            if (recordDetail.hasOwnProperty(ele.fieldAPIName)) {
                                fieldValue = recordDetail[ele.fieldAPIName];
                            }
                            newFldList.push({ ...ele, fieldValue });
                        });
                        //console.log("--newFldList--", newFldList);
                        this.fldSetWithDetails = newFldList;
    
                        //Reset Error Details
                        //this.isLoaded = true;
                        console.log('parse 1 ');

                        this.handleSpinnerLoad(false);
                        this.hasError = false;
                        this.errMsg = resultWrapper.errorMsg;
                        this.errDetail = resultWrapper.errorDetail;
                    })
                    .catch(error => {
                        //this.isLoaded = true;
                        console.log('parse 2 ');

                        this.handleSpinnerLoad(true);
                        this.hasError = true;
                        this.errorMessage =
                            "Unable to get the record detail. Please contact administrator.";
                        this.errDetail = JSON.stringify(error);
                        console.log("--error--", JSON.stringify(error));
                    });
            }
            else{
                //Get Some Details - Start
                if(this.fldSetAPIName==='Customer_Information_Area'){
                    getMainDetails({
                        opportunityId: this.opportunityId,
                        projectId: this.projectId
                    })
                    .then(result => {
                        this.opportunityId = result.oppId;
                        this.accountId = result.accId;
                        let newFldList = [];
                
                        resultWrapper.fldList.forEach(ele => {
                            let fieldValue;
                            if(ele.fieldAPIName == 'Opportunity__c' && this.opportunityId){
                                fieldValue = this.opportunityId;
                            }else if(ele.fieldAPIName == 'Project__c' && this.projectId){
                                fieldValue = this.projectId;
                            }
                            else if(ele.fieldAPIName == 'Account__c' && this.accountId){
                                fieldValue = this.accountId;    
                            }
                            newFldList.push({ ...ele, fieldValue });
                        });
                        this.fldSetWithDetails = newFldList;
                        console.log('parse 3 ');

                        this.handleSpinnerLoad(true);
                        this.hasError = false;
                        this.errMsg = resultWrapper.errorMsg;
                        this.errDetail = resultWrapper.errorDetail;
                    })
                    .catch(error => {
                        let newFldList = [];
                
                        resultWrapper.fldList.forEach(ele => {
                            let fieldValue;
                            newFldList.push({ ...ele, undefined });
                        });
                        this.fldSetWithDetails = newFldList;
                        console.log('parse 4 ');

                        this.handleSpinnerLoad(true);
                        this.hasError = false;
                        this.errMsg = resultWrapper.errorMsg;
                        this.errDetail = resultWrapper.errorDetail;
                    });
                }else{
                    let newFldList = [];
                    resultWrapper.fldList.forEach(ele => {
                        let fieldValue;
                        newFldList.push({ ...ele, undefined });
                    });
                    this.fldSetWithDetails = newFldList;
                    console.log('parse 5 ');

                    this.handleSpinnerLoad(true);
                    this.hasError = false;
                    this.errMsg = resultWrapper.errorMsg;
                    this.errDetail = resultWrapper.errorDetail;
                }
                
                //Get Some Details - End
                
            }
            
        }
        this.fldSetWrapper = resultWrapper;
    }

    handleCancel(event){

        if(this.recordId){
            window.open("/"+this.recordId,'_top');
        }
        else if(this.projectId){
            window.open("/"+this.projectId,'_top');
        }
        else if(this.opportunityId){
            window.open("/"+this.opportunityId,'_top');
        }
        
        
    }

    handleSpinnerLoad(loadSpinner){
       //Event - Start
       console.log('Firing event for Spinner from genericRecordEditForm -->'+loadSpinner);
       const custEvent = new CustomEvent(
           'callhandlespinner', {
               detail: loadSpinner,
               bubbles : true,
               composed : true
           });
       this.dispatchEvent(custEvent);
       //Event - End 
    }

    handleOnLoadForm(event){
        console.log(' -- on load of form');
        this.handleSpinnerLoad(false);
        
    }

    handleFormSubmit(event){
        console.log('This is submit event called');
        console.log('recordTypeId :'+this.recordTypeId);
        
        /*if(this.recordTypeId){
            event.preventDefault();
            let fields = event.detail.fields;
            fields.recordTypeId = this.recordTypeId;
            console.log('this is inside RT components');
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }*/
        this.handleSpinnerLoad(true);
    }

    handleFormSubmitSuccess(event){
        console.log('this.recordId before calculating--->'+this.recordId);
        if(this.recordId == null){
            this.recordId = event.detail.id;
        }
        console.log('this.recordId calculated--->'+this.recordId);
        //this.handleSpinnerLoad(true);
        const custEventFormSuccess = new CustomEvent(
            'callformsubmitsuccess', {
                //Change by Chetan-Start
                detail :this.recordId,
                //Change by Chetan-End
                bubbles : true,
                composed : true
            });
        this.dispatchEvent(custEventFormSuccess);
    }

    showDetailErrorMessage() {
        this.showDetailError = true;
    }

    get componentDensity() {
        return this.cmpDensity == undefined ? "auto" : this.cmpDensity;
    }

    get componentColumns() {
        if (this.cmpColumns == undefined) {
            return "slds-col slds-size_1-of-2 slds-p-horizontal_x-small";
        } else {
            if (this.cmpColumns === 1) {
                return "slds-col slds-size_1-of-1 slds-p-horizontal_xxx-large";
            } else {
                return "slds-col slds-size_1-of-2 slds-p-horizontal_x-small";
            }
        }
    }

    handleMoreAddSite(){
        this.countOfSites += 1;
        if(this.countOfSites == 2){
            this.showSecond = true;
        }else if(this.countOfSites == 3){
            this.showThird = true;
        }else if(this.countOfSites == 4){
            this.showFourth = true;
        }else if(this.countOfSites == 5){
            this.showFifth = true;
            this.showAddAnotherButton = false;
        }
        
        
    }
    handleFormSubmitError(event){
        console.log('Error ');

        this.handleSpinnerLoad(false);

    }

}
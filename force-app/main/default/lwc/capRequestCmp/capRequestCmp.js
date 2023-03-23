import { LightningElement, wire, api, track } from 'lwc';
import userId from '@salesforce/user/Id';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPageLayoutFields from '@salesforce/apex/CAPRequestCmpCtrl.getPageLayoutFields';
import getStatusPicklistValue from '@salesforce/apex/CAPRequestCmpCtrl.getStatusPicklistValue';
import getCapRequestStatus from '@salesforce/apex/CAPRequestCmpCtrl.getCapRequestStatus';
import getCapRequestAccountDetails from '@salesforce/apex/CAPRequestCmpCtrl.getCapRequestAccountDetails';
import getDailyNotesData from '@salesforce/apex/CAPRequestCmpCtrl.getDailyNotesData';
import submitForApproval from '@salesforce/apex/CAPRequestCmpCtrl.submitForApproval';
import handleCAPApproval from '@salesforce/apex/CAPRequestCmpCtrl.handleCAPApproval';
import checkIfUserCanApprove from '@salesforce/apex/CAPRequestCmpCtrl.checkIfUserCanApprove';
//import checkIfUserCanSubmit from '@salesforce/apex/CAPRequestCmpCtrl.checkIfUserCanSubmit';
import CAPSetStatus from '@salesforce/apex/CAPRequestCmpCtrl.CAPSetStatus';
import { NavigationMixin } from 'lightning/navigation';


export default class CapRequestCmp extends NavigationMixin(LightningElement) {
    objectApiName = 'CAP_Request__c';
    @api recordId;
    @api parentId;
    @api parentType;
    @api formMode;
    @track saveSpinner= false;
    @track modalLoaded = false;
    @track modalProcessing= false;
    @track isSaveAndExit = false;
    @track pageLayoutSectionFld = {};
    @track pathCurrentStatus='';
    @track currentSubStatus = '';
    @track statusSteps = [];
    @track subStatusSteps = [];
    @track isDisplayLayoutScreen = false;
    message = {};
    @track errorMessage = '';
    @track displayDailyNotes = false;
    @track dataDailyNotes = [];
    @track approvalComments = '';
    @track confirmationModalLoaded = false;
    @track commentModalLoaded = false;
    @track managingApproval = '';
    @track moveToResolved = false;
    @track saveAndRefresh = false;

    columnsDailyNotes = [
        { label: 'Field', fieldName: 'Field_Label__c'},
        { label: 'Original Value', fieldName: 'Old_Value__c'},
        { label: 'New Value', fieldName: 'New_Value__c'},
        { label: 'User', fieldName: 'AddedBy'},
        { label: 'Date', fieldName: 'CreatedDate', type:'date', typeAttributes:{year: "numeric",month: "long",day: "2-digit",hour: "2-digit",minute: "2-digit", timeZone:TIME_ZONE}}
    ];

    get isDailyNotesEmpty() {
        if(this.dataDailyNotes && this.dataDailyNotes.length>0) 
            return false;
        else return true;
    }

    get statusIsSubmitted() {
        if(this.pathCurrentStatus == 'Submitted') {
            return true;
        }
        else return false;
    }

    get statusIsRejected() {
        if(this.pathCurrentStatus == 'Rejected') {
            return true;
        }
        else return false;
    }

    get statusIsClosed() {
        if(this.pathCurrentStatus == 'Closed') {
            return true;
        }
        else return false;
    }

    get approvalStageIsSubmission() {
        if(this.managingApproval == '') 
            return true;
        else if(this.managingApproval == 'Approve' || this.managingApproval == 'Reject')
            return false;
    }

    get isApproveClicked() {
        if(this.managingApproval == 'Approve') {
            return true;
        }
        else if(this.managingApproval == 'Reject') {
            return false;
        }
    }

    get displayPath() {
        if(this.pathCurrentStatus != 'Submitted') {
            return true;
        }
        else return false;
    }

    get displaySubStatusPath() {
        if(this.pathCurrentStatus == 'New') {
            return true;
        }
        else return false;
    }

    get displayThisSection() {
        //Determines if this section should be rendered inside the Record Edit Form or Not
        return true;
    }

    get isClosurePopup() {
        //let statuses = JSON.parse(JSON.stringify(this.statusSteps)); TODAY CHANGES
        let statuses = [...this.statusSteps];
        if((statuses!=undefined && statuses!=[] && this.pathCurrentStatus == statuses[statuses.length-2].value && statuses[statuses.length-1].value=='Closed')) {
            return true;
        }
        else {
            return false;
        }
    }

    get statusIsResolved() {
        if(this.pathCurrentStatus =='Resolved') {
            return true;
        }
        else return false;
    }

    get isResolvedNext() {
        //let statuses = JSON.parse(JSON.stringify(this.statusSteps)); TODAY CHANGES
        let statuses = [...this.statusSteps];
        if(statuses!=undefined && statuses!=[]) {
            let currentKey = 0;
            for(let key in statuses) {
                if(statuses[key].value == this.pathCurrentStatus) {
                    currentKey = key;
                }
            }
            if(Number(currentKey) != Number(statuses.length-1) && statuses[Number(currentKey)+1].value=='Resolved') {
                return true;
            }
            else {
                return false;
            }
        }
        else {
            return false;
        }
    }

    connectedCallback() {
        this.currentSubStatus = 'Customer Information';
        this.connectedHandler();
    }

    connectedHandler() {
        this.saveAndRefresh = false;
        this.displayDailyNotes = false;
        this.saveSpinner = true;
        this.getStatusPicklistValueHandler();
        if(this.recordId!= undefined && this.recordId!='') {
            //Record id is already present, record is opened in Edit Mode.
            this.formMode = 'Edit';
            //Get current status of the CAP Request
            if(!this.moveToResolved){
                this.getCapRequestStatusHandler();
            }
            //Get fields from Page Layout
            this.getPageLayoutFieldsHandler();
        }
        else {
            //Record Id is not present, record is opened in New Mode.
            this.formMode = 'New';
            this.pathCurrentStatus = 'New';
            this.recordId = '';
            //Get fields from Page Layout
            this.getPageLayoutFieldsHandler();
        }
        if(this.parentId && this.parentType && this.parentType == 'Account') {
            //If Origin is account, get account details
            this.getCapRequestAccountDetailsHandler();
        }
    }

    //Get current CAP Request Status
    getCapRequestStatusHandler(){
        getCapRequestStatus({recordId : this.recordId})
        .then(result => {
            if(result) {
                this.pathCurrentStatus = result;
                if(this.pathCurrentStatus == 'In Progress') {
                    this.getDailyNotesDataHandler();
                    this.displayDailyNotes = true;
                }
            }
        })
        .catch(error => {
            this.message = 'Error received: code' + error.errorCode + ', ' +'message ' + error.body.message;
            this.saveSpinner =false;
        });
    }

    //Get Daily Notes
    getDailyNotesDataHandler(){
        getDailyNotesData({recordId : this.recordId})
        .then(result => {
            if(result) {
                for(let key in result) {
                    result[key]['AddedBy'] = result[key].CreatedBy.Name;
                }
                this.dataDailyNotes = result;
            }
        })
        .catch(error => {
            this.message = 'Error received: code' + error.errorCode + ', ' +'message ' + error.body.message;
            this.saveSpinner =false;
        });
    }

    //Get Account Details and pre-populate the fields on CAP Request as per Account's field's values
    getCapRequestAccountDetailsHandler(){
        getCapRequestAccountDetails({accountId : this.parentId})
        .then(result => {
            if(result) {
                let res = JSON.parse(result);
                let pageLayoutSections = this.pageLayoutSectionFld;
                for(let key in pageLayoutSections.lstSections) {
                    if(res.accRecord && res.meta) {
                        for(let key2 in pageLayoutSections.lstSections[key].lstFields) {
                            if(pageLayoutSections.lstSections[key].lstFields[key2].fieldName != null && pageLayoutSections.lstSections[key].lstFields[key2].fieldName != undefined) {
                                if(res.meta[pageLayoutSections.lstSections[key].lstFields[key2].fieldName] != undefined && res.accRecord[res.meta[pageLayoutSections.lstSections[key].lstFields[key2].fieldName]] != undefined) {
                                    pageLayoutSections.lstSections[key].lstFields[key2].fieldValue = res.accRecord[res.meta[pageLayoutSections.lstSections[key].lstFields[key2].fieldName]];
                                }
                                if(pageLayoutSections.lstSections[key].lstFields[key2].fieldName == 'Account__c')
                                    pageLayoutSections.lstSections[key].lstFields[key2].fieldValue = res.accRecord.Id;
                                if(pageLayoutSections.lstSections[key].lstFields[key2].fieldName == 'CAP_Level__c' && (pageLayoutSections.lstSections[key].lstFields[key2].fieldValue == undefined || pageLayoutSections.lstSections[key].lstFields[key2].fieldValue == null)){
                                    pageLayoutSections.lstSections[key].lstFields[key2].fieldValue = 'Level 3';
                                }                           
                            }   
                        }
                    }
                }
            }
        })
        .catch(error => {
            this.message = 'Error received: code' + error.errorCode + ', ' +'message ' + error.body.message;
            this.saveSpinner =false;
        });
    }

    //Get all the status picklist values
    getStatusPicklistValueHandler(){
        getStatusPicklistValue({})
        .then(result => {
            let steps= [];
            this.statusSteps = [];
            if(result) {
                let resultObj = JSON.parse(result);
                for(let key in resultObj) {
                    steps.push({'label':resultObj[key], 'value':key});
                }
                this.statusSteps = steps;
            }
        })
        .catch(error => {
            this.message = 'Error received: code' + error.errorCode + ', ' +'message ' + error.body.message;
            this.saveSpinner =false;
        });
    }

    //Get fields from the Page Layout
    getPageLayoutFieldsHandler(){
        getPageLayoutFields(
            {
                status : this.pathCurrentStatus,
                recordId : this.recordId
            })
        .then(result => {
            this.pageLayoutSectionFld = {};
            let subSteps = [];
            let resultSections = {"lstSections" : []};
            if(result) {
                let res = JSON.parse(result);
                if(res.lstSections && res.lstSections.length>0) {
                    for(let key in res.lstSections) {
                        
                        if(this.pathCurrentStatus == 'New') {
                            if(this.subStatusSteps == undefined || this.subStatusSteps.length == 0) {
                                subSteps.push({'label':res.lstSections[key].label, 'value':res.lstSections[key].label});
                            }
                            if(res.lstSections[key].label == this.currentSubStatus) {
                                for(let key2 in res.lstSections[key].lstFields) {
                                    if(res.lstSections[key].lstFields[key2].fieldName =='Account__c') {
                                        res.lstSections[key].lstFields[key2].isReadOnly = true;
                                    }
                                    if(res.lstSections[key].lstFields[key2].fieldType =='BOOLEAN') {
                                        let boolStr = res.lstSections[key].lstFields[key2].fieldValue;
                                        if(boolStr) {
                                            res.lstSections[key].lstFields[key2].fieldValue = JSON.parse(boolStr.toLowerCase());
                                        } 
                                    }
                                    if(res.lstSections[key].lstFields[key2].fieldType =='DATETIME') {
                                        let dateTimeStr = res.lstSections[key].lstFields[key2].fieldValue;
                                        if(dateTimeStr) {
                                            //let dt = new Date(dateTimeStr);
                                            //res.lstSections[key].lstFields[key2].fieldValue = dt.toISOString();
                                            res.lstSections[key].lstFields[key2].fieldValue = dateTimeStr;
                                        } 
                                    }
                                    if(res.lstSections[key].lstFields[key2].fieldType =='DATE') {
                                        let dateStr = res.lstSections[key].lstFields[key2].fieldValue;
                                        if(dateStr && dateStr != '') {
                                            //let dt = new Date(dateTimeStr);
                                            res.lstSections[key].lstFields[key2].fieldValue = dateStr.split(" ")[0];
                                        } 
                                    }
                                }
                                resultSections.lstSections.push(res.lstSections[key]);
                            }
                        }
                        else {
                            for(let key2 in res.lstSections[key].lstFields) {
                                if(res.lstSections[key].lstFields[key2].fieldName =='Account__c') {
                                    res.lstSections[key].lstFields[key2].isReadOnly = true;
                                }
                                if(res.lstSections[key].lstFields[key2].fieldType =='BOOLEAN') {
                                    let boolStr = res.lstSections[key].lstFields[key2].fieldValue;
                                    if(boolStr) {
                                        res.lstSections[key].lstFields[key2].fieldValue = JSON.parse(boolStr.toLowerCase());
                                    }   
                                }
                                if(res.lstSections[key].lstFields[key2].fieldType =='DATETIME') {
                                    let dateTimeStr = res.lstSections[key].lstFields[key2].fieldValue;
                                    if(dateTimeStr) {
                                        //let dt = new Date(dateTimeStr);
                                        //res.lstSections[key].lstFields[key2].fieldValue = dt.toISOString();
                                        res.lstSections[key].lstFields[key2].fieldValue = dateTimeStr;
                                    }
                                }
                                if(res.lstSections[key].lstFields[key2].fieldType =='DATE') {
                                    let dateStr = res.lstSections[key].lstFields[key2].fieldValue;
                                    if(dateStr && dateStr != '') {
                                        //let dt = new Date(dateTimeStr);
                                        res.lstSections[key].lstFields[key2].fieldValue = dateStr.split(" ")[0];
                                    } 
                                }
                            }
                            resultSections.lstSections.push(res.lstSections[key]);
                        }
                    }
                    if(this.pathCurrentStatus == 'New' && subSteps != undefined && subSteps.length>0 ) {
                        this.subStatusSteps = subSteps;
                    }
                }
                this.modalLoaded = true;
                this.pageLayoutSectionFld = resultSections;
                this.saveSpinner = false;
            }
            else {
                this.modalLoaded = true;
                this.saveSpinner = false;
                this.pageLayoutSectionFld = {};
            }            
        })
        
    }

    //Save and Next Method
    handleSaveAndNext() {
        try {
            if(this.confirmationModalLoaded) {
                //let statuses = JSON.parse(JSON.stringify(this.statusSteps)); TODAY CHANGE
                let statuses = [...this.statusSteps];
                if((statuses!=undefined && statuses!=[] && this.pathCurrentStatus == statuses[statuses.length-2].value && statuses[statuses.length-1].value=='Closed')) {
                    this.confirmationModalLoaded = false;
                }    
            }
            this.saveSpinner = true;
            this.isSaveAndExit = false;
            this.handleSaveButton();
        }
        catch(err) {
            this.modalProcessing = false;
            this.saveSpinner = false;
        }
    }

    handleMoveToResovled() {
        this.moveToResolved = true;
        this.handleSaveAndNext();
    }

    //Save and Exit Method
    handleSaveAndExit() {
        this.isSaveAndExit = true;
        this.handleSaveButton();
    }

    handleSaveAndRefresh() {
        try {
            this.saveAndRefresh = true;
            this.isSaveAndExit = false;
            this.handleSaveButton();
        }
        catch(err) {
            this.modalProcessing = false;
            this.saveSpinner = false;
        }
    }

    // Save method
    handleSaveButton(){
        try {
            const btn = this.template.querySelector( ".hidden-row" );
            if( btn ){ 
                this.saveSpinner = true;
                btn.click().catch(error => {
                    this.saveSpinner = false;
                });
            }
        }
        catch(err) {
            this.modalProcessing = false;
            this.saveSpinner = false;
        }
    }

    showCommentForApproval() {
        this.confirmationModalLoaded = false;
        this.commentModalLoaded = true;
    }

    handleCommentsChange(event){
        this.approvalComments = event.target.value;
        }

    //Cancel Method
    handleCancel() {
        this.hideCreateEditModal();
        if(this.recordId) {
            this.navigateToRecordPage();
        }
        else {
            this.navigateToRelatedList();
        }
        eval("$A.get('e.force:refreshView').fire();");
    }

    handleCancelClosed() {
        this.confirmationModalLoaded=false;
    }

    handleApprovalCancel() {
        this.commentModalLoaded = false;
    }

    handleSubmitForApproval() {
        submitForApproval(
            {
                recordId : this.recordId,
                comments : this.approvalComments
            })
        .then(result => {
            if(result == 'Success') {
                this.modalLoaded = false;
                this.modalProcessing= false;
                this.saveSpinner = false;
                this.showToast('Success', 'CAP Request has been submitted for approval successfully!');
                this.navigateToRecordPage();
                eval("$A.get('e.force:refreshView').fire();");
            } 
        })
        .catch(error => {
            this.message = 'Error received: code' + error.errorCode + ', ' +'message ' + error.body.message;
            this.saveSpinner =false;
        });
    }

    handleApproval() {
        handleCAPApproval(
            {
                recordId : this.recordId,
                response : this.managingApproval,
                comments : this.approvalComments
            })
        .then(result => {
            if(result == 'Success') {
                this.modalLoaded = false;
                this.modalProcessing= false;
                this.saveSpinner = false;
                let toastResponse = this.managingApproval=='Approve'?'Approved':(this.managingApproval=='Reject'?'Rejected':'');
                this.showToast('Success', 'CAP Request has been '+toastResponse+'!');
                this.navigateToRecordPage();
                eval("$A.get('e.force:refreshView').fire();");
            } 
            else {
                this.showToast('error', 'Approval/Rejection of this CAP Request Failed. Please contact your System Administrator.');
            }
        })
        .catch(error => {
            this.message = 'Error received: code' + error.errorCode + ', ' +'message ' + error.body.message;
            this.saveSpinner =false;
        });
    }

    handleCAPRequestReset(){
        this.handleCAPRequestSetStatus('New');
    }

    handleCAPRequestSetStatus(status) {
        CAPSetStatus(
            {
                recordId : this.recordId,
                recordStatus : status
            })
        .then(result => {
            if(result == 'Success') {
                this.pathCurrentStatus = status;
                this.connectedHandler();
            }
        })
        .catch(error => {
            this.message = 'Error received: code' + error.errorCode + ', ' +'message ' + error.body.message;
            this.saveSpinner =false;
        });
    }

    // SUBMITS THE RECORD EDIT FORM
    handleSubmit(event){
        try {
            event.preventDefault();
            this.modalProcessing = true;
            this.saveSpinner = true;
            let fields = event.detail.fields;
            if(this.managingApproval == 'Approve') {
                //let flds = JSON.parse(JSON.stringify(fields)); TODAY CHANGES
                if(fields && fields.CAP_Manager__c != undefined && fields.CAP_Manager__c != null && fields.CAP_Manager__c != '') {
                    this.template.querySelector('.recEditForm').submit(fields);
                }
                else {
                    this.showToast('error','Please populate CAP Manager before Approving this CAP Request!')
                }
                
            }
            else {
                //let flds = JSON.parse(JSON.stringify(fields)); TODAY CHANGES
                if(fields && fields.CAP_CC_List__c!=undefined && fields.CAP_CC_List__c != null && fields.CAP_CC_List__c !='' && fields.CAP_CC_List__c.includes(';')) {
                    this.showToast('error','CAP CC List must contain emails seperated by comma( , ).');
                }
                else {
                    this.template.querySelector('.recEditForm').submit(fields);
                } 
            }
            
        }
        catch(err) {
            this.modalProcessing = false;
        }
    }

    handleSuccess(event){
        try {
            this.modalLoaded = true;
            this.modalProcessing= true;
            this.recordId = event.detail.id;
            if(this.pathCurrentStatus == 'New' && this.isSaveAndExit == false) {
                if(this.subStatusSteps[this.subStatusSteps.length-1].value == this.currentSubStatus) {
                    this.confirmationModalLoaded = true;
                    this.saveSpinner = false;
                }
                else {
                    //let subStatuses = JSON.parse(JSON.stringify(this.subStatusSteps)); TODAY CHANGES
                    let subStatuses = [...this.subStatusSteps];
                    for(let key in subStatuses) {
                        let objSubStatus = {};
                        let objNextSubStatus = {};
                        objSubStatus = subStatuses[key];
                        if((objSubStatus.value == this.currentSubStatus) && (key != subStatuses.length-1)) {
                            objNextSubStatus = subStatuses[Number(key)+1];
                            this.currentSubStatus = objNextSubStatus.value;
                            this.getPageLayoutFieldsHandler();
                            break;
                        }
                    }
                }
            }
            if(this.isSaveAndExit) {
                this.showToast('success','Your CAP Request is saved!');
                this.navigateToRecordPage();
                eval("$A.get('e.force:refreshView').fire();");
            }
            else if(!this.isSaveAndExit){
                if(this.pathCurrentStatus != 'New' && this.pathCurrentStatus != 'Submitted' && this.pathCurrentStatus != 'Rejected' && this.pathCurrentStatus != 'In Progress'){
                    //let statuses = JSON.parse(JSON.stringify(this.statusSteps)); TODAY CHANGES
                    let statuses = [...this.statusSteps];
                    for(let key in statuses) {
                        let obj = {};
                        let objNext = {};
                        obj = statuses[key];
                        if((obj.value == this.pathCurrentStatus) && (key != statuses.length-1)) {
                            objNext = statuses[Number(key)+1];
                            this.handleCAPRequestSetStatus( objNext.value);
                        }
                    }
                }
                else if(this.pathCurrentStatus == 'In Progress' && this.saveAndRefresh) {
                    this.connectedHandler();
                }
                else if(this.pathCurrentStatus == 'In Progress' && !this.saveAndRefresh && this.moveToResolved) {
                    this.pathCurrentStatus = 'Resolved';
                    this.displayDailyNotes = false;
                    this.getPageLayoutFieldsHandler();
                }
                else 
                    this.connectedHandler();
            }
            if(this.managingApproval == 'Approve' || this.managingApproval == 'Reject') {
                this.commentModalLoaded = true;
            }
        }
        catch(err) {
            this.modalProcessing = false;
        }
    }

    handleError(event){
        this.modalLoaded = true;
        this.confirmationModalLoaded = false;
        this.commentModalLoaded = false;
        this.modalProcessing = false;
        this.saveSpinner = false;
        if(event && event.detail && event.detail.detail) {
            this.showToast('error',event.detail.detail);
        }
    }

    handleCloseRequest() {
        this.confirmationModalLoaded = true;
    }

    //Handle Approving the Request
    handleApprove() {
        this.managingApproval = 'Approve';
        this.checkIfUserCanApproveHandler();
    }

    //handle Rejecting the Request
    handleReject() {
        this.managingApproval = 'Reject';
        this.checkIfUserCanApproveHandler();
    }

    handleRejection() {
        if(this.approvalComments == '' || this.approvalComments == undefined) {
            this.showToast('error','Please specify comments before you Reject the CAP Request!');
        }
        else {
            this.handleApproval();
        }

    }

    // Method to hide the Modal
    hideCreateEditModal(){
        this.modalLoaded = false;
    }

    // Method to show Toast
    showToast(title, msg) {
        const event = new ShowToastEvent({
            title: title,
            variant : title,
            message: msg
        });
        this.dispatchEvent(event);
    }

    checkIfUserCanApproveHandler() {
        checkIfUserCanApprove({
            userRecordId : userId,
            recordId : this.recordId
        })
        .then(result => {
            if(result!=undefined) {
                if(result) {
                    this.isSaveAndExit = false;
                    this.handleSaveButton();
                }
                else {
                    this.showToast('error','You don\'t have enough priviledges to Approve/Reject this CAP Request');
                }
            }
        })
        .catch(error => {
            this.message = 'Error received: code' + error.errorCode + ', ' +'message ' + error.body.message;
            this.saveSpinner =false;
        });
    }

    checkIfUserCanSubmitHandler() {
        this.isSaveAndExit = false;
        this.handleSubmitForApproval();
        /*checkIfUserCanSubmit({
            userRecordId : userId
        })
        .then(result => {
            if(result!=undefined) {
                if(result) {
                    this.isSaveAndExit = false;
                    this.handleSubmitForApproval();
                }
                else {
                    this.showToast('error','You don\'t have enough priviledges to submit this CAP Request');
                }
            }
        })
        .catch(error => {
            this.message = 'Error received: code' + error.errorCode + ', ' +'message ' + error.body.message;
            this.saveSpinner =false;
        });*/
    }

    navigateToRecordPage() {
        window.open("/"+this.recordId,'_top');
        //eval("$A.get('e.force:refreshView').fire();");
    }

    navigateToRelatedList() {
        window.open("/"+this.parentId,'_top');
        //eval("$A.get('e.force:refreshView').fire();");
    }
}
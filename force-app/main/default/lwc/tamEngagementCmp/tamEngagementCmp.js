import { LightningElement, api, track } from 'lwc';
import userId from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getStagePicklistValue from '@salesforce/apex/TAMEngagementCmpCtrl.getStagePicklistValue';
import getPageLayoutFields from '@salesforce/apex/TAMEngagementCmpCtrl.getPageLayoutFields';
import getAccountDetails from '@salesforce/apex/TAMEngagementCmpCtrl.getAccountDetails';
import tamEngagementSetStage from '@salesforce/apex/TAMEngagementCmpCtrl.tamEngagementSetStage';
import getTAMEngagementStage from '@salesforce/apex/TAMEngagementCmpCtrl.getTAMEngagementStage';
import checkIfTAMAccount from '@salesforce/apex/TAMEngagementCmpCtrl.checkIfTAMAccount';
import productsValidation from '@salesforce/apex/TAMEngagementCmpCtrl.productsValidation';
import tamEngagementSetProducts from '@salesforce/apex/TAMEngagementCmpCtrl.tamEngagementSetProducts';
import submitForApproval from '@salesforce/apex/TAMEngagementCmpCtrl.submitForApproval';
import handleApprovalResponse from '@salesforce/apex/TAMEngagementCmpCtrl.handleApprovalResponse';
import checkIfUserCanApprove from '@salesforce/apex/TAMEngagementCmpCtrl.checkIfUserCanApprove';
import checkIfUserCanSubmit from '@salesforce/apex/TAMEngagementCmpCtrl.checkIfUserCanSubmit';
import setClosingComments from '@salesforce/apex/TAMEngagementCmpCtrl.setClosingComments';
import getTERecords from '@salesforce/apex/TAMEngagementCmpCtrl.getTERecords';
// IBA - 3334 By Hitesh Sachdeva Starts
import TAMEngagementURL from '@salesforce/label/c.TamEngagementHelpURL';
// IBA - 3334 By Hitesh Sachdeva End


export default class TamEngagementCmp extends LightningElement {

    @api recordId;
    @api parentId;
    @api parentType;
    formMode = '';
    currentStage = '';
    currentStatus = '';
    @track message = {};
    showProductPopup = false;
    @track pageLayoutSectionFld = {};
    showSpinnerProductModal = false;
    showSpinner = false;
    selectedProduct = '';
    @track stageSteps = [];
    clickType = '';
    productSaveNotAvailable = false;
    productErrorMessage = '';
    errorMessage = '';
    formSaveNotAvailable = false;
    disableProceed = false;
    purchasedProducts = '';
    showConfirmationPopup = false;
    showSpinnerConfirmationModal = false;
    confirmationOption = '';
    approvalOption = '';
    commentsValue = '';
    recordsErrorMessage='';
    productNotPurchasedError =false;
    // IBA - 3334 By Hitesh Sachdeva Starts
    helplinkLabel = TAMEngagementURL;
    // IBA - 3334 By Hitesh Sachdeva End
    
    //Getters Start
    get confirmationModalTitle() {
        if(this.confirmationOption == 'Approval') {
            if(this.approvalOption == 'Approve') {
                return 'Approve TAM Engagement';
            }
            else if(this.approvalOption == 'Reject'){
                return 'Reject TAM Engagement';
            }
        }
        else if(this.confirmationOption == 'Close') {
            return 'Close TAM Engagement';
        }
        else if(this.confirmationOption == 'Submit'){
            return 'Submit TAM Engagement';
        }
    }

    get confirmationModalMessage() {
        if(this.confirmationOption == 'Approval') {
            if(this.approvalOption == 'Approve') {
                return 'Are you sure you want to approve this TAM Engagement?';
            }
            else if(this.approvalOption == 'Reject'){
                return 'Are you sure you want to reject this TAM Engagement?';
            }
        }
        else if(this.confirmationOption == 'Close') {
            return 'Are you sure you want to close this TAM Engagement?';
        }
        else if(this.confirmationOption == 'Submit'){
            return 'This TAM Engagement has been saved. Are you sure you want to Submit this TAM Engagement for Approval?';
        }
    }

    get showNextButton() {
        if(this.currentStage.startsWith('STAGE 6') && this.currentStatus =='Completed') {
            return false;
        }
        else {
            return true;
        }
    }

    get showPrevButton() {
        if(this.currentStage.startsWith('STAGE 2')) {
            return true;
        }
        else {
            return false;
        }
    }

    get showLayoutSection() {
        if(Object.keys(this.pageLayoutSectionFld).length === 0) {
            return false;
        }
        else {
            return true;  
        }
    }

    get showSaveButton() {
        if(Object.keys(this.pageLayoutSectionFld).length === 0) {
            return false;
        }
        else {
            if(!this.currentStage.startsWith('STAGE 6')) {
                return true;   
            }
            else return false;
        }
    }

    get showOperationalContactsSection() {
        if(this.currentStage.startsWith('STAGE 1')) {
            return true;
        }
        else {
            return false;
        }
    }

    // IBA - 2844 By Hitesh Sachdeva Starts
    get showTamTaskOppSection() {
        if(this.currentStage.startsWith('STAGE 1')) {
            return true;
        }
        else {
            return false;
        }
    } 
    // IBA - 2844 By Hitesh Sachdeva Ends

    get showChecklistSection() {
        if(
            this.currentStage.startsWith('STAGE 1') ||
            this.currentStage.startsWith('STAGE 2') ||
            this.currentStage.startsWith('STAGE 3') || 
            this.currentStage == 'STAGE 4: Audit' ||
            this.currentStage == 'STAGE 5: Continuous Adoption') {
            return true;
        }
        else {
            return false;
        }
    }

    get showDocumentsSection() {
        if(
            this.currentStage.startsWith('STAGE 2') ||
            this.currentStage.startsWith('STAGE 4')
            ) {
            return true;
        }
        else {
            return false;
        }
    }

    get displayProductErrorMessage() {
        if(this.productErrorMessage == '' || this.productErrorMessage == undefined) {
            return false;
        }
        else {
            return true;
        }
    }

    get displayErrorMessage() {
        if(this.errorMessage == '' || this.errorMessage == undefined) {
            return false;
        }
        else {
            return true;
        }
    }

    get displayRecordErrorMessage() {
        if(this.recordsErrorMessage == '' || this.recordsErrorMessage == undefined) {
            return false;
        }
        else {
            return true;
        }
    }

    get isSubmittedForApproval() {
        if(this.currentStatus == 'Pending Approval') {
            return true;
        }
        else {
            return false;
        }
    }

    get showConfirmationModal() {
        if(this.confirmationOption != '' && this.confirmationOption != undefined) {
            return true;
        }
        else {
            return false;
        }
    }

    get displayConfirmationComments(){
        if(this.approvalOption == 'Reject' || (this.confirmationOption == 'Close') || this.approvalOption == 'Approve') {
            return true;
        }
        else {
            return false;
        }
    }

    get handleCommentsRequired() {
        if(this.approvalOption == 'Reject' || (this.confirmationOption == 'Close')) {
            return true;
        }
        else {
            return false;
        }
    }

    get isNextDisabled() {
        if(this.formSaveNotAvailable) {
            return true;
        }
        else {
            if(this.disableProceed) {
                return true;
            }
            else {
                return false;
            }
        }
    }

    get isPrevDisabled() {
        if(this.formSaveNotAvailable) {
            return true;
        }
        else {
            return false;
        }
    }

    get displayCloseDisclaimer() {
        if(this.currentStage == 'STAGE 6: Business Continuity') {
            if(this.currentStatus == 'Work in Progress' || this.currentStatus == 'Completed') {
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

    get closeDisclaimer() {
        if(this.currentStage == 'STAGE 6: Business Continuity') {
            if(this.currentStatus == 'Work in Progress') {
                return 'If you want to close this TAM Engagement. Please click Next. This record will only be available in read only mode post closure.';
            }
            else if(this.currentStatus == 'Completed') {
                return 'This TAM Engagement has already been completed.';
            }
        }
    }

    get cancelLabel() {
        if(this.currentStage.startsWith('STAGE 6') && this.currentStatus == 'Completed') {
            return 'Go back to Detail';
        }
        else {
            return 'Cancel';
        }
    }
    //Getters End

    connectedCallback() {
        this.connectedHandler();
    }

    connectedHandler() {
            this.confirmationOption = '';
            this.approvalOption = '';
            this.clickType = '';
            this.formSaveNotAvailable = false;
            this.checkIfTAMAccountHandler();
            if(this.recordId!= undefined && this.recordId!='') {
                //Record id is already present, record is opened in Edit Mode.
                this.formMode = 'Edit';
                this.getTAMEngagementStageHandler();
            }
            else {
                //Record Id is not present, record is opened in New Mode.
                this.formMode = 'New';
                this.recordId = '';
                this.currentStage = 'STAGE 1: Onboarding';
                this.currentStatus = 'Work in Progress';
                this.showProductPopup = true;
            }
            this.getStagePicklistValueHandler();
        }


    //Handling Button Clicks Starts
    handleSaveClick() {
        this.clickType = 'save';
        this.handleSave();
    }

    handleNextClick() {
        this.clickType = 'next';
        this.handleSave();
    }

    handlePrevClick() {
        this.clickType = 'prev';
        this.handleSave();
    }

    handlePrevWithoutSaveClick() {
        this.clickType = 'prev';
        this.setNextPreviousStage();
    }

    handleCancel() {
        if(this.recordId) {
            this.navigateToRecordPage();
        }
        else {
            this.navigateToRelatedList();
        }
        eval("$A.get('e.force:refreshView').fire();");
    }

    approvalClicked() {
        this.checkIfUserCanApproveHandler();
        this.approvalOption = 'Approve';
    }

    rejectClicked() {
        this.checkIfUserCanApproveHandler();
        this.approvalOption = 'Reject';
    }

    handleRejection() {
        let msgWord = this.confirmationOption=='Approval'?this.approvalOption:this.confirmationOption;
        if(this.commentsValue == '' || this.commentsValue == undefined) {
            this.showToast('Error','Please specify comments before you '+msgWord +' this TAM Engagement!');
        }
        else {
            if(this.confirmationOption == 'Approval') {
                this.handleApprovalResp('Reject');
            }
            else if(this.confirmationOption == 'Close') {
                this.handleSetClosingComments();
            }
        }
    }

    yesConfirmationClicked() {
        if(this.confirmationOption == 'Submit') {
            this.showSpinnerConfirmationModal = true;
            this.handleSubmitForApproval();
        }
        else if(this.confirmationOption == 'Close') {
            //CLOSE TAM ENGAGEMENT 
            this.handleRejection();
        }
        else if(this.confirmationOption == 'Approval') {
            if(this.approvalOption == 'Approve') {
                this.handleApprovalResp('Approve');
            }
            else if(this.approvalOption == 'Reject'){
                this.handleRejection();
            }
        }
    }

    noConfirmationClicked() {
        this.confirmationOption = '';
        this.approvalOption = '';
        this.commentsValue = '';
    }
    //Handling Button Clicks Ends

    
    //Handling Record Edit Form Events Starts 
    handleSave() {
        try {
            const btn = this.template.querySelector( ".hidden-row" );
            if( btn ){ 
                btn.click();
            }
            else {
                if(this.clickType == 'next') {
                    if((this.currentStatus=='Work in Progress' || this.currentStatus=='Rejected') && (this.currentStage.startsWith('STAGE 2') || this.currentStage.startsWith('STAGE 3') || this.currentStage.startsWith('STAGE 4') || this.currentStage.startsWith('STAGE 5'))) {
                        //NEED TO GO FOR APPROVAL
                        this.checkIfUserCanSubmitHandler();  
                    }
                    else {
                        this.setNextPreviousStage();
                    }
                    if(this.currentStage.startsWith('STAGE 6') && this.currentStatus=='Work in Progress') {
                        this.confirmationOption = 'Close';
                    }
                }
                else if(this.clickType == 'prev') {
                    this.setNextPreviousStage();
                }
            }
        }
        catch(err) {
            console.log('HANDLE SAVE ERRROR', err);
            this.showSpinner = false;
        }
    }

    handleSubmit(event){
        try {
            this.showSpinner = true;
            event.preventDefault();
            let fields = event.detail.fields;
            this.template.querySelector('.recEditForm').submit(fields);
        }
        catch(err) {
            console.log('## ERROR in handleSubmit',err);
            this.showSpinner = false;
        }
    }
    
    handleSuccess(event){
        try {
            this.showSpinner = false;
            this.recordId = event.detail.id;
            if(this.clickType == 'next') {
                if((this.currentStatus=='Work in Progress' || this.currentStatus=='Rejected') && (this.currentStage.startsWith('STAGE 2') || this.currentStage.startsWith('STAGE 3') || this.currentStage.startsWith('STAGE 4') || this.currentStage.startsWith('STAGE 5'))) {
                    //NEED TO GO FOR APPROVAL
                    this.checkIfUserCanSubmitHandler();  
                }
                else {
                    this.setNextPreviousStage();
                }
            }
            else if(this.clickType == 'prev'){
                this.setNextPreviousStage();
            }
            else if(this.clickType == 'save'){
                this.setNextPreviousStage();
            }

            if(this.formMode == 'New') {
                this.handleTAMEngagementSetProducts();
            }
        }
        catch(err) {
            this.showSpinner = false;
        }
    }

    handleError(event){
        this.showSpinner = false;
        if(event && event.detail && event.detail.detail) {
            this.showToast('Error',event.detail.detail);
        }
    }
    
    //Handling Record Edit Form Events Ends
    
    //Utility Methods Starts
    handleCommentsChange(event){
        this.commentsValue = event.target.value;
    }

    setNextPreviousStage() {
        let stages = [...this.stageSteps];
        for(let key in stages) {
            let obj = {};
            let objNext = {};
            obj = stages[key];
            if((obj.value == this.currentStage) && (key != stages.length-1)) {
                if(this.clickType == 'next') {
                    objNext = stages[Number(key)+1];
                }
                else if(this.clickType == 'prev'){
                    this.disableProceed = false;
                    objNext = stages[Number(key)-1];
                }
                else if(this.clickType == 'save') {
                    objNext = stages[Number(key)];
                }
                this.handleTAMEngagementSetStage(objNext.value);
            }
        }
    }
    
    handleSubmitForApproval() {
        submitForApproval(
            {
                recordId : this.recordId,
                comments : this.commentsValue,
                stage : this.currentStage
            })
        .then(result => {
            if(result == 'Success') {
                this.showSpinnerConfirmationModal = false;
                this.confirmationOption = '';
                this.approvalOption = '';
                this.showToast('Success', 'TAM Engagement has been submitted for approval successfully!');
                this.navigateToRecordPage();
                eval("$A.get('e.force:refreshView').fire();");
            } 
        })
        .catch(error => {
            this.message = 'Error received: code' + error.errorCode + ', ' +'message ' + error.body.message;
            this.saveSpinner =false;
        });
    }

    handleApprovalResp(approvalResponse) {
        handleApprovalResponse(
            {
                recordId : this.recordId,
                response : approvalResponse,
                comments : this.commentsValue
            })
        .then(result => {
            if(result == 'Success') {
                this.modalLoaded = false;
                this.modalProcessing= false;
                this.saveSpinner = false;
                this.commentsValue = '';
                let toastResponse = approvalResponse=='Approve'?'Approved':(approvalResponse=='Reject'?'Rejected':'');
                this.showToast('Success', 'TAM Engagement has been '+toastResponse+'!');
                this.navigateToRecordPage();
                eval("$A.get('e.force:refreshView').fire();");
            } 
            else {
                this.showToast('Error', 'Approval/Rejection of this TAM Engagement Failed. Please contact your System Administrator.');
            }
        })
        .catch(error => {
            this.message = 'Error received: code' + error.errorCode + ', ' +'message ' + error.body.message;
            this.saveSpinner =false;
        });
    }

    checkIfUserCanSubmitHandler() {
        checkIfUserCanSubmit({
            userRecordId : userId,
            recordId : this.recordId
        })
        .then(result => {
            if(result!=undefined) {
                if(result == 'Success') {
                    this.confirmationOption = 'Submit';   
                }
                else {
                    this.showToast('Error',result);
                }
            }
        })
        .catch(error => {
            this.message = 'Error received: code' + error.errorCode + ', ' +'message ' + error.body.message;
            this.showSpinner =false;
        });
    }
    
    checkIfUserCanApproveHandler() {
        checkIfUserCanApprove({
            userRecordId : userId,
            recordId : this.recordId
        })
        .then(result => {
            if(result!=undefined) {
                if(result == 'Success') {
                    this.confirmationOption = 'Approval';  
                }
                else {
                    this.showToast('Error',result);
                    this.approvalOption = '';
                }
            }
        })
        .catch(error => {
            this.message = 'Error received: code' + error.errorCode + ', ' +'message ' + error.body.message;
            this.saveSpinner =false;
        });
    }

    getStagePicklistValueHandler(){
            getStagePicklistValue({})
            .then(result => {
                let steps= [];
                this.stageSteps = [];
                if(result) {
                    let resultObj = JSON.parse(result);
                    for(let key in resultObj) {
                        steps.push({'label':resultObj[key], 'value':key});
                    }
                    this.stageSteps = steps;
                }
            })
            .catch(error => {
                this.message = 'Error received: code' + error.errorCode + ', ' +'message ' + error.body.message;
                this.showSpinner =false;
            });
    }

    //Get fields from the Page Layout
    getPageLayoutFieldsHandler(){
        if(!this.currentStage.startsWith('STAGE 6') || (this.currentStage.startsWith('STAGE 6') && this.currentStatus =='Completed')) {
            getPageLayoutFields(
                {
                    stage : this.currentStage,
                    recordId : this.recordId
                })
            .then(result => {
                this.pageLayoutSectionFld = {};
                let resultSections = {"lstSections" : []};
                if(result) {
                    let res = JSON.parse(result);
                    if(res.lstSections && res.lstSections.length>0) {
                        for(let key in res.lstSections) {
                            for(let key2 in res.lstSections[key].lstFields) {
                                if(this.currentStatus == 'Pending Approval') {
                                    res.lstSections[key].lstFields[key2].isReadOnly = true;
                                }
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
                                        let dt = new Date(dateTimeStr);
                                        res.lstSections[key].lstFields[key2].fieldValue = dt.toISOString();
                                    } 
                                }
                                if(res.lstSections[key].lstFields[key2].fieldType =='DATE') {
                                    let dateTimeStr = res.lstSections[key].lstFields[key2].fieldValue;
                                    if(dateTimeStr && dateTimeStr != '') {
                                        //let dt = new Date(dateTimeStr);
                                        res.lstSections[key].lstFields[key2].fieldValue = dateTimeStr.split(" ")[0];
                                    } 
                                }
                            }
                            resultSections.lstSections.push(res.lstSections[key]);
                        }
                    }
                    this.pageLayoutSectionFld = resultSections;
                    if(this.recordId=='' && this.parentId && this.parentType && this.parentType == 'Account') {
                        //If Origin is account, get account details
                        this.getAccountDetailsHandler();
                    }
                    if(this.showChecklistSection){
                        this.template.querySelector('c-tam-engagement-checklist-cmp').init();
                    }
                }
                else {
                    this.pageLayoutSectionFld = {};
                }  
                this.showSpinner = false;          
            }) 
        }
        
          
    }

    //Get Account Details and pre-populate the fields on CAP Request as per Account's field's values
    getAccountDetailsHandler(){
        getAccountDetails({accountId : this.parentId})
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
                                if(pageLayoutSections.lstSections[key].lstFields[key2].fieldName == 'Account__c') {
                                    pageLayoutSections.lstSections[key].lstFields[key2].fieldValue = res.accRecord.Id;
                                }
                            }   
                        }
                    }
                }
            }
        })
        .catch(error => {
            this.message = 'Error received: code' + error.errorCode + ', ' +'message ' + error.body.message;
            this.showSpinner =false;
        });
    }

    //Get all the stage picklist values
    getStagePicklistValueHandler(){
        getStagePicklistValue({})
        .then(result => {
            let steps= [];
            this.stageSteps = [];
            if(result) {
                let resultObj = JSON.parse(result);
                for(let key in resultObj) {
                    steps.push({'label':resultObj[key], 'value':key});
                }
                this.stageSteps = steps;
            }
        })
        .catch(error => {
            this.message = 'Error received: code' + error.errorCode + ', ' +'message ' + error.body.message;
            this.showSpinner =false;
        });
    }
    
    handleTAMEngagementSetStage(stage) {
        tamEngagementSetStage(
            {
                recordId : this.recordId,
                recordStage : stage
            })
        .then(result => {
            if(result == 'Success') {
                this.currentStage = stage;
                this.connectedHandler();
            }
        })
        .catch(error => {
            this.message = 'Error received: code' + error.errorCode + ', ' +'message ' + error.body.message;
            this.showSpinner =false;
        });
    }

    handleTAMEngagementSetProducts() {
        tamEngagementSetProducts(
            {
                recordId : this.recordId,
                selectedProduct : this.selectedProduct
            })
        .then(result => {
            if(result == 'Success') {

            }
        })
        .catch(error => {
            this.message = 'Error received: code' + error.errorCode + ', ' +'message ' + error.body.message;
            this.showSpinner =false;
        });
    }

    getTAMEngagementStageHandler(){
        getTAMEngagementStage({recordId : this.recordId})
        .then(result => {
            if(result) {
                this.currentStage = result.stage;
                this.currentStatus = result.status;
                this.selectedProduct = result.product;
                this.getPageLayoutFieldsHandler();
            }
        })
        .catch(error => {
            this.message = 'Error received: code' + error.errorCode + ', ' +'message ' + error.body.message;
            this.showSpinner =false;
        });
    }

    checkIfTAMAccountHandler() {
            checkIfTAMAccount({recordId : this.parentId})
            .then(result => {
                if(result=='' || result == undefined) {
                    this.productSaveNotAvailable = true;
                    this.formSaveNotAvailable = true;
                    this.productErrorMessage = 'Primary TAM is not available on this Account!';
                    this.errorMessage = 'Primary TAM is not available on this Account!';
                    //this.showToast('Error','Primary TAM is not available on this Account!');
                }    
            })
            .catch(error => {
                this.message = 'Error received: code' + error.errorCode + ', ' +'message ' + error.body.message;
                this.showSpinner =false;
            });
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

    callFromDocWizard(event){
        this.callChecklistChild();
    }

    callChecklistChild(){
        if(this.recordId != '' && this.recordId != undefined) {
            this.template.querySelector('c-tam-engagement-checklist-cmp').init();
        }
    }

    callFromOperationalContacts(event){
        this.callOperationalContacts();
    }

    callOperationalContacts(){
        this.template.querySelector('c-tam-engagement-checklist-cmp').init();
    }

    callFromChecklist(event) {
        this.evaluateChecklist(event.detail);
    }

    evaluateChecklist(obj) {
        if(obj) {
            let checklistStatusMap = obj.checklistStatusMap;
            let arrChecklist = obj.stageChecklist;
            let flag = true;
            for(let index in arrChecklist) {
                if(!checklistStatusMap[arrChecklist[index]]) {
                   flag = false;
                }
            }
            if( this.currentStage == 'STAGE 1: Onboarding' || 
                this.currentStage == 'STAGE 2: Establish Alignment' || 
                this.currentStage == 'STAGE 3: Adoption Acceleration/Operation Excellence' ||
                this.currentStage == 'STAGE 4: Audit' ||
                this.currentStage == 'STAGE 5: Continuous Adoption') {
                this.disableProceed = !flag;
            }
        }  
    }

    handleSetClosingComments() {
        setClosingComments(
            {
                recordId : this.recordId,
                comments : this.commentsValue
            })
        .then(result => {
            if(result == 'Success') {
                this.showToast('Success', 'This TAM Engagement has been completed successfully!');
                this.connectedHandler();
            }
        })
        .catch(error => {
            this.message = 'Error received: code' + error.errorCode + ', ' +'message ' + error.body.message;
            this.showSpinner =false;
        });
    }
    //Utility Methods Ends


    //Navigation Methods Starts
    navigateToRecordPage() {
        window.open("/"+this.recordId,'_top');
        //eval("$A.get('e.force:refreshView').fire();");
    }

    navigateToRelatedList() {
        window.open("/"+this.parentId,'_top');
        //eval("$A.get('e.force:refreshView').fire();");
    }
    //Navigation Methods Ends

    // Product Selection Methods Starts
    handleProductSave(){
        try {
            const btn = this.template.querySelector( ".hidden-row-product" );
            if( btn ){ 
                btn.click();
            }
        }
        catch(err) {
            this.showSpinnerProductModal = false;
        }
    }

    handleProductSubmit(event){
        try {
            event.preventDefault();
            let fields = event.detail.fields;
            if(fields && fields.Product__c != undefined && fields.Product__c != null && fields.Product__c != '') {
                this.selectedProduct = fields.Product__c;
                this.handleProductsValidation();
            }
        }
        catch(err) {
            this.showSpinnerProductModal = false;
        }
    }

    handleProductsValidation() {
        this.productErrorMessage= '';
        productsValidation({selectedProducts : this.selectedProduct, recordId : this.parentId})
        .then(result => {
            let productsNotPurchased = [];
            if(result != undefined) {
                let selectedProdArr = this.selectedProduct.split(';');
                for(let index in selectedProdArr) {
                    if(result[selectedProdArr[index]] == undefined || result[selectedProdArr[index]] == 0) {
                        productsNotPurchased.push(selectedProdArr[index]);
                    }
                }
            }
            if(productsNotPurchased.length == 0) {
                this.productNotPurchasedError  = false;
            }
            else {
                if(productsNotPurchased.length!=0){
                    this.productNotPurchasedError  = true;
                    //Changed product multipicklist to picklist as part of IBA-3370
                    //this.productErrorMessage = 'The product(s) {'+productsNotPurchased.join() +'} you selected have not been purchased by the Customer!';
                    this.productErrorMessage = 'The product ('+productsNotPurchased.join() +') you selected has not been purchased by the Customer!';
                }
            }
            this.getTERecordsHandler()
        })
        .catch(error => {
            this.message = 'Error received: code' + error.errorCode + ', ' +'message ' + error.body.message;
            this.showSpinner =false;
        });
    }
    // Product Selection Methods Ends
    getTERecordsHandler() {
        getTERecords({selectedProducts : this.selectedProduct, recordId : this.parentId})
        .then(result => {
            let productsTEExists = [];
            let selectedProdArr = this.selectedProduct.split(';');
            if(result != undefined) {
                for(let index in result) {
                    let splittedProducts = result[index].Product__c.split(';');
                    for(let i in splittedProducts){
                        if(!productsTEExists.includes(splittedProducts[i])){
                            productsTEExists.push(splittedProducts[i])
                        }
                    }
                }
            }
            const recordFound = productsTEExists.some(item => selectedProdArr.includes(item))
            const filteredProducts = productsTEExists.filter(value => selectedProdArr.includes(value));
            if(recordFound && filteredProducts.length!=0){
                //Changed product multipicklist to picklist as part of IBA-3370
                //this.recordsErrorMessage = 'Selected product(s) {'+filteredProducts+'} already has an TAM engagement request open. Please continue with request for a product which is not associated to an in progress TAM Engagement request.';
                this.recordsErrorMessage = 'Selected product ('+filteredProducts+') already has an TAM engagement request open. Please continue with request for a product which is not associated to an in progress TAM Engagement request.';
            }
            else{
                this.recordsErrorMessage='';
                if(this.productNotPurchasedError == false) {
                 this.productErrorMessage = '';
                this.recordsErrorMessage = '';
                this.showSpinnerProductModal = true;
                this.showSpinner = true;
                this.showProductPopup = false;
                this.currentStage = 'STAGE 1: Onboarding';
                this.getPageLayoutFieldsHandler();
                }
            
            }
        })
        .catch(error => {
            this.message = 'Error received: code' + error.errorCode + ', ' +'message ' + error.body.message;
            this.showSpinner =false;
        });
    }

    // IBA - 3334 By Hitesh Sachdeva Starts
    helpTab() {
        window.open(this.helplinkLabel, "_blank");       
    }
    // IBA - 3334 By Hitesh Sachdeva End
    
}
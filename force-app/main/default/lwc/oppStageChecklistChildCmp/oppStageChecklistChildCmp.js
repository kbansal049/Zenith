import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { deleteRecord } from 'lightning/uiRecordApi';
import { getRecord, getRecordNotifyChange, updateRecord, getFieldValue } from 'lightning/uiRecordApi';
import ID_FIELD from '@salesforce/schema/Opportunity.Id';
import SUBSTAGE_FIELD from '@salesforce/schema/Opportunity.Sub_Stage__c';
import { createRecord } from 'lightning/uiRecordApi';
import linkFileURLtoOpportunity from '@salesforce/apex/OppStageChecklistController.linkFileURLtoOpportunity';
import unlinkFileURLFromOpportunity from '@salesforce/apex/OppStageChecklistController.unlinkFileURLFromOpportunity';
import updateStage from '@salesforce/apex/OppStageChecklistController.updateOpportunityStage';
import getSolutionMappings from '@salesforce/apex/OppStageChecklistController.getSolutionMapping';
import getValidationDependencies from '@salesforce/apex/OppStageChecklistController.getValidationDependencies';
import VALIDATION_STAGE from '@salesforce/schema/Opportunity.Validation_Stage__c';
const FIELDS = ['Opportunity.Name', STAGE_NAME, SOLUTION, BUYER_INITIATIVE, VALIDATION_STAGE, DOC_TYPE, FLEXI_ID, PC, SC, OPC, OSC, RSCD];
import TYPE from '@salesforce/schema/Opportunity.Type';
import VALIDATED_PARTNER from '@salesforce/schema/Opportunity.Validated_Solution_Tech_Partner__c';
import RSCD from '@salesforce/schema/Opportunity.Requires_signing_customer_documents__c'
import SOLUTION from '@salesforce/schema/Opportunity.Solution__c';
import BUYER_INITIATIVE from '@salesforce/schema/Opportunity.Buyer_Initiative__c';
import STAGE_NAME from '@salesforce/schema/Opportunity.StageName';
import DOC_TYPE from '@salesforce/schema/Opportunity.What_Type_of_doc__c';
import PIPELINE_STAGE from '@salesforce/label/c.Stage_0_Pipeline_Generation';
import PRIMARY_COMPETITOR_BLANK from '@salesforce/label/c.PrimaryCompetitorCantBeBlank';//IBA-1884
import CUSTOMER_DOCS from '@salesforce/schema/Opportunity.Require_Customer_Docs_to_be_submitted__c';
import FLEXI_ID from '@salesforce/schema/Opportunity.Flexible_Identifier__c';
import PC from '@salesforce/schema/Opportunity.Primary_Competitor__c';
import SC from '@salesforce/schema/Opportunity.Secondary_Competitors__c';
import OPC from '@salesforce/schema/Opportunity.Other_Primary_competitor__c';
import OSC from '@salesforce/schema/Opportunity.Other_Secondary_competitor__c';



export default class OppStageChecklistChildCmp extends NavigationMixin(LightningElement) {
    @api recordId;
    @api recordTypeId;
    @api fieldName;
    @api fieldType;
    @api fieldLabel;
    @api fileName;
    @api fileId;
    @api fieldVal;
    @api errMsg;
    @api allowedValues;
    @api dependentFields;
    @track fieldDependencies = [];
    @track churnReason;
    @track churnDetails;
    @track revisitValue;
    @track validatedSolutionTechPartner;
    @track requiresSigningCustomerDocuments;
    recursiveFlag = true;

    @track isSpinnerLoading = true;
    @track HasError = false;
    @track ErrorMsg;
    @track displayChildFields = false;
    @track loadedFiles = [];
    @track oldValStage;
    @track otherType;
    @track textVal;
    @track fieldDependency;
    @track isNext = false;
    @track showBack = false;
    @track renderLossFormType;
    @track subStageValue;
    @track competitiveDeal;
    @track pcVal;
    @track scVal;
    @track lossForm;
    @track reason;
    @track biOptions = [];
    @track solutionVal;
    solutionMapping = new Map();
    @track buyerVal = [];
    @track endDateRequired = false;
    @track validationDependencies = [];
    @track validationData = [];
    @track opportunity;
    @track stageVal;
    @track closedLostComment;
    @track isCustomerDocs = false;
    @track showOverage = false;
    @track overageReason;
    flexi_identifier;
    @track requireLostComment = false;
    isShowPrimaryOther = false;
    isShowSecondaryOther = false;
    otherPrimaryCompetitor;
    otherSecondaryCompetitor;
    isShowCompetitors = true;
    isStageZero = false;
    disableNextButton = false; //IBA-1884
    @wire(getRecord, {
        recordId: '$recordId',
        fields: FIELDS,
        modes: ['View', 'Edit', 'Create']
    })
  
    wiredRecord({
        error,
        data
    }) {
        if (error) {
            console.log('error--->',error);
        }
        else if (data) {
            console.log('data--->',data);
            this.opportunity = data;
            this.flexi_identifier =  data.fields.Flexible_Identifier__c.value;
            
            if(data.fields.Primary_Competitor__c.value){
                this.pcVal = data.fields.Primary_Competitor__c.value;
                if(this.pcVal === 'Other'){
                    this.isShowPrimaryOther = true;
                    if(data.fields.Other_Primary_competitor__c.value){
                        this.otherPrimaryCompetitor = data.fields.Other_Primary_competitor__c.value;
                    }
                }
            }
            if(data.fields.Secondary_Competitors__c.value){
                this.scVal = data.fields.Secondary_Competitors__c.value;
                if(this.scVal && this.scVal.includes('Others')){
                    this.isShowSecondaryOther = true;
                    if(data.fields.Other_Secondary_competitor__c.value){
                        this.otherSecondaryCompetitor = data.fields.Other_Secondary_competitor__c.value;
                    }
                }
            }
            if(data.fields.Requires_signing_customer_documents__c.value){
                this.requiresSigningCustomerDocuments = data.fields.Requires_signing_customer_documents__c.value;
            }
        }
    }

    connectedCallback() {
        
        if (this.dependentFields != undefined && ((this.allowedValues == undefined) || (this.allowedValues != undefined
            && this.allowedValues.includes(this.fieldVal) && !this.fieldVal.includes('Not Required')))) {
            this.fieldDependency = true;
            this.dependentFields.split(',').forEach(item => this.fieldDependencies.push({ fieldName: item.split(':')[0], isFile: item.split(':')[1] == 'true' ? true : false, fieldLabel: item.split(':')[2] }));
            
            console.log('--fieldDependencies--' + JSON.stringify(this.fieldDependencies));
        }
        if (this.fieldName == 'Validation_Stage__c') {
            this.isSpinnerLoading = true;
            this.fieldDependency = true;
            this.loadValidationStageFields();
        }


    }

    loadDocTypes(){
        let docType = getFieldValue(this.opportunity,DOC_TYPE);
        console.log('--docType--'+docType);
        this.isSpinnerLoading = true;
        if( docType != undefined && docType.includes('NDA') == true && !this.dependentFields.includes('Does_Doc_Require_Signature__c')){
            this.fieldDependencies.push({ fieldName: 'Does_Doc_Require_Signature__c', isFile: false, fieldLabel: 'Does Documents Require Signature?' });
            this.dependentFields += ',Does_Doc_Require_Signature__c';
        }
        this.isSpinnerLoading = false;
    }

    loadValidationStageFields() {
        this.oldValStage = getFieldValue(this.opportunity, VALIDATION_STAGE);
        getValidationDependencies({
            oppId: this.recordId,
        }).then(data => {
            console.log('getValidationDependencies Success++'); 
            this.validationData = data;
            data.forEach(item => {
                
                this.validationDependencies.push({
                    fieldName: item.fieldName, fieldLabel: item.fieldLabel, isFile: item.isFile,
                    fileName: item.fileName, fileId: item.fileId, isRequired: item.isRequired, loadedFiles: [],
                    secondFieldLabel: item.secondFieldLabel, secondFieldName: item.secondFieldName,
                });
            });
            this.isSpinnerLoading = false;
            console.log('this.validationDependencies. Success++'+this.validationDependencies);
            
            console.log('this.oldValStage'+this.oldValStage);
        }).catch(error => {
            console.log('Exception:', error);
            this.isSpinnerLoading = false;
        });
    }

    handleClosedLostComment(event){
        this.closedLostComment = event.detail.value;
    }

    handleValidationStage(event) {
        
        let val = event.detail.value;
        console.log(val);
        let startDate = this.template.querySelector("[data-name='Technical_Validation_Start_Date__c']");
        let endDate = this.template.querySelector("[data-name='Validation_End_Date__c']");

        if(val != '' && (val == '1 - Establishing Plan & success criteria' || val == '8 - Not Required' || val == '8B - Not Required - Preferred')){
            
            endDate.required = false;
            startDate.required = false;
            endDate.value = null;
            startDate.value = null;
        }
        else if(val != '' && val == '2 - Configuration in Progress'){
            
            endDate.required = true;
            startDate.required = false;
           
        }
        else if (val != '' && (val == '3 - Detailed validation in progress' || val == '4 - Delivering validation findings report' || val == '5 - Validation Stalled' || val == '5b - Pending customer decision')) {
            endDate.required = true;
            startDate.required = true;

        }else if(val != '' && (val == '6 - Technical Win' || val == '7 - Technical Loss')){
            
           
          
            endDate.required = true;
            startDate.required = true;
           endDate.value = new Date().toISOString();
            
            
        }else{
            endDate.required = false;
            
            startDate.required = false;
           
        }

        
    }
    handleReasonChange(event) {
        this.reason = event.detail.value;
        if (this.reason != undefined) {
            this.HasError = false;
            this.ErrorMsg = '';
        }
        if(this.reason == 'Other'){	
            this.requireLostComment = true;	
        }else{	
            this.requireLostComment = false;	
        }
    }

    handleChange(event) {
        let val = event.detail.value;
        let fieldName = event.currentTarget.dataset.name;
        console.log('--this.dependentFields--' + this.dependentFields);
        console.log('--this.allowedValues--' + this.allowedValues);
        console.log('--this.dependentFields--'+this.dependentFields);
        console.log('--val--' + val);
        this.isSpinnerLoading = true;
        if (this.dependentFields != undefined && ((this.allowedValues == undefined) || (this.allowedValues != undefined && this.allowedValues.includes(val) && !val.includes('Not Required')))) {
            this.fieldDependency = true;
            this.fieldDependencies = [];
            this.dependentFields.split(',').forEach(item => this.fieldDependencies.push({ fieldName: item.split(':')[0], isFile: item.split(':')[1] == 'true' ? true : false, fieldLabel: item.split(':')[2] }));

        } else if (fieldName != undefined && fieldName == this.fieldName) {
            this.fieldDependency = false;
        }
        this.textVal = val;
        console.log('--fieldName--' + this.fieldName);
        if (fieldName != undefined && fieldName == 'What_Type_of_doc__c' && val != undefined && val.includes('NDA') && !this.dependentFields.includes('Does_Doc_Require_Signature__c')) {
            this.fieldDependencies.push({ fieldName: 'Does_Doc_Require_Signature__c', isFile: false, fieldLabel: 'Does Documents Require Signature?' });
            this.dependentFields += ',Does_Doc_Require_Signature__c';
        } else if (fieldName != undefined && fieldName == 'What_Type_of_doc__c' && val != undefined && !val.includes('NDA') && this.dependentFields.includes('Does_Doc_Require_Signature__c')) {
            this.dependentFields = this.dependentFields.replace(',Does_Doc_Require_Signature__c', '');
            this.fieldDependencies.pop();
            this.fieldDependency = false;
        }else if(fieldName != undefined && fieldName == 'What_Type_of_doc__c' && val != undefined && val.includes('NDA') && this.dependentFields.includes('Does_Doc_Require_Signature__c')){
            this.fieldDependencies = [];
            this.dependentFields.split(',').forEach(item => this.fieldDependencies.push({ fieldName: item.split(':')[0], isFile: item.split(':')[1] == 'true' ? true : false, fieldLabel: item.split(':')[2] }));
            this.fieldDependency = true;
        }
        this.isSpinnerLoading = false;
        
    }

    handleSubChange(event) {
        const subFieldName = event.currentTarget.dataset.name;
        console.log('--subFieldName--' + subFieldName);
        let val = event.detail.value;
        this.isSpinnerLoading = true;
        if (subFieldName != undefined && subFieldName == 'What_Type_of_doc__c' && val != undefined && val.includes('NDA') && !this.dependentFields.includes('Does_Doc_Require_Signature__c')) {
            this.fieldDependencies.push({ fieldName: 'Does_Doc_Require_Signature__c', isFile: false, fieldLabel: 'Does Documents Require Signature?' });
            this.dependentFields += ',Does_Doc_Require_Signature__c';
        } else if (subFieldName != undefined && subFieldName == 'What_Type_of_doc__c' && val != undefined && !val.includes('NDA') && this.dependentFields.includes('Does_Doc_Require_Signature__c')) {
            this.dependentFields = this.dependentFields.replace(',Does_Doc_Require_Signature__c', '');
            this.fieldDependencies.pop();
        }else if(subFieldName == 'Competitor__c' && val != undefined && val.includes('Other')){
            let isFound = false;
            this.validationDependencies.forEach(item => {
                if(item.fieldName == 'Other_Competitors__c')
                    isFound = true;
            });
            if(!isFound){
                this.validationDependencies.push({ fieldName: 'Other_Competitors__c', fieldLabel: 'Other Competitors', isRequired: true, isFile: false, fileName:'', fileId:'' });
            }
        }else if(subFieldName == 'Competitor__c' && val != undefined && !val.includes('Other')){
            let OtherKey;
            this.validationDependencies = this.validationDependencies.filter(function( obj ) {
                return obj.fieldName !== 'Other_Competitors__c';
            });
        }
        this.isSpinnerLoading = false;
    }

    handleControlling(event) {
        let val = event.detail.value;
        console.log('--val--');
        let dependValues = [];
        this.isSpinnerLoading = true;
        Object.keys(this.solutionMapping).forEach((key) => {

            if (val != undefined && val != '' && val.includes(key)) {
                this.solutionMapping[key].forEach((item, index) => {
                    dependValues.push({ label: item, value: item });
                });

            }
        });

        this.biOptions = dependValues;
        this.isSpinnerLoading = false;

    }

    handleDependent(event) {
        this.buyerVal = event.detail.value;
    }

    handleCompetitiveDealChange(event) {
        this.competitiveDeal = event.detail.value;
    }

    handleSubStageChange(event) {
        let val = event.detail.value;
        this.subStageValue = val;
        if(this.subStageValue == 'Closed: Delete Duplicate'){
            this.isShowCompetitors = false;
        }else{
            this.isShowCompetitors = true;
        }
        if(this.subStageValue != 'Closed: Delete Duplicate' && this.flexi_identifier != null && this.flexi_identifier.includes('Customer Over-Usage')){
            this.showOverage = true;
        }else{
            this.showOverage = false;
        }
    }

    handleTechPartnerChange(event) {
        let val = event.detail.value;
        this.validatedSolutionTechPartner = val;
    }

    handlerequiresSigningCustomerDocuments(event) {
        let val = event.detail.value;
        this.requiresSigningCustomerDocuments = val;
    }

    handleOverageReasonChange(event) {
        let val = event.detail.value;
        this.overageReason = val;
    }

    handlePrimaryCompetitor(event){
        this.pcVal = event.target.value;
        if(event.target.value == 'Other'){
            this.isShowPrimaryOther = true;
        }else{
            this.isShowPrimaryOther = false;
            this.otherPrimaryCompetitor = '';
        }
         //IBA-1884-Start
        if(this.pcVal != null && this.pcVal != undefined && this.pcVal != 'None'){
            this.disableNextButton = false;
            this.HasError = false;
            this.ErrorMsg = '';
        } //IBA-1884-End
       
    }

    validateOtherCompetitor(){
        try{
            if(this.subStageValue != 'Closed: Delete Duplicate'){
                let b1= false;
                let b2= false;
                if(this.isShowPrimaryOther){
                    if(this.otherPrimaryCompetitor){
                        const re = /^[a-zA-Z0-9. \r\n]{1,}$/;
                        const str = this.otherPrimaryCompetitor;
                        const myArray = str.match(re);
                        if(myArray){
                            b1 =  true;
                        }else{
                            this.template.querySelector('c-custom-toast-component').showToast('error', 'Primary competitor (name of "other") accepts only Spaces');
                            return false;
                        }
                    }else{
                        this.template.querySelector('c-custom-toast-component').showToast('error', 'Please provide value in Primary competitor (name of "other")');
                        return false;
                    }
                }else{
                    b1 = true;
                }
                if(this.isShowSecondaryOther){
                    if(this.otherSecondaryCompetitor){
                        const re2 = /^[a-zA-Z0-9, \r\n]{1,}$/;
                        const str2 = this.otherSecondaryCompetitor.toString();
                        const myArray2 = str2.match(re2);
                        
                        if(myArray2){
                            b2 =  true;
                        }else{
                            this.template.querySelector('c-custom-toast-component').showToast('error', 'Secondary competitor (name of "other") accepts only comma');
                            return false;
                        }
                    }else{
                        this.template.querySelector('c-custom-toast-component').showToast('error', 'Please provide value in Secondary competitor (name of "other")');
                        return false;
                    }
                }else{
                    b2 = true;
                }
                if(b1 && b2){
                    return true;
                }else{
                    return false;
                }
            }else{
                return true;
            }
        }catch(e){
            console.log(e);
        }
    }

    handleOtherPrimaryCompetitor(event){
        this.otherPrimaryCompetitor = event.target.value;
    }

    handleOtherSecondaryCompetitor(event){
        this.otherSecondaryCompetitor = event.target.value;
    }

    handleSecondaryCompetitor(event){
        this.scVal = event.target.value;
        if(event.target.value.includes('Others')){
            this.isShowSecondaryOther = true;
        }else{
            this.isShowSecondaryOther = false;
            this.otherSecondaryCompetitor = '';
        }
    }

    handleNext(event) {
        this.disableNextButton = false; //IBA-1884
        if(this.validateOtherCompetitor()){
            this.isSpinnerLoading = true;
            if (this.subStageValue == undefined) {
                this.HasError = true;
                this.ErrorMsg = 'Please select a sub stage';
            } 
            //IBA-1884-Start
            else if((this.pcVal == null || this.pcVal == undefined || this.pcVal == 'None') && (this.subStageValue != 'Closed: Delete Duplicate')){
                this.HasError = true;
                this.ErrorMsg = PRIMARY_COMPETITOR_BLANK;
                this.template.querySelector('[data-id="redDiv"]').scrollTop=0;
                this.disableNextButton = true;
            } //IBA-1884-End
            else {
                const inputFields = this.template.querySelectorAll('lightning-input-field');
                const allFlag = this.checkFieldsValidity(inputFields);
                this.HasError = false;
                this.ErrorMsg = '';
                if(allFlag){
                    this.isNext = true;
                    this.showBack = true;
                    if (this.subStageValue == 'Closed With No Decision') {
                        this.renderLossFormType = false;
                        this.lossForm = true;
    
                    } else if (this.subStageValue == 'Closed Lost') {
                        this.renderLossFormType = true;
                        this.lossForm = true;
                    } else if (this.subStageValue == 'Closed: Delete Duplicate') {
                        this.lossForm = false;
                    }
                }
                
            }
        }
        
        this.isSpinnerLoading = false;

    }

    handleBack(event) {
        this.isNext = false;
        this.showBack = false;
    }

    handleRemove(event) {
        var index = event.currentTarget.dataset.id;
        if(this.validationDependencies.length > 0){
           let  fieldName = event.currentTarget.dataset.name;
            this.validationDependencies.forEach(item => {
                if(item.fieldName == fieldName && item.isFile == true && item.fileName){
                    item.fileName ='';
                    item.fileTitle = '';
                }else if(item.fieldName == fieldName && item.isFile == true){
                    item.loadedFiles.splice(index, 1);
                }
            });
        }
        this.loadedFiles.splice(index, 1);
    }


    handleDelete(event) {
        this.isSpinnerLoading = true;
        let fieldName,fileId;

        if(event.currentTarget.dataset != undefined && event.currentTarget.dataset.id != undefined){
            fileId = event.currentTarget.dataset.id;
        }else{
            fileId = this.fileId;
        }
        if(event.currentTarget.dataset != undefined && event.currentTarget.dataset.name != undefined){
            fieldName = event.currentTarget.dataset.name;
        }else{
            fieldName = this.fieldName;
        }
        console.log('--fileId--'+fileId);
        deleteRecord(fileId)
            .then(() => {
                unlinkFileURLFromOpportunity({
                    oppId: this.recordId,
                    oppfieldAPIName: fieldName,
                }).then(() => {
                    console.log('unlinkFileURLFromOpportunity Success++');
                    this.isSpinnerLoading = false;
                    this.template.querySelector('c-custom-toast-component').showToast('success', 'File(s) has been deleted successfully.');
                    this.fileName = '';
                    if(this.validationDependencies.length > 0){
                        this.validationDependencies.forEach(item => {
                            if(item.fieldName == fieldName && item.isFile == true && item.fileName){
                                item.fileName ='';
                                item.fileTitle = '';
                            }
                        });
                    }
                }).catch(error => {
                    console.log('Exception:', error);
                    this.isSpinnerLoading = false;
                    this.template.querySelector('c-custom-toast-component').showToast('error', 'Error Occured while deleting files to Opportunity:', error?.body?.message || error?.message);
                });


            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting file',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

    handleOnLoad(event) {
       if(this.recursiveFlag){
        this.recursiveFlag = false;
            this.isSpinnerLoading = false;
            if (this.fieldType == 'PICKLIST' && this.fieldName == 'StageName' && this.fieldVal == PIPELINE_STAGE) {
                this.isStageZero = true;
                this.subStageValue = 'Stage 0 Closed Lost';
                this.stageVal = '7 - Closed Lost';
                if(this.flexi_identifier != null && this.flexi_identifier.includes('Customer Over-Usage')){
                    this.showOverage = true;
                }
                
            }
            if (this.fieldType == 'PICKLIST' && this.fieldName == 'StageName') {
               
                this.stageVal = '7 - Closed Lost';
                
            }
            this.validatedSolutionTechPartner = getFieldValue(this.opportunity, VALIDATED_PARTNER);

            if (this.fieldName == SOLUTION.fieldApiName || this.fieldName == BUYER_INITIATIVE.fieldApiName) {
                this.loadDependentValues();
                console.log('--loadDependentValues--called--');
            }

            if(this.fieldName == CUSTOMER_DOCS.fieldApiName){
                this.loadDocTypes();
                if(this.fieldVal == 'null'){
                    this.fieldVal = 'Yes';
                    this.isCustomerDocs = true;
                    if (this.dependentFields != undefined && ((this.allowedValues == undefined) || (this.allowedValues != undefined && this.allowedValues.includes(this.fieldVal) && !this.fieldVal.includes('Not Required')))) {
                        this.fieldDependency = true;
                        this.fieldDependencies = [];
                        this.dependentFields.split(',').forEach(item => this.fieldDependencies.push({ fieldName: item.split(':')[0], isFile: item.split(':')[1] == 'true' ? true : false, fieldLabel: item.split(':')[2] }));
            
                    }
                }
            }
            
       }
  
       

    }

    handleSubmit(event) {
        event.preventDefault();

        if(!this.showOverage){
            this.overageReason = null;
        }
        if (this.isFile) {
            this.isSpinnerLoading = true;

            let savedfiles = [];
            for (let file of this.loadedFiles) {
                savedfiles.push(file);
            }

        } else if (this.isFileLink) {

            if (this.loadedFiles.length > 0) {
                this.isSpinnerLoading = true;
            

                linkFileURLtoOpportunity({
                    oppId: this.recordId,
                    files: this.loadedFiles,
                    oppfieldAPIName: this.fieldName,
                }).then(() => {
                    console.log('linkFileURLtoOpportunity Success++');
                    this.isSpinnerLoading = false;
                    this.handleFileSuccess();
                    this.template.querySelector('c-custom-toast-component').showToast('success', 'File(s) has been attached successfully.');
                }).catch(error => {
                    console.log('Exception:', error);
                    this.isSpinnerLoading = false;
                    this.template.querySelector('c-custom-toast-component').showToast('error', 'Error Occured while uploading files to Opportunity:', error?.body?.message || error?.message);
                });
            } else if (this.fileName == '' || this.fileName == undefined) {
                this.HasError = true;
                this.ErrorMsg = 'Please attach a file';
            } else {
                this.handleFileSuccess();
            }

        } else if (this.isOtherType) {
            let val = event.detail.fields;
            val = val[this.fieldName];
            console.log('--other type--' + val);
            console.log('--new Date(this.allowedValues)--' + new Date(this.allowedValues).toString('YYYY-MM-dd'));
            if (val != null && val != '') {
                if (this.allowedValues != undefined && this.errMsg != undefined && !this.allowedValues.includes(val)) {
                    this.HasError = true;
                    this.ErrorMsg = this.errMsg;
                    console.log('--allowedValues');
                }
                else if ((this.fieldType == 'INTEGER' || this.fieldType == 'DOUBLE') && val <= 0) {
                    this.HasError = true;
                    this.ErrorMsg = 'Please enter a value greater than 0';
                }
                else if (this.fieldType == 'DATE' && this.fieldName == 'Validation_End_Date__c' && this.allowedValues != undefined && new Date(this.allowedValues).toString('YYYY-MM-dd') > val) {
                    this.HasError = true;
                    this.ErrorMsg = 'Technical Validation End Date should be equal or greater than validation Start Date';
                } else if (this.fieldType == 'DATE' && this.fieldName == 'Technical_Validation_Start_Date__c' && this.allowedValues != undefined && new Date(this.allowedValues).toString('YYYY-MM-dd') < val) {
                    this.HasError = true;
                    this.ErrorMsg = 'Technical Validation Start Date should be equal or less than validation End Date';
                }
                else if (this.fieldDependencies) {

                    let allFlag = true;
                    let fileFieldName = '';
                    Object.keys(this.fieldDependencies).forEach((key) => {
                        if (this.fieldDependencies[key].isFile && (this.fileName == undefined || this.fileName == '') && this.loadedFiles != undefined && this.loadedFiles.length == 0) {
                            this.HasError = true;
                            this.ErrorMsg = 'Please select a file for ' + this.fieldDependencies[key].fieldLabel; 
                            allFlag = false;
                        } else if (this.fieldDependencies[key].isFile) {
                            fileFieldName = this.fieldDependencies[key].fieldName;
                        }
                    });
                    if (allFlag) {
                        this.HasError = false;
                        this.ErrorMsg = '';
                        this.isSpinnerLoading = true;
                        if (fileFieldName != '' && this.loadedFiles.length > 0) {
                           
                            linkFileURLtoOpportunity({
                                oppId: this.recordId,
                                files: this.loadedFiles,
                                oppfieldAPIName: fileFieldName,
                            }).then(() => {
                                console.log('linkFileURLtoOpportunity Success++');

                                this.template.querySelector('c-custom-toast-component').showToast('success', 'File(s) has been attached successfully.');
                                const fields = event.detail.fields;
                                console.log(JSON.stringify(fields));
                                this.template.querySelector('lightning-record-edit-form').submit(fields);
                                
                            }).catch(error => {
                                console.log('Exception:', error);
                                this.isSpinnerLoading = false;
                                this.template.querySelector('c-custom-toast-component').showToast('error', 'Error Occured while uploading files to Opportunity:', error?.body?.message || error?.message);
                            });
                        } else {
                            const fields = event.detail.fields;
                            console.log(JSON.stringify(fields));
                            this.template.querySelector('lightning-record-edit-form').submit(fields);
                        }


                    }


                }
                else {
                    this.isSpinnerLoading = true;
                    const fields = event.detail.fields;
                    console.log(JSON.stringify(fields));
                    this.template.querySelector('lightning-record-edit-form').submit(fields);
                }
            }

            else if (this.fieldType == 'BOOLEAN') {
                this.HasError = true;
                this.ErrorMsg = 'Please select the checkbox';
            } else if (this.fieldType == 'INTEGER' || this.fieldType == 'DOUBLE') {
                this.HasError = true;
                this.ErrorMsg = 'Please enter a value greater than 0';
            } else if (this.fieldType == 'STRING' || this.fieldType == 'TEXTAREA' || this.fieldType == 'URL') {
                this.HasError = true;
                this.ErrorMsg = 'Please fill in a value';
            } else if (this.fieldType == 'CURRENCY') {
                this.HasError = true;
                this.ErrorMsg = 'Please enter an amount greater than 0';
            } else if (this.fieldType == 'PICKLIST' || this.fieldType == 'MULTIPICKLIST' || this.fieldType == 'REFERENCE') {
                this.HasError = true;
                this.ErrorMsg = 'Please select a value';
            }
        } else if (this.isCustomPicklist) {
            this.isSpinnerLoading = true;
            event.preventDefault();
            const buyerField = this.template.querySelector(".buyerCmp");
            if (this.buyerVal == undefined || this.buyerVal.length == 0) {
                this.isSpinnerLoading = false;
                buyerField.reportValidity();
            } else {
                let inputFields = event.detail.fields;
                inputFields[BUYER_INITIATIVE.fieldApiName] = this.buyerVal.join(";");
                this.template.querySelector('lightning-record-edit-form').submit(inputFields);
            }

        } else if (this.isValidationStage) {
            
            this.isSpinnerLoading = true;
            event.preventDefault();
            let allFlag = true;
            let fileFieldName = '';
            let savedFiles = [];
            this.validationDependencies.forEach(item => {
                
                if(item.isFile == true && item.isRequired == true && (item.loadedFiles == undefined || item.loadedFiles.length == 0) && (item.fileName == undefined || item.fileName.trim().length == 0)){
                    this.HasError = true;
                    this.ErrorMsg = 'Please select a file for '+item.fieldLabel;
                    allFlag = false;
                    this.isSpinnerLoading = false;
                    
                }else if(item.isFile && item.loadedFiles != undefined && item.loadedFiles.length > 0){
                    fileFieldName += item.fieldName + ',';
                    savedFiles.push(...item.loadedFiles);
                }
                
            });
            const inputFields = this.template.querySelectorAll('lightning-input-field');
            allFlag &= this.checkFieldsValidity(inputFields);
            
            console.log('--oldValStage--'+this.oldValStage);
            const fields = event.detail.fields;
            let valStage = fields['Validation_Stage__c'];
            let startDate = fields['Technical_Validation_Start_Date__c'];
            let endDate = fields['Validation_End_Date__c'];
            console.log('--startDate'+startDate);
            console.log('--endDate'+endDate);
            if(valStage != '0 - Not Started' && valStage != '1 - Establishing Plan & success criteria' && valStage != '2 - Configuration in Progress' && valStage != '8 - Not Required' && valStage != '8B - Not Required - Preferred'){
                fields['Is_SE_Involved__c'] = 'Yes';
            }
            console.log('--new Date(startDate) > new Date(endDate)'+new Date(startDate) > new Date(endDate));
            if(startDate != undefined && endDate != undefined && new Date(startDate) > new Date(endDate)){
                this.HasError = true;
                this.ErrorMsg = 'Close Date should be after Start Date';
                allFlag = false;
                this.isSpinnerLoading = false;
            }/*else if((this.oldValStage == undefined || this.oldValStage == null) && (valStage == '3 - Detailed validation in progress' || valStage == '4 - Delivering validation findings report' ||
                valStage == '5 - Validation Stalled' || valStage == '5b - Pending customer decision' || valStage == '6 - Technical Win' ||  valStage == '7 - Technical Loss'  )){
                this.HasError = true;
                this.ErrorMsg = '"Technical Validation Stage" cannot be moved directly to 3 or higher without moving to stage 2. Please make sure to move it to stage 2 and then further.';
                allFlag = false;
                this.isSpinnerLoading = false;
            }*/


            if (allFlag) {
                this.HasError = false;
                this.ErrorMsg = '';
                this.isSpinnerLoading = true;
                console.log('--fileFieldName--' + fileFieldName);
                console.log('--this.loadedFiles--' + JSON.stringify(this.loadedFiles));
                if (fileFieldName != '' && savedFiles.length > 0) {
                   
                    linkFileURLtoOpportunity({
                        oppId: this.recordId,
                        files: savedFiles,
                        oppfieldAPIName: fileFieldName.substring(0,fileFieldName.length-1),
                    }).then(() => {
                        console.log('linkFileURLtoOpportunity Success++');

                        this.template.querySelector('c-custom-toast-component').showToast('success', 'File(s) has been attached successfully.');
                        
                        this.template.querySelector('lightning-record-edit-form').submit(fields);
                        
                    }).catch(error => {
                        console.log('Exception:', error?.body?.message || error?.message);
                        this.isSpinnerLoading = false;
                        this.template.querySelector('c-custom-toast-component').showToast('error', 'Error Occured while uploading files to Opportunity:', error?.body?.message || error?.message);
                    });
                }else{
                    
                    this.template.querySelector('lightning-record-edit-form').submit(fields);
                }
            }

        } else if (this.isClosed) {
            this.isSpinnerLoading = false;
            event.preventDefault();
            var allchildcmp;
            if (this.lossForm == true) {
                allchildcmp = this.template.querySelector("c-opportunity-close-loss-info");
                allchildcmp.handleParentSubmit(this.subStageValue, event, this.validatedSolutionTechPartner, this.overageReason,this.competitiveDeal,this.pcVal,this.otherPrimaryCompetitor,this.scVal,this.otherSecondaryCompetitor,this.requiresSigningCustomerDocuments);
            } else if (this.lossForm == false) {
                allchildcmp = this.template.querySelector("c-opp-closed-lost-duplicate");
                allchildcmp.handleParentSubmit(this.subStageValue, event, this.validatedSolutionTechPartner, this.overageReason,this.requiresSigningCustomerDocuments);
            }
        } else if (this.isAutoClosed) {

            event.preventDefault();
            const inputReason = this.template.querySelector('lightning-combobox');
            const inputComment = this.template.querySelector('lightning-textarea');
            let allFlag = inputReason.reportValidity() && inputComment.reportValidity();
            //IBA-1884-Start
           if(this.pcVal == null || this.pcVal == undefined || this.pcVal == 'None'){
            this.HasError = true;
            this.ErrorMsg = PRIMARY_COMPETITOR_BLANK;
            this.template.querySelector('[data-id="redDiv"]').scrollTop=0;
            this.isSpinnerLoading = false;
            allFlag = false;
          }
           //IBA-1884-End 
            if(allFlag){
                this.isSpinnerLoading = true;
                const fields = {};
                fields['Closed_Lost_Reason__c'] = this.reason;
                fields['Closed_Lost_Comment__c']= this.closedLostComment;
                fields['Opportunity__c'] = this.recordId;
                fields['Type__c'] = 'Loss';
                const objRecordInput = {'apiName' : 'Churn__c',fields};
                //IBA-1884
                updateStage({
                    opportunityId: this.recordId,
                    stageValue: '7 - Closed Lost',
                    subStage:this.subStageValue,
                    overageReason:this.overageReason,
                    pcVal:this.pcVal,
                    otherPrimaryCompetitor:this.otherPrimaryCompetitor,
                    requiresSigningCustomerDocuments:this.requiresSigningCustomerDocuments
                    
                }).then(response => {  
                createRecord(objRecordInput);
                   
                    this.isSpinnerLoading = false;
                    const custEvent = new CustomEvent(
                        'childclose', {
                        detail: ''
                    });
                    this.dispatchEvent(custEvent);
                   
                }).catch(error => {
                    console.log('--error.body--'+JSON.stringify(error.body));
                    this.ErrorMsg = error.body?.message;
                    this.HasError = true;
                    this.isSpinnerLoading = false;
                });
            }
                
                
                
               
            
        }
        else {
            if (this.textVal != null && this.textVal != '') {
                if (this.fieldDependencies) {
                    let inputFields = event.detail.fields;
                    let allFlag = true;
                    this.fieldDependencies.forEach(field => {
                        if (inputFields[field] == undefined || inputFields[field] == '') {
                            allFlag = false;
                        }
                    });
                    if (!allFlag) {
                        this.HasError = true;
                        this.ErrorMsg = 'Please fill out all fields';
                    } else {
                        this.isSpinnerLoading = true;
                        const fields = event.detail.fields;
                        console.log(JSON.stringify(fields));
                        fields[this.fieldName] = this.textVal;
                        this.template.querySelector('lightning-record-edit-form').submit(fields);
                    }
                }


            } else {
                this.HasError = true;
                this.ErrorMsg = 'Please fill in the value';
            }
        }
    }
   
    checkFieldsValidity(fields){
        const allValid = [...fields].reduce((validSoFar, field) => {
            return validSoFar && field.reportValidity();
        }, true);

        return allValid;
    }

    async handleGenerateFilePreviewURL(contentDocumentId) {
        console.log('--handleGenerateFilePreviewURL--called--', contentDocumentId);
        let filePreviewURl = '';
        await this[NavigationMixin.GenerateUrl]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: contentDocumentId
            }
        }).then(generatedUrl => {
            console.log('----generatedUrl---', generatedUrl)
            filePreviewURl = generatedUrl;
        });
        return filePreviewURl;
    }


    async handleUploadFinished(event) {
        let fieldName = event.currentTarget.dataset.name;
        if (event.detail.files.length > 0) {

            let uploadedFiles = event.detail.files;
            if (uploadedFiles) {
                let baseUrl = this.getBaseUrl();
                let attachmentArr = [];
                for (let attachment of uploadedFiles) {
                    var attachmentObj = {};
                    attachmentObj.fileId = attachment.documentId;
                    attachmentObj.PathOnClient = attachment.name;
                    attachmentObj.Title = attachment.name;
                    attachmentObj.fileTitle = attachment.name;
                    attachmentObj.filePreviewURL = baseUrl + await this.handleGenerateFilePreviewURL(attachment.documentId);
                    attachmentObj.fieldName = fieldName;
                    attachmentArr.push(attachmentObj);
                }
                if(fieldName != undefined && this.validationDependencies.length > 0){
                    this.validationDependencies.forEach(item => {
                        if(item.fieldName == fieldName && item.isFile == true && item.hasOwnProperty('loadedFiles')){
                            item.loadedFiles.push(...attachmentArr);
                        }else if(item.fieldName == fieldName && item.isFile == true){
                            item.loadedFiles = [];
                            item.loadedFiles.push(...attachmentArr);

                        }
                    });
                }else{
                    this.loadedFiles.push(...attachmentArr);
                }
                
            }
            console.log('---this.loadedFiles--', this.loadedFiles);
        }
    }

    handleFileSuccess(event) {
        const custEvent = new CustomEvent('callpasstoparent', { recordId: this.recordId });
        this.dispatchEvent(custEvent);
        this.isSpinnerLoading = false;
        console.log('im inside handleFileSuccess');
    }


    handleSuccess(event) {
        
        if(!this.isClosed){
            const custEvent = new CustomEvent(
                'callpasstoparent', {
                detail: 'test'
            });  
            this.dispatchEvent(custEvent);
        }else{
            const custEvent = new CustomEvent(
                'childclose', {
                detail: 'test'
            });
            this.dispatchEvent(custEvent);
        }
        
        this.isSpinnerLoading = false;
        console.log('im inside handlesuccess');
    }


    closeModal(event) {
        this.isSpinnerLoading = false;
        console.log('--this.fileName--' + this.fileName);
        console.log('--this.fileId--' + this.fileId);
        if (this.fileName != undefined && this.fileName == '' && this.fileId != undefined) {
            this.handleFileSuccess();
        } else {
            const custEvent = new CustomEvent(
                'childclose', {
                detail: event.target.value
            });
            this.dispatchEvent(custEvent);
        }
    }

    getBaseUrl() {
        let baseUrl = 'https://' + location.host;
        return baseUrl;
    }



    get options() {
        return [
            { label: 'Meeting Canceled - by RSM', value: 'Meeting Canceled - by RSM' },
            { label: 'Meeting Canceled - by Customer', value: 'Meeting Canceled - by Customer' },
            { label: 'Meeting Completed - No Next Steps', value: 'Meeting Completed - No Next Steps' },
            {label:'Other',value:'Other'}	
        ];	
    }	

    get subStageOptions() {	
        return [	
            { label: 'Closed Lost', value: 'Closed Lost' },	
            { label: 'Closed With No Decision', value: 'Closed With No Decision' },	
            { label: 'Closed: Delete Duplicate', value: 'Closed: Delete Duplicate' }
        ];
    }

    get isFile() {
        return this.fieldType == 'file' ? true : false;
    }

    get isFileLink() {

        return this.fieldType == 'fileLink' ? true : false;
    }

    get isTextArea() {
        return this.fieldType == 'TEXTAREA' ? true : false;
    }

    

    get isClosed() {
        
        return this.fieldType == 'PICKLIST' && this.fieldName == 'StageName' && this.fieldVal != PIPELINE_STAGE ? true : false;
    }

    get isAutoClosed() {
        
        return this.fieldType == 'PICKLIST' && this.fieldName == 'StageName' && this.fieldVal == PIPELINE_STAGE ? true : false;
    }

    get isValidationStage() {
        return this.fieldType == 'PICKLIST' && this.fieldName == 'Validation_Stage__c' ? true : false;
    }

    get isOtherType() {

        return this.fieldType != 'TEXTAREA' && this.fieldType != 'fileLink' && this.fieldType != 'file'
            && this.fieldName != 'StageName' && this.fieldName != 'Solution__c' && this.fieldName != 'Buyer_Initiative__c' && this.fieldName != 'Validation_Stage__c' ? true : false;
    }

    get isCustomPicklist() {

        return this.fieldName == SOLUTION.fieldApiName || this.fieldName == BUYER_INITIATIVE.fieldApiName ? true : false;
    }

    get showSubmit() {
        return (this.isSpinnerLoading == false && this.fieldName != 'StageName')
            || (this.fieldName == 'StageName' && (this.isNext || this.fieldVal == PIPELINE_STAGE)) ? true : false;
    }

    get showNext() {
        return this.isSpinnerLoading == false && this.fieldName == 'StageName' && this.isNext == false && this.fieldVal != PIPELINE_STAGE ? true : false;
    }

    get makeRequired() {
        this.type = getFieldValue(this.opportunity, TYPE);
        if (this.type != 'Existing Customer (Renewal)') {
            return false;
        } else {
            return true;
        }
        return;
    }

    loadDependentValues() {
        setTimeout(() => {
            console.log('this.opportunity-->',this.opportunity);
                console.log('SOLUTION-->',SOLUTION);
        this.solutionVal = getFieldValue(this.opportunity, SOLUTION);

        console.log('this.solutionVal' + this.solutionVal);
        this.isSpinnerLoading = true;
        getSolutionMappings()
            .then(result => {
                console.log('getSolutionMappings' + JSON.stringify(result));
                this.solutionMapping = result;
                Object.keys(this.solutionMapping).forEach((key) => {


                    if (this.solutionVal != undefined && this.solutionVal.includes(key)) {
                        this.solutionMapping[key].forEach((item, index) => {
                            this.biOptions.push({ label: item, value: item });
                        });

                    }
                });
                this.isSpinnerLoading = false;
                console.log('this.biOptions-->',this.biOptions);
                console.log('this.opportunity-->',this.opportunity);
                console.log('BUYER_INITIATIVE-->',BUYER_INITIATIVE);
                
                    let buy_init = getFieldValue(this.opportunity, BUYER_INITIATIVE);
                    console.log('--buy_init--' + buy_init);
                    if (buy_init != '' && buy_init != undefined)
                        this.buyerVal = buy_init.split(';');
                
            }).catch(error => {
                console.log('Exception:', error);

            });
        }, 500);

    }
}
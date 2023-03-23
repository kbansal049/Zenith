import { LightningElement,api,track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord,deleteRecord,getFieldValue } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import SOLUTION from '@salesforce/schema/Opportunity.Solution__c';
import BUYER_INITIATIVE from '@salesforce/schema/Opportunity.Buyer_Initiative__c';
import DOC_TYPE from '@salesforce/schema/Opportunity.What_Type_of_doc__c';
const FIELDS = ['Opportunity.Name', SOLUTION, BUYER_INITIATIVE, DOC_TYPE];
import fetchOpp from '@salesforce/apex/OppStageChecklistController.getDetailsForEdit';
import linkFileURLtoOpportunity from '@salesforce/apex/OppStageChecklistController.linkFileURLtoOpportunity';
import unlinkFileURLFromOpportunity from '@salesforce/apex/OppStageChecklistController.unlinkFileURLFromOpportunity';
import getSolutionMappings from '@salesforce/apex/OppStageChecklistController.getSolutionMapping';
export default class OpportunityEditChecklist extends LightningElement {
    @api recordId;
    @api recordTypeId;
    @track currentStep = '1';
    @track fieldsList = [];
    @track isLoading;
    @track error;
    @track hasError;
    @track fields = [];
    @track nextStage;
    @track prevStage;
    @track showNext;
    @track showPrev;
    fieldSet = [];
    wiredData;
    opportunity;
    docType;
    solution;
    buyer_init;
    recursiveFlag = false;

    //for solution buyer initiative field dependencies
    @track biOptions = [];
    @track solutionVal;
    solutionMapping = new Map();
    @track buyerVal = [];

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
            
        }
        else if (data) {
            this.opportunity = data;
        }
    }

    @wire(fetchOpp, {
        opportunityId: '$recordId'
    })
    getDetails(wireResult) {
        this.isLoading = true;
        const {
            data,
            error
        } = wireResult;
        this.wiredData = wireResult;
        if (data) {
            this.fieldsList = data;
            console.log(JSON.stringify(data));
            this.currentStep = data[0].stageVal;
            this.fields = data[0].fieldsList;
            this.prevStage = data[0].prevStage;
            this.nextStage = data[0].nextStage;
            this.isLoading = false;
        }
        else if (error) {
            this.error = error;
            this.hasError = true;
            this.isLoading = false;
            console.log('error', error);
            if (error.body.message) {
                const event = new ShowToastEvent({
                    title: 'Some unexpected error',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
            }
            this.isLoading = false;
        }
    }

    proxyToObj(obj){
        
        return JSON.parse(JSON.stringify(obj));
       
    }
    handleBuyer(event){
        let buyer = event.detail.value;
        console.log(JSON.stringify(buyer));
        this.buyerVal = this.proxyToObj(buyer);
        console.log(JSON.stringify(this.buyerVal));
        if(this.fieldSet.length > 0){
            var index = this.fieldSet.findIndex(object => BUYER_INITIATIVE.fieldApiName === object.fieldName);

            if (index === -1) {
                this.fieldSet.push({fieldName:BUYER_INITIATIVE.fieldApiName,value:buyer});
            } else {
                this.fieldSet[index].value = buyer;
            }
        }else{
            this.fieldSet.push({fieldName: BUYER_INITIATIVE.fieldApiName,value:buyer});
        }
    
    }
    handleOnCustomLoad(event){
            setTimeout(() => {
                this.docType = getFieldValue(this.opportunity,DOC_TYPE);
                this.solution =  getFieldValue(this.opportunity,SOLUTION);
                this.buyer_init = getFieldValue(this.opportunity,BUYER_INITIATIVE);
    
                getSolutionMappings()
                .then(result => {
                    console.log('getSolutionMappings' + JSON.stringify(result));
                    console.log('--this.solution--'+this.solution);
                    this.solutionMapping = result;
                    this.biOptions = [];
                    Object.keys(this.solutionMapping).forEach((key) => {
    
    
                        if (this.solution != undefined && this.solution.includes(key)) {
                            this.solutionMapping[key].forEach((item, index) => {
                                this.biOptions.push({ label: item, value: item });
                            });
    
                        }
                    });
    
                    if (this.buyer_init != '' && this.buyer_init != undefined)
                            this.buyerVal = this.buyer_init.split(';');
                    
                }).catch(error => {
                    console.log('Exception:', error);
    
                });
            }, 500);
        
        
    }

    handleDelete(event) {
        this.isLoading = true;
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
                    if(this.fields.length > 0){
                        this.fields.forEach(item => {
                            if(item.fieldName == fieldName && item.isFile == true && item.fileName){
                                item.fileName ='';
                                item.fileId = '';
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

    handleSubChange(event) {
        const subFieldName = event.currentTarget.dataset.name;
        console.log('--subFieldName--' + subFieldName);
        let val = event.detail.value;
        console.log('--val--'+val); 
        if(this.fieldSet.length > 0){
            var index = this.fieldSet.findIndex(object => subFieldName === object.fieldName);

            if (index === -1) {
                this.fieldSet.push({fieldName:subFieldName,value:val});
            } else {
                this.fieldSet[index].value = val;
            }
        }else{
            this.fieldSet.push({fieldName: subFieldName ,value: val});
        }

        if(subFieldName === 'Solution__c'){
            let dependValues = [];
            this.isLoading = true;
            Object.keys(this.solutionMapping).forEach((key) => {

                if (val != undefined && val != '' && val.includes(key)) {
                    this.solutionMapping[key].forEach((item, index) => {
                        dependValues.push({ label: item, value: item });
                    });

                }
            });

            this.biOptions = dependValues;
            this.isLoading = false;
        }
        this.fieldSet = this.proxyToObj(this.fieldSet);
        this.fields = this.proxyToObj(this.fields);

        if(subFieldName == DOC_TYPE.fieldApiName && val != undefined && val.includes('NDA')){
            var signatureFieldIndex = this.fields.findIndex(object => 'Does_Doc_Require_Signature__c' === object.fieldName);
            if (signatureFieldIndex === -1) {
                this.fields.push({fieldName:'Does_Doc_Require_Signature__c',fieldLabel:'Does NDA Requires Signature?',isFile:false,isCustomPicklist:false});
            } 
        }else if(subFieldName == DOC_TYPE.fieldApiName && val != undefined && !val.includes('NDA')){
            var signatureFieldIndex = this.fields.findIndex(object => 'Does_Doc_Require_Signature__c' === object.fieldName);
            if (signatureFieldIndex != -1) {
                this.fields.splice(signatureFieldIndex,1);
                var index1 = this.fieldSet.findIndex(object => 'Does_Doc_Require_Signature__c' === object.fieldName);

                if (index1 != -1) {
                    this.fieldSet.splice(index1,1);
                } 
            } 
        }else if(subFieldName == 'Require_Customer_Docs_to_be_submitted__c' && val != undefined && val != 'Yes'){
            var docsSubmissionIndex = this.fields.findIndex(object => 'What_Type_of_doc__c' === object.fieldName);
            if (docsSubmissionIndex != -1) {
                this.fields.splice(docsSubmissionIndex,1);
                var index1 = this.fieldSet.findIndex(object => 'What_Type_of_doc__c' === object.fieldName);

                if (index1 != -1) {
                    this.fieldSet.splice(index1,1);
                } 
            } 
            var signatureFieldIndex = this.fields.findIndex(object => 'Does_Doc_Require_Signature__c' === object.fieldName);
            if (signatureFieldIndex != -1) {
                this.fields.splice(signatureFieldIndex,1);
                var index1 = this.fieldSet.findIndex(object => 'Does_Doc_Require_Signature__c' === object.fieldName);

                if (index1 != -1) {
                    this.fieldSet.splice(index1,1);
                } 
            } 
        }else if(subFieldName == 'Require_Customer_Docs_to_be_submitted__c' && val != undefined && val == 'Yes'){
            var docsSubmissionIndex = this.fields.findIndex(object => 'What_Type_of_doc__c' === object.fieldName);
            if (docsSubmissionIndex == -1) {
                
                this.fields.push({fieldName:'What_Type_of_doc__c',fieldLabel:'What Type of document?',isFile:false,isCustomPicklist:false});
                
            } 
        }
        

        console.log('--this.fieldSet--'+this.fieldSet);

        
        
        /*if (subFieldName != undefined && subFieldName == 'What_Type_of_doc__c' && val != undefined && val.includes('NDA') && !this.dependentFields.includes('Does_Doc_Require_Signature__c')) {
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
        this.isSpinnerLoading = false;*/
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
                if(fieldName != undefined && this.fields.length > 0){
                    this.fields.forEach(item => {
                        if(item.fieldName == fieldName && item.isFile == true && item.hasOwnProperty('loadedFiles')){
                            item.loadedFiles.push(...attachmentArr);
                        }else if(item.fieldName == fieldName && item.isFile == true){
                            item.loadedFiles = [];
                            item.loadedFiles.push(...attachmentArr);

                        }
                    });
                }
                
            }
            
        }
    }

    handleOnStepClick(event) {
       
        var allFlag = true;
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        allFlag &= this.checkFieldsValidity(inputFields);
        this.fields.forEach(item => {
            if(item.isCustomPicklist && item.isRequired && (this.buyerVal == undefined ||this.buyerVal == '')){
                const buyerField = this.template.querySelector(".buyerCmp");
                
                    if(buyerField != null){
                        buyerField.reportValidity();
                        allFlag &= false;
                    }
                
                
            }
        });
        if(allFlag){
            this.isLoading = true;
            this.fieldsList.every(item => {
                if(item.stageVal == event.target.value){
                    this.fields = item.fieldsList;
                    this.prevStage = item.prevStage;
                    this.nextStage = item.nextStage;
                    if(item.stageVal == '4 - Impact Validation'){
                        this.nextStage = null;
                    }
                    this.currentStep = event.target.value;
                    this.fields.forEach(item => {
                        var index = this.fieldSet.findIndex(object => item.fieldName === object.fieldName);
                        if(index !== -1){
                            item = this.proxyToObj(item);
                            item.value = this.fieldSet[index].value;
                            console.log(item.fieldName);
                            console.log(item.value);
                        }
                    });
                    return false;
                }
                return true;
            });
            setTimeout(() => {this.isLoading = false}, 0);
        }
    }
 
 
    handleNext(event){
        var allFlag = true;
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        allFlag &= this.checkFieldsValidity(inputFields);
        
        this.fields.forEach(item => {
            if(item.isCustomPicklist && item.isRequired && (this.buyerVal == undefined ||this.buyerVal == '')){
                const buyerField = this.template.querySelector(".buyerCmp");
                if(buyerField != null){
                    buyerField.reportValidity();
                    allFlag &= false;
                }
                
            }

        });
        if(allFlag){
            this.isLoading = true;
            console.log('fieldSet'+JSON.stringify(inputFields));
            this.fieldsList.every(item => {
                if(item.stageVal == this.nextStage){
                    this.fields = item.fieldsList;
                    this.prevStage = item.prevStage;
                    this.nextStage = item.nextStage;
                    if(item.fieldsList.length == 0){
                        return true;
                    }
                    this.fields.forEach(item => {
                        var index = this.fieldSet.findIndex(object => item.fieldName === object.fieldName);
                        if(index !== -1){
                            item = this.proxyToObj(item);
                            item.value = this.fieldSet[index].value;
                            console.log(item.fieldName);
                            console.log(item.value);
                        }
                    });
                    this.currentStep = item.stageVal;
                    if(item.stageVal == '4 - Impact Validation'){
                        this.nextStage = null;
                    }
                    return false;
                }
                return true;
            });

        }
        setTimeout(() => {this.isLoading = false}, 500);
        
        
    }
 
    handlePrev(){
        var allFlag = true;
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        allFlag &= this.checkFieldsValidity(inputFields);
        this.fields.forEach(item => {
            if(item.isCustomPicklist && item.isRequired && (this.buyerVal == undefined ||this.buyerVal == '')){
                const buyerField = this.template.querySelector(".buyerCmp");
                if(buyerField != null){
                    buyerField.reportValidity();
                    allFlag &= false;
                }
            }
        });
       
        if(allFlag){
            this.isLoading = true;
            this.fieldsList.every(item => {
                if(item.stageVal == this.prevStage){
                    this.fields = item.fieldsList;
                    this.prevStage = item.prevStage;
                    this.nextStage = item.nextStage;
                    this.currentStep = item.stageVal;
                    if(item.fieldsList.length == 0){
                        this.handlePrev();
                        return true;
                    }
                    this.fields.forEach(item => {
                        var index = this.fieldSet.findIndex(object => item.fieldName === object.fieldName);
                        if(index !== -1){
                            item = this.proxyToObj(item);
                            item.value = this.fieldSet[index].value;
                            console.log(item.fieldName);
                            console.log(item.value);
                        }
                    });
                    
                    return false;
                }
                return true;
            });
            
        }
        setTimeout(() => {this.isLoading = false}, 500);
    }

    handleSuccess(event) {
        
       
            const custEvent = new CustomEvent(
                'callpasstoparent', {
                detail: event.target.value
            });  
            this.dispatchEvent(custEvent);
        
        
        this.isLoading = false;
        
    }

    handleSubmit(){
        this.isLoading = true;
    }
 
    handleFinish(event){
        var allFlag = true;
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        allFlag &= this.checkFieldsValidity(inputFields);
       
        if(allFlag){
            this.isLoading = true;
            const fields = {};
            fields['Id'] = this.recordId;
             console.log(JSON.stringify(this.fieldSet));
            this.fieldSet.forEach(item => {
                if(Array.isArray(item.value) && item.value.length > 0){
                    fields[item.fieldName] = item.value[0];
                }else if(item.value.length === 0){
                    fields[item.fieldName] = '';
                }else{
                    fields[item.fieldName] = item.value;
                }
            });
            console.log(JSON.stringify(fields));
            const objRecordInput = {fields};
            
            updateRecord(objRecordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Opportunity Updated',
                        variant: 'success'
                    })
                );
                const custEvent = new CustomEvent(
                    'callpasstoparent', {
                    detail: 'updated'
                });  
                this.dispatchEvent(custEvent);
            })
            .catch(error => {
                console.log(error);
                this.isLoading = false;
            });
        }
    }

    checkFieldsValidity(fields){
        const allValid = [...fields].reduce((validSoFar, field) => {
            return validSoFar && field.reportValidity();
        }, true);

        return allValid;
    }

    closeModal(event) {
        this.isLoading = false;
        
            const custEvent = new CustomEvent(
                'childclose', {
                detail: event.target.value
            });
            this.dispatchEvent(custEvent);
        
    }
}
import { LightningElement, api, track, wire } from 'lwc';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { updateRecord } from 'lightning/uiRecordApi';
import ID_FIELD from '@salesforce/schema/Opportunity.Id';
import STAGE_FIELD from '@salesforce/schema/Opportunity.StageName';
import SUBSTAGE_FIELD from '@salesforce/schema/Opportunity.Sub_Stage__c';
import NAME_FIELD from '@salesforce/schema/Opportunity.Name';
import is_Duplicate_Opportunity_Linked from '@salesforce/schema/Opportunity.is_Duplicate_Opportunity_Linked__c';
import Reason_Form_Check from '@salesforce/schema/Opportunity.Reason_form_check__c';
import VALIDATED_PARTNER from '@salesforce/schema/Opportunity.Validated_Solution_Tech_Partner__c';
import getOppExtensionInfo from '@salesforce/apex/OppClosedLostDuplicate.getOppExtensionInfo';
import isActivePRpresentOnOpp from '@salesforce/apex/OppClosedLostDuplicate.isActivePRpresentOnOpp';
import decommissionActivePRsOnOpp from '@salesforce/apex/OppClosedLostDuplicate.decommissionActivePRsOnOpp';
import updateStage from '@salesforce/apex/OppStageChecklistController.updateOpportunityStage';
import updateLinkedOpp from '@salesforce/apex/OppStageChecklistController.updateLinkedOppSDR';
import getIsOverageOpp from '@salesforce/apex/OppClosedLostDuplicate.isOverageOpp';

export default class OppClosedLostDuplicate extends LightningElement {
    @api errorMessage;
    @api hasNoError;
    @api hideSubmit;
    @api renderPage;
    @api hideButtons=false;
    dupicateOppId;
    extensionRecordId;
    loaded = true;
    error = false;
    hasNoError = true;
    hideSubmit = false;
    renderPage = false;

    isActivePRPresent = false;
    isDuppOppUpdated = false;
    DupOpp = false;

    overageOppPresent = false;
    FlexIdentifier;
    @api recordId;
    @track customError=false;
    @wire(getRecord, {
        recordId: "$recordId",
        fields: [STAGE_FIELD, NAME_FIELD]
    })
    opportunity;

    connectedCallback() {
        console.log('---connectedCallback--called---');
        this.oppLostDuplicateLoad();
    }

    async oppLostDuplicateLoad() {
        console.log('---oppLostDuplicateLoad--this.recordId---', this.recordId);
        await getOppExtensionInfo({ opportunityId: this.recordId })
            .then(result => {
                console.log('---getOppExtensionInfo--result---', result);
                let oppExtensionRes = Object.assign({}, result);

                this.oppExtensionResult(oppExtensionRes);
            })
            .catch(error => {
                console.log('---getOppExtensionInfo--error---', error);
                this.error = error;
                this.hasError = true;
                this.loading = false;
                this.loaded = !this.loaded;
            });
            this.checkOvergeOppPresent();
    }

    oppExtensionResult(oppExtensionRes) {
        if (oppExtensionRes.isSuccess) {
            this.loaded = !this.loaded;
            this.renderPage = true;
            this.extensionRecordId = oppExtensionRes.oppExtensionObj.Id;

        }
        else {
            this.loaded = !this.loaded;
            this.hasNoError = false;
            this.hideSubmit = true;
            this.errorMessage = 'Something went wrong please work with Zscaler Salesforce Support Team';
        }
    }

    async checkForActivePROnOpp() {
        console.log('---checkForActivePROnOpp--this.recordId---', this.recordId);
        await isActivePRpresentOnOpp({ opportunityId: this.recordId })
            .then(result => {
                console.log('---isActivePRpresentOnOpp--result---', result);
                this.isActivePRPresent = result;
            })
            .catch(error => {
                console.log('---isActivePRpresentOnOpp--error---', error);
                this.error = error;
                this.hasError = true;
                this.loading = false;
                this.loaded = !this.loaded;
            });
    }

    async decommissionPRs() {
        console.log('---decommissionPRs--this.recordId---', this.recordId);
        await decommissionActivePRsOnOpp({ opportunityId: this.recordId })
            .then(result => {
                console.log('---decommissionActivePRsOnOpp--result---', result);
            })
            .catch(error => {
                console.log('---decommissionActivePRsOnOpp--error---', error);
                this.error = error;
                this.hasError = true;
                this.loading = false;
                this.loaded = !this.loaded;
            });
    }

    async updateLinkedOpportunity() {
        console.log('---updateLinkedOpportunity--this.recordId---', this.recordId);
        console.log('---updateLinkedOpportunity--this.dupicateOppId---', this.dupicateOppId);
        await updateLinkedOpp({ 
                            opportunityId: this.recordId , 
                            duplicateOppId: this.dupicateOppId 
            })
            .then(result => {
                console.log('-----updateLinkedOpportunity result---', result);
                this.isDuppOppUpdated = result;
                if(this.overageOppPresent){
                    this.submitMyformProgramatically();
                }
            })
            .catch(error => {
                console.log('---updateLinkedOpportunity--error---', error);
                this.error = error;
                this.hasError = true;
                this.loading = false;
                this.loaded = !this.loaded;
            });
    }

    handleSubmit() {
        this.loaded = !this.loaded;
    }

    checkFieldsValidity(fields){
        const allValid = [...fields].reduce((val, inp) => {
            let inpVal = true;
        // Custom Logic
        switch (inp.fieldName) {
            case 'Duplicate_Opportunity__c':
                inpVal = inp.value == this.recordId ? false : true;
                if (!inpVal) { 
                    this.errorMessage =  'You cannot add same name as Opportunity in Duplicate Opportunity field';
                    this.customError = true;
                 }
                break;
            default:
                inpVal = true;
                break;
        }
            return inpVal && inp.reportValidity();
        }, true);

        return allValid;
    }

    duplicateOppChange(event){ 
        console.log('--populating dupicateOppId--');
        this.dupicateOppId = event.detail.value[0];
        console.log('--dupicateOppId--'+ this.dupicateOppId);
        if( this.dupicateOppId!= null ||  this.dupicateOppId != ''){
            this.DupOpp = true;
            
        }
    }

    @api
    async handleParentSubmit(subStageValue,event,validatedSolutionTechPartner, overageReason, requiresSigningCustomerDocuments){ 
        event.preventDefault(); 
        var allValid;
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        console.log(JSON.stringify(inputFields));
        
            allValid = this.checkFieldsValidity(inputFields);
        
        
        if(allValid){
            if(!this.dupicateOppId && this.template.querySelector('[data-id="Duplicate_Opportunity__c"]')){
                this.dupicateOppId = this.template.querySelector('[data-id="Duplicate_Opportunity__c"]').value;
                this.DupOpp = true;
            }
            const fields = {};
            fields['attributes'] =  {'type': 'Opportunity_Extension__c'};
            fields['Id'] = this.extensionRecordId;
            inputFields.forEach((item) => {
                    fields[item.fieldName] = item.value;
            });
            this.handleSubmit();
            try{
                const oppResult =  await updateStage({
                    opportunityId: this.recordId,
                    stageValue: '7 - Closed Lost',
                    subStage:subStageValue,
                    validatedSolutionTechPartner: validatedSolutionTechPartner,
                    fieldSet: JSON.stringify(fields),
                    requiresSigningCustomerDocuments: requiresSigningCustomerDocuments
                });
                console.log('--oppResult--'+oppResult);
                this.template.querySelector('c-custom-toast-component').showToast('success', 'Churn/Lost Form Successfully created.');
                
                getRecordNotifyChange([{recordId: this.recordId}]);
                
                if(this.DupOpp) {this.updateLinkedOpportunity();}
            }catch(error){
                console.log('Updating opp error :'+error);
                this.hasNoError = false;
                this.hideSubmit = true;
                this.loaded = !this.loaded;
               console.log('--error'+JSON.stringify(error));
            }
           
           
        }
        
        return allValid;
        
    }
    
    handleSuccess() {
    if(!this.hideButtons){
            const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[STAGE_FIELD.fieldApiName] = '7 - Closed Lost';
        fields[SUBSTAGE_FIELD.fieldApiName] = 'Closed Blackhole';
        //is_Duplicate_Opportunity_Linked__c
        fields[is_Duplicate_Opportunity_Linked.fieldApiName] = false;
        //fields[Reason_Form_Check.fieldApiName] = true;
        const recordInput = { fields };
        this.decommissionPRs();
        
        updateRecord(recordInput)
            .then(() => {
                //this.navigateToVFPage();
                this.template.querySelector('c-custom-toast-component').showToast('success', 'Duplicate Opportunity updated');
                getRecordNotifyChange([{ recordId: this.recordId }]);
            })
            .catch(error => {
                console.log('Updating opp error :' + error);
                this.hasNoError = false;
                this.hideSubmit = true;  
                this.loaded = !this.loaded;
                this.errorMessage = error.body.output.errors[0].message;
            });

        }
        
    }

    handleOppSuccess() {
        console.log('successfully sumbitted');
    }

    handleOppSubmit(event) {
            event.preventDefault();       
            const fields = event.detail.fields;
            fields.Flexible_Identifier__c = this.FlexIdentifier;
            fields.Id = this.dupicateOppId;
            this.template.querySelector('[data-id="oppForm"]').submit(fields);  
        }

     submitMyformProgramatically() {
        try {
            const btn = this.template.querySelector('[data-id="hiddenbtn"]');
            if (btn) {
                btn.click();
            }
        } catch (error) {
            console.error(error);
        }
    }

    handleOppExtError(event){
        console.error(JSON.stringify(event.detail));
    }
    handleOppError(event){
        console.error(JSON.stringify(event.detail));
    }

    get getDupicateOppId() {
        return this.dupicateOppId;
    }
    async checkOvergeOppPresent(){

        try {
            if (this.recordId) {
                const oppResult = await getIsOverageOpp({ opportunityId: this.recordId});
                if(oppResult.isOverage){
                this.overageOppPresent = oppResult.isOverage;
                this.FlexIdentifier = oppResult.FlexibleIdentifier;
                }
            }
        } catch (error) {
            console.log('Exception:', error);
            this.error = error;
                this.hasError = true;
                this.loading = false;
                this.loaded = !this.loaded;
        }
    }
}
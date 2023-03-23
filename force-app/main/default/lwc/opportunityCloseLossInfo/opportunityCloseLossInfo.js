import { LightningElement, api, track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import ID_FIELD from '@salesforce/schema/Opportunity.Id';
import STAGE_FIELD from '@salesforce/schema/Opportunity.StageName';
import SUBSTAGE_FIELD from '@salesforce/schema/Opportunity.Sub_Stage__c';
import TECH_VALIDATION_FIELD from '@salesforce/schema/Opportunity.Validation_Stage__c';
import OPP_SPLITT_FIELD from '@salesforce/schema/Opportunity.Split_Type__c';
import { NavigationMixin } from 'lightning/navigation';
import checkValidationErrors from '@salesforce/apex/OppLossReasonCntrl.checkValidationErrors';
import loadChurnForm from '@salesforce/apex/OppLossReasonCntrl.loadChurnForm';
import { getRecord,getFieldValue } from "lightning/uiRecordApi";
import TYPE from '@salesforce/schema/Opportunity.Type';
import Reason_Form_Check from '@salesforce/schema/Opportunity.Reason_form_check__c';
import Render_Substage_churn_form from '@salesforce/schema/Opportunity.Render_Substage_churn_form__c';
import VALIDATED_PARTNER from '@salesforce/schema/Opportunity.Validated_Solution_Tech_Partner__c';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import updateStage from '@salesforce/apex/OppStageChecklistController.updateOpportunityStage';

const fields = [TYPE,Render_Substage_churn_form];
export default class OpportunityCloseLossInfo extends LightningElement {
    @api errorMessage; 
    @api hasNoError;
    @api recordId;
    @api subStageType;
    @api technicalValStage;
    @api profileName;
    @api optySplitType;
    @api hideSubmit;
    @api renderPage;
    @track revisitValue = 'No';
    @api churnDetails;
    @api churnReason;
    @api type;
    @api hideButtons = false;
    loaded = true;
    error = false;
    hasNoError = true;
    hideSubmit = false;
    renderPage = false;

    isRevisitRequired = false;
    @track isOtherCompetitorRequired = false;

    @wire(getRecord, {
        recordId: "$recordId",
        //modified by Raghu
        fields : [TECH_VALIDATION_FIELD,OPP_SPLITT_FIELD]
        //end of modification
      })
      opportunity;

      connectedCallback(){
        console.log('---connectedCallback--called---');
        this.churnFormLoad();
      }

      async churnFormLoad() 
      {
        console.log('---loadChurnForm--this.recordId---', this.recordId);
        await loadChurnForm({ opportunityId: this.recordId })
            .then(result => {
                console.log('---loadChurnForm--result---',result);
                let churnFormRes = Object.assign({}, result);
                
                this.churnFormResult(churnFormRes);
            })
            .catch(error => {
                this.error = error;
                this.hasError = true;
                this.loading = false;
            });
      }

      churnFormResult(churnFormRes)
      {
        if(churnFormRes.isSuccess)
          {
            this.technicalValStage = churnFormRes.techValidationStage;
            this.optySplitType = churnFormRes.opportunitySplitType;
            this.profileName = churnFormRes.currentUserProfile;
            console.log(this.technicalValStage);
            console.log(this.profileName);
            console.log(this.optySplitType);

            this.loaded = !this.loaded;
            if( this.technicalValStage != undefined
                && this.technicalValStage != '6 - Technical Win' 
                && this.technicalValStage != '7 - Technical Loss' 
                && this.technicalValStage != '8 - Not Required' 
                && this.technicalValStage != '8B - Not Required - Preferred'
                && this.technicalValStage !='0 - Not Started' 
                && ((this.profileName != 'Core Sales - Renewals' && !this.hideButtons)
                || (this.profileName == 'Core Sales - Renewals' && this.optySplitType == 'Renewal/Upsell Split')
                ))
            {
                this.hasNoError = false;
                this.hideSubmit = true;
                this.errorMessage = 'Please choose the Technical Validation Stage value from "6 - Technical Win" or "7 - Technical Loss" or "8 - Not Required" or "8B - Not Required - Preferred" before filling Churn/Closed Lost Form';
            }
            else
            {
                this.renderPage=true;
                /*checkValidationErrors({oppId: this.recordId})
                    .then(ValidationMessage =>{
                        console.log('checkValidation '+ValidationMessage.hasNoErrors);
                    if(!ValidationMessage.hasNoErrors){
                        this.hasNoError = false;
                        this.hideSubmit = true;
                        this.errorMessage = ValidationMessage.ErrorMessage;
                    }
                    else{
                        this.renderPage=true;
                    }
                }); */
            }
        }
        else
        {
            this.hasNoError = false;
            this.hideSubmit = true;
            this.errorMessage = 'Something went wrong please work with Zscaler Salesforce Support Team';
        }
    }
     
    /*connectedCallback(){
        
        //modified by Raghu
        console.log("opportunity : "+JSON.stringify(this.opportunity));
        this.technicalValStage = this.opportunity.data.fields.Validation_Stage__c.value;
        this.optySplitType = this.opportunity.data.fields.Split_Type__c.value;
        //end of modification
        console.log(this.technicalValStage);
        console.log(this.profileName);
        console.log(this.optySplitType);
        this.loaded = !this.loaded;
        if(this.technicalValStage != "" && this.technicalValStage != '6 - Technical Win'  && 
        this.technicalValStage != '7 - Technical Loss' && this.technicalValStage != '8 - Not Required' && this.technicalValStage != '8B - Not Required - Preferred'
        && this.technicalValStage !='0 - Not Started' && (this.profileName != 'Core Sales - Renewals' || (this.profileName == 'Core Sales - Renewals' && this.optySplitType == 'Renewal/Upsell Split'))){
            this.hasNoError = false;
            this.hideSubmit = true;
            this.errorMessage = 'Please choose the Technical Validation Stage value from "6 - Technical Win" or "7 - Technical Loss" or "8A - Not Required" or "8B - Not Required - Preferred"';
        }else{
            checkValidationErrors({oppId: this.recordId}).then(ValidationMessage =>{
                console.log('checkValidation '+ValidationMessage.hasNoErrors);
                if(!ValidationMessage.hasNoErrors){
                    this.hasNoError = false;
                    this.hideSubmit = true;
                    this.errorMessage = ValidationMessage.ErrorMessage;
                }
                else{
                    this.renderPage=true;
                }
            }); 
        }
    }*/

    get renderLossFormType(){
        return getFieldValue(this.opportunity.data,Render_Substage_churn_form) == true;//this.subStageType == 'Closed Lost';
    }

    get renderChurnDetails(){
        return this.churnReason == 'Unknown';
    }

    get typeOfLoss(){
        return "Loss";
    }

    get renderRevisitDateField() {
        return this.revisitValue === 'Yes' ? true : false;
    }

    churnReasonChange(event){
        this.churnReason = event.target.value;
    }

    churnDetailChange(event){
        this.churnDetails = event.target.value;
    }

    handleRevisitChange(event) {
        this.revisitValue = event.target.value;
        this.isRevisitRequired = this.revisitValue === 'Yes' ? true : false ;
    }

    handleCompetitorChange(event) {
        this.isOtherCompetitorRequired = event.detail.value === 'Other'?true:false;
    }
    
    handleOnLoad(){
        //this.loaded = !this.loaded;
    }
    
    checkFieldsValidity(fields){
        const allValid = [...fields].reduce((validSoFar, field) => {
            return validSoFar && field.reportValidity();
        }, true);

        return allValid;
    }

    @api
    handleParentSubmit(subStageValue,event,validatedSolutionTechPartner, overageReason,competitiveDeal,pcVal,otherPrimaryCompetitor,scVal,otherSecondaryCompetitor,requiresSigningCustomerDocuments){
        event.preventDefault(); 
        
        const inputFields = this.template.querySelectorAll('lightning-input-field');

        const allValid = this.checkFieldsValidity(inputFields);
        if(allValid){
            const fields = {};
            fields['attributes'] =  {'type': 'churn__c'};
            inputFields.forEach((item) => {
                    fields[item.fieldName] = item.value;
            });
            this.handleSubmit();
            
                //await this.template.querySelector('lightning-record-edit-form').submit();
                
                    updateStage({
                        opportunityId: this.recordId,
                        stageValue: '7 - Closed Lost',
                        subStage:subStageValue,
                        validatedSolutionTechPartner: validatedSolutionTechPartner, 
                        fieldSet: JSON.stringify(fields),
                        overageReason: overageReason,
                        competitiveDeal: competitiveDeal,
                        pcVal: pcVal,
                        otherPrimaryCompetitor: otherPrimaryCompetitor,
                        scVal: scVal,
                        otherSecondaryCompetitor: otherSecondaryCompetitor,
                        requiresSigningCustomerDocuments: requiresSigningCustomerDocuments
                    }).then(() => {
                        this.template.querySelector('c-custom-toast-component').showToast('success', 'Churn/Lost Form Successfully created.');
                        getRecordNotifyChange([{recordId: this.recordId}]);
                        const custEvent = new CustomEvent(
                            'childclose', {
                            detail: 'test'
                        });
                        this.dispatchEvent(custEvent);
                    })
                    .catch((error) => {
                        console.log('Updating opp error :'+error);
                        this.hasNoError = false;
                        this.hideSubmit = true;
                        this.loaded = !this.loaded;
                        console.log('--error'+JSON.stringify(error));
                    });

                    //
                   
                
                
            
           
           
        }
        
        
        
    }
    
    handleSuccess (){
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[STAGE_FIELD.fieldApiName] = '7 - Closed Lost';
        if(getFieldValue(this.opportunity.data,Render_Substage_churn_form) == true)
        {
            fields[SUBSTAGE_FIELD.fieldApiName] = 'Closed Lost';
        }
        else{
            fields[SUBSTAGE_FIELD.fieldApiName] = 'Closed With No Decision';
        }
        fields[Reason_Form_Check.fieldApiName] = false;
        const recordInput = { fields };
        updateRecord(recordInput)
        .then(() => {
            //this.navigateToVFPage();
            this.template.querySelector('c-custom-toast-component').showToast('success', 'Churn/Lost Form Successfully created.');
            getRecordNotifyChange([{recordId: this.recordId}]);
        })
        .catch(error => {
            console.log('Updating opp error :'+error);
            this.hasNoError = false;
            this.hideSubmit = true;
            this.loaded = !this.loaded;
            this.errorMessage =  error.body.output.errors[0].message;
        });
    
        
    }
    
    handleReset(){
        this.navigateToVFPage(); 
    }

    handleSubmit(){
        this.loaded = !this.loaded;
    }
    showErrorToast(){
        this.loaded = !this.loaded;
        this.error = true;
    }
    
    /*
    async triggerSubmitChurnForm(){
        this.loaded = !this.loaded;
        await submitChurnForm({ oppID: this.recordId })
            .then(result => {
                this.loading = true;
                this.template.querySelector('c-custom-toast-component').showToast('success', 'Churn/Lost Form Successfully created.');
                getRecordNotifyChange([{recordId: this.recordId}]);
            })
            .catch(error => {
                this.error = error;
                this.hasError = true;
                this.loading = false;
            });

    }*/
    navigateToVFPage() {
        window.open('/'+this.recordId,'_self');
    }

    get makeRequired() {
        this.type = getFieldValue(this.opportunity.data, TYPE);
        if (this.type!='Existing Customer (Renewal)') {
            return false;
        } else {
            return true;
        }
        return ;
    }

    

    /*navigateToViewOpptyPage(){
        console.log('inside navigate');
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Opportunity',
                actionName: 'view'
            }
        }); 
    }*/
   
}
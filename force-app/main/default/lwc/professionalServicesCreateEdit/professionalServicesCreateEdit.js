import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import getColumnDetails from '@salesforce/apex/ProfessionalServicesCreateEditController.getColumnDetails';
import validateEarlyEngagementRequest from '@salesforce/apex/ProfessionalServicesCreateEditController.validateEarlyEngagementRequest';
import FetchAcountNameFromOpportunity from '@salesforce/apex/ProfessionalServicesCreateEditController.FetchAcountNameFromOpportunity';


export default class ProfessionalServicesCreateEdit extends NavigationMixin(LightningElement) {

@api opportunityLookupIdFromVF;

sfdcBaseURL = '';
showCreateEditForm = true;
navigateBackURL = '';
professionalServicesRecordId;
equipmentRequestObjectApiName = 'Equipment_Request__c';

@track fieldAPINameList_RecordEditForm = [];
recordEditEvent = false;
recordCreateEvent = false;

isSpinnerVisible = false;

@track objectInfo;
equipmentRequestObjectRecordTypes;

showModalPopUp = false;

isRejected = false;
isWarned = false;
isWarnYesButtonClicked = false;

opportunityId;

isEarlyEngagement = false;
onSubmitFieldsValues;

rejectionReason = '';
warningReason = '';
consolidatedTCVOfPSSKU = 0.0;
gobackMessage = 'Your request has been submitted.';
AccountName = '';                      //Added by Ayush Kangar as part of CR#4575

@wire(getObjectInfo, { objectApiName: '$equipmentRequestObjectApiName' })
objectInfo({ error, data }) {
    if (data) {
        //console.log('data : ' + JSON.stringify(data));
        this.equipmentRequestObjectRecordTypes = data.recordTypeInfos;
    } else if (error) {
        console.log('error : ' + JSON.stringify(error));
    }
}

get professionalServicesRecordTypeId() {
    if (this.equipmentRequestObjectRecordTypes) {
        const rtis = this.equipmentRequestObjectRecordTypes;
        return Object.keys(rtis).find(rti => rtis[rti].name === 'Professional Services');
    }
}

connectedCallback() {
    this.getFieldApiName();
    console.log('opportunityLookupIdFromVF : - ' + this.opportunityLookupIdFromVF);
}

renderedCallback() {
    if (this.opportunityId) {
        this.sfdcBaseURL = window.location.origin + '/' + this.opportunityId;
    }
    if (this.opportunityLookupIdFromVF && this.template.querySelector('[data-id="Opportunity__c"]')) {
        this.template.querySelector('[data-id="Opportunity__c"]').value = this.opportunityLookupIdFromVF;
    }
}

async getFieldApiName() {
    try {
        this.isSpinnerVisible = true;
        let objectColumns_RecordEditForm = await getColumnDetails({ fieldSetName: 'ProfessionalServicesCreateEditLWC', objectAPIName: 'Equipment_Request__c' });
        console.log('objectColumns_RecordEditForm : ' + JSON.stringify(objectColumns_RecordEditForm));
        this.fieldAPINameList_RecordEditForm = objectColumns_RecordEditForm;

        this.isSpinnerVisible = false;

    } catch (error) {
        this.isSpinnerVisible = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error, Please Refresh the Page.',
                message: error.detail.message,
                variant: 'error'
            })
        );
    }
}


handleOnLoadEvent(event) {
    //console.log('handleOnLoadEvent event.detail.record : ' + JSON.stringify(event.detail.records));
    //console.log('Segment__c : ' + JSON.stringify(event.detail.records[this.techPartnerUsageRecordId].fields.Segment__c.value));
    this.isSpinnerVisible = false;
}

handleFieldChange(event) {
    //console.log("handleFieldChange fieldName : " + event.target.fieldName + " , Value : " + event.target.value);
    if (event.target.fieldName === "Opportunity__c" && (event.target.value != null || event.target.value != '')) {
        this.opportunityId = event.target.value;   
        this.findAccoundNameForOpp(event.target.value);      //Added by Ayush Kangar as part of CR#4575
    }
    if (event.target.fieldName === "Type__c" && event.target.value === "Early Engagement") {
        this.showHideEarlyEngagementFieldsOnTypeChange(event.target.value);
        //Added by Ayush Kangar as part of CR#4575 - Start
        if(this.opportunityLookupIdFromVF!='' && this.opportunityLookupIdFromVF!=null){
        this.findAccoundNameForOpp(this.opportunityLookupIdFromVF);
        }
        if(this.AccountName && this.template.querySelector('[data-id="Name"]')){
            this.template.querySelector('[data-id="Name"]').value=this.AccountName;
        }
        //Added by Ayush Kangar as part of CR#4575 - End
    } else if (event.target.fieldName === "Type__c" && event.target.value !== "Early Engagement") {
        this.showHideEarlyEngagementFieldsOnTypeChange(event.target.value);
    }
}

showHideEarlyEngagementFieldsOnTypeChange(typeValue) {
    if (typeValue === "Early Engagement") {
        this.isEarlyEngagement = true;
        for (const obj of this.fieldAPINameList_RecordEditForm) {
            //console.log('Obj : ' + JSON.stringify(obj));
            if (obj.fieldName === "Business_Benefit_Reason__c") {
                obj.isRequired = true;
                obj.isEarlyEngagementSelected = false;
            }
            if (obj.fieldName === "Describe_request_customer_expectation__c") {//Describe_request_customer_expectation__c
                obj.isRequired = true;
            }
            if (obj.fieldName === "POC_POV_Completed__c") {
                obj.isRequired = true;
                obj.isEarlyEngagementSelected = false;
            }
            if (obj.fieldName === "Customer_Time_Zone_New__c") {
                obj.isRequired = true;
            }
            if (obj.fieldName === "When_do_you_expect_to_have_the_PO__c") {
                obj.isRequired = true;
            }
            if (obj.fieldName === "Stage__c") {
                obj.isRequired = true;
            }
            //Added by Ayush Kangar as part of CR#4575 - Start
            if (obj.fieldName === "Name") {
                obj.value= this.AccountName;
            }
            //Added by Ayush Kangar as part of CR#4575 - End
        }
    } else {
        this.isEarlyEngagement = false;
        for (const obj of this.fieldAPINameList_RecordEditForm) {
            //console.log('Obj : ' + JSON.stringify(obj));
            if (obj.fieldName === "Business_Benefit_Reason__c") {
                obj.isRequired = false;
                obj.isEarlyEngagementSelected = true;
            }
            if (obj.fieldName === "Describe_request_customer_expectation__c") {
                obj.isRequired = false;
            }
            if (obj.fieldName === "POC_POV_Completed__c") {
                obj.isRequired = false;
                obj.isEarlyEngagementSelected = true;
            }
            if (obj.fieldName === "Customer_Time_Zone_New__c") {
                obj.isRequired = false;
            }
            if (obj.fieldName === "When_do_you_expect_to_have_the_PO__c") {
                obj.isRequired = false;
            }
            if (obj.fieldName === "Stage__c") {
                obj.isRequired = false;
            }
            //Added by Ayush Kangar as part of CR#4575 - Start
            if (obj.fieldName === "Name") {
                obj.value= "";
            }
            //Added by Ayush Kangar as part of CR#4575 - End
        }
    }

}

handleOnSubmitEvent(event) {
    try {
        this.isSpinnerVisible = true;
        console.log('handleOnSubmitEvent event.detail.fields : ' + JSON.stringify(event.detail.fields));
        console.log('handleOnSubmitEvent this.isEarlyEngagement : ' + JSON.stringify(this.isEarlyEngagement));
        if (this.isEarlyEngagement) {
            event.preventDefault();
            const fields = event.detail.fields;
            this.onSubmitFieldsValues = event.detail.fields;
            this.opportunityId = fields.Opportunity__c;
            this.validateSubmitRequest(fields.Opportunity__c);
        }

    } catch (error) {
        console.log('Error : ' + error);
    }
}

async validateSubmitRequest(oppRecordId) {
    try {
        let validateString = await validateEarlyEngagementRequest({ opportunityId: oppRecordId });
        if (validateString) {
            console.log('validateString : ' + JSON.stringify(validateString));
            this.consolidatedTCVOfPSSKU = validateString.consolidatedTCVOfPSSKU;
            if (validateString.status === 'Reject') {
                this.isSpinnerVisible = false;
                this.showModalPopUp = true;
                this.isRejected = true;
                this.rejectionReason = validateString.message;
            } else if (validateString.status === 'Warn') {
                this.isSpinnerVisible = false;
                this.showModalPopUp = true;
                this.isWarned = true;
                this.warningReason = validateString.message;
            } else if (validateString.status === 'Valid') {
                this.isSpinnerVisible = true;
                this.onSubmitFieldsValues.Early_Engagement_Approval_Process_Status__c = 'Approval Process 2 (Geo based approval) - Submitted';
                this.onSubmitFieldsValues.TCV_of_PS_SKU_Consolidated__c = this.consolidatedTCVOfPSSKU;
                console.log('Before Submit : ' + JSON.stringify(this.onSubmitFieldsValues));
                this.template.querySelector('lightning-record-edit-form').submit(this.onSubmitFieldsValues);
            }
        }
    } catch (error) {
        console.log('Error from validateSubmitRequest : ' + JSON.stringify(error));
    }

}

handleOnSuccessEvent(event) {
    console.log('On Success ' + JSON.stringify(event.detail));
    console.log('On Success Record Id ' + JSON.stringify(event.detail.id));
    this.navigateToRecordPage(event.detail.id);
    this.isSpinnerVisible = false;
    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Success',
            message: event.detail.message,
            variant: 'success',
            bubbles: false,
            composed: false
        })
    );
}

handleOnErrorEvent(event) {
    console.log('On Error ' + JSON.stringify(event.detail));
    this.isSpinnerVisible = false;
    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Error, Please Refresh the Page.',
            message: event.detail.message,
            variant: 'error',
            bubbles: false,
            composed: false
        })
    );
}

handleReset(event) {
    const inputFields = this.template.querySelectorAll(
        'lightning-input-field'
    );
    if (inputFields) {
        inputFields.forEach(field => {
            field.reset();
        });
    }
}

handleCancelClick() {
    this.gobackMessage = 'Your request was not submitted.';
    this.handleReset();
    this.showCreateEditForm = false;
    this.navigateBackURL = this.sfdcBaseURL;
    history.back();
}

navigateToRecordPage(recordIDToNavigate) {
    try {
        console.log('navigateToRecordPage called recordIDToNavigate : ' + recordIDToNavigate);
        this.gobackMessage = 'Your request has been submitted.';
        this.showCreateEditForm = false;
        this.navigateBackURL = this.sfdcBaseURL;
        //window.open('/' + recordIDToNavigate);
    } catch (error) {
        console.log('error : ' + JSON.stringify(error));
    }
}

handleRejectOkButton() {
    this.gobackMessage = 'Thank you. This opportunity will follow the standard approval process.';
    this.showModalPopUp = false;
    this.isRejected = false;
    this.showCreateEditForm = false;
    this.navigateBackURL = this.sfdcBaseURL;
}

handleWarnYesButton() {
    try {
        this.showModalPopUp = false;
        this.isWarned = false;
        this.isWarnYesButtonClicked = true;
        //Submit the Record
        this.isSpinnerVisible = true;
        this.onSubmitFieldsValues.Early_Engagement_Approval_Process_Status__c = 'Approval Process 1 (One Step Approval) - Submitted';
        this.onSubmitFieldsValues.TCV_of_PS_SKU_Consolidated__c = this.consolidatedTCVOfPSSKU;
        console.log('Before Submit : ' + JSON.stringify(this.onSubmitFieldsValues));
        this.template.querySelector('lightning-record-edit-form').submit(this.onSubmitFieldsValues);
    } catch (error) {
        console.log('Error : ' + error);
    }

}

handleWarnNoButton() {
    this.gobackMessage = 'Your request was not submitted.';
    this.showModalPopUp = false;
    this.isWarned = false;
    this.showCreateEditForm = false;
    this.navigateBackURL = this.sfdcBaseURL;
}

handleGoBack() {
    history.back();
}

//Added by Ayush Kangar as part of CR#4575 - Start
async findAccoundNameForOpp(oppRecordId) {
    //let oppRecordDetails = await FetchAcountNameFromOpportunity({opportunityId:event.target.value});
    let oppRecordDetails = await FetchAcountNameFromOpportunity({opportunityId:oppRecordId});
    this.AccountName = oppRecordDetails.AccountNameFromOpp;
    if(this.template.querySelector('[data-id = "Type__c"]').value === "Early Engagement"){
        if(this.AccountName && this.template.querySelector('[data-id="Name"]')){
        this.template.querySelector('[data-id="Name"]').value=this.AccountName;
        }
    }
}
//Added by Ayush Kangar as part of CR#4575 - End
}
import { LightningElement,api,wire,track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';

import { reduceErrorsUpgradedAdvanced } from 'c/ldsUtils';
import retrivePGRecords from '@salesforce/apex/ZscalerCloudIDController.retrivePGRecords';
import callPlatformEvent from '@salesforce/apex/ZscalerCloudIDController.firePlatformEvents';



import NAME_FIELD from '@salesforce/schema/Zscaler_Cloud_ID__c.Name';
import STATUS_FIELD from '@salesforce/schema/Zscaler_Cloud_ID__c.Status__c';
import ACC_FIELD from '@salesforce/schema/Zscaler_Cloud_ID__c.Account__c';

export default class RetrieveCloudDetail extends NavigationMixin(LightningElement) {

    @api recordId;
    
    @track cloudRecord;

    @track cloudWrap;

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [NAME_FIELD,STATUS_FIELD,ACC_FIELD]
    })
    wiredZscalerCloudDetailRetrieve({ error, data }) {
        if (data) {
            this.cloudRecord = data;
            this.retrivePGRecordDetails();
        } else if (error) {
            console.log('---wiredZscalerCloudDetailRetrieve--error--',error);
            this.cloudRecord = undefined;
            this.template.querySelector('c-custom-toast-component').showToast('error',  this.errorMessages(error));
        }
    }

    connectedCallback() {}

    
    
    async retrivePGRecordDetails() {
        console.log('---retrivePGRecordDetails--calledd--');
        console.log('---retrivePGRecordDetails--recordId--',this.recordId);
        console.log('---retrivePGRecordDetails--cloudRecord--',this.cloudRecord);
        await retrivePGRecords({zCloudID: this.recordId})
            .then(result => {
                this.cloudWrap = result;
                if(this.existingPGRecords){
                    this.template.querySelector('c-custom-toast-component').showToast('error',  'Provisioning Details alredy exist in the system, Please go to View tenant action on account level.');
                    //this.handleNavigateToZscalerCloud();
                }else{
                    this.firePlatformEvent();
                }
            })
            .catch(error => {
                console.log('---retrivePGRecordDetails--error--',error);
                this.template.querySelector('c-custom-toast-component').showToast('error',  this.errorMessages(error));
            });
    }

    async firePlatformEvent() {
        console.log('---firePlatformEvent--calledd--');
        console.log('---firePlatformEvent--recordId--',this.recordId);
        console.log('---firePlatformEvent--cloudRecord--',this.cloudRecord);

        await callPlatformEvent({zCloudID: this.recordId})
            .then(result => {
                this.pgWrap = result;
                this.handleNavigateToZscalerCloud();
            })
            .catch(error => {
                console.log('---callPlatformEvent--error--',error);
                this.template.querySelector('c-custom-toast-component').showToast('error',  this.errorMessages(error));
            });
    }

    get cloudName(){
        return this.cloudRecord && this.cloudRecord.fields ?  this.cloudRecord.fields.Name.value : '';
    }

    get existingPGRecords(){
        return this.cloudWrap && this.cloudWrap.pgList && this.cloudWrap.pgList.length > 0 ? this.cloudWrap.pgList : undefined;
    }


    errorMessages(error) {
        return reduceErrorsUpgradedAdvanced(error);
    }

    handleNavigateToZscalerCloud() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Zscaler_Cloud_ID__c',
                actionName: 'view'
            },
        });
    }
}
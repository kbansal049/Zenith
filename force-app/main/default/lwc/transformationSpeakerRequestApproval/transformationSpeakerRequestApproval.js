import { LightningElement, track,api,wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import STATUS from '@salesforce/schema/Transformation_Team_Speaker_Request__c.Status__c';
import COMMENTS from '@salesforce/schema/Transformation_Team_Speaker_Request__c.Comments__c';
import RECORD_TYPE from '@salesforce/schema/Transformation_Team_Speaker_Request__c.RecordTypeId';
import Transformation_Object from "@salesforce/schema/Transformation_Team_Speaker_Request__c";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

const fields = [STATUS, COMMENTS];

export default class TransformationSpeakerRequestApproval extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track statusValue = '';
    @track recordTypeId = '';

    @wire(getRecord, { recordId: '$recordId', fields })
    transformationRequests;

    @wire(getObjectInfo, { objectApiName: Transformation_Object })
    getObjectData({data,error}){
        if(data){
            console.log('data.recordTypeInfos--'+JSON.stringify(data.recordTypeInfos));
            const rtis = data.recordTypeInfos;
            this.recordTypeId = Object.keys(rtis).find(
                (rti) => rtis[rti].name === "Rejected"
            );
        }
    };

    get status() {
       
        return getFieldValue(this.transformationRequests.data, STATUS);
    }

    get comments() {
        return getFieldValue(this.transformationRequests.data, COMMENTS);
    }

    renderedCallback(){
        console.log(this.status );
    }

    handleError(event) {
        console.log("handleError event");
        console.log(JSON.stringify(event.detail));
    }

    connectedCallback(){
        console.log(this.status);
    }

    handleSubmit(event){
        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;
        fields.Status__c = this.statusValue;
        fields.isResubmit__c = false;
        if(this.statusValue == 'Rejected'){
            fields.RecordTypeId = this.recordTypeId;
        }
        this.template.querySelector('lightning-record-edit-form').submit(fields);
     }

    handleApprove(event){
        this.statusValue='Approved';
    }

    handleReject(event){
        this.statusValue='Rejected';
    }

    handleSuccess(){
        this.showToast();
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToast() {
        const event = new ShowToastEvent({
            title: 'Response Updated',
            message:
                ' Thank you for your response ',
            variant : 'Success'
        });
        this.dispatchEvent(event);
    }
    
}
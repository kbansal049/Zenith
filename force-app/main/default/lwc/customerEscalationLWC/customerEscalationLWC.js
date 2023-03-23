//Customer Escalation LWC
import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createDefcon from '@salesforce/apex/DefconEscalationController.createDefcon';
import getSupportRecordTypeId from '@salesforce/apex/DefconEscalationController.getSupportRecordTypeId';
import { fireEvent } from 'c/pubsub'

export default class CustomerEscalationLWC extends LightningElement {
    @track showMod = false;
    @track reason = '';
    @track errormsg = '';
    @api caseId;
    @track showSpinner = false;
    @track supportRecordType;

    @wire(getSupportRecordTypeId)
	SupportRecordTypeId({
        error,
        data
	}) {
        if (data) {
            this.supportRecordType = JSON.parse(JSON.stringify(data));
        } else if (error) {
            /*this.dispatchEvent(new ShowToastEvent({
                title: 'Error!!',
                message: JSON.parse(JSON.stringify(error)),
                variant: 'error'
            }));*/
        }
	};

    //Changes here - Removed Esc Category
    assignreason(event) {
        this.reason = event.target.value;
    }
    //Changes here - Removed Esc Category
    
    @api
    showModal() {
        this.showMod = true;
    }

    closeModal() {
        this.showMod = false;
        this.reason = '';
    }

    savereasonforEsc() {
        console.log("caseId", this.caseId);
        if(!this.reason){
            this.errormsg = 'Please fill in the mandatory details';
            return;
        }
        this.errormsg = '';
        this.showSpinner = true;
        createDefcon({
            reason: this.reason,
            escalationOnBehalf: false,
            caseId: this.caseId,
        }).then(result => {
            let message = ''+ result;
            console.log('Result '+ result);
            if (result != 'SUCCESS') {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!!!',
                    message: message,
                    variant: 'error'
                }));
            } else {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!!',
                    message: 'Case is Escalated!',
                    variant: 'success'
                }));
            }
            this.showMod = false;
            this.reason = '';
            this.showSpinner = false;
            console.log('Fire Update Event Start');
            fireEvent(null, 'customerupdatedcase', null);
            console.log('Fire Update Event End');
        }).catch(error => {
            console.log('Error Message '+ error.body.message);
            let err = '' +  error.body.message;
            if(error.body.message.includes('STRING_TOO_LONG')){
                err = 'Escalation Notes and Escalation Reason has a character limit of 32768 and the value you are attempting to input is too long';
            }
            else{
                err = '' + error.body.message;
            }
            this.showMod = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!!',
                message: err,
                variant: 'error'
            }));
            console.log(err);
            this.reason = '';
            this.showSpinner = false;
        });
    }
}
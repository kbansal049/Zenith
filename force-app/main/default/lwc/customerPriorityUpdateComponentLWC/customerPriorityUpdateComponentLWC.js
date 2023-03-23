import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { fireEvent } from 'c/pubsub'
import { CurrentPageReference } from 'lightning/navigation';
import { publish,subscribe,unsubscribe,createMessageContext,releaseMessageContext } from 'lightning/messageService';
import priorityMessageService from "@salesforce/messageChannel/priorityMessage__c";

export default class CustomerPriorityUpdateComponentLWC extends LightningElement {
    @track showMod = false;
    @track reason = '';
    @track errormsg = '';
    @api caseId;
    @track currPriority;
    @api showSpinner = false;

    @api
    showModal() {
        this.showMod = true;
        this.showSpinner = true;
    }

    @wire(CurrentPageReference) pageRef;

    closeModal() {
        this.showMod = false;
    }

    stopSpinner(){
        this.showSpinner = false;
    }
    
    updateCasePriority(){
        this.showSpinner = true;
    }

    handleSuccess(event){
        var currPrior = this.template.querySelector('lightning-input-field').value;
        this.publishLMS(currPrior);
        this.showSpinner = false;
        this.closeModal();
        this.showSuccessToast();
    }

    
    showSuccessToast() {
        const evt = new ShowToastEvent({
            title: 'Case Priority Updated Successfully!',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    

    context = createMessageContext();

    publishLMS(cPrior) {
        const message = {
            currentPriority: cPrior,
        };
        publish(this.context, priorityMessageService, message);
    }
}
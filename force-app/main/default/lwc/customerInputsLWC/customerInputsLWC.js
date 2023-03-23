import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { fireEvent } from 'c/pubsub'
import { CurrentPageReference } from 'lightning/navigation';
import USER_ID from "@salesforce/user/Id";
import noteMessage from '@salesforce/label/c.Customer_Update_Details_Note';

export default class CustomerPriorityUpdateComponentLWC extends LightningElement {
    currentUserId = USER_ID;
    @track showMod = true;
    @track reason = '';
    @track errormsg = '';
    @api caseId;
    @track currPriority;
    @track showSpinner = true;
    messageNote = noteMessage;


    closeModal() {
        this.showMod = false;
    }

    handleSuccess(event){
        //eval("$A.get('e.force:refreshView').fire();");
        this.closeModal();
        this.showSpinner = false;
        this.showSuccessToast();
    }

    handleError(event){
        this.showSpinner = false;
    }

    handleLoad(){
        this.showSpinner = false;
    }

    handleSubmit(event){
        this.showSpinner = true;
    }

    showSuccessToast() {
        const evt = new ShowToastEvent({
            title: 'Contact Details Updated Successfully!',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

}
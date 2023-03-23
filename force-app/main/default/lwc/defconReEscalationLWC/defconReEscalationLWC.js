import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import updateDefcon from '@salesforce/apex/DefconReEscalationController.updateDefcon';

export default class DefconEscalationLWC extends LightningElement {
    @api recordId;
    @track showSpinner = false;
    @track errorMessage = '';
    @track showError = false;

    connectedCallback() {
    }

    handleSubmit(event){
        this.showSpinner = true;
        this.errorMessage = '';
        this.showError = false;
        event.preventDefault();
        const fields = event.detail.fields;
        updateDefcon({reason:fields['Escalation_Reason__c'],caseId:this.recordId})
        .then(result => {
            if(result == 'SUCCESS'){
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: 'Case is been escalated successfully!',
                    variant: 'success'
                });
                this.dispatchEvent(evt);
                this.showSpinner = false;
                eval("$A.get('e.force:refreshView').fire();");
                this.dispatchEvent(new CloseActionScreenEvent());
            }
            if(result == 'VALIDATION'){
                this.showSpinner = false;
                this.errorMessage = 'You cannot escalate this case';
                this.showError = true;
            }
            if(result == 'NOTELIGIBLE'){
                this.showSpinner = false;
                this.errorMessage = 'You are not eligible to escalate this case';
                this.showError = true;
            }

        })
        .catch(error => {
            console.log('Error message '+JSON.stringify(error));
            this.showSpinner = false;
            if(error.body.message.includes('Please indicate that the case is escalated on behalf of customer')){
                this.errorMessage = 'Please indicate that the case is escalated on behalf of customer';
            }else{
                this.errorMessage = error.body.message;
            }
            this.showError = true;
        });
    }

    onFormLoad(){
        this.showSpinner = false;
    }
}
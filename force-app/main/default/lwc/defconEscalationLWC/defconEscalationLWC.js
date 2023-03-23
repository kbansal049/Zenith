import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import createDefcon from '@salesforce/apex/DefconEscalationController.createDefcon';

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
        createDefcon({reason:fields['Escalation_Reason__c'],escalationOnBehalf:fields['Escalation_on_behalf_of_Customer__c'], caseId:this.recordId})
        .then(result => {
            console.log('Result '+result);
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
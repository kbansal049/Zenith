import { LightningElement, api, track } from 'lwc';

export default class CustomLookupLWC extends LightningElement {
    @api childObjectApiName = ''; //Contact is the default value
    @api targetFieldApiName = ''; //AccountId is the default value
    @api formStyle = '';
    @api fieldLabel = '';
    @api disabled = false;
    @api value;
    @api required = false;
    @track loading = true;

    handleChange(event) {
        // Creates the event
        console.log(event.detail.value);
        const selectedEvent = new CustomEvent('valueselected', {
            detail: event.detail.value
        });
        //dispatching the custom event
        this.dispatchEvent(selectedEvent);
    }

    @api isValid() {
        if (this.required) {
            this.template.querySelector('lightning-input-field').reportValidity();
        }
    }
    handleload(event) {
        console.log(this.childObjectApiName);
        console.log(this.targetFieldApiName);
        this.loading = false;
    }

    handleSubmit(event) {
        
    }

    handleSuccess(event) {

    }
    handleError(event) {

    }
}
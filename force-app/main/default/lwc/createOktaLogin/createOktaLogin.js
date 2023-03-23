import { LightningElement, track, wire, api } from 'lwc';
import createoktauser from '@salesforce/apex/CreateOktaUser.checkandCreateUser';

export default class CreateOktaLogin extends LightningElement {
    @api recordId;
    @track message;
    @track className;
    @track loading = true;
    isRenderedCallbackExecuted = false;
    renderedCallback(){
        if(this.isRenderedCallbackExecuted){
            return;
        }
        createoktauser({ conId: this.recordId}).then(result => {
            this.message = result.message;
            this.className = result.classname;
            this.loading = false;
        }).catch(error => {
            // Showing errors if any while inserting the files
            if (error) {
                let message = 'Error: ';
                if (Array.isArray(error.body)) {
                    message = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    message = error.body.message;
                }
                this.message = message;
                this.className = 'slds-box slds-theme_error';
                this.loading = false;
            }
        });
        this.isRenderedCallbackExecuted = true;
    }
    
}
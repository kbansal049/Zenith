import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import issueNotResolved from '@salesforce/apex/CaseEscalationController_LWC.issueNotResolved';
import { fireEvent } from 'c/pubsub'

export default class needHelpCommentLWC extends LightningElement {
    @track showMod = false;
    @track reason = '';
    @track errormsg = '';
    @api caseId;
    @api showHelpNeededButton=false;

    @api
    showModal() {
        this.showMod = true;
    }

    assignreason(event) {
        this.reason = event.target.value;
    }

    closeModal() {
        this.showMod = false;
        this.reason = '';
    }

    saveComments() {
        if(!this.reason){
            this.errormsg = 'Please update your comments';
            return;
        }
        this.errormsg = '';
        issueNotResolved({
            recId: this.caseId,
            comments: this.reason
        }).then(result => {
            console.log(this.caseId);
            console.log(this.reason);
            console.log(result);
            let message = ''+ result;
            if (result != 'Success') {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!!',
                    message: message,
                    variant: 'error'
                }));
            } else {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!!',
                    variant: 'success'
                }));
            }
            this.showMod = false;
            this.reason = '';
            const helpNeededEvent = new CustomEvent("helpneededvaluechange", {
                detail: this.showHelpNeededButton
              });
              this.dispatchEvent(helpNeededEvent);

            fireEvent(null, 'customerupdatedcase', null);
        })
            .catch(error => {
                let err = '' +  error.message;
                this.showMod = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!!',
                    message: err,
                    variant: 'error'
                }));
                console.log(err);
                this.reason = '';
            });
    }
}
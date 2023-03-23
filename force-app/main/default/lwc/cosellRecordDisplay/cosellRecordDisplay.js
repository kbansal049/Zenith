import { LightningElement, api, track, wire } from 'lwc';
import updateStatus from '@salesforce/apex/coSellActivityLWCHelper.updateStatus';
import saveContdetails from '@salesforce/apex/coSellActivityLWCHelper.updateContact';
import cosellInvite from '@salesforce/label/c.Cosell_Invited';
import cosellCompleted from '@salesforce/label/c.Cosell_Completed';
import cosellWithdrawn from '@salesforce/label/c.Cosell_Withdrawn';

export default class CosellRecordDisplay extends LightningElement {
    @api record;
    @track selectedcontact;
    @api showInvite;
    @api showWithdraw;
    @api showComplete;
    @track isEdit = false;
    @track loading = false;
    selectedRecordId;

    editrecord() {
        this.isEdit = true;
    }
    canceledit() {
        this.isEdit = false;
    }

    saveContact() {
        this.loading = true;
        console.log(this.selectedRecordId);
        if (this.selectedRecordId == null) {
            console.log('selected record is null');
            const filterChangeEvent = new CustomEvent('erroronsave', {
                msg: 'Contact must be selected before saving.'
            });
            // Fire the custom event
            this.dispatchEvent(filterChangeEvent);
            this.loading = false;
        }
        saveContdetails({ rec: this.record, contId: this.selectedRecordId }).then(result => {
            console.log('save is  successful');
            this.loading = false;
            this.isEdit = false;
            const filterChangeEvent = new CustomEvent('successonsave');
            // Fire the custom event
            this.dispatchEvent(filterChangeEvent);
        }).catch(error => {
            console.log('save is  error' + error.body);
            // Showing errors if any while inserting the files
            if (error) {
                let message = 'Error: ';
                if (Array.isArray(error.body)) {
                    message += error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    message += error.body.message;
                } else if (error.body.pageErrors && error.body.pageErrors[0] && error.body.pageErrors[0].message) {
                    message += error.body.pageErrors[0].message;
                }
                console.log(message);
                const filterChangeEvent = new CustomEvent('erroronsave', {
                    detail: message
                });
                // Fire the custom event
                this.dispatchEvent(filterChangeEvent);
                this.loading = false;
            }
        });
    }

    settoinvite() {
        this.loading = true;
        updateStatus({ rec: this.record, status: cosellInvite }).then(result => {
            this.loading = false;
            const filterChangeEvent = new CustomEvent('successonsave');
            // Fire the custom event
            this.dispatchEvent(filterChangeEvent);
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
                const filterChangeEvent = new CustomEvent('erroronsave', {
                    msg: { message }
                });
                // Fire the custom event
                this.dispatchEvent(filterChangeEvent);
                this.loading = false;
            }
        });
    }

    settowithdraw() {
        this.loading = true;
        updateStatus({ rec: this.record, status: cosellWithdrawn }).then(result => {
            this.loading = false;
            const filterChangeEvent = new CustomEvent('successonsave');
            // Fire the custom event
            this.dispatchEvent(filterChangeEvent);
        }).catch(error => {
            // Showing errors if any while inserting the files
            if (error) {
                let message = 'Error: ';
                if (Array.isArray(error.body)) {
                    message = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    message = error.body.message;
                }
                const filterChangeEvent = new CustomEvent('erroronsave', {
                    msg: { message },
                });
                // Fire the custom event
                this.dispatchEvent(filterChangeEvent);
                this.loading = false;
            }
        });
    }

    settocomplete() {
        this.loading = true;
        updateStatus({ rec: this.record, status: cosellCompleted }).then(result => {
            this.loading = false;
            const filterChangeEvent = new CustomEvent('successonsave');
            // Fire the custom event
            this.dispatchEvent(filterChangeEvent);

            const completesuccess = new CustomEvent('completesuccess');
            // Fire the custom event
            this.dispatchEvent(completesuccess);
        }).catch(error => {
            // Showing errors if any while inserting the files
            if (error) {
                let message = 'Error: ';
                if (Array.isArray(error.body)) {
                    message = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    message = error.body.message;
                }
                const filterChangeEvent = new CustomEvent('erroronsave', {
                    msg: { message },
                });
                // Fire the custom event
                this.dispatchEvent(filterChangeEvent);
                this.loading = false;
            }
        });
    }

    handleValueSelcted(event) {
        this.selectedRecordId = '' + event.detail;
        console.log('event to asign contactid ' + this.selectedRecordId);
    }

}
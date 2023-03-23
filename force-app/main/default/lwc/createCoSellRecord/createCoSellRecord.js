import { LightningElement, api, track, wire } from 'lwc';
import createCosell from '@salesforce/apex/coSellActivityLWCHelper.createCosell';
import getExistingPartners from '@salesforce/apex/coSellActivityLWCHelper.getExistingPartners';

export default class CreateCoSellRecord extends LightningElement {
    @api hasAWinvite;
    @api hasPOCinvite;
    @api hasAwPovInvite;
    @api oppId;
    @track recordtoSave = {};
    @track loading = true;
    @track saveRecord = false;
    @track existingpartners = [];
    @track errormsg = '';

    get options() {
        console.log('inside cosell create ' + this.hasAWinvite);
        console.log('inside cosell create ' + this.hasPOCinvite);
        let res = [];
        /* if (!this.hasAWinvite) {
            res.push({ label: 'Architecture Workshop', value: 'Architecture Workshop' })
        }
        if (!this.hasPOCinvite) {
            res.push({ label: 'POV', value: 'POV' })
        } */
        if (!this.hasAwPovInvite) {
            res.push({ label: 'AW/POV', value: 'AW/POV' })
        }
        return res;
    }

    handleFieldChange(e) {
        this.recordtoSave[e.currentTarget.fieldName] = e.target.value;
    }

    handleActivityChange(e) {
        this.recordtoSave['Activity__c'] = e.detail.value;
    }


    handleload(event) {
        if(!this.saveRecord){
            this.loading = false;
        }
    }

    handleSubmit(event) {
        this.loading = true;
        this.saveRecord = true;
        this.errormsg = '';
        event.preventDefault();       // stop the form from submitting
        if(!this.recordtoSave['Activity__c']){
            this.errormsg = 'Activity Type has to be selected.';
            this.loading = false;
            return;
        }
        getExistingPartners({ opportunityId: this.oppId }).then(result1 => {

            let thiscosell = this.recordtoSave['Partner__c'] + '' + this.recordtoSave['Activity__c'];
            console.log(result1);
            console.log(thiscosell);
            if (result1 && thiscosell && result1.indexOf(thiscosell) != -1) {
                this.errormsg = 'This partner with same Cosell Activity already exists.';
                this.loading = false;
                return;
            }

            this.recordtoSave['Opportunity__c'] = this.oppId;
            createCosell({ rec: this.recordtoSave })
                .then(result => {
                    this.loading = false;
                    this.cancelCreation();
                    const filterChangeEvent = new CustomEvent('reloadcosell');
                    // Fire the custom event
                    this.dispatchEvent(filterChangeEvent);
                })
                .catch(error => {
                    // Showing errors if any while inserting the files
                    console.log(error);
                    let message = 'Error: ';
                    if (error) {
                        if (Array.isArray(error.body)) {
                            message += error.body.map(e => e.message).join(', ');
                        } else if (typeof error.body.message === 'string') {
                            message += error.body.message;
                        } else if (error.body.pageErrors && error.body.pageErrors[0] && error.body.pageErrors[0].message) {
                            message += error.body.pageErrors[0].message;
                        }
                    }
                    this.loading = false;
                    this.errormsg = message;
                });
        }).catch(error => {
            this.existingpartners = [];
            this.errormsg = 'Error Loading existing cosell activites. Please contact administrator';
            this.loading = false;
        });

    }

    handleSuccess(event) {

    }
    handleError(event) {
        this.loading = false;
    }

    cancelCreation() {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }

        const filterChangeEvent = new CustomEvent('closemodal');
        // Fire the custom event
        this.dispatchEvent(filterChangeEvent);
    }

}
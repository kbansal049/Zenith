import { LightningElement, track, api } from 'lwc';
import checkClosedOpptyforDRbeforeExp from '@salesforce/apex/DealRegExpirationHelper_LWC.checkDealRegValidity';
import getOpportunitiesforDR from '@salesforce/apex/DealRegExpirationHelper_LWC.getOppsbeforeExpiration';
import expireDealReg from '@salesforce/apex/DealRegExpirationHelper_LWC.saveExpiration';

export default class ExpireDealRegLWC extends  LightningElement {
    @api dealRegtoConvert;
    @api recordId;
    @api opptyId;
    @api dealRegname;
    @api dealRegStatus;
    @api dealRegExpirationReason;
    @track opplst = [];
    @track errmsg;
    @track showModal = false;
    @track loading = false;
    @track loadData = false;
    expirationReason;

    isRenderedCallbackExecuted = false;
    renderedCallback() {
        if (this.isRenderedCallbackExecuted) {
            return;
        }
        if (this.dealRegStatus == 'Expired' || (this.dealRegStatus == 'Pending Conversion' && this.dealRegExpirationReason)) {
            this.errmsg = 'This Deal Reg is already expired.';
        }
        if (this.dealRegStatus != 'Converted') {
            this.errmsg = 'Only a converted Deal Reg can be Expired.';
        } else {
            this.loading = true;
            checkClosedOpptyforDRbeforeExp({ dealRegId: this.recordId }).then(result => {
                if (result != '') {
                    this.errmsg = result;
                } else {
                    this.loadData = true;
                }
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
                    this.errmsg = message;
                    this.loading = false;
                }
            });
        }
        this.isRenderedCallbackExecuted = true;
    }

    getOpps() {
        this.loading = true;
        if (!this.expirationReason) {
            return;
        }
        getOpportunitiesforDR({ dealRegId: this.recordId }).then(result => {
            this.loading = false;
            this.opplst = result;
            if (this.opplst.length > 0) {
                this.showModal = true;
            } else {
                this.expireDR();
            }
        }).catch(error => {
            // Showing errors if any while inserting the files
            if (error) {
                let message = 'Error: ';
                if (Array.isArray(error.body)) {
                    message = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    message = error.body.message;
                }
                this.errmsg = message;
                this.loading = false;
            }
        });
    }

    expireDR() {
        // opty id is coming Id
        console.log('expireDR -- Opty ID::'+this.opptyId);
        this.loading = true;
        expireDealReg({ drtoExpire: this.recordId, drtoConvert: this.dealRegtoConvert, oppId: this.opptyId, expreason: this.expirationReason }).then(result => {
            this.loading = false;
            this.navigatoToRecord();
        }).catch(error => {
            // Showing errors if any while inserting the files
            console.log('++++' + error);
            if (error) {
                let message = 'Error: ';
                if (Array.isArray(error.body)) {
                    message = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    message = error.body.message;
                }
                this.errmsg = message;
                this.loading = false;
            }
        });
    }

    navigatoToRecord() {
        window.location.href = '/' + (this.opptyId ? this.opptyId : this.recordId);
       /* console.log('navigatoToRecord'+ document.referrer.indexOf(".lightning.force.com"));
        if (document.referrer.indexOf(".lightning.force.com") > 0) {
            console.log('Success');
           this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    objectApiName: 'Deal_Reg__c',
                    actionName: 'view'
                }
            });
            window.location.href = '/' + (this.opptyId ? this.opptyId : this.recordId);
        } else {
            window.location.href = '/' + (this.opptyId ? this.opptyId : this.recordId);
        }*/
    }

    assignreason(event) {
        this.expirationReason = event.target.value;
    }

    gotoDR() {
        window.location.href = '/' + (this.dealRegtoConvert ? this.dealRegtoConvert : this.recordId);
        /*if (document.referrer.indexOf(".lightning.force.com") > 0) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.dealRegtoConvert ? this.dealRegtoConvert : this.recordId,
                    actionName: 'view'
                }
            });
        } else {
            window.location.href = '/' + (this.dealRegtoConvert ? this.dealRegtoConvert : this.recordId);
        }*/
    }
}
import { LightningElement, wire, api, track } from 'lwc';
import checkDRinit from '@salesforce/apex/DealRegConversionLWCHelper.init';
import pendconv from '@salesforce/label/c.DR_Pending_Conversion';
import drSourced from '@salesforce/label/c.Deal_Reg_Type_Sourced';
import pendexp from '@salesforce/label/c.DR_Pending_Expiration';

export default class DealRegConversion_LWC extends LightningElement {
    @api recordId;
    @api dealRegStatus;
    @api dealRegDiscoveryDate;
    @api dealRegType;
    @track errmsg;
    @track showModal = false;
    @track loading = false;
    @track loadData = false;
    @track opplst = [];
    @track conditionSet = [];
    @track dealReg;
    dealRegLink;
    isRenderedCallbackExecuted = false;

    renderedCallback() {
        if (this.isRenderedCallbackExecuted) {
            return;
        }
        this.isRenderedCallbackExecuted = true;
        this.dealRegLink = '/' + this.recordId;
        if(this.dealRegStatus != 'Approved' && this.dealRegStatus != pendconv && this.dealRegStatus != pendexp){
            this.errmsg = 'Deal Conversion is allowed on Approved / Pending Conversion / Pending Expiration Deals';
            return;
        }
        console.log(this.dealRegType);
        if(!this.dealRegType){
            this.errmsg = 'Please select Deal Reg Type before conversion.';
            return;
        }

        if(!this.dealRegDiscoveryDate && this.dealRegType == drSourced){
            this.errmsg = 'The Deal registration cannot be converted without a Discovery meeting.';
            return;
        }

        this.loading = true;
        checkDRinit({ dealregtoconvert: this.recordId }).then(result => {
            console.log(result);
            if (!result.convertedOppId && !result.oppList) {
                errmsg = 'This Deal registration cannot be converted as there are no open opportunities found for this customer.';
            } 
            else if (result.convertedOppId) {
                window.location.href = '/' + result.convertedOppId;
                /*if (document.referrer.indexOf(".lightning.force.com") > 0) {
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: result.convertedOppId,
                            actionName: 'view'
                        }
                    });
                } else {
                    window.location.href = '/' + result.convertedOppId;
                }*/
            }else{
                console.log('inside else');
                this.opplst = result.oppList;
                this.dealReg = result.dealReg;
                this.conditionSet = result.conditionSet;
                this.loadData = true;
            }
            this.loading = false;
        }).catch(error => {
            // Showing errors if any while inserting the files
            if (error) {
                console.log('inside error');
                console.log(error);
                let message = 'Error: ';
                if (Array.isArray(error.body)) {
                    message = error.body.map(e => e.message).join(', ');
                } else if (error.body && error.body.message && typeof error.body.message === 'string') {
                    message = error.body.message;
                } else if (error.body.pageErrors != undefined && error.body.pageErrors && error.body.pageErrors[0] && error.body.pageErrors[0].message) {
                    message += error.body.pageErrors[0].message;
                } else if (error.body && error.body.fieldErrors && error.body.fieldErrors[0] && error.body.fieldErrors[0].message) {
                    message += error.body.fieldErrors[0].message;
                }
                this.errmsg = message;
                this.loading = false;
            }
        });

    }

    showerror(event){
        let mesg = event.detail;
        this.errmsg = mesg;
    }
}
import { LightningElement, api, wire, track } from 'lwc';
import getCosellDetails from '@salesforce/apex/coSellActivityLWCHelper.getCosellDetails';
import { refreshApex } from '@salesforce/apex';


export default class CosellActivitiesPartners extends LightningElement {
    @api recId;
    wiredResult;
    @track coselllst;
    @track isCosellPresent;
    @track hasAWinvite;
    @track hasPOCinvite;
    @track hasAWPOVinvite;
    @track showaddnew;
    @track loading = true;
    @track errmsg;
    @track showCreation = false;
    @wire(getCosellDetails, { oppId: '$recId' })
    processcoselllst(results) {
        this.wiredResult = results;
        this.loading = false;
        if (results.data) {
            console.log(results.data);
            this.coselllst = results.data.wrplst;
            this.isCosellPresent = results.data.isCosellPresent;
            this.hasAWinvite = results.data.hasAWinvited;
            this.hasPOCinvite = results.data.hasPOVinvited;
            this.hasAWPOVinvite = results.data.hasAWPOVinvited;
            //this.showaddnew = !(this.hasAWinvite && this.hasPOCinvite);
            this.showaddnew = !this.hasAWPOVinvite;
            console.log('inside cosell activities ' + this.hasAWinvite);
            console.log('inside cosell activities ' + this.hasPOCinvite);
        }
        else if (results.error) {
            let error = results.error;
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.errmsg = message;
        }
    }

    reloadData(event) {
        this.loading = false;
        return refreshApex(this.wiredResult);
    }

    showerror(event) {
        let mesg = event.detail;
        this.errmsg = mesg;
    }

    refreshentirecomponent(event) {
        const filterChangeEvent = new CustomEvent('reloadopppartner');
        // Fire the custom event
        this.dispatchEvent(filterChangeEvent);
    }

    addNewCosell(){
        this.showCreation = true;
    }

    closeModal(){
        this.showCreation = false;
    }
}
import { LightningElement,api,wire,track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import NAME_FIELD from '@salesforce/schema/Account.Name';



export default class NfrLicenseReqAction extends NavigationMixin(LightningElement) {

    @api recordId;

    @track accountRecord;

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [NAME_FIELD]
    })
    wiredOpportunity({ error, data }) {
        if (data) {
            this.accountRecord = data;
            this.handleProvReqNavigate();
        } else if (error) {
            this.error = error;
            this.accountRecord = undefined;
        }
    }

    connectedCallback() {
        //this.handleProvReqNavigate();
    }

    handleProvReqNavigate() {
        console.log('---handleProvReqNavigate--calledd--');
        console.log('---handleProvReqNavigate--recordId--',this.recordId);
        console.log('---handleProvReqNavigate--accountRecord--',this.accountRecord);

        
        if(this.accountRecord){
            var compDefinition = {
                componentDef: "c:nfrLicenseReq",
                attributes: {
                    recordId: this.recordId,
                    isProvisiongModalOpen : true
                }
            };
            // Base64 encode the compDefinition JS object
            var encodedCompDef = btoa(JSON.stringify(compDefinition));
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: '/one/one.app#' + encodedCompDef
                }
            });
        }
    }

    get accountName(){
        return this.accountRecord && this.accountRecord.fields ?  this.accountRecord.fields.Name.value : '';
    }

}
import { LightningElement,api,wire,track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import NAME_FIELD from '@salesforce/schema/Opportunity.Name';



export default class ProvisioningReqAction extends NavigationMixin(LightningElement) {

    @api recordId;

    @track opportunityRecord;

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [NAME_FIELD]
    })
    wiredOpportunity({ error, data }) {
        if (data) {
            this.opportunityRecord = data;
            this.handleProvReqNavigate();
        } else if (error) {
            this.error = error;
            this.opportunityRecord = undefined;
        }
    }

    connectedCallback() {
        //this.handleProvReqNavigate();
    }

    handleProvReqNavigate() {
        console.log('---handleProvReqNavigate--calledd--');
        console.log('---handleProvReqNavigate--recordId--',this.recordId);
        console.log('---handleProvReqNavigate--opportunityRecord--',this.opportunityRecord);

        
        if(this.opportunityRecord){
            var compDefinition = {
                componentDef: "c:provisioningReq",
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

    get opportunityName(){
        return this.opportunityRecord && this.opportunityRecord.fields ?  this.opportunityRecord.fields.Name.value : '';
    }

}
import { LightningElement,api,wire,track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import NAME_FIELD from '@salesforce/schema/Opportunity.Name';



export default class AddOpportunityTeamMemberAction extends NavigationMixin(LightningElement) {

    @api recordId;

    @track opportunityRecord;

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [NAME_FIELD]
    })
    wiredOpportunity({ error, data }) {
        if (data) {
            this.opportunityRecord = data;
            this.handleOppTeamNavigate();
        } else if (error) {
            this.error = error;
            this.opportunityRecord = undefined;
        }
    }

    connectedCallback() {
        
    }

    handleOppTeamNavigate() {
     
        
        if(this.opportunityRecord){
            var compDefinition = {
                componentDef: "c:addOpportunityTeamMemberLWC",
                attributes: {
                    recordId: this.recordId,
                    isTeamMemCreationModalOpen : true
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
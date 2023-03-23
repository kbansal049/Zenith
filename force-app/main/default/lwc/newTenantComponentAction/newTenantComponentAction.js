import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class NewTenantComponentAction extends NavigationMixin(LightningElement) {
    @api recordId;
    @api accountId;
    @api async invoke() {
        await this.sleep(2000);

        console.log('---recordId---',this.recordId);
        this.handleProvReqNavigate();
    }

    sleep(ms) {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    connectedCallback() {
        this.handleProvReqNavigate();
    }

    handleProvReqNavigate() {
        if(this.recordId){
            var compDefinition = {
                componentDef: "c:newTenantComponent",
                attributes: {
                    recordId: this.recordId,
                    accountId : this.accountId
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
}
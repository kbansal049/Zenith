import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class ManageProvisioningAccountActionHL extends NavigationMixin(LightningElement) {
    @api recordId;
   
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
        console.log('---handleProvReqNavigate--calledd--');
        console.log('---handleProvReqNavigate--recordId--',this.recordId);
        if(this.recordId){
            var compDefinition = {
                componentDef: "c:manageProvisioningAccount",
                attributes: {
                    recordId: this.recordId
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
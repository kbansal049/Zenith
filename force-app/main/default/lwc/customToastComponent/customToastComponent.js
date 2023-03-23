import { LightningElement,track,api} from 'lwc';

export default class CustomToastComponent extends LightningElement 
{
    @track type;
    @track message;
    @track showToastBar = false;
    @api autoCloseTime ;
 
    @api
    showToast(type, message) {
        console.log('toast called');
        this.type = type;
        this.message = message;
        this.showToastBar = true;
        setTimeout(() => {
            this.closeModel();
        }, this.autoCloseTime);
    }
    @api
  
    closeModel() {
        this.showToastBar = false;
        this.type = '';
        this.message = '';
	}
 
    get getIconName() {
        return 'utility:' + this.type;
    }
 
    get innerClass() {
        return 'slds-icon_container slds-icon-utility-' + this.type + ' slds-icon-utility-success slds-m-right_small slds-no-flex slds-align-top';
    }
 
    get outerClass() {
        return 'slds-notify slds-notify_toast slds-theme_' + this.type;
    }

}
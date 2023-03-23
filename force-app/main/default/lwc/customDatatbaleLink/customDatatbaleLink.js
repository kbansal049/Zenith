import { LightningElement,api } from 'lwc';
export default class CustomDatatbaleLink extends LightningElement {
    @api recId;
    @api linkName;
    handleClick(){
        let paramData = {recId : this.recId, linkName : this.linkName};
        const ev = new CustomEvent('customlinkaction', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: paramData,
        });
        this.dispatchEvent(ev);
    }
}
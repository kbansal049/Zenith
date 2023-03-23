import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchSpecialInst from "@salesforce/apex/CaseSpecialInstructionCmpCtrl.fetchAccountSpecialInst";
export default class CaseAccountSpecialInstructionLWC extends LightningElement {
    @track type;
    @track message;
    @track showToastBar = false;
    @api autoCloseTime;
    @api recordId;
    @track finalData;
    @api threshold;
    @api defaultSize;
    
    @wire(fetchSpecialInst,{caseId: '$recordId'})
    fetchAccountSpecialInst({ error, data }){
        if(data){
            if(data != "Error"){
                this.showToastBar = true;
                this.type = 'success';
                let data1='';
                let showMore = false;
                data = data.replaceAll('<a', '<a style="color: blue"');
                if(data.length >= this.threshold){
                    data1 = data.substring(0,this.defaultSize);
                    const container = this.template.querySelector('.messageClass');
                    container.innerHTML = data1+'<span>........</span>';
                    showMore = true;
                    this.finalData = data;
                }
                else{
                    const container = this.template.querySelector('.messageClass');
                    container.innerHTML = data;
                }
                this.template.querySelector('[data-id="fullBlock"]').className='slds-show';
                if(showMore == true){
                    this.template.querySelector('[data-id="showMoreBlock"]').className='slds-show';
                }
                //this.template.querySelector('.messageClass').className = 'messageClass custom-class';
                setTimeout(() => {
                    this.closeModel();
                }, this.autoCloseTime);
            }
            
        }
    }

    showMoreContent(){
        console.log('Show More Content Clicked');
        this.template.querySelector('[data-id="showMoreBlock"]').className='slds-hide';
        const container = this.template.querySelector('.messageClass');
        container.innerHTML = this.finalData;
    }
    closeModel() {
        this.showToastBar = false;
        this.template.querySelector('[data-id="fullBlock"]').className='slds-hide';
        this.type = '';
        this.message = '';
 }
 
    get getIconName() {
        return 'utility:success';
    }
 
    get innerClass() {
        return 'slds-icon_container slds-icon-utility-success slds-icon-utility-success slds-m-right_small slds-no-flex slds-align-top';
    }
 
    get outerClass() {
        //return 'slds-notify slds-notify_toast slds-theme_info';
        return 'slds-notify slds-notify_toast box-color';
    }
}
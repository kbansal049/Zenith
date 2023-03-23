import { LightningElement, track } from 'lwc';

export default class ParentOrderTracker extends LightningElement {
    @track isSelectedPath = true;
    @track isSpinnerLoading = true;
    @track isSelectedPathOrderTracker = true;
    @track isSelectedPathDashboards = false;
    @track selectedStep = 'OrderTracker';
    @track Step1Class="slds-path__item slds-is-current slds-is-active";
    @track Step2Class="slds-path__item slds-is-incomplete";
    

    connectedCallback(){
        this.isSpinnerLoading = false;
        
    }
    handleSelectedOrderTracker(){
        this.isSpinnerLoading = true;        
        this.selectedStep = 'OrderTracker';
        this.isSelectedPathOrderTracker=true;
        this.isSelectedPathDashboards = false;
        this.Step1Class="slds-path__item slds-is-current slds-is-active";
        this.Step2Class="slds-path__item slds-is-incomplete";
        this.handleSpinnerLoadingOff();
    }
    handleSelectedDashboard(){
        this.isSpinnerLoading = true;        
        this.selectedStep = 'Dashboard';
        this.isSelectedPathOrderTracker=false;
        this.isSelectedPathDashboards = true;
        this.Step2Class="slds-path__item slds-is-current slds-is-active";
        this.Step1Class="slds-path__item slds-is-incomplete";
        this.handleSpinnerLoadingOff();
    }
    handleSpinnerLoadingOff() {
        this.delayTimeout = setTimeout(() => {
            this.isSpinnerLoading = false;
        }, 300);
    }
}
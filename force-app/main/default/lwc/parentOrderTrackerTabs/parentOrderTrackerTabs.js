import { LightningElement,track } from 'lwc';

export default class ParentOrderTrackerTabs extends LightningElement 
{
    @track selectedTab = 'Assigned To Me';
    @track AssignedToMeSelected = true;
    @track AllSelected = false;
    @track AssignedToMeClass="slds-path__item slds-is-current slds-is-active";
    @track AllClass="slds-path__item slds-is-incomplete";
    @track isSpinnerLoading=false;
   
    selectAssignedToMe() {
        this.isSpinnerLoading=true;
        this.selectedTab = 'Assigned To Me';
        this.AssignedToMeSelected = true;
        this.AllSelected = false;
        this.step3select = false;
        this.AssignedToMeClass="slds-path__item slds-is-current slds-is-active";
        this.AllClass="slds-path__item slds-is-incomplete";
        this.Step3Class="slds-path__item slds-is-incomplete";
        this.handleSpinnerLoadingOff();
    }
 
    selectAll() {
        this.isSpinnerLoading=true;
        this.selectedTab = 'All';
        this.AllSelected = true;
        this.AssignedToMeSelected = false;
        this.step3select = false;
        this.AssignedToMeClass="slds-path__item slds-is-incomplete";
        this.AllClass="slds-path__item slds-is-current slds-is-active";
        this.Step3Class="slds-path__item slds-is-incomplete";
        this.handleSpinnerLoadingOff();
    }
    handleSpinnerLoadingOff() {
        this.delayTimeout = setTimeout(() => {
            this.isSpinnerLoading = false;
        }, 1000);
    }
}
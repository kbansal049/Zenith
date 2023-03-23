import { LightningElement, wire, api, track } from 'lwc';
import retriveCustomOrder from '@salesforce/apex/CreateSalesOrderExtensionLWC.getCustomOrder';
import reCalculateACV from '@salesforce/apex/CreateSalesOrderExtensionLWC.reCalculateACV';
import submitFinalRequest from '@salesforce/apex/CreateSalesOrderExtensionLWC.doSubmit';
import { NavigationMixin } from "lightning/navigation";

export default class CreateSalesOrderLWC extends NavigationMixin(LightningElement) {

    @api recordId;
    @track customOrderWrapper;
    @track error;
    @track hasError = false;
    @track loading = true;

    @track activeSections = ["A", "B", "C", "D", "E", "F", "G", "H"];
    @track currentStep = "1";

    // initialize component
    connectedCallback() {
        console.log('---connectedCallback--called---');
        this.handleLoadCustomOrder();
    }

    handleLoadCustomOrder() {
        this.loading = true;
        console.log('---handleLoadCustomOrder--called---');
        console.log('---handleLoadCustomOrder--this.recordId---', this.recordId);
        retriveCustomOrder({ opportunityId: this.recordId })
            .then(result => {
                this.customOrderWrapper = Object.assign({}, result);
                this.hasError = false;
                this.loading = false;
                console.log('---handleLoadCustomOrder--this.customOrderWrapper---', this.customOrderWrapper);
            })
            .catch(error => {
                this.error = error;
                this.hasError = true;
                this.loading = false;
            });
    }

    handleOpportunityWrapperRefresh(event){
        console.log('---handleOpportunityWrapperRefresh--called---');
        let det = event.detail;
        console.log('---handleOpportunityWrapperRefresh--det---', det);
        if (det) {
             this.customOrderWrapper = det;
        }
    }

    handleOpportunityWrapperChange(event) {
        console.log('---handleOpportunityWrapperChange--called---');
        let det = event.detail;
        console.log('---handleOpportunityWrapperChange--det---', det);
        if (det) {
            if (det.field != undefined && det.value != undefined) {
                this.customOrderWrapper.opp[det.field] = det.value;
            }
        }
    }


    handleStageChange(event) {
        console.log('---handleStageChange--called---');
        let det = event.detail;
        console.log('---handleStageChange--det---', det);
        this.currentStep = det;
    }


    handleChangeValue(event) {
        console.log('---handleChangeValue--called---');
        let det = event.detail;
        if (det) {
            console.log('---handleChangeValue--det---', det);
            if (det.field != undefined && det.value != undefined) {
                if (det.field in this.customOrderWrapper) {
                    this.customOrderWrapper[det.field] = det.value;
                } else {
                    this.customOrderWrapper[det.field] = det.value;
                }
            }
        }
        let acvchange = event.acvchange;
        if (acvchange) {
            console.log('---handleChangeValue--acvchange---', acvchange);
        }
        console.log('---handleChangeValue--customOrderWrapper---', this.customOrderWrapper);
    }

    handleChangeACV(event) {
        console.log('---handleChangeACV--called---');
        let det = event.detail;
        if (det) {
            console.log('---handleChangeACV--det---', det);
            if (this.customOrderWrapper.lstfinallinestoNSwithInternalLines) {
                this.customOrderWrapper.lstfinallinestoNSwithInternalLines.forEach(function (element) {
                    det.forEach(function (line) {
                        if (line.recId === element.recId) {
                            console.log('--matched--');
                            if (line.newACV) {
                                element.newACV = line.newACV;
                            }
                            else if (line.newTCV) {
                                element.newTCV = line.newTCV;
                            }
                            else if (line.RenewalACV) {
                                element.RenewalACV = line.RenewalACV;
                                element.UpsellACV = line.RenewalACV - element.acv;
                            }
                            else if (line.RenewalTCV) {
                                element.RenewalTCV = line.RenewalTCV;
                                element.UpsellTCV = line.RenewalTCV - element.NetPrice;
                            }
                            else if (line.UpsellACV) {
                                element.UpsellACV = line.UpsellACV;
                                element.RenewalACV = line.UpsellACV - element.acv;
                            }
                            else if (line.UpsellTCV) {
                                element.UpsellTCV = line.UpsellTCV;
                                element.RenewalTCV = line.UpsellTCV - element.NetPrice;
                            }
                        }
                    })
                });
            }

            if (this.customOrderWrapper.lstfinallinestoNSwithoutinternallines) {
                this.customOrderWrapper.lstfinallinestoNSwithoutinternallines.forEach(function (element) {
                    det.forEach(function (line) {
                        if (line.recId === element.recId) {
                            console.log('--matched--');
                            if (line.newACV) {
                                element.newACV = line.newACV;
                            }
                            else if (line.newTCV) {
                                element.newTCV = line.newTCV;
                            }
                            else if (line.RenewalACV) {
                                element.RenewalACV = line.RenewalACV;
                                element.UpsellACV = line.RenewalACV - element.acv;
                            }
                            else if (line.RenewalTCV) {
                                element.RenewalTCV = line.RenewalTCV;
                                element.UpsellTCV = line.RenewalTCV - element.NetPrice;
                            }
                            else if (line.UpsellACV) {
                                element.UpsellACV = line.UpsellACV;
                                element.RenewalACV = line.UpsellACV - element.acv;
                            }
                            else if (line.UpsellTCV) {
                                element.UpsellTCV = line.UpsellTCV;
                                element.RenewalTCV = line.UpsellTCV - element.NetPrice;
                            }
                        }
                    })
                });
            }
        }
    }


    handleReCalculateACV(event) {
        console.log('---handleReCalculateACV--called---');

        this.loading = true;
        console.log('---handleReCalculateACV--called---');
        console.log('---handleReCalculateACV--this.customOrderWrapper---', this.customOrderWrapper);
        reCalculateACV({ cow: this.customOrderWrapper })
            .then(result => {
                this.customOrderWrapper = result;
                this.hasError = false;
                this.loading = false;
                console.log('---handleReCalculateACV--this.customOrderWrapper---after--', this.customOrderWrapper);
            })
            .catch(error => {
                this.error = error;
                this.hasError = true;
                this.loading = false;
            });
    }


    handleSubmitRequest() {

        this.loading = true;
        console.log('---handleSubmitRequest--called---');
        submitFinalRequest({ cow: this.customOrderWrapper })
            .then(result => {
                this.customOrderWrapper = result;
                this.hasError = false;
                this.loading = false;
                this.currentStep = "3";
                console.log('---handleReCalculateACV--this.customOrderWrapper---after--', this.customOrderWrapper);
            })
            .catch(error => {
                console.log('---handleReCalculateACV--this.customOrderWrapper---error--', error);
                this.error = error;
                this.hasError = true;
                this.loading = false;
            });
    }


    handleOpportunityRedirect() {
        console.log('---handleOpportunityRedirect--called--');
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Opportunity',
                actionName: 'view'
            }
        });
    }

    get showFirstStep() {
        return this.currentStep && this.currentStep === "1" ? true : false;
    }
    get showSecondStep() {
        return this.currentStep && this.currentStep === "2" ? true : false;
    }
    get showThirdStep() {
        return this.currentStep && this.currentStep === "3" ? true : false;
    }

}
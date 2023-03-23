import { LightningElement, wire, api, track } from 'lwc';
import retriveCustomOrder from '@salesforce/apex/CreateSalesOrderExtensionCPQLWC.getCustomOrder';
import reCalculateACV from '@salesforce/apex/CreateSalesOrderExtensionCPQLWC.reCalculateACV';
import submitFinalRequest from '@salesforce/apex/CreateSalesOrderExtensionCPQLWC.doSubmit';
import { NavigationMixin } from "lightning/navigation";

export default class createSalesOrderLWCCPQ extends NavigationMixin(LightningElement) {

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

    handleOpportunityWrapperChange(event) {
        console.log('---handleOpportunityWrapperChange--called---');
        let det = event.detail;
        console.log('---handleOpportunityWrapperChange--det---', det);
        if (det) {
            console.log('---handleOpportunityWrapperChange--det---', det);
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

            if (this.customOrderWrapper.lstfinallinestoNS) {
                this.customOrderWrapper.lstfinallinestoNS.forEach(function (element) {
                    det.forEach(function (line) {
                        if (line.recId === element.recId) {
                            console.log('--matched--',element);
                            if (line.newACV) {
                                element.newACV = line.newACV;
                            }
                            else if (line.newTCV) {
                                element.newTCV = line.newTCV;
                            }
                            else if (line.RenewalACV) {
                                element.RenewalACV = line.RenewalACV;
                                element.UpsellACV = Math.abs(line.RenewalACV - element.ACV);
                            }
                            else if (line.RenewalTCV) {
                                element.RenewalTCV = line.RenewalTCV;
                                element.UpsellTCV = Math.abs(line.RenewalTCV - element.NetPrice);
                                
                            }
                            else if (line.UpsellACV) {
                                element.UpsellACV = line.UpsellACV;
                                element.RenewalACV = Math.abs(line.UpsellACV - element.ACV);
                            }
                            else if (line.UpsellTCV) {
                                element.UpsellTCV = line.UpsellTCV;
                                element.RenewalTCV = Math.abs(line.UpsellTCV - element.NetPrice);
                            }

                            //Setting Contract && Additional Contract Details
                            if (line.contractDetailName) {
                                element.contractDetailName = line.contractDetailName;
                            }
                            if (line.addcontractDetailName) {
                                element.addcontractDetailName = line.addcontractDetailName;
                            }
                             //Setting ACV & TCV (after Adjustment)
                            if (line.NetPrice) {
                                element.NetPrice = line.NetPrice;
                            }
                            if (line.ACV) {
                                element.ACV = line.ACV;
                            }
                        }
                    })
                });
            }

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
                                element.UpsellACV = Math.abs(line.RenewalACV - element.ACV);
                            }
                            else if (line.RenewalTCV) {
                                element.RenewalTCV = line.RenewalTCV;
                                element.UpsellTCV = Math.abs(line.RenewalTCV - element.NetPrice);
                            }
                            else if (line.UpsellACV) {
                                element.UpsellACV = line.UpsellACV;
                                element.RenewalACV = Math.abs(line.UpsellACV - element.ACV);
                            }
                            else if (line.UpsellTCV) {
                                element.UpsellTCV = line.UpsellTCV;
                                element.RenewalTCV = Math.abs(line.UpsellTCV - element.NetPrice);
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
                                element.UpsellACV = Math.abs(line.RenewalACV - element.ACV);
                            }
                            else if (line.RenewalTCV) {
                                element.RenewalTCV = line.RenewalTCV;
                                element.UpsellTCV = Math.abs(line.RenewalTCV - element.NetPrice);
                            }
                            else if (line.UpsellACV) {
                                element.UpsellACV = line.UpsellACV;
                                element.RenewalACV = Math.abs(line.UpsellACV - element.ACV);
                            }
                            else if (line.UpsellTCV) {
                                element.UpsellTCV = line.UpsellTCV;
                                element.RenewalTCV = Math.abs(line.UpsellTCV - element.NetPrice);
                            }
                            
                            //Setting Contract && Additional Contract Details
                            if (line.contractDetailName) {
                                element.contractDetailName = line.contractDetailName;
                            }
                            if (line.addcontractDetailName) {
                                element.addcontractDetailName = line.addcontractDetailName;
                            }
                            //Setting ACV & TCV (after Adjustment)
                            if (line.NetPrice) {
                                element.NetPrice = line.NetPrice;
                            }
                            if (line.ACV) {
                                element.ACV = line.ACV;
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
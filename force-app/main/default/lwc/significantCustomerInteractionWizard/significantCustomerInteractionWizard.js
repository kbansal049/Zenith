import { LightningElement, track, wire, api } from 'lwc';

export default class SignificantCustomerInteractionWizard extends LightningElement {

    showSpinner = true;

    @track currentStep = "1";
    @track step1 = true;
    @track step2 = false;
    @track step3 = false;
    @track step4 = false;
    @track step5 = false;

    @track nextStep = false;
    @track previousStep = false;


    //Step 1 variables
    @track selectedRecordTypeId;
    @track selectedMeetingLocation;
    @track selectedMeetingNotes;
    @track internalAttendee;
    @track generatedRecordId;
    @track participation;
    @api selectedSciId;
    @track selectedDate;
    @track attendeeExist;
    @track sciRecordId;
    @track recordExist;
    @track saveData;
    @api recordId;

    connectedCallback() {
        console.log('Inside SignificantCustomerInteractionWizard connectedCallback');
        var preUrl = document.referrer;
        console.log('this is previous page url'+preUrl);
        console.log('this is previous page url'+this.recordId);
        //return preUrl;
        

    }

    renderedCallback() {
        console.log('Inside SignificantCustomerInteractionWizard renderedCallback');
        this.showSpinner = false;
        if (this.nextStep && (this.currentStep !== this.nextStep)) {
            if (this.template.querySelector(`[data-key="${this.currentStep}"]`)) {
                let currentStepPathClass = this.template.querySelector(`[data-key="${this.currentStep}"]`).classList;
                console.log('currentStepPathClass : - ' + JSON.stringify(currentStepPathClass));
                if (!currentStepPathClass.contains("slds-is-complete")) {// .classList.remove("mystyle");
                    this.template.querySelector(`[data-key="${this.currentStep}"]`).classList.remove("slds-is-current");
                    this.template.querySelector(`[data-key="${this.currentStep}"]`).classList.remove("slds-is-active");
                    this.template.querySelector(`[data-key="${this.currentStep}"]`).classList.add("slds-is-complete");
                }
                let currentStepPathClassAfter = this.template.querySelector(`[data-key="${this.currentStep}"]`).classList;
                console.log('currentStepPathClassAfter : - ' + JSON.stringify(currentStepPathClassAfter));
            }
        }
        if (this.nextStep) {
            if (this.template.querySelector(`[data-key="${this.nextStep}"]`)) {
                let nextStepPathClass = this.template.querySelector(`[data-key="${this.nextStep}"]`).classList;
                console.log('nextStepPathClass : - ' + JSON.stringify(nextStepPathClass));
                if (!nextStepPathClass.contains("slds-is-current") || !nextStepPathClass.contains("slds-is-active")) {
                    this.template.querySelector(`[data-key="${this.nextStep}"]`).classList.remove("slds-is-incomplete");
                    this.template.querySelector(`[data-key="${this.nextStep}"]`).classList.add("slds-is-current");
                    this.template.querySelector(`[data-key="${this.nextStep}"]`).classList.add("slds-is-active");
                }
                let nextStepPathClassAfter = this.template.querySelector(`[data-key="${this.nextStep}"]`).classList;
                console.log('nextStepPathClassAfter : - ' + JSON.stringify(nextStepPathClassAfter));


                this.currentStep = this.nextStep;
            }
        }
    }

    handlePathClick(event) {
        try {
            if (event.currentTarget) {
                console.log(
                    "event dataset :- " + JSON.stringify(event.currentTarget.dataset)
                );
                console.log(
                    "event data-key defined at element level :- " +
                    JSON.stringify(event.currentTarget.dataset.key)
                );
                let pathNumStr = event.currentTarget.dataset.key;
                let pathNum = parseInt(pathNumStr, 10);
                this.currentStep = pathNumStr;
                this.changeStepName(pathNum);
            } else {
                console.log("event from handlePathClick : " + event);
                let pathNumStr = event;
                let pathNum = parseInt(pathNumStr, 10);
                this.currentStep = pathNumStr;
                this.changeStepName(pathNum);
                let currentStepPathClass = this.template.querySelector('[data-id=' + pathNumStr + ']').className;
                if (currentStepPathClass.includes('slds-is-complete')) {
                    this.template.querySelector('[data-id=' + pathNumStr + ']').className = 'slds-path__item slds-is-complete';
                } else {
                    this.template.querySelector('[data-id=' + pathNumStr + ']').className = 'slds-path__item slds-is-incomplete';
                }
            }

        } catch (error) {
            console.log("Error from handlePathClick : " + error);
        }
    }

    changeStepName(stepNum) {
        switch (stepNum) {
            case 1:
                this.step1 = true;
                this.step2 = false;
                this.step3 = false;
                this.step4 = false;
                break;
            case 2:
                this.step1 = false;
                this.step2 = true;
                this.step3 = false;
                this.step4 = false;
                break;
            case 3:
                this.step1 = false;
                this.step2 = false;
                this.step3 = true;
                this.step4 = false;
                break;
            case 4:
                this.step1 = false;
                this.step2 = false;
                this.step3 = false;
                this.step4 = true;
                break;
            default:
                this.step1 = true;
                this.step2 = false;
                this.step3 = false;
                this.step4 = false;
                break;
        }
    }

    handleGoToNextStep(event) {
        try {
            console.log('handleGoToNextStep event : ' + event.detail.nextStep);
            console.log('handleGoToNextStep selectedRecordTypeId : ' + event.detail.selectedRecordTypeId);
            console.log('handleGoToNextStep selectedDate : ' + event.detail.selectedDate);
            console.log('handleGoToNextStep sciRecordId : ' + event.detail.sciRecordId);
            //this.handlePathClick(event.detail.nextStep);
            this.nextStep = event.detail.nextStep;
            this.selectedRecordTypeId = event.detail.selectedRecordTypeId;
            this.selectedMeetingLocation = event.detail.selectedMeetingLocation;
            this.internalAttendee = event.detail.internalAttendee;
            this.selectedMeetingNotes = event.detail.selectedMeetingNotes;
            this.participation = event.detail.participation;
            this.generatedRecordId = event.detail.generatedRecordId;
            this.selectedDate = event.detail.selectedDate;
            this.selectedSciId = event.detail.selectedSciId;
            this.recordExist = event.detail.recordExist;
            this.attendeeExist = event.detail.attendeeExist;
            this.saveData = event.detail.saveData;
            this.sciRecordId = event.detail.sciRecordId;
            this.changeStepName(parseInt(this.nextStep, 10));
        } catch (error) {
            console.log("Error from handleGoToNextStep : " + error);
            console.log("Error from handleGoToNextStep : " + JSON.stringify(error));
        }

    }



}
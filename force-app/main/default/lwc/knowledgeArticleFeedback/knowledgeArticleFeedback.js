import { LightningElement, track, api } from 'lwc';
import sendKAFeedback from '@salesforce/apex/KnowledgeArticleFeedbackController.sendKAFeedback';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class KnowledgeArticleFeedback extends LightningElement {
    @api recordId;

    @track showFeedcmp = false;
    connectedCallback() {
        this.delayTimeout = setTimeout(() => {
            this.showFeedcmp = true;
        }, 5000);
    }

    @track displayFeedDetailsSection = false;
    @track feedbackCategory = '';
    @track isRequired = false;
    handleEmojiClick(event) {
        if(!this.displayFeedDetailsSection){
            this.displayFeedDetailsSection = true;
            this.feedbackCategory = event.currentTarget.name;
            if(this.feedbackCategory === 'Dislike'){
                this.isRequired = true;
            }
        }else{
            this.isRequired = false;
            this.displayFeedDetailsSection = false;
            this.feedbackCategory = '';
        }
    }

    get options() {
        return [
            { label: 'Change/Enhancement', value: 'Change/Enhancement' },
            { label: 'General Comments', value: 'General Comments' }
        ];
    }

    @track feedbackType = '';
    handleFeedbackTypeChange(event) {
        this.feedbackType = event.detail.value;
    }

    @track feedbackComments = '';
    handleFeedbackCommentsChange(event) {
        this.feedbackComments = event.detail.value;
    }

    submitFeedback() {
        if(this.validateInputs()){
            let urlName = '';
            if(this.recordId === '' || this.recordId === null || this.recordId === undefined){
                let communityUrl = window.location.href;
                urlName = communityUrl.substring(communityUrl.lastIndexOf("/") + 1, communityUrl.length);
            }

            sendKAFeedback({
                kaId : this.recordId,
                kaUrlName: urlName,
                feedbackCategory: this.feedbackCategory,
                feedbackType : this.feedbackType,
                feedbackComments : this.feedbackComments
            }).then(response => {
                if(response === 'Success') {
                    this.showToastMsg(true, 'Thank you for feedback.');
                }
                else {
                    this.showToastMsg(false, 'Oops... something went wrong, please try again later.');
                }
            }).catch(error => {
                this.showToastMsg(false, 'Oops... error occurred while sending your feedback, please try again later. Error is: \n'+JSON.stringify(error));
            });
            this.feedbackType = null;
            this.feedbackComments = null;
            this.isRequired = false;
            this.displayFeedDetailsSection = false;
        }
    }

    cancelFeedback() {
        this.isRequired = false;
        this.displayFeedDetailsSection = false;
        this.feedbackCategory = '';
    }

    validateInputs(){
        let isValid = true;
        if(this.feedbackCategory === 'Dislike'){
            if(this.feedbackType === '' || this.feedbackType === null || this.feedbackType === undefined){
                this.showToastMsg(false, 'Please select feedback type.');
                isValid = false;
            }else if(this.feedbackComments === '' || this.feedbackComments === null || this.feedbackType === undefined){
                this.showToastMsg(false, 'Please provide comments.');
                isValid = false;
            }
        }
        return isValid;
    }

    showToastMsg(isSuccess, toastMsg){
        if(isSuccess){
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: toastMsg,
                variant: 'Success'
            }));
        }else{
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: toastMsg,
                variant: 'Error'
            }));
        }
    }
}
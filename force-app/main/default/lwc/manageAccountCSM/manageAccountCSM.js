import { LightningElement, api, track, wire } from 'lwc';
import manageAccountTeamMembers from '@salesforce/apex/ManageAccountCSMController.manageAccountTeamMembers';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class ManageAccountCSM extends LightningElement {

    @api recordId;
    @api objectApiName;
    showSpinner = false;

    handleSubmit(event) {

        event.preventDefault();
        this.showSpinner = true;
        let accountIdsList = [];
        let accObj = { 'sobjectType': 'Account' };
        accObj.Id = this.recordId;
        accObj.CSM_Name_New__c = event.detail.fields.CSM_Name_New__c;
        accObj.CSM_Name_2__c = event.detail.fields.CSM_Name_2__c;
        accObj.CS_Business_Alignment__c = event.detail.fields.CS_Business_Alignment__c;
        accountIdsList.push(accObj);
        manageAccountTeamMembers({
            accList: accountIdsList
        }).then(result => {
            if (result == 'Success') {
                this.showSpinner = false;
                this.dispatchEvent(new CloseActionScreenEvent());
                this.showToast('Success!!', 'success', 'Account Team Members are updated successfully!');

            }
        })
            .catch(error => {
                this.showSpinner = false;
                console.log('Loading error - error while Updating Account Team Members: ', JSON.stringify(error));
                this.showToast('Error', 'error', 'Error While Updating Account Team Members:'+JSON.stringify(error.body.message));
                console.log('Error', JSON.stringify(error));
            });
    }

    handleCancel(event) {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    showToast(title, variant, msg) {
        const event = new ShowToastEvent({
            title: title,
            variant: variant,
            message: msg
        });
        this.dispatchEvent(event);
    }
}
import { LightningElement, api, wire } from 'lwc';	
import { CloseActionScreenEvent } from 'lightning/actions';
import getDetails from "@salesforce/apex/BookMeetingSchedulerController.getDetails";

export default class BookMeetingScheduler_LWC extends LightningElement {
    @api recordId;
    @api fetchedDetails;
    error;
    displayModal = true;
    flowApiName = 'Book_Support_Meeting';

    handleFlowStatusChange(event){
        console.log('handleStatusChange', event.detail);
        if (event.detail.status === "FINISHED") {
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }

    @wire(getDetails,{ caseRecordId: '$recordId' })
    wiredDetails({ error, data }) {
        if (data) {
            this.fetchedDetails = data;
            console.log('case product**: '+JSON.stringify(data));
            console.log('case displayTACMessage**: '+this.fetchedDetails.displayTACMessage);
            this.error = null;
        } else if (error) {
            this.error = error;
            console.log('Error**: '+JSON.stringify(error));
            this.fetchedDetails = null;
        }
    }

    // Setting flow input variables
    get flowInputVariables() {
        return [
        {
            name: "CaseId",
            type: "String",
            value: this.recordId,
        },
        {
            name: "Case_Product",
            type: "String",
            value: this.fetchedDetails.caseProduct,
        },
        {
            name: "Case_Support_Type",
            type: "String",
            value: this.fetchedDetails.caseSupportType,
        },
        {
            name: "Current_User_Type",
            type: "String",
            value: this.fetchedDetails.currentUserType,
        }];
    }
}
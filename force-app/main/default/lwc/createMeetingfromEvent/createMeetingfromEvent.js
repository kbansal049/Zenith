import { LightningElement, wire, track, api } from 'lwc';
import getrelatedRecords from '@salesforce/apex/MeetingCreationController.getInfo';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

export default class CreateMeetingfromEvent extends NavigationMixin(LightningElement) {
    @track loading = true;
    @track errmsg = '';
    @api recordId;
    @wire(getrelatedRecords, { recId: '$recordId' })
    processres(results) {
        this.wiredResults = results;
        if (results.data) {
            console.log(results.data);
            if (results.data.countofMeeting > 0) {
                this.errmsg = 'This event already has a Meeting. Please <a target="_self" href="/' + results.data.meetingId + '"> click here</a> to view.'
            } else {
                let pageRef = {
                    type: "standard__objectPage",
                    attributes: {
                        objectApiName: "Meeting__c",
                        actionName: "new"
                    },
                    state: {
                    }
                };
                const defaultFieldValues = {
                    Type__c: "TAM Meeting",
                    Participants__c: results.data.evt.peopleai__Participants__c,
                    Duration__c: results.data.evt.DurationInMinutes,
                    Date_of_meeting__c: results.data.evt.StartDateTime,
                    Calendar_ID__c: results.data.evt.Id,
                    Status__c: 'Scheduled',
                    Customer_Name__c: results.data.accId,
                };
                pageRef.state.defaultFieldValues = encodeDefaultFieldValues(defaultFieldValues);
                this[NavigationMixin.Navigate](pageRef);
            }
            
            this.loading = false;
        } else if (results.error) {
            let error = results.error;
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (error.body && error.body.message && typeof error.body.message === 'string') {
                message = error.body.message;
            } else if (error.body.pageErrors && error.body.pageErrors[0] && error.body.pageErrors[0].message) {
                message += error.body.pageErrors[0].message;
            } else if (error.body && error.body.fieldErrors && error.body.fieldErrors[0] && error.body.fieldErrors[0].message) {
                message += error.body.fieldErrors[0].message;
            }
            this.errmsg = message;
            this.loading = false;
        }
    }
}
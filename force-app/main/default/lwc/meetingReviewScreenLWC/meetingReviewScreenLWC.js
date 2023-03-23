import { api, LightningElement, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import USER_TIMEZONE_FIELD from '@salesforce/schema/User.TimeZoneSidKey';
import Id from '@salesforce/user/Id';
import {FlowNavigationBackEvent, FlowNavigationNextEvent} from 'lightning/flowSupport';
import meetingDescriptionValidationMessage from '@salesforce/label/c.Meeing_Description_Required_Validation_Message';

export default class MeetingReviewScreenLWC extends LightningElement {
    loading = true;
    showMeetingDescValidationMsg = false;
    showTimeDiffValidationMsgForTAM = false;
    twoHourBeforeTAMtoTACMeetingBookingErrorMsg;

    @api resourceId;
    @api caseId;
    @api contactId;
    @api startTime;
    @api endTime;
    @api listOfAttendeesEmails;
    @api workTypeGroupId;
    @api serviceTerritoryId;
    @api meetingDescription = '';
    @api agendaForMeeting='';
    @api backClicked = false;
    @api showButtons = false;
    @api currentUserType;
    @api customerMeetingURL = '';

    label = {
        meetingDescriptionValidationMessage
    };

    @wire(getRecord, { recordId: Id, fields: USER_TIMEZONE_FIELD})
    userRecord

    get usrTimezone(){
        return getFieldValue(this.userRecord.data, USER_TIMEZONE_FIELD);
    }

    handleOnLoad(){
        this.loading = false;
    }

    handleChange(event){
        if(event.currentTarget.fieldName == 'Comments'){
            this.meetingDescription = event.currentTarget.value;
        }else if(event.currentTarget.fieldName == 'Street'){
            this.customerMeetingURL = event.currentTarget.value;
        }
    }

    handleBack(){
        this.navigateBack();
    }

    navigateBack(){
        const navigateBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateBackEvent);
    }

    handleNext(){
        this.twoHourBeforeTAMtoTACMeetingBookingErrorMsg = null;
        this.validateMeetingDescription();
        this.backClicked = false;

        if(!this.showMeetingDescValidationMsg && !this.showTimeDiffValidationMsgForTAM){
            this.navigateNext();
        }
    }

    navigateNext(){
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }

    validateMeetingDescription(){
        this.template.querySelectorAll('.meetingDescCls').forEach(element => {
            if(element.fieldName == 'Comments' 
                && (element.value == undefined || element.value == null || element.value == '')){
                this.showMeetingDescValidationMsg = true;
            }else{
                this.showMeetingDescValidationMsg = false;
            }
        });

        console.log('111(A) ==>> this.currentUserType val is: ' + this.currentUserType);
        if(this.currentUserType == 'TAM' || this.currentUserType == 'CS'){
            let currentDate = new Date();
            console.log('111(B) ==>> this.startTime val is: ' + this.startTime);
            console.log('111(C) ==>> currentDate val is: ' + currentDate);
            let timeDiff = this.getTimeDiffInMinutes(new Date(this.startTime), currentDate);
            console.log('222(A) ==>> Time Diff b/w startTime and currentDate in Minutes val is: ' + timeDiff);
            if(timeDiff <= 119){
                this.showTimeDiffValidationMsgForTAM = true;
                this.twoHourBeforeTAMtoTACMeetingBookingErrorMsg = 'Please select a meeting slot whose start time is atleast 2 hours from now.';
            }
        }
    }

    getTimeDiffInMinutes(meetingStartDateTime, currrentTime) {
        let diff = (meetingStartDateTime.getTime() - currrentTime.getTime()) / 1000;
        diff /= (60 * 60);
        return Math.abs(Math.round(diff * 60));
    }
}
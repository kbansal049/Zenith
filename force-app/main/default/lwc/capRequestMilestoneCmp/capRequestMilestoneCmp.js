import { LightningElement, wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getMilestoneRecords from '@salesforce/apex/CAPRequestMilestoneCmpCtrl.getMilestoneRecords';
//import TIME_ZONE from '@salesforce/i18n/timeZone';
import USER_ID from '@salesforce/user/Id';
import TIME_ZONE from '@salesforce/schema/User.TimeZoneSidKey';

const FIELDS = ['CAP_Request__c.Name'];


export default class CapRequestMilestoneCmp extends LightningElement {
    @api recordId;
    completedMilestones = [];
    violatedMilestones = [];
    ongoingMilestones = [];
    timeLeft = '';
    timeZone = ''; 
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [TIME_ZONE]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
           this.error = error ; 
        } else if (data) {
            console.log(JSON.stringify(data));
            this.timeZone = data.fields.TimeZoneSidKey.value;
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS}) capRequest;

    get capName() {
        return getFieldValue(this.capRequest.data, 'CAP_Request__c.Name');
    }

    get isTimezoneBlank() {
        if(this.timeZone) {
            return true;
        }
        else {
            return false;
        }
    }

    get completedMilestonesExist() {
        if(this.completedMilestones) {
            return this.completedMilestones.length>0?true:false;
        }
    }

    get violatedMilestonesExist() {
        if(this.violatedMilestones) {
            return this.violatedMilestones.length>0?true:false;
        }
    }

    get ongoingMilestonesExist() {
        if(this.ongoingMilestones) {
            return this.ongoingMilestones.length>0?true:false;
        }
    }

    connectedCallback() {
        this.getMilestoneRecordsHandler();
    }

    refreshView() {
        this.getMilestoneRecordsHandler();
    }

    getMilestoneRecordsHandler(){
        //clearInterval(this.timeIntervalInstance);
        getMilestoneRecords({recordId : this.recordId})
        .then(result => {
            if(result) {
              console.log("##", result);
              this.completedMilestones = result.completedMilestones;
              this.violatedMilestones = result.violatedMilestones;
              this.ongoingMilestones = result.ongoingMilestones;
              if(this.ongoingMilestones && this.ongoingMilestones.length>0) {
                for(let index in this.ongoingMilestones) {
                    this.ongoingMilestones[index].timeVal = this.calulateTimer(this.ongoingMilestones[index].targetTime);
                }
              }
            }
        })
        .catch(error => {});
    }

    calulateTimer(endDateTime) {
        var dateEnd = new Date(endDateTime);
        // Get todays date and time
        let now = new Date().getTime();
        // Find the distance between now and the count down date
        
        var parentThis = this;
        parentThis.totalMilliseconds = dateEnd.getTime()-now;
        var days = Math.round((parentThis.totalMilliseconds / (1000 * 60 * 60 * 24)));
        var hours = Math.round((parentThis.totalMilliseconds % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
        var minutes = Math.round((parentThis.totalMilliseconds % (1000 * 60 * 60)) / (1000 * 60));
        var seconds = Math.round((parentThis.totalMilliseconds % (1000 * 60)) / 1000);
        console.log('## days :', days);
        console.log('## hours :', hours);
        console.log('## minutes :', minutes);
        console.log('## seconds :', seconds);
        let timeVal = '';

        if(days>0) {
            if(days == 1) {
                timeVal = '~'+days+' day left.';
            }
            else {
                timeVal = '~'+days+' days left.';
            }
        }
        else if(hours > 0) {
            if(hours == 1) {
                timeVal = '~'+hours+' hour left.';
            }
            else if(hours > 1){
                /*if(minutes > 30) {
                    hours++;
                }*/
                timeVal = '~'+hours+' hours left.';
            }
        }
        else if(minutes > 30) {
            timeVal = 'More than 30 minutes left.';
        }
        else if(minutes < 30 && minutes > 0) {
            if(minutes<10) {
                timeVal = 'Less than 10 minutes left.';
            }
            else if(minutes < 15) {
                timeVal = 'Less than 15 minutes left.';
            }
            else {
                timeVal = 'Less than 30 minutes left.';
            }
        }
        else {
            timeVal = 'Less than a minute left';
        }
        return timeVal;
    }

    
}
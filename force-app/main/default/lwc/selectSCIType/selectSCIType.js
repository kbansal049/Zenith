import { LightningElement, api, track } from 'lwc';
import fetchRecordTypeNameDescription from '@salesforce/apex/SelectSCITypeCtrl.fetchRecordTypeNameDescription';
import fetchSignificantCustomerInteraction from '@salesforce/apex/SelectSCITypeCtrl.fetchSignificantCustomer';
import addLoginUser from '@salesforce/apex/SelectSCITypeCtrl.addLoginUser';
import submitSCI from '@salesforce/apex/SelectSCITypeCtrl.submitSCIAction';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';


const columns = [
    { label: 'SCI Type', fieldName: 'Name' },
    { label: 'Description', fieldName: 'Description' },
];

export default class SelectSCIType extends NavigationMixin(LightningElement) {

    @track data = [];
    @track columns = columns;
    @track significantCustomerList = [];
    @track finalDateSci;
    @track isLoading = false;
    @track dataEntered = false;
    organizerAttendee = true;
    @track meetingLoc;
    accountRecId;
    recordExist;
    
    @track sciCurrentDate;
    @track typeOfInteraction;
    @track MethodOfInteraction;
    @track selectedMeetingLocation;
    @track internalAttendee;
    @track selectedMeetingNotes;
    @track selectedSciId;
   
    //@track organizer = {};
    @track options = [];
    sciRecId;

    privateselectedRecordTypeId;
    @api
    get selectedRecordTypeId() {
        return this.privateselectedRecordTypeId;
    }
    set selectedRecordTypeId(value) {
        try {
            if (value) {
                this.privateselectedRecordTypeId = value;
                console.log('Set this.privateselectedRecordTypeId ' + JSON.stringify(this.privateselectedRecordTypeId));
                
            }
        } catch (error) {
            console.log('Error : ' + error);
            console.log('Error : ' + JSON.stringify(error));
        }

    }

    @api
    get accountRecordId() {
        return this.accountRecId;
    }
    set accountRecordId(value) {
        try {
            if (value) {
                this.accountRecId = value;
                console.log('Set this.accountRecordId ' + JSON.stringify(this.accountRecordId));
            }
        } catch (error) {
            console.log('Error : ' + error);
            console.log('Error : ' + JSON.stringify(error));
        }

    }

    

    privateselectedDate;
    @api
    get selectedDate() {
        return this.privateselectedDate;
    }
    set selectedDate(value) {
        try {
            if (value) {
                this.privateselectedDate = value;
                console.log('Set this.privateselectedDate ' + JSON.stringify(this.privateselectedDate));
                
            }
        } catch (error) {
            console.log('Error : ' + error);
            console.log('Error : ' + JSON.stringify(error));
        }

    }

    

    handleSignificantCustomer() {
        fetchSignificantCustomerInteraction({ currentDate: this.privateselectedDate , accId: this.accountRecId})
            .then((result) => {
                console.log('Existing SCIs-->'+JSON.stringify(result));
                this.significantCustomerList = result;
                if(this.significantCustomerList.length == 0){
                    this.handleNext()
                }
                
                //this.privateselectedDate = undefined;
                this.dataEntered = true;
                
            })
            .catch((error) => {
                console.log(error);
            });
    }

    @track options = [];

    connectedCallback() {
        console.log('Inside SelectSCIType connectedCallback');
        this.fetchRecordTypeInfos();
    }

    async fetchRecordTypeInfos() {
        try {
            const recordTypeInfo = await fetchRecordTypeNameDescription();
            console.log('recordTypeInfo : ' + JSON.stringify(recordTypeInfo));
            //this is to match structure of lightning combo box
            let optionsValues = [];
            recordTypeInfo.forEach(arrayItem => {
                if (arrayItem.Name !== 'Master') {
                    optionsValues.push({
                        label: arrayItem.Name,
                        value: arrayItem.Id
                    });
                }
                console.log('arrayItem : ' + arrayItem);
            });

            this.options = optionsValues;
            this.data = recordTypeInfo;
        } catch (error) {
            console.log('Error : ' + error);
            console.log('Error : ' + JSON.stringify(error));
        }
    }

    // Handling RecordType change value
    handleRecordTypeChange(event) {
       
        this.privateselectedRecordTypeId = event.detail.value;
        console.log('Selected RecordType Id : ' + this.privateselectedRecordTypeId);
        if (this.privateselectedRecordTypeId && this.privateselectedDate) {
            // Creates the event.
                this.handleSignificantCustomer();
                console.log('Working')
            // const gotoNextStepEvent = new CustomEvent('gotonextstep', {
            //     detail:
            //     {
            //         nextStep: "2",
            //         selectedRecordTypeId: this.privateselectedRecordTypeId,
            //         selectedDate: this.privateselectedDate
            //     }
            // });
            // // Dispatches the event.
            // this.dispatchEvent(gotoNextStepEvent);
        }
    }

    

    // Handling Date change value
    handleDateChange(event) {
        
        this.privateselectedDate = event.detail.value;
        console.log('Selected Date : ' + this.privateselectedDate);
        if (this.selectedRecordTypeId && this.privateselectedDate) {
            // Creates the event.
                this.handleSignificantCustomer();
                console.log('Working')
            // const gotoNextStepEvent = new CustomEvent('gotonextstep', {
            //     detail:
            //     {
            //         nextStep: "2",
            //         selectedRecordTypeId: this.selectedRecordTypeId,
            //         selectedDate: this.privateselectedDate
            //     }
            // });
            // // Dispatches the event.
            // this.dispatchEvent(gotoNextStepEvent);
        }
    }

    handleInsertSci(event){
        
        console.log('>>>>>>',event.currentTarget.dataset.id);
        this.sciRecId = event.currentTarget.dataset.id;
        let sciIdVal = event.currentTarget.dataset.id.toString();
        console.log('sciIdVal>'+sciIdVal);
        console.log('sciIdVal>'+typeof(sciIdVal));
        this.handleNextAfterSciSave();
        /*addLoginUser({sciId:sciIdVal})
        .then(result=>{
            this.handleNextAfterSciSave(event);
        })
        .catch(error =>{
           this.errorMsg=error.message;
           window.console.log('>>>-->>'+this.error);
           this.handleNextAfterSciSave();
        });*/
    }

    handleNextAfterSciSave(event){
        const gotoNextStepEvent = new CustomEvent('gotonextstep', {
            detail:
            {
                nextStep: "3",
                selectedRecordTypeId: this.selectedRecordTypeId,
                selectedDate: this.privateselectedDate,
                sciRecordId: this.sciRecId
            }
        });
        // Dispatches the event.
        this.dispatchEvent(gotoNextStepEvent);
    }

    handleNext(){
        const gotoNextStepEvent = new CustomEvent('gotonextstep', {
            detail:
            {
                nextStep: "2",
                selectedRecordTypeId: this.selectedRecordTypeId,
                selectedDate: this.privateselectedDate
            }
        });
        // Dispatches the event.
        this.dispatchEvent(gotoNextStepEvent);
    }

    handleEdit(event){

        // this[NavigationMixin.Navigate]({
        //     type: 'standard__component',
        //     attributes: {
        //         componentName: 'c__enterSCIDetails'
        //     },
        //     state: {
        //         selectedRecordTypeId: event.currentTarget.dataset.record,
        //         selectedDate: event.currentTarget.dataset.date,
        //         selectedMeetingLocation: event.currentTarget.dataset.location,
        //         selectedMeetingNotes: event.currentTarget.dataset.notes
        //     }
        // });
       
        this.recordExist = true;

        this.privateselectedRecordTypeId = event.currentTarget.dataset.record;
        const gotoNextStepEvent = new CustomEvent('gotonextstep', {
            detail:
            {
                nextStep: "2",
                selectedRecordTypeId: event.currentTarget.dataset.record,
                sciRecordId: event.currentTarget.dataset.id,
                selectedDate: event.currentTarget.dataset.date,
                selectedMeetingLocation: event.currentTarget.dataset.location,
                internalAttendee: event.currentTarget.dataset.internalattendee,
                selectedMeetingNotes: event.currentTarget.dataset.notes,
                selectedSciId: event.currentTarget.dataset.selectedid
            }
        });
        // Dispatches the event.
        console.log('>>>>>---INTERNAL ATTENDEE>>>>>'+event.currentTarget.dataset.internalattendee)
        this.dispatchEvent(gotoNextStepEvent);
    }

}
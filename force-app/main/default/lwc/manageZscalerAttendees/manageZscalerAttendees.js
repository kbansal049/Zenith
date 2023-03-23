import {
    LightningElement,
    api,
    track,
    wire
} from 'lwc';
import ATTENDEE_NAME from '@salesforce/schema/SCI_Zscaler_Attendee__c.Attendee_Name__c';
import fetchUserDetails from '@salesforce/apex/EnterSCIDetailsCtrl.fetchPushData';
import fetchInternalAttendee from '@salesforce/apex/SelectSCITypeCtrl.fetchInternalAttendee';
import deleteSciOnCancel from '@salesforce/apex/SelectSCITypeCtrl.deleteSciOnCancel';
import addLoginUser from '@salesforce/apex/SelectSCITypeCtrl.addLoginUser';

import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import saveAttendees from '@salesforce/apex/EnterSCIDetailsCtrl.insertZscalarAttendees';
import suggestedAttendees from '@salesforce/apex/SelectSCITypeCtrl.suggestedAttendees';

import id from '@salesforce/user/Id';

// import {getRecord} from 'lightning/uiRecordApi';
// import NAME_FIELD from '@salesforce/schema/User.Name';
// // import EMAIL_FIELD from '@salesforce/schema/User.Email';
// // import PHONE_FIELD from '@salesforce/schema/User.Phone';
// import DEPARTMENT_FIELD from '@salesforce/schema/User.Department';
import {
    NavigationMixin
} from 'lightning/navigation';
//import getContactListController from '../contactPageCommunity/contactPageCommunity';

export default class ManageZscalerAttendees extends NavigationMixin(LightningElement) {
    @track data = [];
    //@track usrData = [];
    dataDetails = [];
    @track usrData = [];
    @track attendeeExist;
    // @track userName;
    // @track userDepartment;
    usId = id;
    sciRecId;
    @track attData = [];

    @api selectedRecordTypeId;
    @api selectedDate;
    @api selectedMeetingLocation;
    @api saveData;
    @api recordExist;
    @api internalAttendee;
    @api generatedRecordId;
    @api attendeeExist;
    accountRecId;

    //@api selectedMeetingNotes;



    @track isLoading = false;
    @track dataDeleteLoading = false;
    @track dataSearchLoading = false;
    @track dataAddLoading = false;
    @track previousLoading = false;
    @api objectApiName = 'SCI_Zscaler_Attendee__c';
    fields = [ATTENDEE_NAME];
    valueAttendee = false;
    valueParticipation = 'In Person';


    /*@api
    get participation() {
        return this.data
    }
    set participation(value) {
        try {
            if (value) {
                const dataSet = JSON.parse(JSON.stringify(value));
                this.data = [...dataSet];
                console.log('Set this.data ' + JSON.stringify(this.data));
            }
        } catch (error) {
            console.log('Error : ' + error);
            console.log('Error : ' + JSON.stringify(error));
        }

    }*/

    meetingNotes;
    @api
    get selectedMeetingNotes() {
        return this.meetingNotes
    }
    set selectedMeetingNotes(value) {
        try {
            if (value) {
                this.meetingNotes = value;
                console.log('Set this.meetingNotes ' + JSON.stringify(this.meetingNotes));
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
            console.log('value-- ' + JSON.stringify(value));

            if (value) {
                this.accountRecId = value;
                console.log('Set this.accountRecordId ' + JSON.stringify(this.accountRecordId));
            }
        } catch (error) {
            console.log('Error : ' + error);
            console.log('Error : ' + JSON.stringify(error));
        }

    }

    // @wire(getRecord, {
    //     recordId: id,
    //     fields: [NAME_FIELD, DEPARTMENT_FIELD]
    // }) wireuser({error,data}) {
    //     if (error) {
    //        console.log(error); 
    //     } else if (data) {
    //         this.userDepartment = data.fields.Department.value;
    //         this.userName = data.fields.Name.value;
    //     }
    // }

    // @track privateselectedRecordTypeId;

    // get selectedRecordTypeId() {
    //     return this.privateselectedRecordTypeId;

    // }
    // set selectedRecordTypeId(value) {
    //     try {
    //         if (value) {
    //             this.privateselectedRecordTypeId = value;
    //             console.log('Set this.privateselectedRecordTypeId ' + JSON.stringify(this.privateselectedRecordTypeId));

    //         }
    //     } catch (error) {
    //         console.log('Error : ' + error);
    //         console.log('Error : ' + JSON.stringify(error));
    //     }

    // }

    @api
    get sciRecordId() {
        return this.sciRecId;
    }
    set sciRecordId(value) {
        try {
            console.log('--->' + value);
            if (value) {
                this.sciRecId = value;
                console.log('Set this.sciRecId ' + JSON.stringify(this.sciRecId));
            }
        } catch (error) {
            console.log('Error : ' + error);
            console.log('Error : ' + JSON.stringify(error));
        }

    }

    connectedCallback() {
        this.fetchInternalAttendeeMethod();
            
        this.addLoginUserDetails();
        
        
        
    }

    async fetchInternalAttendeeMethod(){
        await fetchInternalAttendee({
            sciId: this.sciRecId
        })
        .then(result => {
            console.log('result--->'+result);
            if (result != null) {
                let resultList = [];
                result.forEach(function(el) {
                    resultList.push(JSON.parse(el));
                    console.log('>>>el>>>' + el);
                });
                this.data = resultList;
                this.fetchSuggestedUsers();

                console.log('>>>--->>>--->>>--->>>' + this.data);
                
            }else{
                this.fetchSuggestedUsers();

            }
        });
    }



    get optionsAttendee() {
        return [{
                label: 'Attendee',
                value: false
            },
            {
                label: 'Organizer',
                value: true
            }
        ];
    }

    get optionsParticipation() {
        return [{
                label: 'In Person',
                value: 'In Person'
            },
            {
                label: 'Remote',
                value: 'Remote'
            },
            {
                label: 'Non Attendee',
                value: 'Non Attendee'
            }
        ];
    }

    dataLoader(){
        this.dataDeleteLoading = false;
    }



    callRowAction(event) {
        this.dataDeleteLoading = true;
        setTimeout(() => {
            this.dataLoader();
        }, 2000);

        const recId = event.currentTarget.dataset.id;
        let dataArr = this.data;
        let finalArr = [];
        dataArr.splice(dataArr.findIndex(v => v.Id === recId), 1);
        dataArr.forEach(function(el) {
            finalArr.push(el);
        });
        console.log('finalArr---->' + JSON.stringify(finalArr));
        this.dataDetails = finalArr;
        this.data = finalArr;
        //this.upsertAttendees();
        this.fetchSuggestedUsers();
        
        console.log('event.detail--->' + JSON.stringify(event.currentTarget.dataset));
        console.log('event.detail--->' + JSON.stringify(event.currentTarget.dataset.id));

    }

    async addLoginUserDetails(){
        await addLoginUser({sciId:this.sciRecId})
        .then(result=>{
           console.log('result >',result);
           if (result != null) {
                let resultList = [];
                result.forEach(function(el) {
                    resultList.push(JSON.parse(el));
                    console.log('>>>el>>>' + el);
                });
                this.data = resultList;
                console.log('>>>--->>>--->>>--->>>' + this.data);
                
            }
        })
        .catch(error =>{
           this.errorMsg=error.message;
           window.console.log('>>>-->>'+this.error);
        });
    }


     fetchSuggestedUsers(){
        let userIdList = [];
        if(this.data.length > 0){
            this.data.forEach(function(el){
                userIdList.push(el.Id.toString());
            });
        }
        console.log('userIdList--->'+userIdList);
         suggestedAttendees({accID : this.accountRecId,userIds : userIdList})
        .then(result=>{
            if(result){
                this.attData = result;
                console.log('attData>>>>'+JSON.stringify(this.attData));
            }
        })
        .catch(error=>{
            console.log('>>>>>>>>>>>>>'+error)
        })
    }

    dataAddLoader(){
        this.dataDeleteLoading = false;
    }

    handleAddUser(event) {
        this.dataDeleteLoading = true;
        setTimeout(() => {
            this.dataAddLoader();
        }, 2000);
        console.log('--->'+event.currentTarget.dataset);
        let userId = event.currentTarget.dataset.id;
        if (userId) {
            let isUserExist = false;
            let dataArr = this.data;
            dataArr.forEach(function(el) {
                if (el.Id == userId) {
                    isUserExist = true;
                }
            });
            console.log('isUserExist---->', isUserExist);
            if (!isUserExist) {
                fetchUserDetails({
                        usrId: userId
                    })
                    .then(result => {
                        if (result != null) {
                            console.log('result-->' + result);
                            console.log('result-->' + JSON.parse(result).name);
                            if (!this.data.includes(JSON.parse(result).name)) {
                                let dataArr = [...this.data];
                                let userObj = JSON.parse(result);
                                userObj.parentRecordId = this.sciRecId;
                                userObj.recId = '';
                                dataArr.push(userObj);
                                this.data = dataArr;

                                let suggestedArrayData = this.attData;
                                let newSuggestedArrayData = [];
                                suggestedArrayData.forEach(function(elem){
                                    if(elem.Id != userObj.Id){
                                        newSuggestedArrayData.push(elem);
                                    }
                                });
                                this.attData = newSuggestedArrayData;
                                console.log('result-->' + this.data);
                            }

                        }

                    });
            }
        }
    }

    dataSearchLoader(){
        this.dataSearchLoading = false;
    }

    handleUser(event) {
        this.dataSearchLoading = true;
        setTimeout(() => {
            this.dataSearchLoader();
        }, 2000);
        console.log('--->' + event.detail.value);
        let userId = event.detail.value.toString();
        if (userId) {
            let isUserExist = false;
            let dataArr = this.data;
            dataArr.forEach(function(el) {
                if (el.Id == userId) {
                    isUserExist = true;
                }
            });
            console.log('isUserExist---->', isUserExist);
            if (!isUserExist) {
                fetchUserDetails({
                        usrId: userId
                    })
                    .then(result => {
                        if (result != null) {
                            console.log('result-->' + result);
                            console.log('result-->' + JSON.parse(result).name);
                            if (!this.data.includes(JSON.parse(result).name)) {
                                let dataArr = [...this.data];
                                let userObj = JSON.parse(result);
                                userObj.parentRecordId = this.sciRecId;
                                userObj.recId = '';
                                dataArr.push(userObj);
                                this.data = dataArr;
                                const inputFields = this.template.querySelectorAll(
                                    'lightning-input-field'
                                );
                                console.log('inputFields---', JSON.stringify(inputFields));
                                console.log('inputFields---', inputFields);
                                if (inputFields) {
                                    inputFields.forEach(field => {
                                        field.reset();
                                    });
                                }
                                console.log('result-->', this.data);
                                console.log('result-->' + this.data);
                            }

                        }

                    });
            }
        } else {
            const inputFields = this.template.querySelectorAll(
                'lightning-input-field'
            );
            console.log('inputFields---', JSON.stringify(inputFields));
            console.log('inputFields---', inputFields);
            if (inputFields) {
                inputFields.forEach(field => {
                    field.reset();
                });
            }
        }
    }

    handleAttendee(event) {
        const recId = event.currentTarget.dataset.id;
        console.log('recId--->', recId);
        let dataArr = this.data;
        dataArr.forEach(function(el) {
            console.log('el.Id--', el.Id);
            if (el.Id == recId) {
                if (event.currentTarget.value == 'true')
                    el.attendeeType = true;
            }
        });
        this.dataDetails = dataArr;
        console.log('this.dataDetails--->' + JSON.stringify(this.dataDetails));
        console.log('event.currentTarget--->' + JSON.stringify(event.currentTarget));
        console.log('event.currentTarget--->' + JSON.stringify(event.currentTarget.value));
    }

    handleParticipation(event) {
        const recId = event.currentTarget.dataset.id;
        console.log('recId--->', recId);
        let dataArr = this.data;
        dataArr.forEach(function(el) {
            console.log('el.Id--', el.Id);
            if (el.Id == recId) {
                el.Participation = event.currentTarget.value;
            }
        });
        this.dataDetails = dataArr;
        console.log('this.dataDetails--->' + JSON.stringify(this.dataDetails));
        console.log('event.currentTarget--->' + JSON.stringify(event.currentTarget));
        console.log('event.currentTarget--->' + JSON.stringify(event.currentTarget.value));
    }

    handleSubmit() {
        this.isLoading = true;
        setTimeout(() => {
            this.handleNext();
        }, 2000);
    }

    async upsertAttendees(){
        await saveAttendees({
            result: JSON.stringify(this.data),
            sciRecId: this.sciRecId
        })
        .then(result => {
            let previousData = this.data;
            let finalData = [];
            if(result){
                result.forEach(function(elem){
                    previousData.forEach(function(el){
                        if(el.recId == ''){
                            if(el.Id == elem.Id){
                                el.recId = elem.Attendee_Name__c;
                            }
                        }
                    });
                });
                this.data = previousData;
                console.log('RESULT->>>>>>-->', JSON.stringify(result));
            }
            
        });
    }

    handleNext() {
        //this.sciRecId
        console.log('this.attendeeExist-', this.attendeeExist);
        console.log('this.data-', this.data);
        if (this.attendeeExist) {
            this.attendeeExist = true;
        } else {
            this.attendeeExist = false;
        }
        if (this.data.length > 0) {
            //if (this.attendeeExist == false) {
                this.attendeeExist = true;

                console.log('this.dataDetails-->' + JSON.stringify(this.dataDetails));
                console.log('this.data-->' + JSON.stringify(this.data));
                this.upsertAttendees();
                
           // }
            const gotoNextStepEvent = new CustomEvent('gotonextstep', {
                detail: {
                    nextStep: "4",
                    selectedRecordTypeId: this.selectedRecordTypeId,
                    selectedMeetingLocation: this.selectedMeetingLocation,
                    selectedMeetingNotes: this.meetingNotes,
                    selectedDate: this.selectedDate,
                    attendeeExist: this.attendeeExist,
                    saveData: this.saveData,
                    participation: this.data,
                    generatedRecordId: this.generatedRecordId,
                    sciRecordId: this.sciRecId
                }
            });
            console.log('SCI RECORD ID___>>>>>' + this.sciRecordId);
            // Dispatches the event.
            this.isLoading = false;
            this.dispatchEvent(gotoNextStepEvent);


        } else {
            // const toastEvent = new ShowToastEvent({
            //     title: 'Error',
            //     message: 'Select at least one record',
            //     variant: 'error'
            // });
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Select at least one record');
            this.isLoading = false;
            //this.dispatchEvent(toastEvent);
        }
    }


    handlePreviousLoader(){
        this.previousLoading = true;
        setTimeout(() => {
            this.handlePrevious();
        }, 2000);
    }

    handlePrevious() {
        
        console.log('this.dataDetails-->' + JSON.stringify(this.dataDetails));
        console.log('this.data-->' + JSON.stringify(this.data));

        this.recordExist = true;
        //console.log('result--->',JSON.stringify(result));
        this.upsertAttendees();
        const gotoNextStepEvent = new CustomEvent('gotonextstep', {
            detail: {
                nextStep: "2",

                selectedRecordTypeId: this.selectedRecordTypeId,
                selectedMeetingLocation: this.selectedMeetingLocation,
                selectedMeetingNotes: this.meetingNotes,
                participation: this.data,
                selectedDate: this.selectedDate,
                saveData: this.saveData,
                recordExist: this.recordExist,
                sciRecordId: this.sciRecId
            }
        });
        // Dispatches the event.
        console.log('>>>--->>>--->>>' + this.recordExist);
        this.previousLoading =false;
        this.dispatchEvent(gotoNextStepEvent);
    }



    handleCancel() {

        if (confirm("Are you sure? You will lose all data when cancel") == true) {
            deleteSciOnCancel({
                    recId: this.generatedRecordId
                })
                .then(result => {});
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Account',
                    actionName: 'home',
                },
            });
        } else {

        }

    }


}
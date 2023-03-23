import {
    api,
    LightningElement,
    track
} from 'lwc';
import fetchRecordTypeNameDescription from '@salesforce/apex/SelectSCITypeCtrl.fetchRecordTypeNameDescription';
import updateRecordTypeSCI from '@salesforce/apex/SelectSCITypeCtrl.fatchRecordTypeId';
//import submitSCIAction from '@salesforce/apex/EnterSCIDetailsCtrl.submitSCIAction';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import {
    NavigationMixin
} from 'lightning/navigation';
// import DATE_OF_MEETING from '@salesforce/schema/Significant_Customer_Interaction__c.Date__c';
// import MEETING_LOCATION from '@salesforce/schema/Significant_Customer_Interaction__c.Meeting_Location__c'
// import INTERACTION_WITH from '@salesforce/schema/Significant_Customer_Interaction__c.Interaction_With__c';
// import PRIMARY_TOPIC_COVER from '@salesforce/schema/Significant_Customer_Interaction__c.Primary_Topic_Covered__c';
// import MEETING_NOTES from '@salesforce/schema/Significant_Customer_Interaction__c.Meeting_Notes__c';
// import ARCHITECTURE_WORKSHOP from '@salesforce/schema/Significant_Customer_Interaction__c.Architecture_Workshop_Link__c';
// import NEXT_STEP from '@salesforce/schema/Significant_Customer_Interaction__c.Next_Steps__c';
// import ZSCALER_CXO_ADVISOR from '@salesforce/schema/Significant_Customer_Interaction__c.Zscaler_CXO_Advisor__c';
// import OPP_NAME from '@salesforce/schema/Significant_Customer_Interaction__c.Opportunity_Name__c';
// import LEAD_VAL from '@salesforce/schema/Significant_Customer_Interaction__c.Lead__c';
// import DEAL_REG from '@salesforce/schema/Significant_Customer_Interaction__c.Deal_Reg__c';
// import CAMPAIGN_VAL from '@salesforce/schema/Significant_Customer_Interaction__c.Campaign__c';


export default class EnterSCIDetails extends NavigationMixin(LightningElement) {
    @api isLoaded = false;
    @track sciObjIWC;
    @track sciObjPTC;
    @track sciObjMN;
    @track sciObjML
    @track sciNXTSTPS;
    @track sciZCA;
    @track sciOPPNAMe;
    @track sciLEAD;
    @track sciDR;
    @track sciCMPGN;
    @track options = [];
    //@api sciRecordId;
    @track privateselectedRecordTypeId;
    accountRecId;
    @track recordExist;
    @track generatedRecordId;
    sciRecId;
    @track isLoading = false;



    activeSections = ['A', 'B', 'C'];


    @api saveData;
    @api participation;
    @api selectedSciId;
    @api recordExist;
    @api internalAttendee;


    @api
    get sciRecordId() {
        return this.sciRecId;
    }
    set sciRecordId(value) {
        try {
            if (value) {
                this.sciRecId = value;
                console.log('Set this.sciRecId ' + JSON.stringify(this.sciRecId));
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
    onMeetingNotesChange(event) {
        this.meetingNotes = event.detail.value;
    }

    MeetingLocation;
    @api
    get selectedMeetingLocation() {
        return this.MeetingLocation;;
    }
    set selectedMeetingLocation(value) {
        try {
            if (value) {
                this.MeetingLocation = value;
                console.log('Set this.MeetingLocation ' + JSON.stringify(this.MeetingLocation));
            }
        } catch (error) {
            console.log('Error : ' + error);
            console.log('Error : ' + JSON.stringify(error));
        }

    }
    onMeetingLocChange(event) {
        this.MeetingLocation = event.detail.value;
    }
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

    @api objectApiName = 'Significant_Customer_Interaction__c';
    //fields = [DATE_OF_MEETING,MEETING_LOCATION, INTERACTION_WITH, PRIMARY_TOPIC_COVER,MEETING_NOTES,NEXT_STEP,ZSCALER_CXO_ADVISOR,OPP_NAME,LEAD_VAL,DEAL_REG,CAMPAIGN_VAL,ARCHITECTURE_WORKSHOP];
    onSCIFormSubmit(event) {
        this.isLoading = true;
    }

    handleSuccess(event) {

        console.log('Selected RecordType Id ----> : ' + this.privateselectedRecordTypeId);

        if (this.recordExist) {
            this.recordExist = true;
            this.generatedRecordId = event.detail.id;
        } else {
            this.recordExist = false;

        }
        console.log('>>>>>RecordExist>>>>' + this.recordExist)
        if (this.recordExist == false) {
            if (this.sciRecId) {
                this.recordExist = true;
                this.internalAttendee = true;
                this.template.querySelector('c-custom-toast-component').showToast('success', "Significant Customer Interactions Updated. Record ID: " + event.detail.id);
                // const evt = new ShowToastEvent({
                //     title: "Significant Customer Interactions Updated",
                //     message: "Record ID: " + event.detail.id,
                //     variant: "success"
                // });

                // this.dispatchEvent(evt);
                this.sciRecId = event.detail.id;
                this.isLoading = true;



                setTimeout(() => {
                    this.handleSubmit();
                }, 2000);


            } else {
                this.recordExist = true;
                this.template.querySelector('c-custom-toast-component').showToast('success', "Significant Customer Interactions Created. Record ID: " + event.detail.id);
                //const evt = new ShowToastEvent({
                //     title: "Significant Customer Interactions Created",
                //     message: "Record ID: " + event.detail.id,
                //     variant: "success"
                // });

                //this.dispatchEvent(evt);
                this.sciRecId = event.detail.id;
                this.isLoading = true;

                updateRecordTypeSCI({
                        sciId: this.sciRecId,
                        recTypeId: this.privateselectedRecordTypeId
                    })
                    .then(result => {
                        if (result != null) {
                            console.log('Record Updated');
                        }

                    });

                setTimeout(() => {
                    this.handleSubmit();
                }, 2000);

            }
        } else {
            this.handleSubmit();
        }

    }



    handleSubmit() {
        // Creates the event.
        this.isLoaded = false;
        //console.log('>>>>>>----->>>>>>>'+this.MeetingLocation)
        const gotoNextStepEvent = new CustomEvent('gotonextstep', {
            detail: {
                nextStep: "3",
                selectedRecordTypeId: this.privateselectedRecordTypeId,
                selectedMeetingNotes: this.meetingNotes,
                participation: this.participation,
                internalAttendee: this.internalAttendee,
                selectedMeetingLocation: this.MeetingLocation,
                selectedDate: this.privateselectedDate,
                saveData: this.saveData,
                generatedRecordId: this.generatedRecordId,
                recordExist: this.recordExist,
                sciRecordId: this.sciRecId
            }
        });
        // Dispatches the event.
        this.isLoading = false;
        console.log('>>>>>>privateselectedRecordTypeId----->>>>>>>' + this.privateselectedRecordTypeId)
        this.dispatchEvent(gotoNextStepEvent);


    }

    connectedCallback() {
        this.isLoaded = false;
        console.log('>>>SCI ID>>>' + this.sciRecId);
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



    handleRecordTypeChange(event) {
        this.privateselectedRecordTypeId = event.detail.value;
        console.log('Selected RecordType Id : ' + this.privateselectedRecordTypeId);
    }

    scoreHandleChange(event) {
        if (event.target.name == 'IWC') {
            this.sciObjIWC = event.target.value;
            window.console.log('scoreObName ##' + this.scoreObName);
        }
        if (event.target.name == 'PTC') {
            this.sciObjPTC = event.target.value;
        }
        if (event.target.name == 'ML') {
            this.sciObjML = event.target.value;
        }

        if (event.target.name == 'MN') {
            this.sciObjMN = event.target.value;
        }
        if (event.target.name == 'NXTSTPS') {
            this.sciNXTSTPS = event.target.value;
        }
        if (event.target.name == 'ZCA') {
            this.sciZCA = event.target.value;
        }
        if (event.target.name == 'OPPNAMe') {
            this.sciOPPNAMe = event.target.value;
        }
        if (event.target.name == 'LEAD') {
            this.sciLEAD = event.target.value;
        }
        if (event.target.name == 'DR') {
            this.sciDR = event.target.value;
        }
        if (event.target.name == 'CMPGN') {
            this.sciCMPGN = event.target.value;
        }
    }

    //   submitAction(){
    //       //this.isLoading = true;

    //     submitSCIAction({sciIWC:this.sciObjIWC,sciPTC:this.sciObjPTC,sciML:this.sciObjML,
    //         sciMN:this.sciObjMN,sciNextstps:this.sciNXTSTPS,sciZCA:this.sciZCA
    //         ,sciOppname:this.sciOPPNAMe,sciLead:this.sciLEAD,
    //         sciDealReg:this.sciDR,sciCmpgn:this.sciCMPGN})
    //     .then(result=>{
    //         this.sciRecoID = result.Id;
    //         //window.console.log('sciRecoID##Vijay2 ' + this.sciRecoID);       
    //         const toastEvent = new ShowToastEvent({
    //             title:'Success!',
    //             message:'Record created successfully',
    //             variant:'success'
    //           });
    //           this.dispatchEvent(toastEvent);

    //           /*Start Navigation*/
    //           this[NavigationMixin.Navigate]({
    //             type: 'standard__recordPage',
    //             attributes: {
    //                 recordId: this.sciRecoID,
    //                 objectApiName: 'Significant_Customer_Interaction__c',
    //                 actionName: 'view'
    //             },
    //          });
    //          /*End Navigation*/

    //     })
    //     .catch(error =>{
    //        this.errorMsg=error.message;
    //        window.console.log(this.error);
    //     });

    //  }

    handleCancel() {

        if (confirm("Are you sure? You will lose all data when cancel") == true) {
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
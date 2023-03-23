import { LightningElement,api,track, wire } from 'lwc';
import ATTENDEE_LEAD_NAME from '@salesforce/schema/SCI_External_Attendee__c.Attendee_Name_Lead__c';
import ATTENDEE_TYPE from '@salesforce/schema/SCI_External_Attendee__c.Type__c';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import ATTENDEE_NAME from '@salesforce/schema/SCI_External_Attendee__c.Attendee_Name__c';
import fetchContactData from '@salesforce/apex/EnterSCIDetailsCtrl.fetchContactData';
import fetchLeadData from '@salesforce/apex/EnterSCIDetailsCtrl.fetchLeadData';
import fetchExistingExternalAttendees from '@salesforce/apex/EnterSCIDetailsCtrl.fetchExistingExternalAttendees';
import saveAttendees from '@salesforce/apex/EnterSCIDetailsCtrl.insertExternalAttendees';
import CONTACTSBYACCOUNT from '@salesforce/apex/EnterSCIDetailsCtrl.displayConRecord';//
import CONTACTSDATA from '@salesforce/apex/EnterSCIDetailsCtrl.displayDataConRecord';
import CMTBYACCOUNT from '@salesforce/apex/EnterSCIDetailsCtrl.displayCMTConRecord';
import CMTDATA from '@salesforce/apex/EnterSCIDetailsCtrl.displayDataCMTConRecord';
import deleteSciOnCancel from '@salesforce/apex/SelectSCITypeCtrl.deleteSciOnCancel';
//import fetchUserDetails from '@salesforce/apex/EnterSCIDetailsCtrl.fetchPushData';
import {NavigationMixin} from 'lightning/navigation';
import id from '@salesforce/user/Id';
import Set_Partner_Account from '@salesforce/resourceUrl/Set_Partner_Account';

export default class ManageExternalAttendees  extends NavigationMixin (LightningElement) {
    @api isLoaded = false;
    @api isLoadedContact = false;
    @track data = [];
    dataDetails = [];
    @track usrData = [];
    @track conData =[];
    @track conDataCopy = [];
    @track cmtData =[];
    @track cmtDataCopy = [];
    @track accountName;
    @track accountCheck = true;
    @track showAccountName = true;
    @track dataAddLoading = false;
    @track dataDeleteLoading = false;
    @track dataSearchLoading = false;
    @track previousLoading = false;
    BaseURL;

    
    usId = id;
    sciRecId;
    contId;
    @track isModalOpen = false;
    @api objectApiName = 'SCI_External_Attendee__c';
    fields = [ATTENDEE_NAME,ATTENDEE_LEAD_NAME,ATTENDEE_TYPE];
    valueAttendee = 'Customer';
    valueParticipation = 'In Person';
    @track accountRecId;

    @api participation;
    @api selectedRecordTypeId;
    @api selectedDate;
    @api selectedMeetingLocation;
    @api attendeeExist;
    @api generatedRecordId;


    @api
    get saveData() {
        return this.data
    }
    set saveData(value) {
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

    }

    // @api
    // get saveConData() {
    //     return this.conData
    // }
    // set saveConData(value) {
    //     try {
    //         if (value) {
    //             const dataSet = JSON.parse(JSON.stringify(value));
    //             this.conData = [...dataSet];
    //             console.log('Set this.conData ' + JSON.stringify(this.conData));
    //         }
    //     } catch (error) {
    //         console.log('Error : ' + error);
    //         console.log('Error : ' + JSON.stringify(error));
    //     }

    // }

    // @api
    // get saveCmtData() {
    //     return this.cmtData
    // }
    // set saveCmtData(value) {
    //     try {
    //         if (value) {
    //             const dataSet = JSON.parse(JSON.stringify(value));
    //             this.cmtData = [...dataSet];
    //             console.log('Set this.cmtData ' + JSON.stringify(this.cmtData));
    //         }
    //     } catch (error) {
    //         console.log('Error : ' + error);
    //         console.log('Error : ' + JSON.stringify(error));
    //     }

    // }

    @api
    get accountRecordId() {
        return this.accountRecId;
    }
    set accountRecordId(value) {
        try {
            if (value) {
                this.accountRecId = value;
                console.log('Set this.accountRecordId ' + JSON.stringify(this.accountRecId));
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

    @api
    get sciRecordId() {
        return this.sciRecId;
    }
    set sciRecordId(value) {
        try {
            console.log('--->'+value);
            if (value) {
                this.sciRecId = value;
                console.log('Set this.sciRecId ' + JSON.stringify(this.sciRecId));
            }
        } catch (error) {
            console.log('Error : ' + error);
            console.log('Error : ' + JSON.stringify(error));
        }

    }

    get optionsAttendee() {
        return [
            { label: 'Customer', value: 'Customer' },
            { label: 'Partner', value: 'Partner' }
        ];
    }

    get optionsParticipation() {
        return [
            { label: 'In Person', value: 'In Person' },
            { label: 'Remote', value: 'Remote' }
        ];
    }

    dataDeleteLoader(){
        this.dataDeleteLoading = false;
    }

    callRowAction( event ) {  
        this.dataDeleteLoading = true;
        setTimeout(() => {
            this.dataDeleteLoader();
        }, 2000);
        const recId = event.currentTarget.dataset.id;  
        let dataArr = this.data;
        let finalArr = [];
        dataArr.splice(dataArr.findIndex(v => v.Id === recId), 1);
        dataArr.forEach(function(el){
            finalArr.push(el);
        });
        console.log('finalArr---->'+JSON.stringify(finalArr));
        this.dataDetails = finalArr;
        this.data = finalArr;
        console.log('event.detail--->'+JSON.stringify(event.currentTarget.dataset));
        console.log('event.detail--->'+JSON.stringify(event.currentTarget.dataset.id));


        let userId = event.currentTarget.dataset.id;
        if(userId){
            let isUserExist = false;
            let dataArr = this.conDataCopy;
            console.log('ConData>>>>'+JSON.stringify(this.conData))
            console.log('ConDATACOpy>>>>>'+JSON.stringify(this.conDataCopy))
            dataArr.forEach(function(el){
                if(el.Id == userId){
                    isUserExist = true;
                }
            });
            console.log('isUserExist---->',isUserExist);
            if(isUserExist == true){
                fetchContactData({conId:userId})
                .then(result=>{
                    if(result != null){
                        console.log('result-->'+JSON.stringify(result));
                        console.log('USER ID>>>>>'+userId)
                            let dataArr = [...this.conData];
                        let userObj = result;
                        
                        dataArr.push(userObj);
                        this.conData = dataArr;
                 
                    }
                    
                });
            }
        }

        if(userId){
            let isUserExist = false;
            let dataArr = this.cmtDataCopy;
            dataArr.forEach(function(el){
                if(el.Id == userId){
                    isUserExist = true;
                }
            });
            console.log('isUserExist---->',isUserExist);
            if(isUserExist == true){
                fetchContactData({conId:userId})
                .then(result=>{
                    if(result != null){
                        console.log('result-->'+result);
                        
                            let dataArr = [...this.cmtData];
                        let userObj = result;
                       
                        
                        dataArr.push(userObj);
                        this.cmtData = dataArr;
                        
                        
                    
                    }
                    
                });
            }
        }

        
       
         } 
    
  
    handleType(event){
        console.log('--->'+event.detail.value);
    }

    openModal() {
        console.log('model Opened')
        this.isModalOpen = true;
    }
    submitDetails() {
        this.isModalOpen = false;
    }
    closeModal() {
        this.isModalOpen = false;
    }

    
    handleSuccess(event) {
        this.isLoadedContact = false;
        this.contId = event.detail.id;
        console.log(this.contId);
        console.log('event.detail--->'+JSON.stringify(event.detail));
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        console.log('inputFields---',JSON.stringify(inputFields));
        console.log('inputFields---',inputFields);
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
        this.template.querySelector('c-custom-toast-component').showToast('Success', 'Record Id:'+ this.contId +'Record created');
        // const toastEvent = new ShowToastEvent({
        //     title:'Success!',
        //     message:'Record Id:'+ this.contId +'Record created',
        //     variant:'success'
        //   });
          fetchContactData({conId:this.contId})
            .then(result=>{
                if(result != null){
                    console.log('result-->'+JSON.stringify(result));
                    if(!this.data.includes(result.Name)){
                        let dataArr = [...this.data];
                    let userObj = result;
                    userObj.parentRecordId = this.sciRecId;
                    dataArr.push(userObj);
                    this.data = dataArr;
                    let conCopy = this.conDataCopy;
                    conCopy.push(result);
                    this.conDataCopy = conCopy;
                    
                    //event.detail.value = null;
                    const inputFields = this.template.querySelectorAll(
                        'lightning-input-field'
                    );
                    console.log('inputFields---',JSON.stringify(inputFields));
                    console.log('inputFields---',inputFields);
                    if (inputFields) {
                        inputFields.forEach(field => {
                            field.reset();
                        });
                    }
                    console.log('result-->',this.data);
                    console.log('result-->'+this.data);
                    }
                
                }
                
            });
          //this.dispatchEvent(toastEvent);
          this.isModalOpen = false;
    }

    dataAddLoader(){
        this.dataAddLoading = false;
    }

    handleSuggestedContact(event){
        this.dataAddLoading = true;
        setTimeout(() => {
            this.dataAddLoader();
        }, 2000);
        console.log('--->'+event.currentTarget.dataset);
        let recId = event.currentTarget.dataset.id; 

        let dataArr = this.conData;
        let finalArr = [];
        let userConExist = false;
        dataArr.forEach(function (el){
            if(el.Id == recId){
                userConExist = true;
            }
        });
        if(userConExist == true){
        dataArr.splice(dataArr.findIndex(v => v.Id === recId), 1);
        dataArr.forEach(function(el){
            finalArr.push(el);
        });
        console.log('finalArr---->'+JSON.stringify(finalArr));
        this.dataDetails = finalArr;
        this.conData = finalArr;
        }


       
        

       
          
        let dataCmtArr = this.cmtData;
        let finalCmtArr = [];
        let userCmtExist = false;
        dataCmtArr.forEach(function (el){
            if(el.Id == recId){
                userCmtExist = true;
            }
        });
        if(userCmtExist == true){
        dataCmtArr.splice(dataCmtArr.findIndex(v => v.Id === recId), 1);
        dataCmtArr.forEach(function(el){
            finalCmtArr.push(el);
        });
        console.log('finalArr---->'+JSON.stringify(finalCmtArr));
        this.dataDetails = finalCmtArr;
        this.cmtData = finalCmtArr;
    }

        let userId = event.currentTarget.dataset.id.toString();
        if(userId){
            let isUserExist = false;
            let dataArr = this.data;
            dataArr.forEach(function(el){
                if(el.Id == userId){
                    isUserExist = true;
                }
            });
            console.log('isUserExist---->',isUserExist);
            if(!isUserExist){
                fetchContactData({conId:userId})
                .then(result=>{
                    if(result != null){
                        console.log('result-->'+result);
                        if(!this.data.includes(result.Name)){
                            let dataArr = [...this.data];
                        let userObj = result;
                        userObj.parentRecordId = this.sciRecId;
                        userObj.type = 'Customer';
                        if(result.AccountId){
                            
                        }else{
                            let newObj = {};
                            newObj.Name = '';
                            userObj.Account = newObj;
                        }
                        
                        dataArr.push(userObj);
                        this.data = dataArr;
                        const inputFields = this.template.querySelectorAll(
                            'lightning-input-field'
                        );
                        console.log('inputFields---',JSON.stringify(inputFields));
                        console.log('inputFields---',inputFields);
                        if (inputFields) {
                            inputFields.forEach(field => {
                                field.reset();
                            });
                        }
                        //event.detail.value = null;
                        console.log('result-->',this.data);
                        console.log('result-->'+this.data);
                        }
                    
                    }
                    
                });
            }
        }else{
            event.detail.value = null;
        }
    }

    
    
    
    connectedCallback(){
        this.isLoaded = false;
        this.isLoadedContact = false;
        console.log('>>>>>sciRecId>>>'+this.sciRecId);
        if(this.conData.length === 0){
            if(this.data.length === 0){
            CONTACTSBYACCOUNT({accId:this.accountRecId})
        .then(result=>{
            if(result){
                // let filterConData = [];
                // if(this.data.length > 0){
                //     this.data.forEach(function(elem){
                //         result.forEach(function(el){
                //             if(elem.Id != el.Id){
                //                 filterConData.push(el);
                //             }
                //         });
                //     });
                // }else{
                //     filterConData = result;
                // }
                this.conData = result;
                console.log('conData>>>>'+JSON.stringify(this.conData));
            }
        })
        .catch(error=>{
            console.log('>>>>>>>>>>>>>'+error)
        })}
        }
        if(this.data.length > 0){
            let dataStr = JSON.stringify(this.data);
            CONTACTSDATA({accId:this.accountRecId, dataRec: dataStr})
        .then(result=>{
            if(result){
                // let filterConData = [];
                // if(this.data.length > 0){
                //     this.data.forEach(function(elem){
                //         result.forEach(function(el){
                //             if(elem.Id != el.Id){
                //                 filterConData.push(el);
                //             }
                //         });
                //     });
                // }else{
                //     filterConData = result;
                // }
                this.conData = result;
                console.log('conData>>>>'+JSON.stringify(this.conData));
            }
        })
        .catch(error=>{
            console.log('>>>>>>>>>>>>>'+error)
        })
        }
       
      
        
        if(this.conDataCopy.length === 0){
            
            CONTACTSBYACCOUNT({accId:this.accountRecId})
        .then(result=>{
            this.conDataCopy = result;
            console.log('ConDATACOpy>>>>>'+JSON.stringify(this.conDataCopy))
        })
        .catch(error=>{
            console.log('>>>>>>>>>>>>>'+error)
        })
        }


        // if(this.data.length > 0){
        //     let dataStr = JSON.stringify(this.data);
        //     CONTACTSDATA({accId:this.accountRecId, dataRec: dataStr})
        // .then(result=>{
        //     if(result){
        //         this.conDataCopy = result;
        //         console.log('conData>>>>'+JSON.stringify(this.conDataCopy));
        //     }
        // })
        // .catch(error=>{
        //     console.log('>>>>>>>>>>>>>'+error)
        // })
        // }

        if(this.cmtData.length === 0){
            if(this.data.length === 0){
            CMTBYACCOUNT({accId:this.accountRecId})
        .then(result=>{
            if(result){
                
                this.cmtData = result;
                console.log('CmtData>>>>'+JSON.stringify(this.cmtData));
            }
        })
        .catch(error=>{
            console.log('>>>>>>>>>>>>>'+error)
        })
        
    }
}
        if(this.data.length > 0){
            let dataStr = JSON.stringify(this.data);
            CMTDATA({accId:this.accountRecId,dataRec: dataStr})
            .then(result=>{
                if(result){
                    
                    this.cmtData = result;
                    console.log('CmtData>>>>'+JSON.stringify(this.cmtData));
                }
            })
            .catch(error=>{
                console.log('>>>>>>>>>>>>>'+error)
            })
            }

        
        if(this.cmtDataCopy.length === 0){
           
            CMTBYACCOUNT({accId:this.accountRecId})
        .then(result=>{
            this.cmtDataCopy = result;
            console.log('CmtDATACOpy>>>>>'+JSON.stringify(this.cmtDataCopy))
        })
        .catch(error=>{
            console.log('>>>>>>>>>>>>>'+error)
        })
    
        }


        // if(this.data.length > 0){
        //     let dataStr = JSON.stringify(this.data);
        //     CMTDATA({accId:this.accountRecId,dataRec: dataStr})
        //     .then(result=>{
        //         if(result){
                    
        //             this.cmtDataCopy = result;
        //             console.log('CmtData>>>>'+JSON.stringify(this.cmtDataCopy));
        //         }
        //     })
        //     .catch(error=>{
        //         console.log('>>>>>>>>>>>>>'+error)
        //     })
        // }

        if(this.attendeeExist){
            fetchExistingExternalAttendees({sciId:this.sciRecId})
            .then(result=>{
                console.log('result--->'+result);
                if(result != null){
                    let resultList=[];
                    result.forEach(function(el){
                        let obj = JSON.parse(el);
                        //obj.parentRecordId = this.sciRecId;
                        resultList.push(obj);
                        console.log('>>>obj>>>'+obj);
                    });
                    this.data = resultList;
                    this.showAccountName = false;
                }
                
            });
        
        }
        // console.log('>>>>SCI REC ID'+this.sciRecId)
        // if(this.data){
        //     this.data.forEach(function(el){
        //         el.parentRecordId = this.sciRecId;
        //     });
        // }
    }
    
        
//         let userId = this.usId
//         let isUserExist = false;
//             let dataArr = this.data;
//             dataArr.forEach(function(el){
//                 if(el.Id == userId){
//                     isUserExist = true;
//                 }
//             });
//             if(!isUserExist){
//         fetchUserDetails({usrId:this.usId})
//         .then(result=>{
//             if(result != null){
                
//                 console.log('result-->'+result);
//                 console.log('result-->'+JSON.parse(result).name);
//                 if(!this.data.includes(JSON.parse(result).name)){
//                     let dataArr = [...this.data];
//                 this.accountCheck = false;
//                 let userObj = JSON.parse(result);
//                 userObj.parentRecordId = this.sciRecId;
//                 dataArr.push(userObj);
                
//                 this.data = dataArr;
//                 this.showAccountName = false;
                
//                 }
//             }
            
//         });

        
//     }
        

    onSubmitContact(event){
        this.isLoadedContact=true;
    }

    dataSearchLoader(){
        this.dataSearchLoading = false;
    }

   

    handleContact(event){
        this.dataSearchLoading = true;
        setTimeout(() => {
            this.dataSearchLoader();
        }, 2000);
        
        
        console.log('--->'+event.detail.value);
        let userId = event.detail.value.toString();
        if(userId){
            let isUserExist = false;
            let dataArr = this.data;
            dataArr.forEach(function(el){
                if(el.Id == userId){
                    isUserExist = true;
                }
            });
            console.log('isUserExist---->',isUserExist);
            if(!isUserExist){
                fetchContactData({conId:userId})
                .then(result=>{
                    if(result != null){
                        console.log('result-->'+result);
                        if(!this.data.includes(result.Name)){
                            let dataArr = [...this.data];
                        let userObj = result;
                        userObj.parentRecordId = this.sciRecId;
                        userObj.type = 'Customer';
                        userObj.recId = '';
                        if(result.AccountId){
                            
                        }else{
                            let newObj = {};
                            newObj.Name = '';
                            userObj.Account = newObj;
                        }
                        
                        dataArr.push(userObj);
                        
                        this.data = dataArr;
                        this.accountName = this.data.Name;
                        const inputFields = this.template.querySelectorAll(
                            'lightning-input-field'
                        );
                        console.log('inputFields---',JSON.stringify(inputFields));
                        console.log('inputFields---',inputFields);
                        if (inputFields) {
                            inputFields.forEach(field => {
                                field.reset();
                            });
                        }
                        //event.detail.value = null;
                        console.log('result-->',this.data);
                        console.log('result-->'+this.data);
                        }
                    
                    }
                    
                });
            }
        }else{
            event.detail.value = null;
        }
    }


    handleLead(event){
        console.log('--->'+event.detail.value);
        let userId = event.detail.value.toString();
        if(userId){
            let isUserExist = false;
            let dataArr = this.data;
            dataArr.forEach(function(el){
                if(el.Id == userId){
                    isUserExist = true;
                }
            });
            console.log('isUserExist---->',isUserExist);
            if(!isUserExist){
                fetchLeadData({leadId:userId})
                .then(result=>{
                    if(result != null){
                        console.log('result-->'+result);
                        console.log('result-->'+result.Name);
                        if(!this.data.includes(result.Name)){
                            let dataArr = [...this.data];
                        let userObj = result;
                        userObj.parentRecordId = this.sciRecId;
                        userObj.type = 'Customer';
                        let newObj = {};
                        newObj.Name = '';
                        userObj.Account = newObj;
                        dataArr.push(userObj);
                        this.data = dataArr;
                        const inputFields = this.template.querySelectorAll(
                            'lightning-input-field'
                        );
                        console.log('inputFields---',JSON.stringify(inputFields));
                        console.log('inputFields---',inputFields);
                        if (inputFields) {
                            inputFields.forEach(field => {
                                field.reset();
                            });
                        }
                        //event.detail.value = null;
                        console.log('result-->',this.data);
                        console.log('result-->'+this.data);
                        }
                    
                    }
                    
                });
            }
        }else{
            event.detail.value = null;
        }
    }

    handleAttendee(event){
        const recId = event.currentTarget.dataset.id;
        console.log('recId--->',recId);
        let dataArr = this.data;
        dataArr.forEach(function(el){
            console.log('el.Id--',el.Id);
            if(el.Id == recId){
                el.type = event.currentTarget.value.toString();
            }
        });
        this.dataDetails = dataArr;
        console.log('this.dataDetails--->'+JSON.stringify(this.dataDetails));
        console.log('event.currentTarget--->'+JSON.stringify(event.currentTarget));
        console.log('event.currentTarget--->'+JSON.stringify(event.currentTarget.value));
    }

    handleParticipation(event){
        const recId = event.currentTarget.dataset.id;
        console.log('recId--->',recId);
        let dataArr = this.data;
        dataArr.forEach(function(el){
            console.log('el.Id--',el.Id);
            if(el.Id == recId){
                el.participation = event.currentTarget.value;
            }
        });
        this.dataDetails = dataArr;
        console.log('this.dataDetails--->'+JSON.stringify(this.dataDetails));
        console.log('event.currentTarget--->'+JSON.stringify(event.currentTarget));
        console.log('event.currentTarget--->'+JSON.stringify(event.currentTarget.value));
    }

    renderedCallback() {
        this.BaseURL = window.location.origin;
    }

    handleNext(event){
        //this.sciRecId
        this.isLoaded = true;
        if(this.data.length>0){
        console.log('this.dataDetails-->'+JSON.stringify(this.dataDetails));
        console.log('this.data-->'+JSON.stringify(this.data));
        saveAttendees({result:JSON.stringify(this.data),sciRecId:this.sciRecId})
        .then(result=>{
            this.isLoaded = false;
            result.recId='';
            console.log('result--->',JSON.stringify(result));
            if(result){
                let scirecId = this.sciRecId;
                this.template.querySelector('c-custom-toast-component').showToast('success', 'Created Successfully.SCI '+ this.sciRecId );
                
                
                window.open(this.BaseURL+'/lightning/r/Significant_Customer_Interaction__c/'+scirecId+'/view',"_self");
                // Navigate to the Record View Page
                // this[NavigationMixin.Navigate]({
                //     type: "standard__recordPage",
                //     attributes: {
                //         recordId: scirecId,
                //         actionName: "view"
                //     }
                // });
            
              //location.reload();
            }
            
        });
    }
    else{
        this.isLoaded  = false;
        this.template.querySelector('c-custom-toast-component').showToast('error', 'Select at least one record');
        // const toastEvent = new ShowToastEvent({
        //     title:'Error',
        //     message:'Select at least one record',
        //     variant:'error'
        //   });
        //   this.dispatchEvent(toastEvent);
    }
}

handlePreviousLoader(){
    this.previousLoading = true;
        setTimeout(() => {
            this.handlePrevious();
        }, 2000);
}

handlePrevious(event){
    //this.sciRecId
    
    console.log('this.dataDetails-->'+JSON.stringify(this.dataDetails));
    console.log('this.data-->'+JSON.stringify(this.data));
    this.attendeeExist = true;
        const gotoNextStepEvent = new CustomEvent('gotonextstep', {
            detail:
            {
                nextStep: "3",
                selectedRecordTypeId: this.selectedRecordTypeId,
                selectedMeetingLocation: this.selectedMeetingLocation,
                attendeeExist: this.attendeeExist,
                selectedMeetingNotes: this.meetingNotes,
                saveData: this.data,
                // saveCmtData: this.cmtData,
                // saveConData: this.conData,
                selectedDate: this.selectedDate,
                participation: this.participation,
                sciRecordId : this.sciRecId
            }
        });
        // Dispatches the event.
        console.log('ATTENDEE_EXIST>>>>>>>>'+this.attendeeExist);
        this.previousLoading = false;
        this.dispatchEvent(gotoNextStepEvent);
    

}

handleCancel(){

    if (confirm("Are you sure? You will lose all data when cancel") == true) {
        console.log('GENERATEDRECORDID>>>>'+this.generatedRecordId);
        deleteSciOnCancel({recId:this.generatedRecordId})
        .then(result=>{});
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
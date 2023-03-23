import { LightningElement, track,api,wire } from 'lwc';
import AccountAndOpportunityLinks from '@salesforce/apex/AssociatedAccountAndOpportunityLinks.AccountsAndOpportunityLink';
import AccountNames from '@salesforce/apex/AssociatedAccountAndOpportunityLinks.accountNames';
import fetchAVPLinks from '@salesforce/apex/AssociatedAccountAndOpportunityLinks.fetchAVPLinks';
import OpportunityNames from '@salesforce/apex/AssociatedAccountAndOpportunityLinks.opportunityNames';
import opportunityRemovedNames from '@salesforce/apex/AssociatedAccountAndOpportunityLinks.opportunityRemovedNames';
import UserNames from '@salesforce/apex/AssociatedAccountAndOpportunityLinks.userNames';
import Transformation_Object from "@salesforce/schema/Transformation_Team_Speaker_Request__c";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class TransformationSpeakerRequestRejection extends LightningElement {
    @track accList = [];
    oppList = [];
    userList = [];
    TransformationRecordId;
    loaded = true;
    accLinkList = [];
    oppLinkList = [];
    userLinkList = [];
    showpillAcc = false;
    showpillOpp = false;
    showpillsUser = true;
    @track otherTransformTeam = false;
    @track otherEventType = false;
    @track otherHostedBy = false;
    @track isDiscussion = false;
    @api recordId;
    @track recordTypeId = '';

    @wire(getObjectInfo, { objectApiName: Transformation_Object })
    getObjectData({data,error}){
        if(data){
            const rtis = data.recordTypeInfos;
            this.recordTypeId = Object.keys(rtis).find(
                (rti) => rtis[rti].name === "Submitted"
            );
        }
    };

    handleSubmit(event){
        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;
        //fields.Status__c = 'Submitted';
        //fields.isResubmit__c = true;
        //fields.RecordTypeId = this.recordTypeId;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleOnLoad(){
        console.log('this.recordId--->',this.recordId);
        fetchAVPLinks({ recsId : this.recordId })
        .then(result => {
            if(result){
                if(result.usrList){
                    this.showpillsUser=true;
                    let userNames = [];
                    let userIds = [];
                    result.usrList.forEach(function(el){
                        userNames.push(el.Name);
                        userIds.push(el.Id);
                    });
                    this.userList = userIds;
                    this.userLinkList = userNames;
                }
                if(result.accList){
                    this.showpillAcc=true;
                    let accNames = [];
                    let accIds = [];
                    result.accList.forEach(function(el){
                        accNames.push(el.Name);
                        accIds.push(el.Id);
                    });
                    this.accList = accIds;
                    this.accLinkList = accNames;
                }
                if(result.oppList){
                    this.showpillOpp=true;
                    let oppNames = [];
                    let oppIds = [];
                    result.oppList.forEach(function(el){
                        oppNames.push(el.Name);
                        oppIds.push(el.Id);
                    });
                    this.oppList = oppIds;
                    this.oppLinkList = oppNames;
                }
            }
            

        })
        .catch(error => {
            console.log("Error>>>>"+JSON.stringify(error));
        });

    }

    showToast() {
        const event = new ShowToastEvent({
            title: 'Response Updated',
            message:
                ' Thank you for your response ',
            variant : 'Success'
        });
        this.dispatchEvent(event);
    }

    handleOtherTransformTeam(event){
        if(event.detail.value === 'Other'){
            this.otherTransformTeam = true;
        }
        else{
            this.otherTransformTeam = false;
        }
    }

    handleOtherEventType(event){
        if(event.detail.value === 'Other'){
            this.otherEventType = true;
        }
        else{
            this.otherEventType = false;
        }
    }

    handleOtherHostedBy(event){
        if(event.detail.value === 'Other'){
            this.otherHostedBy = true;
        }
        else{
            this.otherHostedBy = false;
        }
    }

    handleDiscussion(event){
        if(event.target.value == true){
            this.isDiscussion = true;
        }else{
            this.isDiscussion = false;
        }
    }

    handleSuccess(event) {
        setInterval(() => {
            this.loaded = true;
          }, 3000);
        console.log('Record Id>>>'+event.detail.id);
        this.TransformationRecordId = event.detail.id;
        const acList = (JSON.stringify(this.accList));
        const opList = (JSON.stringify(this.oppList));
        const usList = (JSON.stringify(this.userList));
        AccountAndOpportunityLinks({ accountIds : acList, opportunityIds : opList, userIds : usList  , recId : this.recordId })
            .then(result => {
                
                
            })
            .catch(error => {
                console.log("Result>>>"+JSON.stringify(this.transformationSpeaker));
                console.log("Error>>>>"+JSON.stringify(error));
            });

            this.accLinkList = [];
            this.oppLinkList = [];
            this.userLinkList = [];
            this.accList = [];
            this.oppList = [];
            this.userList = [];
            this.loaded = false;
            this.showToast();
            this.dispatchEvent(new CloseActionScreenEvent());
            

    }

    
    handleError(event){
        console.log('error>>>'+JSON.stringify(event.detail));
    }

    handleRemoveAcc(event){
        const pillIndex = event.detail.index ? event.detail.index : event.detail.name;
        
        const itempill = this.accLinkList;
        itempill.splice(pillIndex, 1);       
        this.accLinkList = [...itempill];
        const itempill1 = this.accList.sort();
        itempill1.splice(pillIndex, 1);       
        this.accList = [...itempill1];

        const opList = (JSON.stringify(this.oppList.sort()));
        const acList = (JSON.stringify(this.accList.sort()));
        OpportunityNames({ opportunityIds : opList , accountIds : acList })
            .then(result => {
                this.oppLinkList = result;
                this.template.querySelector('lightning-input-field[data-name="opportunities"]').value = null;
                
            })
            .catch(error => {
                //console.log("Result>>>"+JSON.stringify(this.transformationSpeaker));
                console.log("Error>>>>"+JSON.stringify(error));
            });

            opportunityRemovedNames({ opportunityIds : opList , accountIds : acList })
            .then(result => {
                console.log('>>>>>>Result'+JSON.stringify(result))
                let res = [];
                res = result;
                for(let i = 0;i<res.length;i++){
                    console.log(res[i].Id);
                    var idopp = this.oppList.indexOf(res[i].Id);
                    //this.oppList.remove(opp.id);
                    const itemopp = this.oppList.sort();
                    itemopp.splice(idopp, 1);       
                    this.oppList = [...itemopp];
                    console.log('>>>Updated_Opp_List'+this.oppList)
                
                    //const removedopp = this.oppList.splice(id,  1);
                }
                this.template.querySelector('lightning-input-field[data-name="opportunities"]').value = null;
               
            })
            .catch(error => {
                //console.log("Result>>>"+JSON.stringify(this.transformationSpeaker));
                console.log('Error>>>'+error);
            });



    }

    handleRemoveOpp(event){
        const pillIndex = event.detail.index ? event.detail.index : event.detail.name;
        
        const itempill = this.oppLinkList;
        itempill.splice(pillIndex, 1);       
        this.oppLinkList = [...itempill];
        const itempill1 = this.oppList.sort();
        itempill1.splice(pillIndex, 1);       
        this.oppList = [...itempill1];
        
    }

    handleRemoveUser(event){
        const pillIndex = event.detail.index ? event.detail.index : event.detail.name;
        
        const itempill = this.userLinkList;
        itempill.splice(pillIndex, 1);       
        this.userLinkList = [...itempill];
        let itemUserIds = [];
        this.userList.forEach(function(el,index){
            if(index != pillIndex){
                itemUserIds.push(el);
            }
        });
        const itempill1 = this.userList.sort();
        itempill1.splice(pillIndex, 1);       
        this.userList = [...itempill1];
        
    }

    handleAccounts(event){
        if((event.detail.value).length > 0){
            if(!this.accList.includes(event.detail.value[0])){
                this.accList.push(event.detail.value[0]);
            }
        }
        this.showpillAcc = true;
        const acList = (JSON.stringify(this.accList.sort()));
        AccountNames({ accountIds : acList })
            .then(result => {
                
                
                this.accLinkList = result;
                this.template.querySelector('lightning-input-field[data-name="accounts"]').value = null;
                
                
            })
            .catch(error => {
                //console.log("Result>>>"+JSON.stringify(this.transformationSpeaker));
                console.log("Error>>>>"+JSON.stringify(error));
            });
    }

    handleOpportunities(event){
        if((event.detail.value).length > 0){
            if(!this.oppList.includes(event.detail.value[0])){
                this.oppList.push(event.detail.value[0]);
            }
        }
        this.showpillOpp = true;
        const opList = (JSON.stringify(this.oppList.sort()));
        const acList = (JSON.stringify(this.accList.sort()));
        OpportunityNames({opportunityIds : opList , accountIds : acList})
            .then(result => {
                if(this.oppLinkList.length == result.length){
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message:
                            'Pleases select the opportunity associated with selected accounts',
                        variant : 'Error'
                    });
                    this.dispatchEvent(event);
                }
                this.oppLinkList = result;
                this.template.querySelector('lightning-input-field[data-name="opportunities"]').value = null;
            })
            .catch(error => {
                //console.log("Result>>>"+JSON.stringify(this.transformationSpeaker));
                console.log("Error>>>>"+JSON.stringify(error));
            });

    }

    handleUsers(event){
        if((event.detail.value).length > 0){
            if(!this.userList.includes(event.detail.value[0])){
                this.userList.push(event.detail.value[0]);
            }
            
        }
        this.showpillsUser = true;
        const usList = (JSON.stringify(this.userList.sort()));
        UserNames({ userIds : usList })
            .then(result => {
                
                
                this.userLinkList = result;
                this.template.querySelector('lightning-input-field[data-name="avps"]').value = null;
                
                
            })
            .catch(error => {
                //console.log("Result>>>"+JSON.stringify(this.transformationSpeaker));
                console.log("Error>>>>"+JSON.stringify(error));
            });
        
    }
}
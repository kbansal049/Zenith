import { LightningElement, api,track,wire } from 'lwc';
import AccountAndOpportunityLinks from '@salesforce/apex/AssociatedAccountAndOpportunityLinks.AccountsAndOpportunityLink';
import AccountNames from '@salesforce/apex/AssociatedAccountAndOpportunityLinks.accountNames';
import OpportunityNames from '@salesforce/apex/AssociatedAccountAndOpportunityLinks.opportunityNames';
import opportunityRemovedNames from '@salesforce/apex/AssociatedAccountAndOpportunityLinks.opportunityRemovedNames';
import UserNames from '@salesforce/apex/AssociatedAccountAndOpportunityLinks.userNames';
import Transformation_Object from "@salesforce/schema/Transformation_Team_Speaker_Request__c";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TransformationTeamSpeakerRequestComponent extends LightningElement {
    @track accList = [];
    oppList = [];
    userList = [];
    TransformationRecordId;
    loaded = true;
    accLinkList = [];
    oppLinkList = [];
    userLinkList = [];
    oppRemoveIdList = [];
    showpillAcc = false;
    showpillOpp = false;
    showpillsUser = false;
    @track otherTransformTeam = false;
    @track otherEventType = false;
    @track otherHostedBy = false;
    @track isDiscussion = false;
    @api recordId;

    @wire(getObjectInfo, { objectApiName: Transformation_Object })
    getObjectData({data,error}){
        if(data){
            console.log('data.recordTypeInfos--'+JSON.stringify(data.recordTypeInfos));
        }
    };

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
        window.open('/lightning/r/Transformation_Team_Speaker_Request__c/'+event.detail.id+'/view');
        AccountAndOpportunityLinks({ accountIds : acList, opportunityIds : opList, userIds : usList  , recId : event.detail.id })
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
            this.showpillsUser = false;
            this.isDiscussion = false;
            

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

        if(this.userList.length == 0){
            this.showpillsUser = false;
        }
        
    }

    handleAccounts(event){
        let elementPresent = false;
        for (let i = 0; i < (this.accList).length; i++) {
        var innerArrayLength = this.accList[i].length;
        for (let j = 0; j < innerArrayLength; j++) {
            if(this.accList[i][j] == event.detail.value){
                elementPresent = true;
            }
        }
        }
        if((event.detail.value).length > 0 && !elementPresent){
        this.accList.push(event.detail.value);
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
        // let elementPresent = false;
        // for (let i = 0; i < (this.oppList).length; i++) {
        // var innerArrayLength = this.oppList[i].length;
        // for (let j = 0; j < innerArrayLength; j++) {
        //     if(this.oppList[i][j] == event.detail.value){
        //         elementPresent = true;
        //     }
        // }
        // }
        // if((event.detail.value).length > 0 && !elementPresent){
        //     this.oppList.push(event.detail.value);
        //     }
        let elementPresent = false;
        if((event.detail.value).length > 0){
            for(let i = 0; this.oppList.length>i;i++){
                if(this.oppList[i] == event.detail.value[0]){
                    elementPresent = true;
                }
            }
            if(!elementPresent){
                this.oppList.push(event.detail.value[0]);
            }
        }
        console.log('Event value>>'+event.detail.value[0]);
        console.log('Opp List>>>'+this.oppList);
        console.log('Test Include>>>'+!this.oppList.includes(event.detail.value[0]));
        this.showpillOpp = true;
        const opList = (JSON.stringify(this.oppList.sort()));
        const acList = (JSON.stringify(this.accList.sort()));
        OpportunityNames({ opportunityIds : opList , accountIds : acList })
            .then(result => {
                console.log('Result>>>>'+JSON.stringify(result));
                if(this.oppLinkList.length == result.length && !elementPresent ){
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
        
        let elementPresent = false;
        for (let i = 0; i < (this.userList).length; i++) {
        var innerArrayLength = this.userList[i].length;
        for (let j = 0; j < innerArrayLength; j++) {
            if(this.userList[i][j] == event.detail.value){
                elementPresent = true;
            }
        }
        }
        
        //this.userList = (this.userList.join("','") + "'");

        if((event.detail.value).length > 0 && !elementPresent){
        this.userList.push(event.detail.value);
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

    showToast() {
        const event = new ShowToastEvent({
            title: 'Record Created',
            message:
                'ID: '+this.TransformationRecordId,
            variant : 'Success'
        });
        this.dispatchEvent(event);
    }
}
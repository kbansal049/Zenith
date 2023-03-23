import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import def1 from '@salesforce/resourceUrl/Defcon1';
import def2 from '@salesforce/resourceUrl/Defcon2';
import def3 from '@salesforce/resourceUrl/Defcon3';
import def4 from '@salesforce/resourceUrl/Defcon4';
import def5 from '@salesforce/resourceUrl/Defcon5';
import getCurrentDefcon from '@salesforce/apex/CaseDefconEscalationController.getCurrentDefcon';
//import escalateCaseCSM from '@salesforce/apex/CaseDefconEscalationController.escalateCaseForCSM';

export default class CaseDefconEscalationLWC extends LightningElement {
    @track modalOpen = false;
    @api recordId;
    @track showSpinner = false;
    @track caseRecord = {};
    @track currDefTemp = '';
    @track defconSource = '';
    @track currentDefconLevel = '';
    @track alreadyEscalated = '';
    @track levelCss = '';
    @track showFields = false;
    @track isEscalated = false;
    @track defconCaseId = '';
    @track defconCaseNumber = '';
    @track defconCaseSubject = '';
    @track defconCaseLink = '';

    /*@wire(getCurrentDefcon, { caseId: '$recordId' })
    currentDefconLevel;*/

    connectedCallback() {
        console.log('RecordId : '+this.recordId);
        getCurrentDefcon({ caseId: this.recordId })
        .then(result => {
            console.log('Its a success --->'+JSON.stringify(result));
            this.currentDefconLevel = result.defconLevel;
            console.log('Special User:'+result.defconLevel);
            
            if(result.defconLevel != undefined && result.defconLevel != ''){
                this.isEscalated = true;
                this.showFields = true;
                /*if(result.escalationNotes != ''){
                    this.showFields = true;
                }*/
                if(result.defconId != undefined && result.defconId != '') {
                    this.defconCaseId = result.defconId;
                    this.defconCaseNumber = result.defconNumber;
                    this.defconCaseSubject = result.defconSubject;
                    this.defconCaseLink = '/'+result.defconId;
                }
                if(this.currentDefconLevel == '1'){
                    this.defconSource = def1;
                }
                else if(this.currentDefconLevel == '2'){
                    this.defconSource = def2;
                }
                else if(this.currentDefconLevel == '3'){
                    this.defconSource = def3;
                }
                else if(this.currentDefconLevel == '4'){
                    this.defconSource = def4;
                }
                else if(this.currentDefconLevel == '5'){
                    this.defconSource = def5;
                }
            }
            else{
                this.isEscalated = false;
            }
            
        })
        .catch(error => {
             console.log('Its a Error --->'+error);
        });
    }

    /*openModal(){
        if(this.isSpecialUser == true){
            this.showSpinner = true;
            this.modalOpen = true;
            this.alreadyEscalated = false;
        }else{
            this.alreadyEscalated = true;
            const evt = new ShowToastEvent({
                message: 'You do not have access to escalate this case further!',
                variant: 'warning'
            });
            this.dispatchEvent(evt);
        }
        /*if(this.currentDefconLevel == '3' || this.currentDefconLevel == '2' || this.currentDefconLevel == '1'){
            if(this.currentDefconLevel == '3' && this.isSpecialUser == true){
                this.showSpinner = true;
                this.modalOpen = true;
                this.alreadyEscalated = false;
            }
            else{
                this.alreadyEscalated = true;
                const evt = new ShowToastEvent({
                    message: 'You do not have access to escalate this case further!',
                    variant: 'warning'
                });
                this.dispatchEvent(evt);
            }
        }else{
            this.showSpinner = true;
            this.modalOpen = true;
            this.alreadyEscalated = false;
        }//Comment was ending here
    }*/

    closeModal(){
        this.modalOpen = false;
    }

    /*escalateCase(){
        this.showSpinner = true
        this.template.querySelector('lightning-record-edit-form').submit();
    }

    handleSubmit(event){
        this.showSpinner = true;
        console.log('Handle Submit Called');
        event.preventDefault();
        const fields = event.detail.fields;
        console.log('Fields--->'+fields);
        console.log('Escalation category-->'+fields['Escalation_Category__c']);
        console.log('Escalation notes-->'+fields['Escalation_Notes__c']);
        escalateCaseCSM({ escalationCategory: fields['Escalation_Category__c'], escalationNotes:fields['Escalation_Notes__c'], caseId: this.recordId, defconLevel:  ''})
        .then(result => {
            if(result != 'FAILED'){
                console.log('Its a success for escalate case --->'+result);
                if(result == '4'){
                    this.defconSource = def4;
                }
                else if(result == '3'){
                    this.defconSource = def3;
                }
                else if(result == '2'){
                    this.defconSource = def2;
                }
                else if(result == '1'){
                    this.defconSource = def1;
                }
                else if(result == '5'){
                    this.defconSource = def5;
                }
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: 'Case is been escalated successfully!',
                    variant: 'success'
                });
                this.dispatchEvent(evt);
                this.currentDefconLevel = result;
                this.modalOpen = false;
                this.showSpinner = false;
                this.isEscalated = true;
                this.showFields = true;
                this.isSpecialUser = false;
                eval("$A.get('e.force:refreshView').fire();");
            }
            
        })
        .catch(error => {
             console.log('Its a Error --->'+error);
        });
        
    }
    handleSuccess(){
        const evt = new ShowToastEvent({
            title: 'Success',
            message: 'Case is been escalated successfully!',
            variant: 'success'
        });
        this.dispatchEvent(evt);
        this.currentDefconLevel = this.currDefTemp;
        this.modalOpen = false;
        this.showSpinner = false;
    }*/

    onFormLoad(){
        this.showSpinner = false;
    }
}
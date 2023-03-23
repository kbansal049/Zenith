import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';
import { refreshApex } from '@salesforce/apex';
import { CurrentPageReference } from 'lightning/navigation';
import issueNotResolved from '@salesforce/apex/CaseEscalationController_LWC.issueNotResolved';
import issueResolved from '@salesforce/apex/CaseEscalationController_LWC.issueResolved';
import getDefconLevel from '@salesforce/apex/CaseEscalationController_LWC.getDefconLevel';

const casefieldstoQuery = ['Case.Status', 'Case.Subject', 'Case.IsEscalated', 'Case.CaseNumber', 'Case.ClosedDate', 'Case.IsClosed', 'Case.Resolution_State__c', 'Case.Defcon_Level__c'];

export default class CaseDetailHeaderComponent extends LightningElement {
    @track showResolvedButtons = false;
    @api recordId;
    @track showclosedetails = false;
    @track isClosed = false;
    @track statuscss;
    @track caseSubject;
    @track caseHeader;
    @track caseStatus;
    @track escalatedCase;
    @track escalateVisible;
    @track defconLevel='';
    @track showUpdatePriority = true;
    wiredResult
    //wireDefconResult
    @wire(CurrentPageReference) pageRef
    
    @wire(getRecord, { recordId: '$recordId', fields: casefieldstoQuery })
    wireCase(results) {
        this.wiredResult = results;
        console.log('Wire Result '+ JSON.stringify(this.wiredResult));
        if (results.error) {
            let message = 'Unknown error';
            if (Array.isArray(results.error.body)) {
                message = results.error.body.map(e => e.message).join(', ');
            } else if (typeof results.error.body.message === 'string') {
                message = results.error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading Case Details',
                    message: '' + message,
                    variant: 'error',
                }),
            );
        } else if (results.data) {
            let todaydate = new Date();
            let relativedate = this.addDays(todaydate, -15);
            let casecloseddate = new Date(results.data.fields.ClosedDate.value);
            if ((results.data.fields.IsClosed.value || results.data.fields.Status.value == 'Customer Close Request') && casecloseddate && casecloseddate >= relativedate) {
                this.showclosedetails = true;
            }else{
                this.showclosedetails = false;
            }
            if ((results.data.fields.IsClosed.value || results.data.fields.Status.value == 'Customer Close Request')) {
                this.isClosed = true;
            }else{
                this.isClosed = false;
            }
            this.caseHeader = 'Case: ' + results.data.fields.CaseNumber.value;
            this.caseSubject = results.data.fields.Subject.value;
            this.caseStatus = results.data.fields.Status.value;
            this.escalatedCase = results.data.fields.IsEscalated.value;
            if ((results.data.fields.IsClosed.value || results.data.fields.Status.value == 'Customer Close Request')) {
                this.statuscss = 'zs-closed-status';
            } else if (results.data.fields.Status.value == 'Pending Customer' || results.data.fields.Status.value == 'Pending Fix Verification') {
                this.statuscss = 'zs-pending-status';
            } else {
                this.statuscss = 'zs-open-status';
            }
            //TTC TTR Project Start--Added by Chetan
            console.log('Anup Resolution State-->'+results.data.fields.Resolution_State__c.value);
            if (results.data.fields.Status.value == 'Pending Customer' && (results.data.fields.Resolution_State__c.value == 'Resolved' || results.data.fields.Resolution_State__c.value =='Workaround Provided')) {
                console.log('Anup Condition Met');
                this.showResolvedButtons = true;
            }
            //TTC TTR Project End--Added by Chetan
        }
    }

    get escalateTagVisibleDefcon5() {
        if(this.defconLevel == '5') {
            return true;
        }
        else {
            return false;
        }
    }

    get displayEscalateButton() {
        if(this.defconLevel == '' || this.defconLevel == '5') {
            return true;
        }
        else {
            return false;
        }
    }

    get escalateTagVisibleDefconOthers() {
        if(this.defconLevel != '' && this.defconLevel != '5') {
            return true;
        }
        else {
            return false;
        }
    }//escalateTagVisibleDefconOthers ends here

    escalateCase() {
        this.template.querySelector('c-customer-escalation-l-w-c').showModal();
    }
    closeCase() {
        this.template.querySelector('c-case-close-customer-component').showModal();
    }
    reOpenCase() {
        this.template.querySelector('c-customer-case-reopen-component').showModal();
    }
    updatePriority(){
        this.template.querySelector('c-customer-priority-update-component-l-w-c').showModal();
    }
    connectedCallback() {
        this.defconLevel = '';
        // subscribe to inputChangeEvent event
        this.getDefconDetailsHandler();
        registerListener('customerupdatedcase', this.refreshdata, this);
    }
    disconnectedCallback() {
        // unsubscribe from inputChangeEvent event
        unregisterAllListeners(this);
    }
    refreshdata() {
        eval("$A.get('e.force:refreshView').fire();");
        return refreshApex(this.wiredResult);
    }
    
    addDays(date, days) {
        var result = new Date(date);
        result.setDate(result.getDate() + days);
        return result;
    }
    //TTC TTR Project Start--Added by Chetan
    helpNeeded(){
        console.log('Help Needed Called');
        //this.showResolvedButtons = false;
        console.log('Case Id -->'+this.recordId);
        this.template.querySelector('c-need-help-comment-l-w-c').showModal();
        /*issueNotResolved({ recId: this.recordId})
        .then((result) => {
            if (result == 'Success') {
                
                refreshdata();
            }
        })
        .catch((error) => {
              console.log('Some Error Occured');  
        });*/
    }

    issueResolved(){
        console.log('Issue Resolved Called');
        this.showResolvedButtons = false;
        issueResolved({ recId: this.recordId})
        .then((result) => {
            if (result == 'Success') {
                console.log('Customer Close Request Called');
                refreshApex(this.wiredResult);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success!!',
                        variant: 'success'
                    })
                );
            }
        })
        .catch((error) => {
            console.log('Error'+ error);
              console.log('Some Error Occured');
        });
    }

    handlehelpneededvaluechange(event){
        this.showResolvedButtons=event.detail;
    }
    //TTC TTR Project End--Added by Chetan

    getDefconDetailsHandler() {
        getDefconLevel({ recId:this.recordId })
        .then((result) => {
            console.log('Wire Result defcon '+ JSON.stringify(result)); 
            this.defconLevel = result.defconLevel;
            if (result.defconLevel == '5' || result.isEscalated == false) {
                this.escalateVisible = true;
                console.log('Escalate Visible '+this.escalateVisible);
            }else{
                console.log('Escalated else')
                this.escalateVisible = false;
            }
        })
        .catch((error) => {
            let message = 'Unknown error';
            if (Array.isArray(results.error.body)) {
                message = results.error.body.map(e => e.message).join(', ');
            } else if (typeof results.error.body.message === 'string') {
                message = results.error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading Case Details',
                    message: '' + message,
                    variant: 'error',
                }),
            );
        });
    }
}
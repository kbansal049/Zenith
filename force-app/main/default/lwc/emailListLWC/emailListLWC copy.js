import { LightningElement, track, wire, api } from 'lwc';
import retriveCase from '@salesforce/apex/CaseDetailLWCController.fetchCase';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import addContact from '@salesforce/apex/CaseDetailLWCController.addContact';
import EMAIL_FIELD from '@salesforce/schema/Contact.Email';
import ID_FIELD from '@salesforce/schema/Contact.Id';
import retriveEmailList from '@salesforce/apex/CaseDetailLWCController.fetchEmailList';
import updateContactDetails from '@salesforce/apex/CaseDetailLWCController.updateContact';
import deleteContactDetails from '@salesforce/apex/CaseDetailLWCController.deleteContact';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import { refreshApex } from '@salesforce/apex';

export default class emailListLWC extends LightningElement {
    @track caseId;
    @track caseData;
    @track contactData;
    @track emailList;
    @track contactId;
    @track error;
    @track loading = true;
    @track data;
    @track showLoadingSpinner = false;
    @track email;
    @track errormsg = '';
    emailRefreshData;
    @track openmodel = false;
    @track addMode = false;
    @track editMode = false;
    @track showcommentmandatorymessage = false;
    @track zsValue;
    @track ctRecord = {
        Email: EMAIL_FIELD,
        Id: ID_FIELD,
    };
    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    objectInfo;

    @wire(retriveCase, { strObjectName: '$caseId' })
    cases({ data, error }) {
        if (data) {
         
            this.caseData = data;
            if(this.caseData[0].Account)
            this.zsValue = this.caseData[0].Account.Id;
            this.error = undefined;
        }
        else if (error) {
            this.caseData = undefined;
            this.error = error;
        }
    }

    @wire(retriveEmailList, { csId: '$caseId' })
    emailListData(value) {
        this.emailRefreshData = value;
        const { data, error } = value;
        if (data) {
            this.emailList = data;
            this.error = undefined;
            this.loading = false;
        }
        else if (error) {
            this.emailList = undefined;
            this.error = error;
            this.loading = false;
        }
    }

    handleContactSave(event) {
        this.errormsg = '';
        this.showcommentmandatorymessage = false;
        if(!this.ctRecord.Email){
            this.errormsg = 'Please enter an email.';
            this.showcommentmandatorymessage = true;
            return;
        }
        if(this.errormsg){
            return;
        }
        this.loading = true;
        if (this.addMode) {
            this.ctRecord.Id = null;
            addContact({ email: this.ctRecord.Email, caseId: this.caseId })
                .then(result => {
                    console.log('Result '+result);
                    if(result){
                        this.ctRecord = {};
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Success!!',
                            message: 'Contact Created Successfully!!',
                            variant: 'success'
                        }));
                        this.loading = false;
                        refreshApex(this.emailRefreshData);
                    }
                    else{
                        this.errormsg='Please enter valid Zscaler email.';
                        this.showcommentmandatorymessage = true;
                        this.loading = false;
                        return;
                    }
                })
                .catch(error => {
                    this.error = error.message;
                    this.openmodel = false;
                });
        }
        if (this.editMode) {
            this.ctRecord.Id = this.contactId;
            this.loading = true;
            updateContactDetails({ objCt: this.ctRecord, caseId: this.caseId })
                .then(result => {
                    this.ctRecord = {};
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success!!',
                        message: 'Contact Updated Successfully!!',
                        variant: 'success'
                    }));
                    this.openmodel = false;
                    this.loading = false;
                    refreshApex(this.emailRefreshData);
                })
                .catch(error => {
                    this.error = error.message;
                    this.openmodel = false
                });
        }
    }
    handleEditEmail(event) {
        this.ctRecord.Email = event.currentTarget.dataset.email;
        this.contactId = event.currentTarget.dataset.contactid;
        this.addMode = false;
        this.editMode = true;
        this.openmodel = true;
    }
    handleEmailChange(event){
        this.ctRecord.Email = event.target.value;
    }
    handleDeleteEmail(event) {
        this.contactId = event.currentTarget.dataset.contactid;
        this.loading = true;
        deleteContactDetails({ objCtId: this.contactId, caseId: this.caseId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Email deleted',
                        variant: 'success'
                    })
                );
                refreshApex(this.emailRefreshData);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting Case team member',
                        message: '' + error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
    
    openmodal() {
        this.ctRecord = {};
        this.addMode = true;
        this.editMode = false;
        this.openmodel = true;
    }
    closeModal() {
        this.addMode = false;
        this.editMode = false;
        this.openmodel = false;
        this.errormsg = '';
        this.showcommentmandatorymessage = false;
    }
    connectedCallback() {
        var str = window.location.href;
        var extracted = str.split("/").find(function (v) {
            return v.indexOf("500") > -1;
        });
        this.caseId = extracted;
    }
}
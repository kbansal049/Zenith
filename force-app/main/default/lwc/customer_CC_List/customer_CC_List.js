import { LightningElement, track, wire, api } from 'lwc';
import getDomainstoExcludeList from '@salesforce/apex/CaseDetailLWCController.getDomains';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import retriveEmailList from '@salesforce/apex/CaseDetailLWCController.getCustomerCCList';
import updateCustomerCCList from '@salesforce/apex/CaseDetailLWCController.updateCustomerCCList';
import { refreshApex } from '@salesforce/apex';

export default class customer_CC_List extends LightningElement {
    @track caseId;
    @track emailList;
    @track error;
    @track loading = true;
    @track errormsg = '';
    emailRefreshData;
    @track openmodel = false;
    @track addMode = false;
    @track editMode = false;
    @track showcommentmandatorymessage = false;
    @track blockedemails = [];
    @track customercclist;
    originalcustomercclist;

    @wire(getDomainstoExcludeList)
    domainstoExclude({ data, error }) {
        if (data) {
            this.blockedemails = data;
            this.error = undefined;
        }
        else if (error) {
            this.blockedemails = undefined;
            this.error = error;
        }
    }
    @wire(retriveEmailList, { strObjectName: '$caseId' })
    emailListData(value) {
        this.emailRefreshData = value;
        const { data, error } = value;
        if (data) {
            this.emailList = data;
            this.customercclist = data.join(';');
            this.originalcustomercclist = data.join(';');
            this.error = undefined;
            this.loading = false;
        }
        else if (error) {
            this.emailList = undefined;
            this.error = error;
            this.loading = false;
            console.log('error:-' + JSON.stringify(this.error));
        }
    }
    handleEmailChange(event) {
        this.errormsg = '';
        let reg = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,})$/;
        this.customercclist = event.target.value.split(" ").join("");
        let cclst = event.target.value.split(" ").join("").split(';');
        let countofsc = (this.customercclist.match(/;/g) || []).length;
        let countofattherate = (this.customercclist.match(/@/g) || []).length;
        if (!(countofsc == countofattherate || countofattherate == countofsc + 1)) {
            this.errormsg = 'Please seperate the emails by semi-colon';
            return;
        }
        for (let em1 in cclst) {
            let em = cclst[em1];
            if (em) {
                if (reg.test(em)) {
                    let publicemail = false;
                    let domain = em.indexOf('@') != -1 ? em.split('@')[1] : '';
                    if (domain && this.blockedemails.includes(domain)) {
                        this.errormsg = 'Public Email domains cannot be entered';
                        this.showcommentmandatorymessage = true;
                        publicemail = true;
                    }
                } else {
                    this.errormsg = 'Invalid Email';
                    this.showcommentmandatorymessage = true;
                }
            }
        }
        if (!this.errormsg) {
            this.errormsg = '';
            this.showcommentmandatorymessage = false;
        }
    }

    handleContactSave(event) {
        if (this.errormsg) {
            return;
        }
        this.loading = true;
        if (this.customercclist && this.customercclist[this.customercclist.length - 1] != ';') {
            this.customercclist += ';';
        }
        updateCustomerCCList({ caseId: this.caseId, custcclist: this.customercclist })
            .then(result => {
                // Clear the user enter values
                window.console.log('result ===> ' + result);
                // Show success messsage
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!!',
                    message: 'Collaborators Updated Successfully!!',
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

    openmodal() {
        this.openmodel = true;
    }
    closeModal() {
        this.openmodel = false;
        this.customercclist = this.originalcustomercclist;
    }
    connectedCallback() {
        var str = window.location.href;
        var extracted = str.split("/").find(function (v) {
            return v.indexOf("500") > -1;
        });
        this.caseId = extracted;
    }
}
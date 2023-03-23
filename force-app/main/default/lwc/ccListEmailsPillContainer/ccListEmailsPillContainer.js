import { api, LightningElement, wire, track } from 'lwc';
import getDomainstoExcludeList from '@salesforce/apex/CaseDetailLWCController.getDomains';

export default class Basic extends LightningElement {
    @api caseId;
    @api customerCCList;
    blockedemails = [];
    @api listOfEmails = [];
    @api listOfAttendeesEmails = [];
    errormsg = '';
    showErrorMessage=false;
    @track emailAddressList = [];

    connectedCallback(){
        if(this.customerCCList){
            console.log('Splitted Customer CC List-->'+this.customerCCList.split(";"));
            let splittedEmails = this.customerCCList.split(";");
            for(let i=0; i<splittedEmails.length; i++){
                if(splittedEmails[i]){
                    this.emailAddressList.push(splittedEmails[i]);
                    this.listOfAttendeesEmails.push(splittedEmails[i]);
                }
            }
            console.log('this.listOfEmails CCB--->'+this.listOfEmails);
        }
    }

    @wire(getDomainstoExcludeList)
    domainstoExclude({ data, error }) {
        if (data) {
            this.blockedemails = data;
            this.error = null;
        }
        else if (error) {
            this.blockedemails = null;
            this.error = error;
        }
    }

    handlePillRemove(event){
        console.log('Remove Pill Called');
        const namePill = event.target.dataset.item;
        console.log('Remove Pill-->'+namePill);
        const emailIndex = this.emailAddressList.indexOf(namePill);
        if (emailIndex > -1) {
            this.emailAddressList.splice(emailIndex, 1);
            this.listOfAttendeesEmails.splice(emailIndex,1);
        }
        console.log('New Email Address List-->'+this.emailAddressList);
    }

    handleEnterPress(event){
        if(event.keyCode === 13){
            //alert('Enter Pressed');
            this.errormsg = '';
            let reg = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,})$/;
            let customerCCListTemp = event.target.value.split(" ").join("");
            let cclst = event.target.value.split(" ").join("").split(';');
            let countofsc = (customerCCListTemp.match(/;/g) || []).length;
            let countofattherate = (customerCCListTemp.match(/@/g) || []).length;
            console.log('customerCCListTemp-->'+customerCCListTemp);
            console.log('cclst-->'+cclst);
            console.log('countofsc-->'+countofsc);
            console.log('countofattherate-->'+countofattherate);
            if (!(countofsc == countofattherate || countofattherate == countofsc + 1)) {
                this.errormsg = 'Please seperate the emails by semi-colon';
                this.showErrorMessage = true;
                return;
            }
            else{
                this.showErrorMessage = false;
            }
            console.log('Blocked Emails--->'+this.blockedemails);
            for (let em1 in cclst) {
                let em = cclst[em1];
                console.log('Email-->'+em);
                if (em) {
                    if (reg.test(em)) {
                        let domain = em.indexOf('@') != -1 ? em.split('@')[1] : '';
                        if (domain && this.blockedemails.includes(domain)) {
                            this.errormsg = 'Public Email domains cannot be entered';
                            this.showErrorMessage = true;
                            return;
                        }
                        
                        if(!this.emailAddressList.includes(em)){
                            this.emailAddressList.push(em);
                            this.template.querySelector("lightning-input").value="";
                            this.listOfAttendeesEmails.push(em);
                        }
                    } else {
                        this.errormsg = 'Invalid Email';
                        this.showErrorMessage = true;
                    }
                }
            }
        }
    }
}
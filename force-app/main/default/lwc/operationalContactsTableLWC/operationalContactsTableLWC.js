import { LightningElement, api, track } from 'lwc';
import getOprContacts from '@salesforce/apex/OperationalContactsTableCtrl.getOperationalContacts';
import verifyContactParentAccount from '@salesforce/apex/OperationalContactsTableCtrl.verifyContactParentAccount';
import markUnmarkContactAsOperational from '@salesforce/apex/OperationalContactsTableCtrl.markUnmarkContactAsOperational';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    {label: 'Name', fieldName: 'NameURL', type: 'url', hideDefaultActions: true,
        typeAttributes: {
            label: {
                fieldName: 'Name'
            },
            target:'_blank'
        }, 
    },
    {label: 'Email', fieldName: 'Email', type: 'email', hideDefaultActions: true},
    {label: '', fieldName:'Unmark', type: 'button', hideDefaultActions: true,
        typeAttributes: {
            iconName: 'utility:unlinked',
            name : 'unmarkAction',
            variant: 'destructive',
            label: 'Unmark',
            title: 'Unmark'
        },
        cellAttributes : {alignment :'center'} 
    },
];

export default class OperationalContactsTableLWC extends LightningElement {
    @api recordId;
    @track contactValue = '';
    @track markOperationalDisabled = true;
    accountId;
    showSpinner = true;
    data;
    columns = COLUMNS;

    get dataExists() {
        if(this.data != undefined && this.data.length > 0) {
            return true;
        }
        else {
            return false;
        }
    }

    connectedCallback() {
        this.init();
    }

    init() {
        this.showSpinner = true;
        this.contactValue = '';
        this.markOperationalDisabled = true;
        if(this.recordId != '') {
            this.getOperationalContactsHandler(this.recordId);
        }
    }

    refreshCall() {
        this.init();
    }

    callRowAction(event) {
        const recId = event.detail.row.Id;
        const row = event.detail.row;
        const actionName = event.detail.action.name;
        if(actionName == 'unmarkAction') {
            this.handleMarkUnmarkOperational(recId,false);
        }
    }

    getOperationalContactsHandler(accId){
        getOprContacts({recordId : accId})
        .then(result => {
            if(result) {
                this.data = result.map(item=>{
                    return {...item, 
                        "NameURL":'/lightning/r/Contact/' +item['Id'] +'/view',
                        "Name" : item.Name,
                        "Email" : item.Email          
                    }
                })
                this.showSpinner = false;
            }
        })
        .catch(error => {
            console.log("##Error : ", error);
        });
    }

    handleContactChange(event) {
        this.markOperationalDisabled = true;
        if(event.target.fieldName == 'ContactId') {
            let contId = event.target.value;
            this.contactValue = contId;
            if(contId != undefined && contId != '') {
                this.verifyContactParentAccountHandler(contId);
            }
        }
    }

    verifyContactParentAccountHandler(contId){
        verifyContactParentAccount({
            recordId : this.recordId,
            contactId : contId
        })
        .then(result => {
            if(result=='Success') {
                this.markOperationalDisabled = false;
            }
            else {
                this.showToast('Error',result);
            }
        })
        .catch(error => {
            console.log("##Error : ", error);
        });
    }

    handleMarkOperational() {
        this.showSpinner = true;
        this.handleMarkUnmarkOperational(this.contactValue,true);
    }
    
    handleMarkUnmarkOperational(contId, oprType) {
        this.showSpinner = true;
        markUnmarkContactAsOperational({
            contactId : contId,
            operationType : oprType
        })
        .then(result => {
            if(result=='Success') {
                if(oprType==true) {
                    this.showToast('Success','Contact marked as Operational Contact!');
                }
                else {
                    this.showToast('Success','Operational Contact has been unmarked successfully!');
                }
                this.init();
                let ev = new CustomEvent('childoprcontact');
                this.dispatchEvent(ev); 
            }
            else {
                this.showToast('Error',result);
            }
        })
        .catch(error => {
            console.log("##Error : ", error);
        });
    }

    // Method to show Toast
    showToast(title, msg) {
        const event = new ShowToastEvent({
            title: title,
            variant : title,
            message: msg
        });
        this.dispatchEvent(event);
    }
}
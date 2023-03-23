import { LightningElement, track, wire, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import getContactWrapperMap from '@salesforce/apex/KeyContactsManagementController.getContactWrapperMap';
import updateKeyContactsInformation from '@salesforce/apex/KeyContactsManagementController.updateKeyContactsInformation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import keyContactsHelpText from '@salesforce/label/c.KeyContactsHelpText';
import keyContactsSuccessMessage from '@salesforce/label/c.KeyContactsSuccessMessage';
import modal from '@salesforce/resourceUrl/screenactionmodal';
import { loadStyle} from 'lightning/platformResourceLoader';
//Setting the constants for headers and key contact wrapper fields
const HEADERS = ["Name", "Title", "Last Validation Date", "Head Of IT", "Head Of Networking", "Head Of Security", "Head Of Architecture", "Validate"];
const KEY_CONTACT_FIELDS = ["headOfIT", "headOfNetworking", "headOfSecurity", "headOfArchitecture"];

export default class KeyContactsManagement extends LightningElement {
    //Account Record Id for screen action
    _recordId;

    //Help Note Text
    helpText = '<b>Direction: </b>'+ keyContactsHelpText;

    //Mapping for the datatable and record manipulation
    headers = HEADERS;
    @track data = [];
    @track items = [];
    @track initialItems = [];
    @track results = {};
    @track filteredContacts = {};
    @track isAccountUpdated = false;
    @track accountRecord = {};
    @track originalAccountRecord = {};
    originalResults;
    existingKeyContactIds = [];
    validatedKeyContactIds = [];
    @track searchString;

    //Mapping for pagination component
    @track currentpgnum = 1;
    @api numofrecords = 20;
    @track recordStartnum;
    @track recordEndnum;
    totalRecords;

    //Mapping for show/hide table and whole page
    @track showData;
    @track noDataFound;
    @track loadPage;

    //Mapping for show/hide spinner
    @track showSpinner = false;

    @api set recordId(value) {
        this._recordId = value;
        this.showSpinner = true;
        //Getting the records as connected callback doesn't get recordId value in screen action
        this.getContactData();
    }

    get recordId() {
        return this._recordId;
    }

    connectedCallback() {
        Promise.all([
             loadStyle(this, modal)
         ]);       
    }

    getContactData() {
        getContactWrapperMap({ recordId: this.recordId })
            .then(result => {
                this.showSpinner = false;
                if (result && Object.keys(result).length != 0) {
                    this.loadPage = true;
                    this.originalResults = JSON.parse(JSON.stringify(result));
                    this.results = result;
                    this.initialItems = Object.values(result);
                    this.items = Object.values(result);
                    this.showTable();
                    this.setExistingKeyContactIds();
                } else {
                    this.loadPage = false;
                    this.hideTable();
                }
            }).catch(error => {
                this.showSpinner = false;
                let errorMessage = error.body 
                    ? error.body.message 
                    : error.message ? error.message : 'Something went wrong' ;
                this.showToastNotification
                    (
                        'Error',
                        errorMessage,
                        'error'
                    );
                this.loadPage = false;
                this.hideTable();
            });
    }

    handleCTMFields(event) {
        let recordId = event.currentTarget.dataset.id;
        let fieldAPIName = event.currentTarget.dataset.key;
        let fieldValue = event.currentTarget.checked;
        //Only for checked record set reset
        if (fieldValue) {
            this.resetFilterContacts(recordId, fieldAPIName);
            this.setAccountData(fieldAPIName, recordId);
        } else {
            if (this.accountRecord[fieldAPIName] == recordId) {
                this.setAccountData(fieldAPIName, null);
            }
        }
        this.filterContacts(recordId, fieldAPIName, fieldValue);
    }

    handleValidate(event) {
        let recordId = event.currentTarget.dataset.id;
        let fieldAPIName = event.currentTarget.dataset.key;
        let fieldValue = event.currentTarget.checked;
        console.log('validate fieldValue--'+fieldValue);
        if (fieldValue) {
            this.validatedKeyContactIds.push(recordId);
        } else {
            this.validatedKeyContactIds.pop(recordId);
        }
        this.filterContacts(recordId, fieldAPIName, fieldValue);
    }

    handleContactSearch(event) {
        let searchKey = event.target.value.toLowerCase();
        if (searchKey) {
            this.items = this.initialItems;
            let searchRecords = [];
            for (let record of this.items) {
                let contactName = record.contactName.toLowerCase();
                if (contactName.includes(searchKey)) {
                    searchRecords.push(record);
                }
            }
            this.items = searchRecords;
            if (searchRecords.length != 0) {
                this.showTable();
            } else {
                this.hideTable();
            }
        } else {
            this.items = this.initialItems;
            this.showTable();
        }
    }

    handleSave() {
        console.log('save method accountRecord--'+JSON.stringify(this.accountRecord));
        console.log('save method originalAccountRecord--'+JSON.stringify(this.originalAccountRecord));
        console.log('save method validatedKeyContactIds--'+JSON.stringify(this.validatedKeyContactIds));
        let accountValues = Object.entries(this.accountRecord).toString();
        let originalAccountValues = Object.entries(this.originalAccountRecord).toString();
        if (accountValues != originalAccountValues 
            || (accountValues == originalAccountValues && this.validatedKeyContactIds.length != 0)
            ) {
            this.isAccountUpdated = accountValues != originalAccountValues ? true : false;
            this.saveKeyContactInformation();
        } else {
            //Show toast notification mentioning there is no update done.
            this.showToastNotification
                (
                    'Warning',
                    'There is no update done on Key Contacts for current account',
                    'warning'
                );
        }
    }

    setExistingKeyContactIds() {
        this.setInitialAccountData();
        let recordLength = this.items.length <= 4 ? this.items.length : 4;
        for (let i = 0; i < recordLength; i++) {
            for (const key of KEY_CONTACT_FIELDS) {
                let currentRecord = this.items[i];
                if (currentRecord[key]) {
                    this.accountRecord[key] = currentRecord.contactId;
                    this.originalAccountRecord[key] = currentRecord.contactId;
                    this.filterContacts(currentRecord.contactId, key, currentRecord[key]);
                    this.existingKeyContactIds.push(currentRecord.contactId);
                }
            }
        }
        console.log('accountRecord--'+JSON.stringify(this.accountRecord));
        console.log('originalAccountRecord--'+JSON.stringify(this.originalAccountRecord));
    }

    setInitialAccountData() {
        this.accountRecord['recordId'] = this.recordId;
        this.originalAccountRecord['recordId'] = this.recordId;
        for (const key of KEY_CONTACT_FIELDS) {
            this.accountRecord[key] = null;
            this.originalAccountRecord[key] = null;
        }
    }

    setAccountData(key, value) {
        this.accountRecord[key] = value;
    }

    filterContacts(recordId, fieldAPIName, fieldValue) {
        let contactRecord;
        if (this.filteredContacts && this.filteredContacts[recordId]) {
            contactRecord = this.filteredContacts[recordId];
            contactRecord[fieldAPIName] = fieldValue;
        } else {
            contactRecord = this.results[recordId];
            contactRecord[fieldAPIName] = fieldValue;
            this.filteredContacts[recordId] = contactRecord;
        }
    }

    resetFilterContacts(recordId, fieldAPIName) {
        if (this.filteredContacts && Object.keys(this.filteredContacts).length != 0) {
            for (const [key, value] of Object.entries(this.filteredContacts)) {
                if (key != recordId) {
                    value[fieldAPIName] = false;
                }
            }
        }
    }

    async saveKeyContactInformation() {
        this.showSpinner = true;
        try {
            let saveResult = await updateKeyContactsInformation
                (
                    {
                        accountData: JSON.stringify(this.accountRecord),
                        validatedContactIds: this.validatedKeyContactIds.length != 0 
                                                ? JSON.stringify(this.validatedKeyContactIds) 
                                                : null,
                        isAccountUpdated: this.isAccountUpdated
                    }
                );
            this.showSpinner = false;
            this.showToastNotification
                (
                    'Success',
                    keyContactsSuccessMessage,
                    'success'
                );
            this.handleCloseScreenAction();
        } catch (error) {
            this.showSpinner = false;
            let errorMessage = error.body 
                    ? error.body.message 
                    : error.message ? error.message : 'Something went wrong' ;
            this.showToastNotification
                (
                    'Error',
                    errorMessage,
                    'error'
                );
        }

    }

    setRecordsForIndex(index) {
        this.recordStartnum = this.items.length < 1 ? this.items.length : (index - 1) * this.numofrecords + 1;
        this.recordEndnum = (index * this.numofrecords) > this.items.length ? this.items.length : (index * this.numofrecords);
        this.totalRecords = this.items.length;
        this.data = this.items.slice((index - 1) * this.numofrecords, (index * this.numofrecords));

    }
    
    handlePageChange(event) {
        this.currentpgnum = event.detail;
        this.setRecordsForIndex(this.currentpgnum);
    }

    showTable() {
        this.showData = true;
        this.noDataFound = false;
        this.currentpgnum = 1;
        this.setRecordsForIndex(this.currentpgnum);
        this.showpagination = this.items.length > this.numofrecords;
    }

    hideTable() {
        this.showData = false;
        this.noDataFound = true;
        this.showpagination = false;
    }

    get setDatatableHeight() {
        if(this.items.length == 0){//set the minimum height
            return 'height:2rem;';
        }
        else if(this.items.length >= 8){//set the max height
                return 'height:15rem;';
        }
        return '';//don't set any height (height will be dynamic)
    }

    showToastNotification(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    handleCloseScreenAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}
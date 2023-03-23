import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getCAPData from '@salesforce/apex/TAMCAPRequestCmpCtrl.getCAPRequestData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    {label: 'CAP Request Name', fieldName: 'NameURL', type: 'url', sortable : true,
        typeAttributes: {
            label: {
                fieldName: 'Name'
            },
            target:'_blank'
        }
    },
    { label: 'CAP Level', fieldName: 'CAP_Level__c', sortable: true },
    { label: 'CAP Manager', fieldName: 'CAP_Manager_Name__c', sortable: true },
    { label: 'Status', fieldName: 'Status__c', sortable: true }
];

export default class tamCAPRequestCmp extends LightningElement {
    
    @api recordId;
    parentId = '';
    @api invokedFromParent = false;
    data = [];
    displaySpinner = true;
    columns = columns;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    @wire(getRecord, { recordId: '$recordId', fields: ['TAM_Engagement__c.Account__c'] })
    wireRecord({data, error}){
        if(data){
            this.parentId = data.fields.Account__c.value
        }
        this.displaySpinner = true;
        this.getCAPDataHandler(this.parentId);
    }

    get isDataPresent() {
        return this.data.length > 0? true : false;
    }
    refreshCall() {
        this.displaySpinner = true;
        this.getCAPDataHandler(this.parentId);
    }


    getCAPDataHandler(accId){
        getCAPData({recordId : accId})
        .then(result => {
            if(result != undefined) {
                this.data = result.map(item=>{
                        return {...item, 
                            "NameURL":'/lightning/r/CAP_Request__c/' +item['Id'] +'/view',
                            "CAP_Level__c" : item.CAP_Level__c,
                            "CAP Manager" : item.CAP_Manager_Name__c,
                            "Status__c" : item.Status__c
                        }     
                });
                this.displaySpinner = false;
            }
        })
        .catch(error => {});
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        let { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
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
    //Utility Methods Ends
}
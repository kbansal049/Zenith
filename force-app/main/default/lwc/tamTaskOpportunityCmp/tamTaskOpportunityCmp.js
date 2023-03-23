import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getTaskData from '@salesforce/apex/TAMTaskOpportunityCmpCtrl.getTaskRequestData';
import getOpportunityData from '@salesforce/apex/TAMTaskOpportunityCmpCtrl.getOpportunityRequestData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    {label: 'Task No.', fieldName: 'NameURL', type: 'url', sortable : true,
        typeAttributes: {
            label: {
                fieldName: 'Subject'
            },
            target:'_blank'
        }
    },
    { label: 'Created Date', fieldName: 'Activity Date', type : 'date' , sortable: true,
        typeAttributes: {
            year: 'numeric',
            month: 'long',
            day: '2-digit'
        },
    },
    { label: 'Task Status', fieldName: 'Status', sortable: true },
    { label: 'Comments', fieldName: 'Description', sortable: true }
];

const provProdcolumns = [
    {label: 'Opportunity No.', fieldName: 'NameURL', type: 'url', sortable : true,
        typeAttributes: {
            label: {
                fieldName: 'Opportunity_Number__c'
            },
            target:'_blank'
        }
    },
    { label: 'Opportunity Name', fieldName: 'Name', sortable: true },
    { label: '3 Whys Link', fieldName: 'X3_Why__c', type: 'text', sortable: true },
    { label: 'Created Date', fieldName: 'CreatedDate', type : 'date' ,sortable: true,
        typeAttributes: {
            year: 'numeric',
            month: 'long',
            day: '2-digit'
        },
    },
];

export default class tamTaskOpportunityCmp extends LightningElement {
    
    @api recordId;
    parentId = '';
    @api invokedFromParent = false;
    dataTask = [];
    dataOpp = [];    
    displaySpinnerTask = true;
    displaySpinnerOpp = true;
    columns = columns;
    provProdcolumns = provProdcolumns;
    defaultSortDirectionTask = 'asc';
    defaultSortDirectionOpp = 'asc';
    sortDirectionTask = 'asc';
    sortDirectionOpp = 'asc';
    sortedByTask;
    sortedByOpp;

    @wire(getRecord, { recordId: '$recordId', fields: ['TAM_Engagement__c.Account__c'] })
    wireRecord({data, error}){
        console.log('recordId-->' , this.recordId);
        console.log('parentId-->' , this.parentId);
        if(data){
            this.parentId = data.fields.Account__c.value
        }
        if(this.recordId != undefined && this.recordId.startsWith('001')) {
            this.parentId = this.recordId;
        }
        this.displaySpinnerTask = true;
        this.displaySpinnerOpp =true;
        this.getTaskDataHandler(this.parentId);
        this.getOpportunityDataHandler(this.parentId);
    }
    get isDataTaskPresent() {
        return this.dataTask.length > 0? true : false;
    }
    get isDataOppPresent() {
        return this.dataOpp.length > 0? true : false;
    }
    refreshCallTask() {
        this.displaySpinnerTask = true;
        this.getTaskDataHandler(this.parentId);
    }
    refreshCallOpp() {
        this.displaySpinnerOpp = true;
        this.getOpportunityDataHandler(this.parentId);
    }

    getTaskDataHandler(accId){
        getTaskData({whatId : accId})
        .then(result => {
            if(result != undefined) {
                this.dataTask = result.map(item=>{
                        return {...item, 
                            "NameURL":'/lightning/r/Task/'+item['Id'] +'/view',
                            "Activity Date" : item.ActivityDate,
                            "Status" : item.Status,
                            "Description" : item.Description
                        }     
                });
                this.displaySpinnerTask = false;
            }
        })
        .catch(error => {});
    }

    getOpportunityDataHandler(accId){
        getOpportunityData({accountId : accId})
        .then(result => {
            if(result != undefined) {
                this.dataOpp = result.map(item=>{
                        return {...item, 
                            "NameURL":'/lightning/r/Opportunity/'+item['Id'] +'/view',
                            "Opportunity Name" : item.Name,
                            "3 Whys Link" : item.X3_Why__c,
                            "Created Date" : item.CreatedDate                            
                        }     
                });
                this.displaySpinnerOpp = false;
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

    onHandleSortTask(event) {
        let { fieldName: sortedByTask, sortDirectionTask } = event.detail;
        const cloneData = [...this.dataTask];
        cloneData.sort(this.sortBy(sortedByTask, sortDirectionTask === 'asc' ? 1 : -1));
        this.dataTask  = cloneData;
        this.sortDirectionTask = sortDirectionTask;
        this.sortedByTask = sortedByTask;
    }

    onHandleSortOpp(event) {
        let { fieldName: sortedByOpp, sortDirectionOpp } = event.detail;
        const cloneData = [...this.dataOpp];
        cloneData.sort(this.sortBy(sortedByOpp, sortDirectionOpp === 'asc' ? 1 : -1));
        this.dataOpp  = cloneData;
        this.sortDirectionOpp = sortDirectionOpp;
        this.sortedByOpp = sortedByOpp;
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
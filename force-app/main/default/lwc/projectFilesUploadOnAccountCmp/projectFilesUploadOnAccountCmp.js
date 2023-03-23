import { LightningElement, api } from 'lwc';

import getFileData from '@salesforce/apex/ProjectFilesUploadOnAccountCtrl.getFileData';


const columns = [
    {label: 'Title', fieldName: 'NameURL', type: 'url', sortable : true,
        typeAttributes: {
            label: {
                fieldName: 'Title'
            },
            target:'_blank'
        }
    },
    { label: 'Owner', fieldName: 'Owner', sortable: true },
    { label: 'File Type', fieldName: 'FileType', sortable: true },
    {
        label: "Created Date",
        fieldName: "CreatedDate",
        type: "date",
        typeAttributes:{
            weekday: "short",
            year: "numeric",
            month: "short",
            day: "2-digit",
            hour: "2-digit",
            minute: "2-digit"
        },sortable : true
    }
];

export default class ProjectFilesUploadOnAccountCmp extends LightningElement {
    
    @api recordId;
    @api fileType;
    data = [];
    displaySpinner = true;
    columns = columns;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    get isDataPresent() {
        return this.data.length > 0? true : false;
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
        if(sortedBy == "NameURL") {
            sortedBy = "Title";
        }
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        if(sortedBy == "Title") {
            sortedBy = "NameURL";
        }
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    connectedCallback() {
        this.getFilesDataHandler();
    }

    
    getFilesDataHandler(){
        getFileData({recordId : this.recordId, fileType : this.fileType})
        .then(result => {
            if(result != undefined) {
                this.data = result.map(item=>{
                    return {...item, 
                        "NameURL":'/lightning/r/ContentDocument/' +item['ContentDocumentId'] +'/view',
                        "Title" : item.ContentDocument.LatestPublishedVersion.Title,
                        "FileType" : item.ContentDocument.FileType,
                        "CreatedDate" : item.ContentDocument.LatestPublishedVersion.CreatedDate,
                        "Owner" : item.ContentDocument.Owner.Name
                    }
                });
                this.displaySpinner = false;
            }
        })
        .catch(error => {});
    }

    handleUploadFinished(event) {
        this.displaySpinner = true;
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        if(uploadedFiles != undefined && uploadedFiles.length >0) {
            this.getFilesDataHandler();
        }
    }
}
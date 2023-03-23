import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import TIME_ZONE  from '@salesforce/i18n/timeZone';
import getFileData from '@salesforce/apex/TAMDocumentUploadCmpCtrl.getFileData';
import updateDocTypeOnFiles from '@salesforce/apex/TAMDocumentUploadCmpCtrl.updateDocTypeOnFiles';
import DeleteAllDoc from "@salesforce/apex/TAMDocumentUploadCmpCtrl.DeleteAllDoc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getListUi } from 'lightning/uiListApi';

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
    /*{ label: 'File Type', fieldName: 'FileType', sortable: true },*/
    { label: 'Document Type', fieldName: 'DocumentType', sortable: true },
    { label: 'Product Type', fieldName: 'ProductType', sortable: true },
    {
        label: "Upload Date",
        fieldName: "CreatedDate",
        type: "date",
        typeAttributes:{
            weekday: "short",
            year: "numeric",
            month: "short",
            day: "2-digit",
            hour: "2-digit",
            minute: "2-digit",
            timeZone: TIME_ZONE
        },sortable : true
    }
];

export default class TamDocumentUploadCmp extends LightningElement {
    
    @api recordId;
    parentId = '';
    @api fileType;
    @api invokedFromParent = false;
    data = [];
    displaySpinner = true;
    columns = columns;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    fileUploadIsDisabled = true;
    deleteFilesDisabled = true;
    productType = '';
    documentType = '';
    timeZone = ''; 

    @wire(getRecord, { recordId: '$recordId', fields: ['TAM_Engagement__c.Account__c'] })
    wireRecord({data, error}){
        if(data){
            this.parentId = data.fields.Account__c.value
        }
    }

    get isDataPresent() {
        return this.data.length > 0? true : false;
    }

    connectedCallback() {
        this.init();
    }

    init() {
        this.displaySpinner = true;
        /*if(this.fileType != undefined && this.fileType != '') {
            this.productType = this.fileType;
        }
        else {
            this.productType = '';
        }*/
        this.productType = '';
        this.documentType = '';
        
        if(this.recordId != '') {
            if(this.recordId.startsWith("001")){
                this.parentId = this.recordId;
            }
            this.getFilesDataHandler(this.recordId);
        }
    }

    refreshCall() {
        this.init();
    }

    getFilesDataHandler(accId){
        getFileData({recordId : accId})
        .then(result => {
            if(result != undefined) {
                this.data = result.map(item=>{
                    return {...item, 
                        "NameURL":'/lightning/r/ContentDocument/' +item['ContentDocumentId'] +'/view',
                        "Title" : item.ContentDocument.LatestPublishedVersion.Title,
                        "FileType" : item.ContentDocument.FileType,
                        "CreatedDate" : item.ContentDocument.LatestPublishedVersion.CreatedDate,
                        "DocumentType" : item.ContentDocument.LatestPublishedVersion.Document_Type_fileupload__c,
                        "ProductType" : item.ContentDocument.LatestPublishedVersion.Project_Product_Type_fileupload__c,
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
            let cvIds = [];
            for(let key in uploadedFiles) {
                cvIds.push(uploadedFiles[key].contentVersionId);
            }
            this.updateDocTypeOnFilesHandler(cvIds);
        }
    }

    handleChange(event) {
        if(event.target.fieldName == 'Project_Product_Type_fileupload__c') {
            this.productType = event.target.value;
        }
        else if(event.target.fieldName == 'Document_Type_fileupload__c') {
            this.documentType = event.target.value;
        }
        if(this.productType != '' && this.productType != undefined && this.documentType != '' && this.documentType != undefined) {
            this.fileUploadIsDisabled = false;
        }
        else {
            this.fileUploadIsDisabled = true;
        }
        if(this.invokedFromParent) {
            if(!this.fileType.includes(this.productType)) {
                this.showToast('Error','This Product Type cannot be selected for this TAM Engagement!');
                this.fileUploadIsDisabled = true;
            }
        }
    }

    DeleteRecords(event){
        var result = confirm("Do you want to delete?");
        if (result) {
            var selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();
            if(selectedRecords.length > 0){        
                let ids = '';
                selectedRecords.forEach(currentItem => {
                    ids = ids + ',' + currentItem.Id;
                });
                this.selectedIds = ids.replace(/^,/, '');
                this.lstSelectedRecords = selectedRecords;
                let docArr = [];
                for(let key in selectedRecords) {
                    if(selectedRecords[key]['ContentDocumentId'] != undefined) {
                        docArr.push(selectedRecords[key]['ContentDocumentId']);
                    }
                }
                DeleteAllDoc({
                    records: docArr
                })
                    .then((result) => {
                        this.showSpinner=true;
                        if(result == 'true'){
                        let msg = "Records deleted succesfully.";
                        this.showToast("Success", msg);
                        this.init();
                        let ev = new CustomEvent('childdocwizard');
                        this.dispatchEvent(ev); 
                        this.refreshCall(); 
                        this.showSpinner = false;
                        }
                    })
                    .catch((error) => {
                        this.refreshCall(); 
                        this.showSpinner = false;
                        console.log("---error--", error);
                        let msg = "Error occured, Please contact administartor.";
                        this.showToast("Error Occured,", msg);
                    });

            }  
        }
    }

    updateDocTypeOnFilesHandler(contentVersionIds) {
        updateDocTypeOnFiles({cvIds : contentVersionIds, docType : this.documentType})
        .then(result => {
            if(result != undefined && result == 'Success') {
                this.showToast('Success','File(s) have been uploaded successfully!');
                this.init();
                let ev = new CustomEvent('childdocwizard');
                this.dispatchEvent(ev); 
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
    handleDeleteButtonDisabled(event) {
        const selectedRows = event.detail.selectedRows;
        if(selectedRows!=null && selectedRows.length > 0) {
            this.deleteFilesDisabled = false;
        }
        else {
            this.deleteFilesDisabled = true;
        }
    }
}
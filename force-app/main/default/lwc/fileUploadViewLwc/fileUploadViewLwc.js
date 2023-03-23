import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getRelatedFiles from '@salesforce/apex/FileUploadViewController.getRelatedFiles';

export default class FileUploadViewLwc extends LightningElement {
    @api label;
    @api formats;
    @api recordId;

    @track files = [];
    @track totalNumberOfFiles = 0;

    //Loading
    @track isLoaded = false;

    //Error handling
    @track hasError;
    @track errMsg;
    @track errDetail;
    @track showDetailError = false;

    get acceptedFormats() {
        return this.formats.split(',');
    }

    /*
    @wire(getRelatedFiles, { recordId: '$recordId' })
    files;
    */


    @wire(getRelatedFiles, { recordId: '$recordId' })
    relatedFilesResult(result) {
        if (result.data) {
            this.isLoaded = true;
            this.files = result;
            this.totalNumberOfFiles = result.data.length;
        } else if (result.error) {
            this.isLoaded = true;
            this.hasError = true;
            this.errMsg = "Error Occurred, kindly contact the administrator.";
            this.errDetail = result.error;
        }
    }

    handleActionFinished(event) {
        //refresh the list of files
        refreshApex(this.files);
    }

    showDetailErrorMessage() {
        this.showDetailError = true;
    }
}
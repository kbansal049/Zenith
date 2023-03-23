import { LightningElement, api, wire, track } from 'lwc';
import getRelatedFiles from '@salesforce/apex/FileUploadViewController.getRelatedFilesForPOD';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import deleteFiles from '@salesforce/apex/FileUploadViewController.deleteFileRecord';
import getDocumentUrl from '@salesforce/apex/FileUploadViewController.getDocumentUrl';
import updateUrlOnRecord from '@salesforce/apex/FileUploadViewController.updateUrlOnPsqRecord';
export default class GenericFileUploadLwc extends NavigationMixin(LightningElement){
    @api formats;
    @api recordId;
    @api heading;

    @track files = [];
    @track Label3WhysLink = '3 Whys';
    @track LabelValuePyramid = 'Value Pyramid';
    @track LabelPOVPlayback = 'POV Playback';
    @track LabelPOVPlan = 'POV Plan';
    @track LabelPOVTestCases = 'POV Test Cases';
    @track LabelServiceProposal = 'Service Proposal';
    @track LabelArchitectureDocument = 'Architecture Document';
    @track LabelBVA = 'BVA';

    @track isLoaded = false;
    @track hasError;
    @track errMsg;
    @track errDetail;
    @track HideComponent = false;
    @track showDetailError = false;
    @track showAttachmentSection = false;
    @track isFileAvailable = false;
    @track fileUploadSource = '';
    @track fileDeleteSource = '';
    @track FileToBeDeleted;
    @track DeleteFileMsg = ''
    @track DeletedFileName='';
    @track showDeleteMsg = false;
    @track showSpinner = false;
    @track fullRecordURL = '';
    @track documentIdOfUploadedFile = '';
    @track isDeleteModal = false;
    @track buttonElementDataId;
    @track mapData = [];
    
    @track WhyLinkMap = {
        Label: this.Label3WhysLink,
        isFilePresent: false,
        file:''
    };
    @track ValuePyramidMap = {
        Label: this.LabelValuePyramid,
        isFilePresent: false,
        file:''
    };
    @track POVPlaybackMap = {
        Label: this.LabelPOVPlayback,
        isFilePresent: false,
        file:''
    };
    @track POVPlanMap = {
        Label: this.LabelPOVPlan,
        isFilePresent: false,
        file:''
    };
    @track POVTestCasesMap = {
        Label: this.LabelPOVTestCases,
        isFilePresent: false,
        file:''
    };
    @track ServiceProposalMap = {
        Label: this.LabelServiceProposal,
        isFilePresent: false,
        file:''
    };
    @track ArchitectureDocumentMap = {
        Label: this.LabelArchitectureDocument,
        isFilePresent: false,
        file:''
    };
    @track BVAMap = {
        Label: this.LabelBVA,
        isFilePresent: false,
        file:''
    };

    @track mapFieldsMaps = {
        '3 Whys': this.WhyLinkMap,
        'Value Pyramid': this.ValuePyramidMap,
        'POV Playback': this.POVPlaybackMap,
        'POV Plan': this.POVPlanMap,
        'POV Test Cases': this.POVTestCasesMap,
        'Service Proposal': this.ServiceProposalMap,
        'Architecture Document': this.ArchitectureDocumentMap,
        'BVA': this.BVAMap,
    };  
    @track listOfFieldsMap =[];
    
    get acceptedFormats() {
        return this.formats.split(',');
    }

    connectedCallback(event){

        try{
            this.getRelatedUploadedFiles();
        }catch(error){
            console.error('inside error:'+error);
        }

        for (let key in this.mapFieldsMaps) {
            this.listOfFieldsMap.push(this.mapFieldsMaps[key]);
          }
    }

   
    handleActionFinished(event){
        this.documentIdOfUploadedFile =  event.detail.files[0].documentId;
        if(this.documentIdOfUploadedFile){
            this.getBaseUrlForDocument(this.documentIdOfUploadedFile);
        }
        if(this.FileToBeDeleted){
            this.deletefun(this.FileToBeDeleted);
        }
        refreshApex(this.files);
        this.showAttachmentSection = false;
        this.getRelatedUploadedFiles(); 
        this.isFileAvailable = true;
        const ToastEvent = new ShowToastEvent({
                title: 'Toast message',
                message: this.fileUploadSource+' document is attached',
                variant: 'success',
                mode: 'dismissable'
            });
        this.dispatchEvent(ToastEvent);
    }

    showDetailErrorMessage(){
        this.showDetailError = true;
    }

    handleButtonClick(event){
        this.showDeleteMsg = false;
        this.showAttachmentSection = true;
        let buttonElementDataId=event.currentTarget.dataset.id;
        switch (buttonElementDataId) {
            case this.Label3WhysLink:
                this.fileUploadSource = this.Label3WhysLink;
                break;
            case this.LabelValuePyramid:
                this.fileUploadSource = this.LabelValuePyramid;
                break;
            case this.LabelPOVPlayback:
                this.fileUploadSource = this.LabelPOVPlayback;
                break;
            case this.LabelPOVPlan:
                this.fileUploadSource = this.LabelPOVPlan;
                break;    
            case this.LabelPOVTestCases:
                this.fileUploadSource = this.LabelPOVTestCases;
                break;    
            case this.LabelServiceProposal:
                this.fileUploadSource = this.LabelServiceProposal;
                break;  
            case this.LabelArchitectureDocument:
                this.fileUploadSource = this.LabelArchitectureDocument;
                break;
            case this.LabelBVA:
                this.fileUploadSource = this.LabelBVA;
                break;    
        }
    }
    hideModalBox(){
        this.showAttachmentSection = false;
    }

    filePreview(event){
        // Navigation Service to the show preview
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                // assigning ContentDocumentId to show the preview of file
                selectedRecordId: event.currentTarget.dataset.id
            }
        })
    }


    get fileFieldValue(){
        let header = '';
        switch (this.fileUploadSource) {
            case this.Label3WhysLink:
                header = this.Label3WhysLink;
                break;
            case this.LabelValuePyramid:
                header = this.LabelValuePyramid;
                break;
            case this.LabelPOVPlayback:
                header = this.LabelPOVPlayback;
                break;
            case this.LabelPOVPlan:
                header = this.LabelPOVPlan;
                break;  
            case this.LabelPOVTestCases:
                header = this.LabelPOVTestCases;
                break;       
            case this.LabelServiceProposal:
                header = this.LabelServiceProposal;
                break;  
            case this.LabelArchitectureDocument:
                header = this.LabelArchitectureDocument;
                break;  
            case this.LabelBVA:
                header = this.LabelBVA;
                break;    
        }
        return header;
    }

    assignUploadedFilestoList(){
            //this.resetList();
            if(this.files != undefined){
                for(var tmpFile of this.files){
                    switch (tmpFile.SourceFileUpload) {
                        case this.Label3WhysLink:                            
                            this.WhyLinkMap.file = tmpFile;
                            this.WhyLinkMap.isFilePresent = true;
                            break;
                        case this.LabelValuePyramid:
                            this.ValuePyramidMap.file = tmpFile;
                            this.ValuePyramidMap.isFilePresent = true;
                            break;
                        case this.LabelPOVPlayback:
                            this.POVPlaybackMap.file = tmpFile;
                            this.POVPlaybackMap.isFilePresent = true;
                            break;
                        case this.LabelPOVPlan:
                            this.POVPlanMap.file = tmpFile;
                            this.POVPlanMap.isFilePresent = true;
                            break;      
                        case this.LabelPOVTestCases:
                            this.POVTestCasesMap.file = tmpFile;
                            this.POVTestCasesMap.isFilePresent = true;
                            break;   
                        case this.LabelServiceProposal:
                            this.ServiceProposalMap.file = tmpFile;
                            this.ServiceProposalMap.isFilePresent = true;
                            break;  
                        case this.LabelArchitectureDocument:
                            this.ArchitectureDocumentMap.file = tmpFile;
                            this.ArchitectureDocumentMap.isFilePresent = true;
                            break;  
                        case this.LabelBVA:
                            this.BVAMap.file = tmpFile;
                            this.BVAMap.isFilePresent = true;
                            break;    
                    }
                }
                this.isFileAvailable = true;
            }     
    }

    async getRelatedUploadedFiles(event){

        try {
            if (this.recordId) {
                this.files = await getRelatedFiles({ recordId: this.recordId });
                this.isLoaded = true;
                this.assignUploadedFilestoList();  
            }
        } catch (error) {
            console.log('Exception:', error);
            this.isLoaded = true;
            this.hasError = true;
            this.errMsg = "Error Occurred, kindly contact the administrator.";
            this.errDetail = result.error;
        }
    }
    
    handleDeleteButton(event){
        this.buttonElementDataId=event.currentTarget.dataset.deleteId; 
        this.showDeleteMsg = true;
        this.showSpinner = true;
        this.isDeleteModal = true;
    }
    
    async deletefun(FileToBeDeleted){
        try {
            if (this.FileToBeDeleted != '') {
                this.DeleteFileMsg = await deleteFiles({ contentDocumentId: this.FileToBeDeleted });
                this.isLoaded = true;
                this.files = await getRelatedFiles({ recordId: this.recordId });
                this.assignUploadedFilestoList();  
                if(this.showDeleteMsg){
                if(this.DeleteFileMsg === 'SUCCESS'){
                this.showSpinner = false;
                await updateUrlOnRecord({ url: '',recordId : this.recordId,source:this.fileDeleteSource });
                const ToastEvent = new ShowToastEvent({
                    title: 'Toast message',
                    message: this.DeletedFileName+' document is deleted',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(ToastEvent);
            }
            }
            }
        } catch (error){
            console.log('Exception:', error);
            this.isLoaded = true;
            this.hasError = true;
            this.errMsg = "Error Occurred, kindly contact the administrator.";
            this.errDetail = result.error;
        }
    }

    handleEditButtonClick(event){
        let buttonElementDataId=event.currentTarget.dataset.editId;
        this.showDeleteMsg = false;
        switch(buttonElementDataId){
            case this.Label3WhysLink:
                this.FileToBeDeleted = this.WhyLinkMap.file.Id;
                break;
            case this.LabelValuePyramid:
                this.FileToBeDeleted = this.ValuePyramidMap.file.Id;
                break;
            case this.LabelPOVPlayback:
                this.FileToBeDeleted = this.POVPlaybackMap.file.Id;
                break;
            case this.LabelPOVPlan:
                this.FileToBeDeleted = this.POVPlanMap.file.Id;
                break;   
            case this.LabelPOVTestCases:
                this.FileToBeDeleted = this.POVTestCasesMap.file.Id;
                break;     
            case this.LabelServiceProposal:
                this.FileToBeDeleted = this.ServiceProposalMap.file.Id;
                break;  
            case this.LabelArchitectureDocument:
                this.FileToBeDeleted = this.ArchitectureDocumentMap.file.Id;
                break;  
            case this.LabelBVA:
                this.FileToBeDeleted = this.BVAMap.file.Id;
                break;    
        }
        this.handleButtonClick(event);
    }

    async getBaseUrlForDocument(documentIdOfUploadedFile){
        this.fullRecordURL = await getDocumentUrl({ documentId: this.documentIdOfUploadedFile });
        this.updateUrlOnRecord(this.fullRecordURL,this.recordId);
    }

    async updateUrlOnRecord(fullRecordURL,recordId,Source){
        await updateUrlOnRecord({ url: this.fullRecordURL,recordId : this.recordId,source:this.fileUploadSource });
    }
    handleConfirmDelete(){
        switch (this.buttonElementDataId) {
            case this.Label3WhysLink:
                this.FileToBeDeleted = this.WhyLinkMap.file.Id;
                this.DeletedFileName = this.Label3WhysLink;
                this.fileDeleteSource = this.WhyLinkMap.file.SourceFileUpload;
                this.WhyLinkMap.isFilePresent = false;
                this.WhyLinkMap.file = '';
                break;
            case this.LabelValuePyramid:
                this.FileToBeDeleted = this.ValuePyramidMap.file.Id;
                this.DeletedFileName = this.LabelValuePyramid;
                this.fileDeleteSource = this.ValuePyramidMap.file.SourceFileUpload;
                this.ValuePyramidMap.isFilePresent = false;
                this.ValuePyramidMap.file = '';
                break;
            case this.LabelPOVPlayback:
                this.FileToBeDeleted = this.POVPlaybackMap.file.Id;
                this.DeletedFileName = this.LabelPOVPlayback;
                this.fileDeleteSource = this.POVPlaybackMap.file.SourceFileUpload;
                this.POVPlaybackMap.isFilePresent = false;
                this.POVPlaybackMap.file = '';
                break;
            case this.LabelPOVPlan:
                this.FileToBeDeleted = this.POVPlanMap.file.Id;
                this.DeletedFileName = this.LabelPOVPlan;
                this.fileDeleteSource = this.POVPlanMap.file.SourceFileUpload;
                this.POVPlanMap.isFilePresent = false;
                this.POVPlanMap.file = '';
                break;    
            case this.LabelPOVTestCases:
                this.FileToBeDeleted = this.POVTestCasesMap.file.Id;
                this.DeletedFileName = this.LabelPOVTestCases;
                this.fileDeleteSource = this.POVTestCasesMap.file.SourceFileUpload;
                this.POVTestCasesMap.isFilePresent = false;
                this.POVTestCasesMap.file = '';
                break;   
            case this.LabelServiceProposal:
                this.FileToBeDeleted = this.ServiceProposalMap.file.Id;
                this.DeletedFileName = this.LabelServiceProposal;
                this.fileDeleteSource = this.ServiceProposalMap.file.SourceFileUpload;
                this.ServiceProposalMap.isFilePresent = false;
                this.ServiceProposalMap.file = '';
                break;  
            case this.LabelArchitectureDocument:
                this.FileToBeDeleted = this.ArchitectureDocumentMap.file.Id;
                this.DeletedFileName = this.LabelArchitectureDocument;
                this.fileDeleteSource = this.ArchitectureDocumentMap.file.SourceFileUpload;
                this.ArchitectureDocumentMap.isFilePresent = false;
                this.ArchitectureDocumentMap.file = '';
                break;  
            case this.LabelBVA:
                this.FileToBeDeleted = this.BVAMap.file.Id;
                this.DeletedFileName = this.LabelBVA;
                this.fileDeleteSource = this.BVAMap.file.SourceFileUpload;   
                this.BVAMap.isFilePresent = false;
                this.BVAMap.file = '';
                break;    
        }
        
        if(this.FileToBeDeleted){
            this.deletefun(this.FileToBeDeleted);
        }
        this.isDeleteModal = false;
    }
    hideDeleteBox(){
        this.isDeleteModal = false;
        this.showSpinner=false;
    }
}
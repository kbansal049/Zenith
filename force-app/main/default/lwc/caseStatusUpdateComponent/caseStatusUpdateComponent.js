import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Case_Object from '@salesforce/schema/Case';
import associateCaseWithKnowledge from "@salesforce/apex/CaseStatusUpdateController.associateCaseWithKnowledge";
import isKnowledgeArticleAttached from "@salesforce/apex/CaseStatusUpdateController.isKnowledgeArticleAttached";



const casefieldstoQuery = ['Case.Status','Case.RecordTypeId', 'Case.Case_Type__c', 'Case.Resolution_Details__c', 'Case.Create_New_Knowledge_Article__c','Case.Resolution_Type__c','Case.No_Knowledge_Article_Justification__c'];

export default class CaseStatusUpdateComponent extends LightningElement {
    @api recordId;
    @track usrinfo;
    @track showCaseDetails;
    @track isPortalUser = false;
    @track showclosedetails = false;
    @track loading = false;
    @track objectInfo;
    @track showcommentmandatorymessage = false;
    @track shownotresolvedmessage=false;
    @track errmsg = '';
    @track notresolvederrmsg='';
    @track loadData  = false;

    @track isKnowledge = false;
    @track recordId1;
    @track detailsTemplate = '';
    @track defaultTemplate = '';
    @track isProblemType;
    @track showResolutionInfo = false;
    @track recordTypeName;
    @track kbRecordTypeId;
    @track issueSummary = '';
    @track urlName = '';
    @track product = '';
    @track kbResolutionDetails = '';
    @track showKnowledgeModal = false;
    @track loadingKnowledge = false;
    @track isKnowledgeDisabled = false;
    @track kbErrorMsg='';
    @track kbError=false;
    @track showJustification=false;
    @track showKnowledgeArticleOption=false;
    @track articleAttachError=false;
    @track showLinkArticleValidation=false;
    @track showHelpPortalField=false;
    @track showResTypeInternet=false;
    @track showResTypeZscaler=false;
    @track showResTypeCustomer=false;
    @track showResFields=false




    @wire(getObjectInfo, { objectApiName: Case_Object })
    objectInfo;

    /*get recordTypeId() {
        // Returns a map of record type Ids 
        if (this.objectInfo && this.objectInfo.data && this.objectInfo.data.recordTypeInfos) {
            const rtis = this.objectInfo.data.recordTypeInfos;
            return Object.keys(rtis).find(rti => rtis[rti].name === 'Support');
        }
    }*/

    @wire(getRecord, { recordId: '$recordId', fields: casefieldstoQuery })
    wirecontact({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading Case Details',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            if(data.fields.Case_Type__c.value == 'Problem'){
                this.detailsTemplate = '<b>Cause:</b><br/><br/><br/><b>Troubleshooting steps:</b><br/><br/><br/><b>Solution:</b>';
                this.isProblemType = true;
                this.recordTypeName = 'Problem';
                this.kbRecordTypeId = '0124u00000060yKAAQ'
            }
            if(data.fields.Case_Type__c.value == 'Question'){
                this.detailsTemplate = '<b>Question:</b><br/><br/><br/><b>Answer:</b><br/><br/><br/>';
                this.isProblemType = false;
                this.recordTypeName = 'Question';
                this.kbRecordTypeId = '0124u00000060yPAAQ';
            }
            this.defaultTemplate = this.detailsTemplate;
            if(data.fields.Resolution_Details__c.value){
                this.detailsTemplate = data.fields.Resolution_Details__c.value;
            }
            if (data.fields.Status.value == 'Closed') {
                this.showclosedetails = true;
                this.showResFields = true;
            }
            if (data.fields.Status.value == 'Closed - Duplicate') {
                this.showclosedetails = true;
            }

            if (data.fields.RecordTypeId.value) {
                this.recordTypeId = data.fields.RecordTypeId.value;
                this.loadData = true;
            }
            /*if(data.fields.Knowledge_Candidate__c.value){
                this.isKnowledge = true;
            }*/
            if(data.fields.Create_New_Knowledge_Article__c.value == 'Create Knowledge Article'){
                this.isKnowledgeDisabled = true; 
            }
            if(data.fields.Resolution_Type__c !=null || data.fields.Resolution_Type__c !=undefined ){
                this.showKnowledgeArticleOption = true; 
            }
            if(data.fields.Create_New_Knowledge_Article__c.value =='No Knowledge Association'){
                this.showJustification = true; 
            }
            if(data.fields.Create_New_Knowledge_Article__c.value =='Link Help Portal Documentation and External References'){
                this.showHelpPortalField = true; 
            }
        }
    }


    savecase(event) {
        console.log('Save Case called');
        
        this.errmsg = '';
        this.notresolvederrmsg='';
        if (!this.template.querySelector('.Case_Category__c').value) {
            this.errmsg += 'Case Category'
        }
        if (!this.template.querySelector('.Case_Sub_Category__c').value) {
            if (this.errmsg) {
                this.errmsg += ', ';
            }
            this.errmsg += 'Case Sub Category'
        }
        //TTC TTR Project Start--Added by Chetan
        if (!this.template.querySelector('.Resolution_State__c').value) {
            if (this.errmsg) {
                this.errmsg += ', ';
            }
            this.errmsg += 'Resolution State'
        }
        //TTC TTR Project End--Added by Chetan
        if (this.showclosedetails) {
            /*if (!this.template.querySelector('.Case_Category__c').value) {
                this.errmsg += 'Case Category'
            }
            if (!this.template.querySelector('.Case_Sub_Category__c').value) {
                if (this.errmsg) {
                    this.errmsg += ', ';
                }
                this.errmsg += 'Case Sub Category'
            }*/
            
            /*if (!this.template.querySelector('.Resolution_Summary__c').value) {
                if (this.errmsg) {
                    this.errmsg += ', ';
                }
                this.errmsg += 'Issue Summary'
            }*/
            if(this.showResFields){
            if (!this.template.querySelector('.Resolution_Type__c').value) {
                    if (this.errmsg) {
                    this.errmsg += ', ';
                }
                this.errmsg += 'Resolution Type'
            }
            }
            if (!this.template.querySelector('.Resolution_Details__c').value || this.template.querySelector('.Resolution_Details__c').value == this.defaultTemplate) {
                if (this.errmsg) {
                    this.errmsg += ', ';
                }
                this.errmsg += 'Resolution Details'
            }
            /*if (!this.template.querySelector('.Resolved_with_AI_Assistance__c').value) {
                if (this.errmsg) {
                    this.errmsg += ', ';
                }
                this.errmsg += 'Resolved with AI Assistance?'
            }*/
            if (!this.template.querySelector('.Create_New_Knowledge_Article__c').value) {
                if (this.errmsg) {
                    this.errmsg += ', ';
                }
                this.errmsg += 'Create New Knowledge Article?'
            }
            if(this.showJustification){
                if (!this.template.querySelector('.No_Knowledge_Article_Justification__c').value) {
                    if (this.errmsg) {
                        this.errmsg += ', ';
                    }
                    this.errmsg += 'No Knowledge Article Justification'
                } 
            }
            if(this.showHelpPortalField){
                if (!this.template.querySelector('.Help_Portal_document__c').value) {
                    if (this.errmsg) {
                        this.errmsg += ', ';
                    }
                    this.errmsg += 'Help Portal link/External References URL'
                } 
            }
            if(this.showResFields && this.recordTypeId=='0120g0000009ujLAAQ'){
                if (!this.template.querySelector('.Resolution_Category__c').value) {
                    if (this.errmsg) {
                        this.errmsg += ', ';
                    }
                    this.errmsg += 'Resolution Category'
                } 
            }
            //TTC TTR Project Start--Added by Chetan
            console.log('Before Res State Check');
            if (this.template.querySelector('.Resolution_State__c').value=='Not Resolved' && (this.template.querySelector('.Status').value=='Closed' || this.template.querySelector('.Status').value=='Closed - Duplicate')) {
                console.debug('Resolution State check');
                this.notresolvederrmsg = 'Resolution state cannot be Not Resolved while closing the case.';
            }
            //TTC TTR Project End--Added by Chetan
            /*if (this.errmsg) {
                this.errmsg = 'Please fill the following fields: ' + this.errmsg;
                this.showcommentmandatorymessage = true;
                return;
            }*/
        }
        
        if (this.errmsg) {
            this.errmsg = 'Please fill the following fields: ' + this.errmsg;
            this.showcommentmandatorymessage = true;
            //return;
        }else{
            this.showcommentmandatorymessage=false;
        }
        if(this.notresolvederrmsg){
            console.log('Show Not Resolved Called');
            this.shownotresolvedmessage=true;
            //return;          
        }else{
            this.shownotresolvedmessage=false;
        }
        console.log('Value of Article Attach Error' + this.articleAttachError);
        if(this.showcommentmandatorymessage || this.shownotresolvedmessage){
            return;
        }
        //Chetan Start
        if(this.template.querySelector('.Status')!=null && this.template.querySelector('.Create_New_Knowledge_Article__c')!=null){
            if(this.template.querySelector('.Create_New_Knowledge_Article__c').value=='Link Existing Knowledge Article' && (this.template.querySelector('.Status').value=='Closed' || this.template.querySelector('.Status').value=='Closed - Duplicate')){
                isKnowledgeArticleAttached({ CaseId: this.recordId})
                .then((result) => {
                    console.log('Result from KB'+ result);
                    if(result==false){
                        this.dispatchEvent(
                            new ShowToastEvent({
                            title: "Error !",
                            message: "Please attach a Knowledge article before closing the case. To attach a knowledge article, go to Knowledge widget located on the top left panel, search for a relevant article, click '▼' (down arrow) and select Attach. Attached Knowledge articles can be viewed in the 'Knowledge Tab'.",
                            variant: "error"
                            })
                        );   
                        this.articleAttachError=true; 
                        console.log('Value of Article Attach Error 1'+this.articleAttachError);    
                        return;     
                    }else{
                        this.loading=true;
                        this.template.querySelector('lightning-record-edit-form').submit();
                    }
                    
                })
                .catch((error) => {
                    console.log('Error--->'+error);
                    if (error) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                        title: "Error !",
                        message: "Error while checking associated Knowledge Article",
                        variant: "error"
                        })
                    );
                    }
                    this.loadingKnowledge = false;
                });
            }else{
                this.loading=true;
                this.template.querySelector('lightning-record-edit-form').submit();
            }
        }else{
            this.loading=true;
            this.template.querySelector('lightning-record-edit-form').submit();
        }
        //Chetan End
        this.shownotresolvedmessage=false;
        this.showcommentmandatorymessage = false;
        this.errmsg = '';
        this.notresolvederrmsg='';
        this.articleAttachError=false;
        //this.template.querySelector('lightning-record-edit-form').submit();

    }

    handleSuccess(event) {
        const updatedRecord = event.detail.id;
        this.showtoast('Save is Successful');
        this.cancelCase();
    }
    showtoast(mes) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Case Status Updated!',
                mes,
                variant: 'success',
            }),
        );
    }
    cancelCase() {
        this.loading = false;
        this.sendtoCust = false;
        this.contentIds = [];
        console.log('inside cancel case');
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }

    }
    statuschange(event) {
        if (event.detail.value == 'Closed' || event.detail.value == 'Closed - Duplicate') {
            this.showclosedetails = true;
        } else {
            this.showclosedetails = false;
        }
        if(event.detail.value == 'Closed'){
            this.showResFields=true;
        } else {
            this.showResFields = false;
        }
    }

    resolutionTypeChange(event) {
        let resolutionType = this.template.querySelector('.Resolution_Type__c').value;
        this.showResTypeInternet = false;
        this.showResTypeZscaler=false;
        this.showResTypeCustomer = false;
        if (resolutionType!=null) {
            this.showKnowledgeArticleOption = true;
        } else {
            this.showKnowledgeArticleOption = false;
        }

        if(event.detail.value == 'Internet'){
            this.showResTypeInternet = true;
        }else if(event.detail.value == 'Customer'){
            this.showResTypeCustomer = true;
        }else if(event.detail.value == 'Zscaler'){
            this.showResTypeZscaler=true;
        }else{
            this.showResTypeCustomer=false;
            this.showResTypeInternet = false;
            this.showResTypeZscaler=false;
        }

    }

    changeKnowledge(event){

        this.loadingKnowledge = true;
        /*if(this.isKnowledge == false){
            this.isKnowledge = true;
        }else{
            this.isKnowledge = false;
        }*/
        if(event.detail.value == 'Create Knowledge Article'){
            this.isKnowledge = true;
        }else if(event.detail.value == 'No Knowledge Association'){
            this.showJustification = true;
            this.showLinkArticleValidation=false;
            this.showHelpPortalField=false;
        }else if(event.detail.value == 'Link Existing Knowledge Article'){
            this.showLinkArticleValidation=true;
            this.showJustification=false;
            this.showHelpPortalField=false;
        }else if(event.detail.value == 'Link Help Portal Documentation and External References'){
            console.log('## entered into the condition');
            this.showHelpPortalField=true;
            this.showLinkArticleValidation=false;
            this.showJustification=false;
        }
        else{
            this.isKnowledge = false;
            this.showJustification = false;
            this.showLinkArticleValidation=false;
            this.showHelpPortalField=false;
        }
        this.showKnowledgeModal = this.isKnowledge;
        /*this.issueSummary = this.template.querySelector('.Resolution_Summary__c').value;
        if(this.issueSummary){
            this.urlName = this.issueSummary.replaceAll(' ','-');
        }*/
        this.kbResolutionDetails = this.template.querySelector('.Resolution_Details__c').value;
        this.product = this.template.querySelector('.Product_New__c').value;
        console.log('knowledge-->'+this.isKnowledge);
        console.log('URL Name --->'+this.urlName);
        console.log('Product --->'+this.product);
    }

    closeModal(event){
        this.showKnowledgeModal = false;
        this.isKnowledge = false;
        this.template.querySelector('.Create_New_Knowledge_Article__c').value = null;
        this.loading = false;
        //this.kbErrorMsg='';
        this.kbError=false;
    }

    handleKBSubmit(event){
        this.kbErrorMsg = '';
        this.kbError=false;
        if (!this.template.querySelector('.Product_Applicable__c').value) {
            this.kbErrorMsg += 'Product Applicable'
        }
        if (!this.template.querySelector('.Summary').value) {
            if (this.kbErrorMsg) {
                this.kbErrorMsg += ', ';
            }
            this.kbErrorMsg += 'Summary'
        }
        console.log('Value of Default Template-->'+this.defaultTemplate);
        console.log('KB Error'+ this.kbErrorMsg);
        if (!this.template.querySelector('.Details__c').value) {
            if (this.kbErrorMsg) {
                this.kbErrorMsg += ', ';
            }
            this.kbErrorMsg += 'Resolution Details'
        }
        if (!this.template.querySelector('.UrlName').value) {
            if (this.kbErrorMsg) {
                this.kbErrorMsg += ', ';
            }
            this.kbErrorMsg += 'URL Name'
        }
        if (!this.template.querySelector('.Title').value) {
            if (this.kbErrorMsg) {
                this.kbErrorMsg += ', ';
            }
            this.kbErrorMsg += 'Title'
        }
        if (this.kbErrorMsg) {
            this.kbErrorMsg = 'Please fill the following fields: ' + this.kbErrorMsg;
            this.kbError = true;
            //return;
        }
        //this.loading = true;
        if(!this.kbError){
            this.loadingKnowledge = true;
            this.template.querySelector(".knowledgeForm").submit();
        }
        
        
        console.log('Handle KB Submit Called');
        
    }

    handleKBSuccess(event){
        this.detailsTemplate = this.template.querySelector('.Details__c').value;
        var caseCategory = this.template.querySelector('.Case_Category__c').value;
        var subCategory = this.template.querySelector('.Case_Sub_Category__c').value;
        var product = this.template.querySelector('.Product_New__c').value;
        var knowledgeId = event.detail.id;
        
        associateCaseWithKnowledge({ CaseId: this.recordId, knowledgeId: knowledgeId, category: caseCategory, subcategory: subCategory, caseProduct: product})
        .then((result) => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Knowledge Article Created!',
                variant: 'success'
                }),
            );
            this.isKnowledgeDisabled = true;
            this.showKnowledgeModal = false;
            this.loading = false;
            this.loadingKnowledge = false;
        })
        .catch((error) => {
            console.log('Error--->'+error);
            if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                title: "Error !",
                message: "Error while associating Case with Knowledge Article",
                variant: "error"
                })
            );
            }
            this.loadingKnowledge = false;
        });
        
    }

    handleKbEditError(event){
        this.loadingKnowledge = false;
    }

    handleKbOnLoad(event){
        this.loadingKnowledge = false;
    }

    handleError(event) {
        this.loading=false;
    }

}
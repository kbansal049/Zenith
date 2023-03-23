/*
 * @description       : 
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   09-15-2021   Viral N.      Initial Version
 * 2.0   11-12-2021   Mayank B.     Incremental Fix CR# 3611
 * 3.0   01-12-2021   Viral N.     Incremental Fix CR# 3994
 * 5.0   27-01-2021   Viral       Incremental Fix CR#4084
 * 6.0   09-02-2021   Viral       PO Detail [Edit]
 * 7.0   21-03-2021   Viral       Show Validation Error Messages on Screen
 * 8.0.  Apr 8 2022.  Karthik.    Add Closed lost functionality   
 * 9.0   12-04-2022   Hari        Amount Field Auto refresh
 * 10.0  12-05-2022   Bikram        CR# 4782 SFDC Competitive Tracking 
 * 10.0  22-06-2022   Prachi        CR#4946
 * 11.0  22-06-2022   Bikram        CR# 4964 SFDC Competitive Tracking 
 */
import { LightningElement, wire, api, track } from 'lwc';

import retrivePreQCDetails from '@salesforce/apex/CreateSalesOrderExtensionCPQSalesLWC.retrivePreQCDetails';
import attachPOtoOpportunity from '@salesforce/apex/CreateSalesOrderExtensionCPQSalesLWC.attachPOtoOpportunity';
import createSalesOrder from '@salesforce/apex/CreateSalesOrderExtensionCPQSalesLWC.createSalesOrder';
import moveOpptoFinance from '@salesforce/apex/CreateSalesOrderExtensionCPQSalesLWC.moveOpptoFinance';
import removePOFromOpportunity from '@salesforce/apex/CreateSalesOrderExtensionCPQSalesLWC.removePOFromOpportunity';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

import stage5A from '@salesforce/label/c.Stage_5A_Opportunity';
import stage6Won from '@salesforce/label/c.Stage_6_Closed_Won';
import hasUserAccess from '@salesforce/customPermission/Opportunity_Checklist_Edit_Permission';
import hasCloseAccess from '@salesforce/customPermission/CSM_Ops_Access';
import fetchOpp from '@salesforce/apex/OppStageChecklistController.fetchDetails';
import updateStage from '@salesforce/apex/OppStageChecklistController.updateOpportunityStage';
import strUserId from '@salesforce/user/Id';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import MANAGER_FIELD from '@salesforce/schema/User.ManagerId';
import STAGE_FIELD from '@salesforce/schema/Opportunity.StageName';
import TYPE_FIELD from '@salesforce/schema/Opportunity.Type';
import OWNER_FIELD from '@salesforce/schema/Opportunity.OwnerId';
import AMOUNT_FIELD from '@salesforce/schema/Opportunity.OwnerId';
import { getRecord, getRecordNotifyChange, getFieldValue } from 'lightning/uiRecordApi';
import { reduceErrorsUpgradedAdvanced } from 'c/ldsUtils';

import { NavigationMixin } from 'lightning/navigation';

//CR# 4782 Competitive Tracking
import HOW_COMPETITIVE_WAS_THE_DEAL from '@salesforce/schema/Opportunity.How_competitive_was_the_deal__c';
import PRIMARY_COMPETITOR from '@salesforce/schema/Opportunity.Primary_Competitor__c';
import OTHER_PRIMARY_COMPETITOR from '@salesforce/schema/Opportunity.Other_Primary_competitor__c';
import SECONDARY_COMPETITORS from '@salesforce/schema/Opportunity.Secondary_Competitors__c';
import OTHER_SECONDARY_COMPETITOR from '@salesforce/schema/Opportunity.Other_Secondary_competitor__c';

export default class CreateSalesOrderPreQCCheck extends NavigationMixin(LightningElement) {

    @api recordId;
    @api accountId;
    @track preQCWrapper;

    @track error;
    @track hasError = false;
    @track loading = true;

    @track oppRecord;

    @track poDetRecord; //EDI

    @track erServiceEdgeNeeded;
    @track erServiceEdgeList = [];

    @track erVirtualServiceEdgeNeeded;
    @track erVirtualServiceEdgeList = [];

    @track poCheckList = false;
    @track poChecklistConfirmed = false;


    @track fileUploadSource = '';
    @track openUploadFileModal = false;
    @track isSpinnerLoading = false;

    @track poHasError = false;
    @track poErrorMsg = '';


    @track modalPOFilesUploaded = [];
    @track modalSOWFilesUploaded = [];
    @track modalBillFilesUploaded = [];


    @track loadedFiles = [];

    @track poCheckBoxValues = [];
    @track poCheckListHasError = false;
    @track poCheckListErrorMsg = '';

    @track specialInstructionForMultiCloud = false; //CR#3611 added
    @track cloudTypeToCloudIDMap = []; //CR#3611 added
    @track disableButton = true;//CR#3611 added

    @track optionalFields = [];
    @track error;
    @track hasError;
    @track typeVal;
    @track loading = false;
    @track allowPermissionOverride;
    @track prevStageValue;
    @track nextStageValue;
    @track displayRegress = false;
    @track isLoading = true;
    @track disabledFlag = true;
    @track recordTypeId;
    @track fieldName;
    @track modalWindow;
    @track fieldLabel;
    @track fieldType;
    @track isRequiredFulfilled = false;
    @track stageDescription;
    @track actorsInvolved;
    @track lastChangedDate;
    @track ownerName;
    @track createdByName;
    @track forecastCategory;
    @track daysinCurrentStage;
    @track importantLinks;
    @track fileName;
    @track fileId;
    @track fieldVal;
    @track allowedValues;
    @track errMsg;
    @track dependentFieldNames;
    @track allowStageUpdates;
    @track disablePrevious = true;
    @track disableClosed = true;
    @track profileName;
    @track opportunity;
    @track managerId;
    @track ownerId;
    @track isCompetitiveFieldsRequired = true;


    //CR# 4782 START - Bikram - Competitive Tracking
    @track userProfileName;
    @track closeLightningMessages = true;
    @track areCompetitiveFieldsPopulated = true;
    @track isCompetitiveFieldsModalOpened = false;
    @track isOtherPrimaryCompetitorRequired = false;
    @track isOtherSecondaryCompetitorRequired = false;
    userId = strUserId;
    //CR# 4782 END - Bikram - Competitive Tracking 

    @wire(getRecord, {
        recordId: '$recordId', fields: ['Opportunity.Name', STAGE_FIELD, TYPE_FIELD, OWNER_FIELD, AMOUNT_FIELD,
            HOW_COMPETITIVE_WAS_THE_DEAL, PRIMARY_COMPETITOR, OTHER_PRIMARY_COMPETITOR, SECONDARY_COMPETITORS,
            OTHER_SECONDARY_COMPETITOR]
    })
    getOpportunityRecord({ data, error }) {
        console.log('opportunity =>', data, error);
        if (data) {
            this.opportunity = data;
            this.typeVal = data.fields.Type.value;
            this.ownerId = data.fields.OwnerId.value;
            this.handleLoadOpportunityPreQCCehcks();
        } else if (error) {
            console.error('ERROR => ', JSON.stringify(error)); // handle error properly
        }
    }

    //CR# 4782 START - Bikram - Competitive Tracking
    @wire(getRecord, {
        recordId: strUserId,
        fields: [PROFILE_NAME_FIELD]
    }) loggedInUserDetails({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.userProfileName = data.fields.Profile.value.fields.Name.value;
            console.log('this.userProfileName : - ' + this.userProfileName);
            //this.isCoreSalesOrRenewalsUser = this.userProfileName === 'Core Sales' ? true : false;
        }
    }

    get isCoreSalesOrRenewalsUser() {//CR# 4964
        if (this.opportunity && this.opportunity.fields.StageName.value !== '4 - Impact Validation' &&
            (this.userProfileName === 'Core Sales' || this.userProfileName === 'Core Sales - Renewals')) {
            this.checkCompetitiveFieldvalues();
            return true;
        } else {
            this.areCompetitiveFieldsPopulated = true;
            return false;
        }

    }
    //CR# 4782 END - Bikram - Competitive Tracking 

    // initialize component
    connectedCallback() {
        console.log('---connectedCallback--called---');
        //this.handleLoadOpportunityPreQCCehcks(); commented so it get refreshed using wire.
    }

    async handleLoadOpportunityPreQCCehcks() {
        this.loading = true;
        console.log('---handleLoadOpportunityPreQCCehcks--called---');
        console.log('---handleLoadOpportunityPreQCCehcks--this.recordId---', this.recordId);
        await retrivePreQCDetails({ opportunityId: this.recordId })
            .then(result => {
                console.log('---handleLoadOpportunityPreQCCehcks--result---', result);
                let preQCWrapRes = Object.assign({}, result);

                this.parseQCcheckResult(preQCWrapRes);
            })
            .catch(error => {
                this.error = error;
                this.hasError = true;
                this.loading = false;
                console.log('error', error);
                this.template.querySelector('c-custom-toast-component').showToast('error', error?.body?.message || error?.message);
            });
    }


    parseQCcheckResult(preQCWrapRes) {
        console.log('---parseQCcheckResult--called---');
        console.log('---parseQCcheckResult--preQCWrapRes---', preQCWrapRes);
        if (preQCWrapRes.isSuccess) {
            this.hasError = false;
            this.loading = false;
            this.preQCWrapper = preQCWrapRes.pqw;
            this.oppRecord = this.preQCWrapper.hasOwnProperty('opp') ? this.preQCWrapper['opp'] : undefined;
            this.accountId = this.oppRecord.AccountId;
            this.poDetRecord = this.preQCWrapper.hasOwnProperty('poDet') ? this.preQCWrapper['poDet'] : undefined;
            console.log('---oppRecord---', this.oppRecord);
            console.log(this.oppRecord.Amount < 50000);
            console.log(this.oppRecord.Account.Market_Segment__c == 'Commercial');
            if(this.oppRecord.Amount < 50000 && this.oppRecord.Account.Market_Segment__c == 'Commercial' 
                && (this.oppRecord.StageName=='5 - Procurement' || this.oppRecord.StageName=='5A - Submitted for Order Review' || 
                this.oppRecord.StageName=='5B - In Process with Finance' || this.oppRecord.StageName=='5C - Sales Rep Action Required' || 
                this.oppRecord.StageName=='5D - Approved, awaiting processing')){
                    console.log('in if');
                    this.isCompetitiveFieldsRequired = false;
            }

            // Set ER Service Edge
            if (this.preQCWrapper && this.preQCWrapper.hasOwnProperty('erServiceEdgeNeeded')) {
                this.erServiceEdgeNeeded = this.preQCWrapper.erServiceEdgeNeeded;
            }
            if (this.preQCWrapper && this.preQCWrapper.hasOwnProperty('erServiceEdgeList')) {
                this.erServiceEdgeList = this.preQCWrapper.erServiceEdgeList;
            }

            // Set Virtual ER Service Edge
            if (this.preQCWrapper && this.preQCWrapper.hasOwnProperty('erVirtualServiceEdgeNeeded')) {
                this.erVirtualServiceEdgeNeeded = this.preQCWrapper.erVirtualServiceEdgeNeeded;
            }
            if (this.preQCWrapper && this.preQCWrapper.hasOwnProperty('erVirtualServiceEdgeList')) {
                this.erVirtualServiceEdgeList = this.preQCWrapper.erVirtualServiceEdgeList;
            }
            //CR# 3611
            if (this.preQCWrapper && this.preQCWrapper.hasOwnProperty('cloudTypeCloudListMAP')) {
                //this.cloudTypeToCloudIDMap = this.preQCWrapper.cloudTypeCloudListMAP;

                for (let key in this.preQCWrapper.cloudTypeCloudListMAP) {
                    // Preventing unexcepted data
                    if (this.preQCWrapper.cloudTypeCloudListMAP.hasOwnProperty(key)) { // Filtering the data in the loop
                        this.cloudTypeToCloudIDMap.push({ value: this.preQCWrapper.cloudTypeCloudListMAP[key], key: key });
                    }
                }
            }
            console.log('---Mayank, this.cloudTypeToCloudIDMap: ' + JSON.stringify(this.cloudTypeToCloudIDMap));

            //Set the atatched Files
            this.modalPOFilesUploaded = this.attachedFileList('PO_Document');
            this.modalSOWFilesUploaded = this.attachedFileList('SOW_Document');
            this.modalBillFilesUploaded = this.attachedFileList('Declaration_Document');

            console.log('---handleLoadCustomOrder--this.modalPOFilesUploaded---', this.modalPOFilesUploaded);
            console.log('---handleLoadCustomOrder--this.modalSOWFilesUploaded---', this.modalSOWFilesUploaded);
            console.log('---handleLoadCustomOrder--this.modalBillFilesUploaded---', this.modalBillFilesUploaded);
            console.log('---handleLoadCustomOrder--this.preQCWrapper---', this.preQCWrapper);
        } else {
            this.hasError = true;
            this.loading = false;
            this.error = preQCWrapRes.errMsg;
        }
    }


    async triggerCreateSalesOrderProcess() {
        this.loading = true;
        await createSalesOrder({ oppID: this.recordId })
            .then(result => {
                this.loading = true;
                this.handleLoadOpportunityPreQCCehcks();
                this.template.querySelector('c-custom-toast-component').showToast('success', 'Sales Order creation has been initiated successfully.');
                getRecordNotifyChange([{ recordId: this.recordId }]);
            })
            .catch(error => {
                this.error = error;
                this.hasError = true;
                this.loading = false;
                console.log('error', error);
                //this.template.querySelector('c-custom-toast-component').showToast('error', error?.body?.message||error?.message);
                console.log('this.errorMessages 2--', this.errorMessages(error));
                this.template.querySelector('c-custom-toast-component').showToast('error', this.errorMessages(error));
            });
    }

    //Show Error Messages on Screen
    errorMessages(error) {
        return reduceErrorsUpgradedAdvanced(error);
    }


    async triggerMoveOpptoFinanceProcess() {
        this.loading = true;
        await moveOpptoFinance({ oppID: this.recordId })
            .then(result => {
                this.loading = true;
                this.handleLoadOpportunityPreQCCehcks();
                this.template.querySelector('c-custom-toast-component').showToast('success', 'Succesfully moved the opportunity to Stage 5A.');
                getRecordNotifyChange([{ recordId: this.recordId }]);
            })
            .catch(error => {
                this.error = error;
                this.hasError = true;
                this.loading = false;
                console.log('error', error);
                //this.template.querySelector('c-custom-toast-component').showToast('error', error?.body?.message||error?.message);
                this.template.querySelector('c-custom-toast-component').showToast('error', this.errorMessages(error));
            });
    }


    async handlePOSubmit(event) {
        console.log('--handlePOSubmit--called--');
        event.preventDefault();
        console.log('---this.checkIfPOAttached--', this.checkIfPOAttached);
        console.log('---this.modalPOFilesUploaded--', this.modalPOFilesUploaded.length);
        console.log('---this.loadedFiles--', this.loadedFiles.length);

        //if(this.checkIfPOAttached == false && this.modalPOFilesUploaded.length < 1){
        if (this.checkIfPOAttached == false && this.loadedFiles.length < 1) {
            this.poHasError = true;
            this.poErrorMsg = '!! Please Attach PO as well.';
        } else {
            this.isSpinnerLoading = true;
            const fields = event.detail.fields;
            console.log('---fields--', fields);
            let recordEdit = this.template.querySelector('lightning-record-edit-form');
            await recordEdit.submit();
        }
    }

    handlePOSuccess(event) {
        console.log('--handlePOSuccess--called--');
        this.submitDetails();
    }

    //function to save the attachments
    async submitDetails() {
        console.log('---submitDetails called--');
        console.log('---submitDetails--this.loadedFiles--', this.loadedFiles);

        this.isSpinnerLoading = true;

        let savedfiles = [];
        for (let file of this.loadedFiles) {
            savedfiles.push(file);
        }

        console.log('--submitDetails--savedfiles--', JSON.stringify(savedfiles));

        //calling "attachPOtoOpportunity" of apex class
        await attachPOtoOpportunity({
            opp: this.oppRecord,
            files: savedfiles,
            source: this.fileUploadSource
        }).then(() => {
            console.log('attachPOtoOpportunity Success++');
            this.handleLoadOpportunityPreQCCehcks();
            this.handleSpinnerLoadingOff();
            this.openUploadFileModal = false;
            this.template.querySelector('c-custom-toast-component').showToast('success', 'File(s) has been attached successfully.');
        }).catch(error => {
            console.log('Exception:', error);
            this.handleSpinnerLoadingOff();
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Error Occured while uplaoding files to Opportunity:', error?.body?.message || error?.message);
        });

    }


    //handle removing of files from modal/pop-up
    async handleRemove(event) {
        console.log('--remove-got--called---fileId--', event.currentTarget.dataset.id);

        console.log('---this.loadedFiles--', this.loadedFiles);
        console.log('---this.fileUploadSource--', this.fileUploadSource);

        if (event.currentTarget && event.currentTarget.dataset && event.currentTarget.dataset.id) {
            let fileId = event.currentTarget.dataset.id;
            this.isSpinnerLoading = true;

            //calling "removePOFromOpportunity" of apex class
            await removePOFromOpportunity({
                opp: this.oppRecord,
                fileId: fileId
            }).then(() => {
                this.handleLoadOpportunityPreQCCehcks();
                this.handleSpinnerLoadingOff();
                this.template.querySelector('c-custom-toast-component').showToast('success', 'File(s) has been removed successfully.');
            }).catch(error => {
                console.log('Exception:', error);
                this.handleSpinnerLoadingOff();
                this.template.querySelector('c-custom-toast-component').showToast('error', 'Error Occured while removing files from Opportunity:', error?.body?.message || error?.message);
            });



            //Pre load Existing Files
            switch (this.fileUploadSource) {
                case 'PO':
                    this.loadedFiles = this.attachedFileList('PO_Document');
                    break;
                case 'SOW':
                    this.loadedFiles = this.attachedFileList('SOW_Document');
                    break;
                case 'BILL':
                    this.loadedFiles = this.attachedFileList('Declaration_Document');
                    break;
            }


        }

    }



    handlePOError(event) {
        console.log('--handlePOError--called--');
    }

    get checkListOptionValues() {
        var checkOptions = [];
        checkOptions.push(
            { label: 'Start and End Dates Match (If there is a mis match, provide confirmation in the text box above to use the info from PO)', value: 'dateMatched' },
            { label: 'SKUs Match', value: 'skuMatched' },
            { label: 'Price Points Match', value: 'pricePointsMatch' },
            { label: 'Customer Name and address are accurate (If there is a mis match, provide confirmation in the text box above to use the info from PO)', value: 'customerDetailsMatched' },
            { label: 'Partner name and address are accurate (If there is a mis match, provide confirmation in the text box above to use the info from PO)', value: 'partnerDetailMatched' },
            { label: 'Payment Terms (If there is a mis match, provide confirmation in the text box above to use the info from PO)', value: 'paymentTermsMatched' },
        );
        console.log('multipleCloudIdforsameProduct++' + this.preQCWrapper.multipleCloudIdforsameProduct);
        //CR#3611 commented below code
        /*if(this.preQCWrapper && this.preQCWrapper.multipleCloudIdforsameProduct){
            checkOptions.push({ label: 'Provide Instructions to finance with Cloud and Quantity to provision', value: 'multiCloudIdsProd' });
        }*/

        return checkOptions;
        /* return [
            { label: 'Start and End Dates Match', value: 'dateMatched' },
            { label: 'SKUs Match', value: 'skuMatched' },
            { label: 'Price Points Match', value: 'pricePointsMatch' },
            { label: 'Customer Name and address are accurate', value: 'customerDetailsMatched' },
            { label: 'Partner name and address are accurate', value: 'partnerDetailMatched' },
        ]; */
    }

    get selectedPOCheckListValues() {
        return this.poCheckBoxValues.join(',');
    }

    handlePoCheckListChange(e) {
        this.poCheckBoxValues = e.detail.value;
    }

    //function to open PO modal/pop-up
    handlePOModalPopUp() {
        this.fileUploadSource = 'PO';
        this.openUploadFileModal = true;
        this.poHasError = false;
        this.poErrorMsg = '';
        //Pre load Existing Files
        this.loadedFiles = this.attachedFileList('PO_Document');
    }

    //function to open SOW modal/pop-up
    handleSOWModalPopUp() {
        this.fileUploadSource = 'SOW';
        this.openUploadFileModal = true;
        //Pre load Existing Files
        this.loadedFiles = this.attachedFileList('SOW_Document');
    }

    //function to open Billing modal/pop-up
    handleBillingModalPopUp() {
        this.fileUploadSource = 'BILL';
        this.openUploadFileModal = true;
        //Pre load Existing Files
        this.loadedFiles = this.attachedFileList('Declaration_Document');
    }

    //function to close modal
    closeModal() {
        this.openUploadFileModal = false;
        this.loadedFiles = [];
    }

    //PO Checklist Methods
    openPOCheckListModal() {
        this.isSpinnerLoading = false;
        this.poCheckList = true;
    }
    closePOCheckListModal() {
        this.poCheckList = false;
        this.poCheckListHasError = false;
        this.poCheckListErrorMsg = '';
    }

    //CR# 4782 START - Bikram - Competitive Tracking

    checkCompetitiveFieldvalues() {
        console.log('INSIDE checkCompetitiveFieldvalues');
        console.log(JSON.stringify(this.opportunity));
        if (this.opportunity &&
            this.opportunity.fields.How_competitive_was_the_deal__c.value &&
            this.opportunity.fields.Primary_Competitor__c.value &&
            this.opportunity.fields.Secondary_Competitors__c.value) {
            this.areCompetitiveFieldsPopulated = true;
        } else {
            this.areCompetitiveFieldsPopulated = false;
        }
        console.log('this.areCompetitiveFieldsPopulated ' + this.areCompetitiveFieldsPopulated);
    }

    openCompetitiveFieldsModal() {
        this.isSpinnerLoading = true;
        this.isCompetitiveFieldsModalOpened = true;
    }

    closeCompetitiveFieldsModal() {
        this.isCompetitiveFieldsModalOpened = false;
        this.handleCompetitiveFieldsReset();
    }

    handleCompetitiveFieldsLoad(event) {
        //console.log('INSIDE handleCompetitiveFieldsLoad' + JSON.stringify(event.detail.records));
        this.isSpinnerLoading = false;
        if (this.opportunity && this.opportunity.fields.Primary_Competitor__c.value
            && this.opportunity.fields.Primary_Competitor__c.value.includes('Other')) {
            this.isOtherPrimaryCompetitorRequired = true;
        } else {
            this.isOtherPrimaryCompetitorRequired = false;
        }
        if (this.opportunity && this.opportunity.fields.Primary_Competitor__c.value
            && this.opportunity.fields.Secondary_Competitors__c.value.includes('Others')) {
            this.isOtherSecondaryCompetitorRequired = true;
        } else {
            this.isOtherSecondaryCompetitorRequired = false;
        }
    }

    handlePrimaryCompetitorFieldChange(event) {
        console.log("handlePrimaryCompetitorFieldChange fieldName : " + event.target.fieldName + " , Value : " + event.target.value);
        if (event.target.fieldName === "Primary_Competitor__c" &&
            (event.target.value != null || event.target.value != '') && event.target.value === 'Other') {
            this.isOtherPrimaryCompetitorRequired = true;
        } else {
            this.isOtherPrimaryCompetitorRequired = false;
        }
    }

    handleSecondaryCompetitorFieldChange(event) {
        console.log("handleSecondaryCompetitorFieldChange fieldName : " + event.target.fieldName + " , Value : " + event.target.value);
        if (event.target.fieldName === "Secondary_Competitors__c" &&
            (event.target.value != null || event.target.value != '') && event.target.value.includes("Others")) {
            this.isOtherSecondaryCompetitorRequired = true;
        } else {
            this.isOtherSecondaryCompetitorRequired = false;
        }
    }

    handleCompetitiveFieldsSubmit(event) {
        console.log('INSIDE handleCompetitiveFieldsSubmit');
        console.log(JSON.stringify(event.detail));
        this.isSpinnerLoading = true;
        //this.closeLightningMessages = false;//When uncommneted lightning-messages is not shown
    }

    handleCompetitiveFieldsSuccess(event) {
        console.log('INSIDE handleCompetitiveFieldsSuccess');
        console.log(JSON.stringify(event.detail));
        this.isSpinnerLoading = false;
        this.closeCompetitiveFieldsModal();
    }

    handleCompetitiveFieldsError(event) {
        console.log('INSIDE handleCompetitiveFieldsError');
        console.log(JSON.stringify(event.detail));
        this.isSpinnerLoading = false;
        this.closeLightningMessages = true;
    }

    handleCompetitiveFieldsReset() {
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
        this.closeLightningMessages = false;
    }

    //CR# 4782 END - Bikram - Competitive Tracking

    //CR# 3611 for Special Instruction Modal
    openSpecialInstructionModal() {
        this.isSpinnerLoading = false;
        this.specialInstructionForMultiCloud = true;
    }

    //CR# 3611 for Special Instruction Modal
    closeSpecialInstructionModal() {
        this.specialInstructionForMultiCloud = false;
    }

    //CR# 3611 for Special Instruction Modal
    handleSpecialInstructionModal() {
        this.isSpinnerLoading = false;
    }

    //CR# 3611 for Special Instruction Modal
    handleSpecialInstructionSubmit(event) {
        event.preventDefault();
        this.isSpinnerLoading = true;
        const fields = event.detail.fields;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    //CR# 3611 for Special Instruction Modal
    handleSpecialInstructionSuccess(event) {
        this.isSpinnerLoading = false;
        this.template.querySelector('c-custom-toast-component').showToast('success', 'Record Updated Suucesfully.');
        this.closeSpecialInstructionModal();
        this.handleLoadOpportunityPreQCCehcks(); //CR# 3611 changes for refresh
    }


    handlePOCheckPrimaryQuoteLoad() {
        this.isSpinnerLoading = false;
    }
    handlePOCheckPrimaryQuoteSubmit(event) {
        event.preventDefault();
        var multiCloudIdSameProd = this.preQCWrapper.multipleCloudIdforsameProduct;
        //CR# 3611 changes
        //if((multiCloudIdSameProd && this.poCheckBoxValues.length != 6) ||(!multiCloudIdSameProd && this.poCheckBoxValues.length != 5)){
        if (this.poCheckBoxValues.length != 6) {
            this.poCheckListHasError = true;
            this.poCheckListErrorMsg = '!! Please mark all the checboxes.';
        }
        /*else if(!event.detail.fields.Special_Instructions_to_Finance__c && multiCloudIdSameProd){
            this.poCheckListErrorMsg = '!! Please fill the Special Instruction to Finance field';
        }*/
        else {
            this.isSpinnerLoading = true;
            const fields = event.detail.fields;
            fields.Sales_Declaration_Done__c = true;
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }


    }

    handlePOCheckPrimaryQuoteSuccess(event) {
        this.isSpinnerLoading = false;
        this.poChecklistConfirmed = true;
        this.template.querySelector('c-custom-toast-component').showToast('success', 'Record Updated Suucesfully.');
        this.closePOCheckListModal();
    }



    get isAllStepsPassed() {
        return this.isPrimaryQuoteStepPassed && this.isPRStepPassed && this.isLeagalStepPassed && this.isERStepPassed &&
            this.isPOAttachStepPassed && this.isSOWAttachStepPassed && this.isDeclartionAttachStepPassed && this.checkPOChecklistPassed
            && (!this.checkIfMultipleCloudIds || (this.checkIfMultipleCloudIds && this.checkIfSpecialInstructionsNotRequired))
            && this.areCompetitiveFieldsPopulated;//CR# 4782 - Bikram - Competitive Tracking
    }


    get isAllRestStepsPassed() {
        return this.isPrimaryQuoteStepPassed && this.isPRStepPassed && this.isLeagalStepPassed && this.isERStepPassed &&
            this.isPOAttachStepPassed && this.isSOWAttachStepPassed && this.isDeclartionAttachStepPassed && (!this.checkIfMultipleCloudIds || (this.checkIfMultipleCloudIds && this.checkIfSpecialInstructionsNotRequired));

    }


    get isPrimaryQuoteStepPassed() {
        return this.checkIfPrimaryQuoteExist && this.checkIfQuoteIsApproved;
    }
    get isPRStepPassed() {
        return (!this.checkIfPRRequired) || (this.checkIfPRRequired && this.checkIFPRProvisioned);
    }
    get isLeagalStepPassed() {
        return (!this.islegalNeeded) || (this.islegalNeeded && this.legalApproved);
    }
    get isERStepPassed() {
        return (!this.erApprovalNeeded) || (this.erApprovalNeeded && this.erApprovalStatus);
    }
    get isPOAttachStepPassed() {
        return this.checkIfPOAttached;
    }
    get isSOWAttachStepPassed() {
        return (!this.isSOWRequired) || (this.isSOWRequired && this.isSOWAttached);
    }
    get isDeclartionAttachStepPassed() {
        return (!this.isBillingDeclartionRequired) || (this.isBillingDeclartionRequired && this.isBillingDeclartionAttached);
    }
    get checkPOChecklistPassed() {
        return this.salesDeclarationDone || this.poChecklistConfirmed;
    }


    //CR# 3611
    handleFieldChange(event) {
        this.disableButton = false;
    }




    get primaryQuoteType() {
        return (this.oppRecord != undefined && this.oppRecord.SBQQ__PrimaryQuote__c != null && this.oppRecord.SBQQ__PrimaryQuote__r.SBQQ__Primary__c) ? 'CPQ' : (this.oppRecord != undefined && this.oppRecord.APTS_Primary_Proposal_Lookup__c != null && this.oppRecord.APTS_Primary_Proposal_Lookup__r.Apttus_Proposal__Primary__c ? 'Apttus' : 'None');
    }

    get checkIfPrimaryQuoteExist() {
        console.log('---this.primaryQuoteType--', this.primaryQuoteType);
        return (this.primaryQuoteType == 'CPQ' || this.primaryQuoteType == 'Apttus') ? true : false;
    }

    get checkIfQuoteIsApproved() {
        if (this.primaryQuoteType == 'CPQ') {
            return this.oppRecord != undefined && this.oppRecord.SBQQ__PrimaryQuote__c && (this.oppRecord.SBQQ__PrimaryQuote__r.SBQQ__Status__c == 'Approved' || this.oppRecord.SBQQ__PrimaryQuote__r.SBQQ__Status__c == 'Generated') ? true : false;
        } else if (this.primaryQuoteType == 'Apttus') {
            return this.oppRecord != undefined && this.oppRecord.APTS_Primary_Proposal_Lookup__c && this.oppRecord.APTS_Primary_Proposal_Lookup__r.Apttus_QPApprov__Approval_Status__c == 'Approved' ? true : false;
        }
        return false;
    }

    get primaryQuote() {
        if (this.oppRecord != undefined && this.oppRecord.SBQQ__PrimaryQuote__c != null && this.oppRecord.SBQQ__PrimaryQuote__r.SBQQ__Primary__c) {
            return this.quoteRecordCPQ;
        } else if (this.oppRecord != undefined && this.oppRecord.APTS_Primary_Proposal_Lookup__c != null && this.oppRecord.APTS_Primary_Proposal_Lookup__r.Apttus_Proposal__Primary__c) {
            return this.quoteRecordApttus;
        }
    }

    get quoteRecordCPQ() {
        return this.preQCWrapper != undefined && this.preQCWrapper.hasOwnProperty('primaryQuoteCPQ') ? this.preQCWrapper.primaryQuoteCPQ : undefined;
    }
    get quoteRecordApttus() {
        return this.preQCWrapper != undefined && this.preQCWrapper.hasOwnProperty('primaryQuoteApttus') ? this.preQCWrapper.primaryQuoteApttus : undefined;
    }



    get checkIfPRRequired() {
        return this.preQCWrapper != undefined && this.preQCWrapper.hasOwnProperty('prRequired') && this.preQCWrapper.prRequired == true ? true : false;
    }
    get checkIFPRProvisioned() {
        //CR# 3611 added below if condition
        let check = false;
        let prCheck = true;
        let prgCheck = true;
        if (this.preQCWrapper != undefined && this.preQCWrapper.hasOwnProperty('cloudIdAlreadyProvisionedForUpsell') && this.preQCWrapper.cloudIdAlreadyProvisionedForUpsell) {
            check = true;
        }
        else{
            if (this.preQCWrapper != undefined && this.preQCWrapper.hasOwnProperty('prMAP')) {
                console.log('****prCheck**',prCheck);
                let cloudCatPRList = this.preQCWrapper.prMAP;
                for (let cloudCat in cloudCatPRList) {
                    let prList = cloudCatPRList[cloudCat];
                    console.log('**prList**'+prList);
                    if (prList && prList.length > 0) {
                        for (let pr of prList) {
                            if (pr.Provisioning_Status__c != 'Provisioned' && pr.Provisioning_Status__c != 'Production') {
                                prCheck = false;
                            }
                        }
                    } else {
                        prCheck = false;
                    }
                }
                console.log('****prCheck**',prCheck);
            }
            if(this.preQCWrapper != undefined && this.preQCWrapper.hasOwnProperty('prgMAP') && prCheck == false){
                console.log('****prgCheck**',prgCheck);
                let cloudCatPRList = this.preQCWrapper.prgMAP;
                for (let cloudCat in cloudCatPRList) {
                    let prgList = cloudCatPRList[cloudCat];
                    if (prgList.length > 0) {
                        for (let prg of prgList) {
                            if (prg.Status__c != 'Provisioned') {
                                prgCheck = false;
                            }
                        }
                    } else {
                        prgCheck = false;
                    }
                }
            }
        }
        console.log(check);
        
        return (check || prCheck || prgCheck);
    }
    get prNotRaised() {
        return ((this.prNotRaisedList && this.prNotRaisedList.length > 0)|| (this.prgNotRaisedList && this.prgNotRaisedList.length > 0)) ? true : false;
    }
    get prNotRaisedList() {
        let nonProvPRList = [];
        if (this.preQCWrapper != undefined && this.preQCWrapper.hasOwnProperty('prMAP')) {
            let cloudCatPRList = this.preQCWrapper.prMAP;
            for (let cloudCat in cloudCatPRList) {
                let prList = cloudCatPRList[cloudCat];
                if (prList.length > 0) {
                    for (let pr of prList) {
                        if (pr.Provisioning_Status__c != 'Provisioned' && pr.Provisioning_Status__c != 'Production') {
                            nonProvPRList.push(pr);
                        }
                    }
                }
            }

        }
        return nonProvPRList;
    }
    get prgNotRaisedList() {
        let nonProvPRGList = [];
        if (this.preQCWrapper != undefined && this.preQCWrapper.hasOwnProperty('prgMAP')) {
            let cloudCatPRGList = this.preQCWrapper.prgMAP;
            for (let cloudCat in cloudCatPRGList) {
                let prgList = cloudCatPRGList[cloudCat];
                if (prgList.length > 0) {
                    for (let prg of prgList) {
                        if (prg.Status__c != 'Provisioned') {
                            nonProvPRGList.push(prg);
                        }
                    }
                }
            }

        }
        return nonProvPRGList;
    }
    get prNotRaisedCategoryList() {
        let nonProvPRList = [];
        if (this.preQCWrapper != undefined && (this.preQCWrapper.hasOwnProperty('prMAP') || this.preQCWrapper.hasOwnProperty('prgMAP'))) {
            let cloudCatPRList = this.preQCWrapper.prMAP;
            let cloudCatPRGList = this.preQCWrapper.prgMap;
            for (let cloudCat in cloudCatPRList) {
                let prList = cloudCatPRList[cloudCat];
                if (!prList.length > 0) {
                    nonProvPRList.push(cloudCat);
                }
            }

        }
        return nonProvPRList;
    }

    get islegalNeeded() {
        return this.preQCWrapper != undefined && this.preQCWrapper.hasOwnProperty('isLegalRequired') && this.preQCWrapper.isLegalRequired ? true : false;
    }
    get legalApproved() {
        return this.legalUnApprovedList.length > 0 ? false : true;
    }


    get legalUnApprovedList() {
        let lgList = [];
        if (this.preQCWrapper != undefined && this.preQCWrapper.hasOwnProperty('leagalRecList')) {
            let legalList = this.preQCWrapper.leagalRecList;
            for (let legal of legalList) {
                if (legal.Contract_Execution_Date__c == undefined || legal.Contract_Execution_Date__c == null || legal.Contract_Execution_Date__c == '') {
                    lgList.push(legal);
                }
            }

        }
        return lgList;
    }


    get isAmountWithinSalesTeamThreshold() {
        return this.preQCWrapper != undefined && this.preQCWrapper.hasOwnProperty('oppSaleThresholdPassed') && this.preQCWrapper.oppSaleThresholdPassed ? false : true;
    }
    get isOppMovedToNext() {
        return this.preQCWrapper != undefined && this.preQCWrapper.hasOwnProperty('oppMovedToNext') && this.preQCWrapper.oppMovedToNext ? true : false;
    }

    get headerInfo() {
        let headerDet = '';
        if (this.oppRecord != undefined && this.oppRecord.hasOwnProperty('StageName')) {
            switch (this.oppRecord.StageName) {
                case '5 - Procurement':
                    headerDet = 'Congrats - You are one step closer to receiving a PO'
                    break;
                case stage6Won:
                    headerDet = 'Congrats - You have won the Opportunity'
                    break;
                case stage5A:
                    headerDet = 'Congrats - In Process with Finance.'
                    break;
                default:
                    headerDet = 'Congrats - You are one step closer to receiving a PO.'
            }
        }
        return headerDet;
    }

    get isSystemEditable() {
        return this.oppRecord != undefined && this.oppRecord.hasOwnProperty('StageName') ? this.oppRecord.StageName == '5 - Procurement' || this.oppRecord.StageName == '5C - Sales Rep Action Required' || this.oppRecord.StageName == '4 - Impact Validation' : false;
    }
    get isCurrentStageis5C() {
        return this.oppRecord != undefined && this.oppRecord.hasOwnProperty('StageName') ? this.oppRecord.StageName == '5C - Sales Rep Action Required' : false;
    }
    get isOPPClosedWon() {
        return this.oppRecord != undefined && this.oppRecord.hasOwnProperty('StageName') ? this.oppRecord.StageName == stage6Won : false;
    }
    get isOPPMovedtoFinance() {
        return this.oppRecord != undefined && this.oppRecord.hasOwnProperty('StageName') ? this.oppRecord.StageName == stage5A : false;
    }

    get isSystemReadOnly() {
        return this.isSystemEditable == false ? true : false;
    }



    get erApprovalNeeded() {
        if (this.erServiceEdgeNeeded) {
            return true;
        }
        if (this.erVirtualServiceEdgeNeeded) {
            return true;
        }
        return false;
    }

    get erApprovalStatus() {
        if (this.erServiceEdgeNeeded) {
            if (!this.erServiceEdgeApproved) {
                return false;
            }
        }
        if (this.erVirtualServiceEdgeNeeded) {
            if (!this.erVirtualServiceEdgeApproved) {
                return false;
            }
        }
        return true;
    }


    get unApprovedERList() {
        let erlist = [];
        if (this.erServiceEdgeList) {
            for (let currentItem of this.erServiceEdgeList) {
                if (currentItem.hasOwnProperty('Approval_Status__c') && currentItem.Approval_Status__c != 'Approved') {
                    erlist.push(currentItem);
                }
            }
        }
        if (this.erVirtualServiceEdgeList) {
            for (let currentItem of this.erVirtualServiceEdgeList) {
                if (currentItem.hasOwnProperty('Approval_Status__c') && currentItem.Approval_Status__c != 'Approved') {
                    erlist.push(currentItem);
                }
            }
        }
        return erlist;
    }

    //CR-4827 changed the design from all approval required to atleast one approval
    get erServiceEdgeApproved() {
        if (this.erServiceEdgeList) {
            for (let currentItem of this.erServiceEdgeList) {
                if (currentItem.hasOwnProperty('Approval_Status__c') && currentItem.Approval_Status__c === 'Approved') {
                    return true;
                }
            }
        }
        return false;
    }
    //CR-4827 changed the design from all approval required to atleast one approval
    get erVirtualServiceEdgeApproved() {
        if (this.erVirtualServiceEdgeList) {
            for (let currentItem of this.erVirtualServiceEdgeList) {
                if (currentItem.hasOwnProperty('Approval_Status__c') && currentItem.Approval_Status__c === 'Approved') {
                    return true;
                }
            }
        }
        return false;
    }


    //Check for Multiple could Ids CR# 3611
    get checkIfMultipleCloudIds() {
        return this.preQCWrapper != undefined && this.preQCWrapper.hasOwnProperty('multipleCloudIdforsameProduct') && this.preQCWrapper.multipleCloudIdforsameProduct == true ? true : false;
    }

    //Check for Multiple could Ids CR# 3611
    get checkIfSpecialInstructionsNotRequired() {
        return this.preQCWrapper != undefined && this.preQCWrapper.hasOwnProperty('specialInstructionNotRequired') && this.preQCWrapper.specialInstructionNotRequired == true ? true : (this.preQCWrapper.hasOwnProperty('specialInstructionForMultiCloud') && this.preQCWrapper.specialInstructionForMultiCloud != null ? true : false);
    }

    //Check for Multiple could Ids CR# 3611
    get getOppAccountName() {
        if (this.preQCWrapper != undefined && this.preQCWrapper.hasOwnProperty('oppAccountName')) {
            return this.preQCWrapper.oppAccountName;
        }
        return null;
    }

    //EDI Changes
    get isPOReceivedThroughEDI() {
        return this.oppRecord != undefined && this.oppRecord.PO_Source__c == 'EDI' ? true : false;
    }

    get checkIfPOAttached() {
        return this.oppRecord != undefined && this.oppRecord.PO_Attached__c == true ? true : false;
    }


    get isSOWRequired() {
        return this.preQCWrapper != undefined && this.preQCWrapper.hasOwnProperty('isSOWRequired') && this.preQCWrapper.isSOWRequired == true ? true : false;
    }
    get isSOWAttached() {
        return this.preQCWrapper != undefined && this.preQCWrapper.hasOwnProperty('isSOWAttached') && this.preQCWrapper.isSOWAttached == true ? true : false;
    }


    get isBillingDeclartionRequired() {
        return this.preQCWrapper != undefined && this.preQCWrapper.hasOwnProperty('isBillingCheckRequired') && this.preQCWrapper.isBillingCheckRequired == true ? true : false;
    }
    get isBillingDeclartionAttached() {
        return this.preQCWrapper != undefined && this.preQCWrapper.hasOwnProperty('isBillingDeclarationAttached') && this.preQCWrapper.isBillingDeclarationAttached == true ? true : false;
    }


    get isServiceDateCheckRequired() {
        return this.preQCWrapper != undefined && this.preQCWrapper.hasOwnProperty('isServiceStartDateEarlierProvisionDate') && this.preQCWrapper.isServiceStartDateEarlierProvisionDate == true ? true : false;
    }

    get ottTicketName() {
        return this.preQCWrapper != undefined && this.preQCWrapper.hasOwnProperty('ottTicketName') ? this.preQCWrapper.ottTicketName : undefined;
    }



    get salesDeclarationDone() {
        return this.oppRecord != undefined && this.oppRecord.hasOwnProperty('Sales_Declaration_Done__c') && this.oppRecord.Sales_Declaration_Done__c == true ? true : false;
    }

    get isAmberRoadFailed() {
        return this.preQCWrapper != undefined && this.preQCWrapper.hasOwnProperty('isAmberRoadFailed') && this.preQCWrapper.isAmberRoadFailed == true ? true : false;
    }

    get nsIntegartionSuccess() {
        return this.preQCWrapper != undefined && this.preQCWrapper.hasOwnProperty('nsIntegartionSuccess') && this.preQCWrapper.nsIntegartionSuccess == true ? true : false;
    }




    get isPOFileUpload() {
        return this.fileUploadSource && this.fileUploadSource == 'PO' ? true : false;
    }
    get isSOWFileUpload() {
        return this.fileUploadSource && this.fileUploadSource == 'SOW' ? true : false;
    }
    get isBILLFileUpload() {
        return this.fileUploadSource && this.fileUploadSource == 'BILL' ? true : false;
    }


    get fileUploadHeader() {
        let header = '';
        switch (this.fileUploadSource) {
            case 'PO':
                header = 'Upload PO related Documents'
                break;
            case 'SOW':
                header = 'Upload SOW Documents'
                break;
            case 'BILL':
                header = 'Upload Declaration'
                break;
        }
        return header;
    }

    get fileFieldValue() {
        let header = '';
        switch (this.fileUploadSource) {
            case 'PO':
                header = 'PO_Document'
                break;
            case 'SOW':
                header = 'SOW_Document'
                break;
            case 'BILL':
                header = 'Declaration_Document'
                break;
        }
        return header;
    }


    reDirectToQuoteRecord(event) {
        console.log('---reDirectToQuoteRecord---', event.target.dataset.id);
        if (event.target.dataset.id) {
            if (this.primaryQuoteType == 'CPQ') {
                this.reDirectToRecord('SBQQ__Quote__c', event.target.dataset.id);
            }
            else if (this.primaryQuoteType == 'Apttus') {
                this.reDirectToRecord('Apttus_Proposal__Proposal__c', event.target.dataset.id);
            }
        }
    }
    reDirectToLeaglRecord(event) {
        console.log('---reDirectToLeaglRecord---', event.target.dataset.id);
        if (event.target.dataset.id) {
            this.reDirectToRecord('Legal__c', event.target.dataset.id);
        }
    }
    reDirectToPRRecord(event) {
        console.log('---reDirectToPRRecord---', event.target.dataset.id);
        if (event.target.dataset.id) {
            this.reDirectToRecord('Provisioning_Request__c', event.target.dataset.id);
        }
    }
    reDirectToERRecord(event) {
        console.log('---reDirectToERRecord---', event.target.dataset.id);
        if (event.target.dataset.id) {
            this.reDirectToRecord('Equipment_Request__c', event.target.dataset.id);
        }
    }
    reDirectToRecord(objectAPIName, recordID) {
        if (objectAPIName && recordID) {
            this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                    recordId: recordID,
                    objectApiName: objectAPIName,
                    actionName: 'view'
                }
            });
        }
    }


    handleNavigate() {
        this[NavigationMixin.Navigate]({
            type: "standard__component",
            attributes: {
                componentName: "c__callCreateSalesOrderSalesAuraFromLWC"
            },
            state: {
                c__recordId: this.recordId
            }
        });
    }





    handleUploadFinished(event) {
        let uploadedFiles = event.detail.files;
        if (uploadedFiles) {
            let attachmentArr = [];
            for (let attachment of uploadedFiles) {
                var attachmentObj = {};
                attachmentObj.fileId = attachment.documentId;
                attachmentObj.PathOnClient = attachment.name;
                attachmentObj.Title = attachment.name;
                attachmentObj.fileTitle = attachment.name;
                attachmentArr.push(attachmentObj);
            }
            this.loadedFiles.push(...attachmentArr);
        }

        console.log('---this.modalPOFilesUploaded--', this.modalPOFilesUploaded);
        console.log('---this.modalSOWFilesUploaded--', this.modalSOWFilesUploaded);
        console.log('---this.modalBillFilesUploaded--', this.modalBillFilesUploaded);
    }



    handleSpinnerLoadingOff() {
        this.delayTimeout = setTimeout(() => {
            this.isSpinnerLoading = false;
        }, 10);
    }

    //EDI Changes : Viral
    handlePODetailRedirectClick(event) {
        console.log('---this.handlePODetailRedirectClick called--');
        if (event.currentTarget && event.currentTarget.dataset && event.currentTarget.dataset.id) {
            /*this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                    recordId: event.currentTarget.dataset.id,
                    objectApiName: 'PO_Detail__c',
                    actionName: 'view'
                }
            });*/
            // Make sure the event is only handled here
            event.stopPropagation();
            // Navigate to the Contact object's Recent list view.
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: event.currentTarget.dataset.id,
                    objectApiName: 'PO_Detail__c',
                    actionName: 'view'
                }
            }).then(url => { window.open(url) });
        }
    }

    handleAttachmentClick(event) {
        if (event.currentTarget && event.currentTarget.dataset && event.currentTarget.dataset.id) {
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'filePreview'
                },
                state: {
                    selectedRecordId: event.currentTarget.dataset.id
                }
            });
        }
    }

    handleNewPR() {
        if(this.recordId){
            var compDefinition = {
                componentDef: "c:newTenantComponent",
                attributes: {
                    recordId: this.recordId,
                    accountId : this.accountId
                }
            };
            // Base64 encode the compDefinition JS object
            var encodedCompDef = btoa(JSON.stringify(compDefinition));
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: '/one/one.app#' + encodedCompDef
                }
            });
            
        }
    }

    attachedFileList(src) {
        let poList = [];
        if (this.preQCWrapper != undefined && this.preQCWrapper.hasOwnProperty('attachedFiles')) {
            let poFileList = this.preQCWrapper.attachedFiles;
            for (let poDoc in poFileList) {
                let fileList = poFileList[poDoc];
                if (poDoc == src && fileList.length > 0) {
                    for (let file of fileList) {
                        poList.push(file);
                    }
                }
            }
        }
        return poList;
    }

    /* CR 3970 Start*/

    @wire(fetchOpp, {
        opportunityId: '$recordId'
    })
    getDetails(wireResult) {
        this.isLoading = true;
        const {
            data,
            error
        } = wireResult;
        this.wiredData = wireResult;
        if (data) {

            this.requiredFields = data.requiredFields;
            this.optionalFields = data.optionalFields;
            this.isRequiredFulfilled = data.isRequiredFulfilled;
            this.stageDescription = data.stageDescription;
            this.actorsInvolved = data.actorsInvolved;
            if (data.allowPermissionOverride == true || this.isAllStepsPassed == true)
                this.disabledFlag = false;
            else
                this.disabledFlag = true;
            this.nextStageValue = data.nextStageValue;

            this.prevStageValue = data.prevStageValue;
            this.opp = data.opp;
            this.createdByName = data.createdByName;
            this.ownerName = data.ownerName;
            this.importantLinks = data.importantLinks;
            this.forecastCategory = data.forecastCategory;
            this.daysinCurrentStage = data.daysinCurrentStage;
            this.lastChangedDate = data.lastChangedDate;
            this.recordTypeId = data.recordTypeId;
            if (data.prevStageValue != null && data.prevStageValue != '' && data.allowStageUpdates == true) {
                this.displayRegress = true;
            } else {
                this.displayRegress = false;
            }
            this.isLoading = false;
            this.allowStageUpdates = data.allowStageUpdates;
            if (data.allowStageUpdates == false && data.allowPermissionOverride == false) {
                this.disabledFlag = true;
                this.disablePrevious = true;
            } else if ((data.allowStageUpdates == true && this.isRequiredFulfilled) || data.allowPermissionOverride) {
                this.disabledFlag = false;
                this.disablePrevious = false;
            } else if (data.allowStageUpdates) {
                this.disablePrevious = false;
            }

            if (data.allowClosure || data.allowPermissionOverride) {
                this.disableClosed = false;
            } else {
                this.disableClosed = true;
            }
            console.log('--isLoading--', this.isLoading);
        } else if (error) {
            this.error = error;
            this.hasError = true;
            this.loading = false;
            console.log('error', error);
            if (error.body.message) {
                const event = new ShowToastEvent({
                    title: 'Some unexpected error',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
            }
            this.isLoading = false;
        }
    }

    @wire(getRecord, {
        recordId: strUserId,
        fields: [PROFILE_NAME_FIELD, MANAGER_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            console.log('error--->', error);
        } else if (data) {
            console.log('data--->', data);
            console.log('profile--->', data.fields.Profile.value.fields.Name.value);
            this.profileName = data.fields.Profile.value.fields.Name.value;
            this.managerId = data.fields.ManagerId.value;

        }
    }


    get ShowClosedLostButton() {
        if (this.opportunity) {
            this.stageVal = getFieldValue(this.opportunity, STAGE_FIELD);
        }
        if (strUserId != this.ownerId && this.managerId != strUserId && !hasCloseAccess && this.profileName != 'Core Sales - Deal Desk' && !this.hasUserAccess && this.typeVal == 'Existing Customer (Renewal)') {
            this.disableClosed = true;
        } else {
            this.disableClosed = false;
        }
        return this.stageVal != undefined && (this.stageVal.includes('Closed') || this.stageVal.includes('5D - Approved')) == true ? false : true;
    }

    // CR# 4946 START
    get isModalPOFilesUploaded() {
        return this.modalPOFilesUploaded && this.modalPOFilesUploaded.length > 0;
    }
    // CR# 4946 END

    handleActive(event) {
        this.activeTab = event.target.value;
    }


    handleChildMessage(event) {
        this.modalWindow = false;
        this.isLoading = true;
        refreshApex(this.wiredData);
    }

    handleChildClose(event) {
        this.modalWindow = false;
    }

    openModal(event) {
        this.fieldName = event.currentTarget.dataset.name;
        this.fieldLabel = event.currentTarget.dataset.id;
        this.fieldType = event.currentTarget.dataset.label;
        this.fileName = event.currentTarget.dataset.fileName;
        this.fileId = event.currentTarget.dataset.fileId;
        this.fieldVal = event.currentTarget.dataset.value;
        this.errMsg = event.currentTarget.dataset.errMsg;
        this.allowedValues = event.currentTarget.dataset.allowedValues;
        this.dependentFieldNames = event.currentTarget.dataset.dependentFields;

        console.log(JSON.stringify(event.currentTarget.dataset));
        this.isLoading = false;
        this.modalWindow = true;
        console.log('this.fieldName' + this.fieldName);
        console.log('this.fieldLabel' + this.fieldLabel);
    }

    progressStage(event) {
        this.isLoading = true;
        updateStage({
            opportunityId: this.recordId,
            stageValue: this.nextStageValue
        })
            .then((result) => {

                this.allowPermissionOverride = false;
                const event = new ShowToastEvent({
                    title: 'Opportunity moved to next stage',
                    message: 'Opportunity is moved to next stage',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
                //eval("$A.get('e.force:refreshView').fire();");
                refreshApex(this.wiredData);
                this.updateRecordView(this.recordId);


            })
            .catch((error) => {
                this.error = error;
                this.hasError = true;
                this.loading = false;
                console.log('error', error);
                const event = new ShowToastEvent({
                    title: 'Some unexpected error',
                    message: error,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
                this.isLoading = false;
            });

    }

    regressStage(event) {
        this.isLoading = true;
        updateStage({
            opportunityId: this.recordId,
            stageValue: this.prevStageValue
        })
            .then((result) => {
                this.allowPermissionOverride = false;
                const event = new ShowToastEvent({
                    title: 'Opportunity moved to Prev stage',
                    message: 'Opportunity is moved to Prev stage',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
                //eval("$A.get('e.force:refreshView').fire();");
                refreshApex(this.wiredData);
                this.updateRecordView(this.recordId);

            })
            .catch((error) => {
                this.error = error;
                this.hasError = true;
                this.loading = false;
                console.log('error', error);
                const event = new ShowToastEvent({
                    title: 'Some unexpected error',
                    message: error,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
                this.isLoading = false;
            });

    }

    redirectToRecord(event) {
        let objectAPIName = event.currentTarget.dataset.name;;
        let recordID = event.currentTarget.dataset.id;;
        console.log('--objectAPIName--' + objectAPIName);
        if (objectAPIName && recordID && objectAPIName != 'Object') {
            this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                    recordId: recordID,
                    objectApiName: objectAPIName,
                    actionName: 'view'
                }
            });
        }
        else if (recordID) {
            const config = {
                type: 'standard__webPage',
                attributes: {
                    url: recordID
                }
            };
            this[NavigationMixin.Navigate](config);

        }
        else if (objectAPIName && objectAPIName != 'Object') {
            this[NavigationMixin.Navigate]({
                type: "standard__objectPage",
                attributes: {
                    objectApiName: objectAPIName,
                    actionName: "new"
                },
            });
        }
    }
    /* CR 3970 End */
}
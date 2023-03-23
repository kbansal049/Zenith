import { LightningElement, wire ,track,api} from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import retriveProvisioningDataFromOpp from '@salesforce/apex/ManageProvisioningController.retriveProvisioningDataFromOpp';
import updateProvisioningDetail from '@salesforce/apex/ProvisioningGroupController.updateProvisioningDetail';
import { updateRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { reduceErrorsUpgradedAdvanced } from 'c/ldsUtils';
//197
import fetchDraftPG from '@salesforce/apex/ManageProvisioningController.fetchDraftPG';

import ACCOUNT_ID from '@salesforce/schema/Opportunity.AccountId';
import ACCOUNT_NAME from '@salesforce/schema/Opportunity.Account.Name';
import ACCOUNT_BILLING_COUNTRY from '@salesforce/schema/Opportunity.Account.BillingCountry';
import ACCOUNT_TYPE from '@salesforce/schema/Opportunity.Account.Type';
import ACCOUNT_COMPLIANCE_SCREEN_STATUS from '@salesforce/schema/Opportunity.Account.Amber_Road_Status__c';

import OPP_NAME from '@salesforce/schema/Opportunity.Name';
import OPP_STAGE from '@salesforce/schema/Opportunity.StageName';
import OPP_TYPE from '@salesforce/schema/Opportunity.Type';
import OPP_FED_SYNC from '@salesforce/schema/Opportunity.Is_Federal_Opportunity_Sync__c';

import USER_ID from '@salesforce/user/Id'; 
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';

import getZIAcloud from '@salesforce/apex/ProvisioningGroupController.getZIAcloud';
import retreiveTenantRecFromOpp from '@salesforce/apex/ManageProvisioningController.retreiveTenantRecFromOpp';
import extendPGMethod from '@salesforce/apex/ManageProvisioningController.extendPGMethod';
import decomissionPGMethod from '@salesforce/apex/ManageProvisioningController.decomissionPGMethod';
//197
import updateDraftPGStatus from '@salesforce/apex/ManageProvisioningController.updateDraftPGStatus';
import checkZIAProvisioned from '@salesforce/apex/ManageProvisioningController.checkZIAProvisioned';
import getDataforInfoMessage from '@salesforce/apex/ManageProvisioningController.getDataforInfoMessage';
import getEndDateAndApprovalStatusForPG from '@salesforce/apex/ManageProvisioningController.getEndDateAndApprovalStatusForPG';

import hasSubscriptionPermission from '@salesforce/customPermission/Subscription_Prov_Group_Access';

import ID_FIELD from '@salesforce/schema/Provisioning_Group__c.Id';
import STATUS_FIELD from '@salesforce/schema/Provisioning_Group__c.Status__c';
import SUB_STATUS_FIELD from '@salesforce/schema/Provisioning_Group__c.Sub_Status__c';

import { refreshApex } from '@salesforce/apex';
import TickerSymbol from '@salesforce/schema/Account.TickerSymbol';

const productColumns = [
    {
        label: 'SKU Name',
        fieldName: 'Product_Name__c',
        type: 'text',
        wrapText: true
    },
    {
        label: 'SKU Code',
        fieldName: 'SKU__c',
        type: 'text'
    },
    {
        label: 'Quantity',
        fieldName: 'Quantity__c',
        type: 'text'
    },
    {
        label: 'Start Date',
        fieldName: 'Start_Date__c',
        type: 'date-local'
    },
    {
        label: 'End Date',
        fieldName: 'End_Date__c',
        type: 'date-local'
    },
];

const contactColumns = [
    {
        label: 'Contact Type',
        fieldName: 'Type__c',
        type: 'text',
        wrapText: true
    },
     {
        label: 'Name',
        fieldName: 'User_Name__c',
        type: 'text',
        wrapText: true
    },
    {
        label: 'Email',
        fieldName: 'Email__c',
        type: 'text',
        wrapText: true
    }
];

const decommitionButton = {
    type: "button",
    typeAttributes: {
        label: 'Decommission SKU',
        name: 'DecomissionSKU',
        title: 'Decomission SKU',
        disabled: false,
        value: 'view',
        iconPosition: 'left'
    }
};

const columnsTrialTenant = [...productColumns, decommitionButton];
const columnsTrialTenantNP = [...productColumns];

const defaultActiveAccordianSectionsCount = 5;

export default class ManageProvisioning extends NavigationMixin(LightningElement){
    @api recordId;

    @track hasError = false;
    @track error = false;

    @track acctId;
     isaccountLoaded = true;
    @track acctName;
    @track acctBillingCountry;
    @track acctType;
    @track acctAmberRoadStatus;

    @track isNewTenantBtnDisabled = false;
    @track isCurrentUserProfileAndOpptStageAreInvalid = false;

    @track newTenantBtnDisabledReasons = [];
    @track newTenantBtnDisabledReasonMsg;

    @track optyName;
    @track optyStage;
    @track optyType;
    @track optyFedSync;

    @track pgWrap;
    //197
    @track draftpgWrap;
    @track associatedZIA;
    @track selectedtenant;
    @track pgid;
    @track showSuccess = false;
    @track tenantwrap;
    @track loggedinUserProfile;
    @track isLoaded = true;

    columnsTTNP = columnsTrialTenantNP;
    columnsTT = columnsTrialTenant;
    columnsST = productColumns;
    columnsCC = contactColumns;

    @track extensionReason = '';
    @track endDateValue;

    @track isSubmitForProvisioningBtnIconDisabled = true;
    @track isPushForProvisioningBtnIconDisabled = true;

    @track isDraftPGExists = false;
    @track isPendingPGExists = false;
    @track isProvisionedPGExists = false;

    @track pendingProvisionActiveSections = [];
    @track isPendingExpandAllButtonDisabled = false;
    @track isPendingCollapseAllButtonDisabled = true;
    
    @track provisionedTraialTenantActiveSections = [];
    @track isAtleastOneProvisionedTrailTenantExists = false;
    @track isProvisionedTrailTenantExpandAllButtonDisabled = false;
    @track isProvisionedTrailTenantCollapseAllButtonDisabled = true;

    @track provisionedSubscribedTenantActiveSections = [];
    @track isAtleastOneProvisionedSubscribedTenantExists = false;
    @track isProvisionedSubscribedTenantExpandAllButtonDisabled = false;
    @track isProvisionedSubscribedTenantCollapseAllButtonDisabled = true;

    @track activeTabName;
    @track showManualProcessingMessg;

    isPRGPendingApproval = false;

    @wire(getRecord, {recordId: USER_ID, 
                        fields: [PROFILE_NAME_FIELD]}) 
    wiredUser({error, data}) {
        console.log('wiredUser, data--->', JSON.stringify(data));
        if (data) {
            this.loggedinUserProfile = data.fields.Profile.value.fields.Name.value;
        }
        if (error) {
            this.hasError = true;
            this.error = error;
            this.template.querySelector('c-custom-toast-component').showToast('error', this.errorMessages(error));
        }
    }

    @wire(getRecord, {recordId: '$recordId', 
                        fields: [ACCOUNT_ID, ACCOUNT_NAME, ACCOUNT_BILLING_COUNTRY, 
                                    ACCOUNT_TYPE, ACCOUNT_COMPLIANCE_SCREEN_STATUS, 
                                    OPP_NAME, OPP_STAGE, OPP_TYPE, OPP_FED_SYNC]})
    wiredRecord({error, data}) {
        if (data) {
            console.log('wiredRecord, data--->', JSON.stringify(data));
            this.acctId = getFieldValue(data, ACCOUNT_ID);
            console.log('this.acctid'+this.acctId);
            console.log('this.isaccountLoaded'+this.isaccountLoaded);
            if(this.acctId){
                console.log('now in if '+this.isaccountLoaded);
              this.isaccountLoaded = false;
                console.log('this.acctid'+this.isaccountLoaded);
            }
            this.acctName = getFieldValue(data, ACCOUNT_NAME);
            this.acctBillingCountry = getFieldValue(data, ACCOUNT_BILLING_COUNTRY);
            this.acctType = getFieldValue(data, ACCOUNT_TYPE);
            this.acctAmberRoadStatus = getFieldValue(data, ACCOUNT_COMPLIANCE_SCREEN_STATUS);

            this.optyName = getFieldValue(data, OPP_NAME);
            this.optyStage = getFieldValue(data, OPP_STAGE);
            this.optyType = getFieldValue(data, OPP_TYPE);
            this.optyFedSync = getFieldValue(data, OPP_FED_SYNC);

            this.checkNewTenantBtnVisibility();
        }
        if (error) {
            this.hasError = true;
            this.error = error;
            this.template.querySelector('c-custom-toast-component').showToast('error', this.errorMessages(error));
        }
    }
    
    checkNewTenantBtnVisibility(){
        if(this.acctAmberRoadStatus !== undefined && this.acctAmberRoadStatus !== 'No Match'){
            this.isNewTenantBtnDisabled = true;
            this.newTenantBtnDisabledReasons.push({msg: 'Account compliance screening status, \'' + this.acctAmberRoadStatus + '\' is not eligible for new tenant creation. Please contact dplscreening@zscaler.com for more information.', sno: this.newTenantBtnDisabledReasons.length + 1});
        }
        if(this.acctBillingCountry === undefined || this.acctBillingCountry === null || this.acctBillingCountry === ''){
            this.isNewTenantBtnDisabled = true;
            this.newTenantBtnDisabledReasons.push({msg: 'Account Billing Country is null (or) blank. So please enter Billing Country on Account before new tenant creation.', sno: this.newTenantBtnDisabledReasons.length + 1});
        }
        if(this.acctType !== undefined && !(this.acctType == 'Prospect' || this.acctType == 'Customer')){
            this.isNewTenantBtnDisabled = true;
            this.newTenantBtnDisabledReasons.push({msg: 'Account type, \'' + this.acctType + '\' is not eligible for new tenant creation.', sno: this.newTenantBtnDisabledReasons.length + 1});
        }
        if(this.optyFedSync !== undefined && this.optyFedSync){
            this.isNewTenantBtnDisabled = true;
            this.newTenantBtnDisabledReasons.push({msg: 'Since it\'s a Federal Opportunity, it\'s not eligible for new tenant creation.', sno: this.newTenantBtnDisabledReasons.length + 1});
        }
        //Commented as per IBA-2002
        /*if(this.optyType !== undefined && this.optyType !== 'New Business'){
            this.isNewTenantBtnDisabled = true;
            this.newTenantBtnDisabledReasons.push({msg: 'Since it\'s not a New Business Opportunity, it\'s not eligible for new tenant creation.', sno: this.newTenantBtnDisabledReasons.length + 1});
        }*/
        if(this.loggedinUserProfile !== undefined && this.optyStage !== undefined && this.checkOpportunityStage(this.optyStage)){
            this.isNewTenantBtnDisabled = true;
            this.newTenantBtnDisabledReasons.push({msg: 'Opportunity stage, \'' + this.optyStage + '\' is not eligible for new tenant creation.', sno: this.newTenantBtnDisabledReasons.length + 1});
            this.isCurrentUserProfileAndOpptStageAreInvalid = true;
        }
        
        if(this.newTenantBtnDisabledReasons.length === 1){
            this.newTenantBtnDisabledReasonMsg = this.newTenantBtnDisabledReasons[0].msg;
        }
    }

    checkOpportunityStage(opptStageName){
        if(!(this.loggedinUserProfile === 'Finance v2' 
                || this.loggedinUserProfile === 'System Administrator') 
            && (this.optyStage === '0 - Pipeline Generation' 
                || opptStageName === '5D - Approved, awaiting processing' 
                || opptStageName === '6 - Closed Won' 
                || opptStageName === '7 - Closed Lost')){
            return true;
        }else{
            return false;
        }
    }

    get hasUserSubscriptionPermission(){
        return hasSubscriptionPermission;
    }
    
    connectedCallback() {
        //197
        this.handleDraftPGRecordLoad();

        this.handlePendingPGRecordsLoad();
        this.handleManualProcMessage();

        //After modification, refreshing tenantwrap data using refreshApex
        refreshApex(this.tenantwrap);
    }

    //3697
    handleManualProcMessage(){
            getDataforInfoMessage({oppId: this.recordId})
                .then(result=>{
                    console.log('Printing the result'+result);
                    if(result==true){
                        this.showManualProcessingMessg=true;
                    }else{
                        this.showManualProcessingMessg=false;
                    }
                }

                )
    }

    //197
    handleDraftPGRecordLoad() {
        this.hasError = false;
        fetchDraftPG({oppId: this.recordId})
            .then(result => {
                if(result && result.length > 0){
                    this.isDraftPGExists = true;
                }else{
                    this.isDraftPGExists = false;
                }
                
                this.draftpgWrap = result;
                console.log('--fetchDraftPG--draftpgWrap--', JSON.stringify(this.draftpgWrap));
                if(this.draftpgWrap.hasError){
                    this.hasError = true;
                }
            })
            .catch(error => {
                this.hasError = true;
                this.error = error;
                this.template.querySelector('c-custom-toast-component').showToast('error', this.errorMessages(error));
            });
    }

    handlePendingPGRecordsLoad() {
        this.hasError = false;
        retriveProvisioningDataFromOpp({oppId: this.recordId})
            .then(result => {
                this.pgWrap = result;
                console.log('--retriveProvisioningDataFromOpp--pgWrap--', JSON.stringify(this.pgWrap));

                if(this.pgWrap && this.pgWrap.tenantList && this.pgWrap.tenantList.length > 0){
                    this.isPendingPGExists = true;
                }else{
                    this.isPendingPGExists = false;
                }

                //Praparing the Pending Provisions Active Section Names
                if(this.pgWrap.tenantList.length > defaultActiveAccordianSectionsCount){
                    this.pendingProvisionActiveSections = [];
                    this.isPendingExpandAllButtonDisabled = false;
                    this.isPendingCollapseAllButtonDisabled = true;
                }else{
                    this.populatePendingProvisionsActiveSections();
                    this.isPendingExpandAllButtonDisabled = true;
                    this.isPendingCollapseAllButtonDisabled = false;
                }

                if(this.pgWrap.hasError){
                    this.hasError = true;
                    this.error = this.pgWrap.errorMsg;
                    this.template.querySelector('c-custom-toast-component').showToast('error', this.errorMessages(error));
                }
            })
            .catch(error => {
                this.hasError = true;
                this.error = error;
                this.template.querySelector('c-custom-toast-component').showToast('error', this.errorMessages(error));
            });
    }

    @wire(retreiveTenantRecFromOpp, {opptId: '$recordId', accId: '$acctId'})
    wiredTenantData({error, data}){
        if(data){
            this.tenantwrap = data;
            console.log('7777(A)--wiredTenantData--this.tenantwrap--', JSON.stringify(this.tenantwrap));

            this.isProvisionedPGExists = false;
            if(this.tenantwrap && this.tenantwrap.length > 0){
                this.tenantwrap.forEach(currentItem => {
                    if(currentItem.isTrialTenant){
                        this.isAtleastOneProvisionedTrailTenantExists = true;
                    }else if(currentItem.isScriptionTenant){
                        this.isAtleastOneProvisionedSubscribedTenantExists = true;
                    }
                });

                this.activeTabName = 'Trial Tenants';
                if(this.isAtleastOneProvisionedSubscribedTenantExists){
                    this.activeTabName = 'Subscribed Tenants';
                }

                this.populateProvisionedTenantActiveSections();

                //Praparing the Provisioned Trail tenants active sections
                if(this.provisionedTraialTenantActiveSections.length > defaultActiveAccordianSectionsCount){
                    this.provisionedTraialTenantActiveSections = [];
                    this.isProvisionedTrailTenantExpandAllButtonDisabled = false;
                    this.isProvisionedTrailTenantCollapseAllButtonDisabled = true;
                }else{
                    this.isProvisionedTrailTenantExpandAllButtonDisabled = true;
                    this.isProvisionedTrailTenantCollapseAllButtonDisabled = false;
                }
                
                //Praparing the Provisioned Subscribed tenants active sections
                if(this.provisionedSubscribedTenantActiveSections.length > defaultActiveAccordianSectionsCount){
                    this.provisionedSubscribedTenantActiveSections = [];
                    this.isProvisionedSubscribedTenantExpandAllButtonDisabled = false;
                    this.isProvisionedSubscribedTenantCollapseAllButtonDisabled = true;
                }else{
                    this.isProvisionedSubscribedTenantExpandAllButtonDisabled = true;
                    this.isProvisionedSubscribedTenantCollapseAllButtonDisabled = false;
                }
            }

            this.markassociatedZIA();
            console.log('7777(B)--wiredTenantData, After add--this.tenantwrap--', JSON.stringify(this.tenantwrap));
        }
        if(error){
            this.hasError = true;
            this.error = error;
            this.template.querySelector('c-custom-toast-component').showToast('error', this.errorMessages(error));
        }
    }

    //197
    handleEditDraftPG(event){
        var compDefinition = {
            componentDef: "c:newTenantComponent",
            attributes: {
                recordId: this.recordId,
                draftpgId: event.target.value
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

    //197
    @track tobeArchivedDraftPGId = undefined;
    handleArchiveDraftPG(event){
        this.tobeArchivedDraftPGId = event.target.value;
    }

    closeDraftPGArchiveConfirmationModal(){
        this.tobeArchivedDraftPGId = undefined;
    }
    
    @track showDraftPGStatusUpdationSpinner = false;
    updateDraftPGStatusToArchive(){
        if(this.tobeArchivedDraftPGId){
            this.showDraftPGStatusUpdationSpinner = true;
            updateDraftPGStatus({draftpgId: this.tobeArchivedDraftPGId})
                .then(result=>{
                    if(result == 'Success'){
                        this.showToastMessage('success', ('Selected draft provisioning record archived successfully.'));
                        this.tobeArchivedDraftPGId = undefined;
                        this.showDraftPGStatusUpdationSpinner = false;
                        this.handleDraftPGRecordLoad();
                    }
                })
                .catch(error => {
                    this.tobeArchivedDraftPGId = undefined;
                    this.showDraftPGStatusUpdationSpinner = false;
                    this.hasError = true;
                    this.error = error;
                    this.template.querySelector('c-custom-toast-component').showToast('error', this.errorMessages(error));
                });
        }
    }
    
    showToastMessage(type, errMsg) {
        this.template.querySelector('c-custom-toast-component').showToast(type, errMsg);
    }

    //Show Error Messages on Screen
    errorMessages(error) {
        return reduceErrorsUpgradedAdvanced(error);
    }

    checkPGEndDate(pgId){
        let ApprovalStatus='';
        getEndDateAndApprovalStatusForPG({pgId:pgId})
            .then(result=>{
                console.log('getEndDateAndApprovalStatusForPG',result);
                for (let value of Object.keys(result)) {
                    this.endDateValue = value;
                }
                for (let value of Object.values(result)) {
                    ApprovalStatus =value;
                }
                if(ApprovalStatus=='Submitted'){
                    this.isPRGPendingApproval = true;
                    this.showToastMessage('error',('Extension Request is pending for Approval'));
                    this.error=true;
                    return;
                }else{
                    this.showExtensionModal();
                }
                return  this.endDateValue;
            }).catch(error => {
                this.error = error;
                this.hasError = true;
                this.template.querySelector('c-custom-toast-component').showToast('error', this.errorMessages(error));
            });
    }

    handleAddSKU(event){
        var compDefinition = {
            componentDef: "c:addSKUForProvisioningNew",
            attributes: {
                recordId : event.target.value,
                opportunityId: this.recordId,
            }
        };

        //Base64 encode the compDefinition JS object
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef
            }
        });
    }

    handleChangePlatformSKU(event){
        var compDefinition = {
            componentDef: "c:changeSKUForProvisioning",
            attributes: {
                recordId : event.target.value,
                opportunityId: this.recordId,
            }
        };

        //Base64 encode the compDefinition JS object
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef
            }
        });
    }
    
    handleAddFeature(event){
        var compDefinition = {
            componentDef: "c:addFeatureNonSellableComponent",
            attributes: {
                recordId : event.target.value,
                opportunityId: this.recordId,
            }
        };

        //Base64 encode the compDefinition JS object
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef
            }
        });
    }

    handleExtensionRequest(event){
        this.pgid = event.target.value;
        this.checkPGEndDate(this.pgid);
    }

    handleDecommissionTenant(event){
        this.pgid = event.target.value;
        this.showDecomissionModal()
    }

    handleAssociateZIA(event){
        this.pgid = event.target.value;
        this.showZIASelectModal();
    }

    @track showZIASelectModalPopUp = false;
    showZIASelectModal() {
        this.showZIASelectModalPopUp = true
    }
    closeZIASelectModal() {
        this.showZIASelectModalPopUp = false;
        window.location.reload();
    }

    @track showExtensionModalPopUp = false;
    showExtensionModal() {
        this.showExtensionModalPopUp = true
    }
    closeExtensionModal() {
        this.extensionReason = '';
        this.showExtensionModalPopUp = false;
    }

    @track showDecommisionModalPopUp = false;
    showDecomissionModal() {
        this.showDecommisionModalPopUp = true
    }
    closeDecommisionModal() {
        this.tenantDecommRadioGroupOptionValue = 'No';
        this.isTenantDecommRadioBtnDisabled = true;
        this.showDecommisionModalPopUp = false;
    }

    @wire(getZIAcloud, {accountId: '$acctId'})
    wiredZIACloudList({error, data}){
        if(data){
            var optionsList = [];
            for(var i = 0; i < data.length; i++) {
                var obj = data[i];
                optionsList.push({label: obj.Name, value: obj.Id});
            }
            this.associatedZIA = optionsList;
        }if(error){
            this.hasError = true;
            this.error = error;
            this.template.querySelector('c-custom-toast-component').showToast('error', this.errorMessages(error));
        }
    }

    handleZIAAssociation(event){
        this.selectedtenant = event.detail.value;
    }

    savezia(){
        updateProvisioningDetail({seltenant:this.selectedtenant,pgId:this.pgid,opportunityId:this.opportunityId})
            .then((result)=>{
                if(result == 'Success'){
                    this.showSuccess = true;
                    this.closeZIASelectModal();
                }

                if(result == 'Error'){
                    this.showSuccess = false;
                }

                this.markassociatedZIA();
            }).catch(error => {
                this.error = error;
                this.hasError = true;
                this.template.querySelector('c-custom-toast-component').showToast('error', this.errorMessages(error));
            });
    }

    @track isPrExtBtnDisabled = true;
    handleExtensionReason(event){
        this.extensionReason = event.detail.value;
        if(this.extensionReason === null || this.extensionReason === '' || this.extensionReason.length === 0){
            this.isPrExtBtnDisabled = true;
        }else{
            this.isPrExtBtnDisabled = false;
        }
    }

    @track isPrExtSpinnerLoading = false;
    saveExtension(){
        if(this.extensionReason == null || this.extensionReason == ''){
            this.showToastMessage('error', ('Please provide extension reason.'));
            this.error = true;
            return;
        }else{
            this.isPrExtSpinnerLoading = true;
            extendPGMethod({pgId: this.pgid, extensionReason: this.extensionReason})
                .then(result => {
                    this.showExtensionModalPopUp = false;
                    if(result == true){
                        this.showToastMessage('success', ('Provisioning Group extended successfully.'));
                        setTimeout(() => location.reload(), 3000);
                    }else{
                        this.showToastMessage('info', ('Provisioning Group submitted for extension.'));
                    }
                    this.isPrExtSpinnerLoading = false;
                }).catch(error => {
                    this.error = error;
                    this.hasError = true;
                    this.isPrExtSpinnerLoading = false;
                    this.template.querySelector('c-custom-toast-component').showToast('error', this.errorMessages(error));
                });
        }
    }

    @track isTenantDecommSpinnerLoading = false;
    saveDecommision(){
        if(this.tenantDecommRadioGroupOptionValue == 'No'){
            this.showToastMessage('warning', ('Tenant didn\'t decommissioned.'));
            this.closeDecommisionModal();
            return;
        }else{
            this.isTenantDecommSpinnerLoading = true;
            decomissionPGMethod({pgId: this.pgid})
                .then(result => {
                    this.showDecommisionModalPopUp = false;
                    if(result == true){
                        this.showToastMessage('success', ('Tenant submitted for decommissioning.'));
                        location.reload();
                    }else{
                        this.showToastMessage('info', ('Tenant submitted for decommissioning.'));
                    }
                    this.isTenantDecommSpinnerLoading = false;
                }).catch(error => {
                    this.error = error;
                    this.hasError = true;
                    this.isTenantDecommSpinnerLoading = false;
                    this.template.querySelector('c-custom-toast-component').showToast('error', this.errorMessages(error));
                });
                this.tenantDecommRadioGroupOptionValue = 'No';
        }
    }

    markassociatedZIA(){
        if(this.tenantwrap){
            var tempwrap = [...this.tenantwrap];
            tempwrap = this.tenantwrap.map(this.processtenant);
            this.tenantwrap = tempwrap;
        }
    }

    processtenant(currentItem){
        var item = {...currentItem};
        console.log('222(A) ==>>> Before adding dynamic fields, item val is: '+JSON.stringify(item));

        item.isTTUtilityBtnDisabled = true;
        item.isTTAddFeatureUtilityBtnDisabled = true;
        item.isTTAssociateZIAUtilityBtnDisabled = true;

        if(item.pgWrapper !== undefined 
            && item.pgWrapper.Status__c !== undefined 
            && item.pgWrapper.Product_Line__c !== undefined){

            if(item.pgWrapper.Status__c === 'Provisioned'
                && item.pgWrapper.Approval_Status__c === 'Approved'){
                item.isTTUtilityBtnDisabled = false;
                if(item.pgWrapper.Product_Line__c === 'ZIA' || item.pgWrapper.Product_Line__c === 'ZPA'){
                    item.isTTAddFeatureUtilityBtnDisabled = false;
                }
                if(item.pgWrapper.Product_Line__c === 'ZPA' 
                    && typeof item.pgWrapper.Associated_ZIA_Zscaler_Cloud__c === 'undefined'){
                    item.isTTAssociateZIAUtilityBtnDisabled = false;
                }
            }

            if(item.pgWrapper.Status__c === 'Request Decommission' 
                || item.pgWrapper.Status__c === 'Decommisioned'
                || item.pgWrapper.Status__c === 'Pending Archival'
                || item.pgWrapper.Status__c === 'Archived'
                || item.pgWrapper.Status__c === 'Failed'){
                item.isDecommissionedTenant = true;
            }else if(item.pgWrapper.Status__c === 'Provisioned'){
                item.isProvisionedTenant = true;
            }else{
                item.isNonProvisionedTenant = true;
            }
        }

        item.displayAssociatedCloud = false;
        if(item.pgWrapper !== undefined 
            && item.pgWrapper.Product_Line__c !== undefined 
            && (item.pgWrapper.Product_Line__c === 'ZPA' || item.pgWrapper.Product_Line__c === 'ZDX')
            && item.zscObjWrapper !== undefined 
            && item.zscObjWrapper.Associated_Cloud__c !== undefined){
            item.displayAssociatedCloud = true;
        }
        console.log('222(B) ==>>> After adding dynamic fields, item val is: '+JSON.stringify(item));
        return item;
    }

    navigateToNewTenantComp() {
        console.log(this.recordId+'==accountId='+this.acctId);
        
        var compDefinition = {
            componentDef: "c:newTenantComponent",
            attributes: {
                recordId: this.recordId,
                accountId : this.acctId
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

    navigateToTenantHistoryComp(event) {
        let tenantRec = event.target.value;
        let isScriptionZSTenant = false;
        if(tenantRec.isScriptionTenant){
            isScriptionZSTenant = tenantRec.isScriptionTenant;
        }
        if(tenantRec.zscObjWrapper.Id){
            var compDefinition = {
                componentDef: "c:retrieveCloudHistory",
                attributes: {
                    recordId: tenantRec.zscObjWrapper.Id,
                    oppId: this.recordId,
                    poDetailId: this.pgWrap.poDetailId,
                    isScriptionTenant: isScriptionZSTenant
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

    navigateToOpportunityRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Opportunity',
                actionName: 'view'
            },
        });
    }

    navigateToPRGRecPage(event){
        let prgRecId = event.target.value;
        if(prgRecId){
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    objectApiName: 'Provisioning_Group__c',
                    recordId: prgRecId,
                    actionName: 'view'
                },
            }).then(generatedUrl => {
                window.open(generatedUrl);
            });
        }
    }

    navigateToZSCRecPage(event){
        let zscRecId = event.target.value;
        if(zscRecId){
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    objectApiName: 'Zscaler_Cloud_ID__c',
                    recordId: zscRecId,
                    actionName: 'view'
                },
            }).then(generatedUrl => {
                window.open(generatedUrl);
            });
        }
    }

    //Praparing the Pending Provisions Active Section Names
    populatePendingProvisionsActiveSections(){
        if(this.pgWrap && this.pgWrap.tenantList && this.pgWrap.tenantList.length > 0){
            this.pendingProvisionActiveSections = [];
            this.pgWrap.tenantList.forEach(currentItem => {
                this.pendingProvisionActiveSections.push(currentItem.sectionName);
            });
        }
    }

    //Praparing the Provisioned Tenant Active Section Names
    populateProvisionedTenantActiveSections(){
        if(this.tenantwrap && this.tenantwrap.length > 0){
            this.provisionedTraialTenantActiveSections = [];
            this.provisionedSubscribedTenantActiveSections = [];
            this.tenantwrap.forEach(currentItem => {
                if(currentItem.isTrialTenant && currentItem.zscObjWrapper){
                    this.isProvisionedPGExists = true;
                    this.provisionedTraialTenantActiveSections.push(currentItem.zscObjWrapper.Name);
                }else if(currentItem.isScriptionTenant && currentItem.zscObjWrapper){
                    this.isProvisionedPGExists = true;
                    this.provisionedSubscribedTenantActiveSections.push(currentItem.zscObjWrapper.Name);
                }
            });
        }
    }

    expandAllActiveAccordianSections(event){
        if(event.target.value == 'Pending Provisions Accordian Section'){
            this.populatePendingProvisionsActiveSections();
            this.isPendingExpandAllButtonDisabled = true;
            this.isPendingCollapseAllButtonDisabled = false;
        }else if(event.target.value == 'Provisioned Trail Tenants Accordian Section'){
            this.populateProvisionedTenantActiveSections();
            this.isProvisionedTrailTenantExpandAllButtonDisabled = true;
            this.isProvisionedTrailTenantCollapseAllButtonDisabled = false;
        }else if(event.target.value == 'Provisioned Subscribed Tenants Accordian Section'){
            this.populateProvisionedTenantActiveSections();
            this.isProvisionedSubscribedTenantExpandAllButtonDisabled = true;
            this.isProvisionedSubscribedTenantCollapseAllButtonDisabled = false;
        }
    }

    collapseAllActiveAccordianSections(event){
        if(event.target.value == 'Pending Provisions Accordian Section'){
            this.pendingProvisionActiveSections = [];
            this.isPendingExpandAllButtonDisabled = false;
            this.isPendingCollapseAllButtonDisabled = true;
        }else if(event.target.value == 'Provisioned Trail Tenants Accordian Section'){
            this.provisionedTraialTenantActiveSections = [];
            this.isProvisionedTrailTenantExpandAllButtonDisabled = false;
            this.isProvisionedTrailTenantCollapseAllButtonDisabled = true;
        }else if(event.target.value == 'Provisioned Subscribed Tenants Accordian Section'){
            this.provisionedSubscribedTenantActiveSections = [];
            this.isProvisionedSubscribedTenantExpandAllButtonDisabled = false;
            this.isProvisionedSubscribedTenantCollapseAllButtonDisabled = true;
        }
    }
    
    handleSubmitForProvisioning(event){
        this.isLoaded = false;
        let prgRecId = event.target.value;
        let result1;
        
        checkZIAProvisioned ({zdxPrgId: prgRecId})
        .then(result=>{
            const fields = {};
            fields[ID_FIELD.fieldApiName] = prgRecId;
            fields[SUB_STATUS_FIELD.fieldApiName] = 'Order Created';
            if(result == 'Requested'){
                fields[STATUS_FIELD.fieldApiName] = 'Requested';    
            }
            const recordInput = { fields };
            if(result != 'Error'){
                updateRecord(recordInput)
                .then(() => {
                    this.template.querySelector('c-custom-toast-component').showToast('success', ('Provisioning group record has been submitted for provisioning'));
                    setTimeout(function() {
                        window.location.reload();
                    }, 1000);
                    this.isLoaded = true;
                })
                .catch(error => {
                    this.error = error;
                    this.template.querySelector('c-custom-toast-component').showToast('error', this.errorMessages(error));  
                    this.isLoaded = true;
                });
            }
            else{
                this.template.querySelector('c-custom-toast-component').showToast('error', ('ZIA needs to be provisioned before ZDX'));    
            }
        })
        .catch(error => {
            this.error = error;
            this.template.querySelector('c-custom-toast-component').showToast('error', this.errorMessages(error));
        });
    }
    
    @track tenantDecommRadioGroupOptionValue = 'No';
    get tenantDecommRadioGroupOptions(){
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }

    @track isTenantDecommRadioBtnDisabled = true;
    handleTenantDecommRadioGroupOptionChange(event){
        this.tenantDecommRadioGroupOptionValue = event.detail.value;
        if(this.tenantDecommRadioGroupOptionValue == 'Yes'){
            this.isTenantDecommRadioBtnDisabled = false;
        }else{
            this.isTenantDecommRadioBtnDisabled = true;
        }
    }

    navigateToShowCart(event){
        let recId = event.target.value;
        let generateUrl = window.location.origin + '/apex/ShowCartDetails?id=' + recId;
        window.open(generateUrl, "_blank");
    }

    navigateToWebPage(event){
        const targetURL = event.target.value;
        if(targetURL.includes('<a href=\"') && targetURL.includes('\" target=\"')){
            let actualTargetURL = targetURL.substring(('<a href=\"').length, targetURL.indexOf('\" target=\"'));
            if(actualTargetURL !== undefined){
                const config = {
                    type: 'standard__webPage',
                    attributes: {
                        url: actualTargetURL
                    }
                };
                this[NavigationMixin.Navigate](config);
            }else{
                this.showToastMessage('warning', ('Invalid WebPage URL.'));
            }
        }else{
            this.showToastMessage('warning', ('Invalid WebPage URL.'));
        }
    }

    navigateToPODetailPage(event){
        let poRecId = event.target.value;
        if(poRecId){
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    objectApiName: 'PO_Detail__c',
                    recordId: poRecId,
                    actionName: 'view'
                },
            }).then(generatedUrl => {
                window.open(generatedUrl);
            });
        }    
    }
}
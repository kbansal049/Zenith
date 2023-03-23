import { LightningElement,api,wire,track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { reduceErrorsUpgradedAdvanced } from 'c/ldsUtils';
import retrivePGRecords from '@salesforce/apex/ZscalerCloudIDController.retrivePGRecords';

import NAME_FIELD from '@salesforce/schema/Zscaler_Cloud_ID__c.Name';
import STATUS_FIELD from '@salesforce/schema/Zscaler_Cloud_ID__c.Status__c';
import ACC_FIELD from '@salesforce/schema/Zscaler_Cloud_ID__c.Account__c';

import hasSubscriptionPermission from '@salesforce/customPermission/Subscription_Prov_Group_Access';

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
        type: 'text',
    },
    {
        label: 'Quantity',
        fieldName: 'Quantity__c',
        type: 'text',
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
        wrapText: true,
    },
    {
        label: 'Name',
        fieldName: 'User_Name__c',
        type: 'text',
        wrapText: true,
    },
    {
        label: 'Email',
        fieldName: 'Email__c',
        type: 'text',
        wrapText: true,
    }
];

const approvalHistoryColumns = [
    {
        label: 'Step Name',
        fieldName: 'StepName',
        type: 'text',
        wrapText: true,
    },
    {
        label: 'Date',
        fieldName: 'CreatedDate',
        type: 'date',
        typeAttributes:{
            year: "numeric",
            month: "2-digit",
            day: "2-digit",
            hour: "2-digit",
            minute: "2-digit"
        }
    },
    {
        label: 'Status',
        fieldName: 'StepStatus',
        type: 'text',
        wrapText: true,
    },
    {
        label: 'Assigned To',
        fieldName: 'OriginalActorName',
        type: 'text',
        wrapText: true,
    },
    {
        label: 'Actual Approver',
        fieldName: 'ActorName',
        type: 'text',
        wrapText: true,
    },
    {
        label: 'Comments',
        fieldName: 'Comments',
        type: 'text',
        wrapText: true,
    }
];

export default class RetrieveCloudHistory extends NavigationMixin(LightningElement){
    prodCols = productColumns;
    contCols = contactColumns;
    apprHisCols = approvalHistoryColumns;

    @api recordId;
    @api oppId;
    @api poDetailId;
    @api isScriptionTenant;

    @track cloudRecord;
    @track cloudWrap;

    @track isUtilityBtnsEnabled = false;

    @wire(getRecord, {recordId: '$recordId', fields: [NAME_FIELD, STATUS_FIELD, ACC_FIELD]})
    wiredZscalerCloudDetailRetrieve({ error, data }) {
        if (data) {
            this.cloudRecord = data;
            this.retrivePGRecordDetails();
        } else if (error) {
            this.cloudRecord = undefined;
            this.template.querySelector('c-custom-toast-component').showToast('error', this.errorMessages(error));
        }
    }
    
    async retrivePGRecordDetails() {
        await retrivePGRecords({zCloudID: this.recordId, opptId: this.oppId})
            .then(result => {
                this.cloudWrap = result;
                console.log('---retrivePGRecordDetails--Before add, cloudWrap--', JSON.stringify(this.cloudWrap));

                if(this.cloudWrap !== undefined){
                    if(hasSubscriptionPermission && this.isScriptionTenant){
                        this.isUtilityBtnsEnabled = true;
                    }else{
                        this.isUtilityBtnsEnabled = false;
                    }

                    let isFirstPRG = true;
                    this.cloudWrap.pgList.forEach(function(item){
                        item.prgURL = '/' + item.prg.Id;
                        if(item.prg.Provisioning_Process__c === 'New Tenant'){
                            item.prg.isNewTenantPP = true;
                            item.prg.provisioningProcessSLDS = 'slds-timeline__item_expandable slds-timeline__item_task';
                        }else if(item.prg.Provisioning_Process__c === 'Add SKU'){
                            item.prg.isAddSkuPP = true;
                            item.prg.provisioningProcessSLDS = 'slds-timeline__item_expandable slds-timeline__item_call';
                        }else if(item.prg.Provisioning_Process__c === 'Change Platform SKU'){
                            item.prg.isChangePlanformSkuPP = true;
                            item.prg.provisioningProcessSLDS = 'slds-timeline__item_expandable slds-timeline__item_email';
                        }else if(item.prg.Provisioning_Process__c === 'Decommission'){
                            item.prg.isDecommissionPP = true;
                            item.prg.provisioningProcessSLDS = 'slds-timeline__item_expandable slds-timeline__item_event';
                        }else if(item.prg.Provisioning_Process__c === 'Extension'){
                            item.prg.isExtensionPP = true;
                            item.prg.provisioningProcessSLDS = 'slds-timeline__item_expandable slds-timeline__item_task';
                        }else if(item.prg.Provisioning_Process__c === 'Associate ZIA'){
                            item.prg.isAssociateZiaPP = true;
                            item.prg.provisioningProcessSLDS = 'slds-timeline__item_expandable slds-timeline__item_call';
                        }else if(item.prg.Provisioning_Process__c === 'Convert Trial to Subscription'){
                            item.prg.isConvertTrialToSubscriptionPP = true;
                            item.prg.provisioningProcessSLDS = 'slds-timeline__item_expandable slds-timeline__item_email';
                        }else if(item.prg.Provisioning_Process__c === 'Split PRG for Ramps'){
                            item.prg.isSplitPRGForRampsPP = true;
                            item.prg.provisioningProcessSLDS = 'slds-timeline__item_expandable slds-timeline__item_event';
                        }else if(item.prg.Provisioning_Process__c === 'Cloud Refresh'){
                            item.prg.isCloudRefreshPP = true;
                            item.prg.provisioningProcessSLDS = 'slds-timeline__item_expandable slds-timeline__item_task';
                        }else if(item.prg.Provisioning_Process__c === 'Add Feature'){
                            item.prg.isAddFeaturePP = true;
                            item.prg.provisioningProcessSLDS = 'slds-timeline__item_expandable slds-timeline__item_call';
                        }

                        if(isFirstPRG){
                            item.prg.provisioningProcessSLDS += ' slds-is-open';
                            item.prg.isExpanded = true;
                            isFirstPRG = false;
                        }else{
                            item.prg.isExpanded = false;
                        }

                        if(item.prg.Product_Line__c === 'ZIA'){
                            item.prg.isZIAProvisioning = true;
                        }
                        else{
                            item.prg.isZIAProvisioning = false;
                        }

                        if(typeof item.prg.Associated_ZIA_Zscaler_Cloud__c !== 'undefined'){
                            item.prg.isAssociateZIAZSCValuePresent = true;
                        }
                        else{
                            item.prg.isAssociateZIAZSCValuePresent = false;
                        }

                        if(item.pisWrapList !== undefined && item.pisWrapList.length > 0){
                            item.isApprovalDataPresent = true;
                            item.pisWrapList.forEach((currentPis) => {
                                if(currentPis.processNodeName){
                                    currentPis.StepName = currentPis.processNodeName;
                                }

                                if(currentPis.pis.CreatedDate){
                                    currentPis.CreatedDate = currentPis.pis.CreatedDate;
                                }
                                
                                if(currentPis.pis.StepStatus === 'Started'){
                                    currentPis.StepStatus = 'Submitted';
                                }else{
                                    currentPis.StepStatus = currentPis.pis.StepStatus;
                                }
                                
                                if(currentPis.pis.OriginalActor){
                                    currentPis.OriginalActorName = currentPis.pis.OriginalActor.Name;
                                }

                                if(currentPis.pis.Actor){
                                    currentPis.ActorName = currentPis.pis.Actor.Name;
                                }

                                if(currentPis.pis.Comments){
                                    currentPis.Comments = currentPis.pis.Comments;
                                }
                            });
                        }else{
                            item.isApprovalDataPresent = false;
                        }
                    });
                }
                console.log('---retrivePGRecordDetails--After add, cloudWrap--', JSON.stringify(this.cloudWrap));
            })
            .catch(error => {
                this.template.querySelector('c-custom-toast-component').showToast('error', this.errorMessages(error));
            });
    }

    get cloudName(){
        return this.cloudRecord && this.cloudRecord.fields ?  this.cloudRecord.fields.Name.value : '';
    }

    get existingPGRecords(){
        return this.cloudWrap && this.cloudWrap.pgList && this.cloudWrap.pgList.length > 0 ? this.cloudWrap.pgList : undefined;
    }

    errorMessages(error) {
        return reduceErrorsUpgradedAdvanced(error);
    }

    navigateToCloudRecord(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Zscaler_Cloud_ID__c',
                actionName: 'view'
            },
        });
    }

    handleManageProvisioningNavigate() {
        if(this.oppId){
            var compDefinition = {
                componentDef: "c:manageProvisioning",
                attributes: {
                    recordId: this.oppId,
                    isProvisiongModalOpen : true
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

    handlePRGDetailsExpandedBtn(event){
        let datasetNameAttr = event.currentTarget.dataset.name;
        if(datasetNameAttr !== undefined && this.cloudWrap !== undefined && this.cloudWrap.pgList !== undefined){
            let currentItem;
            for(let i = 0; i < this.cloudWrap.pgList.length; i++){
                if(datasetNameAttr === this.cloudWrap.pgList[i].prg.Id){
                    currentItem = this.cloudWrap.pgList[i];
                    break;
                }
            }
            if(currentItem !== undefined){
                const element = this.template.querySelector(`div [data-target-id="${datasetNameAttr}"]`);
                
                if(element && element.classList && element.classList.contains('slds-is-open')){
                    element.classList.remove('slds-is-open');
                    currentItem.prg.isExpanded = false;
                }else if(element && element.classList && !element.classList.contains('slds-is-open')){
                    element.classList.add('slds-is-open');
                    currentItem.prg.isExpanded = true;
                }
            }
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

    @track isExpandAllButtonDisabled = false;
    @track isCollapseAllButtonDisabled = false;
    handleExpandAllPRGs(){
        let elements = this.template.querySelectorAll(`div [data-target-id`);
        for(let i = 0; i < elements.length; i++){
            let element = elements[i];
            if(element && element.classList && !element.classList.contains('slds-is-open')){
                element.classList.add('slds-is-open');
            }
        }
        for(let i = 0; i < this.cloudWrap.pgList.length; i++){
            this.cloudWrap.pgList[i].prg.isExpanded = true;
        }
        this.isExpandAllButtonDisabled = true;
        this.isCollapseAllButtonDisabled = false;
    }

    handleCollapseAllPRGs(){
        let elements = this.template.querySelectorAll(`div [data-target-id`);
        for(let i = 0; i < elements.length; i++){
            let element = elements[i];
            if(element && element.classList && element.classList.contains('slds-is-open')){
                element.classList.remove('slds-is-open');
            }
        }
        for(let i = 0; i < this.cloudWrap.pgList.length; i++){
            this.cloudWrap.pgList[i].prg.isExpanded = false;
        }
        this.isExpandAllButtonDisabled = false;
        this.isCollapseAllButtonDisabled = true;
    }
}
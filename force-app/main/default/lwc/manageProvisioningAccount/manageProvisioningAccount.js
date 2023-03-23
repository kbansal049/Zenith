import { LightningElement, track,api,wire} from 'lwc';

import retriveProvisioningDataFromAcc from '@salesforce/apex/ManageProvisioningController.retriveProvisioningDataFromAcc';
import retreiveTenantRecFromAcc from '@salesforce/apex/ManageProvisioningController.retreiveTenantRecFromAcc';
import { NavigationMixin } from 'lightning/navigation';
import { reduceErrorsUpgradedAdvanced } from 'c/ldsUtils';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import ACCOUNT_NAME from '@salesforce/schema/Account.Name';

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
    }
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
]

const defaultActiveAccordianSectionsCount = 5;

export default class ManageProvisioningAccount extends NavigationMixin(LightningElement) {
    @api recordId;
    @track accId;
    @track acctName;

    @track error = false;
    @track hasError = false;

    @track pgWrap;
    @track tenantwrap;

    columnsTT = productColumns;
    columnsST = productColumns;
    columnsCC = contactColumns;

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

    connectedCallback(){
        this.handlePGRecordsLoad();
    }

    //Show Error Messages on Screen
    errorMessages(error){
        return reduceErrorsUpgradedAdvanced(error);
    }

    @wire(getRecord, {recordId: '$recordId', fields: [ACCOUNT_NAME]})
    wiredRecord({error, data}){
        if(data){
            console.log('--wiredRecord--data--', JSON.stringify(data));
            this.acctName = getFieldValue(data, ACCOUNT_NAME);
        }
        if(error){
            this.error = error;
            this.template.querySelector('c-custom-toast-component').showToast('error', this.errorMessages(error));
        }
    }

    @wire (retreiveTenantRecFromAcc,{accId: '$recordId'})
    gettenantdata({error, data}){
        if(data){
            this.tenantwrap = data;
            console.log('7777(A)--gettenantdata--this.tenantwrap--', JSON.stringify(this.tenantwrap));

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
            console.log('7777(B)--gettenantdata--this.tenantwrap--', JSON.stringify(this.tenantwrap));
        }
        if(error){
            this.error = error;
            this.template.querySelector('c-custom-toast-component').showToast('error', JSON.stringify(this.errorMessages(error)));
        }
    }

    handlePGRecordsLoad() {
        this.hasError = false;
        retriveProvisioningDataFromAcc({accId: this.recordId})
            .then(result => {
                this.pgWrap = result;
                console.log('--getPGList--pgWrap--', JSON.stringify(this.pgWrap));

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
                    this.template.querySelector('c-custom-toast-component').showToast('error', this.pgWrap.errorMsg);
                }
            })
            .catch(error => {
                this.hasError = true;
                this.error = error;
                this.template.querySelector('c-custom-toast-component').showToast('error', this.errorMessages(error));
            });
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

        if(item.pgWrapper !== undefined 
            && item.pgWrapper.Status__c !== undefined){
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

    get activeTabName(){
        if(this.isAtleastOneProvisionedSubscribedTenantExists){
            return 'Subscribed Tenants';
        }else{
            return 'Trial Tenants';
        }
    }

    navigateToAccountRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Account',
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

    navigateToManageInternalProvisioning(){      
        var compDefinition = {
            componentDef: "c:internalProvisioningComponent",
            attributes: {
                recordId: this.recordId,
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
}
import { LightningElement, wire ,track,api} from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { reduceErrorsUpgradedAdvanced } from 'c/ldsUtils';

import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import fetchInterZscalerAccountid from '@salesforce/apex/ManageProvisioningController.fetchInterZscalerAccountid';
//import fetchInterZscalerAccountid2 from '@salesforce/apex/ManageProvisioningController.fetchInterZscalerAccountid2';

import retreiveTenantRecFromAcc from '@salesforce/apex/ManageProvisioningController.retreiveTenantRecFromAccINT';
import retriveProvisioningDataIntProv from '@salesforce/apex/ManageProvisioningController.retriveProvisioningDataIntProv';



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

const columnsTrialTenant = [...productColumns];
const columnsTrialTenantNP = [...productColumns];

const defaultActiveAccordianSectionsCount = 5;

export default class InternalProvisioningComponent extends NavigationMixin(LightningElement) {
     @api recordId;

    @track activeTabName;
    @track tenantwrap;
    @track pgWrap;
    @track isProvisionedPGExists=false;
    @track isAtleastOneProvisionedTrailTenantExists;
    @track isAtleastOneProvisionedSubscribedTenantExists;
    @track provisionedTraialTenantActiveSections;
    @track showuserselection;
    @track showSuccess=false;
    @api selecteduser;
    @track filterClause;
    @track viewAs='Viewing Tenant as : ';
    @track userId;
    @api selecteduserName;
    @track loggedInuser;
    @track loggedInUserId;
    @api selecteduserEmail;

    columnsTTNP = columnsTrialTenantNP;
    columnsTT = columnsTrialTenant;
    columnsST = productColumns;
    columnsCC = contactColumns;
    fields = ["Name","Email","Phone"];
    displayFields = 'Name, Email, Phone';


     connectedCallback(){
        console.log('display user name'+NAME_FIELD );
        console.log('this.selecteduserName'+this.selecteduserName);
        this.getAccId();
        //this.getAccId2();

        this.filterClause = 'where Profile.UserLicense.name =' + '\'' +'Salesforce' + '\'' + ' OR '+'Profile.UserLicense.name ='+ '\''+ 'Salesforce Platform'+ '\''  ;
    }

    @track accountId;
    @track accountId2;

    getAccId(){
        fetchInterZscalerAccountid({userId :this.userId})
        .then(result=>{
            console.log('Prinitng account id'+result);
            this.accountId=result[0];
            this.accountId2=result[1];
            console.log('internal provisioning account Id--->'+this.accountId);
        })
    }
   /* getAccId2(){
        console.log('inisde get acc 2');
        fetchInterZscalerAccountid2({userId :this.userId})
        .then(result=>{
            console.log('Prinitng account id2'+result);
            this.accountId2=result;
            console.log('internal provisioning account Id2--->'+this.accountId2);
        })
    }*/

      //Show Error Messages on Screen
    errorMessages(error){
        return reduceErrorsUpgradedAdvanced(error);
    }

    @track name;
    @track email;
     @wire(getRecord, {
         recordId: USER_ID,
         fields: [NAME_FIELD,EMAIL_FIELD]
     }) wireuser({
         error,
         data
     }) {
         console.log('selecteduserName->'+this.selecteduserName);
         if (error) {
            this.error = error ; 
         } else if (data) {
            this.loggedInuser=data.fields.Name.value;
            this.loggedInUserId=USER_ID;

             if(this.selecteduserName=='' || this.selecteduserName==null || this.selecteduserName===undefined){
             console.log('printing user-->'+USER_ID);
                this.name = data.fields.Name.value;
                this.email = data.fields.Email.value;
                console.log('Printing email'+this.email);
                this.userId=USER_ID;
             }else{
                 this.name=this.selecteduserName;
                 this.userId=this.selecteduser;
                 this.email=this.selecteduserEmail;
             }
            
             
            console.log('logged n user name'+this.name);

         }
     }

@wire(retriveProvisioningDataIntProv ,{accId:'$accountId' , userId:'$userId'})
    handlePGRecordsonLoad({error , data}) {
        console.log('--handlePGRecordsLoad--called--', this.accountId);
        this.hasError = false;
        console.log('userId-->'+this.userId);
        console.log('accountId55-->'+this.accountId);
        console.log('PRG Data'+data);
        console.log('PRG error'+error);

            if(data){
                this.pgWrap = data;
                console.log('--getPGList--pgWrap--', JSON.stringify(this.pgWrap));
                console.log('this.pgWrap.tenantList.length'+this?.pgWrap?.tenantList?.length);

                if(this.pgWrap && this.pgWrap.tenantList && this?.pgWrap?.tenantList?.length > 0){
                    this.isPendingPGExists = true;
                }else{
                    this.isPendingPGExists = false;
                }
                console.log('--retriveProvisioningDataFromOpp--this.isPendingPGExists--', this.isPendingPGExists);
                console.log('tenantList'+this.pgWrap.tenantList);
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
            }
                
    }


   
    @wire(retreiveTenantRecFromAcc, {accId: '$accountId' ,userid : '$userid'})
    wiredTenantData({error, data}){
        console.log('data------->'+data);
        if(data){
            this.tenantwrap = data;
            console.log('7777(A)--wiredTenantData--this.tenantwrap--', JSON.stringify(this.tenantwrap));

            this.isProvisionedPGExists = false;
            if(this.tenantwrap && this.tenantwrap.length > 0){
               // this.tenantwrap.forEach(currentItem => {
                    //if(currentItem.isTrialTenant){
                      //  this.isAtleastOneProvisionedTrailTenantExists = true;
                    //}else if(currentItem.isScriptionTenant){
                      //  this.isAtleastOneProvisionedSubscribedTenantExists = true;
                    //}
               // });

               // this.activeTabName = 'Trial Tenants';
               // if(this.isAtleastOneProvisionedSubscribedTenantExists){
                //    this.activeTabName = 'Subscribed Tenants';
               // }

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
            console.log('7777(B)--wiredTenantData--this.isProvisionedPGExists--', this.isProvisionedPGExists);

            this.markassociatedZIA();

            console.log('7777(C)--wiredTenantData--this.tenantwrap--', JSON.stringify(this.tenantwrap));
        }
        if(error){
            this.hasError = true;
            console.log('wiredTenantData error--->', error);
            this.error = error;
            this.template.querySelector('c-custom-toast-component').showToast('error', this.errorMessages(error));
        }
    }
   

    
    
     markassociatedZIA(){
        console.log('isnide markassociatedZIA()');
        if(this.tenantwrap){
            var tempwrap = [...this.tenantwrap];
            console.log('inside if');
            tempwrap = this.tenantwrap.map(this.processtenant);
            this.tenantwrap = tempwrap;
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

     //Praparing the Pending Provisions Active Section Names
    populatePendingProvisionsActiveSections(){
        if(this.pgWrap && this.pgWrap.tenantList && this.pgWrap.tenantList.length > 0){
            this.pendingProvisionActiveSections = [];
            this.pgWrap.tenantList.forEach(currentItem => {
                this.pendingProvisionActiveSections.push(currentItem.sectionName);
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
    
    navigateToAccountRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.accountId,
                objectApiName: 'Account',
                actionName: 'view'
            },
        });
    }

    newtenantforinternal(){
        console.log('Printing account'+this.accountId);
        console.log('Printing selected email'+this.email);
         var compDefinition = {
            componentDef: "c:newInternalProvisioningTenant",
            attributes: {
                recordId: this.recordId,
                accountId : this.accountId,
                accountId2 :this.accountId2,
                loggedInuser : this.loggedInuser,
                 selecteduserEmail : this.email,
                 loggedInUserId : this.loggedInUserId,
                 selecteduserNamefordomain:this.name
                
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
    openuserselectionpopup(){
        this.showuserselection=true;
    }

     closeuserselection() {
        this.showuserselection = false;
    }
    closeAndReload(){
        this.showuserselection = false;
        window.location.reload();
    }
    sendUserSelection(){
        
         console.log('inside sendUserSelection');
            var compDefinition = {
                componentDef: "c:internalProvisioningComponent",
                attributes: {
                    selecteduser:this.selecteduser,
                    selecteduserName:this.selecteduserName,
                    selecteduserEmail :this.selecteduserEmail
                    

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
    handleUserSelected(event){
        this.selecteduser=event?.detail?.data?.recordId;
        this.selecteduserName=event?.detail?.data?.record?.Name;
        this.selecteduserEmail=event?.detail?.data?.record?.Email;
        console.log('selecteduser'+this.selecteduser
        );
        console.log('selecteduserName'+this.selecteduserName);
        console.log('onlcick email'+this.selecteduserEmail);
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
    

}
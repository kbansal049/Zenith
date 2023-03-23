import { LightningElement,track, api, wire } from 'lwc';
import createPRrecords from '@salesforce/apex/ProvisioningRequestController.createPRrecords';
import validateForPRComponent from '@salesforce/apex/ProvisioningRequestController.validateForPRComponent';
import getALLPOCProducts from '@salesforce/apex/ProvisioningRequestController.getALLPOCProducts';
import { reduceErrorsUpgradedAdvanced } from 'c/ldsUtils';

import { NavigationMixin } from 'lightning/navigation';
const DELAY = 300;
const columns = [
    { label: 'Product', fieldName: 'Name'},
    { label: 'Product Line', fieldName: 'ProductLine'},
    { label: 'SKU', fieldName: 'ProductCode'},
];

export default class ProvisioningReq extends NavigationMixin(LightningElement) {

    //Opportunity ID
    @api recordId;

    //Wrapper For Setting values
    @track PRValidateWrapper;
    
    //For Spinner
    @track loading = false;

    //For Error Handling
    @track hasError = false;
    @track error;
    

    //POC Screen Products Columns
    @track pocProductsColumns = columns;

    @track mapData= [];

    //Selcted POC products from Datatable
    @track selectedProducts = [];


    @track credList = []; 

    //CehckBox for the Screens
    @track showPRDetailScreen = false;
    @track showPOCProductScreen = false;
    @track showConfirmationScreen = false;

    //Dual List Box Selected Value
    @track selectedCloud = [];
    isPostureControlSelected = false;
    onlyPostureControlSelected = false;


    //
    @track primaryQuotePRCheck = false;


    @track markPrimaryQuoteUncheckReadOnly = false;

    showNumberOfLoads = false;


    //Searching Product
    searchKey;
    //Filtered records available in the data table; valid type is Array
    @track filteredRecords = [];

    index = 0;

    //lookUp componnet
    fields = ["Name","Email","Phone"];
    displayFields = 'Name, Email, Phone';


    connectedCallback() {
        console.log('---opportunity-id---',this.recordId);
        this.showPOCProductScreen = false;
        this.showPRDetailScreen = false;
        this.openProvModal();
        this.addInitialRow();
    }

    addInitialRow(){
        this.credList.push ({
            Type: '',
            Index : this.index,
            RecID : '',
            IsUser : true,
            unfinished : true,
            typeOptionList : this.custtypeoptions,
            filterClause : '',
            isFirst : true
        });
        this.index++;
    }

    addRow(){
        console.log('---addRow--called--');
        let notValid  = this.validateCredDetails();
        console.log('---addRow---validateCredDetails--notValid--',notValid);
        if(!notValid){
            this.credList.push ({
                Type: '',
                Index : this.index,
                RecID : '',
                IsUser : true,
                unfinished : true,
                typeOptionList : this.custtypeoptions
            });
            this.index++;
            this.validateCredDetails();
           
        }else{
            //show error toast here
            if(this.credList && this.credList.length > 0){
                this.template.querySelector('c-custom-toast-component').showToast('error', 'Please verify the details in Credentials');
            }else{
                this.template.querySelector('c-custom-toast-component').showToast('error', 'Please select valid beneficiary for the credentials to be send.');
            }
        }
    }
    
    removeRow(event){
        console.log('---removeRow---',event.currentTarget.dataset.id);
        let ind = event.currentTarget.dataset.id;
        if(ind){
            if(this.credList.length>0)
                this.credList.splice(ind, 1);
            //Reset the index for the splice
            this.index = 0
            for (var i = 0; i < this.credList.length; i++) {
                this.credList[i].Index = this.index;
                this.index++;
            }
        }
    }

   
   
    

    async openProvModal() {
        console.log('----openProvModal---called----');
        this.loading = true;

        await validateForPRComponent({oppId:this.recordId})
        .then(result => {
            console.log('----validateForPRComponent----result--',result);
            this.PRValidateWrapper = result;
            this.loading = false;
            this.showPRDetailScreen = true;
            this.hasError = false;
            
            
        }).catch(error => {
            console.log('----validateForPRComponent----error--',error);
            this.error = error;
            this.loading = false;
            this.hasError = true;
        });
    }

    get domain(){
        return this.PRValidateWrapper && this.PRValidateWrapper.domain ? this.PRValidateWrapper.domain :  undefined;
    }
    get isZPA(){
        return  this.PRValidateWrapper && this.PRValidateWrapper && ( this.PRValidateWrapper.cloud == 'Both' || this.PRValidateWrapper.cloud == 'ZPA' ) ? true : false;
    }
    get isZIA(){
        return  this.PRValidateWrapper && this.PRValidateWrapper && ( this.PRValidateWrapper.cloud == 'Both' || this.PRValidateWrapper.cloud == 'ZIA' ) ? true : false;
    }
    get primaryQuoteExist() {
        return this.PRValidateWrapper && this.PRValidateWrapper.opp && this.PRValidateWrapper.opp.SBQQ__PrimaryQuote__c ? true : false;
    }

    get prCreationForSlection(){
        return this.pocSKU == false ||  this.primaryQuoteExist == false;
    }

    get isPOCProductsExist() {
         return this.PRValidateWrapper && this.PRValidateWrapper.pocProducts && this.PRValidateWrapper.pocProducts.length > 0  ? true : false;
    }

    get pocProductDatatableHeight() {
        return this.filteredRecords && this.filteredRecords.length > 4 ? "height: 400px;" : "height: 200px;";
    }

    get primaryQuoteWithoutPOCProduct(){
        return this.pocSKU == true && this.primaryQuoteExist && this.PRValidateWrapper.cloud == 'None' ? true : false
    }

    get pocProductList() {
        let prdList = [];

        console.log('--this.selectedCloud--',this.selectedCloud);
        console.log('this.PRValidateWrapper',this.PRValidateWrapper);

        if(this.PRValidateWrapper && this.PRValidateWrapper.pocProducts){

            this.PRValidateWrapper.pocProducts.forEach(ele=>{
                if(this.primaryQuoteExist){

                    if(this.pocSKU){
                        prdList.push(ele);
                    }else{
                        if(this.selectedCloud.includes('ZIA')){
                            if(ele.ProductLine == 'ZIA'){
                                prdList.push(ele);
                            } 
                        }
                        if(this.selectedCloud.includes('ZPA')){
                            if(ele.ProductLine == 'ZPA'){
                                prdList.push(ele);
                            } 
                        }
                        if(this.selectedCloud.includes('ZDX')){
                            if(ele.ProductLine == 'ZDX'){
                                prdList.push(ele);
                            } 
                        }
                        if(this.selectedCloud.includes('Workload Protection')){
                            if(ele.ProductLine == 'Workload Protection'){
                                prdList.push(ele);
                            } 
                        }
                        if(this.selectedCloud.includes('ZPA') || this.selectedCloud.includes('ZIA')){
                            if(ele.ProductLine == 'Cross Platform'){
                                prdList.push(ele);
                            } 
                        }
                        if(this.selectedCloud.includes('Posture Control')){
                            if(ele.ProductLine == 'Posture Control'){
                                prdList.push(ele);
                            } 
                        }
                    }
                }else{
                    if(this.selectedCloud.includes('ZIA')){
                        if(ele.ProductLine == 'ZIA'){
                            prdList.push(ele);
                        } 
                    }
                    if(this.selectedCloud.includes('ZPA')){
                        if(ele.ProductLine == 'ZPA'){
                            prdList.push(ele);
                        } 
                    }
                    if(this.selectedCloud.includes('ZDX')){
                        if(ele.ProductLine == 'ZDX'){
                            prdList.push(ele);
                        } 
                    }
                    if(this.selectedCloud.includes('Workload Protection')){
                        if(ele.ProductLine == 'Workload Protection'){
                            prdList.push(ele);
                        } 
                    }
                    if(this.selectedCloud.includes('ZPA') || this.selectedCloud.includes('ZIA')){
                        if(ele.ProductLine == 'Cross Platform'){
                            prdList.push(ele);
                        } 
                    }
                    if(this.selectedCloud.includes('Posture Control')){
                        if(ele.ProductLine == 'Posture Control'){
                            prdList.push(ele);
                        } 
                    }
                }
            });
        }
        return prdList;
        //return this.PRValidateWrapper && this.PRValidateWrapper.pocProducts ? this.PRValidateWrapper.pocProducts : [];
    }
    
    get pocSKU(){
        return this.PRValidateWrapper && this.PRValidateWrapper.checkSKU ? true : false;
    }

    get isFED(){
        return this.PRValidateWrapper && this.PRValidateWrapper.opp  && this.PRValidateWrapper.opp.Is_Federal_Opportunity_Sync__c ? true : false;
    }

    get oppAccountId(){
        return this.PRValidateWrapper && this.PRValidateWrapper.opp ? this.PRValidateWrapper.opp.AccountId : '';
    }

    get oppPartnerAccountId(){
        return this.PRValidateWrapper && this.PRValidateWrapper.opp.Primary_Reseller_Partner__c ? this.PRValidateWrapper.opp.Primary_Reseller_Partner__c : '';
    }

    get customerContactId(){
        return this.PRValidateWrapper && this.PRValidateWrapper.opp && this.PRValidateWrapper.opp.Customer_Contact__c ? this.PRValidateWrapper.opp.Customer_Contact__c : '';
    }
    get seUserId(){
        return this.PRValidateWrapper && this.PRValidateWrapper.opp && this.PRValidateWrapper.opp.SE_Name__c ? this.PRValidateWrapper.opp.SE_Name__c : '';
    }
    get accountOwnerID(){
        return this.PRValidateWrapper && this.PRValidateWrapper.opp && this.PRValidateWrapper.opp.Account && this.PRValidateWrapper.opp.Account.OwnerId ? this.PRValidateWrapper.opp.Account.OwnerId : '';
    }
    get accountManagerID(){
        console.log('---accountManagerID---', this.PRValidateWrapper && this.PRValidateWrapper.opp && this.PRValidateWrapper.opp.Account ? this.PRValidateWrapper.opp.Account.Account_Manager__c : '');
        return this.PRValidateWrapper && this.PRValidateWrapper.opp && this.PRValidateWrapper.opp.Account && this.PRValidateWrapper.opp.Account.Account_Manager__c ? this.PRValidateWrapper.opp.Account.Account_Manager__c : ''; 
    }
    get isSERequired(){
        return this.PRValidateWrapper && this.PRValidateWrapper.isSERequired  ? true : false; 
    }

    get ziaCloudValue() {
        return this.PRValidateWrapper.preferredZIA;
    }

    get associatedZiaCloudValue(){
        if(this.PRValidateWrapper && this.PRValidateWrapper.ziaCloudIdForZPA){
            return this.PRValidateWrapper.ziaCloudIdForZPA;
        }else if(this.PRValidateWrapper){
            this.PRValidateWrapper.ziaCloudIdForZPA = this.associatedZiaCloudsOptions.length > 0 ? this.associatedZiaCloudsOptions[0].value : 'ZPA Only';
            //this.PRValidateWrapper.ziaCloudIdForZPA = 'ZPA Only';
            return this.PRValidateWrapper.ziaCloudIdForZPA;
        }
    }

    get zpaCloudValue(){
        if(this.PRValidateWrapper && this.PRValidateWrapper.preferredZPA){
            return this.PRValidateWrapper.preferredZPA;
        }else if(this.PRValidateWrapper){
            this.PRValidateWrapper.preferredZPA = 'ZPA Production';
            return 'ZPA Production';
        }
    }

    get ziaCloudOptions() {
        return [
            //{ label: '--Select--', value: null },
            { label: 'Zscaler.net', value: 'zscaler.net' },
            { label: 'Zscalerone.net', value: 'zscalerone.net' },
            { label: 'ZscalerTwo.net', value: 'zscalertwo.net' },
            { label: 'Zscalerbeta.net', value: 'zscalerbeta.net' },
            { label: 'Zscloud.net', value: 'zscloud.net' },
            { label: 'Zscalerthree.net', value: 'zscalerthree.net' },
            { label: 'Zscalergov.net', value: 'zscalergov.net' },
        ];
    }

    get zpaCloudOptions() {
        return [
            //{ label: '--Select--', value: null },
            { label: 'ZPA Production', value: 'ZPA Production' },
            { label: 'ZPA Beta', value: 'ZPA Beta' },
        ];
    }
    get isZIACloudReq(){
        return this.PRValidateWrapper.isZIA ? true : false;
    }
    get isZPACloudReq(){
        return this.PRValidateWrapper.isZPA ? true : false; 
    }
    get prCloudOptions() {
        return [
            { label: 'ZIA', value: 'ZIA' },
            { label: 'ZPA', value: 'ZPA' },
            { label: 'ZDX', value: 'ZDX' },
            { label: 'Workload Protection', value: 'Workload Protection' },
            { label: 'Posture Control', value: 'Posture Control' }
        ];
    }

    @track custOptionAvilable = [
            { label: 'Select', value: null },
            { label: 'SE', value: 'SE' },
            { label: 'Customer', value: 'Customer' },
            { label: 'Partner', value: 'Partner' },
            { label: 'Account Manager', value: 'Account Manager' },
            { label: 'Account Owner', value: 'Account Owner' },
        ];


    get associatedZiaCloudsOptions(){
        let optionAvilable = [];
        if(this.PRValidateWrapper && this.PRValidateWrapper.ziaClouds){
            console.log('--ziaClouds--',this.PRValidateWrapper.ziaClouds);
            for(let zc in this.PRValidateWrapper.ziaClouds){
                optionAvilable.push({ label: zc, value: this.PRValidateWrapper.ziaClouds[zc] });
            }
        }
        optionAvilable.push({ label: 'ZPA Only', value: 'ZPA Only' });
        console.log('--optionAvilable--',optionAvilable);
        return optionAvilable;
    }


    get custtypeoptions() {
        let options = [];
        this.custOptionAvilable.forEach(element=>{
            let chk = this.checkIFCredExist(element);
            if(!chk){
                options.push(element); 
            }
        });
        return options;
    }
    

    checkIFCredExist(ele){
        let ret = false;
        if(this.credList && this.credList.length > 0){
            for (var i = 0; i < this.credList.length; i++) {
               if(this.credList[i].Type == ele.label){
                    ret = true;
                    break;
                }
            }
        }
        return ret;
    }


    
   
    get selectedCloudvalues() {
        return this.selectedCloud.length ? this.selectedCloud : 'none';
    }

    handleChangePRCloud(event) {
        this.selectedCloud = event.detail.value;
        this.PRValidateWrapper.preferredCloud = this.selectedCloud;

        let isZPA = false;
        let isZIA = false;
        let isPostureControl = false;
        this.selectedCloud.forEach(ele =>{
            switch(ele) {
                case 'ZPA':
                    isZPA = true;
                    break;
                case 'ZIA':
                    isZIA = true;
                    break;
                case 'ZDX':
                    isZIA = true;
                    break;
                case 'Workload Protection':
                    isZIA = true;
                    break;
                case 'Posture Control':
                    isPostureControl = true;
                    break;
                default:
                    reg = undefined;
            }
        });

        if(isZIA && isZPA){
            this.PRValidateWrapper.cloud = 'Both';
        }else if(isZIA){
            this.PRValidateWrapper.cloud = 'ZIA';
        }else if(isZPA){
            this.PRValidateWrapper.cloud = 'ZPA';
        }
        
        if(isPostureControl){
            this.isPostureControlSelected = true;
            this.showNumberOfLoads = true;
        }

        if(isPostureControl && this.selectedCloud.length==1){
            this.onlyPostureControlSelected = true;
        }
        else{
            this.onlyPostureControlSelected = false;
        }
        
    }


    get credentialList(){
        let credL = this.credList;
        for (var i = 0; i < credL.length; i++) {
            switch(credL[i].Type) {
                case 'Partner':
                    credL[i].IsUser = false;
                    credL[i].filterClause =  this.oppPartnerAccountId ? ('where accountid=\''+this.oppPartnerAccountId+'\'' ) : '';
                    break;
                case 'Customer':
                    credL[i].IsUser = false;
                    credL[i].filterClause =  'where accountid=\''+this.oppAccountId+'\'';
                    break;
                case 'SE':
                    credL[i].IsUser = true;
                    credL[i].filterClause = '';
                    break;
                case 'Account Owner':
                    credL[i].IsUser = true;
                    credL[i].filterClause = '';
                    break;
                 case 'Account Manager':
                    credL[i].IsUser = true;
                    credL[i].filterClause = '';
                    break;
                default:
                    credL[i].IsUser = true;
                    credL[i].filterClause = '';
            }
        }
        console.log('---credL---',credL);
        return credL;
    }

    handleZiaCloudChange(event) {
        this.PRValidateWrapper.preferredZIA = event.detail.value;
    }

    handleZpaCloudChange(event) {
        this.PRValidateWrapper.preferredZPA = event.detail.value;
    }

    handleAssociatedZIACloudChange(event) {
        this.PRValidateWrapper.ziaCloudIdForZPA = event.detail.value;
    }

    handleDomain(event) {
        this.PRValidateWrapper.domain = event.detail.value;        
    }

    handleAddDomain(event){
        this.PRValidateWrapper.additionalDomain = event.detail.value;
    }

    handleAddNoOfLoads(event){
        this.PRValidateWrapper.numberOfLoads = event.detail.value;
    }

    handleSku(event){
        this.PRValidateWrapper.checkSKU = event.target.checked;
        console.log('--this.PRValidateWrapper--',this.PRValidateWrapper);
    }

    handleAddInfo(event){
        this.PRValidateWrapper.additionalInfo = event.detail.value;
    }

    handleTypeChange(event){
        if(event.detail.value){

            console.log('--handleTypeChange.Type--',event.detail.value);

            for (var i = 0; i < this.credList.length; i++) {
                if(i == event.target.dataset.id){
                    this.credList[i].Type = event.detail.value;
                    console.log('--this.credList[i].Type--',this.credList[i].Type);
                    switch(this.credList[i].Type) {
                        case 'Partner':
                            this.credList[i].RecID = '';
                            break;
                        case 'Customer':
                            this.credList[i].RecID =  '';
                            break;
                        case 'SE':
                            this.credList[i].RecID =  this.seUserId;
                            if(this.template.querySelector(`[data-generic-index="${i}"]`)) this.template.querySelector(`[data-generic-index="${i}"]`).triggerChange(this.seUserId);
                            break;
                        case 'Account Owner':
                            this.credList[i].RecID =  this.accountOwnerID;
                            if(this.template.querySelector(`[data-generic-index="${i}"]`)) this.template.querySelector(`[data-generic-index="${i}"]`).triggerChange(this.accountOwnerID);
                            break;
                        case 'Account Manager':
                            this.credList[i].RecID =  this.accountManagerID;
                            if(this.template.querySelector(`[data-generic-index="${i}"]`)) this.template.querySelector(`[data-generic-index="${i}"]`).triggerChange(this.accountManagerID);
                            break;
                        default:
                            this.credList[i].RecID =  '';
                    }
                }
            }
        }
    }

    handleLookup(event){
        if(event.detail.data && event.detail.data.sourceId !=  undefined){
            console.log('---event.detail.data.recordId --',event.detail.data.recordId);
            for (var i = 0; i < this.credList.length; i++) {
                if(i == event.detail.data.sourceId){
                    this.credList[i].RecID = event.detail.data.recordId ? event.detail.data.recordId : '';
                }
            }
        }
    }



    @track selection = [];

    get allSelectedProducts(){
        return this.selection;
    }

    handleSelectedPOCProducts(event) {
        console.log('--handleSelectedPOCProducts called--');
        const selectedRows = event.detail.selectedRows;
        console.log('--selectedRows--',selectedRows);
        this.selectedProducts = [];
        for (let i = 0; i < selectedRows.length; i++) {
            this.selectedProducts.push({
                ProductID: selectedRows[i].ProductID,
                ProductCode: selectedRows[i].ProductCode,
                ProductLine: selectedRows[i].ProductLine,
                prd: selectedRows[i].prd,
                ZScalerProductFamily: selectedRows[i].ZScalerProductFamily,
            })
        }
        console.log('--handleSelectedPOCProducts this.selectedProducts--',this.selectedProducts);
        

        // List of selected items from the data table event.
        let updatedItemsSet = new Set();
        // List of selected items we maintain.
        let selectedItemsSet = new Set(this.selection);
        // List of items currently loaded for the current view.
        let loadedItemsSet = new Set();


        this.filteredRecords.map((event) => {
            loadedItemsSet.add(event.ProductID);
        });

        if (event.detail.selectedRows) {
            event.detail.selectedRows.map((ele) => {
                updatedItemsSet.add(ele.ProductID);
            });

            // Add any new items to the selection list
            updatedItemsSet.forEach((id) => {
                if (!selectedItemsSet.has(id)) {
                    selectedItemsSet.add(id);
                }
            });        
        }


        loadedItemsSet.forEach((id) => {
            if (selectedItemsSet.has(id) && !updatedItemsSet.has(id)) {
                // Remove any items that were unselected.
                selectedItemsSet.delete(id);
            }
        });

        this.selection = [];
        selectedItemsSet.forEach(ele=>{
            this.selection.push(ele);
        });
        this.template.querySelector('[data-id="datarow"]').selectedRows = this.selection;
        console.log('--handleSelectedPOCProducts this.selection--',this.selection);
    }

    handleKeyChange(event) {
        const sKey = event.target.value;
        this.searchKey = sKey;
        if(sKey){
            this.delayTimeout = setTimeout(() => {
               this.filteredRecords = this.pocProductList.filter(rec => JSON.stringify(rec).toLowerCase().includes(this.searchKey.toLowerCase()));
            }, DELAY);
        }else{
            this.filteredRecords = this.pocProductList;
        }
    }

   

    submitPRRequest(){

        let credentialsNotValid  = this.validateCredDetails();
        console.log('---submitPRRequest---validateCredDetails--credentialsNotValid--',credentialsNotValid);
        console.log('---submitPRRequest---this.PRValidateWrapper.selectedCloud--',this.selectedCloud);
        console.log('---submitPRRequest---this.PRValidateWrapper--',this.PRValidateWrapper);
        let postureControlSKUs = [];
        this.selectedProducts.forEach(currentItem => {
            if(currentItem.ProductLine == 'Posture Control'){
                postureControlSKUs.push(currentItem.ProductCode);
            }
        });
        //this.PRValidateWrapper.checkSKU
        if(!this.PRValidateWrapper.preferredCloud && !this.primaryQuoteExist){
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Please select a Product Line to show POC products');
        }else if(!this.domain){
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Please provide domain.');
        }else if(!this.PRValidateWrapper.checkSKU && this.selectedCloud.length == 0 ){
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Kindly select Product Line for PR.');
        }else if(this.isZIA && !this.ziaCloudValue){
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Kindly Select ZIA Cloud');
        }else if(this.isZPA && !this.zpaCloudValue){
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Kindly Select ZPA Cloud');
        }else if(this.isSERequired && !this.credContainsSE) {
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Kindly Select SE in Send Credentials To.');
        }else if(postureControlSKUs.includes('ZPC-ADV-PRE') && 
            (postureControlSKUs.includes('ZPC-IAC-PRE') ||postureControlSKUs.includes('ZPC-VULN-PRE'))){
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Posture Control Advanced cannot be selected with Posture Control Add-ons');
        }
        else if(credentialsNotValid){
            //show error toast here
            if(this.credList && this.credList.length > 0){
                this.template.querySelector('c-custom-toast-component').showToast('error', 'Please verify the details in Credentials');
            }else{
                this.template.querySelector('c-custom-toast-component').showToast('error', 'Please select valid beneficiary for the credentials to be send.');
            }
        }else{
            //Submit the PR
            this.loading = true;
            this.PRValidateWrapper.oppId = this.recordId;
            this.PRValidateWrapper.credDetails = this.credList;
            this.PRValidateWrapper.pocProducts = this.selectedProducts;
            this.PRValidateWrapper.isPostureControlSelected = this.isPostureControlSelected;
            this.PRValidateWrapper.onlyPostureControlSelected = this.onlyPostureControlSelected;
            let dataToSend = JSON.stringify(this.PRValidateWrapper);
            console.log('--submitPRRequest---dataToSend:',dataToSend);
            createPRrecords({jsonStr:dataToSend})
            .then(result => {
                this.loading = false;
                console.log('--createPRrecords---',result);
                var conts = result;
                for(var key in conts){
                    this.mapData.push({value:conts[key], key:key}); //Here we are creating the array to show on UI.
                }
                this.showPRDetailScreen = false;
                this.showPOCProductScreen = false;
                this.showConfirmationScreen = true;
                this.hasError = false;
                this.error = undefined;
            }).catch(error => {
                console.log('---createPRrecords--',error);
                this.loading = false;
                this.error = error;
                this.hasError = true;
            });
        }
    }


    handleBackButton(){
        this.showPRDetailScreen = true;
        this.showPOCProductScreen = false;
    }

    openPOCScreen(){
        let credentialsNotValid  = this.validateCredDetails();
        console.log('---openPOCScreen---validateCredDetails--credentialsNotValid--',credentialsNotValid);
        console.log('---openPOCScreen---this.PRValidateWrapper.selectedCloud--',this.selectedCloud);
        console.log('---openPOCScreen---this.PRValidateWrapper.preferredCloud--',this.PRValidateWrapper.preferredCloud);
        console.log('---openPOCScreen---checkAll--',JSON.stringify(this.PRValidateWrapper));
        console.log('---openPOCScreen---checkSKU--',this.PRValidateWrapper.checkSKU);
        
        //this.PRValidateWrapper.checkSKU
        if(!this.PRValidateWrapper.preferredCloud && !this.primaryQuoteExist){
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Please select a Product Line to show POC products');
        }else if(!this.domain){
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Please provide domain.');
        }else if(!this.PRValidateWrapper.checkSKU && this.selectedCloud.length == 0 ){
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Kindly select Product Line for PR.');
        }
        /*else if(this.checkIFZIAZPACloudNotSelecetd){
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Kindly Select ZIA or ZPA For Product Line');
        }*/
        else if(this.isZIA && !this.ziaCloudValue){
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Kindly Select Preferred ZIA Cloud');
        }else if(this.isZPA && !this.zpaCloudValue){
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Kindly Select Preferred ZPA Cloud');
        }else if(this.isSERequired && !this.credContainsSE) {
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Kindly Select SE in Send Credentials To.');
        }else if(credentialsNotValid){
            //show error toast here
            if(this.credList && this.credList.length > 0){
                this.template.querySelector('c-custom-toast-component').showToast('error', 'Please verify the details in Credentials');
            }else{
                this.template.querySelector('c-custom-toast-component').showToast('error', 'Please select valid beneficiary for the credentials to be send.');
            }
        }else{
            //Load all POC products based on the selection
            this.loadPOCProducts();
        }
    }

    get checkIFZIAZPACloudNotSelecetd(){
        let isZIAZPAExist = false;
        if(this.selectedCloud && this.selectedCloud.length > 0){
            this.selectedCloud.forEach(currentItem => {
                if(currentItem == 'ZIA' || currentItem=='ZPA' ){
                    isZIAZPAExist = true;
                }
            });
        }
        return  isZIAZPAExist ? false : true;
    }


    get credContainsSE(){
        let contSE = false;
        if(this.credList && this.credList.length > 0){
            for (var i = 0; i < this.credList.length; i++) {
                if(this.credList[i].Type == 'SE' && this.credList[i].RecID != '' && this.credList[i].RecID != undefined){
                    contSE = true;
                }
            }
        }
        return contSE;
    }

    async loadPOCProducts(){
        this.loading = true;
        console.log('---loadPOCProducts---PRValidateWrapper--',this.PRValidateWrapper);
        this.PRValidateWrapper.pocProducts = [];
        this.PRValidateWrapper.credDetails = this.credList;
        let dataToSend = JSON.stringify(this.PRValidateWrapper);
        await getALLPOCProducts({jsonStr:dataToSend})
        .then(result => {
            console.log('----loadPOCProducts----result--',result);
            this.PRValidateWrapper = result;
            this.loading = false;

            //Fill PoC products
            this.filteredRecords = this.pocProductList;
            console.log('----loadPOCProducts--this.filteredRecords--',this.filteredRecords);

            this.showPOCProductScreen = true;
            this.showPRDetailScreen =false;

            this.hasError = false;
            this.error = undefined;

        }).catch(error => {
            this.loading = false;
            this.error = error;
            this.hasError = true;
        });
    }



    validateCredDetails(){
        let notValid = 0;
        if(this.credList && this.credList.length > 0){
            for (var i = 0; i < this.credList.length; i++) {
                console.log('---validateCredDetails--- this.credList--', this.credList[i]);
                if(this.credList[i].Type == '' ||  this.credList[i].Type == undefined || this.credList[i].RecID == '' || this.credList[i].RecID == undefined){
                    this.credList[i].unfinished = true;
                    notValid++;
                }else{
                    this.credList[i].unfinished = false;
                }

                if(i == 0){
                    this.credList[i].isFirst = true;
                }else{
                    this.credList[i].isFirst = false;
                }
            }
            console.log('---validateCredDetails---notValid--',notValid);
            return notValid>0 ? true : false;
        }else{
            return true;
        }
    }

    navigateToOpportunityPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Opportunity',
                actionName: 'view'
            }
        });
    }

    rediectToPRRecord(event){
        if(event.target.dataset.id){
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: event.target.dataset.id,
                    objectApiName: 'Provisioning_Request__c',
                    actionName: 'view'
                }
            });
        }

    }

    get errorMessages() {
        return reduceErrorsUpgradedAdvanced(this.error);
    }



    //PO Checklist Methods
    openPrimaryQuoteCheckModal(event){
        this.PRValidateWrapper.checkSKU = event.target.checked;
        this.primaryQuotePRCheck = true;
    }

    closePrimaryQuoteCheckModal() {
        this.primaryQuotePRCheck = false;
    }

    cancelPrimaryQuoteUnCheck(){
        this.PRValidateWrapper.checkSKU = true;
        this.closePrimaryQuoteCheckModal();
    }

    submitPrimaryQuoteUnCheck(){
        this.PRValidateWrapper.checkSKU = false;
        this.markPrimaryQuoteUncheckReadOnly = true;
        this.closePrimaryQuoteCheckModal();
    }

}
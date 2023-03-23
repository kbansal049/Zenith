import { LightningElement,track, api, wire } from 'lwc';
import createNFRrecords from '@salesforce/apex/NFRRequestController.createNFRrecords';
import validateForNFRComponent from '@salesforce/apex/NFRRequestController.validateForNFRComponent';
import getALLPOCProducts from '@salesforce/apex/NFRRequestController.getALLPOCProducts';
import { reduceErrorsUpgradedAdvanced } from 'c/ldsUtils';

import { NavigationMixin } from 'lightning/navigation';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
const DELAY = 300;
const columns = [
    { label: 'Product', fieldName: 'Name'},
    { label: 'Product Line', fieldName: 'ProductLine'},
    { label: 'SKU', fieldName: 'ProductCode'},
];

export default class NfrLicenseReq extends NavigationMixin(LightningElement) {

    //Account ID
    @api recordId;

    //Wrapper For Setting values
    @track NFRValidateWrapper;
    
    //For Spinner
    @track loading = false;

    //For Error Handling
    @track hasError = false;
    @track error;
    
    @track ifPresent = true;

    //POC Screen Products Columns
    @track pocProductsColumns = columns;

    @track mapData= [];

    //Selcted POC products from Datatable
    @track selectedProducts = [];

    @track salesEngineer;

    @track credList = []; 

    @track seCredList = [];

    //CehckBox for the Screens
    @track showPRDetailScreen = false;
    @track showPOCProductScreen = false;
    @track showConfirmationScreen = false;
    @track showAssociatedCloud = false;
    @track showAssociatedCloudFromProdLine =false;
    @track showAssociatedCloudFromDepProduct = false;
    @track dontShowDomainAndZIACloud = false;
    @track isNSS = false;
    @track isCBI = false;
    //Dual List Box Selected Value
    @track selectedCloud = [];
    @track selectedDependencyProducts = [];

    //
    @track primaryQuotePRCheck = false;


    @track markPrimaryQuoteUncheckReadOnly = false;
    //@track dontShowPreferredZiaCloud= false;
    @track showPreferredZiaCloud = false
    //Searching Product
    searchKey;
    //Filtered records available in the data table; valid type is Array
    @track filteredRecords = [];

    @track selectedFilteredRecords = [];

    @track currentDate;

    @track numberOfUsers;
    
    @track contractTerm;
    index = 0;
    
    @track nssAddInfo;

    noAssociatedCloudsPresent = false;

    showZIADependentProducts = false;

    handleStartDate(event){
        
        this.currentDate=event.target.value;
        this.NFRValidateWrapper.startDate = this.currentDate;
        
    }

    handleNoOfUsers(event){
        this.numberOfUsers=event.detail.value;
        this.NFRValidateWrapper.numberOfUsers = this.numberOfUsers;
        
    }

    handleContractTerm(event){
        this.contractTerm=event.detail.value;
        this.NFRValidateWrapper.contractTerm = this.contractTerm;
    }
/**
    handleJustification(event){
        this.justification=event.target.checked;
        this.NFRValidateWrapper.justification =this.justification;
    }

    handleEditions(event){
        this.editions=event.target.checked;
        this.NFRValidateWrapper.editions =this.editions;
    }
 */
    handleNSSComments(event){
        this.nssComments= event.target.value;
        this.NFRValidateWrapper.nssComments =this.nssComments;
        
    }
    //lookUp componnet
    fields = ["Name","Email","Phone"];
    displayFields = 'Name, Email, Phone';


    connectedCallback() {
        this.showPOCProductScreen = false;
        this.showPRDetailScreen = false;
        this.numberOfUsers=50;
        this.contractTerm=12;
        this.openProvModal();
        this.addInitialRow();
        this.setCurrentDate();
    }

    setNSSAddInfo(){
        this.nssComments= "ZIA organization ID + Name:" +""+ "User Count:"+"\n"+"SIEM Solution:"+"\n"+"Cloud-SIEM geo-region:"+"\n"+"Has CFW subscription?";
        this.addInfo = this.nssComments;
    }
    setCurrentDate(){
        let d = new Date();
        let newD = new Date(d.getTime() + d.getTimezoneOffset()*60000);
        this.currentDate = newD.toISOString();

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



        this.seCredList.push ({
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
        let notValid  = this.validateCredDetails();
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
        this.loading = true;

        await validateForNFRComponent({accountId:this.recordId})
        .then(result => {
            this.NFRValidateWrapper = result;
            this.loading = false;
            this.showPRDetailScreen = true;
            this.hasError = false;
            
            
        }).catch(error => {
            this.error = error;
            this.loading = false;
            this.hasError = true;
        });
    }

    get domain(){
        return this.NFRValidateWrapper && this.NFRValidateWrapper.domain ? this.NFRValidateWrapper.domain :  undefined;
    }
    get isZPA(){
        return  this.NFRValidateWrapper && this.NFRValidateWrapper && ( this.NFRValidateWrapper.cloud == 'Both' || this.NFRValidateWrapper.cloud == 'ZPA' ) ? true : false;
    }
    get isZIA(){
        return  this.NFRValidateWrapper && this.NFRValidateWrapper && ( this.NFRValidateWrapper.cloud == 'Both' || this.NFRValidateWrapper.cloud == 'ZIA' ) ? true : false;
    }
    get primaryQuoteExist() {
        return this.NFRValidateWrapper && this.NFRValidateWrapper.opp && this.NFRValidateWrapper.opp.SBQQ__PrimaryQuote__c ? true : false;
    }

    get isPOCProductsExist() {
         return this.NFRValidateWrapper && this.NFRValidateWrapper.pocProducts && this.NFRValidateWrapper.pocProducts.length > 0  ? true : false;
    }

    get pocProductDatatableHeight() {
        return this.filteredRecords && this.filteredRecords.length > 4 ? "height: 300px;" : "height: 200px;";
    }

    get pocSelectedProductDatatableHeight() {
        return this.filteredRecords && this.filteredRecords.length > 4 ? "height: 200px;" : "height: 100px;";
    }

    get primaryQuoteWithoutPOCProduct(){
        return this.pocSKU == true && this.primaryQuoteExist && this.NFRValidateWrapper.cloud == 'None' ? true : false
    }

    get pocProductList() {
        let prdList = [];

        if(this.NFRValidateWrapper && this.NFRValidateWrapper.pocProducts){

            this.NFRValidateWrapper.pocProducts.forEach(ele=>{
                
                    //if(!ele.ProductCode === 'ZIA-CLOUD-NSS' && !ele.ProductCode ==='ZIA-NSS-LOGREC' && ele.ProductCode === 'ZIA-CBI-100' && this.selectedCloud.includes('ZIA')){
                    if(
                        (ele.nssProvisioning == false) 
                        && (ele.cbiProvisioning == false) 
                        && (this.selectedCloud.includes('ZIA'))){
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
                    
                    if(this.selectedDependencyProducts.includes('Cloud NSS') ){
                        if(ele.nssProvisioning == true){
                            prdList.push(ele);
                        } 
                    }
                    if(this.selectedDependencyProducts.includes('CBI') ){
                        if(ele.cbiProvisioning == true){
                            prdList.push(ele);
                        } 
                    }
                
            });

           
        }
        return prdList;
        //return this.NFRValidateWrapper && this.NFRValidateWrapper.pocProducts ? this.NFRValidateWrapper.pocProducts : [];
    }
    
    get pocSKU(){
        return this.NFRValidateWrapper && this.NFRValidateWrapper.checkSKU ? true : false;
    }

    get isFED(){
        return this.NFRValidateWrapper && this.NFRValidateWrapper.opp  && this.NFRValidateWrapper.opp.Is_Federal_Opportunity_Sync__c ? true : false;
    }

    get accountId(){
        return this.NFRValidateWrapper && this.NFRValidateWrapper.accountId ? this.NFRValidateWrapper.accountId : '';
    }

    get customerContactId(){
        return this.NFRValidateWrapper && this.NFRValidateWrapper.opp && this.NFRValidateWrapper.opp.Customer_Contact__c ? this.NFRValidateWrapper.opp.Customer_Contact__c : '';
    }
    get seUserId(){
        return this.NFRValidateWrapper && this.NFRValidateWrapper.opp && this.NFRValidateWrapper.opp.SE_Name__c ? this.NFRValidateWrapper.opp.SE_Name__c : '';
    }
    get accountOwnerID(){
        return this.NFRValidateWrapper && this.NFRValidateWrapper.opp && this.NFRValidateWrapper.opp.Account && this.NFRValidateWrapper.opp.Account.OwnerId ? this.NFRValidateWrapper.opp.Account.OwnerId : '';
    }


    get accountManagerID(){
        return this.NFRValidateWrapper  && this.NFRValidateWrapper.acc && this.NFRValidateWrapper.acc.Account_Manager__c ? this.NFRValidateWrapper.acc.Account_Manager__c : ''; 
    }


    get isSERequired(){
        return this.NFRValidateWrapper && this.NFRValidateWrapper.isSERequired  ? true : false; 
    }

    get ziaCloudValue() {
        return this.NFRValidateWrapper.preferredZIA;
    }

    get associatedZiaCloudValue(){
        if(this.NFRValidateWrapper && this.NFRValidateWrapper.ziaCloudIdForZPA){
            return this.NFRValidateWrapper.ziaCloudIdForZPA;
        }else if(this.NFRValidateWrapper){
            this.NFRValidateWrapper.ziaCloudIdForZPA = this.associatedZiaCloudsOptions.length > 0 ? this.associatedZiaCloudsOptions[0].value : 'ZPA Only';
            //this.NFRValidateWrapper.ziaCloudIdForZPA = 'ZPA Only';
            return this.NFRValidateWrapper.ziaCloudIdForZPA;
        }
    }

    get zpaCloudValue(){
        if(this.NFRValidateWrapper && this.NFRValidateWrapper.preferredZPA){
            return this.NFRValidateWrapper.preferredZPA;
        }else if(this.NFRValidateWrapper){
            this.NFRValidateWrapper.preferredZPA = 'ZPA Production';
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
        return this.NFRValidateWrapper.isZIA ? true : false;
    }
    get isZPACloudReq(){
        return this.NFRValidateWrapper.isZPA ? true : false; 
    }
    get nfrCloudOptions() {
        return [
            { label: 'ZIA', value: 'ZIA' },
            { label: 'ZPA', value: 'ZPA' },
            { label: 'ZDX', value: 'ZDX' },
            { label: 'Workload Protection', value: 'Workload Protection' }
        ];
    }

    get dependencyProductOptions() {
        return [
            { label: 'Cloud NSS', value: 'Cloud NSS'},
            { label: 'CBI', value: 'CBI'}
        ];
    }

    @track custOptionAvilable = [
            { label: 'Select', value: null },
            { label: 'SE/PE', value: 'SE/PE' },
            { label: 'Partner', value: 'Partner' },
            { label: 'Account Manager', value: 'Account Manager' }
        ];


    get associatedZiaCloudsOptions(){
        let optionAvilable = [];
        optionAvilable.push({ label: 'Request New ZIA Tenant', value: 'Request New ZIA Tenant' });
        if(this.NFRValidateWrapper && this.NFRValidateWrapper.ziaClouds){
            for(let zc in this.NFRValidateWrapper.ziaClouds){
                optionAvilable.push({ label: zc, value: this.NFRValidateWrapper.ziaClouds[zc] });
            }
        }
        if(this.NFRValidateWrapper && this.NFRValidateWrapper.ziaClouds.length<1){
            this.noAssociatedCloudsPresent=true;
        }
        //optionAvilable.push({ label: 'ZPA Only', value: 'ZPA Only' });
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
    
    handleChangeNFRCloud(event) {
        this.selectedCloud = event.detail.value;
        this.NFRValidateWrapper.preferredCloud = this.selectedCloud;
        let isZPA = false;
        let isZIA = false;
        let showAssociatedCloudFromProdLine =false;
        //let dontShowDomainAndZIACloud =false;
        //let isCBINSS =false;
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
                /**case 'Cloud NSS':
                   // isZIA = true;
                    isCBINSS =true;
                    break;
                case 'CBI':
                  //  isZIA = true;
                    isCBINSS =true;
                    break;*/    
                default:
                    reg = undefined;
            }
        });

        if(isZIA && isZPA){
            this.NFRValidateWrapper.cloud = 'Both';
        }else if(isZIA){
            this.NFRValidateWrapper.cloud = 'ZIA';
        }else if(isZPA){
            this.NFRValidateWrapper.cloud = 'ZPA';
        }
        /*
        if(isCBINSS && !isZIA){
            dontShowDomainAndZIACloud = true;
        }*/
        
        this.NFRValidateWrapper.selectedCloud = this.selectedCloud;
      /*   if(this.selectedCloud  && this.selectedCloud.length > 1 && this.selectedCloud.includes('ZIA')) ||
            (this.selectedCloud && this.selectedCloud.length > 0 && !this.selectedCloud.includes('ZIA')){
            this.showAssociatedCloudFromProdLine =true;
        }
        else{
            this.showAssociatedCloudFromProdLine =false;
        }
        
        if(this.showAssociatedCloudFromDepProduct || this.showAssociatedCloudFromProdLine){
            this.showAssociatedCloud =true;
        }
        else{
            this.showAssociatedCloud =false;
        }**/
        
        if(this.selectedCloud.length==1){
            //this.dontShowPreferredZiaCloud=false;
            this.showPreferredZiaCloud=true;
            this.showAssociatedCloud =true;
        }else if(this.selectedCloud.length<1){
            this.showPreferredZiaCloud=false;
            this.showAssociatedCloud =false;
        }

        if(this.selectedCloud.includes('ZIA')){
            this.showZIADependentProducts= true;
        }else{
            this.showZIADependentProducts= false;
            this.selectedDependencyProducts = '';
        }

        if(this.NFRValidateWrapper && this.NFRValidateWrapper.ziaClouds.length<1){
            this.noAssociatedCloudsPresent=true;
        }else{
            this.noAssociatedCloudsPresent=false;
        }

        if(this.associatedZiaCloudValue=='Request New ZIA Tenant'){
            //this.dontShowPreferredZiaCloud =true;
            this.showPreferredZiaCloud=true;
        }else{
            this.showPreferredZiaCloud=false;
        }

        //this.dontShowDomainAndZIACloud =dontShowDomainAndZIACloud;
    
    }

    handleChangeDependencyProduct(event) {
        this.selectedDependencyProducts = event.detail.value;
        //this.NFRValidateWrapper.preferredCloud = this.selectedDependencyProducts;

        if (this.selectedDependencyProducts.includes('Cloud NSS')) {
            this.setNSSAddInfo();
        } else {
            this.addInfo = '';
        }
        
        let isNSS = false;
        let isCBI= false;
        //let isZPA = false;
        //let isZIA = false;
        let showAssociatedCloudFromDepProduct =false;
        //let dontShowDomainAndZIACloud =false;
        //let isCBINSS =false;
        this.selectedDependencyProducts.forEach(ele =>{
            switch(ele) {
                case 'Cloud NSS':
                   // isZIA = true;
                   showAssociatedCloudFromDepProduct = true;
                    isNSS =true;
                    break;
                case 'CBI':
                  //  isZIA = true;
                  showAssociatedCloudFromDepProduct =true;
                    isCBI =true;
                    break;    
                default:
                    reg = undefined;
            }
        });

        this.NFRValidateWrapper.selectedDependencyProducts = this.selectedDependencyProducts;
        this.showAssociatedCloudFromDepProduct = showAssociatedCloudFromDepProduct;
        if(this.showAssociatedCloudFromDepProduct || this.showAssociatedCloudFromProdLine){
            this.showAssociatedCloud =true;
        }
        else{
            this.showAssociatedCloud =false;
        }

        if(this.NFRValidateWrapper && this.NFRValidateWrapper.ziaClouds.length<1){
            this.noAssociatedCloudsPresent=true;
        }
        else{
            this.noAssociatedCloudsPresent=false;
        }

        if(this.associatedZiaCloudValue!='Request New ZIA Tenant' && this.selectedDependencyProducts.length>0){
            //this.dontShowPreferredZiaCloud =true;
            this.showPreferredZiaCloud=false;
        }else if(this.selectedDependencyProducts.length==0 || this.selectedDependencyProducts ==''){
            this.showPreferredZiaCloud=true;
        }
        else{
            this.showPreferredZiaCloud=true;
        }
        //this.dontShowDomainAndZIACloud =dontShowDomainAndZIACloud;
    
    }


    get credentialList(){
        let credL = this.credList;
        for (var i = 0; i < credL.length; i++) {
            switch(credL[i].Type) {
                case 'Partner':
                    credL[i].IsUser = false;
                    credL[i].filterClause =  'where accountid=\''+this.accountId+'\'';
                    break;
                case 'SE/PE':
                    credL[i].IsUser = true;
                    credL[i].filterClause = 'where profile.UserLicense.name=\'Salesforce\'';
                    break;
                 case 'Account Manager':
                    credL[i].IsUser = true;
                    credL[i].filterClause = 'where profile.UserLicense.name=\'Salesforce\'';
                    break;
                default:
                    credL[i].IsUser = true;
                    credL[i].filterClause = '';
            }
        }
        return credL;
    }

    get seCredentialList(){


        let credL = this.seCredList;
        for (var i = 0; i < credL.length; i++) {
            if(credL[i].Type=='SE/PE') {
                    credL[i].IsUser = true;
                    credL[i].filterClause = 'where profile.UserLicense.name=\'Salesforce\'';
                    break;
            }
        }


        return credL;
    }

    handleZiaCloudChange(event) {
        this.NFRValidateWrapper.preferredZIA = event.detail.value;
    }

    handleZpaCloudChange(event) {
        this.NFRValidateWrapper.preferredZPA = event.detail.value;
    }

    handleAssociatedZIACloudChange(event) {
        this.NFRValidateWrapper.ziaCloudIdForZPA = event.detail.value;
        /**if(this.associatedZiaCloudValue!='Request New ZIA Tenant'){
            //this.dontShowPreferredZiaCloud =true;
            this.showPreferredZiaCloud=false;
        }else if(this.associatedZiaCloudValue=='Request New ZIA Tenant' && !this.selectedCloud.includes('ZIA') || 
                this.associatedZiaCloudValue=='Request New ZIA Tenant' && this.selectedCloud.includes('ZIA') && this.selectedCloud.length>1 ){
            //this.dontShowPreferredZiaCloud =false;
            this.showPreferredZiaCloud=true;
        }else if(!this.selectedCloud.includes('ZIA') && this.selectedCloud.length>2){
            //this.dontShowPreferredZiaCloud =false;
            this.showPreferredZiaCloud=true;
        }*/
        if(this.associatedZiaCloudValue=='Request New ZIA Tenant'){
            //this.dontShowPreferredZiaCloud =true;
            this.showPreferredZiaCloud=true;
        }else{
            this.showPreferredZiaCloud=false;
        }
    }
            

    handleDomain(event) {
        this.NFRValidateWrapper.domain = event.detail.value;        
    }

    handleAddDomain(event){
        this.NFRValidateWrapper.additionalDomain = event.detail.value;
    }

    handleSku(event){
        this.NFRValidateWrapper.checkSKU = event.target.checked;
    }

    handleAddInfo(event){
        this.NFRValidateWrapper.additionalInfo = event.detail.value;
    }

    handleTypeChange(event){
        if(event.detail.value){

            for (var i = 0; i < this.credList.length; i++) {
                if(i == event.target.dataset.id){
                    this.credList[i].Type = event.detail.value;
                    switch(this.credList[i].Type) {
                        case 'Partner':
                            this.credList[i].RecID = '';
                            break;
                        case 'SE/PE':
                                this.credList[i].RecID =  '';
                                if(this.template.querySelector(`[data-generic-index="${i}"]`)) this.template.querySelector(`[data-generic-index="${i}"]`).triggerChange('null');
                                //if(this.template.querySelector(`[data-generic-index="${i}"]`)) this.template.querySelector(`[data-generic-index="${i}"]`).triggerChange(this.seUserId);
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
        if(event.detail.data && event.detail.data.sourceId !==  undefined){
            for (var i = 0; i < this.credList.length; i++) {
                if(i === event.detail.data.sourceId){
                    this.credList[i].RecID = event.detail.data.recordId ? event.detail.data.recordId : '';
                }
            }
        }
    }

    handleSELookup(event){
        this.salesEngineer = event.detail.data.recordId;
        this.NFRValidateWrapper.salesEngineer = this.salesEngineer;
        /**if(event.detail.data && event.detail.data.sourceId !==  undefined){
            for (var i = 0; i < this.credList.length; i++) {
                if(i === event.detail.data.sourceId){
                    this.salesEngineer = event.detail.data.recordId ? event.detail.data.recordId : '';
                    console.log('reached');
                }
            }
        }*/
    }



    @track selection = [];

    get allSelectedProducts(){
        return this.selection;
    }


    @track productSKUMap = {};

    @track selectedItemsList =[];

    handleSelectedPOCProducts(event) {
        const selectedRows = event.detail.selectedRows;
        
        this.productSKUMap = {};

        //this.selectedProducts = [];

        //this.selectedItemsList = [];
        
        // Code changes by Nagesh //
        this.prepareSelectedItemsList(selectedRows);


        this.selectedProductsUpdated.forEach(ele => {
            let productSKUList = [];

            if (
                ((ele.nssProvisioning == false) && (ele.cbiProvisioning == false))
                
                && (

                    ((this.selectedCloud.includes('ZIA')) && (ele.ProductLine === 'ZIA'))
                || ((this.selectedCloud.includes('ZPA')) && (ele.ProductLine === 'ZPA'))
                || ((this.selectedCloud.includes('ZDX')) && (ele.ProductLine === 'ZDX'))
                || ((this.selectedCloud.includes('Workload Protection')) && (ele.ProductLine === 'Workload Protection'))
                || ((((this.selectedCloud.includes('ZPA')) || (this.selectedCloud.includes('ZIA'))) && (ele.ProductLine === 'Cross Platform')))

                )    
                
            ) {
                if (this.productSKUMap.hasOwnProperty(ele.ProductLine)) {
                    productSKUList = this.productSKUMap[ele.ProductLine];
                }
                productSKUList.push(ele.ProductCode);
                this.productSKUMap[ele.ProductLine] = productSKUList;

            }
            else if(ele.nssProvisioning == true){
                
                if (this.productSKUMap.hasOwnProperty('Cloud NSS')) {
                    productSKUList = this.productSKUMap['Cloud NSS'];
                }

                productSKUList.push(ele.ProductCode);

                this.productSKUMap['Cloud NSS'] = productSKUList;

            }
            else if(ele.cbiProvisioning == true){
               
                if (this.productSKUMap.hasOwnProperty('CBI')) {
                    productSKUList = this.productSKUMap['CBI'];
                }


                productSKUList.push(ele.ProductCode);

                this.productSKUMap['CBI'] = productSKUList;

            }
        });
        
        selectedRows.forEach(ele => {

            this.selectedProducts.push({
                ProductID: ele.ProductID,
                ProductCode: ele.ProductCode,
                ProductLine: ele.ProductLine,
                prd: ele.prd

            })
            
        });

        this.NFRValidateWrapper.cloudSkuMap = this.productSKUMap;

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


        //selectedFilteredRecords

        let selectedFilteredRecordsArr = [];
       
        this.filteredRecords.map((ele) => {
            loadedItemsSet.add(ele.ProductID);
        });

        //console.log('-=- selectedFilteredRecordsArr =-= '+JSON.stringify(selectedFilteredRecordsArr));

        //this.selectedItemsList = selectedFilteredRecordsArr;

        //this.template.querySelector('[data-id="datarow1"]').selectedRows = this.selection;
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

    showToastMessage(type, errMsg) {
        this.template.querySelector('c-custom-toast-component').showToast(type, errMsg);
    }

    

    submitNFRRequest(){

        let credentialsNotValid  = this.validateCredDetails();
       
        let hasError = false;

        //let tempArray = this.selectedProductsUpdated;
       // tempArray = tempArray.filter(item => item.ProductId.Id !== e.target.value);   

        // let tempArray = [];
        // let tempArrayProductId = [];

        // this.selectedProductsUpdated.forEach(ele => {

            

        //     if (!tempArrayProductId.includes(ele.ProductId.Id)) {
        //         tempArray.push(ele);

        //         tempArrayProductId.push(ele.ProductId.Id);
        //     }

            




        // });

        // console.log('-=- tempArrayProductId -=- '+tempArrayProductId);
        // console.log('-=- tempArray -=- '+JSON.stringify(tempArray));

        // this.selectedProductsUpdated = [];
        // this.selectedProductsUpdated = tempArray;



        if(this.selectedCloud.includes('ZIA') && this.selectedDependencyProducts.length===0 && !this.productSKUMap.hasOwnProperty('ZIA')){
            this.showToastMessage('error', ('Please select a product for ZIA'));
            hasError = true;
            //return false; 
        }
        else if(this.selectedCloud.includes('ZIA') && this.selectedDependencyProducts.length > 0
         && this.selectedDependencyProducts.includes('Cloud NSS') && !this.productSKUMap.hasOwnProperty('Cloud NSS')){
            this.showToastMessage('error', ('Please select a product for Cloud NSS'));
            hasError = true;
            //return false;
         }
         else if(this.selectedCloud.includes('ZIA') && this.selectedDependencyProducts.length>0
         && this.selectedDependencyProducts.includes('CBI') && !this.productSKUMap.hasOwnProperty('CBI')){
            this.showToastMessage('error', ('Please select a product for CBI'));
            hasError = true;
            //return false;
         }
         else if(this.selectedCloud.includes('ZPA')  && !this.productSKUMap.hasOwnProperty('ZPA')){
            this.showToastMessage('error', ('Please select a product for ZPA'));
            hasError = true;
        }
        else if(this.selectedCloud.includes('ZDX')  && !this.productSKUMap.hasOwnProperty('ZDX')){
            this.showToastMessage('error', ('Please select a product for ZDX'));
            hasError = true;
        }
        else if(this.selectedCloud.includes('Workload Protection') && !this.productSKUMap.hasOwnProperty('Workload Protection')){
            this.showToastMessage('error', ('Please select a product for Workload Protection'));
            hasError = true;
        }
        else{
            hasError = false;
            
        }
         /**
        this.selectedCloud.every(ele => {
            if (!this.productSKUMap.hasOwnProperty(ele) && !this.productSKUMap.hasOwnProperty('ZIA')) {
                this.showToastMessage('error', ('Please select a product for ' + ele));
                console.log('hasError1'+hasError);
                hasError = true;
                return false;       
            }else if (!this.productSKUMap.hasOwnProperty(ele) && this.productSKUMap.hasOwnProperty('ZIA') && this.selectedDependencyProducts.length==0 ) {
                this.showToastMessage('error', ('Please select a product for ' + ele));
                console.log('hasError12'+hasError);
                hasError = true;
                return false;
                
            }else{
                console.log('hasError123'+hasError);
                hasError = false;
                return true;
                
            }
            
        });
        
        this.selectedDependencyProducts.every(ele => {
            console.log('this.productSKUMap'+JSON.stringify(this.productSKUMap));
            console.log('this.productSKUMap.hasOwnProperty(ele)'+this.productSKUMap.hasOwnProperty(ele));
            console.log('this.productSKUMap.hasOwnProperty(ZIA)'+this.productSKUMap.hasOwnProperty('ZIA'));
            if (!this.productSKUMap.hasOwnProperty(ele)) {
                this.showToastMessage('error', ('Please select a product for ' + ele));
                console.log('hasError1234');
                hasError = true;
                return false;
                
            }         
            else if(this.productSKUMap.hasOwnProperty(ele) && !this.productSKUMap.hasOwnProperty('ZIA')){            
                this.showToastMessage('error', ('Please select a product for ZIA'));
                console.log('hasError1234');
                hasError = true;
                return false;
            }  
            
            else{
                console.log('hasError12345'+hasError);
                hasError = false;
                return true;
                
            }

        }); */

        if(!this.domain){
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Please provide domain.');
        }else if(this.selectedCloud.length == 0 && this.selectedDependencyProducts.length == 0 ){
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Kindly select Either Product Line or Dependency Products for PR.');
        }else if(this.isZIA && !this.ziaCloudValue){
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Kindly Select ZIA Cloud');
        }else if(this.isZPA && !this.zpaCloudValue){
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Kindly Select ZPA Cloud');
        }/**else if(this.isSERequired && !this.credContainsSE) {
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Kindly Select SE in Send Credentials To.');
        }else if(!this.credContainsPartner) {
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Kindly Select Partner in Send Credentials To.');
        }*/
        else if(credentialsNotValid){
            //show error toast here
            if(this.credList && this.credList.length > 0){
                this.template.querySelector('c-custom-toast-component').showToast('error', 'Please verify the details in Credentials');
            }else{
                this.template.querySelector('c-custom-toast-component').showToast('error', 'Please select valid beneficiary for the credentials to be send.');
            }
        }else{
            if (!hasError) {
                //Submit the PR
                this.loading = true;
                this.NFRValidateWrapper.oppId = this.recordId;
                this.NFRValidateWrapper.credDetails = this.credList;
                //this.NFRValidateWrapper.pocProducts = this.selectedProducts;
                this.NFRValidateWrapper.pocProducts = this.selectedProductsUpdated;
                let dataToSend = JSON.stringify(this.NFRValidateWrapper);
                createNFRrecords({jsonStr:dataToSend})
                .then(result => {
                    var conts = result;
                    for(var key in conts){
                        this.rediectToNFRRecord(conts[key].Id);
                    }                   
                    this.loading = false;
                    this.showPRDetailScreen = false;
                    this.showPOCProductScreen = false;
                    this.showConfirmationScreen = false;
                    this.hasError = false;
                    this.error = undefined;
                }).catch(error => {
                    this.loading = false;
                    this.error = error;
                    this.hasError = true;
                });
            } 
        }
    }


    handleBackButton(){
        this.showPRDetailScreen = true;
        this.showPOCProductScreen = false;
    }

    openPOCScreen(){
        
        this.selectedProducts = [];
        let credentialsNotValid  = this.validateCredDetails();
        //this.NFRValidateWrapper.checkSKU
        if(!this.domain){
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Please provide domain.');
        }else if(this.selectedCloud.length == 0 && this.selectedDependencyProducts.length == 0 ){
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Kindly select Either Product Line or Dependency Products for PR.');
        }/*else if(this.isSERequired && !this.credContainsSE) {
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Kindly Select SE in Send Credentials To.');
        }else if(!this.credContainsPartner) {
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Kindly Select Partner in Send Credentials To.');
        }*/
        
        else if(this.isZIA && !this.ziaCloudValue){
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Kindly Select Preferred ZIA Cloud');
        }else if(this.isZPA && !this.zpaCloudValue){
            this.template.querySelector('c-custom-toast-component').showToast('error', 'Kindly Select Preferred ZPA Cloud');
        }else if(credentialsNotValid){
            //show error toast here
            if(this.credList && this.credList.length > 0){
                this.template.querySelector('c-custom-toast-component').showToast('error', 'Please add atleast one value to Send Default Credentials to');
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

    get checkIFNSSSelected(){
        let ifNSSExist = false;
        if(this.selectedDependencyProducts && this.selectedDependencyProducts.length > 0){
            this.selectedDependencyProducts.forEach(currentItem => {
                if(currentItem == 'Cloud NSS'){
                    ifNSSExist = true;
                }
            });
        }
        return  ifNSSExist ? true : false;
    }

    get credContainsSE(){
        let contSE = false;
        if(this.credList && this.credList.length > 0){
            for (var i = 0; i < this.credList.length; i++) {
                if(this.credList[i].Type == 'SE/PE' && this.credList[i].RecID != '' && this.credList[i].RecID != undefined){
                    contSE = true;
                }
            }
        }
        return contSE;
    }

    get credContainsPartner(){
        let contPartner = false;
        if(this.credList && this.credList.length > 0){
            for (var i = 0; i < this.credList.length; i++) {
                if(this.credList[i].Type == 'Partner' && this.credList[i].RecID != '' && this.credList[i].RecID != undefined){
                    contPartner = true;
                }
            }
        }
        return contPartner;
    }

    async loadPOCProducts(){
        this.loading = true;
        this.NFRValidateWrapper.pocProducts = [];
        this.NFRValidateWrapper.credDetails = this.credList;
        let dataToSend = JSON.stringify(this.NFRValidateWrapper);
        let productSKUList = [];
        let productSKUList1 = [];
        //this.selectedProductsUpdated = [];
        // code changes by Nagesh
        let arrayForPrepopulatingSelectedItems =[];
        await getALLPOCProducts({jsonStr:dataToSend})
        .then(result => {
            this.NFRValidateWrapper = result;
            this.loading = false;

            //Fill PoC products
            this.filteredRecords = this.pocProductList;


            //this.selectedFilteredRecords = this.pocProductList;

            this.selection = [];
            
            this.NFRValidateWrapper.pocProducts.forEach(ele=> {


                
                if(this.selectedDependencyProducts.includes('Cloud NSS') ){
                    if(ele.nssProvisioning == true){
                        this.selection.push(ele.prd.Id);
                        productSKUList.push(ele.prd.ProductCode);
                        this.productSKUMap['Cloud NSS'] = productSKUList;
                        this.selectedFilteredRecords.push(ele);
                        let selectedProductIds = [];

                        this.selectedProductsUpdated.forEach(ele => {
                            selectedProductIds.push(ele.ProductID);
                        });

                        arrayForPrepopulatingSelectedItems.push(ele); // code changes by Nagesh
                        if (!selectedProductIds.includes(ele.ProductID)) {
                            this.selectedProductsUpdated.push({
                            ProductID: ele.prd.Id,
                            ProductCode: ele.ProductCode,
                            ProductLine: ele.ProductLine,
                            prd: ele.prd,
                            nssProvisioning: ele.nssProvisioning,
                            cbiProvisioning: ele.cbiProvisioning,
                        })
                    

                    } 
                }
            }

                if(this.selectedDependencyProducts.includes('CBI') ){
                    if(ele.cbiProvisioning == true){
                        let selectedProductIds = [];

                        this.selectedProductsUpdated.forEach(ele => {
                            selectedProductIds.push(ele.ProductID);
                        });

                        this.selection.push(ele.prd.Id);
                        productSKUList1.push(ele.prd.ProductCode);
                        this.productSKUMap['CBI'] = productSKUList1;
                        this.selectedFilteredRecords.push(ele);
                        arrayForPrepopulatingSelectedItems.push(ele); // Code changes by Nagesh
                        if (!selectedProductIds.includes(ele.ProductID)) {

                            this.selectedProductsUpdated.push({
                                ProductID: ele.prd.Id,
                                ProductCode: ele.ProductCode,
                                ProductLine: ele.ProductLine,
                                prd: ele.prd,
                                nssProvisioning: ele.nssProvisioning,
                                cbiProvisioning: ele.cbiProvisioning,
                            })
                        }

                    } 
                }
                
            })
            this.showPOCProductScreen = true;
            this.showPRDetailScreen =false;
            this.NFRValidateWrapper.cloudSkuMap = this.productSKUMap;
            this.hasError = false;
            this.error = undefined;
            // Code changes by Nagesh
            this.prepareSelectedItemsList(arrayForPrepopulatingSelectedItems);


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
            return notValid>0 ? true : false;
        }else{
            return true;
        }
    }

    navigateToAccountPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                
                recordId: this.recordId,
                objectApiName: 'Account',
                actionName: 'view'
            }
        });
    }

    rediectToNFRRecord(recid){
        if(recid){
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: recid,
                    objectApiName: 'NFR__c',
                    actionName: 'view'
                }
            });
        }

    }

    get errorMessages() {
        return reduceErrorsUpgradedAdvanced(this.error);
    }


    @track selectedProductsUpdated = [];




    // Code Changes by Nagesh
    removeItemFromSelectedList(e){
        
        let tempArray = this.selectedItemsList;
        tempArray = tempArray.filter(item => item.ProductId.Id !== e.target.value);   


        let selectedRecordIds = [];



        // let tempArrayProducts = this.selectedProductsUpdated;

        // tempArrayProducts = tempArrayProducts.filter(item => item.ProductID !== e.target.value);   

        // this.selectedProductsUpdated = tempArrayProducts;

        this.selectedProductsUpdated = [];

        tempArray.forEach(eachRec => {
            selectedRecordIds.push(eachRec.ProductId.Id);

            this.selectedProductsUpdated.push({
                ProductID: eachRec.ProductId.Id,
                ProductCode: eachRec.ProductCode,
                ProductLine: eachRec.ProductLine,
                prd: eachRec.prd,
                nssProvisioning: eachRec.nssProvisioning,
                cbiProvisioning: eachRec.cbiProvisioning
            })


        });

        this.selectedItemsList = tempArray;

        this.productSKUMap = {};


        this.selectedProductsUpdated.forEach(ele => {
            let productSKUList = [];
            if (
                ((ele.nssProvisioning==false) && (ele.cbiProvisioning == false))
                
                && (

                    ((this.selectedCloud.includes('ZIA')) && (ele.ProductLine === 'ZIA'))
                || ((this.selectedCloud.includes('ZPA')) && (ele.ProductLine === 'ZPA'))
                || ((this.selectedCloud.includes('ZDX')) && (ele.ProductLine === 'ZDX'))
                || ((this.selectedCloud.includes('Workload Protection')) && (ele.ProductLine === 'Workload Protection'))
                || ((((this.selectedCloud.includes('ZPA')) || (this.selectedCloud.includes('ZIA'))) && (ele.ProductLine === 'Cross Platform')))

                )    
                
            ) {
                if (this.productSKUMap.hasOwnProperty(ele.ProductLine)) {
                    productSKUList = this.productSKUMap[ele.ProductLine];
                }
                productSKUList.push(ele.ProductCode);
                this.productSKUMap[ele.ProductLine] = productSKUList;

            }
            else if(ele.nssProvisioning==true){
                
                if (this.productSKUMap.hasOwnProperty('Cloud NSS')) {
                    productSKUList = this.productSKUMap['Cloud NSS'];
                }

                productSKUList.push(ele.ProductCode);

                this.productSKUMap['Cloud NSS'] = productSKUList;

            }
            else if(ele.cbiProvisioning == true){
               
                if (this.productSKUMap.hasOwnProperty('CBI')) {
                    productSKUList = this.productSKUMap['CBI'];
                }


                productSKUList.push(ele.ProductCode);

                this.productSKUMap['CBI'] = productSKUList;

            }
        });








        this.selection = [];
        selectedRecordIds.forEach(ele=>{
            this.selection.push(ele);
        });
        this.template.querySelector('[data-id="datarow"]').selectedRows = this.selection;
        
    }
    deleteAllSelectedProducts(e){
        this.selectedItemsList = [];
        this.selection =[];
        this.selectedProductsUpdated =[];
        //this.selectedDependencyProducts =[];
        this.productSKUMap = {};
    }  

    // Code changes by Nagesh
    prepareSelectedItemsList(passedRows){

        let selectedProductIds = [];
        this.selectedProductsUpdated.forEach(ele => {
            selectedProductIds.push(ele.ProductID);
        });




        passedRows.forEach(ele => {

            if (!selectedProductIds.includes(ele.ProductID)) {
                this.selectedProductsUpdated.push({
                    ProductID: ele.ProductID,
                    ProductCode: ele.ProductCode,
                    ProductLine: ele.ProductLine,
                    prd: ele.prd,
                    nssProvisioning: ele.nssProvisioning,
                    cbiProvisioning: ele.cbiProvisioning,
                })
            }

          if(!this.selectedItemsList.some(item => item.Name == ele.Name)) {
            this.selectedItemsList.push({
                Name: ele.Name,
                ProductCode: ele.ProductCode,
                ProductLine: ele.ProductLine,
                ProductId: ele.prd,
                RecordId:ele.Id,
                nssProvisioning: ele.nssProvisioning,
                cbiProvisioning: ele.cbiProvisioning,
            })

            

            
            
            
         }   
        });      
    }

}
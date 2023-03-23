import { LightningElement,track, api , wire } from 'lwc';
import { NavigationMixin,CurrentPageReference } from 'lightning/navigation';
import { reduceErrorsUpgradedAdvanced } from 'c/ldsUtils';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import createProvisioningRecords from '@salesforce/apex/ProvisioningGroupController.createProvisioningDetails';
import getZIAcloud from '@salesforce/apex/ProvisioningGroupController.getZIAcloud';
import getZIAcloudfromPR from '@salesforce/apex/ProvisioningGroupController.getZIAcloudfromPR';
import getZIAcloudfromPRG from '@salesforce/apex/ProvisioningGroupController.getZIAcloudfromPRG';

import getAccountData from '@salesforce/apex/ProvisioningGroupController.getAccountData';
//197
import createDraftProvisioningRecords from '@salesforce/apex/ProvisioningGroupController.createDraftProvisioningRecords';
//197
import getDraftJSON from '@salesforce/apex/ProvisioningGroupController.getDraftJSON';
import checkifDraftexists from '@salesforce/apex/ProvisioningGroupController.checkifDraftexists';
import getALLProductSKUforTable from '@salesforce/apex/ProvisioningGroupController.getALLProductSKUforTable';
import fillProductListFromPrimaryQuote from '@salesforce/apex/ProvisioningGroupController.fillProductListFromPrimaryQuote';
import getRequiredContacts from '@salesforce/apex/ProvisioningGroupController.getRequiredContacts';
import searchAndCreateContactRecord from '@salesforce/apex/ProvisioningGroupController.searchAndCreateContactRecord';
import checkifPrimaryQuoteExist from '@salesforce/apex/ProvisioningGroupController.checkifPrimaryQuoteExist';
import updateDraftPGStatus from '@salesforce/apex/ManageProvisioningController.updateDraftPGStatus';
import domainCheckWithExistingCloud from '@salesforce/apex/ProvisioningGroupController.domainCheckWithExistingCloud';
import fillProductListFromPrimaryQuoteforContact from '@salesforce/apex/ProvisioningGroupController.fillProductListFromPrimaryQuoteforContact';
import getTenantDetails from '@salesforce/apex/ProvisioningGroupController.getTenantDetails';
import getTenantDetailsfromPR  from '@salesforce/apex/ProvisioningGroupController.getTenantDetailsfromPR';

import fillProductLineForPrimaryQuote from  '@salesforce/apex/ProvisioningGroupController.fillProductLineForPrimaryQuote';
import productsInThisCrossPlatform from  '@salesforce/apex/ProvisioningGroupController.productsInThisCrossPlatform';
import getCrossPlatformProduct from  '@salesforce/apex/ProvisioningGroupController.getCrossPlatformProduct';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCrossPlatformProductsToShow from '@salesforce/apex/ProvisioningGroupController.getCrossPlatformProductsToShow';
import getPriceListFromOpp from '@salesforce/apex/ProvisioningGroupController.getPriceListFromOpp';
import getAllProductLineForPrimaryQuote from  '@salesforce/apex/ProvisioningGroupController.getAllProductLineForPrimaryQuote';

import hasProvisioningPermission from '@salesforce/customPermission/Update_Clusters_on_PRG';

import OPP_NAME from '@salesforce/schema/Opportunity.Name';
import SE_NAME from '@salesforce/schema/Opportunity.SE_Name__c';

import PRIMARY_RESELL_PARTNER from '@salesforce/schema/Opportunity.Primary_Reseller_Partner__c';
import id from '@salesforce/user/Id';

const createdPGColumns = [
    { label: 'Provisioning Group Name', fieldName: 'pgUrl', type:'url',
        typeAttributes: {
            label: { 
                fieldName: 'Name' 
            },
            target : '_blank'
        }
    },
    { label: 'Product Line', fieldName: 'Product_Line__c'},
    { label: 'Provisioning Type', fieldName: 'Provisioning_Type__c'},
    { label: 'Status', fieldName: 'Status__c'},
    { label: 'Approval Status', fieldName: 'Approval_Status__c'}
];

export default class NewTenantComponent extends NavigationMixin(LightningElement) {
    //Opportunity ID
    @api recordId;

    //IBA-511 START
    @api pgForSubscription = false;
    //IBA-511 END

    @track oppName;
    @track oppPrimaryResellPartnerId;

    //Account ID
    @api accountId;

    @track opportunityId;
    
    @track currentStep = "1";
    @track currentPageReference;

    //For Spinner
    @track loading = false;

    //For Error Handling
    @track hasError = false;
    @track error;
    
    @track selectedProdLine = [];
    @track selectedProdLineMinusPostureControl = [];
    @track selectedCrossPlatformProduct = [];
    
    @track credList = [];
    @track NcCredList = [];
    @track markPrimaryQuoteUncheckReadOnly = false;
    @track domain;
    @track additionalDomain;
    @track industryname;
    @track comments;
    @track startdate;
    @track endDate;
    @track selectedProdsFromChild = [];    //to store products selected in child component during navigation
    @track selectedProductCode = [];
    @track selectedProdLinewithPQ = [];
    @track selectedPLforScreen1=[];
    
    @track showAssociatedCloud = false;
    @track showPreferredZiaCloud = false;
    
    @track preferredZIA;
    @track ziapreferedcloud;
    @track preferredZPA='ZPA Production';
    @track defaultDomain;
    
    @track ziaCloudIdForZPA;
    
    @track associatedZiaCloudValue;
    @track zscCloudName = [];
    @track prghasTenant=false;
    @track prhasTenant=false;
    @track provisioningGroup = [];
    @track createdProvisioningG;
    @track iserror=false;
    @track primaryQuoteProductsList = [];
   
    @track showReason=false;
    @track preferedZIAReason;
    @track assignedTo='SALES_ENGINEER';

    @track createdProvisioningGroup = createdPGColumns;
    @track pgProduct=[];
    @track random;
    @track contactscreenError=false;
    @track contactlistnotselected=[];

    //517
    @track defaultcontact=[];
    @track showAssociateSEButton=true;
    @track preSelectedProductsForCrossPlatform=[];
    @track selectedProdLineForCrossPlatform=[];
    @track selectedPostureControlProducts =[];
    @track selectedPostureControlProdAddOn =[];
    @track crossPlatform =[];
    @track crossPlatformProductCode = [];
    @track productOptionsForCrossPlatform =[];

    primaryQuoteTenantCheck = false;
    checkSKU=false;
    primaryQuoteExist=false;
    zpaOnly=false;
    workloadCommunicationOnly = false
    domainNotAvailable=false;
    crossPlatformSelected=false;
    crossPlatformProductId;
    crossPlatformProductName;
    postureControlSelected = false;
    onlyPostureControlSelected = false;
    crossPlatformInPrimaryQuote = false;
    postureControlOptionsNeeded = false;
    notPostureControl = false;
    showNumberOfLoads = false;
    numberOfWorkloads = 0;
    oldPriceListSelected = false;
    disableAddProducts = false;
    noProductsEligible = false;
    @track checkexceptiontocluster=false;
    @track exceptionclustervalue;

    //2924
    @track NanologCluster;
    @track SandboxCluster;
    @track SMCCluster;
    //197
    @api draftpgId;
    @track draftdata;

    //One Product Screen show Active section by Default
    @track activeLineTypeSections = [];

    //initial Index 
    index = 0;
    clIndex = 0;

    //lookUp componnet
    fields = ["Name","Email","Phone"];
    clusterFields = ["Name","cloud__c","type__c"];
    displayFields = 'Name, Email, Phone';
    clusterDisplayFields = 'Name, cloud__c, type__c';
    @track priceList;

    @wire(getRecord, { recordId: '$recordId', fields: [SE_NAME] })
    oppt;

    @track custOptionAvilable = [
        {label: 'Select', value: null },
        {label:'Sales Engineer' , value:'SALES_ENGINEER'},
        {label:'BUSINESS (PRIMARY)' , value :'BUSINESS_PRIMARY'},
        {label:'BILLING (PRIMARY)' , value:'BILLING_PRIMARY'},
        {label:'TECHNICAL (PRIMARY)' , value:'TECHNICAL_PRIMARY'},
        {label:'BUSINESS (SECONDARY)' , value:'BUSINESS_SECONDARY'},
        {label: 'BILLING (SECONDARY)' ,value:'BILLING_SECONDARY'},
        {label: 'TECHNICAL (SECONDARY)' , value:'TECHNICAL_SECONDARY'},
        {label: 'ZDX CONTACT' , value:'ZDX_CONTACT'},
        {label:'EC CONTACT'  , value: 'EC_CONTACT'},
        {label:'CSPM CONTACT' , value: 'CSPM_CONTACT'},
        {label:'DECEPTION CONTACT' , value: 'DECEPTION_CONTACT'}

    ];

    //Retrive Page Reference
    @wire(CurrentPageReference)
    setcurrentPageRef(currentPageReference){
        this.currentPageReference=currentPageReference;
    }
    
    //Retrive Opportunity Details
    @wire(getRecord, {recordId: '$recordId',fields: [OPP_NAME,PRIMARY_RESELL_PARTNER]})
    wiredRecord({error,data}) {
        if (data) {
            console.log('--wiredRecord called---, data val is:', JSON.stringify(data));
            this.oppName = getFieldValue(data, OPP_NAME);
            this.oppPrimaryResellPartnerId = getFieldValue(data, PRIMARY_RESELL_PARTNER);
        }
        if (error) {
            console.log('--wiredRecord called---, error val is: ', JSON.stringify(error));
            this.error = error;
            this.template.querySelector('c-custom-toast-component').showToast('error',  this.errorMessages);
        }
    }

    //Retrive ZIA Cloud Details
    @wire (getZIAcloud,{accountId:'$accountId'})
    getZIACloudList({error,data}){
        if(data){
            this.zscCloudName = data;
        }
        if(error){
            cosnole.log('error'+error);
        }
    }
    //get if ZIA cloud is pulled from a PR
    @wire (getZIAcloudfromPR,{accountId:'$accountId'})
    getZIACloudListfromPR({error,data}){
        if(data){
            this.prhasTenant = data;
        }
        if(error){
            console.log('error'+error);
        }
    }
    //get if ZIA cloud is pulled from a PR
    @wire (getZIAcloudfromPRG,{accountId:'$accountId'})
    getZIACloudListfromPRG({error,data}){
        if(data){
            this.prghasTenant = data;
        }
        if(error){
            console.log('error'+error);
        }
    }

    @wire(getAccountData , {accountId: '$accountId'})
    getAccData({error,data}){
        if(data && !this.draftpgId){
            this.defaultDomain=data.Domain__c;
            this.domain=data.Domain__c;
            this.ziapreferedcloud=data.Sales_Territory__r.Preferred_ZIA_Cloud__c;
            this.preferredZIA=this.ziapreferedcloud;
            this.industryname=data.FP_A_Parent_industry__c;
            this.domainCheck();
        }
        
        if(data && this.draftpgId){
            this.industryname=data.Industry;
            this.ziapreferedcloud=data.Sales_Territory__r.Preferred_ZIA_Cloud__c;
            if(this.preferredZIA &&(this.preferredZIA!= this.ziapreferedcloud)){
                this.showReason=true;
            }else{
                this.showReason=false;
            }
        }
        
        if(error){
            console,log(error);
        }
    }

    connectedCallback() {
        this.loadDataFromPageRefrence();
        this.getCrossPlatformProducts();
        this.getPriceListOfOpportunity();
        this.checkForCrossPlatforminPrimaryQuote();
        this.random = new Date().toISOString();
        this.addInitialRow();
    }

    @wire(getDraftJSON,{draftpgId:'$draftpgId',random:'$random'})//Used to get latest json form caeche else the caeche record has old data
    getDraftjsondata({error,data}){
        if(data){
            this.draftdata=JSON.parse(data.Draft_Request__c);
            this.domain=this.draftdata?.domain;
            this.additionalDomain=this.draftdata?.additionalDomain;
            this.preferedZIAReason=this.draftdata?.preferedZIAReason;           
            this.opportunityId=this.draftdata?.opportunityId;
            this.accountId=this.draftdata?.accountId;
            this.preferredZIA=this.draftdata?.preferredZIA;
            this.preferredZPA=this.draftdata?.preferredZPA;
            this.associatedZiaCloudValue=this.draftdata?.associatedcloud;
            this.assignedTo=this.draftdata?.assignedToCred;

            this.selectedProdLine=this.draftdata?.provProdWrapper.map(e=>e.lineType);
            
            this.primaryQuoteExist=this.draftdata?.withPrimaryQuoteProducts;
            this.checkSKU=this.draftdata?.withPrimaryQuoteProducts;

            this.pgProduct=this.draftdata?.provProdWrapper;
          
            this.accountId=this.draftdata?.accountId;
            this.credList = this.draftdata?.provContactWrapper?.map(this.getcred);
            
            if(this.selectedProdLine.includes('ZPA') || this.selectedProdLine.includes('ZDX')){
                this.showAssociatedCloud=true;
            }
            else if(selectedProdLine.includes('Workload Communication') && this.selectedProdLine.length == 1){
                this.showAssociatedCloud=true;
                console.log('inside else if')
            }else{
                this.showAssociatedCloud=false;
            }
            

            if(this.preferredZIA!= this.ziapreferedcloud){
                this.showReason=true;
            }else{
                this.showReason=false;
            }
        }
        if(error){
            this.error = error;
            console.log('Error Occured: '+this.error);
        }
    }

    getcred(draftcontact){
        return {
            Index: draftcontact?.ContactObj?.Index,
            IsUser: draftcontact?.ContactObj?.IsUser,
            Label: draftcontact?.ContactObj?.Label,
            RecID: draftcontact?.ContactObj?.RecID,
            Type: draftcontact?.ContactObj?.Type,
            filterClause: draftcontact?.ContactObj?.filterClause,
            isFirst: draftcontact?.ContactObj?.isFirst,
            typeOptionList : draftcontact?.ContactObj?.typeOptionList,
            record : draftcontact?.ContactObj?.record,
            unfinished: draftcontact?.ContactObj?.unfinished
        };
    }
    
    handleskuchange(event){
        var pline= event.detail.Product_Line__c;
        var pgProductCopy = [...this.pgProduct];
        for(var i = 0; i < pgProductCopy.length; i++) {
            var pgp = pgProductCopy[i];
            //Sku selection got changed. Dont edit selectedPOCProducts. Only update sku
            if(pgp.lineType === pline){
                pgp.selectedPlatfromSKU={
                    "Id": event.detail.Id,
                    "IsActive": event.detail.IsActive,
                    "Is_Applicable_for_POC__c": event.detail.Is_Applicable_for_POC__c,
                    "Name": event.detail.Name,
                    "POC_Products__c": event.detail.POC_Products__c,
                    "ProductCode": event.detail.ProductCode,
                    "Product_Line__c": event.detail.Product_Line__c,
                    "Provisioning_Product_Family__c": event.detail.Provisioning_Product_Family__c,
                    "SKU_Type__c": event.detail.SKU_Type__c,
                    "isBundle__c": event.detail.isBundle__c
                };
                pgp.skuselectionId = [event.detail.Id];
            }
        }
        this.pgProduct = pgProductCopy;
        console.log('this.pgProduct',this.pgProduct);
    }
    handleremoveallproductclicked(event){
        
    }

    handleproductvaluechange(event){
        var listOfSelectedProducts=event.detail.selectedItemsList;
        var eventlineType=event.detail.lineType;

        var pgProductCopy=[...this.pgProduct];  

        //We get all selected rows in event. Entry must already be present in pgProduct created during sku selection event
        for(var i = 0; i < pgProductCopy.length; i++){
            if(pgProductCopy[i].lineType === eventlineType){
                pgProductCopy[i].selectedPOCProducts = [];
            for(var j=0; j<listOfSelectedProducts.length;j++){
                    pgProductCopy[i].selectedPOCProducts.push(
                        {
                            "Id": listOfSelectedProducts[j].Id,
                            "IsActive": listOfSelectedProducts[j].IsActive,
                            "Is_Applicable_for_POC__c": listOfSelectedProducts[j].Is_Applicable_for_POC__c,
                            "Name": listOfSelectedProducts[j].Name,
                            "ProductCode": listOfSelectedProducts[j].ProductCode,
                            "Product_Line__c": listOfSelectedProducts[j].Product_Line__c,
                            "Provisioning_Product_Family__c": listOfSelectedProducts[j].Provisioning_Product_Family__c,
                            "SKU_Category__c": listOfSelectedProducts[j].SKU_Category__c,
                            "SKU_Type__c": listOfSelectedProducts[j].SKU_Type__c,
                            "Provisioning_Broker_Eligible__c": listOfSelectedProducts[j].Provisioning_Broker_Eligible__c
                        }
                    );
                }
            }
        }
        this.pgProduct = pgProductCopy;
    }
    
    loadDataFromPageRefrence(){
        if(this.currentPageReference && this.currentPageReference.state.c__oppId){
            this.opportunityId=this.currentPageReference.state.c__oppId;
        }else{
            this.opportunityId = this.recordId;
        }

        if(this.currentPageReference && this.currentPageReference.state.c__accId){
            this.accountId=this.currentPageReference.state.c__accId;
        }
    }

    initContactsOnce = true;
    handleProvistioningContactsNavigate() {
        const pgprocoms = this.crossPlatformSelected==false?this.template.querySelectorAll('c-p-g-product-selection-component'):
                                                        this.template.querySelectorAll('c-cross-platform-component');
        console.log('pgprocoms==',JSON.stringify(pgprocoms));
        this.assignedTo = 'SALES_ENGINEER';
        this.selectedProdsFromChild=[];
        this.selectedProductCode=[];
        for(var i = 0; i < pgprocoms.length; i++) {

            let provisioningProductWrapper = {};
            if(pgprocoms[i].selectedRadioProductrow == null){
                this.showToastMessage('error', ('Please Select Products before Proceeding.'));
                return;
            } else
            if(pgprocoms[i].selectedRadioProductrow != null) {
                provisioningProductWrapper.productName = pgprocoms[i].selectedRadioProductrow.Name;
                provisioningProductWrapper.productCode = pgprocoms[i].selectedRadioProductrow.ProductCode;
                provisioningProductWrapper.prodline = pgprocoms[i].selectedRadioProductrow.Product_Line__c;
                provisioningProductWrapper.productSKUId = pgprocoms[i].selectedRadioProductrow.Id;
                provisioningProductWrapper.isCBI = this.chekcIFProductISCBI(pgprocoms[i].selectedRadioProductrow);
                provisioningProductWrapper.isDeception = this.checkIFProductIsDeception(pgprocoms[i].selectedRadioProductrow);
                provisioningProductWrapper.brokerEligibility=this.checkIFProductisBrokerEligible(pgprocoms[i].selectedRadioProductrow);
                this.selectedProdsFromChild.push(provisioningProductWrapper);
                this.selectedProductCode.push(pgprocoms[i].selectedRadioProductrow.ProductCode);
                for(var j = 0; j < pgprocoms[i].selectedItemsList.length; j++) {
                    let provisioningAddOnProductWrapper = {};
                    if(pgprocoms[i].selectedItemsList != null) {
                        provisioningAddOnProductWrapper.productName = pgprocoms[i].selectedItemsList[j].Name;
                        provisioningAddOnProductWrapper.productCode = pgprocoms[i].selectedItemsList[j].ProductCode;
                        provisioningAddOnProductWrapper.prodline = pgprocoms[i].selectedItemsList[j].Product_Line__c;
                        provisioningAddOnProductWrapper.productAddonnID = pgprocoms[i].selectedItemsList[j].Id;
                        provisioningAddOnProductWrapper.isCBI = this.chekcIFProductISCBI(pgprocoms[i].selectedItemsList[j]);
                        provisioningAddOnProductWrapper.isDeception = this.checkIFProductIsDeception(pgprocoms[i].selectedItemsList[j]);
                        provisioningAddOnProductWrapper.brokerEligibility=this.checkIFProductisBrokerEligible(pgprocoms[i].selectedItemsList[j]);

                        this.selectedProdsFromChild.push(provisioningAddOnProductWrapper);
                        this.selectedProductCode.push(pgprocoms[i].selectedItemsList[j].ProductCode);
                    }
                }
            }
            else{
                this.showToastMessage('error', ('Please Select Products before Proceeding.'));
                return;
            }
        }
        if(this.initContactsOnce){
            this.initContactsOnce = false;
            this.initContactsAgain = false;
            if((!this.draftpgId || this.credList.length==0)){
                if(this.crossPlatformSelected==false)
                this.sendProductDetails(this.selectedProductCode);
                else if(this.crossPlatformSelected==true)
                    this.sendProductDetails(this.crossPlatformProductCode);
            }
                
        }
        if(this.initContactsAgain){
            this.initContactsAgain = false;
            this.credList = [];
            this.index = 0;
            if(this.crossPlatformSelected==false)
                this.sendProductDetails(this.selectedProductCode);
            else if(this.crossPlatformSelected==true)
                this.sendProductDetails(this.crossPlatformProductCode);
        }
        this.currentStep="3";
    }

    sendProductDetails(selectedProducts){
        getRequiredContacts({selectedProduct:selectedProducts})
            .then(result=>{
                var sepresent = false;
                
                this.defaultcontact = result;
                this.defaultcontact.forEach(item=>{
                    if(item == 'SALES_ENGINEER'){
                        sepresent = true;
                        this.showAssociateSEButton = true;
                    }
                    this.credList.push({
                        Label:this.getCustomOptionLabel(item),
                        Type:item,
                        Index:this.index,
                        RecID:item == 'SALES_ENGINEER' ? this.seUserId : '',
                        IsUser:true,
                        unfinished:false,
                        typeOptionList:this.custtypeoptions,
                        showCopyContact:item == 'SALES_ENGINEER' ? true : false,
                        showSeleectContact:true,
                        
                    })
                    this.index++;
                });
                
                if(!sepresent){
                    this.credList.push({
                        Label:this.getCustomOptionLabel('SALES_ENGINEER'),
                        Type:'SALES_ENGINEER',
                        Index:this.index,
                        RecID:this.seUserId,
                        IsUser:true,
                        unfinished:false,
                        typeOptionList:this.custtypeoptions,
                        showCopyContact:true,
                        record: this.serecord,
                        showSeleectContact:true
                    });
                    this.index++;
                    this.showAssociateSEButton=true;
                }
            })
            .catch(error=>{
                this.error = error;
            });
    }

    @track iscopyinProgress=false;
    searchAndCreateContact(){
        this.iscopyinProgress=true;
        searchAndCreateContactRecord({seUserId:this.seUserId,accId:this.accountId})
            .then(result=>{
                var credlist2 = [];
                this.credList.forEach(item=>{
                    item.RecID = item.Type == 'SALES_ENGINEER'?this.seUserId:result.Id;
                    var name = result.FirstName + ' ' + result.LastName;
                    var rec = {...result};
                    rec.Name = name;
                    item.record = rec;
                    item.unfinished = false;
                    credlist2.push(item);
                })
                this.credList = credlist2;
                
                var searchComp = this.template.querySelectorAll('c-generic-search-component');
                for(var i = 0; i<searchComp.length; i++){
                    if(searchComp[i].objName == 'contact'){
                        searchComp[i].triggerChange(result.Id);
                    }
                }
                this.iscopyinProgress=false;
            })
            .catch(error=>{
                this.error = error;
            });
    }
    
    chekcIFProductISCBI(prd){
        return prd.Provisioning_Sub_Product_Line__c && prd.Provisioning_Sub_Product_Line__c == 'CBI' ? true : false;
    }

    checkIFProductIsDeception(prd){
        return prd.Provisioning_Sub_Product_Line__c &&  prd.Provisioning_Sub_Product_Line__c == 'Deception' ? true : false;
    }

    checkIFProductisBrokerEligible(prd){
        return prd.Provisioning_Broker_Eligible__c==true ? true:false;
    }

    initContactsOncePQ = true;
    handleProvistioningContactsWithPrimaryQuote() {
        if(this.noProductsEligible){
            this.showToastMessage('error',('Products available in primary quote are not eligible for provisioning. Please use Product Line to continue.'));
            this.error = true;
            return;
        }
        if(this.domainNotAvailable == true && this.associatedZiaCloudValue==='Request New ZIA Tenant'){
            this.showToastMessage('error',('This domain is already provisioned for an existing tenant'));
            this.error = true;
            return;
        }
        
        var productLinex = this.selectedProdLine;
        console.log('selectedPLforScreen1'+this.selectedPLforScreen1);
       
        if(this.selectedPLforScreen1.includes('ZIA') && this.showReason==true && (this.preferedZIAReason=='' || this.preferedZIAReason==null)){
            this.showToastMessage('error',('Please enter reason to change Preferred  ZIA Cloud'));
            this.error=true;
            return;
        }
        if((this.selectedPLforScreen1.includes('Cross Platform') || this.selectedPLforScreen1.includes('ZPA') || this.selectedPLforScreen1.includes('ZDX') || this.selectedPLforScreen1.includes('Workload Protection') || this.selectedPLforScreen1.includes('Workload Segmentation')) && this.associatedZiaCloudValue == null){
            this.showToastMessage('error', ('Please Select Associated ZIA Cloud'));
            this.iserror=true;
            return;
        }

        if(this.selectedPLforScreen1.includes('Workload Communication') && this.selectedPLforScreen1.length==1 && this.associatedZiaCloudValue == null){
            this.showToastMessage('error', ('Please Select Associated ZIA Cloud'));
            this.iserror=true;
            return;
        }
        
        if(this.onlyPostureControlSelected){
            this.currentStep = "3";
        }else{
            fillProductListFromPrimaryQuoteforContact({opp:this.opportunityId})
            .then(result=>{
                this.selectedProdLinewithPQ = result;
                
                if(this.initContactsOncePQ){
                    this.initContactsOncePQ = false;
                    this.initContactsOnce = false;
                    this.sendProductDetails(this.selectedProdLinewithPQ);
                }
                this.currentStep = "3";
            })
            .catch(error=>{
                this.error = error;
            });
        }
        
    }

    handleProvistioningContactsWithPostureControl() {
        if(this.domainNotAvailable == true && this.associatedZiaCloudValue==='Request New ZIA Tenant'){
            this.showToastMessage('error',('This domain is already provisioned for an existing tenant'));
            this.error = true;
            return;
        }
        if(this.selectedPostureControlProducts == false){
            this.showToastMessage('error',('Please select a Posture Control Product to proceed ahead'));
            this.error = true;
            return;
        }

        let productCodes =[];
        if(this.selectedPostureControlProducts){
            productCodes.push(this.selectedPostureControlProducts);
        }
        if(this.selectedPostureControlProdAddOn){
            for(let item in this.selectedPostureControlProdAddOn){
                productCodes.push(this.selectedPostureControlProdAddOn[item]);
            }
        }
        if(this.credList.length==0){
            this.sendProductDetails(productCodes);
        }        
        this.currentStep = "3";
    }
    
    @track showWarning;
    validateShowSubmitForProvisioningButton(){
        this.showWarning = false;
        let showSubmitForProvisioningButton = false;
        let showcontactmissingerror = false;
        const pgprocoms = this.crossPlatformSelected==false?this.template.querySelectorAll('c-p-g-product-selection-component'):
                                                        this.template.querySelectorAll('c-cross-platform-component');
        if(pgprocoms){
            let individualCheck = true;
            pgprocoms.forEach(pgSelection => {
                if(individualCheck && !pgSelection.selectedRadioProductrow){
                    individualCheck = false;
                    pgSelection.productSelectionMsg = true;
                }
            });
            showSubmitForProvisioningButton = individualCheck;
        }

        this.credList.forEach(cred => {
            if(cred.Type===undefined || cred.Type == null || cred.Type==''){
                this.showToastMessage('error', ('Please Select Contact Type'));
                showcontactmissingerror=true;
            }
            if(cred.record ===undefined|| cred.record  == null || cred.record ==''){
                this.showToastMessage('error', ('Please Select required Contact'));
                showcontactmissingerror=true;
            }
            if(showcontactmissingerror){
                return;
            }
        });

        
        if(this.assignedTo === undefined || this.assignedTo == null || this.assignedTo == '' ){
            this.showToastMessage('error', ('Please Select Credentials Assigned To'));
            return;
        }
        
        if(this.industryname == undefined || this.industryname == null || this.industryname == ''){
            this.showWarning = true;
            this.showToastMessage('warning',('Industry field has blank value at Account , and can cause manual provisioning. To avoid the same , Please fill it at Account level first'));
        }
        
        var stopexec = this.checkContactSelection();
        if(stopexec){
            return;
        }
       
        if(showSubmitForProvisioningButton && !showcontactmissingerror){
            this.handleSaveRecord();
        }
    }

    checkContactSelection(){
        let addedcontType = [];
        let tempContactlistnotselected = [];
        let iscontactRecordAdded = true;

        
        for(var i = 0; i < this.credentialList.length; i++) {
            if(this.credentialList[i].RecID==''||this.credentialList[i].RecID===undefined){
                iscontactRecordAdded=false;
            }
            addedcontType.push(this.credentialList[i].Type)
        }
        this.defaultcontact.forEach(defaultlistitem=>{
            if(!addedcontType.includes(defaultlistitem)){
                tempContactlistnotselected.push(defaultlistitem);
            }
        })
        this.contactlistnotselected = tempContactlistnotselected;
        if(tempContactlistnotselected.length>0){
            this.contactscreenError=true;
        }else{
            this.contactscreenError=false;
        }
        if(!iscontactRecordAdded){
            console.log('showing Error');
          //  this.showErrorToast2();
         //   return true;
        }
        if(this.contactscreenError){
            this.showToastMessage('error',('Please select following Mandatory contact Types ' + this.contactlistnotselected));
            return true;
        }
    }
    showErrorToast() {
        const evt = new ShowToastEvent({
            title: 'Error',
            message:'Please select following Mandatory contact Types '+this.contactlistnotselected,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    showErrorToast2() {
        const evt = new ShowToastEvent({
            title: 'Error',
            message:'Please select Contact',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    showWarningToast() {
        const evt = new ShowToastEvent({
            title: 'Warning',
            message: 'Industry field has blank value at Account , and can cause manual provisioning. To avoid the same , Please fill it at Account level first',
            variant: 'warning',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    @track isSaveDraftinProcess = false;
    validateSaveDraft(){
        if(this.domainNotAvailable==true && this.associatedZiaCloudValue==='Request New ZIA Tenant'){
            this.showToastMessage('error',('This domain is already provisioned for an existing tenant'));
            this.error=true;
            return;
        }
        checkifDraftexists({oppId:this.opportunityId})
            .then(result=>{
                if(this.draftpgId === undefined && result == true){
                    this.showToastMessage('error', ('Draft record already exists on this opportunity'));
                }else{
                    this.handleDraftRecordSave();
                }
            })
            .catch(error=>{
                this.error = error;
                console.log('Error Occured: '+this.error);
            });
    }

    //197
    async handleDraftRecordSave() {
        //Set Spinner
        this.isSaveDraftinProcess = true;

        let provisioningDraftWrapper = {};
        provisioningDraftWrapper.draftPGId=this.draftPGId;
        
        provisioningDraftWrapper.domain = this.domain;
        provisioningDraftWrapper.additionalDomain = this.additionalDomain;
        provisioningDraftWrapper.preferedZIAReason=this.preferedZIAReason;
        provisioningDraftWrapper.startDate = this.startdate;
        provisioningDraftWrapper.opportunityId = this.opportunityId;
        provisioningDraftWrapper.accountId = this.accountId;
        provisioningDraftWrapper.preferredZIA = this.preferredZIA;
        provisioningDraftWrapper.preferredZPA = this.preferredZPA;
        provisioningDraftWrapper.associatedcloud = this.associatedZiaCloudValue;          
        provisioningDraftWrapper.withPrimaryQuoteProducts = this.withPrimaryQuoteProducts;
        provisioningDraftWrapper.assignedToCred = this.assignedTo;

        provisioningDraftWrapper.provProdWrapper = [];
        provisioningDraftWrapper.provContactWrapper = [];

        for(var i = 0; i < this.credentialList.length; i++) {
            let provisioningContacts = {};
            if(this.credentialList[i].IsUser){
                provisioningContacts.userId = this.credentialList[i].RecID;
            }else{
                provisioningContacts.contactId = this.credentialList[i].RecID;
            }
            provisioningContacts.contactType = this?.credentialList[i]?.Type;
            provisioningContacts.email = this?.credentialList[i]?.record?.Email;
            provisioningContacts.ContactObj=this?.credentialList[i];
            provisioningDraftWrapper.provContactWrapper.push(provisioningContacts);
        }
    
        provisioningDraftWrapper['provProdWrapper'].push(...this.pgProduct);
        
        let dataToSend = JSON.stringify(provisioningDraftWrapper);
        console.log('dataToSend json val is *********--> ', dataToSend); 
        let dfval;
        if(this.draftpgId){
            dfval = this.draftpgId;
        }else{
            dfval = null;
        }
        await createDraftProvisioningRecords({jsonStr: dataToSend, draftpgId : dfval, oppId: this.opportunityId})
            .then(result => {
                if(result){
                    this.provisioningGroup = result;
                    this.isSaveDraftinProcess = false;
                    this.showToastMessage('success', ('Draft Saved successfully'));
                    this.handlegoToManageProv();
                }
            })
            .catch(error => {
                this.error = error;
                this.isSaveDraftinProcess = false;
                console.log('Error Occured: '+this.error);
            });
    }

    @track isSaveinProcess = false;
    async handleSaveRecord() {
        //Set Spinner
        this.isSaveinProcess = true;

        let provisioningWrapper = {};
        provisioningWrapper.domain = this.domain;
        provisioningWrapper.additionalDomain = this.additionalDomain;
        provisioningWrapper.preferedZIAReason=this.preferedZIAReason;
        provisioningWrapper.startDate = this.startdate;
        provisioningWrapper.opportunityId = this.opportunityId;
        provisioningWrapper.accountId = this.accountId;
        provisioningWrapper.preferredZIA = this.preferredZIA;
        provisioningWrapper.crossPlatformProductId = this.crossPlatformProductId;
        provisioningWrapper.crossPlatformProductName = this.crossPlatformProductName;
        provisioningWrapper.crossPlatformSelected = this.crossPlatformSelected;
        provisioningWrapper.postureControlSelected = this.postureControlSelected;
        provisioningWrapper.workloadCommunicationOnly = this.workloadCommunicationOnly;
        provisioningWrapper.selectedPostureControlProducts = this.selectedPostureControlProducts;
        provisioningWrapper.selectedPostureControlProdAddOn = this.selectedPostureControlProdAddOn;
        provisioningWrapper.numberOfWorkloads = this.numberOfWorkloads;
        //IBA -511
        if(this.pgForSubscription && this.withPrimaryQuoteProducts){
            provisioningWrapper.pgForSubscription = this.pgForSubscription;
        }
        else{
            provisioningWrapper.pgForSubscription = false;
        }

        provisioningWrapper.preferredZPA = this.preferredZPA;
        provisioningWrapper.associatedcloud = this.associatedZiaCloudValue;
        provisioningWrapper.assignedToCred = this.assignedTo;
        //IBA-3581
        provisioningWrapper.exceptionToCluster=this.checkexceptiontocluster;
        provisioningWrapper.withPrimaryQuoteProducts = this.withPrimaryQuoteProducts;

        //IBA-2924 START
        if(this.NanologCluster){
            provisioningWrapper.nanoLogCluster = this.NanologCluster;
        }
        if(this.SandboxCluster){
            provisioningWrapper.sandboxCluster = this.SandboxCluster;
        }
        if(this.SMCCluster){
            provisioningWrapper.SMCDSSCluster = this.SMCCluster;
        }
        //IBA-2924 END

        provisioningWrapper.provProdWrapper = [];
        provisioningWrapper.provContactWrapper = [];

        for(var i = 0; i < this.credentialList.length; i++) {
            let provisioningContacts = {};
            if(this.credentialList[i].IsUser){
                 provisioningContacts.userId = this.credentialList[i].RecID;
            }else{
                 provisioningContacts.contactId = this.credentialList[i].RecID;
            }
            provisioningContacts.contactType = this.credentialList[i].Type;
            provisioningContacts.email = this.credentialList[i].record?.Email;
            provisioningWrapper.provContactWrapper.push(provisioningContacts);
            if(this.credentialList[i].Type === this.assignedTo){
                provisioningWrapper.initialLoginCredentialsReceiverEmail = this.credentialList[i].record?.Email;
            }
        }

        provisioningWrapper['provProdWrapper'].push(...this.selectedProdsFromChild);
        
        let dataToSend = JSON.stringify(provisioningWrapper);
        var selProdLine =[];
        selProdLine = this.selectedProdLine;
        if(this.crossPlatformSelected==true){
            selProdLine = this.selectedProdLineForCrossPlatform;
        }

        await createProvisioningRecords({jsonStr: dataToSend,selProd: selProdLine})
            .then(result => {
                let baseUrl = 'https://' + location.host + '/';
                this.currentStep = "4";
                this.provisioningGroup = result;
                result.forEach(pgRec => {
                    pgRec.pgUrl = baseUrl + pgRec.Id;
                });

                //Code chnage to archive PRG after successful provisioning of Draft PRG via 'Edit Draft' functionality.
                if(this.draftpgId){
                    updateDraftPGStatus({draftpgId : this.draftpgId})
                        .then(result=>{
                            if(result == 'Success'){
                                this.draftpgId = undefined;
                            }
                        })
                        .catch(error => {
                            this.hasError = true;
                            this.error = error;
                        });
                }
                this.isSaveinProcess = false;
            })
            .catch(error => {
                this.error = error;
                this.template.querySelector('c-custom-toast-component').showToast('error',  this.errorMessages);
                this.isSaveinProcess = false;
                console.log('Error Occured: '+this.error);
            });
    }

    addInitialRow(){
        /*this.credList.push ({
            Label:'',
            Type: '',
            Index : this.index,
            RecID : '',
            IsUser : true,
            unfinished : true,
            typeOptionList : this.custtypeoptions,
            filterClause : '',
            isFirst : true
        });*/

        this.NcCredList.push ({
            Type: '',
            Index : this.clIndex,
            RecID : '',
            IsUser : false,
            unfinished : true,
            typeOptionList : this.custtypeoptions,
            filterClause : '',
            isFirst : true
        });

        this.clIndex++;
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
                this.credList[i].isFirst = i == 0 ? true : false;
            }
            return notValid>0 ? true : false;
        }else{
            return true;
        }
    }

    addRow(){
        this.credList.push ({
            Label:'',
            Type: '',
            Index : this.index,
            RecID : '',
            IsUser : true,
            unfinished : true,
            typeOptionList : this.custtypeoptions,
            showCopyContact:false
        });
        this.index++;
        this.validateCredDetails();
    }

    removeRow(event){
        let ind = event.currentTarget.dataset.id;
        let selectedcredList=[];
        if(ind){
            if(this.credList.length>0){
                this.credList.splice(ind, 1);
            }
            //Reset the index for the splice
            this.index = 0
            for (var i = 0; i < this.credList.length; i++) {
                this.credList[i].Index = this.index;
                this.index++;
                selectedcredList.push(this.credList[i].Label);
            }
            if(!selectedcredList.includes('Sales Engineer')){
                this.showAssociateSEButton=false;
            }
        }
    }

    //Helper methods
    generateInQuery(accList){
        let inQuery = '('
		if(accList){
            accList.forEach(currentItem => {
                inQuery+= '\''+currentItem+'\' ,';
            });
		}
        inQuery = inQuery.slice(0, -1);
        inQuery = inQuery + ')';
        return inQuery;
	}

    getCustomOptionLabel(type){
        let label = type;
        this.custOptionAvilable.forEach(currentItem => {
            if( currentItem.value == type){
                label = currentItem.label;
            }
        });
        return label;
    }

    checkIfCredExists(ele){
        let ret = false;
        if(this.credentialList && this.credentialList.length > 0){
            for (var i = 0; i < this.credentialList.length; i++) {
               if(this.credentialList[i].Type == ele.value){
                    ret = true;
                    break;
                }
            }
        }
        return ret;
    }

    fillLineTypeActiveSectionList(){
        if(this.crossPlatformSelected==false){
            this.activeLineTypeSections = [];
            this.selectedProdLine.forEach(currentItem => {
                if(currentItem!='Posture Control'){
                    this.activeLineTypeSections.push(currentItem);
                }
            });
        }
        if(this.crossPlatformSelected==true){
            this.activeLineTypeSections = [];
            this.selectedProdLineForCrossPlatform.forEach(currentItem => {
                if(currentItem!='Posture Control'){
                    this.activeLineTypeSections.push(currentItem);
                }
            });
        }
    }
    
    showToastMessage(type, errMsg) {
        this.template.querySelector('c-custom-toast-component').showToast(type, errMsg);
    }

    //getter Methods
    get showFirstStep() {
        return this.currentStep && this.currentStep === "1" ? true : false;
    }

    get showSecondStep() {
        return this.currentStep && this.currentStep === "2" ? true : false;
    }

    get showThirdStep() {
        return this.currentStep && this.currentStep === "3" ? true : false;
    }

    get showForthStep() {
        return this.currentStep && this.currentStep === "4" ? true : false;
    }

    get isZPA(){
        let isZPA = false;
        if(this.selectedProdLine){
            this.selectedProdLine.forEach(ele =>{
                switch(ele) {
                    case 'ZPA':
                        isZPA = true;
                        break;
                }
            });  
        }
        if(this.selectedPLforScreen1){
            if(this.selectedPLforScreen1.includes('ZPA')){
                isZPA=true;
            }
        }
        if(this.crossPlatformSelected){
            this.selectedProdLineForCrossPlatform.forEach(ele =>{
                switch(ele) {
                    case 'ZIA':
                        isZPA = true;
                        break;
                }
            });  
        }
        return isZPA;
    }

    get isZIA(){
        let isZIAThere = false;
        if(this.selectedProdLine){
            this.selectedProdLine.forEach(ele =>{
                switch(ele) {
                    case 'ZIA':
                        isZIAThere = true;
                        break;
                }
            });  
        }
        if(this.selectedPLforScreen1){
            if(this.selectedPLforScreen1.includes('ZIA')){
                isZIAThere=true;
            }
        }
        if(this.crossPlatformSelected){
            this.selectedProdLineForCrossPlatform.forEach(ele =>{
                switch(ele) {
                    case 'ZIA':
                        isZIAThere = true;
                        break;
                }
            });  
        }
        return isZIAThere;
    }

    get errorMessages() {
        return reduceErrorsUpgradedAdvanced(this.error);
    }

    get ziaCloudOptions() {
        if(this.ziapreferedcloud) {
           return [
                { label: this.ziapreferedcloud, value: this.ziapreferedcloud },
                { label: 'Zscaler.net', value: 'zscaler.net' },
                { label: 'Zscalerone.net', value: 'zscalerone.net' },
                { label: 'ZscalerTwo.net', value: 'zscalertwo.net' },
                { label: 'Zscalerbeta.net', value: 'zscalerbeta.net' },
                { label: 'Zscloud.net', value: 'zscloud.net' },
                { label: 'Zscalerthree.net', value: 'zscalerthree.net' },
                { label: 'Zscalergov.net', value: 'zscalergov.net' }
            ];
        }else{
            return [
                { label: 'Zscaler.net', value: 'zscaler.net' },
                { label: 'Zscalerone.net', value: 'zscalerone.net' },
                { label: 'ZscalerTwo.net', value: 'zscalertwo.net' },
                { label: 'Zscalerbeta.net', value: 'zscalerbeta.net' },
                { label: 'Zscloud.net', value: 'zscloud.net' },
                { label: 'Zscalerthree.net', value: 'zscalerthree.net' },
                { label: 'Zscalergov.net', value: 'zscalergov.net' },
            ];
        }
    }
    
    get zpaCloudOptions() {
        return [
            { label: 'ZPA Production', value: 'ZPA Production' },
            { label: 'ZPA Beta', value: 'ZPA Beta' },
        ];
    }

    get productlineOptions() {
        return [
            { label: 'ZIA', value: 'ZIA' },
            { label: 'ZPA', value: 'ZPA' },
            { label: 'ZDX', value: 'ZDX' },
            { label: 'Workload Protection', value: 'Workload Protection' },
            { label: 'Workload Segmentation', value: 'Workload Segmentation' },
            { label: 'Workload Communication', value: 'Workload Communication' },
            { label: 'Zscaler for Users (Cross Platform)', value: 'Zscaler for Users (Cross Platform)' },
            { label: 'Posture Control', value: 'Posture Control' }
        ];
    }

    get productOptionsForPostureControl() {
        return [
            { label: 'Posture Control Essentials', value: 'ZPC-ESS-PRE' },
            { label: 'Posture Control Advanced', value: 'ZPC-ADV-PRE' },
        ];
    }

    get addOnsForPostureControl() {
        return [
            { label: 'Posture Control Vulnerability', value: 'ZPC-VULN-PRE' },
            { label: 'Posture Control IaC', value: 'ZPC-IAC-PRE' },
        ];
    }

    get associatedZiaCloudsOptions(){
        let optionAvilable = [];
        if(this.zpaOnly){
            optionAvilable.push({ label: 'ZPA Only', value: 'ZPA Only' });
        }else if (! this.workloadCommunicationOnly){
            optionAvilable.push({ label: 'Request New ZIA Tenant', value: 'Request New ZIA Tenant' });
        }
       
        
        if(this.zscCloudName){
            this.zscCloudName.forEach(zc => {
                optionAvilable.push({ label: zc.Name, value: zc.Id});
            });
        }
        return optionAvilable;
    }

    get assignCredTo(){
        //197
        let optionAvilable = [];
        this.credList?.forEach(cred => {
            if(cred.Type && cred.Label && cred.RecID){
                optionAvilable.push({label:cred.Label , value:cred.Type});
            }
        });
        return optionAvilable;
    }

    get custtypeoptions() {
        let options = [];
        this.custOptionAvilable.forEach(element=>{
            let chk = this.checkIfCredExists(element);
            if(!chk){
                options.push(element); 
            }
        });
        return options;
    }

    get credentialList(){
        let credL = this.credList;
        let acclIst = [];
        acclIst.push(this.accountId);
        if(credL){
            for (var i = 0; i < credL.length; i++) {
                switch(credL[i].Type) {
                    case 'SALES_ENGINEER':
                        credL[i].IsUser = true;
                        credL[i].filterClause = 'where Profile.UserLicense.name =' + '\'' +'Salesforce' + '\'' + ' OR '+'Profile.UserLicense.name ='+ '\''+ 'Salesforce Platform'+ '\''  ;
                    break;
                    default:
                        credL[i].IsUser = false;
                        credL[i].filterClause =  'where accountid in ' + this.generateInQuery(acclIst);
                }
            }
        }
        return credL;
    }

    @track businessPrimaryAdded = false;
    get isBusinessPrimaryAdded(){
        let added = false;
        this.credList?.forEach(cred => {
            if(cred.Type && cred.Type == 'BUSINESS_PRIMARY'){
               added = true;
            }
        });
        this.businessPrimaryAdded = added;
        return added;
    }
    
    @track updatesSeUser;
    get seUserId(){
        if(this.updatesSeUser){
            return this.updatesSeUser;
        } else {
          return getFieldValue(this.oppt.data, SE_NAME);
        }
    }

    @wire(getRecord, { recordId: '$seUserId', fields: ['User.name', 'User.email'] })
    serecord;

    //Handler Event Methods
    handleDomain(event){
        this.domain=event.target.value;
        this.domainCheck();
    }

    handleAddDomain(event){
        this.additionalDomain=event.target.value;
    }

    handleStartDate(event){
        this.startdate=event.target.value;
    }

    handleZiaCloudChange(event) {
        this.preferredZIA = event.detail.value;
        if(this.preferredZIA != this.ziapreferedcloud){
            this.showReason=true;
        }else{
            this.showReason=false;
        }
        this.domainCheck();
        var searchComp = this.template.querySelectorAll('c-generic-search-component');
        console.log(searchComp);
        Array.from(searchComp).forEach(function(item){
            item.handleClose();
        });
    }
    
    handleZIAreason(event){
        this.preferedZIAReason=event.detail.value;
    }

    handleZpaCloudChange(event) {
        this.preferredZPA = event.detail.value;
    }

    @track showSpinner=false;
    @track disableDomain=false;
    @track hasPrgTenant =false;
    handleAssociatedZIACloudChange(event) {
        this.associatedZiaCloudValue = event.detail.value;
        
        if(this.selectedProdLine.length==1 && (this.selectedProdLine=='ZDX' || this.workloadCommunicationOnly===true)  && event.detail.value!='Request New ZIA Tenant'){
            this.disableDomain=true;
            //this.showSpinner=true;
           
            if(this.prghasTenant){
                this.fetchDomainandPrefCloud();
            }else if(this.prhasTenant){
                this.fetchDomainandPrefCloudfromPR();
            }
        }else{
            this.domain= this.defaultDomain;
            //this.preferredZIA=this.ziapreferedcloud;
            this.disableDomain=false;
        }
        console.log('prghasTenant1----'+this.prghasTenant);
        console.log('hasPrgTenant1---->'+this.hasPrgTenant);
      /*  if(this.workloadCommunicationOnly==true && this.hasPrgTenant==false){
            this.showToastMessage('error',('Please select another Tenant , This tenant is not associated to a Provisioning Group'));
            this.showSpinner=false;
            return;

        }*/
    }
    

    fetchDomainandPrefCloud(){
        getTenantDetails({seltenant: this.associatedZiaCloudValue})
        .then(result=>{
            if(result!=null){
                this.domain=result.Organization_Domain__c;
                this.preferredZIA=result.Preferred_Cloud__c;
                this.hasPrgTenant=true;
                this.showSpinner=false;
                console.log('Printing hasPrgTenant 0'+this.hasPrgTenant);

            }else{
                this.showSpinner=false;
                this.showToastMessage('error',('Tenant is not available for selection , Please select another Tenant'));
                return;
            } 

        })
    }

    fetchDomainandPrefCloudfromPR(){
        getTenantDetailsfromPR({seltenant: this.associatedZiaCloudValue})
        .then(result=>{
            if(result!=null){
                this.domain=result.Organization_Domain__c;
                this.preferredZIA=result.Preferred_Cloud__c;
                this.showSpinner=false;
            }
        })
    }

    @track showProductsScreen = false;
    handleAssignedToCredChange(event){
        this.assignedTo=event.detail.value;
        if(this.businessPrimaryAdded){
            this.showProductsScreen = true;
        }
    }

    handlePlChange(event){
        var val = event.detail.value;
        var state = false;
        if((this.selectedProdLine.includes('ZIA') && !val.includes('ZIA'))
            || (!this.selectedProdLine.includes('ZIA') && val.includes('ZIA'))){
            state = true;
        }
        this.selectedProdLine = event.detail.value;
        
        this.selectedProdLineMinusPostureControl = this.selectedProdLine.filter(rec => rec!='Posture Control');
        
        console.log('this.selectedProdLine'+this.selectedProdLine);
        console.log('this.selectedProdLineMinusPostureControl'+this.selectedProdLineMinusPostureControl);
        if(!state){
            this.associatedZiaCloudValue=null;
        }
        if(this.selectedProdLine.length>1 && this.selectedProdLine.includes('ZDX')){
            this.disableDomain=false;
            this.domain=this.defaultDomain;
        }

        if(this.selectedProdLine.includes('Zscaler for Users (Cross Platform)')){
            this.crossPlatformSelected = true;
        }else{
            this.crossPlatformSelected = false;
            this.selectedCrossPlatformProduct =[];
        }

        if(this.selectedProdLine.includes('Posture Control')){
            this.postureControlSelected = true;
            this.showNumberOfLoads = true;
        }else{
            this.postureControlSelected = false;
            this.postureControlOptionsNeeded = false;
            this.showNumberOfLoads = false;
            this.selectedPostureControlProducts =[];
            this.selectedPostureControlProdAddOn =[];
        }

        if(this.selectedProdLine.includes('Posture Control') && this.selectedProdLine.length==1){
            this.onlyPostureControlSelected = true;
        }else{
            this.onlyPostureControlSelected = false;
        }


        if(this.crossPlatformSelected==false){
            getALLProductSKUforTable({"prodLine":this.selectedProdLine , "priceList":this.priceList})
            .then(result => {
                this.updatepgProductskulist1(result);
            })
            .catch(error => {
                this.error = error;
                console.log('Error Occured: '+this.error);
            });
        }
        
        if(!this.priceList.includes('FY23') && this.crossPlatformSelected==true && this.selectedProdLine.length == 1){
            this.oldPriceListSelected = true;
            this.disableAddProducts = true;
        }else{
            this.oldPriceListSelected = false;
            this.disableAddProducts = false;
        }
       
    }
    
    handleCrossPlatformProduct(event){
        if(!this.priceList.includes('FY23') && this.crossPlatformSelected==true && this.selectedProdLine.length == 1){
            this.oldPriceListSelected = true;
            this.disableAddProducts = true;
        }else{
            this.oldPriceListSelected = false;
            this.disableAddProducts = false;
        }
        this.selectedCrossPlatformProduct = event.detail.value;
        this.checkForProductsinThisCrossPlatformProd();
        this.getCrossPlatformProductID();
    }

    handlePostureControlProduct(event){
        this.selectedPostureControlProducts= event.detail.value;
        if(this.selectedPostureControlProducts.includes('ZPC-ESS-PRE')){
            this.postureControlOptionsNeeded = true;
        }
        else{
            this.postureControlOptionsNeeded = false;
        }
    }

    handlePostureControlAddOn(event){
        this.selectedPostureControlProdAddOn= event.detail.value;
        console.log('this.selectedPostureControlProdAddOn'+this.selectedPostureControlProdAddOn);
    }

    async getCrossPlatformProductID(){
        await getCrossPlatformProduct({prod: this.selectedCrossPlatformProduct})
        .then(result => {
            if(result){
                this.crossPlatformProductId = result[0].Id;
                this.crossPlatformProductName = result[0].Name;
                this.crossPlatformProductCode.push(result[0].ProductCode);
                this.crossPlatform = result;
            }
        })
        .catch(error => {
            this.error = error;
            console.log('Error Occured: '+this.error);
        });
    }

    handleAddNoOfLoads(event){
        this.numberOfWorkloads = event.detail.value;
    }

    async checkForProductsinThisCrossPlatformProd(){
         await productsInThisCrossPlatform({prod: this.selectedCrossPlatformProduct})
        .then(result => {
            if(result){
                this.selectedProdLineForCrossPlatform=[];
                this.preSelectedProductsForCrossPlatform=[];
                const tempProdline =[];
                for (let value of Object.keys(result)) {
                    this.preSelectedProductsForCrossPlatform.push(value);
                }
                for (let value of Object.values(result)) {
                    tempProdline.push(value);
                }
                console.log('tempProdline'+tempProdline);
                console.log('this.preSelectedProductsForCrossPlatform'+this.preSelectedProductsForCrossPlatform);
                var sortOrder = ['ZIA', 'ZPA', 'ZDX'];
                this.selectedProdLineForCrossPlatform= tempProdline.sort(function(a, b) {
                    return sortOrder.indexOf(a) - sortOrder.indexOf(b);
                });
                getALLProductSKUforTable({"prodLine":this.selectedProdLineForCrossPlatform,  "priceList":this.priceList})
                .then(result => {
                    this.updatepgProductskulist1(result);
                })
                .catch(error => {
                    this.error = error;
                    console.log('Error Occured: '+this.error);
                });
               }
        })
        .catch(error => {
            this.error = error;
            console.log('Error Occured: '+this.error);
        });
    }
    
    updatepgProductskulist1(skulist){
        var pgProductCopy = [];
        if(this.crossPlatformSelected==false){
            for(var i = 0; i < this.selectedProdLine.length; i++) {
                var lineType = this.selectedProdLine[i];
                var skuForline = [];
                for(var j = 0; j< skulist.length; j++) {
                    if(lineType===skulist[j].Product_Line__c){
                        skuForline.push(skulist[j]);
                    }
                }
                pgProductCopy.push({
                    "lineType": lineType,
                    "skuList" : skuForline
                });
            }
            this.pgProduct = pgProductCopy;
        }
        if(this.crossPlatformSelected==true){
            for(var i = 0; i < this.selectedProdLineForCrossPlatform.length; i++) {
                var lineType = this.selectedProdLineForCrossPlatform[i];
                var skuForline = [];
                for(var j = 0; j< skulist.length; j++) {
                    if(lineType===skulist[j].Product_Line__c){
                        skuForline.push(skulist[j]);
                    }
                }
                pgProductCopy.push({
                    "lineType": lineType,
                    "skuList" : skuForline
                });
            }
            this.pgProduct = pgProductCopy;
            console.log('this.pgProduct',this.pgProduct);
        }
        if(this.selectedProdLine){
            this.setassociatedcloudvisibility(this.selectedProdLine);
        }
        if(this.crossPlatformSelected){
            this.setassociatedcloudvisibility(this.selectedProdLineForCrossPlatform);
        }
        
        if(this.selectedProdLine.includes('ZPA') && this.selectedProdLine.length==1){
            this.zpaOnly=true;
        }else{
            this.zpaOnly=false;
        }
        if(this.selectedProdLine.includes('Workload Communication') && this.selectedProdLine.length == 1){
            this.workloadCommunicationOnly =true;
        }else{
            this.workloadCommunicationOnly=false;
        }
        
    }

    setassociatedcloudvisibility(plinelist){
        if(plinelist.includes('ZPA') || plinelist.includes('ZDX') || plinelist.includes('Workload Protection') || plinelist.includes('Workload Segmentation')){ //plinelist.includes('Workload Communication')
            this.showAssociatedCloud=true;
         } 
        else if(plinelist.includes('Workload Communication') && plinelist.length == 1){
            this.showAssociatedCloud=true;
        }
        else{
            this.showAssociatedCloud=false;
        }
    
    }
    setassociatedcloudvisibilityPQ(plinelist){
        if(plinelist.includes('ZPA') || plinelist.includes('ZDX') || plinelist.includes('Workload Protection') || plinelist.includes('Workload Segmentation')){  // plinelist.includes('Workload Communication')
            this.showAssociatedCloud=true;
          } 
        else if(plinelist.includes('Workload Communication') && plinelist.length == 1){
            this.showAssociatedCloud=true;
        }
        else{
            this.showAssociatedCloud=false;
         }
        
    }

    updatepgProduct(pline){
        var pgProductCopy = [...this.pgProduct];
        for(var i = 0; i < pgProductCopy.length; i++) {
            var pgp = pgProductCopy[i];
            var edited = false;

            //If SKU selection got changed then dont edit selectedPOCProducts just update sku alone.
            if(pgp.lineType === pline){
                edited = true;
            }
        }

        //this is selected for first time. initialize skuList
        if(!edited){
            pgProductCopy.push({
                "lineType": pline,
            });

            getALLProductSKUforTable({"prodLine":pline, "priceList":this.priceList})
                .then(result => {
                    this.updatepgProductskulist(result,pline);
                })
                .catch(error => {
                    this.error = error;
                    console.log('Error Occured: '+this.error);
                });
        }
        this.pgProduct = pgProductCopy;
    }

    updatepgProductskulist(skulist,pline){
        var pgProductCopy = [...this.pgProduct];
        for(var i = 0; i < pgProductCopy.length; i++) {
            var pgp = pgProductCopy[i];
            if(pgp.lineType===pline){
                pgp.skuList=skulist
            }
        }
        this.pgProduct = pgProductCopy;
    }

    cleanpgProduct(plinelist){
        var pgProductCopy = [];
        for(var i = 0; i < this.pgProduct.length; i++) {
            if(plinelist.includes(this.pgProduct[i].lineType)){
                pgProductCopy.push(this.pgProduct[i]);
            }
        }
        this.pgProduct = pgProductCopy;
    }

    handleTypeChange(event){
        if(event.detail.value){
            for (var i = 0; i < this.credList.length; i++) {
                if(i == event.target.dataset.id){
                    this.credList[i].Type = event.detail.value;
                    this.credList[i].Label = this.getCustomOptionLabel(event.detail.value);
                    this.credList[i].RecID =  undefined;
                    this.credList[i].record = undefined;
                    if(this.credList[i].Type!=null || this.credList[i].Type!=''){
                        this.credList[i].showSeleectContact=true;
                    }else{
                        this.credList[i].showSeleectContact=false;
                    }
                    if(this.credList[i].Type=='SALES_ENGINEER'){
                        this.credList[i].RecID=this.seUserId;
                        this.credList[i].showCopyContact=true;
                        this.credList[i].showSeleectContact=true;
                        this.showAssociateSEButton=true;
                    }
                }
            }
        }else{
            this.credList[event.target.dataset.id].Type = null;
            this.credList[event.target.dataset.id].showSeleectContact=false;
        }
    }

    handleSectionToggle(event) {
        const openSections = event.detail.openSections;
    }

    handleLookup(event){
        if(event.detail.data && event.detail.data.sourceId !==  undefined){
            for (var i = 0; i < this.credList.length; i++) {
                if(i === event.detail.data.sourceId){
                    this.credList[i].RecID = event.detail.data.recordId ? event.detail.data.recordId : '';
                    this.credList[i].record = event.detail.data.record;
                    this.credList[i].unfinished = false;
                    if(this.credList[i].Type == 'SALES_ENGINEER' ){
                        this.updatesSeUser = event.detail.data.recordId ? event.detail.data.recordId : '';
                    }
                }
            }
        }
    }

    handleProvistioningContactsBack(){
        this.currentStep="1";
    }

    domainCheck(){
        domainCheckWithExistingCloud({domain:this.domain,preferredZIA:this.preferredZIA})
            .then(result=>{
                this.domainNotAvailable=result;
                return result;
            })
            .catch(error=>{
                this.error = error;
            });
    }
    
    handleDisplayProducts() {
        if(this.domainNotAvailable==true && this.associatedZiaCloudValue==='Request New ZIA Tenant'){
            this.showToastMessage('error',('This domain is already provisioned for an existing tenant'));
            this.error=true;
            return;
        }
        var productLinex=this.selectedProdLine;
        this.iserror=false;
        if(this.selectedProdLine.length == 0 || this.selectedProdLine=='' ){
            this.showToastMessage('error', ('Please Select Product Line'));
            this.iserror=true;
            return;
        }
        
        if(this.domain=='' || this.domain==null){
            this.showToastMessage('error', ('Please add Domain'));
            this.iserror=true;
            return;
        }
        
        if(productLinex.includes('ZIA') && this.preferredZIA==null){
            this.showToastMessage('error', ('Please add Preferred ZIA Cloud'));
            this.iserror=true;
            return;
        }
        
        if((productLinex.includes('ZPA') || productLinex.includes('ZDX') || productLinex.includes('Workload Protection') || productLinex.includes('Workload Segmentation') || productLinex.includes('Zscaler for Users (Cross Platform)') ) && this.associatedZiaCloudValue == null){
            this.showToastMessage('error', ('Please Select Associated ZIA Cloud'));
            this.iserror=true;
            return;
        }

        if(productLinex.includes('Workload Communication') && productLinex.length==1 && this.associatedZiaCloudValue == null){
            this.showToastMessage('error', ('Please Select Associated ZIA Cloud'));
            this.iserror=true;
            return;
        }
        
        if(productLinex.includes('ZIA')  && this.showReason==true && (this.preferedZIAReason=='' || this.preferedZIAReason==null)){
            this.showToastMessage('error',('Please enter reason to change Preferred  ZIA Cloud'));
            this.error=true;
            return;
        }

        if(productLinex.includes('Zscaler for Users (Cross Platform)') && this.selectedCrossPlatformProduct==null){
            this.showToastMessage('error',('Please select only one Cross Platform Product'));
            this.error=true;
            return;
        }

        if(productLinex.includes('Zscaler for Users (Cross Platform)') && productLinex.length>1){
            this.showToastMessage('error',('Zscaler for Users (Cross Platform) cannot be selected with any other product line.'));
            this.error=true;
            return;
        }

        if((productLinex.includes('Workload Protection') ||  productLinex.includes('Workload Segmentation') ||  productLinex.includes('Workload Communication') 
            ||  productLinex.includes('ZPA') ||  productLinex.includes('ZDX')) && !productLinex.includes('ZIA') && this.associatedZiaCloudValue==='Request New ZIA Tenant'){
            this.showToastMessage('error',('ZIA Product Line needs to be selected in order to Request New ZIA Tenant'));
            this.error=true;
            return;
        }

        if(this.selectedPostureControlProducts == false && this.selectedProdLine.includes('Posture Control')){
            this.showToastMessage('error',('Please select a Posture Control Product to proceed ahead'));
            this.error = true;
            return;
        }
        if(this.workloadCommunicationOnly==true && this.hasPrgTenant==false){
            this.showToastMessage('error',('Tenant is not available for selection , Please select another Tenant'));
            this.showSpinner=false;
            return;

        }

       

        else if(this.iserror==false){
            this.currentStep="2";
            this.fillLineTypeActiveSectionList();
        }

    }

    handleBackToProductScreen(){
        if(this.withPrimaryQuoteProducts==true){
            this.selectedProdLinewithPQ=[];
            this.currentStep="1";
        }else if(this.onlyPostureControlSelected){
            this.currentStep="1";
        }
        else{
            this.currentStep="2";
        }
    }
    
    handleBacktonewTenantButton() {
        const pgprocoms = this.crossPlatformSelected==false?this.template.querySelectorAll('c-p-g-product-selection-component'):
                                                        this.template.querySelectorAll('c-cross-platform-component');
        this.selectedProdsFromChild=[];
        for(var i = 0; i < pgprocoms.length; i++) {
            let provisioningProductWrapper = {};
            if(pgprocoms[i].selectedRadioProductrow != null) {
                provisioningProductWrapper.productName = pgprocoms[i].selectedRadioProductrow.Name;
                provisioningProductWrapper.productCode = pgprocoms[i].selectedRadioProductrow.ProductCode;
                provisioningProductWrapper.prodline = pgprocoms[i].selectedRadioProductrow.Product_Line__c;
                provisioningProductWrapper.productSKUId = pgprocoms[i].selectedRadioProductrow.Id;
                this.selectedProdsFromChild.push(provisioningProductWrapper);
                for(var j = 0; j < pgprocoms[i].selectedItemsList.length; j++) {
                    let provisioningAddOnProductWrapper = {};
                    if(pgprocoms[i].selectedItemsList != null) {
                        provisioningAddOnProductWrapper.productName = pgprocoms[i].selectedItemsList[j].Name;
                        provisioningAddOnProductWrapper.productCode = pgprocoms[i].selectedItemsList[j].ProductCode;
                        provisioningAddOnProductWrapper.prodline = pgprocoms[i].selectedItemsList[j].Product_Line__c;
                        provisioningAddOnProductWrapper.productAddonnID = pgprocoms[i].selectedItemsList[j].Id;
                        this.selectedProdsFromChild.push(provisioningAddOnProductWrapper);
                    }
                }
            }
        }
        this.currentStep="1";
    }

    handlegoToManageProv(){
        if(this.recordId){
            var compDefinition = {
                componentDef: "c:manageProvisioningActionHL",
                attributes: {
                    recordId: this.recordId
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

    handleCancelNavigate() {
        if(this.recordId){
            var compDefinition = {
                componentDef: "c:manageProvisioningActionHL",
                attributes: {
                    recordId: this.recordId
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

    handleBacktoOppButton(){
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.opportunityId,
                actionName: 'view'
            }
        });
    }

    @wire(fillProductListFromPrimaryQuote , {opp:'$recordId'})
    getProductsFromPrimaryQuote({error,data}){
        if(data && this.checkSKU){
            this.primaryQuoteProductsList=data;
            for(var i=0;i<data.length;i++){
                if(!this.selectedProdLine.includes(data[i].prodline)){
                    this.selectedProdLine.push(data[i].prodline);
                }
            }
            this.setassociatedcloudvisibility(this.selectedProdLine);
            
            if(this.selectedProdLine.includes('ZPA') && this.selectedProdLine.length == 1){
                this.zpaOnly=true;
            }else{
                this.zpaOnly=false;
            }
            if(this.selectedProdLine.includes('Workload Communication') && this.selectedProdLine.length == 1){
                this.workloadCommunicationOnly =true;
            }else{
                this.workloadCommunicationOnly=false;
            }
        }if(error){
            this.error = error;
            console.log('Error Occured: '+this.error);
        }
    }

    @wire(checkifPrimaryQuoteExist , {opp:'$recordId'})
    getPrimaryQuoteBoolean({error, data}){
        if(data){
            this.primaryQuoteExist=data;
            this.setassociatedcloudvisibility(this.selectedProdLine);
        }if(error){
            this.error = error;
            console.log('Error Occured: '+this.error);
        }
    }

    get primaryQuoteSKU(){
        return this.checkSKU ? true : false;
    }
    listofPLforPQ = [];
    //PO Checklist Methods
    openPrimaryQuoteCheckModal(event){
        this.checkSKU = event.target.checked;
        if(!this.checkSKU){
            this.primaryQuoteTenantCheck = true;
        }
        this.postureControlSelected= false;
        this.postureControlOptionsNeeded= false;
        this.showNumberOfLoads = false;
        if(event.target.checked){
            fillProductLineForPrimaryQuote({opp:this.opportunityId})
            .then(result=>{
                console.log('result@@@',result);
                this.selectedPLforScreen1 = result;

                this.selectedPLforScreen1.forEach(plres=>{
                    if(!this.listofPLforPQ.includes(plres)){
                        this.listofPLforPQ.push(plres);
                    }
                })
                console.log('Printing unique list'+this.listofPLforPQ);

                if(this.selectedPLforScreen1.length==0){
                    this.noProductsEligible = true;
                }
                this.setassociatedcloudvisibilityPQ(this.selectedPLforScreen1);
                if(this.listofPLforPQ.includes('ZPA') && this.listofPLforPQ.length == 1){
                    this.zpaOnly=true;
                }else{
                    this.zpaOnly=false;
                }
                if(this.selectedProdLine.includes('Workload Communication') && this.selectedProdLine.length == 1){
                    this.workloadCommunicationOnly =true;
                }else{
                    this.workloadCommunicationOnly=false;
                }
                if(this.selectedPLforScreen1.includes('Cross Platform')){
                    this.crossPlatformInPrimaryQuote=true;
                }
            })
            .catch(error=>{
                this.error = error;
                console.log('Error Occured: '+this.error);
            });
        }else{
            this.selectedPLforScreen1=[];
            this.showAssociatedCloud=false;
        }

    }

    checkForCrossPlatforminPrimaryQuote(){
        getAllProductLineForPrimaryQuote({opp:this.opportunityId})
            .then(result=>{
                console.log('result@@@',result);
                if(result.includes('Cross Platform')){
                    this.crossPlatformInPrimaryQuote=true;
                }else{
                    this.crossPlatformInPrimaryQuote=false;
                }
            })
            .catch(error=>{
                this.error = error;
                console.log('Error Occured: '+this.error);
            });
    }

    closePrimaryQuoteCheckModal() {
        this.primaryQuoteTenantCheck = false;
    }

    get withPrimaryQuoteProducts(){
        return this.primaryQuoteSKU == true && this.primaryQuoteExist ? true : false
    }

    cancelPrimaryQuoteUnCheck(){
        this.checkSKU = true;
        this.closePrimaryQuoteCheckModal();
    }

    submitPrimaryQuoteUnCheck(){
        this.checkSKU = false;
        this.markPrimaryQuoteUncheckReadOnly=true;
        this.closePrimaryQuoteCheckModal();
        this.selectedProdLine =[];
    }
    saveexceptiontocluster(event){
        if(event.target.checked){
       this.checkexceptiontocluster= true;
    }else{
        this.checkexceptiontocluster=false;
    }
       console.log('printing exception to cluster'+this.checkexceptiontocluster);
        
    }

    getCrossPlatformProducts(){
        getCrossPlatformProductsToShow()
        .then(result=>{
            if(result){
                
                result.forEach(element => {
                    this.productOptionsForCrossPlatform.push({ label: element.ProductCode, value: element.ProductCode});
                    
                });
            }
        })
        .catch(error=>{
            this.error = error;
        });
    }

    async getPriceListOfOpportunity(){
        await getPriceListFromOpp({ opp:this.recordId })
       .then(result => {
           if(result){
               this.priceList=result.Opp_Price_List__c;
               console.log('this.priceList'+ this.priceList);
           }    
       })
       .catch(error => {
           this.error = error;
           console.log('Error Occured: '+this.error);
       });
   }

    get hasUserProvisioningPermission(){
        return hasProvisioningPermission;
    }

    get NCCredentialList(){
        let credL = this.NcCredList;
        for (var i = 0; i < credL.length; i++) {
            credL[i].filterClause = 'where SF_Cloud__c = \''+ this.preferredZIA + '\' and Is_Disabled__c = FALSE';
        }
        return credL;
        
    }

    handleNCLookup(event){
        this.NanologCluster = event.detail.data.recordId;
        console.log(this.NanologCluster);
    }

    handleSCLookup(event){
        this.SandboxCluster = event.detail.data.recordId;
        console.log(this.SandboxCluster);
    }

    handleSMLookup(event){
        this.SMCCluster = event.detail.data.recordId;
        console.log(this.SMCCluster);
    }
}
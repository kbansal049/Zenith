import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import domainCheckWithExistingCloud from '@salesforce/apex/ProvisioningGroupController.domainCheckWithExistingCloud';
import getALLProductSKUforTable from '@salesforce/apex/ProvisioningGroupController.getALLProductSKUforTable';
import createProvisioningRecords from '@salesforce/apex/ProvisioningGroupController.createInternalProvisioningDetails';
import getDefaultContact from  '@salesforce/apex/ProvisioningGroupController.getDefaultContact';
import Internal_Provisioning_Price_List from '@salesforce/label/c.Internal_Provisioning_Price_List';

const createdPGColumns = [
    {label: 'Provisioning Group Name', fieldName: 'pgUrl', type:'url',
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

export default class NewInternalProvisioningTenant extends  NavigationMixin(LightningElement) {
    @track currentStep = "1";
    @track activeLineTypeSections;
    @track selectedProdLine = [];
    @track pgProduct=[];
    @track domain;
    @track showAssociatedCloud = false;
    @track showPreferredZiaCloud = false;  
    @track preferredZIA;
    @track ziapreferedcloud;
    @track preferredZPA='ZPA Production';
    @track defaultDomain;
    @track ziaCloudIdForZPA;
    @track associatedZiaCloudValue;
    @track showReason=false;
    @track preferedZIAReason;
    @track domainNotAvailable=false;
    @track zpaOnly=false;
    @track selectedProdsFromChild = [];    //to store products selected in child component during navigation
    @track selectedProductCode = [];
    @track filterClause;
    @track createdProvisioningGroup = createdPGColumns;
    @track priceList;

    @api accountId;
    @api accountId2;
    @api loggedInuser;
    @api selecteduserNamefordomain;
    @api loggedInUserId;
    @api selecteduserEmail;

    index = 0;

    fields = ["Name","Email","Phone"];
    displayFields = 'Name, Email, Phone';

    connectedCallback() {
        console.log('printing user name '+this.selecteduserEmail);
        this.fetchDefaultContact();
        console.log('new tenant'+this.accountId);
        console.log('selecteduserNamefordomain-->'+this.selecteduserNamefordomain);
        let resultusername = this.selecteduserNamefordomain.replace(/\s+/g, '').trim();
        let randomString=Math.floor((Math.random() * 100) + 1);
        this.domain=resultusername+randomString+'.zcaler.com';
        this.filterClause='where AccountId=\''+this.accountId+'\'' +'OR  AccountId='+'\''+this.accountId2+'\'';
        console.log('filterclause'+this.filterClause);
    }

    fetchDefaultContact(){
        getDefaultContact({email:this.selecteduserEmail})
            .then(result=>{
                console.log('Printing Contact'+result.Id);
                this.template.querySelector('c-generic-search-component').triggerChange(result.Id);
            })
      }

     showToastMessage(type, errMsg) {
        this.template.querySelector('c-custom-toast-component').showToast(type, errMsg);
    }
     
     get productlineOptions() {
        return [
            { label: 'ZIA', value: 'ZIA' },
            { label: 'ZPA', value: 'ZPA' },
            { label: 'ZDX', value: 'ZDX' },
            { label: 'Workload Protection', value: 'Workload Protection' },
            { label: 'Workload Segmentation', value: 'Workload Segmentation' },
            { label: 'Workload Communication', value: 'Workload Communication' },
            { label: 'Zscaler for Users (Cross Platform)', value: 'Zscaler for Users (Cross Platform)' }
        ];
    }

     get ziaCloudOptions() {
        return [
            { label: 'Zscaler.net', value: 'zscaler.net' },
            { label: 'Zscalerone.net', value: 'zscalerone.net' },
            { label: 'ZscalerTwo.net', value: 'zscalertwo.net' },
            { label: 'Zscalerbeta.net', value: 'zscalerbeta.net' },
            { label: 'Zscloud.net', value: 'zscloud.net' },
            { label: 'Zscalerthree.net', value: 'zscalerthree.net' },
            { label: 'Zscalergov.net', value: 'zscalergov.net' }
        ];
     }

     get associatedZiaCloudsOptions(){
        let optionAvilable = [];
        if(this.zpaOnly){
            optionAvilable.push({ label: 'ZPA Only', value: 'ZPA Only' });
        }else{
            optionAvilable.push({ label: 'Request New ZIA Tenant', value: 'Request New ZIA Tenant' });
        }
        return optionAvilable;
    }

     get zpaCloudOptions() {
        return [
            { label: 'ZPA Production', value: 'ZPA Production' },
            { label: 'ZPA Beta', value: 'ZPA Beta' },
        ];
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
        return isZIAThere;
    }
    
     get isZPA(){
        let isZPAflag = false;
        if(this.selectedProdLine){
            this.selectedProdLine.forEach(ele =>{
                switch(ele) {
                    case 'ZPA':
                        isZPAflag = true;
                        break;
                }
            });  
        }
        return isZPAflag;
    }

     handleDomain(event){
        this.domain=event.target.value;
        this.domainCheck();
    }

    handleZiaCloudChange(event) {
        this.preferredZIA = event.detail.value;
        console.log('preferd ZIA current value'+this.preferredZIA);       
        this.domainCheck();
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

    handleZpaCloudChange(event) {
        this.preferredZPA = event.detail.value;
    }
    
    handleAssociatedZIACloudChange(event) {
        this.associatedZiaCloudValue = event.detail.value;
    }

    setassociatedcloudvisibility(plinelist){
        console.log('Printing plinelist'+plinelist);
        if(plinelist.includes('ZPA') || plinelist.includes('ZDX') || plinelist.includes('Workload Protection') || plinelist.includes('Workload Segmentation')|| plinelist.includes('Workload Communication')){
            this.showAssociatedCloud=true;
        }else{
            this.showAssociatedCloud=false;
        }
    }

    domainCheck(){
        domainCheckWithExistingCloud({domain:this.domain,preferredZIA:this.preferredZIA})
            .then(result=>{
                console.log('domainCheck::'+result);
                this.domainNotAvailable=result;
                return result;
            })
            .catch(error=>{
                console.log('Error Occured'+this.error);
                this.error = error;
            });
    }

    handlePlChange(event){
        var val = event.detail.value;
        var state = false;
        if((this.selectedProdLine.includes('ZIA') && !val.includes('ZIA'))
            || (!this.selectedProdLine.includes('ZIA') && val.includes('ZIA')))
        {
            state = true;
        }
        this.selectedProdLine = event.detail.value;

        var plist = Internal_Provisioning_Price_List;
        this.priceList=Internal_Provisioning_Price_List;
       

        getALLProductSKUforTable({"prodLine":this.selectedProdLine, "priceList":plist})
        .then(result => {
            this.updatepgProductskulist1(result);
        })
        .catch(error => {
            console.log(error);
        });
    }

    updatepgProductskulist1(skulist){
        var pgProductCopy = [];
        console.log(' updatepgProductskulist1'+skulist);
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
        console.log('4562 ==>>> In updatepgProductskulist1(), this.pgProduct-->', JSON.stringify(this.pgProduct));
        if(this.selectedProdLine){
            this.setassociatedcloudvisibility(this.selectedProdLine);
        }
        
        if(this.selectedProdLine.includes('ZPA') && this.selectedProdLine.length==1){
            this.zpaOnly=true;
        }else{
            this.zpaOnly=false;
        }
    }

    handleDisplayProducts(){
        console.log('domain--->'+this.domain);
          if(this.selectedProdLine.length == 0 || this.selectedProdLine=='' ){
            this.showToastMessage('error', ('Please Select Product Line'));
            return;
        }
        if(this.domain=='' || this.domain==null || this.domain===undefined){
            this.showToastMessage('error',('Please enter domain before proceeding'));
            return;
        }
        if(this.selectedProdLine.includes('ZIA') && this.preferredZIA==null){
            this.showToastMessage('error', ('Please add Preferred ZIA Cloud'));
            return;
        }
        if((this.selectedProdLine.includes('ZPA') || this.selectedProdLine.includes('ZDX') || this.selectedProdLine.includes('Workload Protection') || this.selectedProdLine.includes('Workload Segmentation') || this.selectedProdLine.includes('Workload Communication')) && this.associatedZiaCloudValue == null){
            this.showToastMessage('error', ('Please Select Associated ZIA Cloud'));
            return;
        }
        if(this.selectedProdLine.includes('ZIA')  && this.showReason==true && (this.preferedZIAReason=='' || this.preferedZIAReason==null)){
            this.showToastMessage('error',('Please enter reason to change Preferred  ZIA Cloud'));
            return;
        }
        if(this.selectedcontact==null || this.selectedcontact===undefined || this.selectedcontact==''){
            this.showToastMessage('error',('Please select Contact'));
            return;
        }
        if(this.domainNotAvailable==true){
            this.showToastMessage('error',('This domain is already provisioned for an existing tenant'));
            this.error=true;
            return;
        }
        this.currentStep="2";
        this.fillLineTypeActiveSectionList();
        console.log('printing current Step-->'+this.currentStep);
    }

    fillLineTypeActiveSectionList(){
    this.activeLineTypeSections = [];
            this.selectedProdLine.forEach(currentItem => {
                this.activeLineTypeSections.push(currentItem);
            });
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
        console.log('4560 ==>>> In handleskuchange(), this.pgProduct-->', JSON.stringify(this.pgProduct));
    }

    @track selectedcontact;
    @track selectedContactName;
    @track selectedcontactEmail;
    handleContactSelected(event){
        this.selectedcontact=event.detail.data.recordId;
        this.selectedContactName=event?.detail?.data?.record?.Name;
        this.selectedcontactEmail= event?.detail?.data?.Email;
        console.log('selecteduser'+this.selecteduser);
        console.log('selecteduserName'+this.selecteduserName);
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
                    pgProductCopy[i].selectedPOCProducts.push({
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
                    });
                }
            }
        }
        this.pgProduct = pgProductCopy;
        console.log('4561 ==>>> In handleproductvaluechange(), this.pgProduct-->', JSON.stringify(this.pgProduct));
    }

    get showSecondStep() {
        console.log('inside show sec step');
        return this.currentStep && this.currentStep === "2" ? true : false;
    }
     
    get showFirstStep() {
        console.log('inside show 1 step');
        return this.currentStep && this.currentStep === "1" ? true : false;
    }

    get showThirdStep() {
        console.log('inside show 3 step');
        return this.currentStep && this.currentStep === "3" ? true : false;
    }
     
    handleCancelNavigate() {
        var compDefinition = {
            componentDef: "c:internalProvisioningComponent",
            attributes: {
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

    handleBacktonewTenantButton() {
        const pgprocoms =this.template.querySelectorAll('c-p-g-product-selection-component');
                                                       
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

    validateShowSubmitForProvisioningButton(){
        this.showWarning = false;
        console.log('account Id-->'+this.accountId);
        let showSubmitForProvisioningButton = false;
        const pgprocoms = this.template.querySelectorAll('c-p-g-product-selection-component');
        if(pgprocoms){
            let individualCheck = true;
            pgprocoms.forEach(pgSelection => {
                if(pgSelection.selectedRadioProductrow != null){
                    if(individualCheck && !pgSelection.selectedRadioProductrow){
                        individualCheck = false;
                        pgSelection.productSelectionMsg = true;
                    }
                }else{
                     individualCheck = false;
                    this.showToastMessage('error', ('Please Select Products before Proceeding.'));
                    return;
                }
            });
            showSubmitForProvisioningButton = individualCheck;
        }

        if(showSubmitForProvisioningButton){
            this.handleSaveRecord();
        }
    }

    @track isSaveinProcess;
    async handleSaveRecord(){
        this.isSaveinProcess = true;
        this.selectedProdsFromChild=[];
        const pgprocoms =this.template.querySelectorAll('c-p-g-product-selection-component');

         for(var i = 0; i < pgprocoms.length; i++) {
            let provisioningProductWrapper = {};
            if(pgprocoms[i].selectedRadioProductrow != null) {
                provisioningProductWrapper.productName = pgprocoms[i].selectedRadioProductrow.Name;
                provisioningProductWrapper.productCode = pgprocoms[i].selectedRadioProductrow.ProductCode;
                provisioningProductWrapper.prodline = pgprocoms[i].selectedRadioProductrow.Product_Line__c;
                provisioningProductWrapper.productSKUId = pgprocoms[i].selectedRadioProductrow.Id;
                //provisioningProductWrapper.isCBI = this.chekcIFProductISCBI(pgprocoms[i].selectedRadioProductrow);
                //provisioningProductWrapper.isDeception = this.checkIFProductIsDeception(pgprocoms[i].selectedRadioProductrow);
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
                       // provisioningAddOnProductWrapper.isCBI = this.chekcIFProductISCBI(pgprocoms[i].selectedItemsList[j]);
                        //provisioningAddOnProductWrapper.isDeception = this.checkIFProductIsDeception(pgprocoms[i].selectedItemsList[j]);
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

        let provisioningContacts = {};
        provisioningContacts.contactId =this.selectedcontact;
        provisioningContacts.contactType='BUSINESS PRIMARY';
        provisioningContacts.email=this.selectedcontactEmail;

        let provisioningWrapper = {};
        provisioningWrapper.domain = this.domain;
        provisioningWrapper.preferedZIAReason=this.preferedZIAReason;
        provisioningWrapper.accountId = this.accountId;
        provisioningWrapper.preferredZIA = this.preferredZIA;
        provisioningWrapper.preferredZPA = this.preferredZPA;
        console.log('Adding logged in user Id'+this.loggedInUserId);
        provisioningWrapper.loggedInUserId=this.loggedInUserId;
        provisioningWrapper.withPrimaryQuoteProducts=false;
        provisioningWrapper.associatedcloud = this.associatedZiaCloudValue;
        provisioningWrapper.selectedContactIntProv=this.selectedcontact;
        provisioningWrapper.provProdWrapper = [];
        provisioningWrapper.provContactWrapper = [];
        provisioningWrapper.provContactWrapper.push(provisioningContacts);

        provisioningWrapper['provProdWrapper'].push(...this.selectedProdsFromChild);
        let dataToSend = JSON.stringify(provisioningWrapper);
        var selProdLine =[];
        selProdLine = this.selectedProdLine;
        console.log('json data'+dataToSend);
        await createProvisioningRecords({jsonStr: dataToSend,selProd: selProdLine})
            .then(result => {
                let baseUrl = 'https://' + location.host + '/';
                console.log('result--->'+ JSON.stringify(result));
                this.currentStep = "3";
                this.provisioningGroup = result;
                result.forEach(pgRec => {
                    pgRec.pgUrl = baseUrl + pgRec.Id;
                });
                this.isSaveinProcess = false;
            })
            .catch(error => {
                this.error = error;
                this.template.querySelector('c-custom-toast-component').showToast('error',  this.errorMessages);
                this.isSaveinProcess = false;
                console.log('Error Occured: '+this.error);
            });
    }

    checkIFProductisBrokerEligible(prd){
        return prd.Provisioning_Broker_Eligible__c==true ? true:false;
    }
}